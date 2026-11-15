# Evidence inventory — IR-2026-0310-EXBI

This index identifies the private artifacts used to prepare the public case. Original evidence, credentials, client identifiers, and executable malware are excluded. Artifact checks were performed offline; no client system or attacker endpoint was contacted.

| Evidence | Retained artifact and finding | Verification basis |
| --- | --- | --- |
| EVD-001–004: backup analysis | March 8 archive filename; March 10 listing/scan output; 18,897 entries; 21,890,291-byte SQL export | Listing, scan output and SQL file available; the full archive was not re-acquired for this edition |
| Child-theme comparison | Archive listing: 1,095 bytes. Live capture: 170,140 bytes with a bounded deployment block | Listing compared with retained live sample; not a byte comparison with the original archive |
| EVD-008: server findings | Webshells, theme backdoors, database persistence, and backdoor-request reconstruction | Static sample inspection plus recorded server analysis; public report excludes raw access logs |
| EVD-011: captured credentials | Nine records: six plaintext and three encoded; two unique account/password pairs | Encoded entries independently decoded offline and matched to the plaintext pairs without publishing values |
| EVD-012: mail log | Seven JSON records containing recipient, subject and timestamp; no message bodies | Counted in the retained database evidence export |
| EVD-013: administrator log | Eleven JSON records | Counted in the retained database evidence export |
| WooCommerce store | `_wc_analytics_data` recorded empty | Database evidence export; client non-use is a separate reported fact |
| EVD-014: panel error log | Listed in the original inventory but not present among the retrieved artifacts | Not used to establish additional facts |
| EVD-015/018/019: live themes | Child-theme deployment block and administrator-creation backdoors in captured parent/inactive themes | Static inspection; no PHP execution |
| EVD-020: containment | Blocked requests to five webshells after directory PHP deny rules | Response notes; not re-tested against the live site |
| EVD-021: cleanup snapshot | Seven captured files and a SHA-256 manifest | All seven hashes verified inside the retained tar archive |
| Recovery checks | Core checksum results, webshell-path checks, credential rotation, and scan outcome | Documented response results; complete execution log not present in retrieved artifacts |

## Snapshot integrity and time basis

| Package | SHA-256 |
| --- | --- |
| Initial evidence tar | `48cca1fe4ad498d8abab05504f4d7e97846248518fc7e035e03dc696389d2dae` |
| Cleanup evidence tar | `243798d269b95f0d5de7c6556b7f6bbed6a9a019ebe49731531b86c97bdc0f0f` |

The cleanup snapshot name contains the local timestamp `20260318-143745`. The script uses local `date`; the tar records its new directory and manifest at `2026-03-18T21:37:48Z`. This supports 14:37 PDT / 21:37 UTC as the start of evidence capture. Captured file mtimes are retained historical file metadata, not snapshot creation times.

The evidence supports the findings and limits in the [incident report](../01-incident-report/IR-2026-0310-EXBI.md). A checksum verifies the retained bytes against a recorded digest; it does not independently establish acquisition history or that a system was free of other compromise.
