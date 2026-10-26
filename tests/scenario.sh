#!/bin/bash
set -euo pipefail
source scripts/office-update-fix.sh
 LANGUAGE=en
 RUN_DIR="$TEST_DIR/$1"
 SYSTEM_BACKUP="$RUN_DIR/system"
 mkdir -p "$RUN_DIR"
 LOG="$RUN_DIR/events"
 : > "$LOG"
 record() { printf '%s\n' "$*" >> "$LOG"; }
 confirm() { [[ "$1" != CANCEL ]]; }
 new_run() { record start; }
 backup_data() { record backup; if [[ "$SCENARIO" == backup-fails ]]; then return 1; fi; }
 ensure_closed() { record closed; }
 curl() { record download; if [[ "$SCENARIO" == download-fails ]]; then return 1; fi; }
 mv() { record move; }
 mkdir() { record mkdir; }
 spctl() { record assess; if [[ "$SCENARIO" == assessment-fails ]]; then return 1; fi; }
 shasum() { printf 'test-hash\n'; }
 pkgutil() {
  if [[ "$SCENARIO" == bad-signature ]]; then printf 'unsigned\n';
  else printf 'Status: signed by a certificate trusted by macOS\nDeveloper ID Installer: Microsoft Corporation (UBF8T346G9)\n'; fi
 }
 version_of() { if [[ "$SCENARIO" == wrong-version ]]; then printf '16.114.1\n'; else printf '16.113.4\n'; fi; }
 sudo() {
  record "sudo $1"
  if [[ "$1" == installer && "$SCENARIO" == installer-fails ]]; then return 1; fi
 }
 remove_mau() { record "mau $1"; }
 if [[ "$SCENARIO" == cancelled ]]; then confirm() { return 1; }; fi
 recover

