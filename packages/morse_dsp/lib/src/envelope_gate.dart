import 'dart:math' as math;

/// Tuning parameters for [EnvelopeGate]. All dB values are power dB.
final class EnvelopeGateConfig {
  const EnvelopeGateConfig({
    this.onDropDb = 6,
    this.offDropDb = 12,
    this.noiseMarginDb = 9,
    this.minContrastDb = 12,
    this.peakDecayDbPerSecond = 6,
    this.noiseAttack = 0.05,
    this.noiseRiseDbPerSecond = 2,
    this.noiseOutlierDb = 10,
    this.minOn = const Duration(milliseconds: 12),
    this.minOff = const Duration(milliseconds: 12),
    this.meterRangeDb = 30,
    this.noiseWarmup = const Duration(milliseconds: 50),
  })  : assert(offDropDb > onDropDb, 'offDropDb must exceed onDropDb'),
        assert(noiseAttack > 0 && noiseAttack <= 1, 'noiseAttack in (0, 1]');

  /// Raw "on" when block power exceeds `peak - onDropDb`. 6 dB = a block
  /// that is at least half tone (power grows with duty^2), so mark edges are
  /// placed without bias.
  final double onDropDb;

  /// Raw "off" when block power drops below `peak - offDropDb` (hysteresis).
  final double offDropDb;

  /// Thresholds never sit closer than this to the noise estimate (on), or
  /// 3 dB less (off), so a decayed peak cannot drag them into the noise.
  final double noiseMarginDb;

  /// Gate stays closed until peak exceeds noise by this much. White-noise
  /// maxima hover ~8 dB above the noise mean, so 12 dB rejects pure noise.
  final double minContrastDb;

  /// AGC release: how fast the peak tracker forgets a loud signal.
  final double peakDecayDbPerSecond;

  /// EMA coefficient for the noise estimate on ordinary "off" blocks.
  final double noiseAttack;

  /// Slow creep of the noise estimate towards blocks it cannot trust (tone
  /// blocks and outliers), so a step change in background noise is
  /// eventually adopted instead of latching the gate.
  final double noiseRiseDbPerSecond;

  /// "Off" blocks more than this far above the noise estimate (edge blocks,
  /// clicks) only creep instead of feeding the fast EMA.
  final double noiseOutlierDb;

  /// Shortest tone / silence that is committed; anything briefer is a click
  /// or a dropout and is ignored. Rounded up to whole blocks.
  final Duration minOn;
  final Duration minOff;

  /// Meter scale: dB above the noise estimate that reads as 1.0 when the
  /// signal contrast is smaller than this.
  final double meterRangeDb;

  /// The noise floor is the mean of the blocks in this first stretch and
  /// the gate stays closed meanwhile. One block of white noise in a narrow
  /// bin is exponentially distributed and can sit 10 dB or more below the
  /// mean; seeding the floor from it would open the gate on plain noise.
  final Duration noiseWarmup;
}

/// A committed key state change. [atBlock] is the index (0-based, counting
/// blocks fed) of the first block of the new state, which is earlier than
/// the block during which it was committed.
final class GateTransition {
  const GateTransition({required this.isOn, required this.atBlock});

  final bool isOn;
  final int atBlock;

  @override
  String toString() => 'GateTransition(${isOn ? 'on' : 'off'} @ $atBlock)';
}

/// Turns a sequence of block powers into debounced on/off decisions.
///
/// Pipeline per block: clamp -> peak tracker (fast attack, slow release,
/// the AGC) -> noise tracker (EMA over quiet blocks, slow creep otherwise)
/// -> contrast check -> two-threshold raw decision relative to the peak,
/// floored at `noise + margin` -> minimum-duration debounce. Because the
/// thresholds ride on the tracked peak, a whisper-quiet and a clipping-loud
/// tone gate identically as long as the contrast to the noise floor holds.
final class EnvelopeGate {
  EnvelopeGate({
    required this.sampleRate,
    required this.blockSize,
    this.config = const EnvelopeGateConfig(),
  })  : assert(sampleRate > 0, 'sampleRate must be positive'),
        assert(blockSize > 0, 'blockSize must be positive'),
        minOnBlocks = _blocksFor(config.minOn, blockSize, sampleRate),
        minOffBlocks = _blocksFor(config.minOff, blockSize, sampleRate),
        warmupBlocks = _blocksFor(config.noiseWarmup, blockSize, sampleRate),
        _peakDecay = _perBlock(-config.peakDecayDbPerSecond, blockSize, sampleRate),
        _noiseRise = _perBlock(config.noiseRiseDbPerSecond, blockSize, sampleRate),
        _onFactor = _fromDb(-config.onDropDb),
        _offFactor = _fromDb(-config.offDropDb),
        _noiseOnFactor = _fromDb(config.noiseMarginDb),
        _noiseOffFactor = _fromDb(config.noiseMarginDb - 3),
        _outlierFactor = _fromDb(config.noiseOutlierDb),
        _minContrastRatio = _fromDb(config.minContrastDb);

  /// Power values below this are treated as this (avoids log(0)).
  static const double floorPower = 1e-16;

  final int sampleRate;
  final int blockSize;
  final EnvelopeGateConfig config;

  /// Debounce lengths in blocks (at least 1).
  final int minOnBlocks;
  final int minOffBlocks;

  /// Blocks averaged into the initial noise floor (gate closed meanwhile).
  final int warmupBlocks;
  double _warmupSum = 0;

  final double _peakDecay;
  final double _noiseRise;
  final double _onFactor;
  final double _offFactor;
  final double _noiseOnFactor;
  final double _noiseOffFactor;
  final double _outlierFactor;
  final double _minContrastRatio;

  int _blocks = 0;
  double? _noise;
  double _peak = 0;
  double _lastPower = floorPower;
  bool _rawOn = false;
  bool _committedOn = false;
  int _candidateStart = -1;

  /// Blocks fed so far.
  int get blockCount => _blocks;

  /// Worst-case commit delay in blocks; consumers that time-stamp from the
  /// block clock should hold back their clock by this much.
  int get latencyBlocks => math.max(minOnBlocks, minOffBlocks);

  Duration get blockDuration => Duration(
        microseconds:
            (blockSize * Duration.microsecondsPerSecond / sampleRate).round(),
      );

  /// Committed (debounced) key state.
  bool get isOn => _committedOn;

  /// Current noise-floor and peak estimates (squared amplitude).
  double get noisePower => _noise ?? floorPower;
  double get peakPower => _peak;

  /// Peak over noise, in dB.
  double get contrastDb => _db(_peak / noisePower);

  /// Whether the contrast is high enough for the gate to open at all.
  bool get hasSignal => _peak / noisePower >= _minContrastRatio;

  /// Meter value 0..1: the last block's level above the noise estimate,
  /// scaled by the signal contrast (AGC) or by
  /// [EnvelopeGateConfig.meterRangeDb], whichever is larger.
  double get level {
    if (_noise == null) return 0;
    final double aboveNoise = _db(_lastPower / noisePower);
    final double range = math.max(contrastDb, config.meterRangeDb);
    return (aboveNoise / range).clamp(0.0, 1.0).toDouble();
  }

  /// Feeds one block's tone power (squared amplitude, as produced by
  /// `GoertzelDetector.power`). Returns a transition when the committed
  /// state changes.
  GateTransition? feed(double power) {
    final double p = power > floorPower ? power : floorPower;
    final int index = _blocks++;
    _lastPower = p;

    if (index < warmupBlocks) {
      _warmupSum += p;
      _noise = _warmupSum / (index + 1);
      _peak = math.max(p, _peak * _peakDecay);
      return _debounce(false, index);
    }
    _peak = math.max(p, _peak * _peakDecay);
    final double noise = _noise!;

    bool raw = false;
    if (_peak / noise >= _minContrastRatio) {
      final double onThreshold =
          math.max(_peak * _onFactor, noise * _noiseOnFactor);
      final double offThreshold =
          math.max(_peak * _offFactor, noise * _noiseOffFactor);
      raw = _rawOn ? p > offThreshold : p > onThreshold;
    }
    _rawOn = raw;

    if (!raw && p < noise * _outlierFactor) {
      _noise = noise + (p - noise) * config.noiseAttack;
    } else {
      _noise = math.min(p, noise * _noiseRise);
    }

    return _debounce(raw, index);
  }

  GateTransition? _debounce(bool raw, int index) {
    if (raw == _committedOn) {
      _candidateStart = -1;
      return null;
    }
    if (_candidateStart < 0) _candidateStart = index;
    final int run = index - _candidateStart + 1;
    final int needed = raw ? minOnBlocks : minOffBlocks;
    if (run < needed) return null;
    _committedOn = raw;
    final int at = _candidateStart;
    _candidateStart = -1;
    return GateTransition(isOn: raw, atBlock: at);
  }

  /// Forgets every estimate and the key state; the block counter restarts.
  void reset() {
    _blocks = 0;
    _noise = null;
    _warmupSum = 0;
    _peak = 0;
    _lastPower = floorPower;
    _rawOn = false;
    _committedOn = false;
    _candidateStart = -1;
  }

  static int _blocksFor(Duration d, int blockSize, int sampleRate) {
    final double blockUs = blockSize * Duration.microsecondsPerSecond / sampleRate;
    return math.max(1, (d.inMicroseconds / blockUs).ceil());
  }

  static double _perBlock(double dbPerSecond, int blockSize, int sampleRate) =>
      _fromDb(dbPerSecond * blockSize / sampleRate);

  static double _fromDb(double db) => math.pow(10, db / 10).toDouble();

  static double _db(double ratio) =>
      ratio <= 0 ? -160 : 10 * math.log(ratio) / math.ln10;
}
