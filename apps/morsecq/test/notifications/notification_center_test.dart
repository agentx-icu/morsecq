import 'dart:async';
import 'dart:ui' show Locale;

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:morsecq/l10n/generated/s.dart';
import 'package:morsecq/notifications/notifications.dart';
import 'package:morsecq/notifications/testing/fake_badge_api.dart';
import 'package:morsecq/notifications/testing/fake_local_notifications_api.dart';
import 'package:morsecq_chat_api/morsecq_chat_api.dart';
import 'package:morsecq_chat_api/testing.dart';

final String kAnn = 'A' * 64;
final String kAnnConv = 'c2c_$kAnn';
final String kBob = 'C' * 64;
final String kBobConv = 'c2c_$kBob';
const String kAnnPattern = '-.-. --.- / -.-. --.- / -.. . / .- -. -.';

/// English strings, the language every assertion below is written against
/// unless the harness is given another resolver.
final S en = lookupS(const Locale('en'));
final S zh = lookupS(const Locale('zh'));

/// Everything a NotificationCenter test needs, wired the way the
/// orchestrator will: fake backend, recording plugin fakes, prefs, a
/// foreground flag the test flips by hand and a strings resolver (English
/// by default, pinned rather than following the test host's locale).
final class Harness {
  Harness({
    NotificationPlatform platform = NotificationPlatform.android,
    bool foreground = false,
    bool badgeSupported = true,
    S Function()? strings,
  }) : chat = FakeChatService(
         selfPublicKey: 'F' * 64,
         clock: () => DateTime(2026, 9, 30, 12),
       ),
       api = FakeLocalNotificationsApi(),
       badge = FakeBadgeApi(supported: badgeSupported),
       prefs = NotificationPrefs(),
       foreground = ValueNotifier<bool>(foreground) {
    center = NotificationCenter(
      chat: chat,
      notifications: api,
      badge: badge,
      prefs: prefs,
      isForeground: this.foreground,
      platform: platform,
      strings: strings ?? () => en,
    );
  }

  final FakeChatService chat;
  final FakeLocalNotificationsApi api;
  final FakeBadgeApi badge;
  final NotificationPrefs prefs;
  final ValueNotifier<bool> foreground;
  late final NotificationCenter center;

  /// Adds Ann as a friend and starts the center.
  Future<void> start() async {
    chat.addFakeFriend(Friend(publicKey: kAnn, displayName: 'Ann'));
    await center.start();
    await pumpEventQueue();
  }

  Future<void> receive(String text, {String? conversationId}) async {
    chat.receiveMessage(conversationId ?? kAnnConv, text);
    await pumpEventQueue();
  }

  Future<void> dispose() async {
    await center.dispose();
    await chat.dispose();
    prefs.dispose();
    foreground.dispose();
  }
}

Future<Harness> harness({
  NotificationPlatform platform = NotificationPlatform.android,
  bool foreground = false,
  bool badgeSupported = true,
  S Function()? strings,
}) async {
  final Harness h = Harness(
    platform: platform,
    foreground: foreground,
    badgeSupported: badgeSupported,
    strings: strings,
  );
  addTearDown(h.dispose);
  await h.start();
  return h;
}

void main() {
  group('inbound messages', () {
    test('in the background posts title, text and Morse pattern', () async {
      final Harness h = await harness();
      await h.receive('CQ CQ DE ANN');

      expect(h.api.shown, hasLength(1));
      final NotificationRequest n = h.api.shown.single;
      expect(n.title, 'Ann');
      expect(n.body, contains('CQ CQ DE ANN'));
      expect(n.body, contains(kAnnPattern));
      expect(n.channel, NotificationChannelKind.messages);
      expect(n.payload, OpenConversationTarget(kAnnConv).encode());
      expect(n.groupKey, 'morsecq.messages.$kAnnConv');
      expect(n.sound, isTrue);
      expect(n.id, stableNotificationId(n.payload));
    });

    test('foreground with the conversation open: no notification', () async {
      final Harness h = await harness(foreground: true);
      h.center.setActiveConversation(kAnnConv);
      await h.receive('CQ');
      expect(h.api.shown, isEmpty);

      // Leaving the conversation re-arms it.
      h.center.setActiveConversation(null);
      await h.receive('CQ');
      expect(h.api.shown, hasLength(1));
    });

    test(
      'foreground with a different conversation open still notifies',
      () async {
        final Harness h = await harness(foreground: true);
        h.center.setActiveConversation(kBobConv);
        await h.receive('CQ');
        expect(h.api.shown, hasLength(1));
      },
    );

    test('background with the conversation "open" still notifies', () async {
      // The screen may still be mounted while the app is paused; the user
      // cannot see it, so the OS banner is the only way to reach them.
      final Harness h = await harness(foreground: false);
      h.center.setActiveConversation(kAnnConv);
      await h.receive('CQ');
      expect(h.api.shown, hasLength(1));
    });

    test('muted conversation never notifies', () async {
      final Harness h = await harness();
      h.prefs.setMuted(kAnnConv, true);
      await h.receive('CQ');
      expect(h.api.shown, isEmpty);

      h.prefs.setMuted(kAnnConv, false);
      await h.receive('CQ');
      expect(h.api.shown, hasLength(1));
    });

    test('disabled prefs suppress everything but the badge', () async {
      final Harness h = await harness();
      h.prefs.enabled = false;
      await h.receive('CQ');
      expect(h.api.shown, isEmpty);
      expect(h.badge.current, 1);
    });

    test('own messages and status updates never notify', () async {
      final Harness h = await harness();
      final ChatMessage sent = await h.chat.sendText(kAnnConv, 'K');
      expect(sent.status, MessageStatus.pending);
      h.chat.setFriendOnline(kAnn, true); // pending -> sent event
      await pumpEventQueue();
      expect(h.api.shown, isEmpty);
    });

    test('a burst becomes one notification with inbox lines', () async {
      final Harness h = await harness();
      await h.receive('CQ');
      await h.receive('K');
      expect(h.api.shown, hasLength(2));
      expect(h.api.active, hasLength(1)); // same id, replaced in place
      final NotificationRequest n = h.api.last!;
      expect(n.lines, hasLength(2));
      expect(n.lines.first, contains('CQ'));
      expect(n.lines.last, contains('K'));
      expect(n.summary, en.notificationNewMessages(2));
      expect(n.summary, '2 new messages');
    });

    test('inbox keeps only the newest five lines', () async {
      final Harness h = await harness();
      for (var i = 1; i <= 7; i++) {
        await h.receive('M$i');
      }
      final NotificationRequest n = h.api.last!;
      expect(n.lines, hasLength(NotificationComposer.maxInboxLines));
      expect(n.lines.first, contains('M3'));
      expect(n.lines.last, contains('M7'));
    });

    test('group message: title is the group, sender prefixed', () async {
      final Harness h = await harness();
      final Group g = h.chat.addFakeGroup(
        const Group(id: 'tox_1', name: 'Net', kind: GroupKind.group),
      );
      h.chat.receiveMessage(
        FakeChatService.groupConversationId(g.id),
        'QRL?',
        senderId: kBob,
        senderName: 'Bob',
      );
      await pumpEventQueue();
      final NotificationRequest n = h.api.shown.single;
      expect(n.title, 'Net');
      expect(n.body, startsWith('Bob: '));
      expect(n.body, contains('--.- .-. .-.. ..--..'));
      expect(n.lines, isEmpty); // single message: no inbox yet
    });

    test(
      'group message from a nameless peer falls back to the short key',
      () async {
        final Harness h = await harness();
        final Group g = h.chat.addFakeGroup(
          const Group(id: 'tox_1', name: 'Net', kind: GroupKind.group),
        );
        h.chat.receiveMessage(
          FakeChatService.groupConversationId(g.id),
          'K',
          senderId: kBob,
        );
        await pumpEventQueue();
        expect(h.api.shown.single.body, startsWith('${'C' * 8}: '));
      },
    );

    test('no grouping keys on Linux / Windows', () async {
      final Harness h = await harness(platform: NotificationPlatform.linux);
      await h.receive('CQ');
      expect(h.api.shown.single.groupKey, isNull);
    });

    test('unsupported platform: nothing is posted, badge untouched', () async {
      final Harness h = await harness(
        platform: NotificationPlatform.unsupported,
      );
      await h.receive('CQ');
      expect(h.api.initialized, isFalse);
      expect(h.api.shown, isEmpty);
      expect(h.badge.writes, isEmpty);
    });
  });

  group('prefs shape the body', () {
    test('pattern only', () async {
      final Harness h = await harness();
      h.prefs.showText = false;
      await h.receive('CQ CQ DE ANN');
      expect(h.api.shown.single.body, kAnnPattern);
    });

    test('text only', () async {
      final Harness h = await harness();
      h.prefs.showPattern = false;
      await h.receive('CQ CQ DE ANN');
      expect(h.api.shown.single.body, 'CQ CQ DE ANN');
    });

    test('neither: neutral body, and sound follows prefs', () async {
      final Harness h = await harness();
      h.prefs
        ..showText = false
        ..showPattern = false
        ..sound = false;
      await h.receive('CQ');
      expect(h.api.shown.single.body, en.notificationNewMessage);
      expect(h.api.shown.single.body, 'New message');
      expect(h.api.shown.single.sound, isFalse);
    });
  });

  group('language', () {
    test('bodies and titles follow the strings resolver (zh)', () async {
      final Harness h = await harness(strings: () => zh);
      h.prefs
        ..showText = false
        ..showPattern = false;
      await h.receive('CQ');
      expect(h.api.shown.single.body, zh.notificationNewMessage);
      expect(h.api.shown.single.body, '新消息');

      h.chat.receiveFriendRequest(kBob, message: '');
      await pumpEventQueue();
      final NotificationRequest fr = h.api.shown.last;
      expect(fr.title, zh.notificationFriendRequestTitle);
      expect(fr.title, '新的好友请求');
      expect(fr.body, zh.notificationFriendRequestFrom('C' * 8));
      expect(fr.body, contains('好友请求'));
    });

    test('a language switch applies to the next notification', () async {
      S current = en;
      final Harness h = await harness(strings: () => current);
      h.prefs
        ..showText = false
        ..showPattern = false;
      await h.receive('CQ');
      expect(h.api.shown.last.body, 'New message');

      current = zh;
      await h.receive('K');
      expect(h.api.shown.last.body, '新消息');
      // The grouped summary is rendered in the new language too.
      expect(h.api.shown.last.summary, zh.notificationNewMessages(2));
    });
  });

  group('badge', () {
    test('follows the total unread across conversations', () async {
      final Harness h = await harness();
      expect(h.badge.current, 0); // replayed conversation list at start
      await h.receive('CQ');
      await h.receive('K');
      h.chat.addFakeFriend(Friend(publicKey: kBob, displayName: 'Bob'));
      await h.receive('CQ', conversationId: kBobConv);
      expect(h.badge.current, 3);

      await h.chat.markRead(kAnnConv);
      await pumpEventQueue();
      expect(h.badge.current, 1);
      // Reading Ann's conversation also took its banner down.
      expect(h.api.cancelled, contains(h.api.shown.first.id));
    });

    test('never writes the same total twice', () async {
      final Harness h = await harness();
      await h.receive('CQ');
      await h.chat.setPinned(
        kAnnConv,
        true,
      ); // conversation change, same unread
      await pumpEventQueue();
      expect(h.badge.writes, <int>[0, 1]);
    });

    test('unsupported launcher: probed once, never written', () async {
      final Harness h = await harness(badgeSupported: false);
      await h.receive('CQ');
      await h.receive('K');
      expect(h.badge.supportChecks, 1);
      expect(h.badge.writes, isEmpty);
    });

    test('platform without a badge never probes the plugin', () async {
      final Harness h = await harness(platform: NotificationPlatform.windows);
      await h.receive('CQ');
      expect(h.badge.supportChecks, 0);
    });
  });

  group('active conversation', () {
    test(
      'opening a conversation in the foreground dismisses its banner',
      () async {
        final Harness h = await harness();
        await h.receive('CQ');
        expect(h.api.active, hasLength(1));

        h.foreground.value = true;
        h.center.setActiveConversation(kAnnConv);
        await pumpEventQueue();
        expect(h.api.active, isEmpty);
      },
    );

    test(
      'returning to the foreground on an open conversation dismisses it',
      () async {
        final Harness h = await harness();
        h.center.setActiveConversation(kAnnConv);
        await h.receive('CQ');
        expect(h.api.active, hasLength(1));

        h.foreground.value = true;
        await pumpEventQueue();
        expect(h.api.active, isEmpty);
      },
    );
  });

  group('a post overtaken by the user reading the conversation', () {
    test('android: resumed and read while the permission check runs', () async {
      final Harness h = await harness();
      final Completer<bool> check = Completer<bool>();
      h.api.permissionCheckAnswer = check.future;
      // The screen stays mounted while the app is paused.
      h.center.setActiveConversation(kAnnConv);
      await h.receive('CQ');
      expect(h.api.shown, isEmpty);

      h.foreground.value = true; // resume: the banner is cancelled
      await h.chat.markRead(kAnnConv);
      await pumpEventQueue();
      check.complete(true);
      await pumpEventQueue();
      expect(h.api.shown, isEmpty);
      expect(h.api.active, isEmpty);

      // Not over-suppressed: the next message in the background notifies.
      h.foreground.value = false;
      await h.receive('K');
      expect(h.api.shown, hasLength(1));
    });

    test(
      'foreground: opened and read while the permission check runs',
      () async {
        final Harness h = await harness(foreground: true);
        final Completer<bool> check = Completer<bool>();
        h.api.permissionCheckAnswer = check.future;
        await h.receive('CQ');
        expect(h.api.shown, isEmpty);

        h.center.setActiveConversation(kAnnConv);
        await h.chat.markRead(kAnnConv);
        await pumpEventQueue();
        check.complete(true);
        await pumpEventQueue();
        expect(h.api.shown, isEmpty);
        expect(h.api.active, isEmpty);
      },
    );

    test(
      'a delayed post read meanwhile never replaces a newer banner',
      () async {
        final Harness h = await harness();
        final Completer<bool> check = Completer<bool>();
        h.api.permissionCheckAnswer = check.future;
        await h.receive('M1');
        await h.chat.markRead(kAnnConv);
        await pumpEventQueue();
        await h.receive('M2'); // unread is above 0 again
        check.complete(true);
        await pumpEventQueue();
        expect(h.api.shown, hasLength(1));
        expect(h.api.shown.single.body, contains('M2'));
        expect(h.api.shown.single.body, isNot(contains('M1')));
      },
    );

    test('Linux: a listener opens and reads it during delivery', () async {
      final Harness h = await harness(
        platform: NotificationPlatform.linux,
        foreground: true,
      );
      // Subscribed after the center, like the conversation screen.
      final StreamSubscription<ChatMessage> sub = h.chat.messageEvents.listen((
        ChatMessage m,
      ) {
        h.center.setActiveConversation(m.conversationId);
        unawaited(h.chat.markRead(m.conversationId));
      });
      addTearDown(sub.cancel);
      await h.receive('CQ');
      expect(h.api.active, isEmpty);
      expect(h.api.shown, isEmpty);
    });
  });

  group('friend requests and group invites', () {
    test('a new friend request notifies on its own channel', () async {
      final Harness h = await harness();
      h.chat.receiveFriendRequest(kBob, message: 'CQ CQ');
      await pumpEventQueue();
      final NotificationRequest n = h.api.shown.single;
      expect(n.channel, NotificationChannelKind.friendRequests);
      expect(n.title, en.notificationFriendRequestTitle);
      expect(n.title, 'New friend request');
      expect(n.body, en.notificationFriendRequestBody('C' * 8, 'CQ CQ'));
      expect(n.body, '${'C' * 8}: CQ CQ');
      expect(n.payload, FriendRequestTarget(kBob).encode());

      await h.chat.acceptFriendRequest(kBob);
      await pumpEventQueue();
      expect(h.api.active, isEmpty); // banner taken down once answered
    });

    test('requests pending at start are not re-announced', () async {
      final Harness h = Harness();
      addTearDown(h.dispose);
      h.chat.receiveFriendRequest(kBob);
      await h.start();
      expect(h.api.shown, isEmpty);
    });

    test('a friend request without a message names the requester', () async {
      final Harness h = await harness();
      h.chat.receiveFriendRequest(kBob, message: '');
      await pumpEventQueue();
      expect(
        h.api.shown.single.body,
        en.notificationFriendRequestFrom('C' * 8),
      );
      expect(h.api.shown.single.body, 'Friend request from ${'C' * 8}');
    });

    test('a group invite notifies with the group name', () async {
      final Harness h = await harness();
      final GroupInvite invite = h.chat.receiveGroupInvite(
        fromPublicKey: kAnn,
        groupName: 'Net',
      );
      await pumpEventQueue();
      final NotificationRequest n = h.api.shown.single;
      expect(n.channel, NotificationChannelKind.groupInvites);
      expect(n.title, en.notificationGroupInviteTitle('Net'));
      expect(n.title, 'Invite to Net');
      expect(n.body, en.notificationGroupInviteBody('Ann'));
      expect(n.body, 'Ann invited you');
      expect(n.payload, GroupInviteTarget(invite.inviteId).encode());
    });
  });

  group('taps', () {
    test(
      'tapping a message notification asks to open the conversation',
      () async {
        final Harness h = await harness();
        final Future<String> opened = h.center.openConversationRequests.first;
        final Future<NotificationTapTarget> tapped = h.center.tapTargets.first;
        h.api.tapTarget(OpenConversationTarget(kAnnConv));
        expect(await opened, kAnnConv);
        expect(await tapped, OpenConversationTarget(kAnnConv));
      },
    );

    test('friend-request taps reach tapTargets only', () async {
      final Harness h = await harness();
      final List<String> opened = <String>[];
      final List<NotificationTapTarget> targets = <NotificationTapTarget>[];
      h.center.openConversationRequests.listen(opened.add);
      h.center.tapTargets.listen(targets.add);
      h.api.tapTarget(FriendRequestTarget(kBob));
      h.api.tap('garbage');
      await pumpEventQueue();
      expect(opened, isEmpty);
      expect(targets, <NotificationTapTarget>[FriendRequestTarget(kBob)]);
    });

    test('a cold-start tap waits for the shell to subscribe', () async {
      // start() reads the launch payload while the startup gate (unlock /
      // open) still hides the AppShell that listens: it must not be lost.
      final Harness h = Harness();
      addTearDown(h.dispose);
      h.api.launchPayload = OpenConversationTarget(kAnnConv).encode();
      await h.start();

      final List<String> opened = <String>[];
      final List<NotificationTapTarget> targets = <NotificationTapTarget>[];
      h.center.tapTargets.listen(targets.add);
      h.center.openConversationRequests.listen(opened.add);
      await pumpEventQueue();
      expect(opened, <String>[kAnnConv]);
      expect(targets, <NotificationTapTarget>[
        OpenConversationTarget(kAnnConv),
      ]);

      // Delivered once: a later subscriber (the shell rebuilt after a
      // lock/unlock) does not reopen it.
      final List<String> late = <String>[];
      h.center.openConversationRequests.listen(late.add);
      await pumpEventQueue();
      expect(late, isEmpty);
    });

    test('only the latest unheard tap is kept', () async {
      final Harness h = await harness();
      h.api.tapTarget(OpenConversationTarget(kBobConv));
      h.api.tapTarget(OpenConversationTarget(kAnnConv));
      final List<String> opened = <String>[];
      h.center.openConversationRequests.listen(opened.add);
      await pumpEventQueue();
      expect(opened, <String>[kAnnConv]);
    });

    test('the latest unheard tap wins across both streams', () async {
      final Harness h = await harness();
      h.api.tapTarget(OpenConversationTarget(kAnnConv));
      h.api.tapTarget(const GroupInviteTarget('invite-1'));
      final List<String> opened = <String>[];
      final List<NotificationTapTarget> targets = <NotificationTapTarget>[];
      h.center.openConversationRequests.listen(opened.add);
      h.center.tapTargets.listen(targets.add);
      await pumpEventQueue();
      expect(opened, isEmpty);
      expect(targets, <NotificationTapTarget>[
        const GroupInviteTarget('invite-1'),
      ]);
    });

    test('a cold-start payload is replayed on start', () async {
      final Harness h = Harness();
      addTearDown(h.dispose);
      h.api.launchPayload = OpenConversationTarget(kAnnConv).encode();
      final List<String> opened = <String>[];
      h.center.openConversationRequests.listen(opened.add);
      await h.start();
      expect(opened, <String>[kAnnConv]);
    });
  });

  group('dispose', () {
    test(
      'releases every subscription and stream before its first await',
      () async {
        final Harness h = await harness();
        await h.receive('CQ');
        expect(h.api.shown, hasLength(1));

        // Deliberately NOT awaited yet: AppScope.dispose() cannot wait either,
        // and a cancelled broadcast subscription may resume in the root zone.
        final Future<void> done = h.center.dispose();

        // Subscriptions were cancelled synchronously: nothing else is posted.
        await h.receive('CQ DE BOB');
        expect(h.api.shown, hasLength(1));
        // Both outbound controllers were closed synchronously.
        expect(await h.center.tapTargets.isEmpty, isTrue);
        expect(await h.center.openConversationRequests.isEmpty, isTrue);
        await done;
        await h.center.dispose(); // idempotent
      },
    );
  });

  group('permission', () {
    test(
      'a background post never prompts; the prompt waits for foreground',
      () async {
        // Android 13+ cannot show the permission dialog from a stopped
        // activity (the request comes back as "denied"), iOS queues it out of
        // context. The post is dropped and the user is asked once they return.
        final Harness h = await harness();
        h.api.permissionGranted = false;
        await h.receive('CQ');
        expect(h.api.shown, isEmpty);
        expect(h.api.permissionRequests, 0);
        expect(h.api.permissionChecks, 1);

        h.api.grantOnRequest = true;
        h.foreground.value = true;
        await pumpEventQueue();
        expect(h.api.permissionRequests, 1);

        h.foreground.value = false;
        await h.receive('K');
        expect(h.api.shown, hasLength(1));
        expect(h.api.permissionRequests, 1);
      },
    );

    test(
      'a grant from an earlier run posts from the background silently',
      () async {
        final Harness h = await harness();
        await h.receive('CQ');
        await h.receive('K');
        expect(h.api.shown, hasLength(2));
        expect(h.api.permissionRequests, 0);
        // The grant is cached after the first check.
        expect(h.api.permissionChecks, 1);
        expect(await h.center.ensurePermission(), isTrue);
        expect(h.api.permissionRequests, 0);
      },
    );

    test(
      'in the foreground posting prompts once per session, not per message',
      () async {
        final Harness h = await harness(foreground: true);
        h.api
          ..permissionGranted = false
          ..grantOnRequest = false;
        // Two at once share the one prompt; later ones never re-prompt.
        h.chat.receiveMessage(kAnnConv, 'CQ');
        h.chat.receiveMessage(kAnnConv, 'CQ CQ');
        await pumpEventQueue();
        await h.receive('K');
        expect(h.api.permissionRequests, 1);
        expect(h.api.shown, isEmpty);

        // A denial is not cached: enabling it in Settings is picked up.
        h.api.permissionGranted = true;
        await h.receive('73');
        expect(h.api.shown, hasLength(1));
        expect(h.api.permissionRequests, 1);
      },
    );

    test(
      'posts that arrive while the prompt is open wait for its answer',
      () async {
        final Harness h = await harness(foreground: true);
        h.chat.addFakeFriend(Friend(publicKey: kBob, displayName: 'Bob'));
        final Completer<bool> answer = Completer<bool>();
        h.api
          ..permissionGranted = false
          ..promptAnswer = answer.future;
        await h.receive('CQ');
        await h.receive('DE BOB', conversationId: kBobConv);
        expect(h.api.permissionRequests, 1);
        expect(h.api.shown, isEmpty);

        answer.complete(true);
        await pumpEventQueue();
        expect(h.api.shown, hasLength(2));
        expect(h.api.permissionRequests, 1);
      },
    );

    test(
      'ensurePermission prompts on demand even after the session prompt',
      () async {
        final Harness h = await harness(foreground: true);
        h.api
          ..permissionGranted = false
          ..grantOnRequest = false;
        await h.receive('CQ');
        expect(h.api.permissionRequests, 1);
        expect(await h.center.ensurePermission(), isFalse);
        expect(h.api.permissionRequests, 2);
      },
    );

    test('Linux needs no permission and never asks', () async {
      final Harness h = await harness(platform: NotificationPlatform.linux);
      expect(await h.center.ensurePermission(), isTrue);
      await h.receive('CQ');
      expect(h.api.permissionRequests, 0);
      expect(h.api.shown, hasLength(1));
    });
  });

  group('refreshStrings', () {
    test('forwards a language change to the plugin once ready', () async {
      final Harness h = Harness();
      await h.start();
      await h.center.refreshStrings();
      expect(h.api.refreshStringsCalls, 1);
    });

    test('forwarded before start (the API defers it), not after dispose or '
        'on a platform without OS notifications', () async {
      final Harness h = Harness();
      await h.center.refreshStrings();
      expect(h.api.refreshStringsCalls, 1);
      await h.center.dispose();
      await h.center.refreshStrings();
      expect(h.api.refreshStringsCalls, 1);

      final Harness none = Harness(platform: NotificationPlatform.unsupported);
      await none.start();
      await none.center.refreshStrings();
      expect(none.api.refreshStringsCalls, 0);
    });
  });
}
