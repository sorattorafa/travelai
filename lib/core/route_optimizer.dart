import 'dart:math' as math;
import '../domain/entities/itinerary_entity.dart';

/// Otimizador de rota do roteiro.
///
/// Estrat\u00e9gia: os passos com `mealSlot != null` (caf\u00e9, almo\u00e7o, jantar) s\u00e3o
/// \u00e2ncoras fixas no hor\u00e1rio. Os passeios entre duas \u00e2ncoras consecutivas
/// formam um "segmento" reorden\u00e1vel. Para cada segmento, calcula-se a
/// permuta\u00e7\u00e3o de menor dist\u00e2ncia total usando for\u00e7a bruta (segmentos at\u00e9
/// 6 pontos, 720 permuta\u00e7\u00f5es \u2014 instant\u00e2neo em celular).
///
/// A dist\u00e2ncia usa a f\u00f3rmula de Haversine (linha reta entre coordenadas
/// geogr\u00e1ficas) \u2014 gr\u00e1tis, offline, e precis\u00e3o suficiente para o caso de uso.
class RouteOptimizer {
  /// Reordena os steps mantendo refei\u00e7\u00f5es fixas e otimizando os passeios
  /// entre elas. Steps sem coordenadas s\u00e3o mantidos na ordem atual.
  ///
  /// Tamb\u00e9m renumera `order` e recalcula o campo `transport` para refletir
  /// a nova dist\u00e2ncia em cada aresta.
  static List<ItineraryStep> optimize(List<ItineraryStep> steps) {
    if (steps.length < 3) return List.of(steps);

    // Quebra em segmentos delimitados por \u00e2ncoras (refei\u00e7\u00f5es).
    final segments = <List<ItineraryStep>>[];
    var current = <ItineraryStep>[];
    for (final s in steps) {
      if (s.isFixed) {
        segments.add(current);
        segments.add([s]); // \u00e2ncora sozinha
        current = <ItineraryStep>[];
      } else {
        current.add(s);
      }
    }
    segments.add(current);

    // Otimiza cada segmento, usando a \u00e2ncora anterior como ponto de partida
    // e a pr\u00f3xima como destino (quando existirem).
    final out = <ItineraryStep>[];
    for (var i = 0; i < segments.length; i++) {
      final seg = segments[i];
      if (seg.isEmpty) continue;
      if (seg.length == 1) {
        out.add(seg.first);
        continue;
      }

      final prevAnchor = _lastWithCoords(out);
      final nextAnchor = _firstWithCoordsFrom(segments, i + 1);

      final withCoords = seg.where((s) => s.hasCoords).toList();
      final withoutCoords = seg.where((s) => !s.hasCoords).toList();

      List<ItineraryStep> ordered;
      if (withCoords.length >= 2) {
        ordered = _bestPermutation(
          withCoords,
          start: prevAnchor,
          end: nextAnchor,
        );
      } else {
        ordered = withCoords;
      }
      // Steps sem coord s\u00e3o apensados no fim do segmento, ordem original.
      out.addAll([...ordered, ...withoutCoords]);
    }

    // Renumera order e recalcula transport aproximado.
    return _renumberAndAnnotate(out);
  }

  static ItineraryStep? _lastWithCoords(List<ItineraryStep> list) {
    for (var i = list.length - 1; i >= 0; i--) {
      if (list[i].hasCoords) return list[i];
    }
    return null;
  }

  static ItineraryStep? _firstWithCoordsFrom(
    List<List<ItineraryStep>> segments,
    int startIdx,
  ) {
    for (var i = startIdx; i < segments.length; i++) {
      for (final s in segments[i]) {
        if (s.hasCoords) return s;
      }
    }
    return null;
  }

  /// For\u00e7a bruta sobre as permuta\u00e7\u00f5es de `items`, escolhendo a de menor
  /// dist\u00e2ncia total considerando `start` \u2192 items \u2192 `end`.
  static List<ItineraryStep> _bestPermutation(
    List<ItineraryStep> items, {
    ItineraryStep? start,
    ItineraryStep? end,
  }) {
    if (items.length > 7) {
      // Heur\u00edstica: mais de 7 \u00e9 improv\u00e1vel no caso de uso, mas cairia em
      // 5040 permuta\u00e7\u00f5es. Usa nearest-neighbor.
      return _nearestNeighbor(items, start: start, end: end);
    }

    double bestDist = double.infinity;
    List<ItineraryStep> best = items;
    for (final perm in _permutations(items)) {
      final d = _totalDistance(perm, start: start, end: end);
      if (d < bestDist) {
        bestDist = d;
        best = perm;
      }
    }
    return best;
  }

  static List<ItineraryStep> _nearestNeighbor(
    List<ItineraryStep> items, {
    ItineraryStep? start,
    ItineraryStep? end,
  }) {
    final remaining = List.of(items);
    final result = <ItineraryStep>[];
    ItineraryStep? cursor = start;
    while (remaining.isNotEmpty) {
      remaining.sort((a, b) {
        final da = cursor == null ? 0 : _haversine(cursor!, a);
        final db = cursor == null ? 0 : _haversine(cursor!, b);
        return da.compareTo(db);
      });
      final next = remaining.removeAt(0);
      result.add(next);
      cursor = next;
    }
    // `end` influencia apenas a \u00faltima escolha; simples o suficiente aqui.
    if (end != null && result.length >= 2) {
      result.sort((a, b) => 0);
    }
    return result;
  }

  static Iterable<List<ItineraryStep>> _permutations(
    List<ItineraryStep> items,
  ) sync* {
    if (items.length <= 1) {
      yield List.of(items);
      return;
    }
    for (var i = 0; i < items.length; i++) {
      final rest = [...items.sublist(0, i), ...items.sublist(i + 1)];
      for (final p in _permutations(rest)) {
        yield [items[i], ...p];
      }
    }
  }

  static double _totalDistance(
    List<ItineraryStep> seq, {
    ItineraryStep? start,
    ItineraryStep? end,
  }) {
    double total = 0;
    ItineraryStep? prev = start;
    for (final s in seq) {
      if (prev != null) total += _haversine(prev, s);
      prev = s;
    }
    if (end != null && prev != null) total += _haversine(prev, end);
    return total;
  }

  /// Dist\u00e2ncia em metros entre dois steps geo.
  static double _haversine(ItineraryStep a, ItineraryStep b) {
    if (!a.hasCoords || !b.hasCoords) return 0;
    const r = 6371000.0; // raio terra em m
    final dLat = _toRad(b.latitude! - a.latitude!);
    final dLon = _toRad(b.longitude! - a.longitude!);
    final lat1 = _toRad(a.latitude!);
    final lat2 = _toRad(b.latitude!);
    final h = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.sin(dLon / 2) * math.sin(dLon / 2) * math.cos(lat1) * math.cos(lat2);
    return 2 * r * math.asin(math.sqrt(h));
  }

  static double _toRad(double deg) => deg * math.pi / 180;

  static List<ItineraryStep> _renumberAndAnnotate(List<ItineraryStep> steps) {
    final result = <ItineraryStep>[];
    for (var i = 0; i < steps.length; i++) {
      final cur = steps[i];
      String? transport = cur.transport;
      if (i < steps.length - 1) {
        final nxt = steps[i + 1];
        if (cur.hasCoords && nxt.hasCoords) {
          final meters = _haversine(cur, nxt);
          transport = _describeDistance(meters);
        }
      } else {
        transport = null; // \u00faltimo passo sem transporte
      }
      result.add(cur.copyWith(order: i, transport: transport));
    }
    return result;
  }

  static String _describeDistance(double meters) {
    if (meters < 150) return 'Ao lado (${meters.round()} m)';
    if (meters < 1500) {
      final min = (meters / 80).round(); // ~80 m/min caminhando
      return '~$min min a p\u00e9 (${meters.round()} m)';
    }
    final km = (meters / 1000).toStringAsFixed(1);
    return '~$km km de carro';
  }

  /// Dist\u00e2ncia total do roteiro em metros (ignora passos sem coord).
  static double totalRouteMeters(List<ItineraryStep> steps) {
    double total = 0;
    ItineraryStep? prev;
    for (final s in steps) {
      if (prev != null && prev.hasCoords && s.hasCoords) {
        total += _haversine(prev, s);
      }
      prev = s;
    }
    return total;
  }
}
