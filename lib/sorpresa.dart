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
  final Map<String, String> hints;

  const SorpresaStop({
    required this.id, required this.branch, required this.lugar,
    required this.lat, required this.lng, required this.hints,
  });

  String hint(String lang) => hints[lang] ?? hints['es'] ?? '';
}

class SorpresaPersonaje {
  final String id, name, emoji, desc, r2Base;
  final List<SorpresaStop> stops;

  const SorpresaPersonaje({
    required this.id, required this.name, required this.emoji,
    required this.desc, required this.r2Base, required this.stops,
  });
}

// ── DATOS LENA HOFFMANN ──────────────────────────────────────
const kLena = SorpresaPersonaje(
  id: 'lena', name: 'Lena Hoffmann', emoji: '💃',
  desc: 'La bailarina del cabaret · Berlín 1925–1933',
  r2Base: 'https://pub-b20ae9c7d6c140aa868ea5aba6210b5f.r2.dev/audios/sorpresa/berlin/lena/',
  stops: [
    SorpresaStop(id:'lena_01', branch:'shared', lugar:'Introducción', lat:52.5200, lng:13.3880,
        hints:{'es':'Berlín, 1925. Escucha antes de comenzar a caminar.','en':'Berlin, 1925. Listen before you start walking.','de':'Berlin, 1925. Höre zu, bevor du anfängst zu laufen.','it':'Berlino, 1925. Ascolta prima di iniziare a camminare.'}),
    SorpresaStop(id:'lena_02', branch:'shared', lugar:'Friedrichstrasse', lat:52.5208, lng:13.3880,
        hints:{'es':'Empieza donde Berlín se vistió de gala por última vez.','en':'Start where Berlin last dressed up.','de':'Beginne dort, wo Berlin sich zum letzten Mal in Schale geworfen hat.','it':'Inizia dove Berlino si è vestita a festa per l\'ultima volta.'}),
    SorpresaStop(id:'lena_03', branch:'shared', lugar:'Gendarmenmarkt', lat:52.5135, lng:13.3927,
        hints:{'es':'Busca la plaza donde la eternidad se parece a un domingo.','en':'Find the square where eternity feels like a Sunday.','de':'Suche den Platz, wo die Ewigkeit sich wie ein Sonntag anfühlt.','it':'Trova la piazza dove l\'eternità sembra una domenica.'}),
    SorpresaStop(id:'lena_04', branch:'shared', lugar:'Hackesche Höfe', lat:52.5231, lng:13.4019,
        hints:{'es':'Entra al lugar donde un cerezo florece sin que nadie lo recuerde.','en':'Enter the place where a cherry tree blooms without anyone remembering it.','de':'Betritt den Ort, wo ein Kirschbaum blüht, ohne dass es jemand erinnert.','it':'Entra nel luogo dove un ciliegio fiorisce senza che nessuno lo ricordi.'}),
    SorpresaStop(id:'lena_05', branch:'shared', lugar:'Bebelplatz', lat:52.5138, lng:13.3939,
        hints:{'es':'Camina hasta la plaza donde los libros ardieron.','en':'Walk to the square where books burned.','de':'Geh zum Platz, wo die Bücher brannten.','it':'Cammina fino alla piazza dove bruciarono i libri.'}),
    SorpresaStop(id:'lena_05_bif', branch:'bifurcacion', lugar:'Puerta de Brandenburgo', lat:52.5163, lng:13.3777,
        hints:{'es':'Aquí la historia se divide. ¿Quién es tu Lena?','en':'Here the story divides. Who is your Lena?','de':'Hier teilt sich die Geschichte. Wer ist deine Lena?','it':'Qui la storia si divide. Chi è la tua Lena?'}),
    SorpresaStop(id:'lena_06', branch:'A', lugar:'Puerta de Brandenburgo', lat:52.5163, lng:13.3777,
        hints:{'es':'Ve a la Puerta. Mira la Cuadriga.','en':'Go to the Gate. Look at the Quadriga.','de':'Geh zum Tor. Schau dir die Quadriga an.','it':'Vai alla Porta. Guarda la Quadriga.'}),
    SorpresaStop(id:'lena_08', branch:'A', lugar:'Tiergarten', lat:52.5145, lng:13.3500,
        hints:{'es':'Entra al parque y siéntate bajo los árboles nuevos.','en':'Enter the park and sit under the new trees.','de':'Betritt den Park und setz dich unter die neuen Bäume.','it':'Entra nel parco e siediti sotto i nuovi alberi.'}),
    SorpresaStop(id:'lena_10', branch:'A', lugar:'Neue Wache', lat:52.5175, lng:13.3935,
        hints:{'es':'Busca el memorial donde llueve sobre el bronce.','en':'Find the memorial where rain falls on bronze.','de':'Finde das Mahnmal, wo Regen auf Bronze fällt.','it':'Trova il memoriale dove piove sul bronzo.'}),
    SorpresaStop(id:'lena_12', branch:'A', lugar:'Isla de los Museos', lat:52.5196, lng:13.3986,
        hints:{'es':'Siéntate frente a quien ha sobrevivido tres mil años.','en':'Sit before one who has survived three thousand years.','de':'Setz dich vor jemanden, der dreitausend Jahre überlebt hat.','it':'Siediti di fronte a chi ha sopravvissuto tremila anni.'}),
    SorpresaStop(id:'lena_07', branch:'B', lugar:'Puerta de Brandenburgo', lat:52.5163, lng:13.3777,
        hints:{'es':'Ve a la Puerta. Quédate sola un momento.','en':'Go to the Gate. Stay alone for a moment.','de':'Geh zum Tor. Bleib einen Moment allein.','it':'Vai alla Porta. Resta sola un momento.'}),
    SorpresaStop(id:'lena_09', branch:'B', lugar:'Tiergarten', lat:52.5145, lng:13.3500,
        hints:{'es':'Entra al parque. Recuerda los árboles viejos.','en':'Enter the park. Remember the old trees.','de':'Betritt den Park. Erinnere dich an die alten Bäume.','it':'Entra nel parco. Ricorda i vecchi alberi.'}),
    SorpresaStop(id:'lena_11', branch:'B', lugar:'Neue Wache', lat:52.5175, lng:13.3935,
        hints:{'es':'Busca el memorial donde llueve sobre el bronce.','en':'Find the memorial where rain falls on bronze.','de':'Finde das Mahnmal, wo Regen auf Bronze fällt.','it':'Trova il memoriale dove piove sul bronzo.'}),
    SorpresaStop(id:'lena_13', branch:'B', lugar:'Isla de los Museos', lat:52.5196, lng:13.3986,
        hints:{'es':'Siéntate frente a quien ha sobrevivido tres mil años.','en':'Sit before one who has survived three thousand years.','de':'Setz dich vor jemanden, der dreitausend Jahre überlebt hat.','it':'Siediti di fronte a chi ha sopravvissuto tremila anni.'}),
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
          (dLng / 2) * (dLng / 2);
  return R * 2 * (a < 1 ? a : 1);
}

// ── SELECTOR DE PERSONAJE ─────────────────────────────────────
class SorpresaScreen extends StatefulWidget {
  final String lang;
  const SorpresaScreen({super.key, required this.lang});
  @override State<SorpresaScreen> createState() => _SorpresaScreenState();
}

class _SorpresaScreenState extends State<SorpresaScreen> {
  late String _lang;
  bool _selected = false;

  @override
  void initState() { super.initState(); _lang = widget.lang; }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(child: Column(children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), color: kSurface,
          child: Row(children: [
            GestureDetector(onTap: () => Navigator.pop(context),
                child: Container(width: 36, height: 36,
                    decoration: BoxDecoration(border: Border.all(color: kBorder), borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.arrow_back, color: kText, size: 18))),
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
                    border: Border.all(color: _selected ? kGold : kBorder, width: _selected ? 1.5 : 0.5)),
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
              onTap: _selected ? () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => SorpresaPlayerScreen(personaje: kLena, lang: _lang))) : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                    gradient: _selected ? const LinearGradient(colors: [kGold, kGoldLight]) : null,
                    color: _selected ? null : kSurface2,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _selected ? kGold : kBorder)),
                child: Center(child: Text(ts(_lang, 'start'),
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600,
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
  @override State<SorpresaPlayerScreen> createState() => _SorpresaPlayerScreenState();
}

class _SorpresaPlayerScreenState extends State<SorpresaPlayerScreen> {
  late String _lang;
  late List<SorpresaStop> _route;
  int _idx = 0;

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
    _buildRoute(null);
    _player = AudioPlayer();
    _player.positionStream.listen((p) { if (mounted) setState(() => _pos = p); });
    _player.durationStream.listen((d) { if (mounted) setState(() => _dur = d ?? Duration.zero); });
    _player.playerStateStream.listen((s) {
      if (mounted) setState(() => _playing = s.playing);
      if (s.processingState == ProcessingState.completed) {
        if (mounted) setState(() { _playing = false; _pos = Duration.zero; });
        _player.seek(Duration.zero); _player.pause();
      }
    });
    _loadAudio();
    _startGeo();
  }

  @override
  void dispose() { _player.dispose(); _geoSub?.cancel(); super.dispose(); }

  void _buildRoute(String? branch) {
    final all = widget.personaje.stops;
    _route = branch == null
        ? all.where((s) => s.branch == 'shared' || s.branch == 'bifurcacion').toList()
        : all.where((s) => s.branch == 'shared' || s.branch == branch).toList();
  }

  SorpresaStop get _currentStop => _route[_idx];

  Future<void> _loadAudio() async {
    final stop = _currentStop;
    if (stop.branch == 'bifurcacion') return;
    final langSuffix = (_lang == 'en') ? 'en' : 'es';
    final url = '${widget.personaje.r2Base}${stop.id}_$langSuffix.mp3';
    try {
      await _player.stop();
      setState(() { _pos = Duration.zero; _dur = Duration.zero; _playing = false; });
      await _player.setUrl(url);
    } catch (_) {}
  }

  Future<void> _togglePlay() async {
    if (_currentStop.branch == 'bifurcacion') return;
    if (_playing) await _player.pause(); else await _player.play();
  }

  void _chooseBranch(String branch) {
    setState(() {
      _buildRoute(branch);
      _idx = _route.indexWhere((s) => s.branch == branch);
      if (_idx < 0) _idx = 0;
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
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 5),
      ).listen((pos) {
        setState(() { _userLat = pos.latitude; _userLng = pos.longitude; });
        _checkProximity();
      });
    } catch (_) {}
  }

  void _checkProximity() {
    if (_userLat == null || _userLng == null) return;
    final stop = _currentStop;
    if (stop.branch == 'bifurcacion') return;
    final dist = _haversine(_userLat!, _userLng!, stop.lat, stop.lng);
    if (dist <= _proximityRadius && !_nearStop) setState(() => _nearStop = true);
  }

  // ── MAPA SORPRESA ─────────────────────────────────────────
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
          // Paradas de la ruta
          ..._route.asMap().entries.map((e) {
            final s = e.value;
            final isCurrent = e.key == _idx;
            final isDone = e.key < _idx;
            if (s.branch == 'bifurcacion') return null;
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
                    color: isCurrent ? kGoldLight : (isDone ? kGold.withOpacity(0.6) : kBorder),
                    width: isCurrent ? 2.5 : 1.5,
                  ),
                ),
                child: Center(
                  child: Text('${e.key + 1}',
                      style: TextStyle(
                          fontSize: isCurrent ? 14 : 10,
                          fontWeight: FontWeight.bold,
                          color: isCurrent ? Colors.black : (isDone ? kGold : kMuted))),
                ),
              ),
            );
          }).whereType<Marker>().toList(),
          // Ubicación del usuario
          if (_userLat != null) Marker(
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
    final isBif = stop.branch == 'bifurcacion';
    final progress = _dur.inMilliseconds > 0
        ? (_pos.inMilliseconds / _dur.inMilliseconds).clamp(0.0, 1.0) : 0.0;

    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(child: Column(children: [

        // ── TOP BAR ──
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), color: kSurface,
          child: Row(children: [
            GestureDetector(onTap: () { _player.stop(); Navigator.pop(context); },
                child: Container(width: 36, height: 36,
                    decoration: BoxDecoration(border: Border.all(color: kBorder), borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.arrow_back, color: kText, size: 18))),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: kGold.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20), border: Border.all(color: kGold)),
              child: Text(ts(_lang, 'mode_label'),
                  style: const TextStyle(fontSize: 10, color: kGold, letterSpacing: 2, fontWeight: FontWeight.w600)),
            ),
            const Spacer(),
            langPill(_lang, (l) => setState(() { _lang = l; _loadAudio(); })),
          ]),
        ),

        // ── MAPA (arriba) ──
        SizedBox(
          height: 220,
          child: _buildMap(),
        ),

        // ── DOTS DE PROGRESO ──
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Row(children: List.generate(_route.length, (i) {
            Color c = i < _idx ? kGold : (i == _idx ? kGoldLight : kBorder);
            return Expanded(child: Container(height: 3, margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(2))));
          })),
        ),

        // ── HISTORIA (abajo, scrollable) ──
        Expanded(child: SingleChildScrollView(child: Column(children: [
          const SizedBox(height: 12),

          // Pista
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: kSurface, borderRadius: BorderRadius.circular(14),
                border: Border.all(color: isBif ? kGold : kBorder)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(width: 8, height: 8, decoration: const BoxDecoration(color: kGold, shape: BoxShape.circle)),
                const SizedBox(width: 8),
                Text(isBif ? ts(_lang, 'branch_label') : ts(_lang, 'clue'),
                    style: const TextStyle(fontSize: 10, color: kGold, letterSpacing: 2, fontWeight: FontWeight.w600)),
              ]),
              const SizedBox(height: 8),
              Text(stop.hint(_lang),
                  style: const TextStyle(fontSize: 14, color: kText, fontStyle: FontStyle.italic, height: 1.5)),
            ]),
          ),
          const SizedBox(height: 10),

          // Lugar + distancia GPS
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(children: [
              Text(stop.lugar, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: kText)),
              const Spacer(),
              if (_userLat != null && !isBif)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: kSurface2, borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: kBorder)),
                  child: Text('${_haversine(_userLat!, _userLng!, stop.lat, stop.lng).round()}m',
                      style: const TextStyle(fontSize: 11, color: kMuted)),
                ),
            ]),
          ),
          const SizedBox(height: 10),

          // Bifurcación
          if (isBif) Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(children: [
              Text(ts(_lang, 'who_is_lena'),
                  style: const TextStyle(fontSize: 13, color: kGold, fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(child: GestureDetector(
                  onTap: () => _chooseBranch('A'),
                  child: Container(padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: kSurface, borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: kBorder)),
                    child: Column(children: [
                      const Text('💨', style: TextStyle(fontSize: 24)),
                      const SizedBox(height: 6),
                      Text(ts(_lang, 'branch_a_title'), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: kText), textAlign: TextAlign.center),
                      const SizedBox(height: 4),
                      Text(ts(_lang, 'branch_a_desc'), style: const TextStyle(fontSize: 11, color: kMuted), textAlign: TextAlign.center),
                    ]),
                  ),
                )),
                const SizedBox(width: 10),
                Expanded(child: GestureDetector(
                  onTap: () => _chooseBranch('B'),
                  child: Container(padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: kSurface, borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: kBorder)),
                    child: Column(children: [
                      const Text('🏠', style: TextStyle(fontSize: 24)),
                      const SizedBox(height: 6),
                      Text(ts(_lang, 'branch_b_title'), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: kText), textAlign: TextAlign.center),
                      const SizedBox(height: 4),
                      Text(ts(_lang, 'branch_b_desc'), style: const TextStyle(fontSize: 11, color: kMuted), textAlign: TextAlign.center),
                    ]),
                  ),
                )),
              ]),
            ]),
          ),

          // Reproductor
          if (!isBif) ...[
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: kSurface, borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: kBorder)),
              child: Row(children: [
                GestureDetector(onTap: _togglePlay,
                    child: Container(width: 48, height: 48,
                        decoration: const BoxDecoration(color: kGold, shape: BoxShape.circle),
                        child: Icon(_playing ? Icons.pause : Icons.play_arrow, color: Colors.black, size: 22))),
                const SizedBox(width: 12),
                Expanded(child: Column(children: [
                  SliderTheme(
                    data: const SliderThemeData(trackHeight: 3, activeTrackColor: kGold,
                        inactiveTrackColor: kSurface2, thumbColor: kGold),
                    child: Slider(value: progress, onChanged: (v) {
                      if (_dur == Duration.zero) return;
                      _player.seek(Duration(milliseconds: (_dur.inMilliseconds * v).round()));
                    }),
                  ),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text(_fmtTime(_pos), style: const TextStyle(fontSize: 11, color: kMuted)),
                    Text(_fmtTime(_dur), style: const TextStyle(fontSize: 11, color: kMuted)),
                  ]),
                ])),
              ]),
            ),
          ],

          // GPS + siguiente
          if (!isBif && _idx < _route.length - 1) ...[
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
                      _nearStop ? ts(_lang, 'near_stop') : '${ts(_lang, 'walk_to')} ${stop.lugar}',
                      style: TextStyle(fontSize: 12, color: _nearStop ? kGold : kMuted))),
                  if (_nearStop) GestureDetector(
                    onTap: _nextStop,
                    child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: kGold, borderRadius: BorderRadius.circular(8)),
                        child: Text(ts(_lang, 'next'),
                            style: const TextStyle(fontSize: 12, color: Colors.black, fontWeight: FontWeight.w600))),
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
                  width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(color: kSurface2, borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: kBorder)),
                  child: Center(child: Text(ts(_lang, 'next_stop'),
                      style: const TextStyle(fontSize: 13, color: kMuted))),
                ),
              ),
            ),
          ],

          // Fin
          if (_idx == _route.length - 1 && !isBif) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                width: double.infinity, padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: kGold.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16), border: Border.all(color: kGold)),
                child: Column(children: [
                  const Text('✨', style: TextStyle(fontSize: 32)),
                  const SizedBox(height: 8),
                  Text(ts(_lang, 'end_title'),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kGold)),
                  const SizedBox(height: 4),
                  Text(ts(_lang, 'end_sub'), style: const TextStyle(fontSize: 13, color: kMuted)),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () { _player.stop(); Navigator.pop(context); Navigator.pop(context); },
                    child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                        decoration: BoxDecoration(color: kGold, borderRadius: BorderRadius.circular(10)),
                        child: Text(ts(_lang, 'back_home'),
                            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600))),
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