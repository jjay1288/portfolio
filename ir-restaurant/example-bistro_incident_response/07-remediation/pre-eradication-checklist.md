# Pre-Eradication Checklist

| Field | Value |
|---|---|
| Case ID | IR-2026-0310-EXBI |
| Date | March 18, 2026 |
| Analyst | Ronald Phillips |
| Scope | Immediate preflight before running `eradicate.sh` |

---

## Purpose

Use this checklist immediately before the recorded cleanup sequence to confirm access, evidence preservation, and readiness. It describes the March 2026 procedure, not a current instruction to modify the site.

If any required check fails, stop and resolve it before running `eradicate.sh`.

---

## Site State

- [ ] Confirm the site is still in maintenance mode
  ```bash
  test -f ~/example-bistro.invalid/.maintenance
  ```

- [ ] Confirm normal public entry points still return `503`
  ```bash
  curl -I https://www.example-bistro.invalid/
  curl -I https://www.example-bistro.invalid/wp-login.php
  ```

- [ ] Confirm emergency containment is still blocking all 5 webshell paths
  ```bash
  curl -I "https://www.example-bistro.invalid/wp-includes/fonts/font-metrics.php?bypass_key=[REDACTED-BYPASS-KEY]"
  curl -I "https://www.example-bistro.invalid/wp-content/upgrade/wp-update-verify.php?bypass_key=[REDACTED-BYPASS-KEY]"
  curl -I "https://www.example-bistro.invalid/wp-content/uploads/woocommerce_uploads/wc-report-handler.php?bypass_key=[REDACTED-BYPASS-KEY]"
  curl -I "https://www.example-bistro.invalid/wp-content/uploads/wp-cache-stats.php?bypass_key=[REDACTED-BYPASS-KEY]"
  curl -I "https://www.example-bistro.invalid/wp-content/languages/wp-locale-handler.php?bypass_key=[REDACTED-BYPASS-KEY]"
  ```
  Expected result: `403` or `503`, not `200`

---

## Environment Readiness

- [ ] Confirm no one else is changing the live site during the window
  - SharedHost Provider support
  - site owner
  - developer accounts

- [ ] Confirm `WP-CLI` and database connectivity work
  ```bash
  wp --skip-plugins --skip-themes db query "SELECT 1"
  ```

- [ ] Confirm WordPress.org package endpoints are reachable
  ```bash
  curl -I https://wordpress.org/wordpress-6.9.4.zip
  curl -I https://downloads.wordpress.org/theme/hello-biz.latest-stable.zip
  ```

- [ ] Confirm the current approved script is present and syntax-valid
  ```bash
  bash -n ~/eradicate.sh
  ```

- [ ] Confirm sufficient free disk space exists for evidence and logs
  ```bash
  df -h "$HOME" .
  ```

---

## Known Live Artifacts

- [ ] Fix and verify child-theme file permissions before execution
  ```bash
  chmod u+rw ~/example-bistro.invalid/wp-content/themes/hello-biz-child/functions.php
  ls -l ~/example-bistro.invalid/wp-content/themes/hello-biz-child/functions.php
  ```

- [ ] Confirm `_tds_cache_selfheal` still exists or is absent for a known reason
  ```bash
  wp --skip-plugins --skip-themes cron event list | grep _tds_cache_selfheal
  ```

- [ ] Confirm `wp-perf-analytics` still exists or is absent for a known reason
  ```bash
  wp --skip-plugins --skip-themes plugin list | grep wp-perf-analytics
  ```

- [ ] Confirm `one_time_login_token` still exists or is absent for a known reason
  ```bash
  wp --skip-plugins --skip-themes db query "SELECT user_id, meta_key FROM wp_s8yhai_usermeta WHERE meta_key = 'one_time_login_token'"
  ```

---

## Evidence Readiness

- [ ] Confirm current evidence exists for `hello-biz-child/functions.php`
- [ ] Confirm current evidence exists for `one_time_login_token`
- [ ] Confirm current evidence exists for orphaned `usermeta` rows for user ID 8
- [ ] Confirm the SharedHost Provider SSH/SFTP username-field ClickFix payload is captured
- [ ] Confirm the evidence destination and execution log path are decided

---

## Rotation Readiness

- [ ] Confirm credential rotation will happen only after eradication
- [ ] Confirm the post-eradication rotation set is ready:
  - SharedHost Provider panel password and MFA
  - WordPress administrator passwords and MFA
  - SSH/SFTP credentials and authorized keys
  - MySQL password and `wp-config.php` update
  - Jetpack / WordPress.com
  - Elementor / Elementor Pro integrations
  - Neuron Builder integrations
  - LiteSpeed / CDN Provider integrations
  - UpdraftPlus remote backup credentials
  - Klaviyo and WooCommerce / payment-related integrations if active

---

## Operator Decision

- [ ] Go: all required checks passed, evidence preserved, and the window is coordinated
- [ ] No-Go: one or more required checks failed and must be resolved before execution

---

*Document Reference: IR-2026-0310-EXBI / pre-eradication-checklist / Generated March 18, 2026*
