# Post-Eradication Checklist

| Field | Value |
|---|---|
| Case ID | IR-2026-0310-EXBI |
| Date | March 18, 2026 |
| Analyst | Ronald Phillips |
| Scope | Validation, credential recovery, and go-live controls after `eradicate.sh` |
| Eradication Executed | March 18, 2026, beginning approximately 14:37 PDT (21:37 UTC); completion reported in response notes. Referenced execution log was not recovered for this edition. |
| Evidence Snapshot | `/home/siteuser02/eradication-evidence-20260318-143745/` — downloaded to `05-evidence/eradication-evidence-20260318-143745/` |

---

## Purpose

This checklist records post-execution validation, credential rotation, hardening, provider follow-up, and return-to-service checks.

Do not return the site to production until the required validation and credential items are complete.

---

## Immediate Validation

- [x] Review the `eradicate.sh` log for any `[FAIL]` output — **COMPLETE** (2 post-script FAILs resolved manually: malicious DB options and user ID 8; fonts/ PHP FAIL was false positive — legitimate WP core files)
- [x] Confirm WordPress core verifies cleanly — **PASS** (`Success: WordPress installation verifies against checksums.`)
- [x] Confirm user ID 8 is absent — **COMPLETE** (script detection edge case; deleted manually via direct SQL + `wp user delete`)
- [x] Confirm `one_time_login_token` is absent — **PASS** (18 live tokens for user ID 1 cleared by Layer 8)
- [x] Confirm all known malicious options and TDS rows are gone — **COMPLETE** (script detection edge case; deleted manually via direct SQL; verified empty)
- [x] Confirm `_tds_cache_selfheal` is absent — **PASS**
- [x] Confirm `wp-perf-analytics` is removed — **PASS**
- [x] Confirm no rogue PHP files remain in uploads, fonts, upgrade, or languages — **PASS** (fonts/ PHP files are legitimate WP 6.9.4 core classes)
- [x] Confirm `.htaccess` is free of `TDS_NOCACHE` — **PASS** (already removed before the script ran)
- [x] Confirm both `.backup_time` artifacts are gone — **PASS**

---

## Containment Cleanup

- [x] Remove `wp-includes/fonts/.htaccess` — **COMPLETE** (removed as part of post-script fix; core checksums clean after removal)
- [x] Remove remaining 4 containment `.htaccess` files — **COMPLETE** (March 18, 2026; all 4 confirmed absent: `upgrade/`, `uploads/woocommerce_uploads/`, `uploads/`, `languages/`)
- [x] Re-test the former webshell URLs — **COMPLETE** (March 18, 2026)
  - `font-metrics.php` → 404
  - `wp-update-verify.php` → 404
  - `wc-report-handler.php` → 404 (intermittent 503 is transient SharedHost Provider mod_fcgid load; file confirmed absent; no PHP errors logged)
  - `wp-cache-stats.php` → 404 (same caveat)
  - `wp-locale-handler.php` → 404 (same caveat)

---

## Credential and Secret Rotation

- [x] Rotate all WordPress administrator passwords — **COMPLETE** (March 18, 2026; all 5 accounts rotated via WP-CLI `--skip-plugins --skip-themes`)
- [ ] Enable MFA for all WordPress administrator accounts — **PENDING** (requires each user to log in and configure their own MFA device)
- [x] Rotate the SharedHost Provider panel password — **COMPLETE** (new user `siteuser02` created; original `siteuser01` access revoked)
- [ ] Confirm SharedHost Provider panel MFA is enabled — **PENDING**
- [x] Rotate or review all SharedHost Provider SSH/SFTP credentials and authorized keys — **COMPLETE** (authorized_keys inspected; two keys present: IR key `example-bistro siteuser02 2026-03-18` and analyst desktop key `docker-remote`, both verified legitimate; no attacker keys found)
- [x] Rotate the MySQL password in SharedHost Provider and update `wp-config.php` — **COMPLETE** (new password set for `example_bistro_db`; `wp-config.php` updated and DB connectivity verified)
- [x] Confirm all WordPress sessions were invalidated and salts changed — **COMPLETE** (Layer 8: session tokens cleared, one-time tokens cleared, salts shuffled)
- [ ] Disconnect and reconnect Jetpack / WordPress.com — **DEFERRED to site owner** (Jetpack v15.6 active with 26 modules; requires Site Owner's WordPress.com account to reconnect and issue fresh token; while reconnecting: disable `sso` and `woocommerce-analytics` modules; stats and monitor are the primary value features)
- [ ] Rotate Elementor Pro license key — **DEFERRED** (license key `[REDACTED-LICENSE-KEY]` is exposed; rotation requires access to Web Agency's Elementor account at plugin-vendor.invalid; Agency Developer 1 is unresponsive; risk is low — key cannot be used to access site or customer data; practical risk is license seat abuse; action owner: Web Agency when reachable)
- [ ] Rotate Neuron Builder integration secrets if populated — **PENDING** (not verified during IR; check dashboard)
- [ ] Rotate LiteSpeed / CDN Provider integration credentials if populated — **PENDING** (not verified during IR; check dashboard)
- [ ] Rotate UpdraftPlus remote backup credentials — **PENDING** (plugin inactive; review if remote backup destination is configured)
- [x] Klaviyo API key — **N/A** (plugin was never active; plugin deleted; no key in options table; no action required)
- [ ] Review and rotate mailbox / SMTP credentials if present — **PENDING**

---

## Functional Testing

> **Note:** Maintenance mode was lifted unintentionally when `wp rewrite flush --hard` ran with plugins loaded (March 18, 2026 ~15:xx PDT). Site went live at that point. Wordfence was already active in protecting mode; this alone does not establish absence of exposure during the transition. Remaining functional checks are post-live confirmations.

- [x] Maintenance mode lifted — **COMPLETE** (unintentional but accepted; site is live)
- [x] Confirm the homepage loads normally — **PASS** (confirmed during rewrite flush testing)
- [x] Confirm `wp-login.php` renders and authenticates normally — **PASS** (confirmed during credential rotation)
- [ ] Confirm no redirects to unknown domains occur — **PENDING** (spot-check from client network recommended)
- [ ] Confirm visual page rendering is normal — **PENDING** (site owner to verify)
- [x] Confirm the child theme behaves acceptably after cleanup — **PASS** (`hello-biz-child/functions.php` is 30 lines, PHP syntax verified clean; PHP error logs show no parse errors post-eradication)

---

## Hardening

- [x] Add `DISALLOW_FILE_EDIT` to `wp-config.php` — **COMPLETE** (added March 18, 2026; blocks theme/plugin editor in WordPress admin)
- [x] Raise PHP memory limit — **COMPLETE** (`WP_MEMORY_LIMIT = 256M` in `wp-config.php`; `memory_limit = 256M` in `.user.ini`; resolves Elementor OOM crashes)
- [x] Put the Wordfence firewall into protecting mode — **COMPLETE** (confirmed: `firewallEnabled=1`, `wafStatus=enabled`, `blockBadPOST=1`)
- [x] Enable Wordfence login brute-force protection — **COMPLETE** (confirmed: `loginSecurityEnabled=1`, max 4 failures / 5 min window, 240 min lockout, invalid user lockout enabled)
- [x] Reduce administrator accounts to the minimum necessary — **COMPLETE** (webagency / user ID 4 and AgencyAdmin2 / user ID 5 deleted; remaining admins: Manager/[REDACTED-OWNER-USERNAME], SiteOwnerUser, ResponderAdmin)
- [ ] Install and configure WP Ghost (Hide My WP) login hiding — **DEFERRED to site owner** (WP Ghost 5.5.02 installed from WordPress.org and verified clean; currently deactivated; "ghost" mode caused 503 on SharedHost Provider shared hosting without proper .htaccess support; recommend site owner or developer configure via WordPress admin UI in "safe" or "default" mode; `hmwp_options` DB record seeded with hidden login path `3a2d3ee1a6f5297d9a3a80b1` but not in effect while plugin is deactivated; Wordfence brute-force protection is active as interim mitigation)
- [x] Enable and review a full Wordfence scan — **COMPLETE** (March 18, 2026; triggered via WP-Cron; `lastScanCompleted: ok`; 0 issues found; next auto-scan scheduled March 20, 2026)
- [x] Normalize file permissions across the WordPress tree — **COMPLETE** (March 18, 2026; all dirs 755, no world-writable files or dirs; `wp-config.php` tightened to 640; two PHP stubs in uploads verified clean; Google Safe Browsing confirmed clean; SPF/DKIM/DMARC verified — `p=reject`, `-all`, SHA-256 DKIM all in force)
- [x] Disable XML-RPC — **COMPLETE** (March 18, 2026; blocked via `.htaccess` `<Files "xmlrpc.php">` deny rule; confirmed 404; Jetpack v15.6 does not require it; homepage unaffected)
- [x] Preserve current DMARC enforcement and verify SPF / DKIM alignment — **COMPLETE** (March 18, 2026; `p=reject; pct=100`, SPF `-all` hardfail via SharedHost Provider + Mail Relay, DKIM `sharedhost` selector RSA/SHA-256 active; verified during file permissions pass)

---

## Provider Follow-Up

- [ ] Ask SharedHost Provider for panel audit and login records for March 8-18, 2026
- [ ] Ask SharedHost Provider to inspect, preserve, and then remove `/home/siteuser01`
- [ ] Ask SharedHost Provider to confirm there are no extra panel users, subdomains, redirects, or DNS changes tied to the incident
- [ ] Ask SharedHost Provider to confirm the SSH/SFTP username-field payload was preserved and then cleared

Provider follow-up remained pending in the retained record; correspondence is held privately.

---

## Return to Service

- [x] Required validation items complete
- [x] Site is live — maintenance mode lifted March 18, 2026
- [ ] Remaining credential rotations complete — **BLOCKED** on: MFA enablement (requires user action at login), Jetpack reconnect, Elementor Pro (deferred/Web Agency)
- [ ] Remaining functional checks complete — **PENDING** (cross-domain redirect check, site owner visual sign-off)
- [x] Hardening complete — **MOSTLY COMPLETE** (Wordfence WAF+scan, XML-RPC block, file permissions, DMARC/SPF/DKIM all done; WP Ghost deferred to site owner)
- [ ] Provider follow-up requests sent — **PENDING**
- [ ] Site owner sign-off received — **PENDING**

---

*Document Reference: IR-2026-0310-EXBI / post-eradication-checklist / Generated March 18, 2026*
