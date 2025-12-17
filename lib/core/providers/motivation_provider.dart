import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';

final motivationProvider = AsyncNotifierProvider<MotivationNotifier, String?>(MotivationNotifier.new);

class MotivationNotifier extends AsyncNotifier<String?> {
  List<String> _items = [];
  Timer? _timer;
  final _rnd = Random();
  int _currentIdx = 0;

  @override
  Future<String?> build() async {
    try {
      final raw = await rootBundle.loadString('assets/motivation/motivation.json');
      _items = (json.decode(raw) as List<dynamic>).map((e) => e.toString()).where((s) => s.isNotEmpty).toList();
      if (_items.isEmpty) return null;
      _currentIdx = _rnd.nextInt(_items.length);
      state = AsyncValue.data(_items[_currentIdx]);
      _startTimer();
      // Cancel timer when provider is disposed
      ref.onDispose(() {
        _timer?.cancel();
      });
      return state.value;
    } catch (_) {
      return null;
    }
  }

  void _startTimer() {
    _timer?.cancel();
    if (_items.isEmpty) return;
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (_items.length <= 1) return;
      int next;
      do {
        next = _rnd.nextInt(_items.length);
      } while (next == _currentIdx && _items.length > 1);
      _currentIdx = next;
      state = AsyncValue.data(_items[_currentIdx]);
    });
  }

  /// Manually refresh the current motivation.
  /// If the items list is empty, attempt to (re)load the asset.
  Future<void> refresh() async {
    try {
      if (_items.isEmpty) {
        final raw = await rootBundle.loadString('assets/motivation/motivation.json');
        _items = (json.decode(raw) as List<dynamic>).map((e) => e.toString()).where((s) => s.isNotEmpty).toList();
      }

      if (_items.isEmpty) {
        state = const AsyncValue.data(null);
        return;
      }

      int next;
      if (_items.length == 1) {
        next = 0;
      } else {
        do {
          next = _rnd.nextInt(_items.length);
        } while (next == _currentIdx);
      }

      _currentIdx = next;
      state = AsyncValue.data(_items[_currentIdx]);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  // Timer cancellation handled via ref.onDispose in build().
}
