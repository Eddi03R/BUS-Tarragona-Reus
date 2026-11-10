import 'package:flutter/material.dart';
import 'package:reus_tarragona_bus/l10n/app_localizations.dart';
import '../games/game_intro_screen.dart';
import '../widgets/christmas_decorations.dart';

/// "Spezza l'attesa": minigiochi per l'attesa del bus.
class ArcadeScreen extends StatelessWidget {
  const ArcadeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final games = <_Game>[
      _Game(Icons.directions_bus_rounded, l.gameBusJam, l.gameBusJamDesc, const GameIntroScreen(kind: GameKind.busJam)),
      _Game(Icons.grid_on_rounded, l.gameSudoku, l.gameSudokuDesc, const GameIntroScreen(kind: GameKind.sudoku)),
      _Game(Icons.route_rounded, l.gameMaze, l.gameMazeDesc, const GameIntroScreen(kind: GameKind.maze)),
      _Game(Icons.sailing_rounded, l.gameBattleship, l.gameBattleshipDesc, const GameIntroScreen(kind: GameKind.battleship)),
      _Game(Icons.tag_rounded, l.gameTicTacToe, l.gameTicTacToeDesc, const GameIntroScreen(kind: GameKind.ticTacToe)),
    ];
    return Scaffold(
      appBar: AppBar(title: Text(l.arcadeTitle)),
      body: ChristmasBackdrop(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(l.arcadeSubtitle,
                style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13)),
            const SizedBox(height: 16),
            for (final g in games)
              Card(
                margin: const EdgeInsets.only(bottom: 12),
                clipBehavior: Clip.antiAlias,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: scheme.primaryContainer,
                    child: Icon(g.icon, color: scheme.onPrimaryContainer),
                  ),
                  title: Text(g.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text(g.subtitle),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => Navigator.of(context)
                      .push(MaterialPageRoute(builder: (_) => g.screen)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Game {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget screen;
  const _Game(this.icon, this.title, this.subtitle, this.screen);
}
