# First-day and seventh-day beginner trial

[简体中文](BEGINNER_TRIAL.zh-CN.md)

This is an executable observation protocol for **5–10 volunteers who have not learned Morse code**. No participant results have been collected by this document. The first-day target is that at least 80% complete the app's first lesson within ten minutes without instruction from the observer. This small trial identifies friction; it does not estimate population learning outcomes.

## Prepare

Record the exact app version, source commit, package hash, OS and audio output. Install on a participant-owned or explicitly designated test device, retaining existing learning data unless the participant chooses a separate clean profile/device. Test that the website and app can produce an audible tone at a comfortable volume. Do not start the app in the middle of a course.

Explain that participation is voluntary, the participant may stop, and answers are not a grade. Ask permission before observing or sharing any notes. Use participant codes P01–P10 rather than names; keep contact arrangements outside the observation file. The website lesson sends/saves no answers, has no microphone access and does not transfer progress to the app. Do not add telemetry, record audio, or capture unrelated personal information.

## Day 1: observe, do not teach

1. Open the product website. Ask, “Can you try learning your first two letters here?” Time from choosing the lesson to its result. Let the participant use examples, replays and keyboard navigation. Note where they hesitate and whether they understand the difference between K and M. Record the displayed score and replay disclosure as practice, not mastery.
2. Ask the participant to choose the download for their system and open the app. Record installation failure separately from learning failure, including any distribution/signature warning. An unsigned iOS archive is not an installable consumer channel.
3. Ask, “Where would you start?” Allow up to ten minutes for the existing first lesson. Observe actual choices, help requested, sound failures and stopping points. Do not click for them. Stop timing when they finish or elect to stop.
4. On Learn home ask, “What would you practise next, and why?” The compact plan now names its next required step and displays the domain reason before Continue. Record whether that visible information answers the question without opening Plan details.
5. Finish one guided practice if the participant wants to. Ask, “What changed in your learning record? Have you passed a course lesson?” Plan completion, assisted practice and independent challenge evidence must remain distinct. Do not tell them they have mastered K/M based on a six-sound web trial.
6. Ask the participant to close and reopen the app, find today's progress and describe where to continue. End with “When would you choose to use this again?” Record their words, not an inferred retention prediction.

## Day 7: continue the same learning profile

Schedule this observation seven days after the actual first-day session only if the participant agrees; this file creates no reminder or contact message. Before suggesting a task, ask whether they chose to practise in between and why. Self-report and observed app history are different evidence; label each. A participant who does not return is an outcome, not an empty success.

Ask them to resume from Learn home, explain the recommended practice and its reason, complete one step of their choice, and locate the progress afterwards. Record confusion, requested help, independent challenge outcomes and audio/environment problems. Do not reset the learning profile or substitute a fresh beginner session.

## Observation record and decisions

Copy [the empty CSV template](fixtures/beginner-observations.csv) locally, one row per task. `success`, time, score, replays and help are blank until directly observed. `not_run`, `stopped`, `blocked_install`, `completed_with_help` and `completed_unassisted` are different outcomes. Retain only the minimum notes agreed with participants; sharing/export is manual.

After Day 1 and Day 7, summarize actual denominators: invited, consented, installed, started, completed unassisted, chose to return, and lost to follow-up. Prioritize reproducible blockers to first success and misunderstanding of progress. A planned sample, test script or automated test is never a real-person result.

## Device checks outside the trial

Physical Android/iPhone Bluetooth routing, a headset connecting while audio starts, system lock/unlock, permission changes and formally signed channel upgrades need explicit device/package evidence. Widget tests and simulator runs do not prove those behaviors. Record `needs_device` or `needs_signed_channel` until exercised with the candidate bytes. The first-success UI changes do not alter microphone, route or signing code.
