import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/poi.dart';

class PoiRepository {
  PoiRepository._();
  static final PoiRepository instance = PoiRepository._();

  List<Poi> _pois = [];
  bool _loaded = false;

  List<Poi> get pois => List.unmodifiable(_pois);

  Future<void> load() async {
    if (_loaded) return;
    final raw = await rootBundle.loadString('assets/data/poi.json');
    final json = jsonDecode(raw) as Map<String, dynamic>;
    _pois = (json['pois'] as List)
        .map((e) => Poi.fromJson(e as Map<String, dynamic>))
        .toList();
    _loaded = true;
  }
}
