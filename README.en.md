# Office Update Fix

[Español](README.md) · **English** · [Web guide](https://juandiegoc30.github.io/office-update-fix/en/)

Assisted recovery for Office Home & Business 2021 on Apple Silicon Macs after an update coincides with activation errors. Downloads **16.113.4 (26100421)** directly from Microsoft and removes Microsoft AutoUpdate. Requires a legitimate license associated with your Microsoft account.

> **Preview — not yet tested on an affected Mac.** The official download URL and isolated logic tests were checked. Actual installation, activation and Outlook profile compatibility have not been verified. This is a community-reported candidate, not a guaranteed fix or a certified final compatible version.

## Prepare

Use an Apple Silicon Mac running macOS 14 or later, an administrator account and internet (~2.9 GB). Intel and organization-managed Macs are outside this release's scope. Allow free space equal to your local data plus 25 GiB. Record the exact error and Office version. Confirm that Office 2021 appears in your Microsoft account purchases.

Quit Office and make a recent, recoverable external backup that includes Outlook's local data. Check that Time Machine actually includes it. Export an `.olm` archive as well if your Outlook version offers that option. A same-disk copy is not a replacement. Back up custom profile locations separately; other users' data is not copied. Log out other users and finish any ongoing installations.

The assistant preserves profiles, licensing files and Keychain, but an older Outlook may not understand a newer profile. If macOS denies access to a data folder, copying stops; grant Terminal access in Privacy & Security only if needed, then retry.

## Run

Download [office-update-fix.zip](https://github.com/juandiegoc30/office-update-fix/releases/latest/download/office-update-fix.zip), extract it, and open **Office-Update-Fix.command**. Choose English and start with diagnostics.

If macOS blocks double-click execution, inspect the script and use Terminal instead. Do not disable Gatekeeper. Type `cd ` with a trailing space, drag the extracted folder into Terminal and press Return. Then run:

```bash
bash scripts/office-update-fix.sh diagnose en
bash scripts/office-update-fix.sh recover en
# Alternative: remove the updater without reinstalling Office
bash scripts/office-update-fix.sh remove-autoupdate en
```

Do not prefix these commands with `sudo`. The assistant asks for administrator privileges when needed. It never asks for your Microsoft password. Replace `en` with `es` for Spanish.

## What happens

The assistant checks the platform and closed apps, requests confirmation of your license and external backup, and copies these existing folders:

- `~/Library/Group Containers/UBF8T346G9.Office`
- `~/Library/Containers/com.microsoft.Outlook`
- `~/Documents/Microsoft User Data`

It downloads the official suite without Teams using HTTPS, checks the trusted installer signature and Microsoft's identity, and requests macOS assessment. A recorded SHA-256 is a local audit record, not a published official checksum.

After a second confirmation, it disables and unloads AutoUpdate services, stops their processes and moves the four known components to a protected backup. It moves existing apps to that backup and installs the full suite: Word, Excel, PowerPoint, Outlook and OneNote, including apps you did not previously use. It removes AutoUpdate again and checks all five versions.

Open Word yourself, sign in with the purchasing account and verify that editing works. Then check Outlook's local mail, contacts and calendars. Stop if anything is missing or an unexpected migration is requested; see [RECOVERY.md](RECOVERY.md#english).

Keep both backup folders: `~/Library/Application Support/Office Update Fix/run.*` and `/Library/OfficeUpdateFix.*`. The assistant displays their exact locations. It keeps the installer and logs. It does not automatically roll back profiles after failure.

## Updates and limitations

Removing AutoUpdate affects every app using that updater. It does not prevent updates via other tools, the App Store or manual installation. Another Microsoft installer can bring AutoUpdate back; run diagnostics afterward. Removal is reversible, not a permanent guarantee.

Office 2021 support ended October 13, 2026. Staying on an old version means missing future security fixes. See [recovery](RECOVERY.md#english) to restore updating. macOS protections remain enabled.

## The case and evidence

A relative owns Office Home & Business 2021 linked to their Microsoft account. An update was followed by a licensing error, and reinstalling from the account page did not resolve it. The exact cause and this Mac's recovery outcome are not yet confirmed. Microsoft 365 branding in a package does not prove that a perpetual license has changed.

- [Reddit discussion](https://www.reddit.com/r/macapps/comments/1xf6o5f/fixed_how_to_get_microsoft_office_2021_for_mac_to/): community experience, not a Microsoft confirmation.
- [Official update archive](https://learn.microsoft.com/en-us/officeupdates/update-history-office-for-mac): October 6, 2026 installer. The filename uses `16.113.26100421`; the listed version is `16.113.4`.
- [Office 2021 lifecycle](https://learn.microsoft.com/en-us/lifecycle/products/office-2021).
- [Activate Office for Mac](https://support.microsoft.com/en-us/microsoft-365-activation-licensing/office-install/activate-office-for-mac).
- [Perpetual licenses and the Mac App Store](https://support.microsoft.com/en-us/microsoft-365-activation-licensing/microsoft-office-activation-and-the-mac-app-store): use apps distributed directly by Microsoft.
- [Outlook backups](https://support.microsoft.com/en-us/outlook/automatically-archive-or-back-up-outlook-for-mac-items).
- [mrsarac's Microsoft Update Remover](https://github.com/mrsarac/microsoft-update-remover), MIT licensed, inspired the AutoUpdate component inventory. This implementation is independent; it never downloads or executes that script.

Reviewed October 26, 2026. Independent project, not affiliated with Microsoft. No activators or licensing bypasses.

## Development

`scripts/` holds the tool; `docs/` holds the bilingual static website. Select **GitHub Actions** under **Settings → Pages → Source**. No website dependencies or external services are required.

```bash
bash -n scripts/office-update-fix.sh Office-Update-Fix.command tests/test.sh tests/scenario.sh
bash tests/test.sh
python3 tests/site.py
```

Tests substitute all system mutations. They cover cancellation, signature rejection, operation order, installer failure and unexpected versions, not actual activation, Microsoft servers, launch services, installation or Outlook migrations. Do not run real recovery on a development Mac.

Before marking this release tested, record macOS, architecture, app versions before/after, license edition, activation outcome and preservation of all local Outlook data. Never publish keys, email, profiles or private logs.
