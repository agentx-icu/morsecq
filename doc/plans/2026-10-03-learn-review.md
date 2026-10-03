# Learn feature review

**Goal:** review the whole Learn tab (the `morse_core` engine, the `morse_trainer` pedagogy, `morse_io` keying and audio, the app's training layer and the Learn screens) and fix the real defects at their cause.

**Method:** a parallel review of `morse_trainer`; the remaining areas went to Codex (`gpt-6.1-sol`, read-only, against `1d15469`). Every fix ships with a regression test. Nothing was run on a physical device.

## Fixed

### Pedagogy (`morse_trainer`)

| Finding | Effect | Fix |
|---|---|---|
| The Koch unlock rule ignored inserted symbols | Typing both candidates for a symbol the learner cannot tell apart scored 100 % and unlocked the next lesson | `KochCourse.passes` uses `strictAccuracy` (insertions count against the copy); the receive summary shows the same figure |
| Session length could be set below the course minimum | The slider went down to 20 symbols while a lesson needs 50; such sessions never unlocked anything, silently | `TrainingSettings.minSessionChars` is `KochCourse.defaultMinCharsPerSession`; stored shorter lengths are lifted when the settings file loads |
| Streak arithmetic used `Duration.inDays` between local midnights | Across a daylight-saving change the day gap is 23 h or 25 h, so the streak was not extended or not reset | `TrainerProgress.daysBetween` compares calendar dates; send sessions go through the new `recordPractice`, so the two streak rules cannot drift |
| Session and symbol totals were sums over the trimmed history | After 500 sessions the Stats totals stopped growing and then shrank | Lifetime counters in `TrainerProgress`, persisted; older files start from their history |
| SRS promoted every symbol of every session | Daily lesson drills pushed the whole learned set to the 14-day box in four days | A good result promotes a symbol only when it is due; a bad one always demotes |
| `SrsScheduler.record` indexed past the interval list for a box beyond it | `RangeError` when finishing a session (only reachable from code; the file store already rejects such files) | The current box is clamped to `maxBox` |
| `CharWeights.explicit` accepted an infinite weight | Weighted picks always returned one symbol | Non-finite weights (and default weight) are rejected |
| `recentCharsForLesson` never counted the first symbol past lesson 1 | Slightly wrong extra weight for early lessons | The window counts lessons; reaching lesson 1 adds both of its symbols |

The review also suggested clamping out-of-range values in `TrainerProgress.fromJson`. That was not done: `FileTrainerStore` deliberately rejects such files so it can fall back to the `.bak` of the previous save, and clamping would defeat that recovery.

### Keying, audio and the training layer

| Finding | Mobile scenario | Fix |
|---|---|---|
| Losing focus with a key held kept it down | Desktop, and tablets with a hardware keyboard: the key-up goes to the newly focused widget | `StraightKeyButton` and `PaddleButtons` release keyboard-held keys on focus loss; fingers still on the key stay down |
| Restarting (or switching keyer) with the key held corrupted the decoder | Hold the straight key with one finger, tap Restart with another: the next dit decoded as `T` | `MorseDecoder.clearText` drops a held mark, new `cancelMark` / `SendSession.cancelHeld`; the screen releases held input and rebuilds the key widgets on restart, mode change and backgrounding |
| Backgrounding left playback and keying running while the sidetone was muted | Phone call or app switch mid-round: the round played out unheard | On Android/iOS, going to the background stops receive playback (Replay on return) and drops held send input; playback does not start while backgrounded |
| A failed progress save stranded the drill on "recording" | Full disk: no result, no way out but Back, which then skipped the leave check | Record methods return `saved`; the result is shown with a snack bar whose Retry rewrites the in-memory progress (never re-applies the session) |
| Screen readers could not key | VoiceOver / TalkBack found the keys but activation did nothing | Straight key: custom actions "Dit" / "Dah" timed from the session speed; paddles: a semantic tap presses and releases the paddle |
| Answer keys and result cells took a whole row each | The keypad of a late lesson was about 2,300 dp tall on a phone; result rows stacked vertically | Keys shrink-wrap their label (still ≥ 48 dp); each result column gets one width shared by the sent and copied rows, so they wrap together |
| Prosigns sharing a pattern with punctuation scored as wrong | A perfect `<AR>` decoded as `+` and scored 0 in send practice | `SendSession` reads a look-alike mark as the target's prosign when the target asks for the prosign and not the mark |
| Stored speeds were only checked for being positive | `characterWpm: 1e300` loaded and rounded the dit to zero | The settings file is clamped to the slider ranges (speed, Farnsworth, tone, session length) on load |
| A haptic-only profile had no feedback on desktop | Restoring a phone profile on a desktop | The flash fallback applies when no output the platform supports is on; the receive screen's warning uses the same rule |
| The sample in Training settings kept old switches | Turn sound off after playing the sample: it still sounded | Changing sound / flash / haptic drops the sample bundle; a bundle prepared for old switches is discarded |
| The daily-goal slider did not move | It saved on every drag step but never redrew | Shown live while dragging, saved once on release |

## Second review round

Codex reviewed the fixes and found seven more problems in them, all fixed with tests:

| Finding | Fix |
|---|---|
| A key widget replaced while a finger was on it got the finger's late up/cancel after dispose (`setState` after dispose) | `StraightKeyButton` and `PaddleButtons` ignore pointer callbacks once unmounted; dispose has already released the input |
| Clamping stored lifetime counters up to the history hid a corrupt file, so a healthy `.bak` was overwritten | `fromJson` keeps stored counters; `FileTrainerStore` rejects counters below the kept history, which falls back to the backup |
| Flipping a feedback switch while the sample was being prepared allowed a second, overlapping creation | One creation at a time; a bundle built for old switches is disposed and built again |
| A flash-only sample created on demand played without its overlay | The screen rebuilds when it accepts the new bundle |
| A cancelled press kept the gap that preceded it, faking an "element gap too long" diagnostic | `SendSession.cancelHeld` removes that gap |
| `recentCharsForLesson` counted symbols, not lessons, so a window reaching lesson 1 missed its first symbol | The window is `count` lessons; reaching lesson 1 adds both of its symbols |
| The save-retry widget test passed without tapping Retry | The test waits for the snack bar, taps Retry and checks the store holds exactly one session |

## Not fixed (and why)

- **Koch order wording.** The plan said "the common LCWO sequence"; the table is the G4FON order. The plan now says G4FON; the order itself is unchanged so no learner's lesson is remapped.
- **`MorseTiming` keeps assert-only validation.** It is a `const` value type used everywhere; untrusted values only come from the settings file, which is now bounded.
- **A course fingerprint in the progress file** (to re-map lessons if the Koch table ever changes) is left for the change that first reorders the table.
- **Send diagnostics** have no "dah too long" kind and judge severity on very short targets; a pedagogy refinement, not a defect.

## Device checks still owed

- VoiceOver and TalkBack keying with the new actions.
- Background / resume during a receive round and with a paddle held, on iOS and Android.
- Keypad and result layout with large text on a 320 dp phone and in landscape.
- Product screenshots of the receive drill were not regenerated in this change (the keypad looks different now).

## Change log

- **2026-10-03** — Created with the review and its fixes.
- **2026-10-03** — Added the second Codex round on the fixes.
