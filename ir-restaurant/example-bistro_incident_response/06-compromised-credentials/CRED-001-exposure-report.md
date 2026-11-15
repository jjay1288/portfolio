# Compromised Credentials Report

| Field          | Value                        |
|----------------|------------------------------|
| **Case ID**    | IR-2026-0310-EXBI            |
| **Document**   | CRED-001-exposure-report     |
| **Date**       | March 18, 2026               |
| **Classification** | CONFIDENTIAL -- CREDENTIAL MATERIAL |
| **Analyst**    | Jay Phillips                 |
| **Subject**    | Example Bistro (example-bistro.invalid) -- Compromised Credentials |

---

## 1. Executive Summary

Two WordPress credential pairs were recovered from attacker-controlled storage on the compromised server. This report separates confirmed capture from suspected hosting-panel and workstation exposure. Local capture establishes exposure to the attacker; it does not by itself establish every external transfer or subsequent use.

The credential stealer operated through two components: a modified `wp-login.php` (line 1327) and a malicious `authenticate` filter injected into the active theme's `functions.php`. Captured credentials were written in cleartext to a file disguised as an image in the uploads directory.

---

## 2. Confirmed Credential Compromises

### 2.1 webagency (Agency Developer 1)

| Field | Detail |
|-------|--------|
| **Username** | agency-developer-1 (email used as login) |
| **Password** | `[REDACTED-PASSWORD]` |
| **Source** | Captured 4 times in cleartext in `wp-content/uploads/2024/06/Stained_Heart_Red-600x500.png` |
| **Capture Mechanism** | `wp-login.php` credential stealer (line 1327) and `hello-biz/functions.php` authenticate filter |
| **Associated Email** | agency-dev-1-agency.invalid |
| **WordPress Role** | Administrator (user ID 4) |
| **Risk Assessment** | **HIGH** -- Full administrative access to WordPress dashboard including plugin/theme installation, user management, and database access. Password follows a predictable pattern (`[REDACTED-PASSWORD]`) suggesting possible reuse across Web Agency client environments and other services. |

### 2.2 SiteOwnerUser (Site Owner)

| Field | Detail |
|-------|--------|
| **Username** | site-owner-user |
| **Password** | `[REDACTED-PASSWORD]` |
| **Source** | Captured 2 times in cleartext in same credential dump file (`Stained_Heart_Red-600x500.png`) |
| **Capture Mechanism** | Same as above -- `wp-login.php` credential stealer (line 1327) and `hello-biz/functions.php` authenticate filter |
| **Associated Emails** | [EMAIL-REDACTED], [EMAIL-REDACTED] |
| **WordPress Role** | Administrator (user ID 2) |
| **Risk Assessment** | **CRITICAL** -- Site owner account with full administrative privileges. Although the password appears randomly generated, it has been captured in cleartext and must be considered fully compromised. This account likely has the highest privilege level on the site. |

### 2.3 XOR-Encrypted Entries (DECRYPTED -- March 18, 2026)

| Field | Detail |
|-------|--------|
| **Count** | 3 XOR-encrypted entries in the credential dump (2 unique values) |
| **Encrypted Value 1** | `c19cW3V9QV1QV1F0XVNfAx8CCg8DeXgCVldEQVAFEApLXFZQXF4GABM=` (appears twice) |
| **Decrypted Value 1** | `agency-developer-1:[REDACTED-PASSWORD]` |
| **Encrypted Value 2** | `WlxAQ1xVRgtXE1poG25QMEcZIxF5TVsw` |
| **Decrypted Value 2** | `site-owner-user:[REDACTED-PASSWORD]` |
| **XOR Key Derivation** | `md5('a3f8b2c1d4e5f6071829304a5b6c7d8e9f0a1b2c3d4e5f607182930a1b2c3d4e' + 'www.example-bistro.invalid')` |
| **Computed XOR Key** | `909750412699876b1aeb945a99031fde` |
| **Manager Account Status** | **NOT PRESENT** -- The Manager account ([EMAIL-REDACTED], user ID 1) credentials were not captured in any of the 3 encrypted entries |
| **Finding** | All encrypted entries are re-captures of the same two accounts already found in plaintext (webagency and SiteOwnerUser). No additional credential compromise was discovered. |
| **Risk Assessment** | **RESOLVED** -- No new accounts identified. The Manager account password should still be changed as a precautionary measure, but there is no evidence it was captured by the credential stealer. |

### 2.4 Attacker-Created Account

| Field | Detail |
|-------|--------|
| **Username** | adminbackup1d8273 |
| **Email** | adminbackup@wordpress.org |
| **User ID** | 8 |
| **Created** | March 8, 2026 18:16:18 UTC |
| **Role** | Administrator |
| **Visibility** | HIDDEN from all WordPress interfaces by `wp-user-query.php` stealth toolkit (mu-plugin) |
| **Password** | Unknown -- set by the attacker at account creation |
| **Risk Assessment** | **CRITICAL** -- This is a fully attacker-controlled administrator account. It is invisible to site administrators through normal WordPress UI due to the stealth mu-plugin filtering it from all user queries. This account must be deleted entirely -- password rotation is not sufficient. |

---

## 3. Suspected hosting-panel and workstation exposure

A ClickFix-style PowerShell downloader was found in the hosting panel's SSH/SFTP username field. This created a possible execution path for an administrator who copied and ran it. The public record does not establish execution on a particular workstation or theft of browser-stored credentials.

| Field | Detail |
|-------|--------|
| **Observed Artifact** | ClickFix-style PowerShell downloader in the hosting panel |
| **Original Panel User** | siteuser01 |
| **Panel Password** | Unknown; browser theft is a hypothesis, not a confirmed capture in the retained evidence |
| **Scope of Compromise** | If endpoint execution occurred, browser-stored credentials and sessions may be exposed; endpoint review is outstanding |
| **Risk Assessment** | Potentially serious endpoint exposure; the recovered downloader alone does not establish second-stage behavior or which credentials were accessible. |

---

## 4. Credential Rotation Checklist

| Account | Type | Current Status | Action Required |
|---------|------|----------------|-----------------|
| WordPress: Manager ([EMAIL-REDACTED]) | WP Admin | **ROTATED** March 18, 2026 | Enable MFA |
| WordPress: SiteOwnerUser | WP Admin | **ROTATED** March 18, 2026 | Enable MFA |
| WordPress: webagency | WP Admin | **ROTATED** March 18, 2026 — notify Agency Developer 1 of breach | Enable MFA; advise password reuse review |
| WordPress: AgencyAdmin2 | WP Admin | **ROTATED** March 18, 2026 | Enable MFA |
| WordPress: ResponderAdmin | WP Admin | **ROTATED** March 18, 2026 | Enable MFA |
| WordPress: adminbackup1d8273 | Attacker account | **DELETED** March 18, 2026 (user ID 8, usermeta cleared) | No further action |
| SharedHost Provider panel | Hosting admin | **ROTATED** — new user `siteuser02` created; developer access (Agency Developer 1, Agency Developer 2) revoked | Enable MFA on panel |
| MySQL database | Database | **ROTATED** March 18, 2026 — `example_bistro_db` new password; `wp-config.php` updated and verified | No further action |
| SFTP/SSH authorized keys | Server access | **VERIFIED CLEAN** March 18, 2026 — two keys present (IR key + analyst desktop key `docker-remote`); no attacker keys found | No further action |
| Elementor Pro license key | Plugin license | **DEFERRED** — key exposed (`[REDACTED-LICENSE-KEY]`); rotation requires Web Agency's plugin-vendor.invalid account; Agency Developer 1 unresponsive; low risk (no site/data access path); 367 pages and 11 form widgets actively using Pro | Action owner: Web Agency when reachable |
| Klaviyo API | Email marketing | **N/A** — plugin was never active; deleted March 18, 2026; no key in options table | No further action |
| Square integration | Payment processing | **N/A** — WooCommerce was never used; Square integration not configured; no stored API keys | No further action |

---

## 5. Recommendations

1. **Immediate Actions**
   - Rotate all passwords listed as "CHANGE IMMEDIATELY" in the checklist above.
   - Delete the attacker-created account (`adminbackup1d8273`, user ID 8) entirely from the database.
   - Enable two-factor authentication (2FA) on all WordPress administrator accounts.
   - Notify Agency Developer 1 (Web Agency) that his credentials have been captured in cleartext and advise him to change passwords on any other service where he may have reused the same or similar password pattern.

2. **Client Notification**
   - Site Owner should be advised to change passwords on all services where credentials may have been saved in her browser, due to the ClickFix PowerShell trojan's browser credential harvesting capability.
   - A formal credential breach notification should be issued to all affected users.

3. **Long-Term Hardening**
   - Enforce strong, unique passwords via WordPress policy plugin.
   - Mandate 2FA for all administrator-level accounts.
   - Implement login attempt rate limiting.
   - Consider IP allowlisting for wp-admin access.

---

*Document Reference: IR-2026-0310-EXBI / CRED-001-exposure-report / Generated March 18, 2026*
