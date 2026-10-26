# Office Update Fix

**Español** · [English](README.en.md) · [Guía web](https://juandiegoc30.github.io/office-update-fix/)

Recuperación asistida para Office Hogar y Empresas 2021 en Mac Apple Silicon cuando una actualización coincide con errores de activación. Descarga Office **16.113.4 (26100421)** de Microsoft y retira Microsoft AutoUpdate. Requiere una licencia legítima vinculada a tu cuenta.

> **Versión preliminar, pendiente de prueba real.** Se verificaron el enlace oficial y pruebas aisladas de la lógica, pero no se ha instalado Office ni comprobado la activación o la compatibilidad de perfiles de Outlook en un Mac afectado. 16.113.4 es una candidata reportada por la comunidad, no una reparación garantizada ni una «última versión compatible» certificada por este proyecto.

## Antes de empezar

- Mac Apple Silicon, macOS 14 o posterior; el caso original indica posiblemente Tahoe, aún por confirmar. No se valida Intel ni equipos administrados por una organización.
- Cuenta Microsoft con la compra de Office 2021 visible. Anota el error y la versión desde **Word → Acerca de Microsoft Word**.
- Copia externa reciente y recuperable del Mac, incluyendo las carpetas locales de Outlook. Cierra Office antes de respaldar. Comprueba que Time Machine incluye esos datos; una copia en el mismo disco no sustituye este respaldo. Si Outlook ofrece exportar a `.olm`, guarda también esa exportación.
- Espacio libre: tamaño de los datos locales más **25 GiB**, internet (~2,9 GB de descarga) y una cuenta administradora.
- Cierra Word, Excel, PowerPoint, Outlook y OneNote; cierra las sesiones de otros usuarios y espera a que termine cualquier instalación.

**Outlook:** el script copia sus ubicaciones habituales y no borra perfiles, llavero ni licencias. Esto no garantiza que una versión anterior pueda leer un perfil actualizado. Si usas perfiles fuera de las rutas estándar, respáldalos por separado. La copia automática no cubre otros usuarios. Si falta acceso a una carpeta, el proceso se detiene; autoriza a Terminal en Privacidad y seguridad únicamente si macOS lo requiere y reintenta.

## Descargar y ejecutar

Descarga [office-update-fix.zip](https://github.com/juandiegoc30/office-update-fix/releases/latest/download/office-update-fix.zip), descomprímelo y abre **Office-Update-Fix.command**. Elige idioma y luego diagnóstico, recuperación o retirada de AutoUpdate. El diagnóstico es la opción inicial recomendada.

Si macOS bloquea el ejecutable, revisa su contenido y usa la alternativa de Terminal. No es necesario desactivar Gatekeeper. En Terminal escribe `cd ` (con espacio), arrastra la carpeta descomprimida a la ventana y pulsa Enter. Después:

```bash
# Solo diagnóstico; no pide permisos administrativos ni cambia Office
bash scripts/office-update-fix.sh diagnose es

# Recuperación asistida; pide confirmación y permisos
bash scripts/office-update-fix.sh recover es

# Solo retirar AutoUpdate; no reinstala Office
bash scripts/office-update-fix.sh remove-autoupdate es
```

No ejecutes estos comandos con `sudo` por delante. El asistente solicita permisos cuando los necesita. No pide tu contraseña Microsoft. Para inglés, cambia `es` por `en`.

## Qué hace la recuperación

1. Comprueba plataforma y que Office esté cerrado. Solicita confirmar licencia y respaldo externo.
2. Copia `~/Library/Group Containers/UBF8T346G9.Office`, `~/Library/Containers/com.microsoft.Outlook` y `~/Documents/Microsoft User Data`, cuando existen.
3. Descarga la suite oficial sin Teams por HTTPS; comprueba la confianza de la firma, el identificador de Microsoft y la evaluación de macOS. Guarda un SHA-256 como registro local, no como checksum oficial publicado.
4. Pide una segunda confirmación. Deshabilita los servicios de AutoUpdate, detiene sus procesos y mueve sus cuatro componentes conocidos a una copia protegida.
5. Mueve las aplicaciones actuales a esa copia e instala Word, Excel, PowerPoint, Outlook y OneNote. Aunque antes no usaras todas, se instala la suite completa.
6. Retira de nuevo AutoUpdate y comprueba la versión de las cinco aplicaciones. Conserva instalador, registros y copias.
7. Tú abres Word, inicias sesión con la cuenta de compra y verificas la edición. Después compruebas correos, carpetas locales, contactos y calendarios en Outlook. Ante una migración inesperada o datos ausentes, detente y consulta [RECOVERY.md](RECOVERY.md).

Las copias se guardan en `~/Library/Application Support/Office Update Fix/run.*` y `/Library/OfficeUpdateFix.*`. No las borres hasta comprobar todos tus datos y tener una copia externa. El asistente muestra las rutas concretas. No intenta restaurar automáticamente un perfil tras un fallo.

## Límites del bloqueo

La retirada de AutoUpdate afecta a **todas las aplicaciones que dependen de ese actualizador**, no solo Office. No bloquea otros actualizadores, App Store, herramientas de terceros ni instalaciones manuales. Otro instalador Microsoft puede recuperarlo; vuelve a ejecutar el diagnóstico después. No prometemos un bloqueo permanente.

Office 2021 terminó su soporte el 13 de octubre de 2026: conservar una versión antigua implica perder protección frente a vulnerabilidades futuras. La retirada de AutoUpdate es reversible; consulta [recuperación](RECOVERY.md). No se desactivan las protecciones de macOS.

## El caso y las fuentes

Un familiar con Office Hogar y Empresas 2021 vinculado a su cuenta encontró un error de licencia después de actualizar. Reinstalar desde su cuenta no resolvió el problema. La causa exacta y el resultado en ese equipo están pendientes de confirmar. Un nombre de producto «Microsoft 365» en el instalador no demuestra que la licencia haya cambiado.

- [Hilo de Reddit](https://www.reddit.com/r/macapps/comments/1xf6o5f/fixed_how_to_get_microsoft_office_2021_for_mac_to/): experiencia comunitaria que inspiró el proyecto; no es confirmación de Microsoft.
- [Archivo de Microsoft](https://learn.microsoft.com/en-us/officeupdates/update-history-office-for-mac): publica el instalador del 6 de octubre de 2026. El nombre del paquete contiene `16.113.26100421`; la versión publicada es `16.113.4`.
- [Ciclo de vida de Office 2021](https://learn.microsoft.com/en-us/lifecycle/products/office-2021).
- [Activar Office para Mac](https://support.microsoft.com/en-us/microsoft-365-activation-licensing/office-install/activate-office-for-mac).
- [Licencias perpetuas y Mac App Store](https://support.microsoft.com/en-us/microsoft-365-activation-licensing/microsoft-office-activation-and-the-mac-app-store): usa las aplicaciones distribuidas directamente por Microsoft.
- [Copias de Outlook](https://support.microsoft.com/en-us/outlook/automatically-archive-or-back-up-outlook-for-mac-items).
- [Microsoft Update Remover, de mrsarac](https://github.com/mrsarac/microsoft-update-remover), licencia MIT: inspiración para identificar los componentes de AutoUpdate. Implementación independiente; no descargamos ni ejecutamos su script.

Fuentes revisadas: 26 de octubre de 2026. Proyecto independiente, no afiliado a Microsoft. No incluye activadores ni modifica derechos de licencia.

## Desarrollo y publicación

`scripts/` contiene la herramienta; `docs/` la web estática bilingüe. GitHub Pages publica `docs/` mediante Actions. En **Settings → Pages → Source**, selecciona **GitHub Actions**. La web no requiere dependencias ni servicios externos.

```bash
bash -n scripts/office-update-fix.sh Office-Update-Fix.command tests/test.sh tests/scenario.sh
bash tests/test.sh
python3 tests/site.py
```

Las pruebas sustituyen las operaciones del sistema: verifican cancelación, firma incorrecta, orden de respaldo e instalación, fallo del instalador y versiones inesperadas. No prueban la activación, los servidores Microsoft, `launchctl`, el instalador real ni una migración de Outlook. No ejecutes pruebas de recuperación real sobre el Mac de desarrollo.

Antes de cambiar el estado a «probado», registra macOS y arquitectura, versiones anterior y posterior, edición de licencia, resultado de activación y presencia de todos los datos locales de Outlook. No publiques claves, correos, perfiles ni registros con datos personales.
