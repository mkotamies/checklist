CRITICAL: after every change you should run `just check`

Build signing toggle:

- Default (signing disabled): run `just check`
- Enable signing when needed: `DISABLE_CODE_SIGNING=0 just check`

Notes:

- Disabling signing sets `CODE_SIGNING_ALLOWED=NO` for simulator builds.
- To re-enable fully, set a Development Team in Xcode or pass `DEVELOPMENT_TEAM=<TeamID>`.
