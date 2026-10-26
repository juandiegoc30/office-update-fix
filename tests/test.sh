#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
source scripts/office-update-fix.sh
LANGUAGE=en
valid_signature 'Status: signed by a certificate trusted by macOS
Developer ID Installer: Microsoft Corporation (UBF8T346G9)'
if valid_signature 'Status: signed by a certificate trusted by macOS
Developer ID Installer: Other Company (AAAAAAAAAA)'; then exit 1; fi
if valid_signature 'Status: no signature
Developer ID Installer: Microsoft Corporation (UBF8T346G9)'; then exit 1; fi
if confirm '' '' <<< no; then exit 1; fi
confirm '' '' <<< CONTINUE
bash scripts/office-update-fix.sh help en >/dev/null
if bash scripts/office-update-fix.sh typo en >/dev/null 2>&1; then exit 1; fi
if bash scripts/office-update-fix.sh help fr >/dev/null 2>&1; then exit 1; fi
TEST_DIR=$(mktemp -d)
trap 'rm -rf "$TEST_DIR"' EXIT
# All OS mutations are replaced with recording functions. No installer, sudo,
# downloads, launchctl or system application paths are executed in these tests.

export TEST_DIR
export SCENARIO=success
bash tests/scenario.sh success >/dev/null
python3 - "$TEST_DIR/success/events" <<'PY'
import sys
from pathlib import Path
s = Path(sys.argv[1]).read_text().splitlines()
expected = ['backup', 'download', 'assess', 'mau before-install', 'sudo installer', 'mau after-install']
assert [s.index(x) for x in expected] == sorted(s.index(x) for x in expected), s
PY
export SCENARIO=bad-signature
# A separate bash process preserves errexit semantics (not a conditional function call).
export TEST_DIR
if bash tests/scenario.sh bad-signature >/dev/null 2>&1; then exit 1; fi
if grep -q 'sudo installer\|mau ' "$TEST_DIR/bad-signature/events"; then exit 1; fi
export SCENARIO=installer-fails
if bash tests/scenario.sh installer-fails >/dev/null 2>&1; then exit 1; fi
grep -q 'mau after-install' "$TEST_DIR/installer-fails/events"
export SCENARIO=wrong-version
if bash tests/scenario.sh wrong-version >/dev/null 2>&1; then exit 1; fi
for SCENARIO in backup-fails download-fails assessment-fails; do
 export SCENARIO
 if bash tests/scenario.sh "$SCENARIO" >/dev/null 2>&1; then exit 1; fi
 if grep -q "sudo installer\|mau " "$TEST_DIR/$SCENARIO/events"; then exit 1; fi
done
export SCENARIO=cancelled
bash tests/scenario.sh cancelled >/dev/null
if grep -q start "$TEST_DIR/cancelled/events"; then exit 1; fi
# A running Office application stops recovery instead of losing unsaved work.
if ( pgrep() { return 0; }; ensure_closed ) >/dev/null 2>&1; then exit 1; fi
printf 'PASS: signatures, CLI, cancellation, running-app guard, operation order, installer failure, version mismatch.\n'
