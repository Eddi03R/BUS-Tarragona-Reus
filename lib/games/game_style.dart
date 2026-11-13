import 'package:flutter/material.dart';
import 'game_art.dart';

/// Colori fissi di ogni gioco (non seguono i temi): sfondo della tessera e
/// colore del titolo.
class GameStyle {
  final Color bg;
  final Color title;
  const GameStyle(this.bg, this.title);
}

GameStyle gameStyle(GameKind k) => switch (k) {
      GameKind.busJam => const GameStyle(Color(0xFFCDE9F5), Color(0xFF0E6BA8)),
      GameKind.sudoku => const GameStyle(Color(0xFFF7D6E0), Color(0xFFC2185B)),
      GameKind.maze => const GameStyle(Color(0xFF1F2430), Color(0xFFFF5C8A)),
      GameKind.battleship => const GameStyle(Color(0xFF0D2B45), Color(0xFF4FC3F7)),
      GameKind.ticTacToe => const GameStyle(Color(0xFFE0F3E6), Color(0xFF1B8A50)),
      GameKind.blocks => const GameStyle(Color(0xFF2B1B4F), Color(0xFFD1A3FF)),
      GameKind.g2048 => const GameStyle(Color(0xFFF7E8D0), Color(0xFFE0662A)),
      GameKind.memory => const GameStyle(Color(0xFFFFE9A8), Color(0xFFB26A00)),
      GameKind.wordle => const GameStyle(Color(0xFF1C3A2B), Color(0xFF7BE495)),
      GameKind.flow => const GameStyle(Color(0xFF103B5C), Color(0xFFFFC933)),
      GameKind.snake => const GameStyle(Color(0xFF0B0F14), Color(0xFFFFC933)),
      GameKind.minesweeper => const GameStyle(Color(0xFFCBD6E0), Color(0xFF34495E)),
      GameKind.solitaire => const GameStyle(Color(0xFF1B5E3F), Color(0xFFFFF59D)),
      GameKind.slide => const GameStyle(Color(0xFFFFD9C2), Color(0xFFD84315)),
      GameKind.connections => const GameStyle(Color(0xFFE1D5F2), Color(0xFF5E35B1)),
      GameKind.flappy => const GameStyle(Color(0xFF7FD3F7), Color(0xFF0B5C86)),
      GameKind.quiz => const GameStyle(Color(0xFFFFEFC2), Color(0xFFC2410C)),
      GameKind.checkers => const GameStyle(Color(0xFF2A1A14), Color(0xFFF2C14E)),
      GameKind.chess => const GameStyle(Color(0xFFF3E7D3), Color(0xFF8B4A2B)),
    };

/// Giochi aggiunti da poco (data di uscita): mostrano il nastro "Nuovo!" per
/// 10 giorni, finché non li provi.
final Map<GameKind, DateTime> gameAddedOn = {
  GameKind.snake: DateTime(2026, 11, 12),
  GameKind.minesweeper: DateTime(2026, 11, 12),
  GameKind.solitaire: DateTime(2026, 11, 12),
  GameKind.slide: DateTime(2026, 11, 12),
  GameKind.connections: DateTime(2026, 11, 12),
  GameKind.flappy: DateTime(2026, 11, 12),
  GameKind.quiz: DateTime(2026, 11, 12),
  GameKind.checkers: DateTime(2026, 11, 13),
  GameKind.chess: DateTime(2026, 11, 13),
};

bool isNewGame(GameKind k, [DateTime? now]) {
  final d = gameAddedOn[k];
  return d != null && (now ?? DateTime.now()).difference(d) < const Duration(days: 10);
}
