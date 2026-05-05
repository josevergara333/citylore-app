import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'sorpresa.dart';
import 'widgets.dart';
import 'map_screen.dart';
import 'tours.dart';

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
  final Map<String, String> gastronomia;
  final Map<String, String> cineLiteratura;
  final Map<String, String> mitologiaReligion;

  const Place({
    required this.ciudad, required this.id, required this.nombres,
    required this.barrio, required this.epoca, required this.lat,
    required this.lng, required this.textos, required this.audios,
    required this.wikipediaEN,
    this.gastronomia = const {},
    this.cineLiteratura = const {},
    this.mitologiaReligion = const {},
  });

  // Para París, el FR está en la columna DE (nombre, textos base)
  String nombre(String lang) {
    final effectiveLang = (lang == 'fr' && ciudad == 'Paris') ? 'de' : lang;
    return (nombres[effectiveLang]?.isNotEmpty == true)
        ? nombres[effectiveLang]!
        : nombres['es'] ?? id;
  }

  // Devuelve el texto de una capa para el idioma dado,
  // manejando el mapeo FR→DE para París en las capas base
  String textoParaCapa(String capa, String lang) {
    if (capa == 'gastronomia') {
      return gastronomia[lang] ?? gastronomia['es'] ?? '';
    }
    if (capa == 'cine_literatura') {
      return cineLiteratura[lang] ?? cineLiteratura['es'] ?? '';
    }
    if (capa == 'mitologia_religion') {
      return mitologiaReligion[lang] ?? mitologiaReligion['es'] ?? '';
    }
    // Capas base: para París FR está en columna DE
    final effectiveLang = (lang == 'fr' && ciudad == 'Paris') ? 'de' : lang;
    return textos[effectiveLang]?[capa] ?? textos['es']?[capa] ?? '';
  }

  // Capas disponibles: París y Roma añaden capas extra si tienen contenido
  List<String> capasDisponibles() {
    const base = ['historia', 'arquitectura', 'arte', 'curiosidades'];
    if (ciudad == 'Paris') {
      final extra = <String>[];
      if (gastronomia.values.any((v) => v.isNotEmpty)) extra.add('gastronomia');
      if (cineLiteratura.values.any((v) => v.isNotEmpty)) extra.add('cine_literatura');
      return [...base, ...extra];
    }
    if (ciudad == 'Roma') {
      final extra = <String>[];
      if (cineLiteratura.values.any((v) => v.isNotEmpty)) extra.add('cine_literatura');
      if (mitologiaReligion.values.any((v) => v.isNotEmpty)) extra.add('mitologia_religion');
      return [...base, ...extra];
    }
    return base;
  }

  // Idiomas disponibles para el selector de idioma
  List<String> idiomasDisponibles() =>
      ciudad == 'Paris' ? ['es', 'en', 'fr'] : ['es', 'en', 'de', 'it'];
}

// ── GOOGLE SHEETS ─────────────────────────────────────────────
const kSheetId = '1K1iMpmKiYMC3A05V9byG1duokRJK-2eYMQKti_wc2Fg';

// Columnas Lugares:
// A(0):Ciudad B(1):ID C(2):Nombre_ES D(3):Nombre_EN E(4):Nombre_DE/FR F(5):Nombre_IT
// G(6):Barrio H(7):Epoca I(8):Lat J(9):Lng
// K(10):Historia_ES L(11):Historia_EN M(12):Historia_DE/FR N(13):Historia_IT
// O(14):Arq_ES P(15):Arq_EN Q(16):Arq_DE/FR R(17):Arq_IT
// S(18):Arte_ES T(19):Arte_EN U(20):Arte_DE/FR V(21):Arte_IT
// W(22):Curio_ES X(23):Curio_EN Y(24):Curio_DE/FR Z(25):Curio_IT
// AA(26):Audio_ES AB(27):Audio_EN AC(28):Audio_DE AD(29):Audio_IT AE(30):Wikipedia_EN
// AF(31):Gastro_ES AG(32):Gastro_EN AH(33):Gastro_FR [solo París]
// AI(34):Cine_ES AJ(35):Cine_EN AK(36):Cine_FR [solo París]
Future<List<Place>> fetchPlaces(String ciudad) async {
  final url = 'https://docs.google.com/spreadsheets/d/$kSheetId/gviz/tq?tqx=out:json&sheet=Lugares';
  final res = await http.get(Uri.parse(url));
  if (res.statusCode != 200) throw Exception('Error al cargar datos');
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
        gastronomia:       {'es': cell(31), 'en': cell(32), 'fr': cell(33)},
        cineLiteratura:    {'es': cell(34), 'en': cell(35), 'fr': cell(36)},
        mitologiaReligion: {'es': cell(37), 'en': cell(38), 'de': cell(39), 'it': cell(40)},
      );
      if (place.ciudad == ciudad) places.add(place);
    } catch (_) { continue; }
  }
  return places;
}

// Intenta obtener la foto de un artículo de Wikipedia (EN o FR)
Future<String?> _tryWikiPhoto(String lang, String articleName) async {
  if (articleName.isEmpty) return null;
  try {
    final encoded = Uri.encodeComponent(articleName);
    final base = lang == 'fr'
        ? 'https://fr.wikipedia.org/api/rest_v1/page/summary/$encoded'
        : 'https://en.wikipedia.org/api/rest_v1/page/summary/$encoded';
    final res = await http.get(Uri.parse(base));
    if (res.statusCode != 200) return null;
    final data = json.decode(res.body);
    String? thumbUrl = data['originalimage']?['source'] as String?;
    thumbUrl ??= (data['thumbnail']?['source'] as String?)
        ?.replaceAll(RegExp(r'/\d+px-'), '/800px-');
    return thumbUrl;
  } catch (_) { return null; }
}

// Busca la foto probando: 1) campo wikipediaEN del sheet,
// 2) nombre EN del lugar, 3) nombre FR del lugar en Wikipedia FR
Future<String?> fetchWikipediaPhoto(String articleName,
    {String nameEN = '', String nameFR = ''}) async {
  // 1. Campo explícito del sheet
  if (articleName.isNotEmpty) {
    final url = await _tryWikiPhoto('en', articleName);
    if (url != null) return url;
  }
  // 2. Nombre EN del lugar en Wikipedia EN
  if (nameEN.isNotEmpty) {
    final url = await _tryWikiPhoto('en', nameEN);
    if (url != null) return url;
  }
  // 3. Nombre FR en Wikipedia FR (para París)
  if (nameFR.isNotEmpty) {
    final url = await _tryWikiPhoto('fr', nameFR);
    if (url != null) return url;
  }
  return null;
}

// ── TRADUCCIONES UI ───────────────────────────────────────────
const kT = {
  'es': {
    'choose_city':           'Elige tu destino',
    'surprise':              '✨  Modo Sorpréndeme',
    'tours':                 '🗺  Tours Temáticos',
    'soon':                  'Pronto',
    'search':                'Buscar lugar...',
    'place':                 'Lugar',
    'historic_photo':        'Foto histórica',
    'no_photo':              'Foto no disponible',
    'error_load':            'Error al cargar datos',
    'retry':                 'Reintentar',
    'no_results':            'No se encontraron lugares',
    'no_text':               'Texto no disponible en este idioma.',
    'see_map':               'Ver mapa',
    'capa_historia':         '🏛 Historia',
    'capa_arquitectura':     '🏗 Arquitectura',
    'capa_arte':             '🎨 Arte',
    'capa_curiosidades':     '🤩 Curiosidades',
    'capa_gastronomia':      '🍽 Gastronomía',
    'capa_cine_literatura':    '🎬 Cine & Literatura',
    'capa_mitologia_religion': '⚡ Mitología & Religión',
  },
  'en': {
    'choose_city':           'Choose your destination',
    'surprise':              '✨  Surprise Me',
    'tours':                 '🗺  Thematic Tours',
    'soon':                  'Soon',
    'search':                'Search place...',
    'place':                 'Place',
    'historic_photo':        'Historic photo',
    'no_photo':              'Photo not available',
    'error_load':            'Error loading data',
    'retry':                 'Retry',
    'no_results':            'No places found',
    'no_text':               'Text not available in this language.',
    'see_map':               'View map',
    'capa_historia':         '🏛 History',
    'capa_arquitectura':     '🏗 Architecture',
    'capa_arte':             '🎨 Art',
    'capa_curiosidades':     '🤩 Curiosities',
    'capa_gastronomia':      '🍽 Gastronomy',
    'capa_cine_literatura':    '🎬 Cinema & Literature',
    'capa_mitologia_religion': '⚡ Mythology & Religion',
  },
  'de': {
    'choose_city':           'Wähle dein Ziel',
    'surprise':              '✨  Überrasch mich',
    'tours':                 '🗺  Thematische Touren',
    'soon':                  'Bald',
    'search':                'Ort suchen...',
    'place':                 'Ort',
    'historic_photo':        'Historisches Foto',
    'no_photo':              'Foto nicht verfügbar',
    'error_load':            'Fehler beim Laden',
    'retry':                 'Erneut versuchen',
    'no_results':            'Keine Orte gefunden',
    'no_text':               'Text in dieser Sprache nicht verfügbar.',
    'see_map':               'Karte anzeigen',
    'capa_historia':         '🏛 Geschichte',
    'capa_arquitectura':     '🏗 Architektur',
    'capa_arte':             '🎨 Kunst',
    'capa_curiosidades':     '🤩 Kuriositäten',
    'capa_gastronomia':      '🍽 Gastronomie',
    'capa_cine_literatura':    '🎬 Kino & Literatur',
    'capa_mitologia_religion': '⚡ Mythologie & Religion',
  },
  'it': {
    'choose_city':           'Scegli la tua destinazione',
    'surprise':              '✨  Sorprendimi',
    'tours':                 '🗺  Tour Tematici',
    'soon':                  'Presto',
    'search':                'Cerca luogo...',
    'place':                 'Luogo',
    'historic_photo':        'Foto storica',
    'no_photo':              'Foto non disponibile',
    'error_load':            'Errore nel caricamento',
    'retry':                 'Riprova',
    'no_results':            'Nessun luogo trovato',
    'no_text':               'Testo non disponibile in questa lingua.',
    'see_map':               'Vedi mappa',
    'capa_historia':         '🏛 Storia',
    'capa_arquitectura':     '🏗 Architettura',
    'capa_arte':             '🎨 Arte',
    'capa_curiosidades':     '🤩 Curiosità',
    'capa_gastronomia':      '🍽 Gastronomia',
    'capa_cine_literatura':    '🎬 Cinema & Letteratura',
    'capa_mitologia_religion': '⚡ Mitologia & Religione',
  },
  'fr': {
    'choose_city':           'Choisissez votre destination',
    'surprise':              '✨  Surprenez-moi',
    'tours':                 '🗺  Visites Thématiques',
    'soon':                  'Bientôt',
    'search':                'Rechercher un lieu...',
    'place':                 'Lieu',
    'historic_photo':        'Photo historique',
    'no_photo':              'Photo non disponible',
    'error_load':            'Erreur de chargement',
    'retry':                 'Réessayer',
    'no_results':            'Aucun lieu trouvé',
    'no_text':               'Texte non disponible dans cette langue.',
    'see_map':               'Voir la carte',
    'capa_historia':         '🏛 Histoire',
    'capa_arquitectura':     '🏗 Architecture',
    'capa_arte':             '🎨 Art',
    'capa_curiosidades':     '🤩 Curiosités',
    'capa_gastronomia':      '🍽 Gastronomie',
    'capa_cine_literatura':    '🎬 Cinéma & Littérature',
    'capa_mitologia_religion': '⚡ Mythologie & Religion',
  },
};

String t(String lang, String key) => kT[lang]?[key] ?? kT['es']![key] ?? key;

// ── CIUDADES ─────────────────────────────────────────────────
const List<City> kCities = [
  City(id: 'Berlin', name: 'Berlín', flag: '🇩🇪', description: '30 lugares · 120 audios'),
  City(id: 'Paris',  name: 'París',  flag: '🇫🇷', description: '30 lugares · Tours temáticos'),
  City(id: 'Roma',        name: 'Roma',         flag: '🇮🇹', description: 'La Ciudad Eterna', available: true),
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
            decoration: BoxDecoration(
                color: kGold.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: kGold, width: 1.5)),
            child: const Center(child: Text('CL',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: kGold))),
          ),
          const SizedBox(height: 8),
          const Text('AUDIO TOURS · WORLD',
              style: TextStyle(fontSize: 11, color: kMuted, letterSpacing: 4)),
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
                    decoration: BoxDecoration(
                        color: active ? kGold.withOpacity(0.12) : kSurface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: active ? kGold : kBorder)),
                    child: Text(l.$2,
                        style: TextStyle(
                            fontSize: 12,
                            color: active ? kGoldLight : kMuted,
                            fontWeight: active ? FontWeight.w600 : FontWeight.normal)),
                  ),
                );
              }).toList()),
          const SizedBox(height: 24),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(children: [
                Text(t(_lang, 'choose_city'),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: kText))
              ])),
          const SizedBox(height: 10),
          Expanded(child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: kCities.length,
            itemBuilder: (ctx, i) => _CityCard(city: kCities[i], lang: _lang),
          )),

          const SizedBox(height: 16),
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
      onTap: ok ? () => Navigator.push(context, MaterialPageRoute(
          builder: (_) => PlacesScreen(city: widget.city, lang: widget.lang))) : null,
      onTapDown: (_) => setState(() => _p = true),
      onTapUp: (_) => setState(() => _p = false),
      onTapCancel: () => setState(() => _p = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: _p && ok ? kSurface2 : kSurface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _p && ok ? kGold : kBorder)),
        child: Row(children: [
          Text(widget.city.flag, style: const TextStyle(fontSize: 26)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(widget.city.name,
                style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w600,
                    color: ok ? kText : kMuted)),
            const SizedBox(height: 2),
            Text(widget.city.description,
                style: const TextStyle(fontSize: 12, color: kMuted)),
          ])),
          if (ok) const Icon(Icons.chevron_right, color: kGold, size: 20)
          else Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
                color: kSurface2,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: kBorder)),
            child: Text(t(widget.lang, 'soon'),
                style: const TextStyle(fontSize: 10, color: kMuted)),
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

  bool get _isParis => widget.city.id == 'Paris';
  List<String> get _availableLangs => _isParis ? ['es', 'en', 'fr'] : ['es', 'en', 'de', 'it'];
  String get _cityLabel => _isParis ? 'París' : widget.city.id;

  @override
  void initState() {
    super.initState();
    _lang = widget.lang;
    // Reset lang if not available for this city
    if (_isParis && (_lang == 'de' || _lang == 'it')) _lang = 'es';
    _load();
  }

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

  void _openMap() {
    final mapPlaces = _all.asMap().entries.map((e) => MapPlace(
      id: e.value.id,
      nombre: e.value.nombre(_lang),
      barrio: e.value.barrio,
      lat: e.value.lat,
      lng: e.value.lng,
      numero: e.key + 1,
    )).toList();

    Navigator.push(context, MaterialPageRoute(
      builder: (_) => MapScreen(
        lang: _lang,
        places: mapPlaces,
        onPlaceTap: (mapPlace) {
          final place = _all.firstWhere((p) => p.id == mapPlace.id);
          Navigator.push(context, MaterialPageRoute(
            builder: (_) => PlayerScreen(place: place, lang: _lang),
          ));
        },
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      floatingActionButton: _all.isEmpty ? null : FloatingActionButton.extended(
        onPressed: _openMap,
        backgroundColor: kGold,
        icon: const Icon(Icons.map_outlined, color: Colors.black),
        label: Text(t(_lang, 'see_map'),
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
      ),
      body: SafeArea(child: Column(children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), color: kSurface,
          child: Row(children: [
            GestureDetector(onTap: () => Navigator.pop(context),
                child: Container(width: 36, height: 36,
                    decoration: BoxDecoration(
                        border: Border.all(color: kBorder),
                        borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.arrow_back, color: kText, size: 18))),
            const SizedBox(width: 12),
            Text('${widget.city.flag} ${widget.city.name}',
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: kText)),
            const Spacer(),
            langPill(_lang, (l) => setState(() { _lang = l; _filter(''); }),
                langs: _availableLangs),
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
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: kBorder)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: kBorder)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: kGold)),
            ),
          ),
        ),
        // ── TOURS + SORPRESA ──
        Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          color: kSurface,
          child: Row(children: [
            Expanded(child: GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => ToursScreen(lang: _lang, initialCity: _cityLabel))),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 11),
                decoration: BoxDecoration(
                    color: kSurface2,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: kBorder)),
                child: Center(child: Text(t(_lang, 'tours'),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: kText))),
              ),
            )),
            const SizedBox(width: 10),
            Expanded(child: GestureDetector(
              onTap: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => SorpresaScreen(lang: _lang, initialCity: _cityLabel))),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 11),
                decoration: BoxDecoration(
                    color: kGold.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: kGold)),
                child: Center(child: Text(t(_lang, 'surprise'),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: kGold))),
              ),
            )),
          ]),
        ),

        Expanded(child: _loading
            ? const Center(child: CircularProgressIndicator(color: kGold))
            : _error != null
            ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.wifi_off, color: kMuted, size: 48),
          const SizedBox(height: 12),
          Text(t(_lang, 'error_load'), style: const TextStyle(color: kText)),
          const SizedBox(height: 8),
          GestureDetector(
              onTap: () { setState(() { _loading = true; _error = null; }); _load(); },
              child: Text(t(_lang, 'retry'), style: const TextStyle(color: kGold))),
        ]))
            : _filtered.isEmpty
            ? Center(child: Text(t(_lang, 'no_results'),
            style: const TextStyle(color: kMuted)))
            : ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 80),
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
      onTap: () => Navigator.push(context, MaterialPageRoute(
          builder: (_) => PlayerScreen(place: place, lang: lang))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: kSurface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: kBorder)),
        child: Row(children: [
          Container(width: 32, height: 32,
              decoration: BoxDecoration(
                  color: kSurface2,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: kBorder)),
              child: Center(child: Text(num,
                  style: const TextStyle(
                      fontSize: 11, color: kMuted, fontWeight: FontWeight.w500)))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(place.nombre(lang),
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w500, color: kText),
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text('${place.barrio} · ${place.epoca}',
                style: const TextStyle(fontSize: 11, color: kMuted)),
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

  // Capas disponibles según ciudad (Paris añade gastronomia y cine_literatura)
  List<String> get _capas => widget.place.capasDisponibles();

  // Para Paris, FR lee de la columna DE en las capas base; gastronomia/cine usan FR real
  String get _effectiveLang {
    if (_lang == 'fr' && widget.place.ciudad == 'Paris') return 'de';
    return _lang;
  }

  @override
  void initState() {
    super.initState();
    _lang = widget.lang;
    // Reset lang si no está disponible para esta ciudad
    if (widget.place.ciudad == 'Paris' && (_lang == 'de' || _lang == 'it')) _lang = 'es';
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
    _loadPhoto();
  }

  @override
  void dispose() { _player.dispose(); super.dispose(); }

  Future<void> _loadPhoto() async {
    setState(() => _loadingPhoto = true);
    // Para París: nombre en FR está en la columna DE del modelo
    final nameFR = widget.place.ciudad == 'Paris'
        ? (widget.place.nombres['de'] ?? '')
        : '';
    final url = await fetchWikipediaPhoto(
      widget.place.wikipediaEN,
      nameEN: widget.place.nombres['en'] ?? '',
      nameFR: nameFR,
    );
    if (mounted) setState(() { _photoUrl = url; _loadingPhoto = false; });
  }

  Future<void> _loadAudio() async {
    // Para Paris FR, usa el audio DE (misma columna); audios Paris aún pendientes
    final baseUrl = widget.place.audios[_effectiveLang] ?? '';
    if (baseUrl.isEmpty) return;
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
    if (_playing) { await _player.pause(); } else { await _player.play(); }
  }

  Color get _capaColor => kCapaColors[_capa] ?? kGold;

  @override
  Widget build(BuildContext context) {
    final texto = widget.place.textoParaCapa(_capa, _lang);
    final progress = _dur.inMilliseconds > 0
        ? (_pos.inMilliseconds / _dur.inMilliseconds).clamp(0.0, 1.0) : 0.0;
    final availableLangs = widget.place.idiomasDisponibles();

    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(child: Column(children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), color: kSurface,
          child: Row(children: [
            GestureDetector(
                onTap: () { _player.stop(); Navigator.pop(context); },
                child: Container(width: 36, height: 36,
                    decoration: BoxDecoration(
                        border: Border.all(color: kBorder),
                        borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.arrow_back, color: kText, size: 18))),
            const SizedBox(width: 12),
            Expanded(child: Text(widget.place.nombre(_lang),
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600, color: kText),
                overflow: TextOverflow.ellipsis)),
            const SizedBox(width: 8),
            langPill(_lang, _selectLang, langs: availableLangs),
          ]),
        ),
        Expanded(child: SingleChildScrollView(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _buildPhoto(),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('${t(_lang, 'place')} ${widget.place.id.split('_').last} · ${widget.place.epoca}',
                    style: const TextStyle(fontSize: 10, color: kGold, letterSpacing: 2)),
                const SizedBox(height: 4),
                Text(widget.place.nombre(_lang),
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold, color: kText)),
                const SizedBox(height: 2),
                Text('${widget.place.barrio} · ${widget.place.ciudad}',
                    style: const TextStyle(fontSize: 12, color: kMuted)),
              ]),
            ),
            // ── PESTAÑAS (dinámicas: 4 para Berlín, hasta 6 para París) ──
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
                    child: Text(t(_lang, 'capa_$c'),
                        style: TextStyle(
                            fontSize: 12,
                            color: active ? color : kMuted,
                            fontWeight: active ? FontWeight.w600 : FontWeight.normal)),
                  ),
                );
              }).toList()),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: kSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: kBorder)),
              child: Column(children: [
                Row(children: [
                  Container(width: 8, height: 8,
                      decoration: BoxDecoration(color: _capaColor, shape: BoxShape.circle)),
                  const SizedBox(width: 8),
                  Text(t(_lang, 'capa_$_capa').toUpperCase(),
                      style: TextStyle(
                          fontSize: 10, color: _capaColor,
                          letterSpacing: 2, fontWeight: FontWeight.w600)),
                  const Spacer(),
                  if (_playing) Row(children: [
                    _bar(12), const SizedBox(width: 2),
                    _bar(8),  const SizedBox(width: 2),
                    _bar(12),
                  ]),
                ]),
                const SizedBox(height: 14),
                Row(children: [
                  GestureDetector(
                      onTap: _togglePlay,
                      child: Container(
                          width: 52, height: 52,
                          decoration: BoxDecoration(color: _capaColor, shape: BoxShape.circle),
                          child: Icon(_playing ? Icons.pause : Icons.play_arrow,
                              color: Colors.white, size: 24))),
                  const SizedBox(width: 14),
                  Expanded(child: Column(children: [
                    SliderTheme(
                      data: SliderThemeData(
                          trackHeight: 4,
                          activeTrackColor: _capaColor,
                          inactiveTrackColor: kSurface2,
                          thumbColor: _capaColor),
                      child: Slider(value: progress, onChanged: (v) {
                        if (_dur == Duration.zero) return;
                        _player.seek(Duration(
                            milliseconds: (_dur.inMilliseconds * v).round()));
                      }),
                    ),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text(_fmtTime(_pos),
                          style: const TextStyle(fontSize: 11, color: kMuted)),
                      Text(_fmtTime(_dur),
                          style: const TextStyle(fontSize: 11, color: kMuted)),
                    ]),
                  ])),
                ]),
              ]),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: kSurface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: kBorder)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Container(width: 4, height: 16,
                      decoration: BoxDecoration(
                          color: _capaColor,
                          borderRadius: BorderRadius.circular(2))),
                  const SizedBox(width: 8),
                  Text(t(_lang, 'capa_$_capa').toUpperCase(),
                      style: TextStyle(
                          fontSize: 10, color: _capaColor,
                          letterSpacing: 2, fontWeight: FontWeight.w600)),
                ]),
                const SizedBox(height: 12),
                texto.isEmpty
                    ? Text(t(_lang, 'no_text'),
                    style: const TextStyle(color: kMuted, fontSize: 14))
                    : Text(texto,
                    style: const TextStyle(
                        fontSize: 14, color: Color(0xFFc8c4bc), height: 1.8)),
              ]),
            ),
          ]),
        )),
      ])),
    );
  }

  Widget _buildPhoto() {
    if (_loadingPhoto) {
      return Container(height: 200, color: kSurface2,
          child: const Center(
              child: CircularProgressIndicator(color: kGold, strokeWidth: 2)));
    }
    if (_photoUrl == null) {
      return Container(height: 160, color: kSurface2,
          child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.image_not_supported_outlined, color: kMuted, size: 32),
            const SizedBox(height: 8),
            Text(t(_lang, 'no_photo'),
                style: const TextStyle(color: kMuted, fontSize: 12)),
          ])));
    }
    return Stack(children: [
      Image.network(_photoUrl!, width: double.infinity, height: 220, fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(height: 160, color: kSurface2,
              child: const Center(
                  child: Icon(Icons.image_not_supported_outlined,
                      color: kMuted, size: 32)))),
      Positioned(bottom: 0, left: 0, right: 0,
          child: Container(height: 60,
              decoration: BoxDecoration(gradient: LinearGradient(
                  begin: Alignment.topCenter, end: Alignment.bottomCenter,
                  colors: [Colors.transparent, kBg.withOpacity(0.8)])))),
      Positioned(top: 12, right: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
                color: Colors.black54, borderRadius: BorderRadius.circular(8)),
            child: Row(children: [
              const Icon(Icons.history, color: kGold, size: 12),
              const SizedBox(width: 4),
              Text(t(_lang, 'historic_photo'),
                  style: const TextStyle(
                      color: kGold, fontSize: 10, fontWeight: FontWeight.w500)),
            ]),
          )),
    ]);
  }

  Widget _bar(double h) => Container(
      width: 3, height: h,
      decoration: BoxDecoration(
          color: _capaColor, borderRadius: BorderRadius.circular(2)));
}
