Below is a focused review based on the code in this workspace after the latest changes. Tests were run: `npm test`.

Security Review

What’s solid
- CSP is defined and tightened. default-src is 'self', media-src is limited to the radio CDN, and connect-src is restricted to 'self'. src-tauri/tauri.conf.json:26-31
- External links use rel="noopener noreferrer". src/components/AboutDialog.tsx:133-141
- Now-playing data is fetched via Rust command rather than direct webview fetch. src/services/nowPlaying.ts:50
- HTTP client timeouts are set for SR API calls. src-tauri/src/lib.rs:46-72
- Station ID allowlist validation is in place. src-tauri/src/lib.rs:40-45
- Unused opener plugin was removed, reducing attack surface. src-tauri/Cargo.toml:21-25

Potential issues / improvements
- None material observed in this pass.

Coding Standards Review

What’s strong
- TypeScript strict mode is enabled. tsconfig.app.json:17-27
- Types are well-defined for stations and now-playing data. src/data/stations.ts, src/services/nowPlaying.ts
- Clear separation between UI, data, and service layers.
- Logging is DEV-only to avoid noisy production logs. src/components/RadioPlayer.tsx:41-90, src/services/nowPlaying.ts:22-63
- Clipboard usage now awaits and handles errors. src/components/AboutDialog.tsx:43-50
- Volume updates do not reload the stream. src/components/RadioPlayer.tsx:139-205
- One-shot now-playing fetch is restored (no polling side effects). src/services/nowPlaying.ts:102-110
- Polling is prevented from rescheduling when there are no listeners. src/services/nowPlaying.ts:41-96
- Tests assert About dialog alignment and no polling on one-shot fetch. test/AboutDialog.test.tsx:200-240, test/nowPlaying.test.ts:44-55

Issues / improvements
- None material observed in this pass.

Ratings

- Security: 10/10
CSP tightening, timeouts, station allowlist, and reduced plugin surface cover the main hardening items.

- Coding Standards: 10/10
Behavioral regressions are fixed and tests cover the critical cases.

- Overall: 10/10

Suggestions (actionable, high ROI)
- Keep dependency audit and tests in CI to prevent regressions.
