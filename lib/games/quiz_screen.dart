import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:reus_tarragona_bus/l10n/app_localizations.dart';
import 'game_common.dart';
import 'logic/quiz_data.dart';

class _Round {
  final QuizQuestion q;
  final List<int> order; // indici di q.options in ordine mescolato
  _Round(this.q, this.order);
}

/// Quiz: 10 domande mescolate su Tarragona, Santa Tecla, Spagna e Catalogna.
class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  static const int rounds = 10;
  static const String _key = 'quiz';
  final _rand = Random();
  late List<_Round> _list;
  int _i = 0;
  int _score = 0;
  int? _picked; // posizione scelta (nell'ordine mescolato)
  bool _finished = false;
  bool _newRecord = false;

  @override
  void initState() {
    super.initState();
    _newGame();
  }

  void _newGame() {
    final qs = List.of(quizQuestions)..shuffle(_rand);
    setState(() {
      _list = [
        for (final q in qs.take(rounds))
          _Round(q, List.generate(q.options.length, (i) => i)..shuffle(_rand)),
      ];
      _i = 0;
      _score = 0;
      _picked = null;
      _finished = false;
      _newRecord = false;
    });
  }

  void _pick(int pos) {
    if (_picked != null) return;
    final r = _list[_i];
    final ok = r.order[pos] == r.q.answer;
    HapticFeedback.selectionClick();
    setState(() {
      _picked = pos;
      if (ok) _score++;
    });
  }

  Future<void> _next() async {
    if (_i + 1 < _list.length) {
      setState(() {
        _i++;
        _picked = null;
      });
      return;
    }
    final record = await GameStats.instance.submitHigh(_key, _score);
    if (!mounted) return;
    setState(() {
      _finished = true;
      _newRecord = record;
    });
  }

  String _catName(AppLocalizations l, QuizCat c) => switch (c) {
        QuizCat.tarragona => l.quizCatTarragona,
        QuizCat.santaTecla => l.quizCatSantaTecla,
        QuizCat.spain => l.quizCatSpain,
        QuizCat.catalonia => l.quizCatCatalonia,
      };

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final scheme = Theme.of(context).colorScheme;
    final lang = Localizations.localeOf(context).languageCode;
    final best = GameStats.instance.high(_key);
    if (_finished) {
      final great = _score >= 8;
      return GameScaffold(
        title: l.gameQuiz,
        celebrate: great,
        children: [
          const SizedBox(height: 12),
          ResultBanner(
            key: ValueKey('quiz-$_score'),
            text: _newRecord ? '${l.quizScore(_score, rounds)} 🏆' : l.quizScore(_score, rounds),
            kind: great ? ResultKind.win : ResultKind.neutral,
          ),
          const SizedBox(height: 10),
          Center(child: Text(best == null ? l.gameNoRecord : l.gameBestScore(best))),
          const SizedBox(height: 24),
          GameButton(onPressed: _newGame, icon: Icons.refresh_rounded, label: l.gameNew),
        ],
      );
    }
    final r = _list[_i];
    return GameScaffold(
      title: l.gameQuiz,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l.quizQuestionOf(_i + 1, rounds),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            Text(l.gameScore(_score)),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: (_i + (_picked == null ? 0 : 1)) / rounds,
          minHeight: 6,
          borderRadius: BorderRadius.circular(3),
        ),
        const SizedBox(height: 18),
        Align(
          alignment: Alignment.centerLeft,
          child: Chip(
            label: Text(_catName(l, r.q.cat), style: const TextStyle(fontSize: 12)),
            visualDensity: VisualDensity.compact,
          ),
        ),
        const SizedBox(height: 6),
        Text(r.q.textFor(lang),
            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700, height: 1.3)),
        const SizedBox(height: 18),
        for (var pos = 0; pos < r.order.length; pos++) ...[
          _option(scheme, r, pos),
          const SizedBox(height: 10),
        ],
        const SizedBox(height: 6),
        if (_picked != null)
          GameButton(
            onPressed: _next,
            icon: _i + 1 < _list.length ? Icons.arrow_forward_rounded : Icons.flag_rounded,
            label: _i + 1 < _list.length ? l.quizNext : l.quizFinish,
          ),
      ],
    );
  }

  Widget _option(ColorScheme scheme, _Round r, int pos) {
    final isAnswer = r.order[pos] == r.q.answer;
    final chosen = _picked == pos;
    Color bg = scheme.surfaceContainerHighest;
    Color fg = scheme.onSurface;
    IconData? icon;
    if (_picked != null) {
      if (isAnswer) {
        bg = Colors.green.shade600;
        fg = Colors.white;
        icon = Icons.check_circle_rounded;
      } else if (chosen) {
        bg = Colors.red.shade600;
        fg = Colors.white;
        icon = Icons.cancel_rounded;
      }
    }
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => _pick(pos),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: [
            Expanded(
              child: Text(r.q.options[r.order[pos]],
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: fg)),
            ),
            if (icon != null) Icon(icon, color: fg),
          ],
        ),
      ),
    );
  }
}
