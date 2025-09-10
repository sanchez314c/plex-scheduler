## What does this PR do?

<!-- One or two sentences describing the change. -->

## Why?

<!-- What problem does it solve, or what improvement does it make? -->

## Files Changed

| File | What changed |
|------|-------------|
| | |

## Testing Done

Describe how you tested this. For changes to `plex-scheduler.sh`, list the boundary cases you verified for `is_within_schedule()`:

- [ ] Plex starts when time is within window
- [ ] Plex stops when time is outside window
- [ ] Overnight crossover (22:00 to 04:00) works correctly
- [ ] Manual `start`/`stop` commands work regardless of schedule
- [ ] `status` output is accurate
- [ ] `plex-control-panel.sh` menu works

## CHANGELOG Updated?

- [ ] Yes, added an entry to `CHANGELOG.md`

## Notes for Reviewer

<!-- Anything unusual, edge cases to watch for, or context that helps review. -->
