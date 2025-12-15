#!/usr/bin/env sh
set -eu

root_dir="$(cd "$(dirname "$0")/.." && pwd)"

if [ -f "${root_dir}/.env" ]; then
  set -a
  . "${root_dir}/.env"
  set +a
fi

if [ -z "${GRAFANA_CLOUD_REMOTE_WRITE_URL:-}" ]; then
  echo "missing GRAFANA_CLOUD_REMOTE_WRITE_URL" >&2
  exit 1
fi

if [ -z "${GRAFANA_CLOUD_USERNAME:-}" ]; then
  echo "missing GRAFANA_CLOUD_USERNAME" >&2
  exit 1
fi

if [ -z "${GRAFANA_CLOUD_API_KEY:-}" ]; then
  echo "missing GRAFANA_CLOUD_API_KEY" >&2
  exit 1
fi

case "${GRAFANA_CLOUD_REMOTE_WRITE_URL}" in
  https://*/api/prom/push) : ;;
  *) echo "invalid GRAFANA_CLOUD_REMOTE_WRITE_URL (expected https://.../api/prom/push)" >&2; exit 1 ;;
esac

mkdir -p "${root_dir}/prometheus" "${root_dir}/secrets" "${root_dir}/targets"

umask 077
printf "%s" "${GRAFANA_CLOUD_API_KEY}" > "${root_dir}/secrets/grafana_cloud_api_key"

tmpl="${root_dir}/prometheus/prometheus.yml.tmpl"
out="${root_dir}/prometheus/prometheus.yml"

sed \
  -e "s|__GRAFANA_CLOUD_REMOTE_WRITE_URL__|${GRAFANA_CLOUD_REMOTE_WRITE_URL}|g" \
  -e "s|__GRAFANA_CLOUD_USERNAME__|${GRAFANA_CLOUD_USERNAME}|g" \
  "${tmpl}" > "${out}"

chmod 600 "${out}" "${root_dir}/secrets/grafana_cloud_api_key"

echo "rendered ${out}"


