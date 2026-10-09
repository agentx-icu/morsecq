# Advanced learning

MorseCQ uses the whole-word recognition, QSO/POTA information extraction, short-story head copy, readable sending and contest practice directions of the [CW Academy Intermediate Curriculum v2.1](https://cwops.org/wp-content/uploads/2025/06/Practice-Instructions-Intermediate-ver.2.1.htm). Bundled exercises are original offline content. No course recordings are redistributed, and the app does not claim Academy endorsement or certification.

The Learn tab exposes a persistent mistake notebook, head-copy listening and goal routes. The notebook retains exact copying and semantic comprehension exercises, answers, timing and channel conditions. Explicit retries on two different days must be independently correct to recover an entry. Replaying or revealing cannot recover it; another failure resets recovery evidence. Entries and exercise IDs are bounded and deduplicated.

Listening covers words, phrases, QSO details, POTA details and short-story questions. Answers are enabled after playback. Unlearned-symbol previews and replay/reveal attempts are assisted. Question scores remain separate from character copying accuracy, Koch unlocks and receive SRS.

The first-QSO, conversation and contest routes use optional effective-speed milestones inspired by the Academy's 10/13/15/18/20/25 WPM stages. Each skill needs two independent recent attempts at 90% accuracy with sufficient samples; evidence expires after 28 days. QSO evidence uses first-try stage accuracy. Beginners retain the existing course path. After passing the course, daily plans include goal-specific comprehension and simulator steps, keeping review and sending. Changing goals preserves started and completed work.

The simulator adds contest exchanges and park-to-park POTA scenarios, corrected information and targeted repetition of heard CALL/RST/NAME/QTH/NR/PARK fields. Existing CQ, AGN, QRS and drafts remain supported. Keyed replies and explicitly assisted text replies are available. The scenario and timing snapshot travel with the local draft and plan result.

New evidence is stored atomically with `TrainerProgress`, defaults safely for older profiles and is removed with local learning data. Unit and widget tests cover migration, actual file reopening, duplicate submissions, cross-day recovery, assistance, plan completion and narrow-screen layouts.
