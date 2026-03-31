import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'widgets.dart';

class MapScreen extends StatefulWidget {
  final List<MapPlace> places;
  final String lang;
  // Callback opcional para abrir el player de un lugar
  final void Function(MapPlace)? onPlaceTap;

  const MapScreen({
    super.key,
    required this.places,
    required this.lang,
    this.onPlaceTap,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  MapPlace? _selected;
  final MapController _mapController = MapController();

  void _onMarkerTap(MapPlace place) {
    setState(() => _selected = place);
    _mapController.move(LatLng(place.lat, place.lng), 15);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(
        child: Stack(children: [

          // ── MAPA ──
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: const LatLng(52.5163, 13.3777),
              initialZoom: 12,
              onTap: (_, __) => setState(() => _selected = null),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.citylore.app',
              ),
              MarkerLayer(
                markers: widget.places.map((place) {
                  final isSelected = _selected?.id == place.id;
                  return Marker(
                    point: LatLng(place.lat, place.lng),
                    width: isSelected ? 44 : 36,
                    height: isSelected ? 44 : 36,
                    child: GestureDetector(
                      onTap: () => _onMarkerTap(place),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: isSelected ? kGold : kSurface,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? kGoldLight : kGold,
                            width: isSelected ? 2.5 : 1.5,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '${place.numero}',
                            style: TextStyle(
                              fontSize: isSelected ? 14 : 11,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.black : kGold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),

          // ── TOP BAR ──
          Positioned(
            top: 0, left: 0, right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: kSurface.withOpacity(0.95),
              child: Row(children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                        border: Border.all(color: kBorder),
                        borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.arrow_back, color: kText, size: 18),
                  ),
                ),
                const SizedBox(width: 12),
                const Text('🇩🇪 Berlín',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: kText)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                      color: kSurface2,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: kBorder)),
                  child: Text('${widget.places.length} lugares',
                      style: const TextStyle(fontSize: 11, color: kMuted)),
                ),
              ]),
            ),
          ),

          // ── CARD lugar seleccionado ──
          if (_selected != null)
            Positioned(
              bottom: 24, left: 16, right: 16,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: kSurface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: kGold)),
                child: Row(children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                        color: kGold.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: kGold)),
                    child: Center(
                      child: Text('${_selected!.numero}',
                          style: const TextStyle(
                              fontSize: 14, fontWeight: FontWeight.bold, color: kGold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(_selected!.nombre,
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600, color: kText)),
                      const SizedBox(height: 2),
                      Text(_selected!.barrio,
                          style: const TextStyle(fontSize: 12, color: kMuted)),
                    ]),
                  ),
                  const SizedBox(width: 8),
                  // Botón Escuchar
                  if (widget.onPlaceTap != null)
                    GestureDetector(
                      onTap: () => widget.onPlaceTap!(_selected!),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                            color: kGold,
                            borderRadius: BorderRadius.circular(10)),
                        child: const Row(children: [
                          Icon(Icons.headphones, color: Colors.black, size: 14),
                          SizedBox(width: 4),
                          Text('Escuchar',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.black, fontWeight: FontWeight.w600)),
                        ]),
                      ),
                    ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => setState(() => _selected = null),
                    child: Container(
                      width: 28, height: 28,
                      decoration: BoxDecoration(
                          color: kSurface2,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: kBorder)),
                      child: const Icon(Icons.close, color: kMuted, size: 14),
                    ),
                  ),
                ]),
              ),
            ),
        ]),
      ),
    );
  }
}