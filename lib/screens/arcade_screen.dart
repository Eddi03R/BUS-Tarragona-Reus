import 'package:flutter/material.dart';
import 'package:reus_tarragona_bus/l10n/app_localizations.dart';
import '../games/game_art.dart';
import '../games/game_common.dart';
import '../games/game_intro_screen.dart';
import '../games/game_style.dart';
import '../services/game_sound.dart';
import '../widgets/christmas_decorations.dart';

/// "Spezza l'attesa": una tessera a colori per ogni gioco, con titolo in alto,
/// illustrazione, stella dei preferiti (che salgono in cima) e nastri
/// "Nuovo!" / "Più giocati!".
class ArcadeScreen extends StatelessWidget {
  const ArcadeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
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
      (GameKind.checkers, l.gameCheckers),
      (GameKind.chess, l.gameChess),
      (GameKind.arrows, l.gameArrows),
    ];
    return ListenableBuilder(
      listenable: GameStats.instance,
      builder: (context, _) {
        final stats = GameStats.instance;
        // preferiti in cima (mantengono l'ordine originale tra loro)
        final sorted = [
          ...games.where((g) => stats.isFavorite(g.$1.name)),
          ...games.where((g) => !stats.isFavorite(g.$1.name)),
        ];
        // il più giocato (almeno 3 partite)
        GameKind? mostPlayed;
        var top = 2;
        for (final g in games) {
          final n = stats.plays(g.$1.name);
          if (n > top) {
            top = n;
            mostPlayed = g.$1;
          }
        }
        return Scaffold(
          appBar: AppBar(
            title: Text(l.arcadeTitle),
            actions: [
              // interruttore dei suoni dei giochi (spenti di base)
              ListenableBuilder(
                listenable: GameSound.instance,
                builder: (context, _) {
                  final on = GameSound.instance.enabled;
                  return IconButton(
                    tooltip: on ? l.gameSoundsOff : l.gameSoundsOn,
                    icon: Icon(on ? Icons.volume_up_rounded : Icons.volume_off_rounded),
                    onPressed: GameSound.instance.toggle,
                  );
                },
              ),
              Tooltip(
                message: l.arcadeRecords,
                child: Container(
                  margin: const EdgeInsets.only(right: 14),
                  padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFBE3B0),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: const [BoxShadow(color: Color(0xFFE8C97C), offset: Offset(0, 3))],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.emoji_events_rounded, size: 20, color: Color(0xFFB77900)),
                      const SizedBox(width: 6),
                      Text('${stats.recordCount}',
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF4A3300))),
                    ],
                  ),
                ),
              ),
            ],
          ),
          body: ChristmasBackdrop(
            // Su PC lo schermo è largo: contenuto centrato e tessere più piccole,
            // con più colonne. Sul telefono resta a 2 colonne.
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: GridView(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 24),
                  gridDelegate: MediaQuery.sizeOf(context).width < 600
                      ? const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 14,
                          childAspectRatio: 0.86,
                        )
                      : const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 190,
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 14,
                          childAspectRatio: 0.86,
                        ),
                  children: [
                    for (final g in sorted)
                      _Tile(
                        key: ValueKey(g.$1),
                        kind: g.$1,
                        title: g.$2,
                        favorite: stats.isFavorite(g.$1.name),
                        ribbon: g.$1 == mostPlayed
                            ? _Ribbon.popular
                            : (isNewGame(g.$1) && stats.plays(g.$1.name) == 0 ? _Ribbon.fresh : null),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

enum _Ribbon { fresh, popular }

class _Tile extends StatelessWidget {
  final GameKind kind;
  final String title;
  final bool favorite;
  final _Ribbon? ribbon;
  const _Tile({super.key, required this.kind, required this.title, required this.favorite, required this.ribbon});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final style = gameStyle(kind);
    final ring = Color.lerp(scheme.surface, scheme.onSurface, 0.13)!;
    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => GameIntroScreen(kind: kind))),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(color: ring, borderRadius: BorderRadius.circular(26)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(21),
                child: Container(
                  color: style.bg,
                  padding: const EdgeInsets.fromLTRB(12, 11, 12, 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // spazio per la stella a destra del titolo
                      Padding(
                        padding: const EdgeInsets.only(right: 30),
                        child: Text(
                          title.toUpperCase(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: style.title,
                              fontSize: 15,
                              height: 1.05,
                              fontWeight: FontWeight.w900),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Container(
                        width: 54,
                        height: 3,
                        decoration: BoxDecoration(color: style.title, borderRadius: BorderRadius.circular(2)),
                      ),
                      Expanded(child: Padding(padding: const EdgeInsets.only(top: 2), child: GameArt(kind))),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // stella: tocca per mettere / togliere dai preferiti
          Positioned(
            right: 7,
            top: 7,
            child: Semantics(
              button: true,
              label: favorite ? l.arcadeFavRemove : l.arcadeFavAdd,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => GameStats.instance.toggleFavorite(kind.name),
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: favorite ? const Color(0xFF2B2B2B) : const Color(0x66000000),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    favorite ? Icons.star_rounded : Icons.star_outline_rounded,
                    size: 22,
                    color: favorite ? const Color(0xFFFFC107) : Colors.white70,
                  ),
                ),
              ),
            ),
          ),
          if (ribbon != null)
            Positioned(
              left: -3,
              bottom: 26,
              child: Transform.rotate(
                angle: -0.09,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: ribbon == _Ribbon.fresh ? const Color(0xFFE8453C) : const Color(0xFF14B8E8),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.white, width: 2.5),
                    boxShadow: const [BoxShadow(color: Color(0x66000000), blurRadius: 6, offset: Offset(0, 3))],
                  ),
                  child: Text(
                    (ribbon == _Ribbon.fresh ? l.arcadeNew : l.arcadeMostPlayed).toUpperCase(),
                    style: const TextStyle(
                        color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w900, height: 1.05),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
