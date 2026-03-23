#!/usr/bin/env bash
set -euox pipefail

# E2E smoke test: verify the public REST API enforces authentication.
#
# The /rest/owner/setup endpoint requires a browser session cookie in n8n 1.0.1
# and is not part of the documented public API, so automated owner creation is
# not tested here.  The setup wizard is intended to be completed manually on
# first launch at http://localhost:5678/setup.

echo "Verify unauthenticated public API call returns 401..."
HTTP_CODE=$(curl --silent --output /dev/null --write-out "%{http_code}" \
  http://127.0.0.1:5678/api/v1/me || echo "000")
if [ "$HTTP_CODE" -ne 401 ]; then
  echo "Expected 401 but got ${HTTP_CODE}"
  exit 1
fi

echo "E2E smoke tests passed."
