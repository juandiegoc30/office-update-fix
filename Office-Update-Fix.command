#!/bin/bash
cd -- "$(dirname -- "$0")" || exit 1
printf 'Idioma / Language: 1 Español, 2 English: '
read -r language
case "$language" in 1) language=es;; 2) language=en;; *) exit 1;; esac
printf '\n1. Diagnóstico / Diagnose\n2. Recuperar Office / Recover Office\n3. Retirar AutoUpdate / Remove AutoUpdate\n0. Salir / Exit\n> '
read -r choice
case "$choice" in
 1) action=diagnose;; 2) action=recover;; 3) action=remove-autoupdate;; *) exit 0;;
esac
/bin/bash scripts/office-update-fix.sh "$action" "$language"
result=$?
printf '\nResultado / Exit status: %s\nEnter para cerrar / Press Enter to close.' "$result"
read -r _
exit "$result"
