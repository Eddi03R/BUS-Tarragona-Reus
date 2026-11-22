import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Gli effetti sonori dei giochi (file in assets/sounds/, generati da
/// tools/gen_sounds.py).
enum Sfx {
  win('win', 1.0, long: true),
  lose('lose', 1.0, long: true),
  draw('draw', 0.9, long: true),
  tap('tap', 0.7),
  step('step', 0.5),
  place('place', 0.9),
  place2('place2', 0.9),
  capture('capture', 1.0),
  correct('correct', 0.9),
  wrong('wrong', 0.8),
  flip('flip', 0.7),
  pop('pop', 0.9),
  clear('clear', 0.9),
  splash('splash', 0.9),
  explosion('explosion', 1.0),
  eat('eat', 0.8),
  flap('flap', 0.7),
  ding('ding', 0.85),
  thud('thud', 1.0),
  flag('flag', 0.8),

  /// Musica di sottofondo (loop) della Corsa del minibus: giorno e notte.
  raceDay('race_day', 0.4, long: true),
  raceNight('race_night', 0.4, long: true);

  final String file;
  final double volume;

  /// Suoni lunghi (fanfara, trombone): player normale invece di quello a bassa latenza.
  final bool long;
  const Sfx(this.file, this.volume, {this.long = false});
}

/// Suoni dei giochi: **spenti di base**, si accendono dall'interruttore
/// nell'elenco giochi o in Impostazioni. Quando sono spenti non si tocca mai
/// il plugin audio. Ogni errore audio viene ignorato: il suono non deve mai
/// rompere un gioco.
class GameSound extends ChangeNotifier {
  GameSound._();
  static final GameSound instance = GameSound._();

  static const _prefKey = 'game_sounds_on';

  bool _enabled = false;
  bool get enabled => _enabled;

  final Map<Sfx, AudioPlayer> _players = {};
  bool _contextSet = false;

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _enabled = prefs.getBool(_prefKey) ?? false;
    } catch (_) {}
    notifyListeners();
  }

  Future<void> setEnabled(bool on) async {
    _enabled = on;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefKey, on);
    } catch (_) {}
    if (on) {
      play(Sfx.correct); // piccolo "ding" di conferma
    } else {
      stopMusic();
    }
  }

  Future<void> toggle() => setEnabled(!_enabled);

  /// Suona [sfx] se i suoni sono accesi; con [delay] parte dopo un po'
  /// (es. il verdetto finale dopo l'esplosione).
  void play(Sfx sfx, {Duration delay = Duration.zero}) {
    if (!_enabled) return;
    if (delay > Duration.zero) {
      Timer(delay, () => _play(sfx));
    } else {
      _play(sfx);
    }
  }

  AudioPlayer? _music;
  Sfx? _wanted; // brano che deve suonare finché non si chiama stopMusic

  /// Musica di sottofondo (solo con i suoni accesi): suona in continuo finché
  /// non si chiama [stopMusic]. Se il loop nativo si ferma, riparte da sola.
  Future<void> playMusic(Sfx track) async {
    if (!_enabled) return;
    _wanted = track;
    try {
      await _setContext();
      var p = _music;
      if (p == null) {
        p = AudioPlayer();
        _music = p;
        await p.setPlayerMode(PlayerMode.mediaPlayer);
        await p.setReleaseMode(ReleaseMode.loop);
        p.onPlayerComplete.listen((_) => _restartMusic());
        p.onPlayerStateChanged.listen((s) {
          if (s == PlayerState.completed) _restartMusic();
        });
      }
      await p.setVolume(track.volume);
      await p.play(AssetSource('sounds/${track.file}.wav'));
    } catch (_) {
      // Nessun audio disponibile: si gioca in silenzio.
    }
  }

  void _restartMusic() {
    final t = _wanted;
    final p = _music;
    if (t == null || p == null || !_enabled) return;
    // con il loop nativo funzionante il player resta "playing": non si fa nulla
    Timer(const Duration(milliseconds: 80), () async {
      try {
        if (_wanted != t || p.state == PlayerState.playing) return;
        await p.play(AssetSource('sounds/${t.file}.wav'));
      } catch (_) {}
    });
  }

  Future<void> stopMusic() async {
    _wanted = null;
    try {
      await _music?.stop();
    } catch (_) {}
  }

  Future<void> _setContext() async {
    if (_contextSet) return;
    _contextSet = true;
    // Effetti e musica si mischiano a quella dell'utente senza fermarla.
    if (!kIsWeb) {
      await AudioPlayer.global.setAudioContext(AudioContextConfig(
        focus: AudioContextConfigFocus.mixWithOthers,
        stayAwake: false,
      ).build());
    }
  }

  Future<void> _play(Sfx sfx) async {
    if (!_enabled) return;
    try {
      await _setContext();
      var p = _players[sfx];
      if (p == null) {
        p = AudioPlayer();
        _players[sfx] = p;
        await p.setPlayerMode(sfx.long ? PlayerMode.mediaPlayer : PlayerMode.lowLatency);
        await p.setReleaseMode(ReleaseMode.stop);
      }
      await p.setVolume(sfx.volume);
      await p.play(AssetSource('sounds/${sfx.file}.wav'));
    } catch (_) {
      // Nessun audio disponibile: si gioca in silenzio.
    }
  }
}
