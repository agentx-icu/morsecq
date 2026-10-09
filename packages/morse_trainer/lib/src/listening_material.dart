part of 'listening_comprehension.dart';

List<ListeningExercise> _listeningCandidates(ListeningMode mode) {
  ListeningExercise text(String value) => ListeningExercise(
    mode: mode,
    spokenText: value,
    questions: [ListeningQuestion(field: ListeningField.answer, answer: value)],
  );
  if (mode == ListeningMode.words) {
    return [
      for (final word in const [
        'ME',
        'WE',
        'AM',
        'MOM',
        'TEN',
        'TREE',
        'TIME',
        'RAIN',
        'HOME',
        'NAME',
        'BOOK',
        'ROAD',
        'WIND',
        'RIVER',
        'RADIO',
        'MORNING',
        'SIGNAL',
        'SUN',
        'PARK',
        'WALK',
        'WATER',
        'HELLO',
        'HAPPY',
        'LIGHT',
        'NIGHT',
        'CLEAR',
        'GREEN',
        'SMALL',
        'FRIEND',
        'SUMMER',
        'WINTER',
        'GARDEN',
        'COFFEE',
      ])
        text(word),
    ];
  }
  if (mode == ListeningMode.phrases) {
    // Word families build recognition of recurring parts before sentences.
    return [
      for (final phrase in const [
        'ME TOO',
        'WE MET',
        'TEN MEN',
        'GO HOME',
        'GOOD MORNING',
        'READ A BOOK',
        'THE SKY IS CLEAR',
        'WALK TO THE PARK',
        'MY NAME IS ANNA',
        'THANK YOU',
        'SEE YOU SOON',
        'THE RADIO IS ON',
        'THE RIVER IS WIDE',
        'RAIN IS COMING',
        'PLAY PLAYER PLAYING',
        'HELP HELPER HELPING',
        'WALK WALKER WALKING',
        'READ READER READING',
        'KIND UNKIND KINDNESS',
      ])
        text(phrase),
    ];
  }
  if (mode == ListeningMode.story) {
    const people = ['ANNA', 'TOM', 'MIA', 'SAM'];
    const places = ['PARK', 'RIVER', 'GARDEN', 'HILL'];
    const times = ['NINE', 'TEN', 'NOON', 'SIX'];
    const actions = [
      'READ A BOOK',
      'MEET A FRIEND',
      'TAKE A PHOTO',
      'EAT LUNCH',
    ];
    const numerals = ['9', '10', '12', '6'];
    return [
      for (var i = 0; i < 32; i++)
        ListeningExercise(
          mode: mode,
          spokenText:
              '${people[i % 4]} WALKS TO THE ${places[(i ~/ 4) % 4]} '
              'AT ${times[(i ~/ 2) % 4]} TO ${actions[(i ~/ 8) % 4]} '
              'THE SKY IS CLEAR AND THE AIR IS WARM',
          questions: [
            ListeningQuestion(
              field: ListeningField.person,
              answer: people[i % 4],
            ),
            ListeningQuestion(
              field: ListeningField.destination,
              answer: places[(i ~/ 4) % 4],
              alternatives: ['THE ${places[(i ~/ 4) % 4]}'],
            ),
            ListeningQuestion(
              field: ListeningField.time,
              answer: times[(i ~/ 2) % 4],
              alternatives: [numerals[(i ~/ 2) % 4]],
            ),
            ListeningQuestion(
              field: ListeningField.action,
              answer: actions[(i ~/ 8) % 4],
            ),
          ],
        ),
    ];
  }
  const calls = [
    'K1ABC',
    'W2MOR',
    'G3NET',
    'F4SUN',
    'JA1CW',
    'VK2PAX',
    'VE3RAY',
    'DL1FOX',
  ];
  const names = ['ANNA', 'TOM', 'MIA', 'SAM', 'JANE', 'JOHN', 'SUE', 'PAUL'];
  const towns = [
    'LONDON',
    'TOKYO',
    'PARIS',
    'SYDNEY',
    'BOSTON',
    'OSLO',
    'BERLIN',
    'ROME',
  ];
  const reports = ['599', '579', '559', '589'];
  return [
    for (var i = 0; i < 32; i++)
      if (mode == ListeningMode.qso)
        ListeningExercise(
          mode: mode,
          spokenText:
              'DE ${calls[i % 8]} NAME ${names[(i ~/ 4) % 8]} '
              'QTH ${towns[(i ~/ 2) % 8]} RST ${reports[i % 4]} K',
          questions: [
            ListeningQuestion(
              field: ListeningField.callsign,
              answer: calls[i % 8],
            ),
            ListeningQuestion(
              field: ListeningField.name,
              answer: names[(i ~/ 4) % 8],
            ),
            ListeningQuestion(
              field: ListeningField.qth,
              answer: towns[(i ~/ 2) % 8],
            ),
            ListeningQuestion(
              field: ListeningField.rst,
              answer: reports[i % 4],
            ),
          ],
        )
      else
        ListeningExercise(
          mode: mode,
          spokenText:
              '${calls[i % 8]} DE ${calls[(i + 3) % 8]} '
              'RST ${reports[i % 4]} PARK US ${1200 + i * 7} BK',
          questions: [
            ListeningQuestion(
              field: ListeningField.callsign,
              answer: calls[i % 8],
            ),
            ListeningQuestion(
              field: ListeningField.otherCallsign,
              answer: calls[(i + 3) % 8],
            ),
            ListeningQuestion(
              field: ListeningField.park,
              answer: 'US-${1200 + i * 7}',
            ),
            ListeningQuestion(
              field: ListeningField.rst,
              answer: reports[i % 4],
            ),
          ],
        ),
  ];
}
