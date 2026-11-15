# Supplemental Manual Remediation Report

| Field | Value |
|---|---|
| Case ID | IR-2026-0310-EXBI |
| Date | March 18, 2026 |
| Analyst | Jay Phillips |
| Scope | Manual actions required alongside `eradicate.sh` |

---

> **Recorded outcome, March 18, 2026:** Cleanup began at approximately 14:37 PDT (21:37 UTC). The response notes report the manual fixes described below and return to service after verification of the known artifacts. This report preserves the pre-cleanup findings and required actions; see [recovery checks](post-eradication-checklist.md) for recorded completion and remaining follow-up.

---

## Current-State Verdict (Pre-Eradication — Historical)

**The malware is not inert in the current server configuration, but emergency containment has been applied.**

Live validation on March 18, 2026 initially showed:

- `https://www.example-bistro.invalid/` returns `503 Service Unavailable`
- `https://www.example-bistro.invalid/wp-login.php` returns `503 Service Unavailable`
- `https://www.example-bistro.invalid/wp-includes/fonts/font-metrics.php` returns `200 OK` (via Hide My WP bypass)
- `https://www.example-bistro.invalid/wp-content/uploads/wp-cache-stats.php` returns `200 OK` (via Hide My WP bypass)

That meant maintenance mode was suppressing normal WordPress entry points, but was **not** neutralizing the directly reachable PHP webshells. The Hide My WP `.htaccess` rewrite rules included a bypass parameter (`?bypass_key=[REDACTED-BYPASS-KEY]`) that allowed direct access to any PHP file in `wp-content/` and `wp-includes/` subdirectories, including all 5 webshells. The bypass key was trivially guessable (site owner's first name).

### Emergency Containment Applied (March 18, 2026 10:05 PDT)

`.htaccess` files with `<Files *.php> Require all denied` rules were deployed to all 5 webshell directories:

- `wp-includes/fonts/.htaccess`
- `wp-content/upgrade/.htaccess`
- `wp-content/uploads/woocommerce_uploads/.htaccess`
- `wp-content/uploads/.htaccess`
- `wp-content/languages/.htaccess`

Post-deployment verification confirmed all 5 webshell URLs now return `503` across three test vectors (no params, bypass param only, bypass + webshell auth key). The attacker's remote access via webshells is now blocked.

**Note for eradication:** These containment `.htaccess` files should be removed or replaced with appropriate production rules after the webshell files themselves are deleted during eradication. The `wp-content/uploads/.htaccess` rule in particular will block legitimate PHP execution in the uploads directory (e.g., some plugins place PHP handlers there). Since the eradication script deletes the webshell files, the containment `.htaccess` files can be removed in the post-eradication cleanup step.

The host still has active on-disk malware, active persistence residue, and an alternate admin-login mechanism, but the webshell remote-access path is now closed.

---

## Supplemental Findings

- After SharedHost Provider support's partial March 18 cleanup, the current live host still contains `advanced-cache.php`, `wp-perf-analytics`, all five webshells, modified core/theme files, database persistence, auth residue, and the `_tds_cache_selfheal` WP-Cron event. `wp-content/mu-plugins/` and the `TDS_NOCACHE` block were removed by support, but the compromise remains active enough to require full coordinated eradication.
- User ID 1 (`Manager`) still has a populated `one_time_login_token` usermeta entry from the active `sharedhost-panel-login.php` plugin. The plugin is a legitimate SharedHost Provider panel SSO bridge, not malware, but any live token is an alternate authentication path and should be explicitly cleared after the panel compromise.
- Orphaned `wp_s8yhai_usermeta` rows still exist for deleted user ID 8. They are not a live account by themselves, but they should be removed as cleanup residue.
- A second `.backup_time` file exists at the web root (`/home/siteuser02/example-bistro.invalid/.backup_time`) in addition to `wp-admin/.backup_time`. Both files are 333 bytes with 2015 timestamps and contain SharedHost Provider backup system encoded metadata -- they are **legacy hosting artifacts, not attacker tools**. The eradication script now removes both copies. They have no forensic value to this case.
- The active child-theme file `wp-content/themes/hello-biz-child/functions.php` is currently permissioned as `--w-------`. In this state the script cannot safely snapshot or inspect it.
- The original script's `wp-perf-analytics` detection string was too specific for the current live file; `eradicate.sh` has since been patched to match the live host more reliably.
- No additional user crontab, shell-startup persistence, or extra SSH keys were found under `/home/siteuser02`.
- `/home/siteuser01` still exists but was not readable from `siteuser02`. That remains a visibility gap and needs provider-side review.

---

## Manual Checklist

### Before Running `eradicate.sh`

- [ ] Keep the site in maintenance mode, but do **not** treat maintenance mode as containment by itself.
- [ ] Preserve the existing pre-containment and post-containment reachability evidence already recorded as EVD-020; do not re-open access paths just to reproduce fresh `200 OK` responses.
- [ ] Export evidence for the active SharedHost Provider one-time-login token:
  ```bash
  wp --skip-plugins --skip-themes db query "SELECT user_id, meta_key, meta_value FROM wp_s8yhai_usermeta WHERE meta_key = 'one_time_login_token'"
  ```
- [ ] Export evidence for orphaned user-8 metadata before deleting it:
  ```bash
  wp --skip-plugins --skip-themes db query "SELECT user_id, meta_key, meta_value FROM wp_s8yhai_usermeta WHERE user_id = 8"
  ```
- [ ] Manually snapshot `wp-content/themes/hello-biz-child/functions.php` by a method that works with its current unreadable permissions.
- [ ] Manually correct the child-theme file permissions before relying on script logic against it.
- [ ] Capture and then clear the malicious ClickFix payload still stored in the SharedHost Provider SSH/SFTP username field.
- [ ] Retain SharedHost Provider panel access for hosting administration, but clear any active `one_time_login_token` values before go-live.

### Manual Actions Required During or Immediately After the Script

- [ ] Watch the script output for `wp-perf-analytics`. If the script does not remove it, delete it manually:
  ```bash
  wp --skip-plugins --skip-themes plugin deactivate wp-perf-analytics || true
  rm -rf ~/example-bistro.invalid/wp-content/plugins/wp-perf-analytics
  ```
- [ ] Manually inspect or replace `wp-content/themes/hello-biz-child/functions.php`; do not rely on the script to classify it as clean while it is unreadable.
- [ ] Verify the script successfully removed the extra web-root `.backup_time` artifact, cleared `one_time_login_token`, and deleted orphaned metadata for deleted attacker user ID 8. These are now handled by the patched script and should only require manual follow-up if verification fails.
- [ ] Do not remove `sharedhost-panel-login.php` by default; it is a legitimate SharedHost Provider helper plugin. Remove it only if the site owner intentionally wants to stop using SharedHost Provider panel-initiated one-time logins after credential rotation and MFA hardening.
- [ ] Remove editor residue such as `..htaccess.swp` after confirming it is not needed.

### Credential and Secret Rotation

Rotate these only **after** the credential-stealing code and webshells are removed.

- [ ] Reset all WordPress admin passwords for users `Manager`, `SiteOwnerUser`, `webagency`, `AgencyAdmin2`, and `ResponderAdmin`.
- [ ] Enforce MFA for every WordPress administrator.
- [ ] Rotate the SharedHost Provider panel password and verify MFA is enabled there.
- [ ] Rotate or review every SharedHost Provider SSH/SFTP credential and every authorized key tied to the account.
- [ ] Rotate the MySQL password in SharedHost Provider and update `wp-config.php`.
- [ ] Invalidate all WordPress sessions and login cookies. `eradicate.sh` handles salts and session-token deletion, but verify it completed successfully.
- [ ] Rotate any mailbox or SMTP credentials represented by `mailserver_login` and `mailserver_pass`.
- [ ] Disconnect and reconnect Jetpack / WordPress.com so `jetpack_private_options`, `jetpack_secrets`, and `jetpack_protect_key` are replaced.
- [ ] Rotate Elementor/Elementor Pro integration secrets if populated:
  `elementor_google_maps_api_key`,
  `elementor_pro_activecampaign_api_key`,
  `elementor_pro_convertkit_api_key`,
  `elementor_pro_drip_api_token`,
  `elementor_pro_getresponse_api_key`,
  `elementor_pro_mailchimp_api_key`,
  `elementor_pro_mailerlite_api_key`,
  `elementor_pro_recaptcha_secret_key`,
  `elementor_pro_recaptcha_v3_secret_key`,
  `elementor_pro_stripe_live_secret_key`,
  `elementor_pro_stripe_test_secret_key`,
  `elementor_pro_license_key`.
- [ ] Rotate Neuron Builder integration secrets if populated:
  `neuron_google_map_api_key`,
  `neuron_instagram_access_token`,
  `neuron_mailchimp_api_key`,
  `neuron_recaptcha_secret_key`,
  `neuron_recaptcha_v3_secret_key`,
  `neuron_typekit_api_key`.
- [ ] Rotate LiteSpeed / CDN Provider integration credentials if those options are in use:
  `litespeed.conf.api_key`,
  `litespeed.conf.cdn-cloudflare_email`,
  `litespeed.conf.qc-token`.
- [ ] Review and rotate any remote backup credentials stored by UpdraftPlus:
  `updraft_dreamobjects`,
  `updraft_dropbox`,
  `updraft_ftp`,
  `updraft_googlecloud`,
  `updraft_googledrive`,
  `updraft_onedrive`,
  `updraft_s3`,
  `updraft_s3generic`,
  `updraft_sftp`,
  `updraft_updraftvault`,
  `updraft_webdav`.
- [ ] Review WooCommerce payment/integration secrets and webhooks if `woocommerce_braintree_paypal_settings` or any offsite payment connector is actually in use.
- [ ] Review Klaviyo, domain registrar, DNS, CDN, and business-email credentials even if they were not directly visible in this host review.

### Workstation and Account Recovery

- [ ] Treat every workstation that logged into WordPress or SharedHost Provider during the compromise window as potentially compromised by the ClickFix chain.
- [ ] Run AV/EDR scans on those systems or reimage them if confidence is low.
- [ ] Remove any browser-saved site, panel, SMTP, and payment credentials from those endpoints.
- [ ] Force sign-out / revoke sessions on SharedHost Provider, WordPress.com/Jetpack, backup providers, email providers, and any admin browsers used during the incident.

### Provider-Side Follow-Up

- [ ] Ask SharedHost Provider to review panel audit logs, login history, and any available SSH/SFTP logs around March 8-18, 2026.
- [ ] Ask SharedHost Provider to inspect `/home/siteuser01` for residual web content, cron jobs, SSH keys, mail forwarders, or legacy account-level artifacts.
- [ ] Confirm there are no extra panel users, subdomains, redirects, or DNS changes left by the attacker.

### Go-Live Validation

- [ ] Confirm all five webshell URLs now return `404` or `403`, not `200`.
- [ ] Confirm `wp-content/advanced-cache.php` is absent or known-good.
- [ ] Confirm `_tds_cache_selfheal` is gone from WP-Cron.
- [ ] Confirm `TDS_NOCACHE` is still absent from `.htaccess` after cleanup.
- [ ] Confirm `sharedhost-panel-login` has no remaining `one_time_login_token` metadata before go-live, unless a new token is intentionally created after panel hardening.
- [ ] Confirm `wp_s8yhai_usermeta` has no rows for `user_id = 8`.
- [ ] Confirm both `.backup_time` artifacts are gone.
- [ ] Confirm `wp-login.php` renders cleanly only after maintenance mode is intentionally lifted.

---

## Additional Information Still Worth Obtaining

- [ ] Exact SharedHost Provider panel audit records for the initial compromise window.
- [ ] A provider-side review of `/home/siteuser01`.
- [ ] A trusted copy of the live `hello-biz-child/functions.php` contents before replacement.
- [ ] A confirmed inventory of which stored third-party credentials are actually active versus stale plugin residue.

---

## Operator Notes

- The current environment should be treated as **compromised but partially constrained**, not clean.
- Pre-containment testing proved the webshells were reachable via the Hide My WP bypass parameter, but emergency containment now blocks that path. The site should still not return to service before eradication because the malware and persistence layers remain present on disk and in the database.
- `sharedhost-panel-login.php` is a legitimate SharedHost Provider plugin that generates one-time WordPress login URLs by storing `one_time_login_token` usermeta and redeeming it through `wp-login.php`. In this incident it materially matters because the compromised SharedHost Provider panel could create or retain that alternate login path until tokens are cleared and panel access is hardened.
