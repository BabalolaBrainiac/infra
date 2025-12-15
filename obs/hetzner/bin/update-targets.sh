#!/usr/bin/env sh
set -eu

if [ -z "${HCLOUD_TOKEN:-}" ]; then
  echo "missing HCLOUD_TOKEN" >&2
  exit 1
fi

api_base="${HCLOUD_API_BASE:-https://api.hetzner.cloud/v1}"
out_dir="${OUT_DIR:-/work/targets}"

tmp="$(mktemp)"
trap 'rm -f "${tmp}"' EXIT

code="$(curl -sS -o "${tmp}" -w "%{http_code}" \
  -H "Authorization: Bearer ${HCLOUD_TOKEN}" \
  "${api_base}/servers?per_page=50" || true)"

if [ "${code}" != "200" ]; then
  echo "hcloud api request failed (status=${code})" >&2
  cat "${tmp}" >&2 || true
  exit 1
fi

servers_json="$(cat "${tmp}")"

write_targets() {
  svc="$1"
  port="$2"
  file="${out_dir}/${svc}.json"
  label_service="${3:-}"
  tmp_out="${file}.tmp"

  if [ -n "${label_service}" ]; then
    echo "${servers_json}" | jq --arg svc "${svc}" --arg port "${port}" --arg label_service "${label_service}" '
      .servers
      | map(select(.public_net.ipv4.ip != null))
      | map(select(.labels.Service == $label_service))
      | map({
          targets: [(.public_net.ipv4.ip + ":" + $port)],
          labels: {
            server_id: (.id|tostring),
            server_name: .name,
            service: $svc
          }
        })
    ' > "${tmp_out}"
  else
    echo "${servers_json}" | jq --arg svc "${svc}" --arg port "${port}" '
      .servers
      | map(select(.public_net.ipv4.ip != null))
      | map({
          targets: [(.public_net.ipv4.ip + ":" + $port)],
          labels: {
            server_id: (.id|tostring),
            server_name: .name,
            service: $svc
          }
        })
    ' > "${tmp_out}"
  fi

  mv "${tmp_out}" "${file}"
}

mkdir -p "${out_dir}"

write_targets "ssh" "22"
write_targets "postgres" "5432" "postgresql"
write_targets "redis" "6379" "redis"


