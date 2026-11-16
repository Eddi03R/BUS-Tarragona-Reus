import 'package:flutter/material.dart';
import 'package:reus_tarragona_bus/l10n/app_localizations.dart';
import '../widgets/christmas_decorations.dart';
import 'arrows_screen.dart';
import 'battleship_screen.dart';
import 'connections_screen.dart';
import 'flappy_screen.dart';
import 'minesweeper_screen.dart';
import 'quiz_screen.dart';
import 'slide_screen.dart';
import 'snake_screen.dart';
import 'solitaire_screen.dart';
import 'block_screen.dart';
import 'busjam_screen.dart';
import 'checkers_screen.dart';
import 'chess_screen.dart';
import 'flow_screen.dart';
import 'game2048_screen.dart';
import 'game_art.dart';
import 'game_style.dart';
import 'game_common.dart';
import 'maze_screen.dart';
import 'memory_screen.dart';
import 'sudoku_screen.dart';
import 'tictactoe_screen.dart';
import 'wordle_screen.dart';

/// Pagina prima della partita: spiegazione breve del gioco e scelta della
/// difficoltà, poi "Gioca".
class GameIntroScreen extends StatefulWidget {
  final GameKind kind;
  const GameIntroScreen({super.key, required this.kind});

  @override
  State<GameIntroScreen> createState() => _GameIntroScreenState();
}

class _GameIntroScreenState extends State<GameIntroScreen> {
  Difficulty _difficulty = Difficulty.easy;
  bool _wordleDaily = true;

  static const _noDifficulty = {
    GameKind.wordle,
    GameKind.quiz,
    GameKind.connections,
    GameKind.solitaire,
  };
  // Parola del giorno: la difficoltà (numero di tentativi) vale solo per la
  // parola casuale; quella di oggi è uguale per tutti.
  bool get _hasDifficulty =>
      !_noDifficulty.contains(widget.kind) || (widget.kind == GameKind.wordle && !_wordleDaily);

  String _title(AppLocalizations l) => switch (widget.kind) {
        GameKind.busJam => l.gameBusJam,
        GameKind.sudoku => l.gameSudoku,
        GameKind.maze => l.gameMaze,
        GameKind.battleship => l.gameBattleship,
        GameKind.ticTacToe => l.gameTicTacToe,
        GameKind.blocks => l.gameBlocks,
        GameKind.g2048 => l.game2048,
        GameKind.memory => l.gameMemory,
        GameKind.wordle => l.gameWordle,
        GameKind.flow => l.gameFlow,
        GameKind.snake => l.gameSnake,
        GameKind.minesweeper => l.gameMines,
        GameKind.solitaire => l.gameSolitaire,
        GameKind.slide => l.gameSlide,
        GameKind.connections => l.gameConnections,
        GameKind.flappy => l.gameFlappy,
        GameKind.quiz => l.gameQuiz,
        GameKind.checkers => l.gameCheckers,
        GameKind.chess => l.gameChess,
        GameKind.arrows => l.gameArrows,
      };

  String _how(AppLocalizations l) => switch (widget.kind) {
        GameKind.busJam => l.gameBusJamHow,
        GameKind.sudoku => l.gameSudokuHow,
        GameKind.maze => l.gameMazeHow,
        GameKind.battleship => l.gameBattleshipHow,
        GameKind.ticTacToe => l.gameTicTacToeHow,
        GameKind.blocks => l.gameBlocksHow,
        GameKind.g2048 => l.game2048How,
        GameKind.memory => l.gameMemoryHow,
        GameKind.wordle => l.gameWordleHow,
        GameKind.flow => l.gameFlowHow,
        GameKind.snake => l.gameSnakeHow,
        GameKind.minesweeper => l.gameMinesHow,
        GameKind.solitaire => l.gameSolitaireHow,
        GameKind.slide => l.gameSlideHow,
        GameKind.connections => l.gameConnectionsHow,
        GameKind.flappy => l.gameFlappyHow,
        GameKind.quiz => l.gameQuizHow,
        GameKind.checkers => l.gameCheckersHow,
        GameKind.chess => l.gameChessHow,
        GameKind.arrows => l.gameArrowsHow,
      };

  Widget _game() => switch (widget.kind) {
        GameKind.busJam => BusJamScreen(difficulty: _difficulty),
        GameKind.sudoku => SudokuScreen(difficulty: _difficulty),
        GameKind.maze => MazeScreen(difficulty: _difficulty),
        GameKind.battleship => BattleshipScreen(difficulty: _difficulty),
        GameKind.ticTacToe => TicTacToeScreen(difficulty: _difficulty),
        GameKind.blocks => BlockScreen(difficulty: _difficulty),
        GameKind.g2048 => Game2048Screen(difficulty: _difficulty),
        GameKind.memory => MemoryScreen(difficulty: _difficulty),
        GameKind.wordle => WordleScreen(daily: _wordleDaily, difficulty: _difficulty),
        GameKind.flow => FlowScreen(difficulty: _difficulty),
        GameKind.snake => SnakeScreen(difficulty: _difficulty),
        GameKind.minesweeper => MinesweeperScreen(difficulty: _difficulty),
        GameKind.solitaire => const SolitaireScreen(),
        GameKind.slide => SlideScreen(difficulty: _difficulty),
        GameKind.connections => const ConnectionsScreen(),
        GameKind.flappy => FlappyScreen(difficulty: _difficulty),
        GameKind.quiz => const QuizScreen(),
        GameKind.checkers => CheckersScreen(difficulty: _difficulty),
        GameKind.chess => ChessScreen(difficulty: _difficulty),
        GameKind.arrows => ArrowsScreen(difficulty: _difficulty),
      };

  Color get _levelColor => switch (_difficulty) {
        Difficulty.easy => Colors.green.shade600,
        Difficulty.medium => Colors.orange.shade700,
        Difficulty.hard => Colors.red.shade600,
      };

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final sub = widget.kind == GameKind.busJam
        ? l.gameLevel(BusJamScreen.unlocked(_difficulty))
        : widget.kind == GameKind.arrows
            ? l.gameLevel(ArrowsScreen.levelFor(_difficulty))
            : (widget.kind == GameKind.wordle ? (_wordleDaily ? l.wordleToday : l.wordlePractice) : l.gameNew);
    return Scaffold(
      appBar: AppBar(title: Text(_title(l))),
      body: ChristmasBackdrop(
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Copertina del gioco (colori fissi del gioco, come nell'elenco)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: gameStyle(widget.kind).bg,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: SizedBox(height: 170, child: GameArt(widget.kind)),
                  ),
                  const SizedBox(height: 20),
                  Text(_title(l),
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w800)),
                  const SizedBox(height: 10),
                  Text(_how(l),
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15, height: 1.4, color: scheme.onSurfaceVariant)),
                  if (widget.kind == GameKind.wordle) ...[
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: _ModeButton(
                            icon: Icons.today_rounded,
                            label: l.wordleToday,
                            selected: _wordleDaily,
                            onTap: () => setState(() => _wordleDaily = true),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _ModeButton(
                            icon: Icons.casino_rounded,
                            label: l.wordlePractice,
                            selected: !_wordleDaily,
                            onTap: () => setState(() => _wordleDaily = false),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (_hasDifficulty) ...[
                  const SizedBox(height: 28),
                  Text(l.gameDifficulty.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 12,
                          letterSpacing: 1.2,
                          fontWeight: FontWeight.w700,
                          color: scheme.onSurfaceVariant)),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      difficultyLabel(l, _difficulty).toUpperCase(),
                      key: ValueKey(_difficulty),
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: _levelColor),
                    ),
                  ),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      trackHeight: 14,
                      activeTrackColor: _levelColor,
                      thumbColor: _levelColor,
                      overlayColor: _levelColor.withOpacity(0.15),
                    ),
                    child: Slider(
                      value: _difficulty.index.toDouble(),
                      min: 0,
                      max: 2,
                      divisions: 2,
                      onChanged: (v) => setState(() => _difficulty = Difficulty.values[v.round()]),
                    ),
                  ),
                  if (widget.kind == GameKind.wordle)
                    Text(l.wordleAttempts(WordleScreen.attemptsFor(_difficulty)),
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant)),
                  ],
                  const SizedBox(height: 20),
                  GameButton(
                    icon: Icons.play_arrow_rounded,
                    label: l.gamePlay,
                    onPressed: () {
                      GameStats.instance.addPlay(widget.kind.name);
                      Navigator.of(context)
                          .push(MaterialPageRoute(builder: (_) => _game()))
                          .then((_) => setState(() {}));
                    },
                  ),
                  const SizedBox(height: 6),
                  Text(sub,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Scelta tra due modalità, con la stessa forma dei pulsanti dell'app
/// (angoli 16, altezza 16+16, testo 16 semibold): pieno = selezionato.
class _ModeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _ModeButton({required this.icon, required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fg = selected ? scheme.onPrimaryContainer : scheme.onSurfaceVariant;
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? scheme.primaryContainer : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: selected ? scheme.primary : scheme.outlineVariant, width: selected ? 2 : 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 20, color: fg),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(label,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: fg)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
