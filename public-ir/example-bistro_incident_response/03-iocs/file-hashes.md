# File Hashes -- IR-2026-0310-EXBI

**Collected:** March 18, 2026 via `sha256sum` on live server
**Server:** iad1-shared-b8-33.sharedhost.invalid (user: siteuser02)

---

## Malicious File SHA256 Hashes

| SHA256 | File | Classification |
|---|---|---|
| `74097512bb04534aef04e10ed2ccb4fa6bbf3a4e80e4a04e226916b4fef43982` | `wp-content/mu-plugins/session-manager.php` | TDS Engine |
| `243581bada950102336785b5ddb90bb84809eba6556a0728d37c7f98a3605de0` | `wp-content/mu-plugins/session-manager.php.bak` | TDS Engine (backup) |
| `b796eed003b7a088b645e5ce47845ad4b91dde7f3cc482db9bb65ed440576092` | `wp-content/mu-plugins/wp-user-query.php` | Stealth Toolkit |
| `5928710e09da492c0a046bc96f46869f40c44dfd5e432e482e07aa9ad06d95e5` | `wp-content/mu-plugins/health-check.php` | Stub/Loader |
| `3f4bb8dc57dcc317ddabc5d7821ff0ddaa4dc76dc6ffbd2aea2d5d91086c8f19` | `wp-includes/fonts/font-metrics.php` | Webshell v1.3 |
| `8f8b5b000f23ed3f123c546e8e7e7734d56255640fdccf00a81214f21cbdff19` | `wp-content/upgrade/wp-update-verify.php` | Webshell v1.3 |
| `546060e196ab70218702c9e36596f99aa967ea5e37463876882ca73674de3804` | `wp-content/uploads/woocommerce_uploads/wc-report-handler.php` | Webshell v1.3 |
| `953edb60e7c7991a8857aecbe4d3d7646829982cfcd13159c26d6e423e617705` | `wp-content/uploads/wp-cache-stats.php` | Webshell v1.3 |
| `9aca3e2e560d894cf3503bfe5976041732708ecf327638215c3f95cc427d81e0` | `wp-content/languages/wp-locale-handler.php` | Webshell v1.3 |
| `801af0772effdb8bd6634bebf08694ace8dbc77033e81f08090e6074ab6c2afe` | `wp-content/advanced-cache.php` | Persistence / Auto-restore |
| `5a9799298236c327f77ed0c2200c7fbb213cbe44b4c943f05456bac5399c23d0` | `wp-content/uploads/2024/06/Stained_Heart_Red-600x500.png` | Credential Dump |
| `a6c861ca4d80f84c8a8b3d9810bb36d48509cbc24b283715eba186d43e1a5ea1` | `wp-includes/css/wp-editor-font.css` | Encrypted Data |
| `3b2038657cb5e3f9e5dc8bbcc224123737b76e1019729aa1358cd106106343fa` | `wp-admin/.backup_time` | Encrypted Data |
| `83af1b257fa1716b75da99763241bb7900abb3f36ef8a9023cbf093e26887a93` | `wp-login.php` | Modified Core File (credential stealer at line 1327) |
| `96780cfb26165a1378529319739508c67e126417f49c73793d5d2c2178464146` | `wp-content/plugins/wp-perf-analytics/wp-perf-analytics.php` | XOR-encrypted JS Injector (fake plugin) |
| `5c1b190358c5c2a3ff0612a02ae71eddf9b1ca4c565f82cf26ac5186c06796a4` | `wp-content/themes/hello-biz/functions.php` | Modified Theme (credential stealer + admin creator backdoor) |

---

## Notes

- The 5 webshell files have **different hashes** despite identical functionality because each has a slightly different relative path calculation (`realpath(__DIR__.'/../..')` vs `realpath(__DIR__.'/../../..')`) and different header comments ("Font Metrics Calculator" vs "Cache Statistics Handler", etc.)
- `session-manager.php` and `session-manager.php.bak` have different hashes, indicating the `.bak` may be an earlier version
- `wp-perf-analytics` was discovered during plugin audit on March 18 -- a fake "WP Performance Analytics" plugin that injects XOR-encrypted (key: 240) JavaScript into every page footer, skipping admins/bots/scanners. Modified March 16 2026. This is the **client-side JS redirect component** of the TDS.
- `functions.php` contains TWO injections: (1) a hidden admin creator backdoor at `?create_admin=erwesdxsas` (user `adminpro`/`@@Admin234$` -- never triggered), and (2) the credential stealer authenticate filter. The admin creator may indicate a second wave of the attack or a separate attacker.
- These hashes can be used to scan other WordPress installations on the same shared hosting server for similar compromises

---

*Document: IR-2026-0310-EXBI / File Hashes v1.1 (updated with wp-perf-analytics and functions.php findings)*
