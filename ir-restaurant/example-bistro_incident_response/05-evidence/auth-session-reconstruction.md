# Authenticated Admin Session Reconstruction

**Case:** IR-2026-0310-EXBI  
**Scope:** Server-backed reconstruction of successful or highly probable authenticated WordPress admin sessions using:

- `wp_s8yhai_usermeta.session_tokens`
- `_wp_site_activity`
- SharedHost Provider HTTPS access logs

**Time basis:** WordPress session tokens are Unix timestamps converted to UTC and server-local PDT (UTC-7). SharedHost Provider access logs are in PDT.

---

## Summary

The original `_wp_site_activity` dates were only approximate. Converting the underlying Unix timestamps and correlating them to access-log evidence produces the following exact or near-exact admin session reconstruction.

User attribution provided during response validation identifies `[IP-REDACTED]` as Example Bistro ownership (`SiteOwnerUser`) and `[IP-REDACTED]` as responder/administrator (`Manager`). Those sessions should be treated as legitimate admin activity unless contradicted by separate evidence.

## Reconstructed Sessions

| User | Evidence Type | Login Time (PDT) | IP | User-Agent | Corroborating Access-Log Activity | Confidence |
|---|---|---:|---|---|---|---|
| `SiteOwnerUser` | `_wp_site_activity` login | 2026-03-10 16:57:24 | `[IP-REDACTED]` | Firefox 148 on macOS 10.15 | `POST /wp-login.php` at `2026-03-10 16:57:23`, followed by `GET /wp-admin/admin.php?page=ai1wm_export` at `16:57:38`; same IP also shows sustained admin activity from `09:04:41` through `16:59:00`. User attributed this IP to the site owner. | High |
| `webagency` | `session_tokens` + `_wp_site_activity` login | 2026-03-13 07:13:11 | `[IP-REDACTED]` | Chrome 144 on Windows 10 | `POST /wp-login.php` with `302` at `2026-03-13 07:12:46` | High |
| `webagency` | `session_tokens` + `_wp_site_activity` login | 2026-03-13 07:17:17 | `[IP-REDACTED]` | Chrome 144 on Windows 10 | Repeated `GET /wp-login.php` attempts followed by `POST /wp-login.php` with `302` at `2026-03-13 07:16:37` | High |
| `webagency` | `session_tokens` + `_wp_site_activity` login | 2026-03-16 14:27:43 | `[IP-REDACTED]` | Chrome 144 on Windows 10 | Full login chain preserved: `GET /wp-login.php` `14:27:38`, `POST /wp-login.php` `302` `14:27:42`, `confirm_admin_email` flow `14:27:45-14:27:47`, `GET /wp-admin/` `200` `14:27:49`, then `theme-install.php` and `plugins.php` | High |
| `webagency` | `session_tokens` + `_wp_site_activity` login | 2026-03-17 03:56:37 | `[IP-REDACTED]` | Chrome 144 on Windows 10 | Session token and malware activity log confirm login; no preserved `wp-admin` page sequence found in accessible logs for that exact minute | Medium |
| `SiteOwnerUser` | `session_tokens` login | 2026-03-17 15:43:12 | `[IP-REDACTED]` | Firefox 148 on macOS 10.15 | Later same-day admin browsing from same IP/UA at `21:12:21-21:24:40` (`theme-editor.php`, `nav-menus.php`, `profile.php`, `tools.php?page=redirection.php...`). User attributed this IP to the site owner. | Medium |
| `Manager` | `session_tokens` login | 2026-03-17 19:44:28 | `[IP-REDACTED]` | Chrome 146 on Windows 10 | Same IP/UA shows authenticated `POST /wp-admin/admin-ajax.php` requests against `admin.php?page=WordfenceTools` from `20:46:12` through `21:11:10`; initial successful redirect is not preserved. User attributed this IP to the responder/admin. | Medium |
| `Manager` | `session_tokens` login | 2026-03-17 22:33:41 | `[IP-REDACTED]` | Chrome 146 on Windows 10 | Exact successful one-time login flow preserved: `GET /wp-login.php?user_id=1&one_time_login_token=...` `302` at `22:33:40`, then `GET /wp-admin/` `200` at `22:33:41`, followed by `Wordfence` admin pages and `admin-ajax` requests through `22:49:07`. User attributed this IP to the responder/admin. | High |

## Exact Timestamp Conversions

| Source Timestamp | UTC | PDT | Source |
|---|---|---|---|
| `1773187044` | 2026-03-10 23:57:24 UTC | 2026-03-10 16:57:24 PDT | `_wp_site_activity` `SiteOwnerUser` login |
| `1773411191` | 2026-03-13 14:13:11 UTC | 2026-03-13 07:13:11 PDT | `_wp_site_activity` `webagency` login |
| `1773411437` | 2026-03-13 14:17:17 UTC | 2026-03-13 07:17:17 PDT | `_wp_site_activity` `webagency` login |
| `1773696463` | 2026-03-16 21:27:43 UTC | 2026-03-16 14:27:43 PDT | `_wp_site_activity` `webagency` login |
| `1773744997` | 2026-03-17 10:56:37 UTC | 2026-03-17 03:56:37 PDT | `_wp_site_activity` `webagency` login |
| `1773787392` | 2026-03-17 22:43:12 UTC | 2026-03-17 15:43:12 PDT | `_wp_site_activity` + `session_tokens` `SiteOwnerUser` login |
| `1773801868` | 2026-03-18 02:44:28 UTC | 2026-03-17 19:44:28 PDT | `session_tokens` `Manager` login |
| `1773812021` | 2026-03-18 05:33:41 UTC | 2026-03-17 22:33:41 PDT | `session_tokens` `Manager` login |

## Notable Observations

- `SiteOwnerUser`'s March 10 session was substantially longer than the original rough timeline implied. The same IP/UA remained active in the admin area from approximately `09:04` until at least `16:59` PDT, with a preserved re-auth at `16:57:23`.
- `webagency` had rapid successive successful logins from different IPs on March 13: `[IP-REDACTED]` at `07:13` PDT and `[IP-REDACTED]` at `07:17` PDT.
- The March 16 `webagency` session at `[IP-REDACTED]` is the cleanest preserved administrative login sequence in the log set and includes immediate post-login navigation to `theme-install.php` and `plugins.php`.
- The preserved HTTPS logs begin on March 10, while the malware deployment window is March 8. On the evidence currently available, `webagency` can be confirmed as a post-compromise WordPress admin user whose credentials were stolen, but not as the initial access source or the operator who deployed the malware.
- User-provided context confirms Agency Developer 1 (`webagency`) had SharedHost Provider panel access. That makes Agency Developer 1 a plausible access path for the stolen-panel-credential scenario, but it is still not enough to attribute the March 8 deployment to him without March 8 panel logs, panel-side audit data, or workstation forensics.
- `SiteOwnerUser` activity from `[IP-REDACTED]` is now attributed by the user to the site owner, so those entries are treated as legitimate owner administration rather than suspicious infrastructure.
- `Manager` shows two March 17 session tokens from `[IP-REDACTED]`. The later one is fully corroborated by a successful one-time login token redirect into `/wp-admin/`; the earlier one is supported by same-IP/same-UA authenticated admin-ajax traffic but lacks the initial successful redirect in the preserved logs. The user attributed this IP to the responder/admin.
- The available logs also show repeated one-time login token attempts that failed with `404` or `500` before the later successful `Manager` login. These likely reflect responder troubleshooting during the SharedHost Provider restore/user migration window rather than attacker activity.

## Gaps

- The accessible SharedHost Provider log set does not preserve every successful redirect or cookie exchange, so some sessions can only be confirmed by combining session-token metadata with surrounding admin-page requests.
- The accessible SharedHost Provider log set does not reach back to March 8, 2026, so it cannot directly show who performed the initial malware deployment during the file timestamp window.
- `/home/siteuser01` is not readable from `siteuser02`, so any legacy account-local browser/session artifacts under the old user remain outside current visibility.
