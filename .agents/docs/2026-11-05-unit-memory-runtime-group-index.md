# Unit-memory runtime version group registration

Date: 2026-11-05. Tracks mcpp-community/mcpp#885.

Register Form-A openkal-musl 0.27.7 as three new platform entries while preserving every historical entry. The exact source manifest selects public Linux 0.24.2 and openkal-ld 0.4.5; public interfaces, feature choices and implementation remain unchanged. Its upstream PR #85 passed all ten native, cross-start and image checks before merge/tag 2dd80df14614860899453f8a317dc784c967413b.

GitHub and local-gtc GitCode source archives both contain 1270694 bytes and have SHA256 a32c6947d2c894d1595a8970296697921fd00c05ceed19c7561a81172efa02b8. No new feature or autoupdate rule is needed for this additive version. The existing direct test member selects the new release. Matching runtime/platform packages follow public predecessor availability; no engine performance qualification is inferred.

Released mcpp 2026.11.3.1 runs the updated openkal-musl-tests member in the isolated test home: one test passes, with descriptor cleanup, stack, mapping contents and unmapping observations checked. Its lock selects index+mcpplibs@0.27.7 and Linux 0.24.2. Lua syntax, mirror, package-name, namespace, duplicate-version and platform-parity checks, xpkg parse and diff checks pass.
