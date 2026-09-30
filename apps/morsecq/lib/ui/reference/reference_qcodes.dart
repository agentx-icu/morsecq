/// Q-codes commonly heard on CW, with the meaning in the form that suits
/// both the question (with `?`) and the statement.
abstract final class ReferenceQCodes {
  /// Insertion order is display order: the everyday set first, then the
  /// rest alphabetically.
  static const Map<String, String> meanings = <String, String>{
    'QRL': 'Is the frequency in use? / The frequency is in use.',
    'QRM': 'Interference from other stations (man-made).',
    'QRN': 'Static / atmospheric noise.',
    'QRO': 'Increase power / high power.',
    'QRP': 'Reduce power / low power (5 W or less).',
    'QRQ': 'Send faster.',
    'QRS': 'Send more slowly.',
    'QRT': 'Stop sending / I am closing down.',
    'QRU': 'Have you anything for me? / I have nothing for you.',
    'QRV': 'Are you ready? / I am ready.',
    'QRX': 'Stand by; I will call you again at (time).',
    'QRZ': 'Who is calling me?',
    'QSB': 'Your signal is fading.',
    'QSL': 'Can you acknowledge? / I acknowledge receipt.',
    'QSO': 'A contact; I can communicate with (station).',
    'QSY': 'Change to another frequency.',
    'QTH': 'What is your location? / My location is (place).',
    'QRA': 'The name of my station is (call).',
    'QRG': 'Your exact frequency is (kHz).',
    'QRH': 'Your frequency varies.',
    'QRI': 'The tone of your transmission is (good / variable / bad).',
    'QRK': 'The readability of your signal is (1 to 5).',
    'QSA': 'The strength of your signal is (1 to 5).',
    'QSK': 'I can hear you between my signals; break in on my transmission.',
    'QSP': 'Will you relay to (station)? / I will relay.',
    'QST': 'General call to all amateur stations.',
    'QSV': 'Send a series of Vs for tuning.',
    'QSZ': 'Send each word or group twice.',
    'QTC': 'I have (number) messages for you.',
    'QTR': 'What is the correct time? / The correct time is (UTC).',
  };

  static List<String> get codes => meanings.keys.toList(growable: false);
}
