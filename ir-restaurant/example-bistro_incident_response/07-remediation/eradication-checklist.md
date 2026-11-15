# Eradication & Remediation Checklist

| Field          | Value                        |
|----------------|------------------------------|
| **Case ID**    | IR-2026-0310-EXBI            |
| **Document**   | eradication-checklist        |
| **Date**       | March 18, 2026               |
| **Classification** | CONFIDENTIAL               |
| **Analyst**    | Ronald Phillips                 |
| **Subject**    | Example Bistro (example-bistro.invalid) -- Eradication & Remediation |

---

> **Recorded outcome, March 18, 2026:** The response notes report completion of the eight cleanup layers, with residual database and account issues resolved manually. Snapshot metadata places the start at approximately 14:37 PDT (21:37 UTC). The complete execution log is not in the retained evidence. The checklist below preserves the planned work; see [recovery checks](post-eradication-checklist.md) for recorded results and outstanding follow-up.

> **CRITICAL: All eradication steps in Phase 1 must be performed in a single maintenance window. The malware has 5 persistence layers -- addressing them sequentially allows remaining layers to regenerate removed components. Do NOT reboot, reload, or visit the site between Layer 1 and Layer 5 completion. Coordinate all steps before beginning and execute them without interruption.**

---

## Pre-Eradication: Go / No-Go Preflight

Run these checks immediately before starting the maintenance-window cleanup. If any required item fails, stop and resolve it before executing `eradicate.sh`.

- [ ] Confirm the site is still in maintenance mode and normal public entry points return `503`
  ```bash
  curl -I https://www.example-bistro.invalid/
  curl -I https://www.example-bistro.invalid/wp-login.php
  ```

- [ ] Confirm emergency containment is still blocking all 5 webshell directories over HTTP
  ```bash
  curl -I "https://www.example-bistro.invalid/wp-includes/fonts/font-metrics.php?bypass_key=[REDACTED-BYPASS-KEY]"
  curl -I "https://www.example-bistro.invalid/wp-content/upgrade/wp-update-verify.php?bypass_key=[REDACTED-BYPASS-KEY]"
  curl -I "https://www.example-bistro.invalid/wp-content/uploads/woocommerce_uploads/wc-report-handler.php?bypass_key=[REDACTED-BYPASS-KEY]"
  curl -I "https://www.example-bistro.invalid/wp-content/uploads/wp-cache-stats.php?bypass_key=[REDACTED-BYPASS-KEY]"
  curl -I "https://www.example-bistro.invalid/wp-content/languages/wp-locale-handler.php?bypass_key=[REDACTED-BYPASS-KEY]"
  ```
  Expected result: `403` or `503`, not `200`

- [ ] Confirm no one else, including SharedHost Provider support, is making live file or WordPress changes during the maintenance window

- [ ] Verify `WP-CLI`, database access, and outbound package reachability still work from the host
  ```bash
  wp --skip-plugins --skip-themes db query "SELECT 1"
  curl -I https://wordpress.org/wordpress-6.9.4.zip
  curl -I https://downloads.wordpress.org/theme/hello-biz.latest-stable.zip
  ```

- [ ] Verify the child-theme file is readable and writable before relying on script logic
  ```bash
  chmod u+rw ~/example-bistro.invalid/wp-content/themes/hello-biz-child/functions.php
  ls -l ~/example-bistro.invalid/wp-content/themes/hello-biz-child/functions.php
  ```

- [ ] Confirm the current live artifacts that the script is expected to remove are still present or absent for a known reason
  ```bash
  wp --skip-plugins --skip-themes cron event list | grep _tds_cache_selfheal
  wp --skip-plugins --skip-themes plugin list | grep wp-perf-analytics
  wp --skip-plugins --skip-themes db query "SELECT user_id, meta_key FROM wp_s8yhai_usermeta WHERE meta_key = 'one_time_login_token'"
  ```

- [ ] Confirm the evidence set is complete and current before any destructive changes
  - `wp-content/themes/hello-biz-child/functions.php`
  - `one_time_login_token` evidence
  - orphaned `usermeta` for user ID 8
  - SharedHost Provider SSH/SFTP username-field ClickFix payload

- [ ] Confirm sufficient free disk space exists for the evidence snapshot directory and log output
  ```bash
  df -h "$HOME" .
  ```

- [ ] Confirm all credential-rotation actions are staged for immediately after eradication, not before
  - SharedHost Provider panel password and MFA
  - WordPress administrator passwords and MFA
  - SharedHost Provider SSH/SFTP credentials and authorized keys
  - MySQL password in SharedHost Provider and `wp-config.php`
  - Jetpack / WordPress.com
  - Elementor / Elementor Pro integrations
  - Neuron Builder integrations
  - LiteSpeed / CDN Provider integrations
  - UpdraftPlus remote backup credentials
  - Klaviyo and WooCommerce / payment-related integrations if active

- [ ] Confirm rollback expectations are understood
  - Do not restore files from the archive catalogued on March 10 or the oldest hosting backup without verifying the individual files against a trusted source
  - If the child theme cannot be safely cleaned, replace it with a minimal safe stub and restore function deliberately from a separately verified source

For a standalone maintenance-window runbook, see `pre-eradication-checklist.md`.

---

## Pre-Eradication: Evidence Preservation

Complete all evidence preservation steps before beginning eradication. Once malware is removed, forensic artifacts will be permanently lost.

- [ ] Collect SHA256 hashes of all 15 malicious files and record them in the evidence inventory
- [ ] Export database options for evidence preservation:
  - `wp db query "SELECT * FROM wp_s8yhai_options WHERE option_name = '_wp_mail_queue_log'" > evidence_mail_queue_log.sql`
  - `wp db query "SELECT * FROM wp_s8yhai_options WHERE option_name = '_wp_site_activity'" > evidence_site_activity.sql`
  - `wp db query "SELECT * FROM wp_s8yhai_options WHERE option_name = '_wc_analytics_data'" > evidence_wc_analytics.sql`
- [ ] Screenshot SharedHost Provider panel SSH/SFTP username field (contains ClickFix payload)
- [ ] Save copy of credential dump file (`Stained_Heart_Red-600x500.png`) to evidence storage
- [ ] Download copies of all malware artifacts to local evidence storage directory

### Pre-Eradication: Environment Preparation

These steps fix known issues that will prevent the eradication script from running correctly.

- [ ] Fix child theme file permissions so the script can snapshot and inspect it:
  ```bash
  chmod u+rw ~/example-bistro.invalid/wp-content/themes/hello-biz-child/functions.php
  ```
  Current permissions are `--w-------` (write-only). The script's `prepare_file_for_review()` requires read access. Without this fix, the script will skip the file with a warning and the child theme malware block will not be processed.

- [ ] Confirm the script file itself is the current approved version and syntax-check it before execution
  ```bash
  bash -n ~/eradicate.sh
  ```
  If the script is stored elsewhere, adjust the path accordingly.

---

## Phase 1: Eradication (Single Maintenance Window)

### Layer 1 -- Remove Persistence Bootstrap

The advanced-cache.php file serves as the initial bootstrap loader. It executes on every page load before WordPress fully initializes, loading and verifying the integrity of all other malware components.

- [ ] Delete or replace `wp-content/advanced-cache.php`
  ```bash
  rm ~/example-bistro.invalid/wp-content/advanced-cache.php
  ```

### Layer 2 -- Remove MU-Plugins

Must-Use plugins load automatically on every request and cannot be disabled through the WordPress admin interface. The attacker installed four malicious mu-plugins providing credential theft, user query manipulation, and self-healing capabilities.

- [ ] Delete session-manager.php
  ```bash
  rm ~/example-bistro.invalid/wp-content/mu-plugins/session-manager.php
  ```

- [ ] Delete session-manager.php.bak
  ```bash
  rm ~/example-bistro.invalid/wp-content/mu-plugins/session-manager.php.bak
  ```

- [ ] Delete wp-user-query.php
  ```bash
  rm ~/example-bistro.invalid/wp-content/mu-plugins/wp-user-query.php
  ```

- [ ] Delete health-check.php
  ```bash
  rm ~/example-bistro.invalid/wp-content/mu-plugins/health-check.php
  ```

- [ ] Delete malicious plugin `wp-perf-analytics`
  ```bash
  rm -rf ~/example-bistro.invalid/wp-content/plugins/wp-perf-analytics
  ```

### Layer 3 -- Remove Webshells

Five PHP webshells are distributed across the file system in directories that are rarely inspected. Each provides remote code execution capability to the attacker.

- [ ] Delete `wp-includes/fonts/font-metrics.php`
  ```bash
  rm ~/example-bistro.invalid/wp-includes/fonts/font-metrics.php
  ```

- [ ] Delete `wp-content/upgrade/wp-update-verify.php`
  ```bash
  rm ~/example-bistro.invalid/wp-content/upgrade/wp-update-verify.php
  ```

- [ ] Delete `wp-content/uploads/woocommerce_uploads/wc-report-handler.php`
  ```bash
  rm ~/example-bistro.invalid/wp-content/uploads/woocommerce_uploads/wc-report-handler.php
  ```

- [ ] Delete `wp-content/uploads/wp-cache-stats.php`
  ```bash
  rm ~/example-bistro.invalid/wp-content/uploads/wp-cache-stats.php
  ```

- [ ] Delete `wp-content/languages/wp-locale-handler.php`
  ```bash
  rm ~/example-bistro.invalid/wp-content/languages/wp-locale-handler.php
  ```

### Layer 4 -- Remove Database Persistence

The attacker stored configuration data, intercepted emails, surveillance logs, and backup copies of malware code in the WordPress options table. These entries allow malware regeneration even after file-level cleanup.

- [ ] Delete malware backup configuration
  ```bash
  wp db query "DELETE FROM wp_s8yhai_options WHERE option_name = 'wp_session_tokens_config'"
  ```

- [ ] Delete hidden user tracker
  ```bash
  wp db query "DELETE FROM wp_s8yhai_options WHERE option_name = '_pre_user_id'"
  ```

- [ ] Delete intercepted email log
  ```bash
  wp db query "DELETE FROM wp_s8yhai_options WHERE option_name = '_wp_mail_queue_log'"
  ```

- [ ] Delete exfiltrated order data
  ```bash
  wp db query "DELETE FROM wp_s8yhai_options WHERE option_name = '_wc_analytics_data'"
  ```

- [ ] Delete admin activity surveillance log
  ```bash
  wp db query "DELETE FROM wp_s8yhai_options WHERE option_name = '_wp_site_activity'"
  ```

- [ ] Delete TDS runtime / cache-bypass metadata
  ```bash
  wp db query "DELETE FROM wp_s8yhai_options WHERE option_name IN ('_tds_stats','_tds_config') OR option_name LIKE '\\_transient\\_\\_tds\\_%' ESCAPE '\\' OR option_name LIKE '\\_transient\\_timeout\\_\\_tds\\_%' ESCAPE '\\'"
  ```

- [ ] Delete `_tds_cache_selfheal` WP-Cron event
  ```bash
  wp cron event delete _tds_cache_selfheal
  ```

### Layer 5 -- Remove Hidden Admin Account

The attacker created a hidden administrator account (user ID 8) that is filtered from all WordPress user queries by the stealth mu-plugin. This account must be removed at the database level after the mu-plugin is deleted (Layer 2).

- [ ] Delete attacker user account
  ```bash
  wp user delete 8 --reassign=1
  ```

- [ ] Verify user record removed
  ```bash
  wp db query "SELECT * FROM wp_s8yhai_users WHERE ID = 8"
  ```
  Expected result: Empty result set

- [ ] Verify user metadata removed
  ```bash
  wp db query "SELECT * FROM wp_s8yhai_usermeta WHERE user_id = 8"
  ```
  Expected result: Empty result set

### Modified Core & Theme Files

These files were modified by the attacker and must be restored to clean versions.

- [ ] Reinstall WordPress core (replaces modified `wp-login.php` and all core files)
  ```bash
  wp core download --force
  ```

- [ ] Clean theme `functions.php` -- Remove the credential stealer code appended to `wp-content/themes/hello-biz/functions.php`
  - Locate and delete the last block starting with the comment `// WordPress session analytics`
  - This block contains the `authenticate` filter hook that captures credentials on login

- [ ] Remove dormant `create_admin=erwesdxsas` backdoors from alternate theme files
  - `wp-content/themes/kaon/functions.php`
  - `wp-content/themes/lemonchili/functions.php`

- [ ] Remove the bounded `/* __mu_deployer__ */` malware block from `wp-content/themes/hello-biz-child/functions.php`
  - Do **not** restore it blindly from the archive catalogued on March 10 or the oldest SharedHost Provider backup
  - If additional malicious code remains after removing the bounded block, quarantine the file and replace it with a minimal safe stub or rebuild it from a separately verified source

- [ ] Reinstall the official `hello-biz` parent theme from WordPress.org
  ```bash
  wp theme install hello-biz --force
  ```

- [ ] Delete credential dump file
  ```bash
  rm ~/example-bistro.invalid/wp-content/uploads/2024/06/Stained_Heart_Red-600x500.png
  ```

- [ ] Delete encrypted data store
  ```bash
  rm ~/example-bistro.invalid/wp-includes/css/wp-editor-font.css
  ```

- [ ] Delete `.backup_time` files (SharedHost Provider legacy backup metadata -- not attacker artifacts, but should be removed as cleanup)
  ```bash
  rm ~/example-bistro.invalid/.backup_time
  rm ~/example-bistro.invalid/wp-admin/.backup_time
  ```
  Note: Both files are 333 bytes, dated 2015, and contain SharedHost Provider backup system encoded timestamps. They predate the March 2026 attack by over a decade. Safe to remove; no forensic value.

- [ ] Remove TDS cache-bypass residue from `.htaccess`
  - Delete the block between `# BEGIN TDS_NOCACHE` and `# END TDS_NOCACHE`

- [ ] **Change Hide My WP `admin_key` from `[REDACTED-BYPASS-KEY]` to a cryptographically random string** (elevated from Phase 4)
  - The current bypass parameter `?bypass_key=[REDACTED-BYPASS-KEY]` allows direct PHP file access outside WordPress routing
  - Generate a new random key: `openssl rand -hex 16`
  - Update the Hide My WP plugin settings via WP-CLI or directly in the options table
  - This must be done during eradication, not deferred to hardening, because the bypass parameter is a known attacker-accessible value

- [ ] Delete hidden uploads temp/config files and redirect guard log
  ```bash
  find ~/example-bistro.invalid/wp-content/uploads -maxdepth 1 -type f -name '.*.tmp'
  rm ~/example-bistro.invalid/wp-content/uploads/.redirect_blocked.log
  ```

---

## Phase 2: Credential Rotation

All credentials must be rotated after eradication is complete. Do not rotate credentials before eradication, as active credential stealers will capture the new passwords.

- [ ] Change all WordPress user passwords (users 1, 2, 4, 5, 9)
  ```bash
  wp user update 1 --user_pass="[NEW_STRONG_PASSWORD]"
  wp user update 2 --user_pass="[NEW_STRONG_PASSWORD]"
  wp user update 4 --user_pass="[NEW_STRONG_PASSWORD]"
  wp user update 5 --user_pass="[NEW_STRONG_PASSWORD]"
  wp user update 9 --user_pass="[NEW_STRONG_PASSWORD]"
  ```
- [ ] Enable two-factor authentication (2FA) on all WordPress admin accounts
- [ ] Verify SharedHost Provider panel password has been changed and 2FA is enabled
- [ ] Retain SharedHost Provider panel access, but clear any active one-time panel login token before bringing the site back:
  ```bash
  wp db query "DELETE FROM wp_s8yhai_usermeta WHERE meta_key = 'one_time_login_token'"
  ```
- [ ] Verify no orphaned metadata remains for attacker user ID 8:
  ```bash
  wp db query "DELETE FROM wp_s8yhai_usermeta WHERE user_id = 8"
  ```
- [ ] Change Klaviyo API keys and regenerate integration tokens
- [ ] Verify Square payment integration security and rotate API credentials if exposed

---

## Phase 3: Verification

All verification checks must pass before the site is returned to production.

- [ ] Run WordPress core integrity check
  ```bash
  wp core verify-checksums
  ```
  Expected result: `Success: WordPress installation verifies against checksums.`

- [ ] Verify user list is clean
  ```bash
  wp user list
  ```
  Expected result: Only 5 legitimate users; user ID 8 (`adminbackup1d8273`) must NOT appear

- [ ] Check for PHP files in uploads directory
  ```bash
  find wp-content/uploads/ -name '*.php' -not -name 'index.php'
  ```
  Expected result: No output (no PHP files found)

- [ ] Check mu-plugins directory is clean
  ```bash
  ls -la wp-content/mu-plugins/
  ```
  Expected result: Either the directory is absent following the earlier cleanup, or it contains only legitimate files after cleanup

- [ ] Verify site loads correctly
  - HTTP 200 response on homepage
  - No redirects to external or unknown domains
  - Visual inspection confirms normal page rendering

- [ ] Test wp-login.php works correctly
  - Login page renders without errors
  - Successful authentication with new credentials
  - No credential capture code present (verify source)

- [ ] Verify database is clean of all malware entries
  ```bash
  wp db query "SELECT option_name FROM wp_s8yhai_options WHERE option_name IN ('wp_session_tokens_config','_pre_user_id','_wp_mail_queue_log','_wc_analytics_data','_wp_site_activity','_tds_stats','_tds_config') OR option_name LIKE '\\_transient\\_\\_tds\\_%' ESCAPE '\\' OR option_name LIKE '\\_transient\\_timeout\\_\\_tds\\_%' ESCAPE '\\'"
  ```
  Expected result: Empty result set

- [ ] Verify `.htaccess` is clean of TDS residue
  ```bash
  grep -n 'TDS_NOCACHE' ~/example-bistro.invalid/.htaccess
  ```
  Expected result: No output

- [ ] Verify `_tds_cache_selfheal` is gone
  ```bash
  wp cron event list | grep _tds_cache_selfheal
  ```
  Expected result: No output
- [ ] Verify SharedHost Provider one-time login tokens are gone
  ```bash
  wp db query "SELECT user_id, meta_key FROM wp_s8yhai_usermeta WHERE meta_key = 'one_time_login_token'"
  ```
  Expected result: Empty result set unless a new token is intentionally generated after SharedHost Provider credential rotation

- [ ] Remove emergency containment `.htaccess` files from webshell directories (deployed March 18, 2026 10:05 PDT as pre-eradication containment)
  ```bash
  rm ~/example-bistro.invalid/wp-includes/fonts/.htaccess
  rm ~/example-bistro.invalid/wp-content/upgrade/.htaccess
  rm ~/example-bistro.invalid/wp-content/uploads/woocommerce_uploads/.htaccess
  rm ~/example-bistro.invalid/wp-content/uploads/.htaccess
  rm ~/example-bistro.invalid/wp-content/languages/.htaccess
  ```
  These files block all PHP execution in these directories. They were deployed to cut off attacker webshell access before eradication. After the webshell files are deleted, these deny rules are no longer needed and may interfere with legitimate plugin behavior (e.g., some plugins place PHP handlers in `wp-content/uploads/`). If a production `.htaccess` is needed in `wp-content/uploads/` to block PHP execution permanently as a hardening measure, replace the deny-all rule with a more targeted rule that allows `index.php` and other known-legitimate files.

For a standalone post-execution validation and recovery runbook, see `post-eradication-checklist.md`.

---

## Phase 4: Hardening

Post-eradication hardening measures to reduce the risk of recompromise.

- [x] ~~Add DMARC DNS record to prevent email spoofing~~ -- **ALREADY CONFIGURED**: Live DNS confirmed `v=DMARC1; p=reject; fo=1; rua=mailto:[EMAIL-REDACTED];ruf=mailto:[EMAIL-REDACTED];pct=100`. No action required.

- [ ] Change Hide My WP custom login URL from `/hidden-login` to a new random string
  - Current value exposes a predictable login path

- [ ] Change Hide My WP `admin_key` from `[REDACTED-BYPASS-KEY]` to a strong random string
  - **ELEVATED from hardening:** This parameter currently allows the Hide My WP bypass (`?bypass_key=[REDACTED-BYPASS-KEY]`) that was used to access webshells directly. Although the containment `.htaccess` rules now block PHP execution in webshell directories, the bypass parameter itself should be changed during eradication to prevent any future misuse. Do not defer to post-eradication hardening.

- [ ] Add file edit restriction to `wp-config.php`
  ```php
  define('DISALLOW_FILE_EDIT', true);
  ```

- [ ] Set correct file permissions across the WordPress installation
  ```bash
  find ~/example-bistro.invalid/ -type f -exec chmod 644 {} \;
  find ~/example-bistro.invalid/ -type d -exec chmod 755 {} \;
  chmod 600 ~/example-bistro.invalid/wp-config.php
  ```

- [ ] Reduce administrator accounts -- downgrade `AgencyAdmin2` and `webagency` to Editor or Author role if they are not actively performing site development
  ```bash
  wp user set-role 5 editor   # AgencyAdmin2 (if applicable)
  wp user set-role 4 editor   # webagency (if applicable)
  ```

- [ ] Enable Wordfence full malware scan and review results
- [ ] Configure Wordfence firewall rules (Learning Mode -> Enabled and Protecting)
- [ ] Disable XML-RPC if not required by any active integration
  ```php
  add_filter('xmlrpc_enabled', '__return_false');
  ```
- [ ] Consider migration to a managed WordPress hosting provider with built-in WAF and malware scanning

### Provider-Side Follow-Up

These items require SharedHost Provider support action and cannot be completed from the `siteuser02` SSH account.

- [ ] Request SharedHost Provider review of `/home/siteuser01` for residual web content, cron jobs, SSH keys, mail forwarders, or legacy account-level artifacts. This directory is inaccessible from `siteuser02` (permission denied) and remains a visibility gap.
- [ ] Request SharedHost Provider panel audit logs and login history for the period March 8-18, 2026
- [ ] Confirm no extra panel users, subdomains, redirects, or DNS changes were made by the attacker

---

## Sign-Off

| Role | Name | Date | Signature |
|------|------|------|-----------|
| IR Analyst | Ronald Phillips | | |
| Site Owner | Site Owner | | |

---

*Document Reference: IR-2026-0310-EXBI / eradication-checklist / Generated March 18, 2026*
