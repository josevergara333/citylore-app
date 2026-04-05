import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async';
import 'widgets.dart';

// ── TRADUCCIONES MODO SORPRESA ────────────────────────────────
const kTS = {
  'es': {
    'title':          '✨ Modo Sorpréndeme',
    'choose_guide':   'Elige tu guía',
    'subtitle':       'Berlín vista a través de ojos únicos.',
    'soon':           'Pronto',
    'start':          'Comenzar la experiencia →',
    'mode_label':     '✨ MODO SORPRESA',
    'clue':           '🔍 PISTA',
    'branch_label':   '⚡ BIFURCACIÓN',
    'who_is_lena':    '¿Quién es tu Lena?',
    'branch_a_title': 'La que escapó',
    'branch_a_desc':  'Parte con Heinrich a París',
    'branch_b_title': 'La que se quedó',
    'branch_b_desc':  'Se queda en Berlín',
    'near_stop':      '¡Estás en el lugar!',
    'walk_to':        'Camina hacia',
    'next':           'Siguiente →',
    'next_stop':      'Siguiente parada →',
    'end_title':      'Fin de la historia',
    'end_sub':        'Gracias por caminar con Lena.',
    'back_home':      'Volver al inicio',
    'your_location':  'Tu ubicación',
  },
  'en': {
    'title':          '✨ Surprise Me',
    'choose_guide':   'Choose your guide',
    'subtitle':       'Berlin seen through unique eyes.',
    'soon':           'Soon',
    'start':          'Begin the experience →',
    'mode_label':     '✨ SURPRISE MODE',
    'clue':           '🔍 CLUE',
    'branch_label':   '⚡ CROSSROADS',
    'who_is_lena':    'Who is your Lena?',
    'branch_a_title': 'The one who escaped',
    'branch_a_desc':  'Leaves with Heinrich to Paris',
    'branch_b_title': 'The one who stayed',
    'branch_b_desc':  'Stays in Berlin',
    'near_stop':      'You are here!',
    'walk_to':        'Walk to',
    'next':           'Next →',
    'next_stop':      'Next stop →',
    'end_title':      'End of the story',
    'end_sub':        'Thank you for walking with Lena.',
    'back_home':      'Back to home',
    'your_location':  'Your location',
  },
  'de': {
    'title':          '✨ Überrasch mich',
    'choose_guide':   'Wähle deinen Guide',
    'subtitle':       'Berlin durch einzigartige Augen gesehen.',
    'soon':           'Bald',
    'start':          'Erlebnis beginnen →',
    'mode_label':     '✨ ÜBERRASCHUNGS-MODUS',
    'clue':           '🔍 HINWEIS',
    'branch_label':   '⚡ WEGSCHEIDE',
    'who_is_lena':    'Wer ist deine Lena?',
    'branch_a_title': 'Die, die floh',
    'branch_a_desc':  'Reist mit Heinrich nach Paris',
    'branch_b_title': 'Die, die blieb',
    'branch_b_desc':  'Bleibt in Berlin',
    'near_stop':      'Du bist hier!',
    'walk_to':        'Geh zu',
    'next':           'Weiter →',
    'next_stop':      'Nächste Station →',
    'end_title':      'Ende der Geschichte',
    'end_sub':        'Danke, dass du mit Lena gelaufen bist.',
    'back_home':      'Zurück zum Start',
    'your_location':  'Dein Standort',
  },
  'it': {
    'title':          '✨ Sorprendimi',
    'choose_guide':   'Scegli la tua guida',
    'subtitle':       'Berlino vista attraverso occhi unici.',
    'soon':           'Presto',
    'start':          'Inizia l\'esperienza →',
    'mode_label':     '✨ MODALITÀ SORPRESA',
    'clue':           '🔍 INDIZIO',
    'branch_label':   '⚡ BIVIO',
    'who_is_lena':    'Chi è la tua Lena?',
    'branch_a_title': 'Quella che fuggì',
    'branch_a_desc':  'Parte con Heinrich verso Parigi',
    'branch_b_title': 'Quella che rimase',
    'branch_b_desc':  'Rimane a Berlino',
    'near_stop':      'Sei qui!',
    'walk_to':        'Cammina verso',
    'next':           'Avanti →',
    'next_stop':      'Prossima tappa →',
    'end_title':      'Fine della storia',
    'end_sub':        'Grazie per aver camminato con Lena.',
    'back_home':      'Torna all\'inizio',
    'your_location':  'La tua posizione',
  },
};

String ts(String lang, String key) =>
    kTS[lang]?[key] ?? kTS['es']![key] ?? key;

// ── MODELO SORPRESA ──────────────────────────────────────────
class SorpresaStop {
  final String id, branch, lugar;
  final double lat, lng;

  const SorpresaStop({
    required this.id,
    required this.branch,
    required this.lugar,
    required this.lat,
    required this.lng,
  });
}

class SorpresaPersonaje {
  final String id, name, emoji, desc, r2Base;
  final List<SorpresaStop> stops;

  const SorpresaPersonaje({
    required this.id,
    required this.name,
    required this.emoji,
    required this.desc,
    required this.r2Base,
    required this.stops,
  });
}

// ── DATOS LENA HOFFMANN (v2 — xlsx v9) ───────────────────────
// Ruta: 6 paradas shared → bifurcación → 3 paradas A o B
// Rama A: Memorial del Holocausto → Puerta de Brandenburgo → Columna de la Victoria
// Rama B: Lustgarten → Neues Museum (Nefertiti) → Pergamon Panorama
const kLena = SorpresaPersonaje(
  id: 'lena',
  name: 'Lena Hoffmann',
  emoji: '💃',
  desc: 'La bailarina del cabaret · Berlín 1925–1933',
  r2Base: 'https://pub-b20ae9c7d6c140aa868ea5aba6210b5f.r2.dev/audios/sorpresa/berlin/lena/v2/',
  stops: [
    // ── SHARED (paradas 1–6) ──────────────────────────────
    SorpresaStop(id: 'lena_01', branch: 'shared', lugar: 'Nueva Sinagoga',       lat: 52.5249, lng: 13.3942),
    SorpresaStop(id: 'lena_02', branch: 'shared', lugar: 'Monbijoupark',         lat: 52.5231, lng: 13.3963),
    SorpresaStop(id: 'lena_03', branch: 'shared', lugar: 'Bode Museum',          lat: 52.5219, lng: 13.3944),
    SorpresaStop(id: 'lena_04', branch: 'shared', lugar: 'Berliner Dom',         lat: 52.5190, lng: 13.4011),
    SorpresaStop(id: 'lena_05', branch: 'shared', lugar: 'Staatsoper / Bebelplatz', lat: 52.5171, lng: 13.3947),
    SorpresaStop(id: 'lena_06', branch: 'shared', lugar: 'Neue Wache',           lat: 52.5179, lng: 13.3955),
    // ── RAMA A ───────────────────────────────────────────
    SorpresaStop(id: 'lena_07a', branch: 'A', lugar: 'Memorial del Holocausto', lat: 52.5139, lng: 13.3787),
    SorpresaStop(id: 'lena_08a', branch: 'A', lugar: 'Puerta de Brandenburgo',  lat: 52.5163, lng: 13.3777),
    SorpresaStop(id: 'lena_09a', branch: 'A', lugar: 'Columna de la Victoria',  lat: 52.5145, lng: 13.3501),
    // ── RAMA B ───────────────────────────────────────────
    SorpresaStop(id: 'lena_07b', branch: 'B', lugar: 'Lustgarten',              lat: 52.5187, lng: 13.3992),
    SorpresaStop(id: 'lena_08b', branch: 'B', lugar: 'Neues Museum (Nefertiti)', lat: 52.5201, lng: 13.3976),
    SorpresaStop(id: 'lena_09b', branch: 'B', lugar: 'Pergamon Panorama',       lat: 52.5209, lng: 13.3940),
  ],
);

// ── HELPERS ───────────────────────────────────────────────────
String _fmtTime(Duration d) {
  final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
  final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$m:$s';
}

double _haversine(double lat1, double lng1, double lat2, double lng2) {
  const R = 6371000.0;
  final dLat = (lat2 - lat1) * 3.14159265358979 / 180;
  final dLng = (lng2 - lng1) * 3.14159265358979 / 180;
  final a = (dLat / 2) * (dLat / 2) +
      (lat1 * 3.14159265358979 / 180).abs() *
          (lat2 * 3.14159265358979 / 180).abs() *
          (dLng / 2) *
          (dLng / 2);
  return R * 2 * (a < 1 ? a : 1);
}

// ── SELECTOR DE PERSONAJE ─────────────────────────────────────
class SorpresaScreen extends StatefulWidget {
  final String lang;
  const SorpresaScreen({super.key, required this.lang});
  @override
  State<SorpresaScreen> createState() => _SorpresaScreenState();
}

class _SorpresaScreenState extends State<SorpresaScreen> {
  late String _lang;
  bool _selected = false;

  @override
  void initState() {
    super.initState();
    _lang = widget.lang;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(child: Column(children: [
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
                  child: const Icon(Icons.arrow_back, color: kText, size: 18)),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(ts(_lang, 'title'),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: kText))),
            langPill(_lang, (l) => setState(() => _lang = l)),
          ]),
        ),
        Expanded(child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(children: [
            const SizedBox(height: 16),
            const Text('🎭', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 16),
            Text(ts(_lang, 'choose_guide'),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: kGold)),
            const SizedBox(height: 8),
            Text(ts(_lang, 'subtitle'),
                style: const TextStyle(fontSize: 14, color: kMuted), textAlign: TextAlign.center),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: () => setState(() => _selected = true),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity, padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                    color: _selected ? kGold.withOpacity(0.1) : kSurface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: _selected ? kGold : kBorder,
                        width: _selected ? 1.5 : 0.5)),
                child: Row(children: [
                  const Text('💃', style: TextStyle(fontSize: 28)),
                  const SizedBox(width: 14),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Lena Hoffmann',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: kText)),
                    const SizedBox(height: 2),
                    const Text('La bailarina del cabaret · Berlín 1925–1933',
                        style: TextStyle(fontSize: 12, color: kMuted)),
                  ])),
                  if (_selected) const Icon(Icons.check_circle, color: kGold, size: 20),
                ]),
              ),
            ),
            const SizedBox(height: 12),
            _comingSoonCard('🐕', 'Rex', 'Berlín 1936–1945'),
            const SizedBox(height: 12),
            _comingSoonCard('🕵️', 'Klaus Brenner', 'Berlín 1975'),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: _selected
                  ? () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => SorpresaPlayerScreen(personaje: kLena, lang: _lang)))
                  : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                    gradient: _selected
                        ? const LinearGradient(colors: [kGold, kGoldLight])
                        : null,
                    color: _selected ? null : kSurface2,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _selected ? kGold : kBorder)),
                child: Center(child: Text(ts(_lang, 'start'),
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _selected ? Colors.black : kMuted))),
              ),
            ),
          ]),
        )),
      ])),
    );
  }

  Widget _comingSoonCard(String emoji, String name, String desc) {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: kSurface, borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kBorder)),
      child: Row(children: [
        Text(emoji, style: const TextStyle(fontSize: 28, color: kMuted)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: kMuted)),
          Text(desc, style: const TextStyle(fontSize: 12, color: kMuted)),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(color: kSurface2, borderRadius: BorderRadius.circular(6),
              border: Border.all(color: kBorder)),
          child: Text(ts(_lang, 'soon'), style: const TextStyle(fontSize: 10, color: kMuted)),
        ),
      ]),
    );
  }
}

// ── PLAYER SORPRESA ───────────────────────────────────────────
class SorpresaPlayerScreen extends StatefulWidget {
  final SorpresaPersonaje personaje;
  final String lang;
  const SorpresaPlayerScreen({super.key, required this.personaje, required this.lang});
  @override
  State<SorpresaPlayerScreen> createState() => _SorpresaPlayerScreenState();
}

class _SorpresaPlayerScreenState extends State<SorpresaPlayerScreen> {
  late String _lang;

  // Ruta activa: starts con solo las 6 shared; se expande al elegir rama
  late List<SorpresaStop> _route;
  int _idx = 0;

  // true cuando el usuario ya eligió rama (para no mostrar bifurcación de nuevo)
  String? _chosenBranch;

  // true cuando estamos en el momento de bifurcación (justo después de parada 6)
  bool get _atBifurcation => _chosenBranch == null && _idx == _route.length - 1;

  late AudioPlayer _player;
  bool _playing = false;
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
    // Empezamos solo con las paradas shared
    _route = widget.personaje.stops.where((s) => s.branch == 'shared').toList();

    _player = AudioPlayer();
    _player.positionStream.listen((p) { if (mounted) setState(() => _pos = p); });
    _player.durationStream.listen((d) { if (mounted) setState(() => _dur = d ?? Duration.zero); });
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

  SorpresaStop get _currentStop => _route[_idx];

  // Construye la URL del audio según el id de la parada y el idioma
  String _audioUrl(SorpresaStop stop) {
    final langSuffix = (_lang == 'en') ? 'en' : 'es';
    return '${widget.personaje.r2Base}${stop.id}_$langSuffix.mp3';
  }

  Future<void> _loadAudio() async {
    final stop = _currentStop;
    try {
      await _player.stop();
      setState(() { _pos = Duration.zero; _dur = Duration.zero; _playing = false; });
      await _player.setUrl(_audioUrl(stop));
    } catch (_) {}
  }

  Future<void> _togglePlay() async {
    if (_playing) await _player.pause(); else await _player.play();
  }

  // El usuario elige rama A o B: añadimos esas paradas a la ruta
  void _chooseBranch(String branch) {
    final branchStops = widget.personaje.stops.where((s) => s.branch == branch).toList();
    setState(() {
      _chosenBranch = branch;
      _route = [..._route, ...branchStops];
      _idx++; // avanzamos a la primera parada de la rama elegida
      _nearStop = false;
    });
    _loadAudio();
    _centerMap();
  }

  void _nextStop() {
    if (_idx < _route.length - 1) {
      setState(() { _idx++; _nearStop = false; });
      _player.stop();
      _loadAudio();
      _centerMap();
    }
  }

  void _centerMap() {
    final stop = _currentStop;
    _mapController.move(LatLng(stop.lat, stop.lng), 15);
  }

  Future<void> _startGeo() async {
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) perm = await Geolocator.requestPermission();
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
    if (_userLat == null || _userLng == null || _atBifurcation) return;
    final stop = _currentStop;
    final dist = _haversine(_userLat!, _userLng!, stop.lat, stop.lng);
    if (dist <= _proximityRadius && !_nearStop) setState(() => _nearStop = true);
  }

  // ── MAPA ─────────────────────────────────────────────────
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
          ..._route.asMap().entries.map((e) {
            final s = e.value;
            final isCurrent = e.key == _idx;
            final isDone = e.key < _idx;
            return Marker(
              point: LatLng(s.lat, s.lng),
              width: isCurrent ? 44 : 32,
              height: isCurrent ? 44 : 32,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color: isCurrent ? kGold : (isDone ? kGold.withOpacity(0.4) : kSurface),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isCurrent
                        ? kGoldLight
                        : (isDone ? kGold.withOpacity(0.6) : kBorder),
                    width: isCurrent ? 2.5 : 1.5,
                  ),
                ),
                child: Center(
                  child: Text('${e.key + 1}',
                      style: TextStyle(
                          fontSize: isCurrent ? 14 : 10,
                          fontWeight: FontWeight.bold,
                          color: isCurrent
                              ? Colors.black
                              : (isDone ? kGold : kMuted))),
                ),
              ),
            );
          }).toList(),
          if (_userLat != null)
            Marker(
              point: LatLng(_userLat!, _userLng!),
              width: 20, height: 20,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
        ]),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final stop = _currentStop;
    final isBif = _atBifurcation;
    final progress = _dur.inMilliseconds > 0
        ? (_pos.inMilliseconds / _dur.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;
    final isLast = !isBif && _idx == _route.length - 1 && _chosenBranch != null;

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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                  color: kGold.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: kGold)),
              child: Text(ts(_lang, 'mode_label'),
                  style: const TextStyle(
                      fontSize: 10, color: kGold,
                      letterSpacing: 2, fontWeight: FontWeight.w600)),
            ),
            const Spacer(),
            langPill(_lang, (l) => setState(() { _lang = l; _loadAudio(); })),
          ]),
        ),

        // ── MAPA ──
        SizedBox(height: 220, child: _buildMap()),

        // ── BARRA DE PROGRESO ──
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Row(children: List.generate(_route.length, (i) {
            Color c = i < _idx ? kGold : (i == _idx ? kGoldLight : kBorder);
            return Expanded(
              child: Container(
                height: 3,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(2)),
              ),
            );
          })),
        ),

        // ── CONTENIDO ──
        Expanded(child: SingleChildScrollView(child: Column(children: [
          const SizedBox(height: 12),

          // Pista / label bifurcación
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color: kSurface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: isBif ? kGold : kBorder)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(width: 8, height: 8,
                    decoration: const BoxDecoration(color: kGold, shape: BoxShape.circle)),
                const SizedBox(width: 8),
                Text(isBif ? ts(_lang, 'branch_label') : ts(_lang, 'clue'),
                    style: const TextStyle(
                        fontSize: 10, color: kGold,
                        letterSpacing: 2, fontWeight: FontWeight.w600)),
              ]),
              const SizedBox(height: 8),
              Text(
                isBif
                    ? ts(_lang, 'who_is_lena')
                    : stop.lugar,
                style: const TextStyle(
                    fontSize: 14, color: kText,
                    fontStyle: FontStyle.italic, height: 1.5),
              ),
            ]),
          ),
          const SizedBox(height: 10),

          // Nombre del lugar + distancia GPS
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(children: [
              Text(stop.lugar,
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.bold, color: kText)),
              const Spacer(),
              if (_userLat != null && !isBif)
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
          const SizedBox(height: 10),

          // ── BIFURCACIÓN ──
          if (isBif) Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(children: [
              Expanded(child: GestureDetector(
                onTap: () => _chooseBranch('A'),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                      color: kSurface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: kBorder)),
                  child: Column(children: [
                    const Text('💨', style: TextStyle(fontSize: 24)),
                    const SizedBox(height: 6),
                    Text(ts(_lang, 'branch_a_title'),
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: kText),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 4),
                    Text(ts(_lang, 'branch_a_desc'),
                        style: const TextStyle(fontSize: 11, color: kMuted),
                        textAlign: TextAlign.center),
                  ]),
                ),
              )),
              const SizedBox(width: 10),
              Expanded(child: GestureDetector(
                onTap: () => _chooseBranch('B'),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                      color: kSurface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: kBorder)),
                  child: Column(children: [
                    const Text('🏠', style: TextStyle(fontSize: 24)),
                    const SizedBox(height: 6),
                    Text(ts(_lang, 'branch_b_title'),
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: kText),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 4),
                    Text(ts(_lang, 'branch_b_desc'),
                        style: const TextStyle(fontSize: 11, color: kMuted),
                        textAlign: TextAlign.center),
                  ]),
                ),
              )),
            ]),
          ),

          // ── REPRODUCTOR ──
          if (!isBif) ...[
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                  color: kSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: kBorder)),
              child: Row(children: [
                GestureDetector(
                  onTap: _togglePlay,
                  child: Container(
                      width: 48, height: 48,
                      decoration: const BoxDecoration(color: kGold, shape: BoxShape.circle),
                      child: Icon(_playing ? Icons.pause : Icons.play_arrow,
                          color: Colors.black, size: 22)),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(children: [
                  SliderTheme(
                    data: const SliderThemeData(
                        trackHeight: 3,
                        activeTrackColor: kGold,
                        inactiveTrackColor: kSurface2,
                        thumbColor: kGold),
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
                ])),
              ]),
            ),
          ],

          // ── GPS + SIGUIENTE (si no es bifurcación ni fin) ──
          if (!isBif && !isLast && _idx < _route.length - 1) ...[
            const SizedBox(height: 8),
            if (_userLat != null) Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: _nearStop ? kGold.withOpacity(0.1) : kSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _nearStop ? kGold : kBorder)),
                child: Row(children: [
                  Icon(_nearStop ? Icons.location_on : Icons.navigation,
                      color: _nearStop ? kGold : kMuted, size: 16),
                  const SizedBox(width: 8),
                  Expanded(child: Text(
                    _nearStop
                        ? ts(_lang, 'near_stop')
                        : '${ts(_lang, 'walk_to')} ${stop.lugar}',
                    style: TextStyle(
                        fontSize: 12,
                        color: _nearStop ? kGold : kMuted),
                  )),
                  if (_nearStop) GestureDetector(
                    onTap: _nextStop,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                          color: kGold, borderRadius: BorderRadius.circular(8)),
                      child: Text(ts(_lang, 'next'),
                          style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black,
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
                  child: Center(child: Text(ts(_lang, 'next_stop'),
                      style: const TextStyle(fontSize: 13, color: kMuted))),
                ),
              ),
            ),
          ],

          // ── FIN ──
          if (isLast) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                width: double.infinity, padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: kGold.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: kGold)),
                child: Column(children: [
                  const Text('✨', style: TextStyle(fontSize: 32)),
                  const SizedBox(height: 8),
                  Text(ts(_lang, 'end_title'),
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold, color: kGold)),
                  const SizedBox(height: 4),
                  Text(ts(_lang, 'end_sub'),
                      style: const TextStyle(fontSize: 13, color: kMuted)),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {
                      _player.stop();
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                      decoration: BoxDecoration(
                          color: kGold, borderRadius: BorderRadius.circular(10)),
                      child: Text(ts(_lang, 'back_home'),
                          style: const TextStyle(
                              color: Colors.black, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ]),
              ),
            ),
          ],

          const SizedBox(height: 24),
        ]))),
      ])),
    );
  }
}