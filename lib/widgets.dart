import 'package:flutter/material.dart';

// ── COLORES GLOBALES ──────────────────────────────────────────
const kBg        = Color(0xFF0a0a0f);
const kSurface   = Color(0xFF13131a);
const kSurface2  = Color(0xFF1c1c28);
const kBorder    = Color(0xFF2a2a3a);
const kGold      = Color(0xFFc9a84c);
const kGoldLight = Color(0xFFe8c97a);
const kText      = Color(0xFFe8e4dc);
const kMuted     = Color(0xFF7a7890);
const kCapaColors = {
  'historia':     Color(0xFF4a7fa5),
  'arquitectura': Color(0xFF7a5fa5),
  'arte':         Color(0xFFa55f7a),
  'curiosidades': Color(0xFF5fa57a),
};

// ── MODELO COMPARTIDO ─────────────────────────────────────────
class MapPlace {
  final String id, nombre, barrio;
  final double lat, lng;
  final int numero;
  const MapPlace({
    required this.id, required this.nombre, required this.barrio,
    required this.lat, required this.lng, required this.numero,
  });
}

// ── SELECTOR DE IDIOMA ────────────────────────────────────────
Widget langPill(String current, void Function(String) onSelect) {
  return Container(
    padding: const EdgeInsets.all(3),
    decoration: BoxDecoration(
        color: kSurface2,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kBorder)),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: ['es', 'en', 'de', 'it'].map((l) {
        final active = current == l;
        return GestureDetector(
          onTap: () => onSelect(l),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
                color: active ? kGold : Colors.transparent,
                borderRadius: BorderRadius.circular(16)),
            child: Text(l.toUpperCase(),
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: active ? Colors.black : kMuted)),
          ),
        );
      }).toList(),
    ),
  );
}