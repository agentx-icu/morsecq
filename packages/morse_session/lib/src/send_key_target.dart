/// Receives timestamped key transitions from whatever drives a send
/// session: the app's on-screen and physical keyers (through its adapter to
/// `morse_io`'s `KeyTarget`) or the mini program's touch key.
abstract interface class SendKeyTarget {
  void keyDown(Duration at);
  void keyUp(Duration at);
}
