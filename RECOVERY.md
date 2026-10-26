# Recuperación / Recovery

## Español

### Si algo falla

1. No abras Outlook ni aceptes migraciones de perfiles. Cierra las demás aplicaciones Office.
2. Conserva la carpeta `~/Library/Application Support/Office Update Fix/run.*` mostrada por el asistente. `system-backup.txt` indica la copia protegida `/Library/OfficeUpdateFix.*`; `moved.tsv` relaciona cada archivo movido con su ubicación original. `installer.log` permite revisar un fallo de instalación. Puede que no existan todos esos archivos si se detuvo antes de instalar.
3. Si ya abriste Outlook y hay datos ausentes, usa tu copia externa para recuperar **la aplicación y el perfil del mismo momento**, preferiblemente con ayuda técnica. No mezcles perfiles viejos y nuevos, no importes repetidamente un archivo y no sustituyas datos en uso. La copia local automática está en `run.*/data/` y conserva la estructura de las rutas originales. No es una garantía de recuperación completa ni incluye perfiles personalizados.
4. Si el fallo ocurrió antes de abrir las aplicaciones, puedes recuperar solo los binarios anteriores: en Finder → Ir → Ir a la carpeta, abre la ruta `/Library/OfficeUpdateFix.*` exacta de tu ejecución. En `apps/`, cada `Microsoft Nombre.saved` es la aplicación anterior. Conserva primero cualquier aplicación nueva de `/Applications` en otra carpeta; mueve la copia anterior a `/Applications` y cambia `.saved` por `.app`. Finder pedirá autenticación. Repite para todas las apps guardadas. No abras una app `.saved` dentro del respaldo. Si no estás seguro, restaura desde Time Machine.

El instalador también puede haber cambiado componentes compartidos y registros del sistema. Recuperar los binarios no deshace esos cambios: para una reversión completa usa un respaldo completo del Mac. El proyecto no ofrece una reversión automática.

### Volver a recibir actualizaciones

Esto permite que Office vuelva a actualizarse y podría reproducir el error. Hazlo cuando decidas salir de la versión fijada o comprobar una corrección oficial.

1. Reactiva las dos etiquetas que deshabilita el asistente, desde Terminal con tu usuario habitual:

```bash
sudo launchctl enable system/com.microsoft.autoupdate.helper
launchctl enable "gui/$(id -u)/com.microsoft.update.agent"
```

2. Descarga e instala Microsoft AutoUpdate desde el [historial oficial de AutoUpdate](https://learn.microsoft.com/en-us/officeupdates/release-history-microsoft-autoupdate). No ejecutes el comando de retirada después.
3. Reinicia el Mac, abre Word → Ayuda → Buscar actualizaciones y verifica que AutoUpdate abre y encuentra actualizaciones. Si falla, conserva las copias y solicita ayuda antes de borrar nada.

Las carpetas `before-install/`, `after-install/` o `standalone/` contienen componentes retirados para diagnóstico; los nombres `1.saved` a `4.saved` se corresponden con las rutas de `moved.tsv`. Es preferible reinstalar el actualizador oficial a cargar manualmente componentes antiguos.

### Ejecución interrumpida / bloqueo residual

Si hubo un cierre inesperado, comprueba en Monitor de Actividad que no siga ejecutándose el asistente ni Installer. Solo entonces elimina **la carpeta vacía de bloqueo** y vuelve a ejecutar el diagnóstico:

```bash
sudo rmdir /var/run/office-update-fix.lock
```

No borres copias para resolver un bloqueo. Si Installer sigue trabajando, espera. Si el asistente está ejecutándose, no retires el bloqueo.

### Validación en el equipo afectado

Anota versión exacta de macOS; arquitectura; versión anterior; error textual; versión instalada; resultado de inicio de sesión y edición de Word/Excel/PowerPoint; cuentas, carpetas locales, correos, contactos y calendarios de Outlook; y resultado del diagnóstico de AutoUpdate después de reiniciar. Conserva una copia externa incluso tras una recuperación satisfactoria.

## English

### If something fails

1. Do not open Outlook or accept profile migrations. Quit the other Office apps.
2. Keep the `~/Library/Application Support/Office Update Fix/run.*` folder printed by the assistant. `system-backup.txt` points to the protected `/Library/OfficeUpdateFix.*` backup; `moved.tsv` maps moved files to their original locations. `installer.log` records installation output. Some files may not exist if the process stopped early.
3. If you already opened Outlook and data is missing, restore **the app and its profile from the same point in time** using your external backup, preferably with technical help. Do not merge old and new profiles, repeatedly import archives, or overwrite active data. The automatic local copy is under `run.*/data/`, preserving original relative paths. It does not guarantee complete recovery or include custom profiles.
4. If failure happened before opening the apps, you can recover previous app binaries: in Finder → Go → Go to Folder, open the exact `/Library/OfficeUpdateFix.*` path for your run. Each `apps/Microsoft Name.saved` is the previous app. First move any newly installed version from `/Applications` to a separate folder for safekeeping. Move the saved app back to `/Applications` and rename `.saved` to `.app`; authenticate when Finder asks. Repeat for every saved app. Do not open `.saved` apps inside the backup. If uncertain, restore from Time Machine.

The installer may also have changed shared components and system receipts. Restoring binaries alone does not undo those changes. Use a full Mac backup for a complete reversal; this project provides no automatic rollback.

### Restore updates

This allows Office to update again and may reproduce the original error. Use it when leaving the pinned version or testing an official fix.

1. Re-enable the service labels from Terminal as your usual user:

```bash
sudo launchctl enable system/com.microsoft.autoupdate.helper
launchctl enable "gui/$(id -u)/com.microsoft.update.agent"
```

2. Install Microsoft AutoUpdate from its [official release history](https://learn.microsoft.com/en-us/officeupdates/release-history-microsoft-autoupdate). Do not run the removal command afterward.
3. Restart, open Word → Help → Check for Updates, and confirm AutoUpdate opens and finds updates. Keep the backups and seek help if it fails.

The `before-install/`, `after-install/` or `standalone/` folders retain updater components for diagnosis; `1.saved` through `4.saved` map to paths in `moved.tsv`. Prefer a fresh official updater installation over manually loading old components.

### Interrupted run / stale lock

Use Activity Monitor to confirm neither the assistant nor Installer is still running. Only then remove the empty lock directory and rerun diagnostics:

```bash
sudo rmdir /var/run/office-update-fix.lock
```

Never remove backups to resolve a lock. Wait if Installer is still running. Do not remove a live assistant's lock.

### Validate on the affected Mac

Record exact macOS version, architecture, prior version, error text, installed version, sign-in and editing results in Word/Excel/PowerPoint, all Outlook accounts/local folders/mail/contacts/calendars, and AutoUpdate diagnostics after restarting. Keep an external backup even after successful recovery.
