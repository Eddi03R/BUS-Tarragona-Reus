import 'package:flutter/material.dart';
import 'package:reus_tarragona_bus/l10n/app_localizations.dart';
import '../games/game_art.dart';
import '../games/game_intro_screen.dart';
import '../widgets/christmas_decorations.dart';
import '../widgets/themed_banner.dart';

/// "Spezza l'attesa": tessere grandi con l'illustrazione di ogni gioco,
/// nei colori del tema.
class ArcadeScreen extends StatelessWidget {
  const ArcadeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final games = <(GameKind, String)>[
      (GameKind.busJam, l.gameBusJam),
      (GameKind.sudoku, l.gameSudoku),
      (GameKind.maze, l.gameMaze),
      (GameKind.battleship, l.gameBattleship),
      (GameKind.ticTacToe, l.gameTicTacToe),
      (GameKind.blocks, l.gameBlocks),
      (GameKind.g2048, l.game2048),
      (GameKind.memory, l.gameMemory),
      (GameKind.wordle, l.gameWordle),
      (GameKind.flow, l.gameFlow),
      (GameKind.quiz, l.gameQuiz),
      (GameKind.snake, l.gameSnake),
      (GameKind.flappy, l.gameFlappy),
      (GameKind.minesweeper, l.gameMines),
      (GameKind.slide, l.gameSlide),
      (GameKind.connections, l.gameConnections),
      (GameKind.solitaire, l.gameSolitaire),
    ];
    return Scaffold(
      appBar: AppBar(title: Text(l.arcadeTitle)),
      body: ChristmasBackdrop(
        // Su PC lo schermo è largo: contenuto centrato e tessere più piccole,
        // con più colonne. Sul telefono resta a 2 colonne.
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 0, 4, 14),
                  child: Text(l.arcadeSubtitle,
                      style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13)),
                ),
                GridView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 190,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                  ),
                  children: [for (final g in games) _Tile(kind: g.$1, title: g.$2)],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final GameKind kind;
  final String title;
  const _Tile({required this.kind, required this.title});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([]),
      builder: (context, _) => GestureDetector(
        onTap: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => GameIntroScreen(kind: kind))),
        child: Container(
          decoration: BoxDecoration(
            gradient: ThemedBanner.gradient(),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: Colors.black.withOpacity(0.18), width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(23),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 18),
                    child: GameArt(kind),
                  ),
                ),
                Positioned(
                  left: 8,
                  right: 8,
                  bottom: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.42),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Colors.white, fontSize: 14, fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
