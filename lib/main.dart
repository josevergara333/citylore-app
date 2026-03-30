import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';

void main() {
  runApp(const CityLoreApp());
}

class CityLoreApp extends StatelessWidget {
  const CityLoreApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CityLore',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(scaffoldBackgroundColor: kBg),
      home: const SplashScreen(),
    );
  }
}

// ── COLORES ──────────────────────────────────────────────────
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

// ── MODELOS ──────────────────────────────────────────────────
class City {
  final String id, name, flag, description;
  final bool available;
  const City({required this.id, required this.name, required this.flag,
    required this.description, this.available = true});
}

class Place {
  final String ciudad, id, barrio, epoca;
  final Map<String, String> nombres;
  final double lat, lng;
  final Map<String, Map<String, String>> textos;
  final Map<String, String> audios;
  final String wikipediaEN;

  const Place({required this.ciudad, required this.id, required this.nombres,
    required this.barrio, required this.epoca, required this.lat,
    required this.lng, required this.textos, required this.audios,
    required this.wikipediaEN});

  String nombre(String lang) =>
      (nombres[lang]?.isNotEmpty == true) ? nombres[lang]! : nombres['es'] ?? id;

// Columnas v7 (31 cols):
// 0:Ciudad 1:ID 2:Nombre_ES 3:Nombre_EN 4:Nombre_DE 5:Nombre_IT
// 6:Barrio 7:Epoca 8:Lat 9:Lng
// 10:Historia_ES 11:Historia_EN 12:Historia_DE 13:Historia_IT
// 14:Arquitectura_ES 15:Arquitectura_EN 16:Arquitectura_DE 17:Arquitectura_IT
// 18:Arte_ES 19:Arte_EN 20:Arte_DE 21:Arte_IT
// 22:Curiosidades_ES 23:Curiosidades_EN 24:Curiosidades_DE 25:Curiosidades_IT
// 26:Audio_ES 27:Audio_EN 28:Audio_DE 29:Audio_IT
// 30:Wikipedia_EN
}

// ── GOOGLE SHEETS ─────────────────────────────────────────────
const kSheetId = '1K1iMpmKiYMC3A05V9byG1duokRJK-2eYMQKti_wc2Fg';

Future<List<Place>> fetchPlaces(String ciudad) async {
  final url = 'https://docs.google.com/spreadsheets/d/$kSheetId/gviz/tq?tqx=out:json&sheet=Lugares';
  final res = await http.get(Uri.parse(url));
  if (res.statusCode != 200) throw Exception('Error al cargar datos');

  // Sheets devuelve JSON con prefijo: /*O_o*/\ngoogle.visualization.Query.setResponse({...})
  // Hay que limpiar el prefijo antes de parsear
  String body = res.body;
  final start = body.indexOf('{');
  final end = body.lastIndexOf('}');
  if (start == -1 || end == -1) throw Exception('Formato inesperado');
  body = body.substring(start, end + 1);

  final data = json.decode(body);
  final rows = data['table']['rows'] as List;
  final places = <Place>[];

  for (final row in rows) {
    final cells = row['c'] as List;
    // Extraer valor de cada celda (puede ser null)
    String cell(int i) {
      if (i >= cells.length || cells[i] == null) return '';
      final v = cells[i]['v'];
      if (v == null) return '';
      return v.toString().trim();
    }

    if (cells.isEmpty || cell(0).isEmpty) continue;

    try {
      final place = Place(
        ciudad: cell(0), id: cell(1),
        nombres: {'es': cell(2), 'en': cell(3), 'de': cell(4), 'it': cell(5)},
        barrio: cell(6), epoca: cell(7),
        lat: double.tryParse(cell(8)) ?? 0.0,
        lng: double.tryParse(cell(9)) ?? 0.0,
        textos: {
          'es': {'historia': cell(10), 'arquitectura': cell(14), 'arte': cell(18), 'curiosidades': cell(22)},
          'en': {'historia': cell(11), 'arquitectura': cell(15), 'arte': cell(19), 'curiosidades': cell(23)},
          'de': {'historia': cell(12), 'arquitectura': cell(16), 'arte': cell(20), 'curiosidades': cell(24)},
          'it': {'historia': cell(13), 'arquitectura': cell(17), 'arte': cell(21), 'curiosidades': cell(25)},
        },
        audios: {'es': cell(26), 'en': cell(27), 'de': cell(28), 'it': cell(29)},
        wikipediaEN: cell(30),
      );
      if (place.ciudad == ciudad) places.add(place);
    } catch (_) { continue; }
  }
  return places;
}

Future<String?> fetchWikipediaPhoto(String articleName) async {
  if (articleName.isEmpty) return null;
  try {
    final url = 'https://en.wikipedia.org/api/rest_v1/page/summary/$articleName';
    final res = await http.get(Uri.parse(url));
    if (res.statusCode != 200) return null;
    final data = json.decode(res.body);
    // Obtener URL original en alta resolución
    String? thumbUrl = data['originalimage']?['source'] as String?;
    // Si no hay original, usar thumbnail pero en mayor tamaño
    thumbUrl ??= (data['thumbnail']?['source'] as String?)
        ?.replaceAll(RegExp(r'/\d+px-'), '/800px-');
    return thumbUrl;
  } catch (_) { return null; }
}



// ── TRADUCCIONES UI ───────────────────────────────────────────
const kT = {
  'es': {
    'choose_city':   'Elige tu destino',
    'surprise':      '✨  Modo Sorpréndeme',
    'surprise_soon': 'Modo Sorpréndeme — próximamente',
    'soon':          'Pronto',
    'search':        'Buscar lugar...',
    'place':         'Lugar',
    'historic_photo':'Foto histórica',
    'no_photo':      'Foto no disponible',
    'error_load':    'Error al cargar datos',
    'retry':         'Reintentar',
    'no_results':    'No se encontraron lugares',
    'no_text':       'Texto no disponible en este idioma.',
  },
  'en': {
    'choose_city':   'Choose your destination',
    'surprise':      '✨  Surprise Me',
    'surprise_soon': 'Surprise Me — coming soon',
    'soon':          'Soon',
    'search':        'Search place...',
    'place':         'Place',
    'historic_photo':'Historic photo',
    'no_photo':      'Photo not available',
    'error_load':    'Error loading data',
    'retry':         'Retry',
    'no_results':    'No places found',
    'no_text':       'Text not available in this language.',
  },
  'de': {
    'choose_city':   'Wähle dein Ziel',
    'surprise':      '✨  Überrasch mich',
    'surprise_soon': 'Überrasch mich — demnächst',
    'soon':          'Bald',
    'search':        'Ort suchen...',
    'place':         'Ort',
    'historic_photo':'Historisches Foto',
    'no_photo':      'Foto nicht verfügbar',
    'error_load':    'Fehler beim Laden',
    'retry':         'Erneut versuchen',
    'no_results':    'Keine Orte gefunden',
    'no_text':       'Text in dieser Sprache nicht verfügbar.',
  },
  'it': {
    'choose_city':   'Scegli la tua destinazione',
    'surprise':      '✨  Sorprendimi',
    'surprise_soon': 'Sorprendimi — prossimamente',
    'soon':          'Presto',
    'search':        'Cerca luogo...',
    'place':         'Luogo',
    'historic_photo':'Foto storica',
    'no_photo':      'Foto non disponibile',
    'error_load':    'Errore nel caricamento',
    'retry':         'Riprova',
    'no_results':    'Nessun luogo trovato',
    'no_text':       'Testo non disponibile in questa lingua.',
  },
};

String t(String lang, String key) => kT[lang]?[key] ?? kT['es']![key] ?? key;

// ── CIUDADES ─────────────────────────────────────────────────
const List<City> kCities = [
  City(id: 'Berlin',      name: 'Berlín',      flag: '🇩🇪', description: '30 lugares · 120 audios'),
  City(id: 'Paris',       name: 'París',        flag: '🇫🇷', description: 'Próximamente', available: false),
  City(id: 'Roma',        name: 'Roma',         flag: '🇮🇹', description: 'Próximamente', available: false),
  City(id: 'Tokyo',       name: 'Tokyo',        flag: '🇯🇵', description: 'Próximamente', available: false),
  City(id: 'NewYork',     name: 'Nueva York',   flag: '🇺🇸', description: 'Próximamente', available: false),
  City(id: 'Barcelona',   name: 'Barcelona',    flag: '🇪🇸', description: 'Próximamente', available: false),
  City(id: 'Bangkok',     name: 'Bangkok',      flag: '🇹🇭', description: 'Próximamente', available: false),
  City(id: 'Istanbul',    name: 'Estambul',     flag: '🇹🇷', description: 'Próximamente', available: false),
  City(id: 'London',      name: 'Londres',      flag: '🇬🇧', description: 'Próximamente', available: false),
  City(id: 'BuenosAires', name: 'Buenos Aires', flag: '🇦🇷', description: 'Próximamente', available: false),
];

// ── HELPERS ───────────────────────────────────────────────────
String _fmtTime(Duration d) {
  final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
  final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '$m:$s';
}

Widget langPill(String current, void Function(String) onSelect) {
  return Container(
    padding: const EdgeInsets.all(3),
    decoration: BoxDecoration(color: kSurface2, borderRadius: BorderRadius.circular(20), border: Border.all(color: kBorder)),
    child: Row(children: ['es','en','de','it'].map((l) {
      final active = current == l;
      return GestureDetector(
        onTap: () => onSelect(l),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: active ? kGold : Colors.transparent, borderRadius: BorderRadius.circular(16)),
          child: Text(l.toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: active ? Colors.black : kMuted)),
        ),
      );
    }).toList()),
  );
}

// ── SPLASH ────────────────────────────────────────────────────
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  String _lang = 'es';
  late AnimationController _ctrl;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      body: FadeTransition(
        opacity: _fade,
        child: SafeArea(child: Column(children: [
          const SizedBox(height: 36),
          Container(
            width: 60, height: 60,
            decoration: BoxDecoration(color: kGold.withOpacity(0.08), borderRadius: BorderRadius.circular(14), border: Border.all(color: kGold, width: 1.5)),
            child: const Center(child: Text('CL', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: kGold))),
          ),
          const SizedBox(height: 8),
          const Text('AUDIO TOURS · WORLD', style: TextStyle(fontSize: 11, color: kMuted, letterSpacing: 4)),
          const SizedBox(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.center,
              children: [('es','🇪🇸 ES'),('en','🇬🇧 EN'),('de','🇩🇪 DE'),('it','🇮🇹 IT')].map((l) {
                final active = _lang == l.$1;
                return GestureDetector(
                  onTap: () => setState(() => _lang = l.$1),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: active ? kGold.withOpacity(0.12) : kSurface, borderRadius: BorderRadius.circular(20), border: Border.all(color: active ? kGold : kBorder)),
                    child: Text(l.$2, style: TextStyle(fontSize: 12, color: active ? kGoldLight : kMuted, fontWeight: active ? FontWeight.w600 : FontWeight.normal)),
                  ),
                );
              }).toList()),
          const SizedBox(height: 24),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(children: [Text(t(_lang, 'choose_city'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: kText))])),
          const SizedBox(height: 10),
          Expanded(child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: kCities.length,
            itemBuilder: (ctx, i) => _CityCard(city: kCities[i], lang: _lang),
          )),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: GestureDetector(
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t(_lang, 'surprise_soon')))),
              child: Container(
                width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(color: kGold.withOpacity(0.08), borderRadius: BorderRadius.circular(14), border: Border.all(color: kGold)),
                child: Center(child: Text(t(_lang, 'surprise'), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: kGold))),
              ),
            ),
          ),
        ])),
      ),
    );
  }
}

class _CityCard extends StatefulWidget {
  final City city; final String lang;
  const _CityCard({required this.city, required this.lang});
  @override State<_CityCard> createState() => _CityCardState();
}

class _CityCardState extends State<_CityCard> {
  bool _p = false;
  @override
  Widget build(BuildContext context) {
    final ok = widget.city.available;
    return GestureDetector(
      onTap: ok ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => PlacesScreen(city: widget.city, lang: widget.lang))) : null,
      onTapDown: (_) => setState(() => _p = true),
      onTapUp: (_) => setState(() => _p = false),
      onTapCancel: () => setState(() => _p = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: _p && ok ? kSurface2 : kSurface, borderRadius: BorderRadius.circular(14), border: Border.all(color: _p && ok ? kGold : kBorder)),
        child: Row(children: [
          Text(widget.city.flag, style: const TextStyle(fontSize: 26)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(widget.city.name, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: ok ? kText : kMuted)),
            const SizedBox(height: 2),
            Text(widget.city.description, style: const TextStyle(fontSize: 12, color: kMuted)),
          ])),
          if (ok) const Icon(Icons.chevron_right, color: kGold, size: 20)
          else Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: kSurface2, borderRadius: BorderRadius.circular(6), border: Border.all(color: kBorder)),
            child: Text(t(widget.lang, 'soon'), style: const TextStyle(fontSize: 10, color: kMuted)),
          ),
        ]),
      ),
    );
  }
}

// ── PLACES SCREEN ─────────────────────────────────────────────
class PlacesScreen extends StatefulWidget {
  final City city; final String lang;
  const PlacesScreen({super.key, required this.city, required this.lang});
  @override State<PlacesScreen> createState() => _PlacesScreenState();
}

class _PlacesScreenState extends State<PlacesScreen> {
  late String _lang;
  List<Place> _all = [], _filtered = [];
  bool _loading = true; String? _error;

  @override
  void initState() { super.initState(); _lang = widget.lang; _load(); }

  Future<void> _load() async {
    try {
      final p = await fetchPlaces(widget.city.id);
      setState(() { _all = p; _filtered = p; _loading = false; });
    } catch (e) { setState(() { _error = e.toString(); _loading = false; }); }
  }

  void _filter(String q) => setState(() {
    _filtered = q.isEmpty ? _all : _all.where((p) =>
    p.nombre(_lang).toLowerCase().contains(q.toLowerCase()) ||
        p.barrio.toLowerCase().contains(q.toLowerCase())).toList();
  });

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
            Text('${widget.city.flag} ${widget.city.name}',
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: kText)),
            const Spacer(),
            langPill(_lang, (l) => setState(() { _lang = l; _filter(''); })),
          ]),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10), color: kSurface,
          child: TextField(
            onChanged: _filter,
            style: const TextStyle(color: kText, fontSize: 14),
            decoration: InputDecoration(
              hintText: t(_lang, 'search'), hintStyle: const TextStyle(color: kMuted),
              filled: true, fillColor: kSurface2,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: kBorder)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: kBorder)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: kGold)),
            ),
          ),
        ),
        Expanded(child: _loading
            ? const Center(child: CircularProgressIndicator(color: kGold))
            : _error != null
            ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.wifi_off, color: kMuted, size: 48),
          const SizedBox(height: 12),
          Text(t(_lang, 'error_load'), style: const TextStyle(color: kText)),
          const SizedBox(height: 8),
          GestureDetector(onTap: () { setState(() { _loading = true; _error = null; }); _load(); },
              child: Text(t(_lang, 'retry'), style: const TextStyle(color: kGold))),
        ]))
            : _filtered.isEmpty
            ? Center(child: Text(t(_lang, 'no_results'), style: const TextStyle(color: kMuted)))
            : ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          itemCount: _filtered.length,
          itemBuilder: (ctx, i) => _PlaceItem(place: _filtered[i], lang: _lang),
        )),
      ])),
    );
  }
}

class _PlaceItem extends StatelessWidget {
  final Place place; final String lang;
  const _PlaceItem({required this.place, required this.lang});
  @override
  Widget build(BuildContext context) {
    final num = place.id.split('_').last;
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PlayerScreen(place: place, lang: lang))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: kSurface, borderRadius: BorderRadius.circular(14), border: Border.all(color: kBorder)),
        child: Row(children: [
          Container(width: 32, height: 32,
              decoration: BoxDecoration(color: kSurface2, borderRadius: BorderRadius.circular(8), border: Border.all(color: kBorder)),
              child: Center(child: Text(num, style: const TextStyle(fontSize: 11, color: kMuted, fontWeight: FontWeight.w500)))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(place.nombre(lang), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: kText), overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text('${place.barrio} · ${place.epoca}', style: const TextStyle(fontSize: 11, color: kMuted)),
          ])),
          const Icon(Icons.chevron_right, color: kMuted, size: 16),
        ]),
      ),
    );
  }
}

// ── PLAYER SCREEN ─────────────────────────────────────────────
class PlayerScreen extends StatefulWidget {
  final Place place; final String lang;
  const PlayerScreen({super.key, required this.place, required this.lang});
  @override State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  late String _lang;
  String _capa = 'historia';
  late AudioPlayer _player;
  bool _playing = false;
  Duration _pos = Duration.zero, _dur = Duration.zero;
  String? _photoUrl;
  bool _loadingPhoto = true;

  final _capas = ['historia','arquitectura','arte','curiosidades'];
  final _capaLabels = {
    'historia':     '🏛 Historia',
    'arquitectura': '🏗 Arquitectura',
    'arte':         '🎨 Arte',
    'curiosidades': '🤩 Curiosidades',
  };

  @override
  void initState() {
    super.initState();
    _lang = widget.lang;
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
    _loadPhoto();
  }

  @override
  void dispose() { _player.dispose(); super.dispose(); }

  Future<void> _loadPhoto() async {
    setState(() => _loadingPhoto = true);
    final url = await fetchWikipediaPhoto(widget.place.wikipediaEN);
    if (mounted) setState(() { _photoUrl = url; _loadingPhoto = false; });
  }

  Future<void> _loadAudio() async {
    final baseUrl = widget.place.audios[_lang] ?? '';
    if (baseUrl.isEmpty) return;
    // Construir URL correcta reemplazando la capa
    final url = baseUrl.replaceAll('_historia.mp3', '_$_capa.mp3');
    try {
      await _player.stop();
      setState(() { _pos = Duration.zero; _dur = Duration.zero; _playing = false; });
      await _player.setUrl(url);
    } catch (_) {}
  }

  void _selectCapa(String capa) {
    setState(() => _capa = capa);
    _loadAudio();
  }

  void _selectLang(String lang) {
    setState(() => _lang = lang);
    _loadAudio();
  }

  Future<void> _togglePlay() async {
    if (_playing) { await _player.pause(); }
    else { await _player.play(); }
  }

  Color get _capaColor => kCapaColors[_capa] ?? kGold;

  @override
  Widget build(BuildContext context) {
    final texto = widget.place.textos[_lang]?[_capa] ?? '';
    final progress = _dur.inMilliseconds > 0
        ? (_pos.inMilliseconds / _dur.inMilliseconds).clamp(0.0, 1.0)
        : 0.0;

    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(child: Column(children: [

        // ── TOP BAR ──
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), color: kSurface,
          child: Row(children: [
            GestureDetector(
                onTap: () { _player.stop(); Navigator.pop(context); },
                child: Container(width: 36, height: 36,
                    decoration: BoxDecoration(border: Border.all(color: kBorder), borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.arrow_back, color: kText, size: 18))),
            const SizedBox(width: 12),
            Expanded(child: Text(widget.place.nombre(_lang),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: kText),
                overflow: TextOverflow.ellipsis)),
            const SizedBox(width: 8),
            langPill(_lang, _selectLang),
          ]),
        ),

        Expanded(child: SingleChildScrollView(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            // ── FOTO HISTÓRICA ──
            _buildPhoto(),

            // ── HERO INFO ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${t(_lang, 'place')} ${widget.place.id.split('_').last} · ${widget.place.epoca}',
                    style: const TextStyle(fontSize: 10, color: kGold, letterSpacing: 2)),
                const SizedBox(height: 4),
                Text(widget.place.nombre(_lang),
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: kText)),
                const SizedBox(height: 2),
                Text('${widget.place.barrio} · ${widget.place.ciudad}',
                    style: const TextStyle(fontSize: 12, color: kMuted)),
              ]),
            ),

            // ── CAPA TABS ──
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(children: _capas.map((c) {
                final active = _capa == c;
                final color = kCapaColors[c] ?? kGold;
                return GestureDetector(
                  onTap: () => _selectCapa(c),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                        color: active ? color.withOpacity(0.15) : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: active ? color : kBorder)),
                    child: Text(_capaLabels[c] ?? c,
                        style: TextStyle(fontSize: 12, color: active ? color : kMuted,
                            fontWeight: active ? FontWeight.w600 : FontWeight.normal)),
                  ),
                );
              }).toList()),
            ),

            // ── REPRODUCTOR ──
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: kSurface, borderRadius: BorderRadius.circular(16), border: Border.all(color: kBorder)),
              child: Column(children: [
                // Label + indicador
                Row(children: [
                  Container(width: 8, height: 8, decoration: BoxDecoration(color: _capaColor, shape: BoxShape.circle)),
                  const SizedBox(width: 8),
                  Text((_capaLabels[_capa] ?? _capa).toUpperCase(),
                      style: TextStyle(fontSize: 10, color: _capaColor, letterSpacing: 2, fontWeight: FontWeight.w600)),
                  const Spacer(),
                  if (_playing) Row(children: [
                    _bar(12), const SizedBox(width: 2), _bar(8), const SizedBox(width: 2), _bar(12),
                  ]),
                ]),
                const SizedBox(height: 14),
                // Controles
                Row(children: [
                  GestureDetector(
                      onTap: _togglePlay,
                      child: Container(
                          width: 52, height: 52,
                          decoration: BoxDecoration(color: _capaColor, shape: BoxShape.circle),
                          child: Icon(_playing ? Icons.pause : Icons.play_arrow, color: Colors.white, size: 24))),
                  const SizedBox(width: 14),
                  Expanded(child: Column(children: [
                    SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 4,
                        activeTrackColor: _capaColor,
                        inactiveTrackColor: kSurface2,
                        thumbColor: _capaColor,
                      ),
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
              ]),
            ),

            // ── TEXTO ──
            Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: kSurface, borderRadius: BorderRadius.circular(14), border: Border.all(color: kBorder)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Container(width: 4, height: 16, decoration: BoxDecoration(color: _capaColor, borderRadius: BorderRadius.circular(2))),
                  const SizedBox(width: 8),
                  Text((_capaLabels[_capa] ?? _capa).toUpperCase(),
                      style: TextStyle(fontSize: 10, color: _capaColor, letterSpacing: 2, fontWeight: FontWeight.w600)),
                ]),
                const SizedBox(height: 12),
                texto.isEmpty
                    ? Text(t(_lang, 'no_text'), style: const TextStyle(color: kMuted, fontSize: 14))
                    : Text(texto, style: const TextStyle(fontSize: 14, color: Color(0xFFc8c4bc), height: 1.8)),
              ]),
            ),

          ]),
        )),
      ])),
    );
  }

  Widget _buildPhoto() {
    if (_loadingPhoto) {
      return Container(
        height: 200, color: kSurface2,
        child: const Center(child: CircularProgressIndicator(color: kGold, strokeWidth: 2)),
      );
    }
    if (_photoUrl == null) {
      return Container(
        height: 160, color: kSurface2,
        child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.image_not_supported_outlined, color: kMuted, size: 32),
          const SizedBox(height: 8),
          Text(t(_lang, 'no_photo'), style: const TextStyle(color: kMuted, fontSize: 12)),
        ])),
      );
    }
    return Stack(children: [
      Image.network(
        _photoUrl!,
        width: double.infinity, height: 220,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
            height: 160, color: kSurface2,
            child: const Center(child: Icon(Icons.image_not_supported_outlined, color: kMuted, size: 32))),
      ),
      // Gradiente sobre la foto
      Positioned(bottom: 0, left: 0, right: 0,
          child: Container(
            height: 60,
            decoration: BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    colors: [Colors.transparent, kBg.withOpacity(0.8)])),
          )),
      // Badge "Foto histórica"
      Positioned(top: 12, right: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(8)),
            child: Row(children: [
              const Icon(Icons.history, color: kGold, size: 12),
              const SizedBox(width: 4),
              Text(t(_lang, 'historic_photo'), style: const TextStyle(color: kGold, fontSize: 10, fontWeight: FontWeight.w500)),
            ]),
          )),
    ]);
  }

  Widget _bar(double h) => Container(
      width: 3, height: h,
      decoration: BoxDecoration(color: _capaColor, borderRadius: BorderRadius.circular(2)));
}