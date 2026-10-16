[简体中文](./ADVANCED_LEARNING.zh-CN.md)

# Advanced learning

MorseCQ's advanced learning follows the whole-word recognition, QSO/POTA information extraction, short-story head copy, readable sending and contest exchange directions of the [CW Academy Intermediate Curriculum v2.1](https://cwops.org/wp-content/uploads/2025/06/Practice-Instructions-Intermediate-ver.2.1.htm). Bundled exercise text is original offline content. No course recordings are redistributed, and the app does not claim CW Academy endorsement or certification.

## Mistake notebook

**Learn → Mistake notebook** keeps the original exercise, the first and latest answers, the original character and effective speeds, the channel conditions and the practice dates. Mistakes from copying and from comprehension exercises can both enter the notebook; a comprehension mistake keeps the original audio text and question and is graded on its semantic answer.

A retry starts from the original exercise at the original speed and channel conditions. An entry is recovered only after independent, complete and correct answers on two different days; repeated correct answers on one day count as one day, and replaying or revealing the answer adds no recovery evidence. Another failure clears the earlier recovery evidence. Entries are grouped by exercise and training conditions, the list is bounded, and submission IDs prevent double counting.

## Whole-word and sentence comprehension

**Learn → Head-copy listening** offers words, phrases, QSO details, POTA details and short stories. Answers open only after the whole playback; replaying, revealing the answer and previews containing unlearned symbols are marked as assisted. QSO exercises extract the call, name, location and signal report; POTA exercises extract both calls, the park reference and the signal report; stories ask who, where, when and what.

Comprehension is scored per question and stored in its own records. It is never converted into per-character copy accuracy and does not update the Koch course or the per-symbol spaced review. A mistake retry keeps a snapshot of the original question, so later changes to the exercise bank or to the learned symbols do not change the retry.

## Goal routes

**Learn → Learning goal** offers three routes: first QSO, everyday conversation and head copy, and contest exchanges. Each shows the current evidence, what is missing and direct practice entries. Routes use optional speed stages of 10, 13, 15, 18, 20 and 25 WPM; the first-QSO route ends at 13 WPM, conversation at 20 WPM and contest at 25 WPM.

A milestone needs at least two independent attempts within the last 28 days at 90% accuracy and the required effective speed, plus each skill's minimum sample size. Expired, assisted, future-dated, too-slow or too-small attempts do not count. QSO evidence uses the share of stages answered correctly on the first try, never character echo accuracy in place of protocol skill.

Beginners still follow dit/dah, K/M, guided recognition and the independent character course. After the course is passed, daily plans replace the course part with the chosen goal's comprehension and interactive QSO steps and keep review and sending. Changing goals only reorders steps that have not started; started steps keep their speed, content and score.

## Simulated QSOs

The short exchange, answering a CQ and calling CQ remain; contest exchanges and park-to-park POTA contacts are added. Contest exchanges check the call, RST and serial number; POTA checks both calls, the park reference and RST. The other station may correct information, which must then be confirmed correctly.

AGN asks for a full repeat, QRS for a slower repeat, and a targeted request repeats only a heard CALL, RST, NAME, QTH, NR or PARK field. Repeats never advance a stage and count as assistance. The protocol can be completed with the on-screen key or by typed text; typed replies are recorded as assisted. A draft keeps its scenario, timing snapshot, text and plan step, and can be resumed after the app reopens.

## Storage and verification

Mistakes, comprehension records and the chosen goal are written atomically with `TrainerProgress` in the current local learning profile. Older profiles without these fields load safe defaults; clearing learning data removes them with the profile. Automated tests cover submission IDs, real file reopening, cross-day retries, assistance marking, plan completion and large-text phone layouts. The native `integration_test/advanced_learning_test.dart` additionally checks reopening on a device with timeline-recording test playback, and separately checks that real device audio either completes or blocks answering (see the [test pyramid](../testing/TEST_PYRAMID.md)).
