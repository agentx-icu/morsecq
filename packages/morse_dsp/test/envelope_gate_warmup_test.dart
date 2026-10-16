import 'package:morse_dsp/morse_dsp.dart';
import 'package:test/test.dart';

/// 10 ms blocks at 8 kHz: the 12 ms minimum durations take 2 blocks and a
/// 120 ms warm-up takes 12.
EnvelopeGate _gate({Duration warmup = Duration.zero}) => EnvelopeGate(
  sampleRate: 8000,
  blockSize: 80,
  config: EnvelopeGateConfig(noiseWarmup: warmup),
);

const Duration _warmup = Duration(milliseconds: 120);

/// Narrow-band noise around power 1 whose first block happens to be very
/// quiet (block powers of noise are exponentially distributed).
const List<double> _quietFirstNoise = <double>[
  0.002,
  1.0,
  0.6,
  1.8,
  0.9,
  1.3,
  0.5,
  2.2,
  1.1,
  0.7,
  1.6,
  0.8,
  1.2,
  0.6,
  1.9,
  1.0,
  0.7,
  1.4,
  0.9,
  1.1,
  0.6,
  1.7,
  1.0,
  0.8,
];

List<GateTransition> _feedAll(EnvelopeGate gate, Iterable<double> powers) => [
  for (final double p in powers) ...gate.feedAll(p),
];

void main() {
  test('block clock and warm-up length follow the sample rate', () {
    final EnvelopeGate gate = _gate(warmup: _warmup);
    expect(gate.blockDuration, const Duration(milliseconds: 10));
    expect(gate.minOnBlocks, 2);
    expect(gate.warmupBlocks, 12);
    expect(
      gate.latencyBlocks,
      2 + 12,
      reason: 'nothing decided while buffering',
    );
  });

  test('a quiet first noise block opens the default gate on noise only', () {
    // The documented limitation of seeding the floor from block one...
    final List<GateTransition> plain = _feedAll(_gate(), _quietFirstNoise);
    expect(plain.where((t) => t.isOn), isNotEmpty);
    // ...which the warm-up removes: the floor is the stretch's mean.
    final EnvelopeGate warmed = _gate(warmup: _warmup);
    expect(_feedAll(warmed, _quietFirstNoise), isEmpty);
    expect(warmed.isOn, isFalse);
    expect(warmed.hasSignal, isFalse);
    expect(warmed.latencyBlocks, 2, reason: 'the warm-up is over');
  });

  test('a tone starting inside the warm-up keeps its exact onset', () {
    final EnvelopeGate gate = _gate(warmup: _warmup);
    final List<double> powers = <double>[
      1.0, 0.6, 1.4, // noise
      ...List<double>.filled(20, 1000), // steady tone from block 3
      ...List<double>.filled(10, 1.0), // back to noise
    ];
    final List<List<GateTransition>> perBlock = <List<GateTransition>>[
      for (final double p in powers) gate.feedAll(p),
    ];
    for (int i = 0; i < 11; i++) {
      expect(perBlock[i], isEmpty, reason: 'buffered block $i');
    }
    final List<GateTransition> replay = perBlock[11];
    expect(replay, hasLength(1));
    expect(replay.single.isOn, isTrue);
    expect(replay.single.atBlock, 3);
    final GateTransition off = perBlock.expand((t) => t).last;
    expect(off.isOn, isFalse);
    expect(off.atBlock, 23);
    expect(gate.noisePower, lessThan(10), reason: 'floor from quiet blocks');
  });

  test('feed hands out replayed transitions one call at a time', () {
    final EnvelopeGate gate = _gate(warmup: const Duration(milliseconds: 80));
    // Tone, gap and tone again, all inside the 8-block warm-up.
    final List<double> powers = <double>[
      1.0,
      1000,
      1000,
      1000,
      1000,
      1.0,
      1.0,
      1.0,
      1000,
      1000,
      1000,
      1000,
      1000,
    ];
    final List<GateTransition?> out = <GateTransition?>[
      for (final double p in powers) gate.feed(p),
    ];
    final List<GateTransition> got = out.whereType<GateTransition>().toList();
    expect(got.map((t) => (t.isOn, t.atBlock)), <(bool, int)>[
      (true, 1),
      (false, 5),
      (true, 8),
    ]);
    expect(out.take(7), everyElement(isNull), reason: 'nothing before replay');
  });

  test('without a steady run the floor is the mean of the stretch', () {
    final EnvelopeGate gate = _gate(warmup: const Duration(milliseconds: 40));
    _feedAll(gate, <double>[1, 2, 3, 6]);
    // Seeded from the mean (3), then nudged by replaying the four blocks.
    expect(gate.noisePower, closeTo(3, 0.1));
    final EnvelopeGate plain = _gate();
    _feedAll(plain, <double>[1, 2, 3, 6]);
    expect(plain.noisePower, lessThan(2), reason: 'seeded from block one');
  });
}
