[简体中文](./ADDING_A_LANGUAGE.zh-CN.md)

# Adding a UI language to morsecq

morsecq ships English (`en`, template) and Simplified Chinese (`zh`) through
Flutter's `gen-l10n`. This page explains how localisation is wired end to end
and gives the exact steps for adding a third language, modelled on how the
sibling project toxee ships `ar` / `en` / `ja` / `ko` / `zh_Hans` / `zh_Hant`
(`/home/user/toxee/l10n.yaml`, `lib/util/locale_controller.dart`,
`test/l10n/arb_completeness_test.dart` there).

For day-to-day string work (adding a key, migrating a `*_strings.dart` const,
ham vocabulary) see [`apps/morsecq/lib/l10n/README.md`](../../apps/morsecq/lib/l10n/README.md).

> **Status note (2026-09-30).** The locale resolution layer
> (`lib/i18n/locale_resolution.dart`), the language catalog
> (`lib/i18n/language_catalog.dart`) and the context-free resolver
> (`lib/i18n/current_strings.dart`, `strings_resolver.dart`) were landed while
> this page was written. Where the text below says "target" it describes the
> agreed design that a piece of code has not fully caught up with yet; each
> such spot is marked.

## 1. How localisation works

### 1.1 gen-l10n and the `S` class

| Piece | Where | Notes |
|---|---|---|
| gen-l10n config | `apps/morsecq/l10n.yaml` | `arb-dir: lib/l10n`, `template-arb-file: app_en.arb`, `output-class: S`, `output-dir: lib/l10n/generated`, `output-localization-file: s.dart`, `nullable-getter: false`, `format: false`. No `synthetic-package` (removed in Flutter 3.41; the key only warns). |
| Auto-generation | `apps/morsecq/pubspec.yaml` → `flutter: generate: true` | `flutter run` / `flutter build` regenerate; `flutter gen-l10n` does it explicitly. |
| ARB files | `apps/morsecq/lib/l10n/app_<tag>.arb` | One per locale. `app_en.arb` is the template and the only file that needs `@key` metadata (description, placeholders). 500 message keys as of 2026-09-30. |
| Generated code | `apps/morsecq/lib/l10n/generated/s.dart`, `s_en.dart`, `s_zh.dart` | Committed, never edited. Exempt from the 500-LOC gate via the `**/l10n/**` pattern. |
| Access | `context.s` (`lib/i18n/l10n_extension.dart`) or `S.of(context)` | Below `MaterialApp` only; tests pump `localizationsDelegates: S.localizationsDelegates`. |
| Supported set | `S.supportedLocales` | Derived from the ARB files. `LocaleController.supportedLocales` and the language picker read it, so **no Dart list has to be edited to add a language**. |

`main.dart` wires:

```dart
MaterialApp(
  onGenerateTitle: (context) => S.of(context).appName,
  localizationsDelegates: S.localizationsDelegates,
  supportedLocales: S.supportedLocales,
  locale: context.watch<LocaleController>().locale,   // null = follow system
  localeResolutionCallback: LocaleController.resolve,
  ...
)
```

### 1.2 `LocaleController`: follow-system or manual override

`lib/i18n/locale_controller.dart` is a `ChangeNotifier` provided by `AppScope`
above `MaterialApp`.

- `locale` is the **override** (`null` = follow the system). The Me page's
  `LanguageSettingsTile` (`lib/i18n/language_settings_tile.dart`) sets it.
- `effectiveLocale` is what the UI renders in right now: the override, or the
  device locale resolved against `S.supportedLocales`.
- Persistence goes through the `KeyValueStore` interface
  (`lib/i18n/key_value_store.dart`). Production uses
  `JsonFileKeyValueStore` on `<application support>/settings.json` (opened in
  `main.dart`; the desktop shell shares the same file through
  `DesktopStoreAdapter`); the fake backend and tests use
  `InMemoryKeyValueStore`. Key: `i18n.locale`; value: a tag produced by
  `localeTag()` — `en`, `zh`, `zh_Hant`, `pt_BR` (script wins over region).
  `parseLocaleTag()` accepts `-`/`_`, any case and legacy `zh_CN`, so an
  existing preference never needs a migration when a language is added.
- A saved tag this build no longer ships falls back to "follow the system".

### 1.3 One resolution rule, used three times

`lib/i18n/locale_resolution.dart::resolveSystemLocale(system, supported)` is
toxee's resolver generalised so that the supported set is data:

1. A language with no ARB → English (`fallback`).
2. Chinese: Traditional when the script is `Hant` **or** the region is
   TW / HK / MO with no script (Android reports `zh-TW` without a script, iOS
   reports `zh-Hant-TW`) — *if* a `zh_Hant` ARB ships; otherwise the
   Simplified file (`zh_Hans` if shipped, else plain `zh`).
3. Any other language: exact script match if shipped, else the language-only
   file.

The same function backs `MaterialApp.localeResolutionCallback`
(`LocaleController.resolve`), `LocaleController.effectiveLocale` and the
context-free `currentLocale()`, so the widget tree, the settings tile and a
notification always agree. `supportedLocaleFor()` is the same rule without the
English fallback (used to validate a user choice).

### 1.4 The language catalog (native names)

`lib/i18n/language_catalog.dart::LanguageCatalog.nativeName(locale)` returns a
language's own name — `English`, `简体中文`, `繁體中文`, `日本語`, `العربية`, …
These are **not** ARB keys: an endonym is the same in every UI language (toxee
whitelists `english` as "legitimately identical to English" for the same
reason). The picker lists `S.supportedLocales` and labels each with the
catalog; only "System default" (`languageSystemDefault`) is a translated ARB
string. Lookup order: full tag → `language_Script` → language → the BCP-47 tag
itself, so an unlisted language still gets *a* label. `LanguageCatalog.isRtl`
is the layout-direction hint for `ar` / `he` / `fa` / `ur`.

The catalog is pre-populated well beyond what ships (≈35 entries) so most
additions need no catalog edit at all.

### 1.5 Strings without a `BuildContext` (notifications, tray)

`lib/i18n/current_strings.dart`:

- `currentS()` — the `S` instance for the current UI language, resolved on
  every call from `LocaleController.active` (set by `AppScope` for the app run,
  `null` in unit tests → platform locale). Same contract as toxee's
  `currentAppL10n()`.
- `lookupSFor(locale)` — `lookupS` that survives a persisted locale this build
  no longer ships (falls back to English instead of throwing in a
  notification path).
- `StringsResolver` (`strings_resolver.dart`) — a `ChangeNotifier` view for
  long-lived services (tray menu, persistent notification) that must relabel
  when the user changes the setting or, while following the system, when the
  OS locale changes (`PlatformDispatcher.onLocaleChanged`).

**Target vs. today:** `lib/notifications/notification_strings.dart` still
holds English `static const` text (Android channel names, "New message",
offline banner) and `main.dart` still uses `AccountStrings.appName` for the
window title. The agreed design is that those callers move to `currentS()` /
`StringsResolver` and the consts are deleted; that swap is tracked in the
"Follow-up" section of `lib/l10n/README.md`. Until it lands, a new language
translates the widgets but not those few OS-facing strings.

### 1.6 What CI checks

| Check | Where | What it guards |
|---|---|---|
| `dart run tool/strings_to_arb.dart --check` | `.github/workflows/analyze.yml` ("Localisation strings in sync") | Every `static const` in `apps/morsecq/lib/ui/**/*_strings.dart` has an ARB key in the template **and** every other `app_*.arb` in the ARB dir (the tool lists `app_*.arb` itself, so a new file is covered automatically). Exit 1 if anything is missing. |
| `test/i18n/arb_consistency_test.dart` | `flutter test apps/morsecq` | Identical key sets, `@@locale` declared, non-empty values, every template placeholder present in the translation, every plural has `other{…}`, `appName` untranslated, one `error*` key per `ChatException` code. **Today it compares `app_en.arb` with `app_zh.arb` only** — see step 6 below. |
| `test/i18n/locale_resolution_test.dart`, `locale_controller_test.dart`, `language_settings_tile_test.dart` | same | Resolution rules, persistence tags, picker behaviour. |
| `flutter analyze apps/morsecq` | CI analyze step | Generated code compiles; strict lints. |

gen-l10n itself **never fails on a missing translation**: it silently compiles
the English template value into any locale that lacks a key. toxee learned
this the hard way (ja/ko shipped ~110 English strings with a green build),
which is why its `arb_completeness_test.dart` exists and why the consistency
test here must cover every shipped ARB.

## 2. Adding a language, step by step

Example: Japanese (`ja`). Replace the tag as needed.

### Step 1 — create the ARB

```bash
cd apps/morsecq/lib/l10n
cp app_en.arb app_ja.arb
```

File name = `app_` + the locale tag gen-l10n expects:
`app_<lang>.arb`, `app_<lang>_<Script>.arb` (`app_zh_Hant.arb`) or
`app_<lang>_<REGION>.arb` (`app_pt_BR.arb`). Set the header to match:

```json
{
  "@@locale": "ja",
  "appName": "morsecq",
  ...
}
```

### Step 2 — translate

- Translate every **value**. Keep every `{placeholder}` exactly as in the
  template (the consistency test checks each one).
- ICU plurals must keep an `other{…}` branch:
  `{count, plural, =1{1 session} other{{count} sessions}}`. Languages without
  plural forms (ja, zh, ko) usually collapse to
  `{count, plural, other{{count} 回}}` — keep any `=0` special case the
  template has.
- Leave `appName` as `morsecq` (product name, tested to be identical).
- The `@key` metadata blocks are optional outside the template; keeping them
  is harmless, deleting them keeps the file short. The migration tool marks
  untranslated entries it adds with `"description": "@@TODO(l10n): …"`;
  `grep -n '@@TODO' apps/morsecq/lib/l10n/app_ja.arb` lists open work.
- Reuse the ham/Morse vocabulary consistently within the language (the zh
  glossary in `lib/l10n/README.md` is the model: dit/dah, character speed,
  Farnsworth spacing, sidetone, straight key, paddles, callsign, copy, send).

### Step 3 — display name in the language catalog

Open `apps/morsecq/lib/i18n/language_catalog.dart`. If your tag (or its
language code) is already in `LanguageCatalog._names`, nothing to do — `ja` →
`日本語` is there. Otherwise add one line with the **endonym** (the name in that
language, never translated):

```dart
'cy': 'Cymraeg',
```

For a right-to-left language add its code to the set in `isRtl`. Without a
catalog entry the picker still works but shows the raw tag (`cy`).

### Step 4 — generate

```bash
cd apps/morsecq
flutter gen-l10n          # writes lib/l10n/generated/s_ja.dart, updates s.dart
```

`S.supportedLocales` now contains `Locale('ja')`; the delegate's
`isSupported`, the picker and the resolver pick it up with no further edits.
Commit the regenerated files.

### Step 5 — verify

```bash
# repo root
dart run tool/strings_to_arb.dart --check     # every *_strings.dart const present in app_ja.arb
flutter analyze apps/morsecq
cd apps/morsecq && flutter test test/i18n
```

Then run the app (`MORSECQ_FAKE_BACKEND=1` is enough), open **Me → Language**,
pick 日本語, and confirm the shell relabels immediately. Switch back to
"System default" and set the device language to Japanese to exercise the
resolver path.

### Step 6 — extend the consistency test (target)

`test/i18n/arb_consistency_test.dart` currently reads exactly `app_en.arb`
and `app_zh.arb`. The target shape (and what to do when you add the third
file) is toxee's `_completeLocales` pattern: iterate every `app_*.arb` in
`lib/l10n/`, and for each non-template file assert the same key set,
placeholders and `other{}` branches against the template. Do this in the same
change as the new ARB so the "silent English fallback" failure mode described
in §1.6 cannot recur.

### Step 7 — platform manifests

- **iOS / macOS**: Flutter reads the device locale from `NSLocale`, but iOS
  only offers a per-app language switch in Settings when
  `CFBundleLocalizations` lists the languages. toxee declares
  `en`, `zh-Hans`, `zh-Hant` in `ios/Runner/Info.plist`; morsecq's
  `apps/morsecq/ios/Runner/Info.plist` has no such array yet — add one with
  every shipped tag (BCP-47 form: `ja`, `zh-Hans`, `zh-Hant`) when you add a
  language. Same for `macos/Runner/Info.plist`.
- **Android**: nothing required. If you later use `resourceConfigurations` /
  `resConfigs` to shrink the APK, keep the new language in the list.
- **Windows / Linux**: nothing; the locale comes from the OS user profile.

## 3. Script and region variants (zh_Hant, pt_BR, …)

Follow toxee's precedent but keep it minimal:

- **Traditional Chinese.** Add `app_zh_Hant.arb` (`"@@locale": "zh_Hant"`) as
  a *complete* file — do not rely on gen-l10n falling back to `zh`, which
  would show Simplified text for any key you forget. Keep `app_zh.arb` as the
  Simplified file; there is no need for a separate `app_zh_Hans.arb` (toxee
  has one only as an override layer, and its completeness test deliberately
  excludes it because gen-l10n resolves it through `zh`). The resolver then
  routes `zh-Hant-*`, `zh-TW`, `zh-HK`, `zh-MO` to `zh_Hant` and everything
  else Chinese to `zh` — no code change. `LanguageCatalog` already labels
  `zh_Hant` as `繁體中文`. gen-l10n emits the variant as a subclass
  (`SZhHant` inside `s_zh.dart`), which is why a script file may contain only
  the keys that differ — but for the reason above, ship it complete anyway.
  Write it as Taiwan Mandarin, not Cantonese colloquial (toxee's test rejects
  `咗嘅唔喺哋嚟冇揀`).
- **Region variants** (`app_pt_BR.arb`, `app_en_GB.arb`): gen-l10n requires
  the plain language file (`app_pt.arb`) to exist as the parent. The resolver
  picks the exact script match first, then the language-only file; for a
  region-only variant, rule 3 lands on the parent unless you extend
  `resolveSystemLocale` with a region preference (as it does for Chinese).
  Persisted tags for region variants are `pt_BR` (`localeTag`: region only
  when there is no script).
- **RTL** (`ar`, `he`): Flutter flips `Directionality` from the locale
  automatically; use `LanguageCatalog.isRtl` only where a widget needs the hint
  outside the tree (tray menus, notification layout).

## 4. Checklist

- [ ] `apps/morsecq/lib/l10n/app_<tag>.arb` with `@@locale`, complete, placeholders and `other{}` intact, `appName` unchanged
- [ ] Endonym present in `LanguageCatalog._names` (and `isRtl` if applicable)
- [ ] `flutter gen-l10n` run; `lib/l10n/generated/` committed
- [ ] `dart run tool/strings_to_arb.dart --check` green
- [ ] `test/i18n/arb_consistency_test.dart` covers the new file (extend it if it still hard-codes `en`/`zh`)
- [ ] `flutter analyze apps/morsecq` and `flutter test apps/morsecq` green
- [ ] `CFBundleLocalizations` updated in the iOS and macOS `Info.plist`
- [ ] Manual check: Me → Language switch, and system-follow with the device set to the new language
- [ ] Mobile parity: everything above is shared Dart; the only platform-specific step is the plist entry
