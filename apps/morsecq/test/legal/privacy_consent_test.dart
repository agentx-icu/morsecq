import 'package:flutter_test/flutter_test.dart';
import 'package:morsecq/di/privacy_consent.dart';
import 'package:morsecq/i18n/key_value_store.dart';

void main() {
  test('an empty store has not accepted the current policy', () {
    final consent = PrivacyConsent(store: InMemoryKeyValueStore());
    addTearDown(consent.dispose);
    expect(consent.accepted, isFalse);
  });

  test('a stored current version is accepted', () {
    final consent = PrivacyConsent(
      store: InMemoryKeyValueStore({
        PrivacyConsent.storageKey: PrivacyConsent.currentVersion,
      }),
    );
    addTearDown(consent.dispose);
    expect(consent.accepted, isTrue);
  });

  test('a stale stored version re-prompts', () {
    final consent = PrivacyConsent(
      store: InMemoryKeyValueStore({PrivacyConsent.storageKey: '1'}),
    );
    addTearDown(consent.dispose);
    expect(consent.accepted, isFalse);
  });

  test('accept persists the current version and notifies once', () async {
    final store = InMemoryKeyValueStore();
    final consent = PrivacyConsent(store: store);
    addTearDown(consent.dispose);
    var notified = 0;
    consent.addListener(() => notified++);

    await consent.accept();

    expect(consent.accepted, isTrue);
    expect(notified, 1);
    expect(
      store.values[PrivacyConsent.storageKey],
      PrivacyConsent.currentVersion,
    );

    // A second accept is a no-op.
    await consent.accept();
    expect(notified, 1);
  });
}
