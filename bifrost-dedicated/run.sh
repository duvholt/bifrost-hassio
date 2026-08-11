#!/usr/bin/env bash
set -Eeuo pipefail

readonly CONFIG=/config/bifrost/config.yaml
readonly TMP_LINK=bifrost-lan-tmp

child=
slirp=
stopping=0

log() { printf '[bifrost-network] %s\n' "$*"; }
fail() { log "ERROR: $*"; exit 1; }

cleanup() {
    local status=$?
    trap - EXIT INT TERM
    [[ -z "${child}" ]] || kill -TERM "${child}" 2>/dev/null || true
    [[ -z "${child}" ]] || wait "${child}" 2>/dev/null || true
    [[ -z "${slirp}" ]] || kill -TERM "${slirp}" 2>/dev/null || true
    [[ -z "${slirp}" ]] || wait "${slirp}" 2>/dev/null || true
    ip link delete "${TMP_LINK}" 2>/dev/null || true
    log "Network cleanup complete"
    exit "${status}"
}

terminate() {
    stopping=1
    [[ -z "${child}" ]] || kill -TERM "${child}" 2>/dev/null || true
}

wait_link() {
    for _ in $(seq 1 100); do
        nsenter -t "${child}" -n ip link show "$1" >/dev/null 2>&1 && return
        kill -0 "${child}" 2>/dev/null || fail "Network namespace exited during setup"
        sleep 0.05
    done
    fail "Timed out waiting for interface $1"
}

trap cleanup EXIT
trap terminate INT TERM

[[ -r "${CONFIG}" ]] || fail "Missing ${CONFIG}"
[[ -c /dev/net/tun ]] || fail "Missing /dev/net/tun"

interface=$(ip -4 route show default | awk '$1 == "default" { print $5; exit }')
[[ -n "${interface}" ]] || fail "Could not detect the LAN interface"
internal_cidr=$(ip -4 route show dev hassio scope link | awk 'NR == 1 { print $1 }')
[[ -n "${internal_cidr}" ]] || fail "Could not detect the Supervisor network"

ipaddress=$(yq -er '.bridge.ipaddress' "${CONFIG}")
netmask=$(yq -er '.bridge.netmask' "${CONFIG}")
gateway=$(yq -er '.bridge.gateway' "${CONFIG}")
mac=$(yq -er '.bridge.mac' "${CONFIG}")
prefix=$(python3 -c \
    'import ipaddress,sys; print(ipaddress.IPv4Network("0.0.0.0/" + sys.argv[1]).prefixlen)' \
    "${netmask}")
python3 -c 'import ipaddress,sys; a,b,c=(ipaddress.ip_network(s,False) for s in sys.argv[1:]); raise SystemExit(a.overlaps(c) or b.overlaps(c))' \
    "${ipaddress}/${prefix}" "${internal_cidr}" 10.0.2.0/24 \
    || fail "LAN or Supervisor network overlaps the slirp network 10.0.2.0/24"

log "Using ${interface}: ${ipaddress}/${prefix}, ${mac}, gateway ${gateway}"
ip link delete "${TMP_LINK}" 2>/dev/null || true

ready_dir=$(mktemp -d /tmp/bifrost-ready.XXXXXX)
ready_fifo=${ready_dir}/ready
mkfifo "${ready_fifo}"
unshare --net -- bash -c 'read -r _ < "$1"; exec setpriv \
    --bounding-set=-sys_admin,-net_admin \
    --inh-caps=-sys_admin,-net_admin \
    --ambient-caps=-sys_admin,-net_admin \
    /app/bifrost' bifrost-netns "${ready_fifo}" &
child=$!
wait_link lo
nsenter -t "${child}" -n ip link set lo up

slirp4netns --configure "${child}" tap0 &
slirp=$!
wait_link tap0

ip link add link "${interface}" name "${TMP_LINK}" type macvlan mode bridge
ip link set "${TMP_LINK}" address "${mac}"
first_octet=$((16#${mac%%:*}))
(( (first_octet & 3) == 2 )) || fail "Bridge MAC must be locally administered and unicast"
ip link set "${TMP_LINK}" netns "${child}"
nsenter -t "${child}" -n ip link set "${TMP_LINK}" name lan0
nsenter -t "${child}" -n ip address add "${ipaddress}/${prefix}" dev lan0
nsenter -t "${child}" -n ip link set lan0 up
nsenter -t "${child}" -n ip route replace default via "${gateway}" dev lan0
nsenter -t "${child}" -n ip route replace "${internal_cidr}" via 10.0.2.2 dev tap0

log "Namespace ready"
nsenter -t "${child}" -n ip -brief address
nsenter -t "${child}" -n ip route
printf 'ready\n' >"${ready_fifo}"
rm -f "${ready_fifo}"
rmdir "${ready_dir}"

set +e
while kill -0 "${child}" 2>/dev/null; do
    wait -n "${child}" "${slirp}"
    status=$?
    if ! kill -0 "${slirp}" 2>/dev/null && kill -0 "${child}" 2>/dev/null; then
        log "ERROR: Supervisor-network transit exited"
        kill -TERM "${child}" 2>/dev/null || true
        status=1
        break
    fi
    (( stopping == 1 )) && kill -0 "${child}" 2>/dev/null && continue
    break
done
set -e
exit "${status:-0}"
