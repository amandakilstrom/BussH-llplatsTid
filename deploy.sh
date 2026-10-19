#!/usr/bin/env bash
# Bygger BussHållplatsTid, ökar versionsnumret och deployar till k3s på homelab.
# Körs från repots rot: ./deploy.sh
set -euo pipefail

SERVER="amanda@192.168.50.211"
IMAGE="busshallplatstid"
MANIFEST="k8s/busshallplatstid.yaml"
NAMESPACE="busshallplatstid"

cd "$(dirname "$0")"

# Läs nuvarande version (t.ex. v1) ur manifestet och räkna upp den
current=$(grep -oE "${IMAGE}:v[0-9]+" "$MANIFEST" | head -1 | sed -E 's/.*:v//')
if [[ -z "$current" ]]; then
  echo "Hittade ingen ${IMAGE}:vN i $MANIFEST" >&2
  exit 1
fi
next=$((current + 1))
tag="v${next}"
echo "==> v${current} -> ${tag}"

echo "==> Bygger imagen"
docker build -t "${IMAGE}:${tag}" .

echo "==> Kopierar imagen till homelab"
tarfile=$(mktemp --suffix=.tar)
trap 'rm -f "$tarfile"' EXIT
docker save "${IMAGE}:${tag}" -o "$tarfile"
scp "$tarfile" "${SERVER}:${IMAGE}.tar"

echo "==> Importerar i k3s (sudo-lösenord kan behövas)"
ssh -t "$SERVER" "sudo k3s ctr images import ${IMAGE}.tar && rm ${IMAGE}.tar"

echo "==> Uppdaterar manifestet och deployar"
sed -i -E "s|(${IMAGE}):v[0-9]+|\1:${tag}|" "$MANIFEST"
kubectl apply -f "$MANIFEST"
kubectl -n "$NAMESPACE" rollout status deployment/"$IMAGE" --timeout=120s

echo "==> Klart! ${tag} körs. Glöm inte att committa $MANIFEST."
