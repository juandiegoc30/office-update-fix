#!/bin/bash
# macOS ships Bash 3.2. No third-party runtime is required.
set -euo pipefail
PATH=/usr/bin:/bin:/usr/sbin:/sbin
export PATH
readonly TARGET_VERSION=16.113.4
readonly PACKAGE_URL='https://res.public.onecdn.static.microsoft/mro1cdnstorage/C1297A47-86C4-4C1F-97FA-950631F94777/MacAutoupdate/Microsoft_365_and_Office_16.113.26100421_Installer.pkg'
readonly TEAM_ID=UBF8T346G9
APPS=(Word Excel PowerPoint Outlook OneNote)
MAU_PATHS=(
 '/Library/Application Support/Microsoft/MAU2.0/Microsoft AutoUpdate.app'
 '/Library/LaunchAgents/com.microsoft.update.agent.plist'
 '/Library/LaunchDaemons/com.microsoft.autoupdate.helper.plist'
 '/Library/PrivilegedHelperTools/com.microsoft.autoupdate.helper'
)
LANGUAGE=es
RUN_DIR=''
SYSTEM_BACKUP=''
LOCKED=0
say() { if [[ "$LANGUAGE" == en ]]; then printf '%s\n' "$2"; else printf '%s\n' "$1"; fi; }
fail() { say "$1" "$2" >&2; exit 1; }
confirm() {
 local answer
 say "$1" "$2"
 read -r answer || return 1
 [[ "$answer" == CONTINUE ]]
}
version_of() { /usr/libexec/PlistBuddy -c 'Print :CFBundleShortVersionString' "$1/Contents/Info.plist" 2>/dev/null || printf 'unknown\n'; }
valid_signature() {
 # Both a trusted certificate chain and Microsoft's installer identity are required.
 [[ "$1" == *'Status: signed by a certificate trusted by'* ]] &&
 [[ "$1" == *"Developer ID Installer: Microsoft Corporation ($TEAM_ID)"* ]]
}
platform_check() {
 [[ "$(uname -s)" == Darwin ]] || fail 'Solo macOS.' 'macOS only.'
 [[ "$EUID" -ne 0 ]] || fail 'Ejecuta sin sudo; pediremos permisos cuando sean necesarios.' 'Run without sudo; elevation is requested only when needed.'
 [[ "$(sysctl -n hw.optional.arm64 2>/dev/null || true)" == 1 ]] || fail 'Esta edición requiere un Mac Apple Silicon.' 'This edition requires an Apple Silicon Mac.'
 local major
 major=$(sw_vers -productVersion); major=${major%%.*}
 [[ "$major" -ge 14 ]] || fail 'Requiere macOS 14 o posterior.' 'Requires macOS 14 or later.'
}
ensure_closed() {
 local name
 for name in "${APPS[@]}"; do
  if pgrep -x "Microsoft $name" >/dev/null; then
   fail "Cierra Microsoft $name y vuelve a intentarlo. No se cerrará a la fuerza." "Quit Microsoft $name and retry. It will not be force-quit."
  fi
 done
}
diagnose() {
 say 'Diagnóstico local; no modifica Office ni envía datos.' 'Local diagnostics; does not modify Office or send data.'
 sw_vers
 for name in "${APPS[@]}"; do
  local app="/Applications/Microsoft $name.app"
  if [[ -d "$app" ]]; then
   printf '%s: %s\n' "$name" "$(version_of "$app")"
   if [[ -e "$app/Contents/_MASReceipt/receipt" ]]; then say '  Origen: Mac App Store (no sirve para licencia perpetua).' '  Source: Mac App Store (not suitable for a perpetual license).'; fi
  else printf '%s: —\n' "$name"; fi
 done
 for path in "${MAU_PATHS[@]}"; do [[ ! -e "$path" ]] || printf 'AutoUpdate: %s\n' "$path"; done
 say 'La licencia se verifica manualmente en la cuenta Microsoft y dentro de Word.' 'Verify the license manually in the Microsoft account and inside Word.'
}
cleanup() {
 local result=$?
 trap - EXIT
 if [[ "$LOCKED" == 1 ]]; then sudo rmdir /var/run/office-update-fix.lock || true; fi
 if [[ "$result" -ne 0 && -n "$RUN_DIR" ]]; then
  say "Proceso interrumpido. Conserva las copias: $RUN_DIR y $SYSTEM_BACKUP. Consulta RECOVERY.md; no abras Outlook todavía." "Interrupted. Keep backups: $RUN_DIR and $SYSTEM_BACKUP. See RECOVERY.md; do not open Outlook yet."
 fi
 exit "$result"
}
new_run() {
 sudo -v
 sudo mkdir -m 700 /var/run/office-update-fix.lock || fail 'Ya hay otra ejecución o un bloqueo pendiente. Consulta RECOVERY.md.' 'Another run or a stale lock exists. See RECOVERY.md.'
 LOCKED=1
 trap cleanup EXIT
 trap 'exit 130' INT
 trap 'exit 143' TERM
 umask 077
 mkdir -p "$HOME/Library/Application Support/Office Update Fix"
 RUN_DIR=$(mktemp -d "$HOME/Library/Application Support/Office Update Fix/run.XXXXXX")
 SYSTEM_BACKUP=$(sudo mktemp -d /Library/OfficeUpdateFix.XXXXXX)
 printf '%s\n' "$SYSTEM_BACKUP" > "$RUN_DIR/system-backup.txt"
 say "Registro de recuperación: $RUN_DIR" "Recovery record: $RUN_DIR"
}
backup_data() {
 local relative source used=0 size free
 DATA_PATHS=(
  'Library/Group Containers/UBF8T346G9.Office'
  'Library/Containers/com.microsoft.Outlook'
  'Documents/Microsoft User Data'
 )
 # Permission errors abort; a partial copy must never authorize a downgrade.
 for relative in "${DATA_PATHS[@]}"; do
  source="$HOME/$relative"
  if [[ -e "$source" ]]; then
   size=$(du -sk "$source" | awk '{print $1}')
   used=$((used + size))
  fi
 done
 free=$(df -Pk "$HOME" | awk 'END {print $4}')
 [[ "$free" -gt $((used + 26214400)) ]] || fail 'Libera espacio: datos locales + 25 GiB necesarios.' 'Free space required: local data size + 25 GiB.'
 for relative in "${DATA_PATHS[@]}"; do
  source="$HOME/$relative"
  if [[ -e "$source" ]]; then
   mkdir -p "$RUN_DIR/data/$(dirname "$relative")"
   ditto "$source" "$RUN_DIR/data/$relative"
  fi
 done
 say 'Copia local finalizada. La copia externa sigue siendo necesaria.' 'Local copy completed. Your external backup is still required.'
}
remove_mau() {
 local phase="$1" domain path i=0 process
 sudo mkdir -p "$SYSTEM_BACKUP/$phase"
 # Disable registration before unloading, including registrations recreated by the installer.
 for domain in "gui/$(id -u)/com.microsoft.update.agent" 'system/com.microsoft.autoupdate.helper'; do
  sudo launchctl disable "$domain"
  if sudo launchctl print "$domain" >/dev/null 2>&1; then sudo launchctl bootout "$domain"; fi
 done
 for process in 'Microsoft AutoUpdate' 'Microsoft Update Assistant' 'com.microsoft.autoupdate.helper'; do
  if pgrep -x "$process" >/dev/null; then sudo pkill -TERM -x "$process"; fi
 done
 sleep 2
 for process in 'Microsoft AutoUpdate' 'Microsoft Update Assistant' 'com.microsoft.autoupdate.helper'; do
  if pgrep -x "$process" >/dev/null; then fail 'AutoUpdate sigue activo. Reinicia y reintenta.' 'AutoUpdate is still running. Restart and retry.'; fi
 done
 for path in "${MAU_PATHS[@]}"; do
  i=$((i+1))
  if [[ -e "$path" || -L "$path" ]]; then
   sudo mv "$path" "$SYSTEM_BACKUP/$phase/$i.saved"
   printf '%s\t%s\n' "$SYSTEM_BACKUP/$phase/$i.saved" "$path" >> "$RUN_DIR/moved.tsv"
  fi
 done
}
recover() {
 ensure_closed
 local item
 for item in "${APPS[@]}"; do
  [[ ! -L "/Applications/Microsoft $item.app" ]] || fail "Enlace simbólico no admitido: $item" "Unsupported symlink: $item"
 done
 say "Versión candidata: $TARGET_VERSION. Activación y compatibilidad de Outlook aún no verificadas en tu Mac." "Candidate version: $TARGET_VERSION. Activation and Outlook compatibility are not yet verified on your Mac."
 say 'Se instalará la suite completa sin Teams y se retirará AutoUpdate para todas las apps que lo utilizan.' 'Installs the full suite without Teams and removes AutoUpdate for all apps that use it.'
 confirm 'Confirma licencia 2021 válida, copia externa reciente y recuperable (incluido Outlook), todas las sesiones de otros usuarios cerradas y ninguna instalación en curso. Escribe CONTINUE.' 'Confirm a valid 2021 license, a recent recoverable external backup (including Outlook), all other user sessions logged out and no installation in progress. Type CONTINUE.' || return 0
 new_run
 backup_data
 local package="$RUN_DIR/Office-16.113.4.pkg" signature name app
 say 'Descargando instalador oficial (~2,9 GB)…' 'Downloading the official installer (~2.9 GB)…'
 curl --fail --location --proto '=https' --proto-redir '=https' --retry 3 --output "$package.part" "$PACKAGE_URL"
 mv "$package.part" "$package"
 signature=$(LC_ALL=C pkgutil --check-signature "$package")
 valid_signature "$signature" || fail 'Firma inesperada. No se instalará el paquete.' 'Unexpected signature. The package will not be installed.'
 spctl --assess --type install "$package"
 shasum -a 256 "$package" > "$RUN_DIR/package.sha256"
 printf '%s\n' "$signature" > "$RUN_DIR/package-signature.txt"
 ensure_closed
 confirm 'Descarga y copia listas. Se moverán las apps actuales a una copia y se instalará 16.113.4. No abras Office durante el proceso. Escribe CONTINUE.' 'Download and backup ready. Current apps will be moved to a backup and 16.113.4 installed. Do not open Office during this process. Type CONTINUE.' || return 0
 remove_mau before-install
 sudo mkdir "$SYSTEM_BACKUP/apps"
 for name in "${APPS[@]}"; do
  app="/Applications/Microsoft $name.app"
  if [[ -e "$app" || -L "$app" ]]; then
   [[ ! -L "$app" ]] || fail "No se admite un enlace simbólico: $app" "Symlink not supported: $app"
   sudo mv "$app" "$SYSTEM_BACKUP/apps/Microsoft $name.saved"
   printf '%s\t%s\n' "$SYSTEM_BACKUP/apps/Microsoft $name.saved" "$app" >> "$RUN_DIR/moved.tsv"
  fi
 done
 # Even a failed installer may have reinstalled MAU. Remove it before reporting failure.
 local install_result=0
 sudo installer -pkg "$package" -target / > "$RUN_DIR/installer.log" 2>&1 || install_result=$?
 remove_mau after-install
 [[ "$install_result" -eq 0 ]] || fail 'La instalación falló. Consulta installer.log y RECOVERY.md.' 'Installation failed. See installer.log and RECOVERY.md.'
 for name in "${APPS[@]}"; do
  app="/Applications/Microsoft $name.app"
  [[ "$(version_of "$app")" == "$TARGET_VERSION" ]] || fail "Versión inesperada en $name. Conserva las copias." "Unexpected version in $name. Keep the backups."
 done
 say 'Instalación verificada. Abre Word, inicia sesión con la cuenta que compró Office 2021 y comprueba que puedes editar. Después revisa Outlook; si faltan datos o pide migrarlos, detente y consulta RECOVERY.md.' 'Installation verified. Open Word, sign in with the account that purchased Office 2021 and verify editing. Then check Outlook; if data is missing or migration is requested, stop and see RECOVERY.md.'
 say 'La activación no se puede garantizar. Conserva ambas copias. AutoUpdate puede reaparecer al instalar otro producto Microsoft; ejecuta diagnose después.' 'Activation cannot be guaranteed. Keep both backups. AutoUpdate may return when another Microsoft product is installed; run diagnose afterward.'
}
main() {
 local action="${1:-diagnose}"
 [[ $# -le 2 ]] || { printf 'Usage: bash scripts/office-update-fix.sh [diagnose|recover|remove-autoupdate|help] [es|en]\n'; return 2; }
 LANGUAGE="${2:-es}"
 [[ "$LANGUAGE" == es || "$LANGUAGE" == en ]] || { printf 'Language: es | en\n' >&2; return 2; }
 case "$action" in
 help|--help|-h) printf 'Usage: bash scripts/office-update-fix.sh [diagnose|recover|remove-autoupdate|help] [es|en]\n'; return 0;;
 diagnose|recover|remove-autoupdate) ;;
 *) printf 'Unknown command: %s\n' "$action" >&2; return 2;;
 esac
 platform_check
 case "$action" in
 diagnose) diagnose;;
 recover) recover;;
 remove-autoupdate)
  confirm 'Esto retira AutoUpdate para todas las apps que lo utilizan y detiene sus actualizaciones de seguridad. Cierra otras sesiones de usuario. Escribe CONTINUE.' 'This removes AutoUpdate for all apps that use it and stops their security updates. Log out other user sessions. Type CONTINUE.' || return 0
  new_run
  remove_mau standalone
  say 'AutoUpdate retirado. Copia conservada; consulta RECOVERY.md para restaurarlo.' 'AutoUpdate removed. Backup retained; see RECOVERY.md to restore it.';;
 esac
}
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then main "$@"; fi
