#!/usr/bin/env bash
set -euox pipefail

# E2E smoke test: create owner, verify unauthenticated /api/v1/me, login
ROOT_DIR=$(cd "$(dirname "$0")/../.." && pwd)
cd "$ROOT_DIR"

N8N_EMAIL=$(grep '^N8N_OWNER_EMAIL=' .env | cut -d= -f2)
N8N_FIRST=$(grep '^N8N_OWNER_FIRST_NAME=' .env | cut -d= -f2)
N8N_LAST=$(grep '^N8N_OWNER_LAST_NAME=' .env | cut -d= -f2)
N8N_PASS=$(grep '^N8N_OWNER_PASSWORD=' .env | cut -d= -f2)

echo "Creating owner account via setup API..."
for attempt in $(seq 1 10); do
  HTTP_CODE=$(curl --silent --output /tmp/setup.json --write-out "%{http_code}" \
    --request POST \
    --header "Content-Type: application/json" \
    --data "{\"email\":\"${N8N_EMAIL}\",\"firstName\":\"${N8N_FIRST}\",\"lastName\":\"${N8N_LAST}\",\"password\":\"${N8N_PASS}\"}" \
    http://127.0.0.1:5678/rest/owner/setup || echo "000")
  BODY=$(cat /tmp/setup.json 2>/dev/null || true)
  echo "Attempt ${attempt}/10 - HTTP ${HTTP_CODE}"
  if [ "$HTTP_CODE" -eq 200 ] && ! echo "${BODY}" | grep -qi "starting up"; then
    echo "Owner created."
    break
  fi
  echo "  Not ready yet (body: ${BODY}), retrying in 5 s..."
  sleep 5
  if [ "$attempt" -eq 10 ]; then
    echo "Failed to create owner after 10 attempts. Last HTTP ${HTTP_CODE}."
    cat /tmp/setup.json || true
    exit 1
  fi
done

echo "Verify unauthenticated API returns 401..."
HTTP_CODE=$(curl --silent --output /dev/null --write-out "%{http_code}" \
  http://127.0.0.1:5678/api/v1/me || echo "000")
if [ "$HTTP_CODE" -ne 401 ]; then
  echo "Expected 401 but got ${HTTP_CODE}"
  exit 1
fi

echo "Verify login with preset credentials..."
HTTP_CODE=$(curl --silent --output /dev/null --write-out "%{http_code}" \
  --request POST --header "Content-Type: application/json" \
  --data "{\"email\":\"${N8N_EMAIL}\",\"password\":\"${N8N_PASS}\"}" \
  http://127.0.0.1:5678/rest/login || echo "000")
if [ "$HTTP_CODE" -ne 200 ]; then
  echo "Login failed (HTTP ${HTTP_CODE})"
  exit 1
fi

echo "E2E smoke tests passed."
