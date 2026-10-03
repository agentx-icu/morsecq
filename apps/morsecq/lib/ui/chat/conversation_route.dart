import 'dart:async';

import 'package:flutter/material.dart';

import 'conversation_screen.dart';
import 'conversation_target.dart';

/// [RouteSettings.name] of a pushed conversation; its arguments are the
/// conversation id, so code outside the chat UI can tell which one is open.
const String kConversationRouteName = 'conversation';

/// The route every pushed [ConversationScreen] uses.
Route<void> conversationRoute(ConversationTarget target) =>
    MaterialPageRoute<void>(
      settings: RouteSettings(name: kConversationRouteName, arguments: target.id),
      builder: (_) => ConversationScreen(target: target),
    );

/// The route on top of [navigator] (without changing anything).
Route<dynamic>? topRoute(NavigatorState navigator) {
  Route<dynamic>? top;
  navigator.popUntil((route) {
    top = route;
    return true;
  });
  return top;
}

/// Opens [target] from outside the conversation UI (a notification tap):
/// keeps an already open route of the same conversation, replaces another
/// conversation on top, and otherwise pushes above whatever flow is open
/// (training, account pages) instead of tearing it down.
void openConversationRoute(NavigatorState navigator, ConversationTarget target) {
  final RouteSettings? top = topRoute(navigator)?.settings;
  if (top?.name == kConversationRouteName) {
    if (top!.arguments == target.id) return;
    unawaited(navigator.pushReplacement(conversationRoute(target)));
    return;
  }
  unawaited(navigator.push(conversationRoute(target)));
}
