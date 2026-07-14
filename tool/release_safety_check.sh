#!/usr/bin/env bash
set -euo pipefail

tracked_files="$(git ls-files)"

if printf '%s\n' "$tracked_files" | rg -i '\.(jks|keystore|p12|mobileprovision)$|(^|/)(\.env|google-services\.json|GoogleService-Info\.plist|id_rsa)$'; then
  echo "Sensitive signing or configuration material is tracked." >&2
  exit 1
fi

if printf '%s\n' "$tracked_files" | xargs -r rg -n -i \
  '(BEGIN (RSA|EC|OPENSSH) PRIVATE KEY|api[_-]?key\s*[:=]|secret[_-]?key\s*[:=]|password\s*[:=])'; then
  echo "Potential secret material found in tracked source." >&2
  exit 1
fi

runtime_files="$(git ls-files -- 'lib/**' 'android/**' 'ios/**')"
if printf '%s\n' "$runtime_files" | xargs -r rg -n -i \
  '(https?://(localhost|127\.0\.0\.1|10\.0\.2\.2)|file://|/Users/[A-Za-z0-9._-]+/)'; then
  echo "Development endpoint or private path found in runtime source." >&2
  exit 1
fi

echo "Release safety scan passed."
