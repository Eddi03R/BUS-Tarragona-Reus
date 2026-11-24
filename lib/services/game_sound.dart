import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' show AppLifecycleState, WidgetsBinding, WidgetsBindingObserver;
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
  raceNight('race_night', 0.4, long: true),

  /// Canzoncine di sottofondo dei giochi (tools/gen_music.py), una per gioco.
  musicBusjam('music_busjam', 0.22, ext: 'mp3', long: true),
  musicSudoku('music_sudoku', 0.22, ext: 'mp3', long: true),
  musicMaze('music_maze', 0.22, ext: 'mp3', long: true),
  musicBattleship('music_battleship', 0.22, ext: 'mp3', long: true),
  musicTictactoe('music_tictactoe', 0.22, ext: 'mp3', long: true),
  musicBlocks('music_blocks', 0.22, ext: 'mp3', long: true),
  musicG2048('music_g2048', 0.22, ext: 'mp3', long: true),
  musicMemory('music_memory', 0.22, ext: 'mp3', long: true),
  musicWordle('music_wordle', 0.22, ext: 'mp3', long: true),
  musicFlow('music_flow', 0.22, ext: 'mp3', long: true),
  musicSnake('music_snake', 0.22, ext: 'mp3', long: true),
  musicMinesweeper('music_minesweeper', 0.22, ext: 'mp3', long: true),
  musicSolitaire('music_solitaire', 0.22, ext: 'mp3', long: true),
  musicSlide('music_slide', 0.22, ext: 'mp3', long: true),
  musicConnections('music_connections', 0.22, ext: 'mp3', long: true),
  musicFlappy('music_flappy', 0.22, ext: 'mp3', long: true),
  musicQuiz('music_quiz', 0.22, ext: 'mp3', long: true),
  musicCheckers('music_checkers', 0.22, ext: 'mp3', long: true),
  musicChess('music_chess', 0.22, ext: 'mp3', long: true),
  musicArrows('music_arrows', 0.22, ext: 'mp3', long: true),
  musicBriscola('music_briscola', 0.22, ext: 'mp3', long: true);

  final String file;
  final double volume;
  final String ext;

  /// Suoni lunghi (fanfara, trombone): player normale invece di quello a bassa latenza.
  final bool long;
  const Sfx(this.file, this.volume, {this.long = false, this.ext = 'wav'});

  /// La canzoncina del gioco [game] (nome di GameKind), se ce l'ha.
  static Sfx? musicFor(String game) {
    final f = 'music_${game.toLowerCase()}';
    for (final s in values) {
      if (s.file == f) return s;
    }
    return null;
  }
}

/// Suoni dei giochi: **spenti di base**, si accendono dall'interruttore
/// nell'elenco giochi o in Impostazioni. Quando sono spenti non si tocca mai
/// il plugin audio. Ogni errore audio viene ignorato: il suono non deve mai
/// rompere un gioco.
class GameSound extends ChangeNotifier with WidgetsBindingObserver {
  GameSound._();
  static final GameSound instance = GameSound._();

  static const _prefKey = 'game_sounds_on';

  bool _enabled = false;
  bool get enabled => _enabled;

  final Map<Sfx, AudioPlayer> _players = {};
  bool _contextSet = false;

  bool _observing = false;
  bool _suspended = false; // app in background / schermo bloccato: la musica sta ferma
  bool _starting = false; // play() della musica in corso (su web il caricamento può durare)

  /// In background (o a schermo bloccato) la musica si ferma e riparte al ritorno:
  /// su Android altrimenti continuerebbe a suonare.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.detached) {
      _suspended = true;
      _music?.pause().catchError((_) {});
    } else if (state == AppLifecycleState.resumed && _suspended) {
      _suspended = false;
      if (_wanted != null && _enabled) _music?.resume().catchError((_) {});
    }
  }

  Future<void> load() async {
    if (!_observing) {
      try {
        WidgetsBinding.instance.addObserver(this);
        _observing = true;
      } catch (_) {}
    }
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
  Timer? _watchdog;

  /// Musica di sottofondo (solo con i suoni accesi): suona in continuo finché
  /// non si chiama [stopMusic]. Se il loop nativo si ferma, riparte da sola.
  Future<void> playMusic(Sfx track) async {
    if (!_enabled || _suspended) return;
    _wanted = track;
    _starting = true;
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
      await p.play(AssetSource('sounds/${track.file}.${track.ext}'));
      // Rete di sicurezza: qualunque sia il motivo per cui si ferma (fine del
      // brano, effetti sonori, sistema), finché serve la musica riparte.
      // Non sul web: lì il caricamento può durare più di un secondo e il
      // controllo rilancerebbe il brano in continuazione (silenzio); il loop del
      // browser basta.
      if (!kIsWeb) {
        _watchdog ??= Timer.periodic(const Duration(seconds: 1), (_) => _restartMusic(immediate: true));
      }
    } catch (_) {
      // Nessun audio disponibile: si gioca in silenzio.
    } finally {
      _starting = false;
    }
  }

  void _restartMusic({bool immediate = false}) {
    final t = _wanted;
    final p = _music;
    if (t == null || p == null || !_enabled || _suspended || _starting) return;
    // con il loop nativo funzionante il player resta "playing": non si fa nulla
    Timer(immediate ? Duration.zero : const Duration(milliseconds: 80), () async {
      try {
        if (_wanted != t || p.state == PlayerState.playing) return;
        await p.play(AssetSource('sounds/${t.file}.${t.ext}'));
      } catch (_) {}
    });
  }

  Future<void> stopMusic() async {
    _wanted = null;
    _watchdog?.cancel();
    _watchdog = null;
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
