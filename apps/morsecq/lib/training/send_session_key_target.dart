import 'package:morse_io/morse_io.dart';
import 'package:morse_session/morse_session.dart';

/// Lets the `morse_io` keyers drive a [SendSession]: the session implements
/// the package-local [SendKeyTarget], this adapter presents it as the
/// keyers' [KeyTarget].
final class SendSessionKeyTarget implements KeyTarget {
  const SendSessionKeyTarget(this.session);

  final SendSession session;

  @override
  void keyDown(Duration at) => session.keyDown(at);

  @override
  void keyUp(Duration at) => session.keyUp(at);
}
