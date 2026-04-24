import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'dart:math' as math;
import 'widgets.dart';
import 'sorpresa.dart' show tourName; // ← nombres traducidos

// ── TRADUCCIONES TOURS ────────────────────────────────────────
const kTT = {
  'es': {
    'title':        'Tours Temáticos',
    'subtitle':     'Berlín por temas, a pie.',
    'stops':        'paradas',
    'start':        'Comenzar tour →',
    'walk_to':      'Camina hacia',
    'near_stop':    '¡Estás en el lugar!',
    'next':         'Siguiente →',
    'next_stop':    'Siguiente parada →',
    'end_title':    'Tour completado',
    'end_sub':      'Gracias por explorar Berlín.',
    'back_home':    'Volver al inicio',
    'audio_soon':   'Audio próximamente',
    'error_load':   'Error al cargar tours',
    'retry':        'Reintentar',
    'loading':      'Cargando tours...',
    'stop':         'Parada',
    'min':          'min',
    'km':           'km',
    'empty_title':  'Tours en producción',
    'empty_sub':    'Estamos preparando rutas increíbles. Vuelve pronto.',
  },
  'en': {
    'title':        'Thematic Tours',
    'subtitle':     'Berlin by theme, on foot.',
    'stops':        'stops',
    'start':        'Start tour →',
    'walk_to':      'Walk to',
    'near_stop':    'You are here!',
    'next':         'Next →',
    'next_stop':    'Next stop →',
    'end_title':    'Tour completed',
    'end_sub':      'Thank you for exploring Berlin.',
    'back_home':    'Back to home',
    'audio_soon':   'Audio coming soon',
    'error_load':   'Error loading tours',
    'retry':        'Retry',
    'loading':      'Loading tours...',
    'stop':         'Stop',
    'min':          'min',
    'km':           'km',
    'empty_title':  'Tours in production',
    'empty_sub':    'We are preparing amazing routes. Come back soon.',
  },
  'de': {
    'title':        'Thematische Touren',
    'subtitle':     'Berlin nach Themen, zu Fuß.',
    'stops':        'Stationen',
    'start':        'Tour beginnen →',
    'walk_to':      'Geh zu',
    'near_stop':    'Du bist hier!',
    'next':         'Weiter →',
    'next_stop':    'Nächste Station →',
    'end_title':    'Tour abgeschlossen',
    'end_sub':      'Danke, dass du Berlin erkundet hast.',
    'back_home':    'Zurück zum Start',
    'audio_soon':   'Audio demnächst',
    'error_load':   'Fehler beim Laden',
    'retry':        'Erneut versuchen',
    'loading':      'Touren werden geladen...',
    'stop':         'Station',
    'min':          'Min',
    'km':           'km',
    'empty_title':  'Touren in Produktion',
    'empty_sub':    'Wir bereiten tolle Routen vor. Komm bald zurück.',
  },
  'it': {
    'title':        'Tour Tematici',
    'subtitle':     'Berlino per temi, a piedi.',
    'stops':        'tappe',
    'start':        'Inizia il tour →',
    'walk_to':      'Cammina verso',
    'near_stop':    'Sei qui!',
    'next':         'Avanti →',
    'next_stop':    'Prossima tappa →',
    'end_title':    'Tour completato',
    'end_sub':      'Grazie per aver esplorato Berlino.',
    'back_home':    'Torna all\'inizio',
    'audio_soon':   'Audio prossimamente',
    'error_load':   'Errore nel caricamento',
    'retry':        'Riprova',
    'loading':      'Caricamento tour...',
    'stop':         'Tappa',
    'min':          'min',
    'km':           'km',
    'empty_title':  'Tour in produzione',
    'empty_sub':    'Stiamo preparando percorsi incredibili. Torna presto.',
  },
};

String tt(String lang, String key) =>
    kTT[lang]?[key] ?? kTT['es']![key] ?? key;

// ── ICONOS Y COLORES POR TIPO ─────────────────────────────────
const kTourMeta = {
  'miedo':       {'emoji': '💀', 'color': Color(0xFFa55f5f)},
  'romantico':   {'emoji': '❤️', 'color': Color(0xFFa55f7a)},
  'clasico':     {'emoji': '🏛',  'color': Color(0xFF4a7fa5)},
  'museos':      {'emoji': '🎨', 'color': Color(0xFF7a5fa5)},
  'misterio':    {'emoji': '🔮', 'color': Color(0xFF5f7aa5)},
  'arte':        {'emoji': '✏️', 'color': Color(0xFF5fa57a)},
  'musica':      {'emoji': '🎵', 'color': Color(0xFFa5955f)},
  'guerrafria':  {'emoji': '🧱', 'color': Color(0xFF8a7a5f)},
};

Color tourColor(String tipo) {
  for (final key in kTourMeta.keys) {
    if (tipo.contains(key)) return kTourMeta[key]!['color'] as Color;
  }
  return kGold;
}

String tourEmoji(String tipo) {
  for (final key in kTourMeta.keys) {
    if (tipo.contains(key)) return kTourMeta[key]!['emoji'] as String;
  }
  return '🗺';
}

// ── MODELOS ───────────────────────────────────────────────────
class TourStop {
  final String tourId, lugar;
  final int paradaNum;
  final double lat, lng;
  final String textoES, textoEN, textoDE, textoIT;
  final String audioES, audioEN;

  const TourStop({
    required this.tourId,
    required this.lugar,
    required this.paradaNum,
    required this.lat,
    required this.lng,
    required this.textoES,
    required this.textoEN,
    required this.textoDE,
    required this.textoIT,
    required this.audioES,
    required this.audioEN,
  });

  String texto(String lang) {
    switch (lang) {
      case 'en': return textoEN.isNotEmpty ? textoEN : textoES;
      case 'de': return textoDE.isNotEmpty ? textoDE : textoES;
      case 'it': return textoIT.isNotEmpty ? textoIT : textoES;
      default:   return textoES;
    }
  }

  String audio(String lang) => lang == 'en' ? audioEN : audioES;

  bool get isIntro => paradaNum == 0;
}

class Tour {
  final String id, ciudad, nombre, tipo;
  final List<TourStop> stops;

  const Tour({
    required this.id,
    required this.ciudad,
    required this.nombre,
    required this.tipo,
    required this.stops,
  });

  List<TourStop> get contentStops =>
      stops.where((s) => !s.isIntro).toList();

  TourStop? get introStop =>
      stops.where((s) => s.isIntro).isNotEmpty
          ? stops.firstWhere((s) => s.isIntro)
          : null;

  int get numParadas => contentStops.length;

  // Nombre traducido usando kTourNames de sorpresa.dart
  String nombreTraducido(String lang) => tourName(tipo, lang);

  String introText(String lang) {
    final intro = introStop;
    if (intro == null) return '';
    final text = intro.texto(lang);
    final paragraphs = text.split('\n\n').where((p) => p.trim().isNotEmpty).toList();
    return paragraphs.length > 1 ? paragraphs[1].trim() : paragraphs[0].trim();
  }

  int get duracionMinutos {
    final cs = contentStops;
    if (cs.isEmpty) return 0;
    double totalDist = 0;
    for (int i = 0; i < cs.length - 1; i++) {
      totalDist += _haversine(cs[i].lat, cs[i].lng, cs[i+1].lat, cs[i+1].lng);
    }
    final walkMin = (totalDist / 1000 / 4 * 60).round();
    final audioMin = cs.length * 5;
    return walkMin + audioMin;
  }

  String duracionLabel(String lang) {
    final m = duracionMinutos;
    if (m < 60) return '~$m ${tt(lang, 'min')}';
    final h = m ~/ 60;
    final rem = m % 60;
    if (rem == 0) return '~${h}h';
    return '~${h}h ${rem}${tt(lang, 'min')}';
  }

  double get distanciaKm {
    final cs = contentStops;
    if (cs.length < 2) return 0;
    double total = 0;
    for (int i = 0; i < cs.length - 1; i++) {
      total += _haversine(cs[i].lat, cs[i].lng, cs[i+1].lat, cs[i+1].lng);
    }
    return double.parse((total / 1000).toStringAsFixed(1));
  }
}

// ── FETCH DESDE GOOGLE SHEETS ─────────────────────────────────
// Columnas: tour_id(0) ciudad(1) tour_nombre(2) tour_tipo(3) parada_num(4)
//           lugar(5) lat(6) lng(7) texto_ES(8) texto_EN(9) texto_DE(10) texto_IT(11)
//           audio_ES(12) audio_EN(13) fish_voice_ES(14) fish_voice_EN(15)
const kSheetId = '1K1iMpmKiYMC3A05V9byG1duokRJK-2eYMQKti_wc2Fg';

Future<List<Tour>> fetchTours(String ciudad) async {
  final url =
      'https://docs.google.com/spreadsheets/d/$kSheetId/gviz/tq?tqx=out:json&sheet=Tours_Tematicos';
  final res = await http.get(Uri.parse(url));
  if (res.statusCode != 200) throw Exception('Error al cargar tours');

  String body = res.body;
  final start = body.indexOf('{');
  final end = body.lastIndexOf('}');
  if (start == -1 || end == -1) throw Exception('Formato inesperado');
  body = body.substring(start, end + 1);
  final data = json.decode(body);
  final rows = data['table']['rows'] as List;

  final Map<String, List<TourStop>> stopsMap = {};
  final Map<String, Map<String, String>> tourMeta = {};

  for (final row in rows) {
    final cells = row['c'] as List;
    String cell(int i) {
      if (i >= cells.length || cells[i] == null) return '';
      final v = cells[i]['v'];
      return v == null ? '' : v.toString().trim();
    }

    if (cells.isEmpty || cell(0).isEmpty) continue;
    if (cell(1) != ciudad) continue;

    final tourTipo = cell(3);
    final tourId = cell(2); // usamos nombre ES como key interna

    if (!tourMeta.containsKey(tourId)) {
      tourMeta[tourId] = {'nombre': cell(2), 'tipo': tourTipo};
      stopsMap[tourId] = [];
    }

    try {
      stopsMap[tourId]!.add(TourStop(
        tourId:    cell(0),
        lugar:     cell(5),
        paradaNum: int.tryParse(cell(4)) ?? 0,
        lat:       double.tryParse(cell(6)) ?? 0.0,
        lng:       double.tryParse(cell(7)) ?? 0.0,
        textoES:   cell(8),
        textoEN:   cell(9),
        textoDE:   cell(10),
        textoIT:   cell(11),
        audioES:   cell(12),
        audioEN:   cell(13),
      ));
    } catch (_) {
      continue;
    }
  }

  final tours = stopsMap.entries.map((e) {
    final meta = tourMeta[e.key]!;
    final stops = e.value..sort((a, b) => a.paradaNum.compareTo(b.paradaNum));
    return Tour(
      id:     e.key,
      ciudad: ciudad,
      nombre: meta['nombre']!,
      tipo:   meta['tipo']!,
      stops:  stops,
    );
  }).toList();

  const order = ['miedo', 'romantico', 'clasico', 'museos', 'misterio', 'arte', 'musica', 'guerrafria'];
  tours.sort((a, b) {
    int rank(String tipo) {
      for (int i = 0; i < order.length; i++) {
        if (tipo.contains(order[i])) return i;
      }
      return 99;
    }
    final ai = rank(a.tipo);
    final bi = rank(b.tipo);
    if (ai == bi) return a.nombre.compareTo(b.nombre);
    return ai.compareTo(bi);
  });

  return tours;
}

// ── HELPER ────────────────────────────────────────────────────
String _fmtTime(Duration d) {
  final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
  final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$m:$s';
}

double _haversine(double lat1, double lng1, double lat2, double lng2) {
  const R = 6371000.0;
  final dLat = (lat2 - lat1) * math.pi / 180;
  final dLng = (lng2 - lng1) * math.pi / 180;
  final a = math.pow(math.sin(dLat / 2), 2) +
      math.cos(lat1 * math.pi / 180) *
          math.cos(lat2 * math.pi / 180) *
          math.pow(math.sin(dLng / 2), 2);
  return R * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
}

// ── TOURS LIST SCREEN ─────────────────────────────────────────
class ToursScreen extends StatefulWidget {
  final String lang;
  const ToursScreen({super.key, required this.lang});

  @override
  State<ToursScreen> createState() => _ToursScreenState();
}

class _ToursScreenState extends State<ToursScreen> {
  late String _lang;
  List<Tour> _tours = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _lang = widget.lang;
    _load();
  }

  Future<void> _load() async {
    try {
      final tours = await fetchTours('Berlin');
      setState(() { _tours = tours; _loading = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(child: Column(children: [
        // ── TOP BAR ──
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: kSurface,
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
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(tt(_lang, 'title'),
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: kText)),
              Text(tt(_lang, 'subtitle'),
                  style: const TextStyle(fontSize: 11, color: kMuted)),
            ])),
            langPill(_lang, (l) => setState(() => _lang = l)),
          ]),
        ),

        // ── CONTENIDO ──
        Expanded(child: _loading
            ? const Center(child: CircularProgressIndicator(color: kGold))
            : _error != null
            ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.wifi_off, color: kMuted, size: 48),
          const SizedBox(height: 12),
          Text(tt(_lang, 'error_load'),
              style: const TextStyle(color: kText)),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () { setState(() { _loading = true; _error = null; }); _load(); },
            child: Text(tt(_lang, 'retry'),
                style: const TextStyle(color: kGold)),
          ),
        ]))
            : _tours.isEmpty
            ? Center(child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Text('🗺', style: TextStyle(fontSize: 52)),
                  const SizedBox(height: 20),
                  Text(tt(_lang, 'empty_title'),
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: kGold)),
                  const SizedBox(height: 10),
                  Text(tt(_lang, 'empty_sub'),
                      style: const TextStyle(fontSize: 13, color: kMuted, height: 1.6),
                      textAlign: TextAlign.center),
                ]),
              ))
            : ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          itemCount: _tours.length,
          itemBuilder: (ctx, i) => _TourCard(
            tour: _tours[i],
            lang: _lang,
          ),
        )),
      ])),
    );
  }
}

// ── TOUR CARD ─────────────────────────────────────────────────
class _TourCard extends StatefulWidget {
  final Tour tour;
  final String lang;
  const _TourCard({required this.tour, required this.lang});

  @override
  State<_TourCard> createState() => _TourCardState();
}

class _TourCardState extends State<_TourCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final t = widget.tour;
    final c = tourColor(t.tipo);
    final emoji = tourEmoji(t.tipo);
    final resumen = t.introText(widget.lang);

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(
          builder: (_) => TourPlayerScreen(tour: t, lang: widget.lang))),
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: _pressed ? kSurface2 : kSurface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _pressed ? c : kBorder),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // ── CABECERA ──
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                    color: c.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: c.withOpacity(0.4))),
                child: Center(child: Text(emoji, style: const TextStyle(fontSize: 20))),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // ← Nombre traducido al idioma activo
                Text(t.nombreTraducido(widget.lang),
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600, color: kText)),
                const SizedBox(height: 5),
                Wrap(spacing: 6, children: [
                  _MetaPill(
                    icon: Icons.place_outlined,
                    label: '${t.numParadas} ${tt(widget.lang, 'stops')}',
                    color: c,
                  ),
                  _MetaPill(
                    icon: Icons.schedule_outlined,
                    label: t.duracionLabel(widget.lang),
                    color: c,
                  ),
                  _MetaPill(
                    icon: Icons.directions_walk,
                    label: '${t.distanciaKm} ${tt(widget.lang, 'km')}',
                    color: c,
                  ),
                ]),
              ])),
              Icon(Icons.chevron_right, color: c, size: 20),
            ]),
          ),

          // ── RESUMEN (texto intro en idioma activo) ──
          if (resumen.isNotEmpty) ...[
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: c.withOpacity(0.06),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: c.withOpacity(0.15)),
              ),
              child: Text(
                resumen,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: kMuted, height: 1.55),
              ),
            ),
          ],
        ]),
      ),
    );
  }
}

// ── META PILL ─────────────────────────────────────────────────
class _MetaPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _MetaPill({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 10, color: color.withOpacity(0.8)),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 10, color: color.withOpacity(0.9),
            fontWeight: FontWeight.w500)),
      ]),
    );
  }
}

// ── TOUR PLAYER SCREEN ────────────────────────────────────────
class TourPlayerScreen extends StatefulWidget {
  final Tour tour;
  final String lang;
  const TourPlayerScreen({super.key, required this.tour, required this.lang});

  @override
  State<TourPlayerScreen> createState() => _TourPlayerScreenState();
}

class _TourPlayerScreenState extends State<TourPlayerScreen> {
  late String _lang;
  int _idx = 0;

  late AudioPlayer _player;
  bool _playing = false;
  bool _audioAvailable = true;
  Duration _pos = Duration.zero, _dur = Duration.zero;

  StreamSubscription<Position>? _geoSub;
  double? _userLat, _userLng;
  bool _nearStop = false;
  static const _proximityRadius = 30.0;

  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _lang = widget.lang;
    _player = AudioPlayer();
    _player.positionStream.listen((p) { if (mounted) setState(() => _pos = p); });
    _player.durationStream.listen((d) {
      if (mounted) setState(() => _dur = d ?? Duration.zero);
    });
    _player.playerStateStream.listen((s) {
      if (mounted) setState(() => _playing = s.playing);
      if (s.processingState == ProcessingState.completed) {
        if (mounted) setState(() { _playing = false; _pos = Duration.zero; });
        _player.seek(Duration.zero);
        _player.pause();
      }
    });
    _loadAudio();
    _startGeo();
  }

  @override
  void dispose() {
    _player.dispose();
    _geoSub?.cancel();
    super.dispose();
  }

  List<TourStop> get _cs => widget.tour.contentStops;
  TourStop get _currentStop => _cs[_idx];
  bool get _isLast => _idx == _cs.length - 1;
  Color get _color => tourColor(widget.tour.tipo);

  Future<void> _loadAudio() async {
    final url = _currentStop.audio(_lang);
    if (url.isEmpty) {
      setState(() => _audioAvailable = false);
      return;
    }
    try {
      await _player.stop();
      setState(() {
        _pos = Duration.zero;
        _dur = Duration.zero;
        _playing = false;
        _audioAvailable = true;
      });
      await _player.setUrl(url);
    } catch (_) {
      if (mounted) setState(() => _audioAvailable = false);
    }
  }

  Future<void> _togglePlay() async {
    if (!_audioAvailable) return;
    if (_playing) await _player.pause(); else await _player.play();
  }

  void _nextStop() {
    if (_isLast) return;
    setState(() { _idx++; _nearStop = false; });
    _player.stop();
    _loadAudio();
    _mapController.move(LatLng(_currentStop.lat, _currentStop.lng), 15);
  }

  Future<void> _startGeo() async {
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.deniedForever) return;
      _geoSub = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high, distanceFilter: 5),
      ).listen((pos) {
        setState(() { _userLat = pos.latitude; _userLng = pos.longitude; });
        _checkProximity();
      });
    } catch (_) {}
  }

  void _checkProximity() {
    if (_userLat == null || _userLng == null) return;
    final stop = _currentStop;
    final dist = _haversine(_userLat!, _userLng!, stop.lat, stop.lng);
    if (dist <= _proximityRadius && !_nearStop) setState(() => _nearStop = true);
  }

  Widget _buildMap() {
    final stop = _currentStop;
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: LatLng(stop.lat, stop.lng),
        initialZoom: 14,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.citylore.app',
        ),
        MarkerLayer(markers: [
          ..._cs.asMap().entries.map((e) {
            final s = e.value;
            final isCurrent = e.key == _idx;
            final isDone = e.key < _idx;
            final c = _color;
            return Marker(
              point: LatLng(s.lat, s.lng),
              width: isCurrent ? 44 : 32,
              height: isCurrent ? 44 : 32,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color: isCurrent ? c : (isDone ? c.withOpacity(0.4) : kSurface),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isCurrent ? c : (isDone ? c.withOpacity(0.6) : kBorder),
                    width: isCurrent ? 2.5 : 1.5,
                  ),
                ),
                child: Center(
                  child: Text('${e.key + 1}',
                      style: TextStyle(
                          fontSize: isCurrent ? 14 : 10,
                          fontWeight: FontWeight.bold,
                          color: isCurrent ? Colors.black : (isDone ? c : kMuted))),
                ),
              ),
            );
          }),
          if (_userLat != null)
            Marker(
              point: LatLng(_userLat!, _userLng!),
              width: 20, height: 20,
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2)),
              ),
            ),
        ]),
      ],
    );
  }

  Widget _buildPlayer() {
    final progress = _dur.inMilliseconds > 0
        ? (_pos.inMilliseconds / _dur.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;
    final c = _color;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: kSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kBorder)),
      child: Row(children: [
        GestureDetector(
          onTap: _audioAvailable ? _togglePlay : null,
          child: Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
                color: _audioAvailable ? c : kSurface2,
                shape: BoxShape.circle,
                border: _audioAvailable ? null : Border.all(color: kBorder)),
            child: Icon(
              _playing ? Icons.pause : Icons.play_arrow,
              color: _audioAvailable ? Colors.black : kMuted,
              size: 22,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: _audioAvailable
            ? Column(children: [
          SliderTheme(
            data: SliderThemeData(
                trackHeight: 3,
                activeTrackColor: c,
                inactiveTrackColor: kSurface2,
                thumbColor: c),
            child: Slider(
              value: progress,
              onChanged: (v) {
                if (_dur == Duration.zero) return;
                _player.seek(Duration(
                    milliseconds: (_dur.inMilliseconds * v).round()));
              },
            ),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(_fmtTime(_pos),
                style: const TextStyle(fontSize: 11, color: kMuted)),
            Text(_fmtTime(_dur),
                style: const TextStyle(fontSize: 11, color: kMuted)),
          ]),
        ])
            : Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(children: [
            const SizedBox(width: 4),
            Expanded(child: Container(height: 3,
                decoration: const BoxDecoration(color: kSurface2,
                    borderRadius: BorderRadius.all(Radius.circular(2))))),
          ]),
        )),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stop = _currentStop;
    final c = _color;
    final emoji = tourEmoji(widget.tour.tipo);
    final total = _cs.length;

    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(child: Column(children: [

        // ── TOP BAR ──
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: kSurface,
          child: Row(children: [
            GestureDetector(
              onTap: () { _player.stop(); Navigator.pop(context); },
              child: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                      border: Border.all(color: kBorder),
                      borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.arrow_back, color: kText, size: 18)),
            ),
            const SizedBox(width: 8),
            // Badge con nombre traducido del tour
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: c.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: c)),
                child: Text(
                  '$emoji ${widget.tour.nombreTraducido(_lang)}',
                  style: TextStyle(
                      fontSize: 10, color: c,
                      letterSpacing: 1, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            const SizedBox(width: 8),
            langPill(_lang, (l) {
              setState(() => _lang = l);
              _loadAudio();
            }),
          ]),
        ),

        // ── MAPA ──
        SizedBox(height: 200, child: _buildMap()),

        // ── BARRA DE PROGRESO ──
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Row(children: List.generate(total, (i) {
            final dotColor = i < _idx ? c : (i == _idx ? c : kBorder);
            return Expanded(
              child: Container(
                height: 3,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                    color: dotColor, borderRadius: BorderRadius.circular(2)),
              ),
            );
          })),
        ),

        // ── CONTENIDO ──
        Expanded(child: SingleChildScrollView(child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),

            // Parada N / Total + distancia GPS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                      color: c.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: c.withOpacity(0.4))),
                  child: Text(
                      '${tt(_lang, 'stop')} ${_idx + 1} / $total',
                      style: TextStyle(fontSize: 10, color: c,
                          fontWeight: FontWeight.w600, letterSpacing: 1)),
                ),
                const Spacer(),
                if (_userLat != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                        color: kSurface2,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: kBorder)),
                    child: Text(
                        '${_haversine(_userLat!, _userLng!, stop.lat, stop.lng).round()}m',
                        style: const TextStyle(fontSize: 11, color: kMuted)),
                  ),
              ]),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(stop.lugar,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold, color: kText)),
            ),
            const SizedBox(height: 12),

            // ── INTRO DEL TOUR (solo en parada 1) ──
            if (_idx == 0 && widget.tour.introStop != null) ...[
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: c.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: c.withOpacity(0.25))),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Text(tourEmoji(widget.tour.tipo),
                        style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.tour.nombreTraducido(_lang).toUpperCase(),
                        style: TextStyle(
                            fontSize: 10, color: c,
                            letterSpacing: 1.5, fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ]),
                  const SizedBox(height: 10),
                  Text(
                    widget.tour.introStop!.texto(_lang),
                    style: const TextStyle(
                        fontSize: 13, color: Color(0xFFc8c4bc), height: 1.75),
                  ),
                ]),
              ),
              const SizedBox(height: 12),
            ],

            // ── REPRODUCTOR ──
            _buildPlayer(),
            const SizedBox(height: 12),

            // ── TEXTO DE LA PARADA ──
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: kSurface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: kBorder)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Container(width: 4, height: 16,
                      decoration: BoxDecoration(
                          color: c, borderRadius: BorderRadius.circular(2))),
                  const SizedBox(width: 8),
                  Text(stop.lugar.toUpperCase(),
                      style: TextStyle(
                          fontSize: 10, color: c,
                          letterSpacing: 2, fontWeight: FontWeight.w600)),
                ]),
                const SizedBox(height: 12),
                Text(stop.texto(_lang),
                    style: const TextStyle(
                        fontSize: 14, color: Color(0xFFc8c4bc), height: 1.8)),
              ]),
            ),
            const SizedBox(height: 12),

            // ── GPS / SIGUIENTE ──
            if (!_isLast) ...[
              if (_userLat != null) Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: _nearStop ? c.withOpacity(0.1) : kSurface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _nearStop ? c : kBorder)),
                  child: Row(children: [
                    Icon(_nearStop ? Icons.location_on : Icons.navigation,
                        color: _nearStop ? c : kMuted, size: 16),
                    const SizedBox(width: 8),
                    Expanded(child: Text(
                      _nearStop
                          ? tt(_lang, 'near_stop')
                          : '${tt(_lang, 'walk_to')} ${_cs[_idx + 1].lugar}',
                      style: TextStyle(
                          fontSize: 12, color: _nearStop ? c : kMuted),
                    )),
                    if (_nearStop) GestureDetector(
                      onTap: _nextStop,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                            color: c, borderRadius: BorderRadius.circular(8)),
                        child: Text(tt(_lang, 'next'),
                            style: const TextStyle(
                                fontSize: 12, color: Colors.black,
                                fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ]),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GestureDetector(
                  onTap: _nextStop,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                        color: kSurface2,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: kBorder)),
                    child: Center(child: Text(tt(_lang, 'next_stop'),
                        style: const TextStyle(fontSize: 13, color: kMuted))),
                  ),
                ),
              ),
            ],

            // ── FIN DEL TOUR ──
            if (_isLast) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      color: c.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: c)),
                  child: Column(children: [
                    Text(emoji, style: const TextStyle(fontSize: 32)),
                    const SizedBox(height: 8),
                    Text(tt(_lang, 'end_title'),
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold, color: c)),
                    const SizedBox(height: 4),
                    Text(tt(_lang, 'end_sub'),
                        style: const TextStyle(fontSize: 13, color: kMuted)),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: () {
                        _player.stop();
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 10),
                        decoration: BoxDecoration(
                            color: c, borderRadius: BorderRadius.circular(10)),
                        child: Text(tt(_lang, 'back_home'),
                            style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ]),
                ),
              ),
            ],

            const SizedBox(height: 24),
          ],
        ))),
      ])),
    );
  }
}