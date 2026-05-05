import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'widgets.dart';

// ── TRADUCCIONES NOMBRES DE TOURS TEMÁTICOS ──────────────────
const kTourNames = <String, Map<String, String>>{
  'miedo1': {
    'es': 'Tour del Miedo I — El Bunker y el Terror',
    'en': 'Fear Tour I — The Bunker and the Terror',
    'de': 'Angst-Tour I — Der Bunker und der Terror',
    'it': 'Tour della Paura I — Il Bunker e il Terrore',
  },
  'clasico1': {
    'es': 'Tour Clásico I — El Berlín Prusiano',
    'en': 'Classic Tour I — Prussian Berlin',
    'de': 'Klassik-Tour I — Das Preußische Berlin',
    'it': 'Tour Classico I — La Berlino Prussiana',
  },
  'miedo2': {
    'es': 'Tour del Miedo II — El Poder Nazi en Mitte',
    'en': 'Fear Tour II — Nazi Power in Mitte',
    'de': 'Angst-Tour II — Die Nazi-Macht in Mitte',
    'it': 'Tour della Paura II — Il Potere Nazista a Mitte',
  },
  'guerrafria2': {
    'es': 'Tour Guerra Fría II — El Muro del Sur',
    'en': 'Cold War Tour II — The Southern Wall',
    'de': 'Kalter Krieg Tour II — Die Südliche Mauer',
    'it': 'Tour Guerra Fredda II — Il Muro Sud',
  },
  'clasico2': {
    'es': 'Tour Clásico II — El Berlín Imperial',
    'en': 'Classic Tour II — Imperial Berlin',
    'de': 'Klassik-Tour II — Das Imperiale Berlin',
    'it': 'Tour Classico II — La Berlino Imperiale',
  },
  'guerrafria1': {
    'es': 'Tour Guerra Fría I — El Muro del Norte',
    'en': 'Cold War Tour I — The Northern Wall',
    'de': 'Kalter Krieg Tour I — Die Nördliche Mauer',
    'it': 'Tour Guerra Fredda I — Il Muro Nord',
  },
  'romantico': {
    'es': 'Tour Romántico — Berlín Enamorada',
    'en': 'Romantic Tour — Berlin in Love',
    'de': 'Romantik-Tour — Berlin Verliebt',
    'it': 'Tour Romantico — Berlino Innamorata',
  },
  'museos': {
    'es': 'Tour Isla de los Museos — El Mundo en Una Isla',
    'en': 'Museum Island Tour — The World on One Island',
    'de': 'Museumsinsel-Tour — Die Welt auf einer Insel',
    'it': 'Tour Isola dei Musei — Il Mondo in un\'Isola',
  },
  'misterio': {
    'es': 'Tour Misterio — La Ciudad Oculta',
    'en': 'Mystery Tour — The Hidden City',
    'de': 'Mysterien-Tour — Die Verborgene Stadt',
    'it': 'Tour Mistero — La Città Nascosta',
  },
  'arte': {
    'es': 'Tour Arte — El Laboratorio del Siglo XX',
    'en': 'Art Tour — The Laboratory of the 20th Century',
    'de': 'Kunst-Tour — Das Labor des 20. Jahrhunderts',
    'it': 'Tour Arte — Il Laboratorio del XX Secolo',
  },
  'musica1': {
    'es': 'Tour Música I — Cabarets y Ópera',
    'en': 'Music Tour I — Cabarets and Opera',
    'de': 'Musik-Tour I — Kabaretts und Oper',
    'it': 'Tour Musica I — Cabaret e Opera',
  },
  'musica2': {
    'es': 'Tour Música II — El Techno Post-Muro',
    'en': 'Music Tour II — Post-Wall Techno',
    'de': 'Musik-Tour II — Post-Mauer Techno',
    'it': 'Tour Musica II — Il Techno Post-Muro',
  },
};

String tourName(String tourTipo, String lang) =>
    kTourNames[tourTipo]?[lang] ?? kTourNames[tourTipo]?['es'] ?? tourTipo;

// ── TRADUCCIONES MODO SORPRESA ────────────────────────────────
const kTS = {
  'es': {
    'title':          '✨ Modo Sorpréndeme',
    'choose_guide':   'Elige tu guía',
    'subtitle':       'Berlín vista a través de ojos únicos.',
    'subtitle_paris': 'París vista a través de ojos únicos.',
    'soon':           'Pronto',
    'start':          'Comenzar la experiencia →',
    'mode_label':     '✨ MODO SORPRESA',
    'clue':           '🔍 PISTA',
    'branch_label':   '⚡ BIFURCACIÓN',
    'who_is':         '¿Quién eres?',
    'branch_a_title': 'Camino A',
    'branch_a_desc':  'Primera opción',
    'branch_b_title': 'Camino B',
    'branch_b_desc':  'Segunda opción',
    'near_stop':      '¡Estás en el lugar!',
    'walk_to':        'Camina hacia',
    'next':           'Siguiente →',
    'next_stop':      'Siguiente parada →',
    'end_title':      'Fin de la historia',
    'end_sub':        'Gracias por caminar con nosotros.',
    'back_home':      'Volver al inicio',
    'your_location':  'Tu ubicación',
    'stops':          'paradas',
    'min':            'min',
    'km':             'km',
    'approx':         'aprox.',
    'story':          '📖 HISTORIA',
    'read_story':     'Leer la historia',
    'close':          'Cerrar',
    'nearest':        'Más cercano',
    'see_map':        'Ver mapa',
    'see_list':       'Ver lista',
    'subtitle_roma':  'Roma vista a través de ojos únicos.',
  },
  'en': {
    'title':          '✨ Surprise Me',
    'choose_guide':   'Choose your guide',
    'subtitle':       'Berlin seen through unique eyes.',
    'subtitle_paris': 'Paris seen through unique eyes.',
    'soon':           'Soon',
    'start':          'Begin the experience →',
    'mode_label':     '✨ SURPRISE MODE',
    'clue':           '🔍 CLUE',
    'branch_label':   '⚡ CROSSROADS',
    'who_is':         'Who are you?',
    'branch_a_title': 'Path A',
    'branch_a_desc':  'First option',
    'branch_b_title': 'Path B',
    'branch_b_desc':  'Second option',
    'near_stop':      'You are here!',
    'walk_to':        'Walk to',
    'next':           'Next →',
    'next_stop':      'Next stop →',
    'end_title':      'End of the story',
    'end_sub':        'Thank you for walking with us.',
    'back_home':      'Back to home',
    'your_location':  'Your location',
    'stops':          'stops',
    'min':            'min',
    'km':             'km',
    'approx':         'approx.',
    'story':          '📖 STORY',
    'read_story':     'Read the story',
    'close':          'Close',
    'nearest':        'Nearest',
    'see_map':        'See map',
    'see_list':       'See list',
    'subtitle_roma':  'Rome seen through unique eyes.',
  },
  'de': {
    'title':          '✨ Überrasch mich',
    'choose_guide':   'Wähle deinen Guide',
    'subtitle':       'Berlin durch einzigartige Augen gesehen.',
    'subtitle_paris': 'Paris durch einzigartige Augen gesehen.',
    'soon':           'Bald',
    'start':          'Erlebnis beginnen →',
    'mode_label':     '✨ ÜBERRASCHUNGS-MODUS',
    'clue':           '🔍 HINWEIS',
    'branch_label':   '⚡ WEGSCHEIDE',
    'who_is':         'Wer bist du?',
    'branch_a_title': 'Weg A',
    'branch_a_desc':  'Erste Option',
    'branch_b_title': 'Weg B',
    'branch_b_desc':  'Zweite Option',
    'near_stop':      'Du bist hier!',
    'walk_to':        'Geh zu',
    'next':           'Weiter →',
    'next_stop':      'Nächste Station →',
    'end_title':      'Ende der Geschichte',
    'end_sub':        'Danke, dass du mit uns gelaufen bist.',
    'back_home':      'Zurück zum Start',
    'your_location':  'Dein Standort',
    'stops':          'Stationen',
    'min':            'Min',
    'km':             'km',
    'approx':         'ca.',
    'story':          '📖 GESCHICHTE',
    'read_story':     'Geschichte lesen',
    'close':          'Schließen',
    'nearest':        'Am nächsten',
    'see_map':        'Karte ansehen',
    'see_list':       'Liste ansehen',
    'subtitle_roma':  'Rom durch einzigartige Augen gesehen.',
  },
  'it': {
    'title':          '✨ Sorprendimi',
    'choose_guide':   'Scegli la tua guida',
    'subtitle':       'Berlino vista attraverso occhi unici.',
    'subtitle_paris': 'Parigi vista attraverso occhi unici.',
    'soon':           'Presto',
    'start':          'Inizia l\'esperienza →',
    'mode_label':     '✨ MODALITÀ SORPRESA',
    'clue':           '🔍 INDIZIO',
    'branch_label':   '⚡ BIVIO',
    'who_is':         'Chi sei?',
    'branch_a_title': 'Percorso A',
    'branch_a_desc':  'Prima opzione',
    'branch_b_title': 'Percorso B',
    'branch_b_desc':  'Seconda opzione',
    'near_stop':      'Sei qui!',
    'walk_to':        'Cammina verso',
    'next':           'Avanti →',
    'next_stop':      'Prossima tappa →',
    'end_title':      'Fine della storia',
    'end_sub':        'Grazie per aver camminato con noi.',
    'back_home':      'Torna all\'inizio',
    'your_location':  'La tua posizione',
    'stops':          'tappe',
    'min':            'min',
    'km':             'km',
    'approx':         'circa',
    'story':          '📖 STORIA',
    'read_story':     'Leggi la storia',
    'close':          'Chiudi',
    'nearest':        'Più vicino',
    'see_map':        'Vedi mappa',
    'see_list':       'Vedi lista',
    'subtitle_roma':  'Roma vista attraverso occhi unici.',
  },
};

String ts(String lang, String key) =>
    kTS[lang]?[key] ?? kTS['es']![key] ?? key;


// ── FETCH TEXTOS SORPRESA DESDE GOOGLE SHEETS ────────────────
const _kSorpresaSheetId = '1K1iMpmKiYMC3A05V9byG1duokRJK-2eYMQKti_wc2Fg';

Future<Map<String, Map<String, String>>> fetchSorpresaTexts() async {
  const url = 'https://docs.google.com/spreadsheets/d/1K1iMpmKiYMC3A05V9byG1duokRJK-2eYMQKti_wc2Fg/gviz/tq?tqx=out:json&sheet=Modo_Sorpresa';
  try {
    final res = await http.get(Uri.parse(url));
    if (res.statusCode != 200) return {};
    String body = res.body;
    final start = body.indexOf('{');
    final end   = body.lastIndexOf('}');
    if (start == -1 || end == -1) return {};
    body = body.substring(start, end + 1);
    final data = json.decode(body);
    final rows = data['table']['rows'] as List;
    final textos = <String, Map<String, String>>{};
    for (final row in rows) {
      final cells = row['c'] as List;
      String cell(int i) {
        if (i >= cells.length || cells[i] == null) return '';
        final v = cells[i]['v'];
        return v?.toString().trim() ?? '';
      }
      final id = cell(0);
      if (id.isEmpty) continue;
      textos[id] = {
        'ES': cell(8),
        'EN': cell(9),
        'DE': cell(11),
        'IT': cell(12),
      };
    }
    return textos;
  } catch (_) {
    return {};
  }
}

String sorpresaStopText(String stopId, String lang, Map<String, Map<String, String>> textos) {
  final map = textos[stopId];
  if (map == null) return '';
  switch (lang) {
    case 'en': return map['EN']?.isNotEmpty == true ? map['EN']! : map['ES'] ?? '';
    case 'de': return map['DE']?.isNotEmpty == true ? map['DE']! : map['ES'] ?? '';
    case 'it': return map['IT']?.isNotEmpty == true ? map['IT']! : map['ES'] ?? '';
    default:   return map['ES'] ?? '';
  }
}

// ── MODELO SORPRESA ───────────────────────────────────────────
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
  final String id, name, emoji;
  final String desc;
  final String resumenES, resumenEN, resumenDE, resumenIT;
  final String r2Base;
  final List<SorpresaStop> stops;
  final String branchATitle, branchADesc, branchBTitle, branchBDesc;
  final int duracionMin;
  final double distanciaKm;
  final String? introStopId;
  final List<String> storyLangs;

  const SorpresaPersonaje({
    required this.id,
    required this.name,
    required this.emoji,
    required this.desc,
    required this.resumenES,
    required this.resumenEN,
    required this.resumenDE,
    required this.resumenIT,
    required this.r2Base,
    required this.stops,
    required this.duracionMin,
    required this.distanciaKm,
    this.branchATitle = 'Camino A',
    this.branchADesc  = '',
    this.branchBTitle = 'Camino B',
    this.branchBDesc  = '',
    this.introStopId,
    this.storyLangs = const ['es', 'en', 'de', 'it'],
  });

  List<SorpresaStop> get contentStops =>
      introStopId != null ? stops.where((s) => s.id != introStopId).toList() : stops;

  SorpresaStop? get introStop =>
      introStopId != null ? stops.where((s) => s.id == introStopId).firstOrNull : null;

  String resumen(String lang) {
    switch (lang) {
      case 'en': return resumenEN;
      case 'de': return resumenDE;
      case 'it': return resumenIT;
      default:   return resumenES;
    }
  }

  String duracionLabel(String lang) {
    final m = duracionMin;
    if (m < 60) return '~$m ${ts(lang, 'min')}';
    final h = m ~/ 60;
    final rem = m % 60;
    if (rem == 0) return '~${h}h';
    return '~${h}h ${rem}${ts(lang, 'min')}';
  }
}

// ── LENA HOFFMANN ─────────────────────────────────────────────
const kLena = SorpresaPersonaje(
  id: 'lena',
  name: 'Lena Hoffmann',
  emoji: '💃',
  desc: 'Cantante de cabaret · Berlín 1925–1933',
  resumenES: 'Berlín, 1925. Lena tiene veintidós años y canta en el Silhouetten, el cabaret de la Friedrichstrasse. En 1933 llega una bifurcación que cambiará su vida: ¿irse con Heinrich a París o quedarse en la ciudad que la hizo?',
  resumenEN: 'Berlin, 1925. Lena is twenty-two and sings at the Silhouetten cabaret on Friedrichstrasse. In 1933 a crossroads arrives that will change everything: leave with Heinrich for Paris, or stay in the city that made her?',
  resumenDE: 'Berlin, 1925. Lena ist zweiundzwanzig und singt im Silhouetten-Kabarett in der Friedrichstraße. 1933 kommt eine Weggabelung: Mit Heinrich nach Paris gehen oder in der Stadt bleiben, die sie geprägt hat?',
  resumenIT: 'Berlino, 1925. Lena ha ventidue anni e canta al Silhouetten, il cabaret della Friedrichstrasse. Nel 1933 arriva un bivio che cambierà tutto: partire con Heinrich per Parigi o restare nella città che l\'ha formata?',
  r2Base: 'https://pub-b20ae9c7d6c140aa868ea5aba6210b5f.r2.dev/audios/sorpresa/berlin/lena/v4/',
  duracionMin: 123,
  distanciaKm: 5.2,
  branchATitle: 'La que escapó',
  branchADesc:  'Parte con Heinrich a París',
  branchBTitle: 'La que se quedó',
  branchBDesc:  'Se queda en Berlín',
  stops: [
    SorpresaStop(id: 'lena_01', branch: 'shared', lugar: 'Nueva Sinagoga',          lat: 52.5249, lng: 13.3942),
    SorpresaStop(id: 'lena_02', branch: 'shared', lugar: 'Monbijoupark',            lat: 52.5231, lng: 13.3963),
    SorpresaStop(id: 'lena_03', branch: 'shared', lugar: 'Bode Museum',             lat: 52.5212, lng: 13.3969),
    SorpresaStop(id: 'lena_04', branch: 'shared', lugar: 'Berliner Dom',            lat: 52.5190, lng: 13.4014),
    SorpresaStop(id: 'lena_05', branch: 'shared', lugar: 'Staatsoper / Bebelplatz', lat: 52.5168, lng: 13.3933),
    SorpresaStop(id: 'lena_06', branch: 'shared', lugar: 'Neue Wache',              lat: 52.5175, lng: 13.3971),
    SorpresaStop(id: 'lena_07a', branch: 'A', lugar: 'Memorial del Holocausto',    lat: 52.5138, lng: 13.3788),
    SorpresaStop(id: 'lena_08a', branch: 'A', lugar: 'Puerta de Brandenburgo',     lat: 52.5163, lng: 13.3777),
    SorpresaStop(id: 'lena_09a', branch: 'A', lugar: 'Columna de la Victoria',     lat: 52.5145, lng: 13.3501),
    SorpresaStop(id: 'lena_07b', branch: 'B', lugar: 'Lustgarten',                 lat: 52.5190, lng: 13.4014),
    SorpresaStop(id: 'lena_08b', branch: 'B', lugar: 'Neues Museum (Nefertiti)',   lat: 52.5206, lng: 13.3979),
    SorpresaStop(id: 'lena_09b', branch: 'B', lugar: 'Pergamon Panorama',          lat: 52.5211, lng: 13.3963),
  ],
);

// ── KLAUS BRENNER ─────────────────────────────────────────────
const kKlaus = SorpresaPersonaje(
  id: 'klaus',
  name: 'Klaus Brenner',
  emoji: '🕵️',
  desc: 'Detective del Este · Berlín 1975',
  resumenES: 'Berlín Oriental, 1975. Klaus es detective en la Volkspolizei y lleva años ignorando lo que no quiere ver. Hasta que un caso lo lleva demasiado cerca de la Stasi. ¿Colaborar o resistir?',
  resumenEN: 'East Berlin, 1975. Klaus is a detective in the Volkspolizei who has spent years ignoring what he does not want to see. Until a case brings him too close to the Stasi. Collaborate or resist?',
  resumenDE: 'Ost-Berlin, 1975. Klaus ist Kriminaldetektiv bei der Volkspolizei und hat jahrelang weggesehen. Bis ihn ein Fall zu nah an die Stasi heranführt. Kollaborieren oder widerstehen?',
  resumenIT: 'Berlino Est, 1975. Klaus è detective della Volkspolizei e da anni fa finta di non vedere. Finché un caso lo porta troppo vicino alla Stasi. Collaborare o resistere?',
  r2Base: 'https://pub-b20ae9c7d6c140aa868ea5aba6210b5f.r2.dev/audios/sorpresa/berlin/klaus/v1/',
  duracionMin: 107,
  distanciaKm: 4.2,
  branchATitle: 'El que traicionó',
  branchADesc:  'Colabora con la Stasi',
  branchBTitle: 'El que resistió',
  branchBDesc:  'Se niega a delatar',
  stops: [
    SorpresaStop(id: 'klaus_01', branch: 'shared', lugar: 'Alexanderplatz',         lat: 52.5219, lng: 13.4132),
    SorpresaStop(id: 'klaus_02', branch: 'shared', lugar: 'Fernsehturm',            lat: 52.5208, lng: 13.4094),
    SorpresaStop(id: 'klaus_03', branch: 'shared', lugar: 'Marx-Engels-Forum',      lat: 52.5188, lng: 13.4044),
    SorpresaStop(id: 'klaus_04', branch: 'shared', lugar: 'Nikolaiviertel',         lat: 52.5161, lng: 13.4068),
    SorpresaStop(id: 'klaus_05', branch: 'shared', lugar: 'Rotes Rathaus',          lat: 52.5175, lng: 13.4083),
    SorpresaStop(id: 'klaus_06', branch: 'shared', lugar: 'Gendarmenmarkt',         lat: 52.5135, lng: 13.3933),
    SorpresaStop(id: 'klaus_07a', branch: 'A', lugar: 'Bebelplatz',                lat: 52.5168, lng: 13.3933),
    SorpresaStop(id: 'klaus_08a', branch: 'A', lugar: 'Neue Wache',                lat: 52.5175, lng: 13.3971),
    SorpresaStop(id: 'klaus_09a', branch: 'A', lugar: 'Checkpoint Charlie',         lat: 52.5075, lng: 13.3904),
    SorpresaStop(id: 'klaus_07b', branch: 'B', lugar: 'Bebelplatz',                lat: 52.5168, lng: 13.3933),
    SorpresaStop(id: 'klaus_08b', branch: 'B', lugar: 'Neue Wache',                lat: 52.5175, lng: 13.3971),
    SorpresaStop(id: 'klaus_09b', branch: 'B', lugar: 'Nikolaiviertel (regreso)',   lat: 52.5161, lng: 13.4068),
  ],
);

// ── CLARA ─────────────────────────────────────────────────────
const kClara = SorpresaPersonaje(
  id: 'clara',
  name: 'Clara',
  emoji: '📖',
  desc: '9 años en el Berlín de posguerra · 1946',
  resumenES: 'Berlín, primavera de 1946. Clara tiene nueve años y tres cuartos. En una ciudad todavía en ruinas, una niña recorre los lugares más cargados de historia de Berlín. Y en un sótano, encuentra algo que nadie quería que encontrara.',
  resumenEN: "Berlin, spring 1946. Clara is nine and three-quarters. In a city still in ruins, a girl walks through Berlin's most history-laden places. And in a basement, she finds something no one wanted her to find.",
  resumenDE: 'Berlin, Frühjahr 1946. Clara ist neun Jahre und drei Viertel alt. In einer Stadt noch in Trümmern geht ein Mädchen durch die geschichtsträchtigsten Orte Berlins. Und in einem Keller findet sie etwas, das niemand wollte, dass sie es findet.',
  resumenIT: 'Berlino, primavera del 1946. Clara ha nove anni e tre quarti. In una città ancora in macerie, una bambina percorre i luoghi più carichi di storia di Berlino. E in una cantina trova qualcosa che nessuno voleva che trovasse.',
  r2Base: 'https://pub-b20ae9c7d6c140aa868ea5aba6210b5f.r2.dev/audios/sorpresa/berlin/clara/v1/',
  duracionMin: 100,
  distanciaKm: 3.7,
  branchATitle: 'La que lo contó',
  branchADesc:  'Decide contar lo que encontró',
  branchBTitle: 'La que lo guardó',
  branchBDesc:  'Decide guardar el secreto',
  stops: [
    SorpresaStop(id: 'clara_01', branch: 'shared', lugar: 'Anhalter Bahnhof',        lat: 52.5047, lng: 13.3817),
    SorpresaStop(id: 'clara_02', branch: 'shared', lugar: 'Topographie des Terrors', lat: 52.5062, lng: 13.3828),
    SorpresaStop(id: 'clara_03', branch: 'shared', lugar: 'Checkpoint Charlie',      lat: 52.5075, lng: 13.3904),
    SorpresaStop(id: 'clara_04', branch: 'shared', lugar: 'Gendarmenmarkt',          lat: 52.5135, lng: 13.3933),
    SorpresaStop(id: 'clara_05', branch: 'shared', lugar: 'Bebelplatz',              lat: 52.5168, lng: 13.3933),
    SorpresaStop(id: 'clara_06', branch: 'shared', lugar: 'Unter den Linden 17',     lat: 52.5171, lng: 13.3910),
    SorpresaStop(id: 'clara_07a', branch: 'A', lugar: 'Neue Wache',                 lat: 52.5175, lng: 13.3971),
    SorpresaStop(id: 'clara_08a', branch: 'A', lugar: 'Lustgarten',                 lat: 52.5190, lng: 13.4014),
    SorpresaStop(id: 'clara_09a', branch: 'A', lugar: 'Berliner Dom',               lat: 52.5190, lng: 13.4014),
    SorpresaStop(id: 'clara_07b', branch: 'B', lugar: 'Nikolaiviertel',             lat: 52.5161, lng: 13.4068),
    SorpresaStop(id: 'clara_08b', branch: 'B', lugar: 'Marx-Engels-Forum',          lat: 52.5188, lng: 13.4044),
    SorpresaStop(id: 'clara_09b', branch: 'B', lugar: 'Rotes Rathaus',              lat: 52.5175, lng: 13.4083),
  ],
);

// ── OTTO FISCHER ──────────────────────────────────────────────
const kOtto = SorpresaPersonaje(
  id: 'otto',
  name: 'Otto Fischer',
  emoji: '📄',
  desc: 'Funcionario del Estado · Berlín 9N 1989',
  resumenES: 'Berlín Oriental, 9 de noviembre de 1989. Otto es un funcionario del Ministerio de Información. Esa tarde tiene que leer un decreto en una rueda de prensa. No lo ha leído bien. Lo que pase en las próximas horas cambiará la historia de Berlín.',
  resumenEN: 'East Berlin, 9 November 1989. Otto is a Ministry of Information official. That afternoon he has to read a decree at a press conference. He has not read it carefully enough. What happens in the next few hours will change the history of Berlin.',
  resumenDE: 'Ost-Berlin, 9. November 1989. Otto ist Beamter im Ministerium für Information. An diesem Nachmittag muss er auf einer Pressekonferenz ein Dekret verlesen. Er hat es nicht sorgfältig genug gelesen. Was in den nächsten Stunden passiert, wird die Geschichte Berlins verändern.',
  resumenIT: 'Berlino Est, 9 novembre 1989. Otto è un funzionario del Ministero dell\'Informazione. Nel pomeriggio deve leggere un decreto in una conferenza stampa. Non l\'ha letto con abbastanza attenzione. Quello che accadrà nelle prossime ore cambierà la storia di Berlino.',
  r2Base: 'https://pub-b20ae9c7d6c140aa868ea5aba6210b5f.r2.dev/audios/sorpresa/berlin/otto/v1/',
  duracionMin: 95,
  distanciaKm: 3.8,
  branchATitle: 'El que fue al Muro',
  branchADesc:  'Va a ver lo que provocó',
  branchBTitle: 'El que se quedó',
  branchBDesc:  'Observa desde la distancia',
  stops: [
    SorpresaStop(id: 'otto_01', branch: 'shared', lugar: 'Alexanderplatz',              lat: 52.5219, lng: 13.4133),
    SorpresaStop(id: 'otto_02', branch: 'shared', lugar: 'Fernsehturm',                 lat: 52.5208, lng: 13.4094),
    SorpresaStop(id: 'otto_03', branch: 'shared', lugar: 'Marx-Engels-Forum',           lat: 52.5185, lng: 13.4046),
    SorpresaStop(id: 'otto_04', branch: 'shared', lugar: 'Humboldt Forum',              lat: 52.5172, lng: 13.4017),
    SorpresaStop(id: 'otto_05', branch: 'shared', lugar: 'Nikolaiviertel',              lat: 52.5174, lng: 13.4070),
    SorpresaStop(id: 'otto_06', branch: 'shared', lugar: 'Rotes Rathaus',               lat: 52.5183, lng: 13.4086),
    SorpresaStop(id: 'otto_07a', branch: 'A',     lugar: 'Tränenpalast',                lat: 52.5209, lng: 13.3872),
    SorpresaStop(id: 'otto_08a', branch: 'A',     lugar: 'Friedrichstadtpalast',        lat: 52.5239, lng: 13.3888),
    SorpresaStop(id: 'otto_09a', branch: 'A',     lugar: 'Neue Wache',                  lat: 52.5175, lng: 13.3971),
    SorpresaStop(id: 'otto_07b', branch: 'B',     lugar: 'Gendarmenmarkt',              lat: 52.5135, lng: 13.3933),
    SorpresaStop(id: 'otto_08b', branch: 'B',     lugar: 'Bebelplatz',                  lat: 52.5168, lng: 13.3933),
    SorpresaStop(id: 'otto_09b', branch: 'B',     lugar: 'Staatsoper Unter den Linden', lat: 52.5163, lng: 13.3933),
  ],
);

// ── VICTOR HUGO ───────────────────────────────────────────────
const kVictor = SorpresaPersonaje(
  id: 'victor',
  name: 'Victor Hugo',
  emoji: '✍️',
  desc: 'Escritor y diputado · París 1848',
  resumenES: 'Soy Victor Hugo. Es el 26 de junio de 1848. He pasado la noche entre barricadas. Soy diputado de la Segunda República y el autor de Notre-Dame de París. Esta mañana no sé cuál de esas dos cosas pesa más sobre mi conciencia.',
  resumenEN: 'Soy Victor Hugo. Es el 26 de junio de 1848. He pasado la noche entre barricadas. Soy diputado de la Segunda República y el autor de Notre-Dame de París. Esta mañana no sé cuál de esas dos cosas pesa más sobre mi conciencia.',
  resumenDE: 'Ich bin Victor Hugo. Es ist der sechsundzwanzigste Juni achtzehnhundertachtundvierzig. Ich habe die Nacht zwischen den Barrikaden verbracht. Ich bin Abgeordneter der Zweiten Republik und der Autor von Notre-Dame de Paris. Heute Morgen weiß ich nicht, welches dieser beiden Dinge schwerer auf meinem Gewissen lastet.',
  resumenIT: 'Soy Victor Hugo. Es el 26 de junio de 1848. He pasado la noche entre barricadas. Soy diputado de la Segunda República y el autor de Notre-Dame de París. Esta mañana no sé cuál de esas dos cosas pesa más sobre mi conciencia.',
  r2Base: 'https://pub-b20ae9c7d6c140aa868ea5aba6210b5f.r2.dev/audios/sorpresa/paris/hugo/v1/',
  introStopId: 'paris_surprise_hugo_00',
  storyLangs: ['es', 'en'],
  duracionMin: 120,
  distanciaKm: 4.8,
  branchATitle: 'El camino del Père Lachaise',
  branchADesc:  'Norte, hacia el cementerio',
  branchBTitle: 'El camino de la Bastille',
  branchBDesc:  'Sur, por la Rue de Charonne',
  stops: [
    SorpresaStop(id: 'paris_surprise_hugo_00', branch: 'shared', lugar: 'Introducción Hugo',         lat: 48.8554, lng: 2.3645),
    SorpresaStop(id: 'paris_surprise_hugo_01', branch: 'shared', lugar: 'Place des Vosges',          lat: 48.8553, lng: 2.3644),
    SorpresaStop(id: 'paris_surprise_hugo_02', branch: 'shared', lugar: 'Rue Saint-Antoine',         lat: 48.8541, lng: 2.3608),
    SorpresaStop(id: 'paris_surprise_hugo_03', branch: 'shared', lugar: 'Rue de la Bastille',        lat: 48.8530, lng: 2.3665),
    SorpresaStop(id: 'paris_surprise_hugo_04', branch: 'shared', lugar: 'Place de la Bastille',      lat: 48.8533, lng: 2.3692),
    SorpresaStop(id: 'paris_surprise_hugo_05', branch: 'shared', lugar: 'Rue de la Roquette',        lat: 48.8526, lng: 2.3737),
    SorpresaStop(id: 'paris_surprise_hugo_06', branch: 'shared', lugar: 'Square de la Roquette',     lat: 48.8524, lng: 2.3776),
    SorpresaStop(id: 'paris_surprise_hugo_07A', branch: 'A',     lugar: 'Boulevard de Ménilmontant', lat: 48.8608, lng: 2.3803),
    SorpresaStop(id: 'paris_surprise_hugo_08A', branch: 'A',     lugar: 'Père Lachaise entrada',     lat: 48.8616, lng: 2.3876),
    SorpresaStop(id: 'paris_surprise_hugo_09A', branch: 'A',     lugar: 'Muro de los Federados',     lat: 48.8609, lng: 2.3958),
    SorpresaStop(id: 'paris_surprise_hugo_07B', branch: 'B',     lugar: 'Rue de Charonne',           lat: 48.8530, lng: 2.3753),
    SorpresaStop(id: 'paris_surprise_hugo_08B', branch: 'B',     lugar: 'Rue Faidherbe',             lat: 48.8522, lng: 2.3757),
    SorpresaStop(id: 'paris_surprise_hugo_09B', branch: 'B',     lugar: 'Rue Trousseau',             lat: 48.8514, lng: 2.3742),
  ],
);

// ── LOUISE MICHEL ─────────────────────────────────────────────
const kLouise = SorpresaPersonaje(
  id: 'louise',
  name: 'Louise Michel',
  emoji: '✊',
  desc: 'Maestra anarquista · París 1871',
  resumenES: 'Soy Louise Michel. Es el 28 de mayo de 1871, el último día de la Semana Sangrienta. La Comuna de París está siendo aplastada. Soy maestra, anarquista y combatiente. He pasado los últimos dos meses en las barricadas de Montmartre. Ahora espero la llegada de los versalleses.',
  resumenEN: 'Soy Louise Michel. Es el 28 de mayo de 1871, el último día de la Semana Sangrienta. La Comuna de París está siendo aplastada. Soy maestra, anarquista y combatiente. He pasado los últimos dos meses en las barricadas de Montmartre. Ahora espero la llegada de los versalleses.',
  resumenDE: 'Ich bin Louise Michel. Es ist der achtundzwanzigste Mai achtzehnhunderteinundsiebzig, der letzte Tag der Blutigen Woche. Die Pariser Kommune wird niedergeschlagen. Ich bin Lehrerin, Anarchistin und Kämpferin. Ich habe die letzten zwei Monate auf den Barrikaden von Montmartre verbracht.',
  resumenIT: 'Soy Louise Michel. Es el 28 de mayo de 1871, el último día de la Semana Sangrienta. La Comuna de París está siendo aplastada. Soy maestra, anarquista y combatiente. He pasado los últimos dos meses en las barricadas de Montmartre. Ahora espero la llegada de los versalleses.',
  r2Base: 'https://pub-b20ae9c7d6c140aa868ea5aba6210b5f.r2.dev/audios/sorpresa/paris/louise/v1/',
  introStopId: 'paris_surprise_louise_00',
  storyLangs: ['es', 'en'],
  duracionMin: 90,
  distanciaKm: 2.5,
  branchATitle: 'La que bajó a Clichy',
  branchADesc:  'Desciende de Montmartre',
  branchBTitle: 'La que se quedó en la Butte',
  branchBDesc:  'Permanece en Montmartre',
  stops: [
    SorpresaStop(id: 'paris_surprise_louise_00', branch: 'shared', lugar: 'Introducción Louise',              lat: 48.8867, lng: 2.3411),
    SorpresaStop(id: 'paris_surprise_louise_01', branch: 'shared', lugar: 'Rue Lepic',                        lat: 48.8853, lng: 2.3378),
    SorpresaStop(id: 'paris_surprise_louise_02', branch: 'shared', lugar: 'Place Constantin Pecqueur',        lat: 48.8872, lng: 2.3363),
    SorpresaStop(id: 'paris_surprise_louise_03', branch: 'shared', lugar: 'Rue Lamarck',                      lat: 48.8876, lng: 2.3383),
    SorpresaStop(id: 'paris_surprise_louise_04', branch: 'shared', lugar: 'Place du Tertre',                  lat: 48.8865, lng: 2.3408),
    SorpresaStop(id: 'paris_surprise_louise_05', branch: 'shared', lugar: 'Rue du Chevalier de la Barre',     lat: 48.8868, lng: 2.3422),
    SorpresaStop(id: 'paris_surprise_louise_06', branch: 'shared', lugar: 'Sacré-Cœur solar',                 lat: 48.8861, lng: 2.3432),
    SorpresaStop(id: 'paris_surprise_louise_07A', branch: 'A',     lugar: 'Rue Caulaincourt',                 lat: 48.8880, lng: 2.3343),
    SorpresaStop(id: 'paris_surprise_louise_08A', branch: 'A',     lugar: 'Boulevard de Clichy',              lat: 48.8841, lng: 2.3325),
    SorpresaStop(id: 'paris_surprise_louise_09A', branch: 'A',     lugar: 'Place de Clichy',                  lat: 48.8836, lng: 2.3274),
    SorpresaStop(id: 'paris_surprise_louise_07B', branch: 'B',     lugar: 'Rue Gabrielle',                    lat: 48.8868, lng: 2.3441),
    SorpresaStop(id: 'paris_surprise_louise_08B', branch: 'B',     lugar: 'Rue Ravignan',                     lat: 48.8855, lng: 2.3427),
    SorpresaStop(id: 'paris_surprise_louise_09B', branch: 'B',     lugar: 'Place Émile-Goudeau',              lat: 48.8847, lng: 2.3415),
  ],
);

// ── ALPHONSE DAUDET ───────────────────────────────────────────
const kDaudet = SorpresaPersonaje(
  id: 'daudet',
  name: 'Alphonse Daudet',
  emoji: '📰',
  desc: 'Novelista y cronista · París 1870',
  resumenES: 'Soy Alphonse Daudet. Es el 12 de diciembre de 1870. París lleva ochenta y siete días sitiada por los prusianos. Soy novelista, cronista del lunes en Le Figaro, y observador de esta ciudad que se muere de hambre con una elegancia que no termina de convencerme.',
  resumenEN: 'Soy Alphonse Daudet. Es el 12 de diciembre de 1870. París lleva ochenta y siete días sitiada por los prusianos. Soy novelista, cronista del lunes en Le Figaro, y observador de esta ciudad que se muere de hambre con una elegancia que no termina de convencerme.',
  resumenDE: 'Ich bin Alphonse Daudet. Es ist der zwölfte Dezember achtzehnhundertsiebzig. Paris wird seit siebenundachtzig Tagen von den Preußen belagert. Ich bin Romancier, Montagschronist für den Figaro, und Beobachter dieser Stadt, die mit einer Eleganz verhungert, die mich nicht ganz überzeugt.',
  resumenIT: 'Soy Alphonse Daudet. Es el 12 de diciembre de 1870. París lleva ochenta y siete días sitiada por los prusianos. Soy novelista, cronista del lunes en Le Figaro, y observador de esta ciudad que se muere de hambre con una elegancia que no termina de convencerme.',
  r2Base: 'https://pub-b20ae9c7d6c140aa868ea5aba6210b5f.r2.dev/audios/sorpresa/paris/daudet/v1/',
  introStopId: 'paris_surprise_daudet_00',
  storyLangs: ['es', 'en'],
  duracionMin: 90,
  distanciaKm: 3.0,
  branchATitle: 'El camino de la Concordia',
  branchADesc:  'Hacia los Tullerías',
  branchBTitle: 'El camino del Faubourg',
  branchBDesc:  'Hacia el boulevard Haussmann',
  stops: [
    SorpresaStop(id: 'paris_surprise_daudet_00', branch: 'shared', lugar: 'Introducción Daudet',              lat: 48.8716, lng: 2.3320),
    SorpresaStop(id: 'paris_surprise_daudet_01', branch: 'shared', lugar: 'Opéra Garnier',                    lat: 48.8719, lng: 2.3316),
    SorpresaStop(id: 'paris_surprise_daudet_02', branch: 'shared', lugar: 'Rue de la Paix',                   lat: 48.8698, lng: 2.3305),
    SorpresaStop(id: 'paris_surprise_daudet_03', branch: 'shared', lugar: 'Place Vendôme',                    lat: 48.8673, lng: 2.3293),
    SorpresaStop(id: 'paris_surprise_daudet_04', branch: 'shared', lugar: 'Rue Cambon',                       lat: 48.8658, lng: 2.3286),
    SorpresaStop(id: 'paris_surprise_daudet_05', branch: 'shared', lugar: 'Rue Saint-Honoré',                 lat: 48.8640, lng: 2.3308),
    SorpresaStop(id: 'paris_surprise_daudet_06', branch: 'shared', lugar: 'Rue Duphot',                       lat: 48.8685, lng: 2.3268),
    SorpresaStop(id: 'paris_surprise_daudet_07', branch: 'shared', lugar: 'Place de la Madeleine',            lat: 48.8700, lng: 2.3246),
    SorpresaStop(id: 'paris_surprise_daudet_08A', branch: 'A',     lugar: 'Rue Royale',                       lat: 48.8680, lng: 2.3232),
    SorpresaStop(id: 'paris_surprise_daudet_09A', branch: 'A',     lugar: 'Place de la Concorde',             lat: 48.8657, lng: 2.3212),
    SorpresaStop(id: 'paris_surprise_daudet_10A', branch: 'A',     lugar: 'Jardin des Tuileries',             lat: 48.8638, lng: 2.3291),
    SorpresaStop(id: 'paris_surprise_daudet_08B', branch: 'B',     lugar: 'Rue du Faubourg Saint-Honoré',     lat: 48.8726, lng: 2.3163),
    SorpresaStop(id: 'paris_surprise_daudet_09B', branch: 'B',     lugar: 'Rue de Miromesnil',                lat: 48.8758, lng: 2.3143),
    SorpresaStop(id: 'paris_surprise_daudet_10B', branch: 'B',     lugar: 'Boulevard Haussmann',              lat: 48.8778, lng: 2.3152),
  ],
);

// ── GERTRUDE STEIN ────────────────────────────────────────────
const kStein = SorpresaPersonaje(
  id: 'stein',
  name: 'Gertrude Stein',
  emoji: '🎨',
  desc: 'Escritora americana · París 1937',
  resumenES: 'Soy Gertrude Stein. Es el verano de 1937. Llevo treinta y cuatro años viviendo en París. He visto nacer el cubismo, sobrevivir la Gran Guerra, rugir los años veinte. Ahora veo llegar los refugiados españoles y sé que otra guerra se acerca. Vivo en el número 27 de la rue de Fleurus con Alice B. Toklas.',
  resumenEN: 'Soy Gertrude Stein. Es el verano de 1937. Llevo treinta y cuatro años viviendo en París. He visto nacer el cubismo, sobrevivir la Gran Guerra, rugir los años veinte. Ahora veo llegar los refugiados españoles y sé que otra guerra se acerca. Vivo en el número 27 de la rue de Fleurus con Alice B. Toklas.',
  resumenDE: 'Ich bin Gertrude Stein. Es ist der Sommer neunzehnhundertsiebenunddreißig. Ich lebe seit vierunddreißig Jahren in Paris. Ich habe den Kubismus geboren sehen, den Großen Krieg überleben sehen, die zwanziger Jahre brüllen sehen. Jetzt sehe ich die spanischen Flüchtlinge ankommen und weiß, dass ein weiterer Krieg näher rückt.',
  resumenIT: 'Soy Gertrude Stein. Es el verano de 1937. Llevo treinta y cuatro años viviendo en París. He visto nacer el cubismo, sobrevivir la Gran Guerra, rugir los años veinte. Ahora veo llegar los refugiados españoles y sé que otra guerra se acerca. Vivo en el número 27 de la rue de Fleurus con Alice B. Toklas.',
  r2Base: 'https://pub-b20ae9c7d6c140aa868ea5aba6210b5f.r2.dev/audios/sorpresa/paris/stein/v1/',
  introStopId: 'paris_surprise_stein_00',
  storyLangs: ['es', 'en'],
  duracionMin: 75,
  distanciaKm: 2.0,
  branchATitle: 'El camino del Sena',
  branchADesc:  'Por los muelles',
  branchBTitle: 'El Barrio Latino',
  branchBDesc:  'Por las calles medievales',
  stops: [
    SorpresaStop(id: 'paris_surprise_stein_00', branch: 'shared', lugar: 'Introducción Stein',       lat: 48.8458, lng: 2.3327),
    SorpresaStop(id: 'paris_surprise_stein_01', branch: 'shared', lugar: '27 rue de Fleurus',        lat: 48.8458, lng: 2.3327),
    SorpresaStop(id: 'paris_surprise_stein_02', branch: 'shared', lugar: 'Rue Guynemer',             lat: 48.8467, lng: 2.3342),
    SorpresaStop(id: 'paris_surprise_stein_03', branch: 'shared', lugar: 'Rue de Vaugirard',         lat: 48.8460, lng: 2.3363),
    SorpresaStop(id: 'paris_surprise_stein_04', branch: 'shared', lugar: "Place de l'Odéon",         lat: 48.8509, lng: 2.3402),
    SorpresaStop(id: 'paris_surprise_stein_05', branch: 'shared', lugar: "Rue Saint-André des Arts", lat: 48.8525, lng: 2.3433),
    SorpresaStop(id: 'paris_surprise_stein_06', branch: 'shared', lugar: 'Place Saint-Michel',       lat: 48.8532, lng: 2.3466),
    SorpresaStop(id: 'paris_surprise_stein_07A', branch: 'A',     lugar: 'Quai Saint-Michel',        lat: 48.8526, lng: 2.3476),
    SorpresaStop(id: 'paris_surprise_stein_08A', branch: 'A',     lugar: 'Quai de Montebello',       lat: 48.8519, lng: 2.3490),
    SorpresaStop(id: 'paris_surprise_stein_09A', branch: 'A',     lugar: 'Square Jean XXIII',        lat: 48.8522, lng: 2.3507),
    SorpresaStop(id: 'paris_surprise_stein_07B', branch: 'B',     lugar: 'Rue de la Harpe',          lat: 48.8528, lng: 2.3447),
    SorpresaStop(id: 'paris_surprise_stein_08B', branch: 'B',     lugar: 'Rue de la Huchette',       lat: 48.8527, lng: 2.3469),
    SorpresaStop(id: 'paris_surprise_stein_09B', branch: 'B',     lugar: 'Rue Xavier Privas',        lat: 48.8527, lng: 2.3461),
  ],
);

// ── MARIE CURIE ───────────────────────────────────────────────
const kCurie = SorpresaPersonaje(
  id: 'curie',
  name: 'Marie Curie',
  emoji: '⚗️',
  desc: 'Física y química · París 1906',
  resumenES: 'Soy Marie Curie. Es el 29 de abril de 1906, diecinueve días después de la muerte de Pierre. Soy la primera mujer que ha ganado el Premio Nobel. Soy la primera mujer que enseñará en la Sorbona. Y esta mañana no sé cuál de esas dos cosas pesa más sobre mi corazón.',
  resumenEN: 'Soy Marie Curie. Es el 29 de abril de 1906, diecinueve días después de la muerte de Pierre. Soy la primera mujer que ha ganado el Premio Nobel. Soy la primera mujer que enseñará en la Sorbona. Y esta mañana no sé cuál de esas dos cosas pesa más sobre mi corazón.',
  resumenDE: 'Ich bin Marie Curie. Es ist der neunundzwanzigste April neunzehnhundertsechs, neunzehn Tage nach Pierres Tod. Ich bin die erste Frau, die den Nobelpreis gewonnen hat. Ich bin die erste Frau, die an der Sorbonne unterrichten wird. Und heute Morgen weiß ich nicht, welches dieser beiden Dinge schwerer auf meinem Herzen lastet.',
  resumenIT: 'Soy Marie Curie. Es el 29 de abril de 1906, diecinueve días después de la muerte de Pierre. Soy la primera mujer que ha ganado el Premio Nobel. Soy la primera mujer que enseñará en la Sorbona. Y esta mañana no sé cuál de esas dos cosas pesa más sobre mi corazón.',
  r2Base: 'https://pub-b20ae9c7d6c140aa868ea5aba6210b5f.r2.dev/audios/sorpresa/paris/curie/v1/',
  introStopId: 'paris_surprise_curie_00',
  storyLangs: ['es', 'en'],
  duracionMin: 60,
  distanciaKm: 1.5,
  branchATitle: 'El camino de la Sorbona',
  branchADesc:  'Por Soufflot y Saint-Jacques',
  branchBTitle: 'El camino del Val-de-Grâce',
  branchBDesc:  "Por la Rue d'Ulm",
  stops: [
    SorpresaStop(id: 'paris_surprise_curie_00', branch: 'shared', lugar: 'Introducción Curie',              lat: 48.8462, lng: 2.3445),
    SorpresaStop(id: 'paris_surprise_curie_01', branch: 'shared', lugar: 'Place du Panthéon',               lat: 48.8462, lng: 2.3460),
    SorpresaStop(id: 'paris_surprise_curie_02', branch: 'shared', lugar: 'Rue Pierre et Marie Curie',       lat: 48.8454, lng: 2.3448),
    SorpresaStop(id: 'paris_surprise_curie_03', branch: 'shared', lugar: 'École Normale Supérieure',        lat: 48.8431, lng: 2.3441),
    SorpresaStop(id: 'paris_surprise_curie_04', branch: 'shared', lugar: 'Rue Claude Bernard',              lat: 48.8432, lng: 2.3468),
    SorpresaStop(id: 'paris_surprise_curie_05', branch: 'shared', lugar: 'Place de la Contrescarpe',        lat: 48.8437, lng: 2.3484),
    SorpresaStop(id: 'paris_surprise_curie_06', branch: 'shared', lugar: 'Rue Mouffetard',                  lat: 48.8426, lng: 2.3503),
    SorpresaStop(id: 'paris_surprise_curie_07A', branch: 'A',     lugar: 'Rue Soufflot',                    lat: 48.8465, lng: 2.3436),
    SorpresaStop(id: 'paris_surprise_curie_08A', branch: 'A',     lugar: 'Rue Saint-Jacques',               lat: 48.8483, lng: 2.3466),
    SorpresaStop(id: 'paris_surprise_curie_09A', branch: 'A',     lugar: 'Collège de France',               lat: 48.8513, lng: 2.3441),
    SorpresaStop(id: 'paris_surprise_curie_07B', branch: 'B',     lugar: "Rue d'Ulm",                       lat: 48.8441, lng: 2.3461),
    SorpresaStop(id: 'paris_surprise_curie_08B', branch: 'B',     lugar: 'Rue Gay-Lussac',                  lat: 48.8462, lng: 2.3468),
    SorpresaStop(id: 'paris_surprise_curie_09B', branch: 'B',     lugar: 'Val-de-Grâce',                    lat: 48.8437, lng: 2.3434),
  ],
);

// ── PARADAS ROMA (compartidas por todos los personajes) ───────
const _kRomaLugares = <(String, double, double)>[
  ('Coliseo',                                            41.8902, 12.4922),
  ('Foro Romano',                                        41.8925, 12.4853),
  ('Palatino',                                           41.8893, 12.4875),
  ('Panteón',                                            41.8986, 12.4769),
  ('Plaza Navona',                                       41.8992, 12.4731),
  ("Castel Sant'Angelo",                                 41.9031, 12.4663),
  ('Basílica de San Pedro',                              41.9022, 12.4539),
  ('Museos Vaticanos y Capilla Sixtina',                 41.9065, 12.4536),
  ('Fontana di Trevi',                                   41.9009, 12.4833),
  ('Plaza de España y Escalinata',                       41.9057, 12.4823),
  ('Basílica de Santa Maria Maggiore',                   41.8976, 12.4994),
  ('Termas de Caracalla',                                41.8797, 12.4922),
  ('Circo Máximo',                                       41.8855, 12.4856),
  ('Basílica de San Juan de Letrán',                     41.8858, 12.5058),
  ('Arco de Constantino',                                41.8896, 12.4905),
  ("Campo de' Fiori",                                    41.8955, 12.4722),
  ('Plaza del Popolo',                                   41.9108, 12.4763),
  ('Villa Borghese y Galería Borghese',                  41.9143, 12.4922),
  ('Trastevere – Basílica de Santa Maria',               41.8897, 12.4697),
  ('Ghetto Ebraico',                                     41.8933, 12.4772),
  ('Isla Tiberina',                                      41.8900, 12.4761),
  ('Basílica de San Clemente',                           41.8889, 12.4978),
  ('Catacumbas de San Calixto',                          41.8567, 12.5139),
  ('Vía Appia Antica',                                   41.8578, 12.5197),
  ('Mercados de Trajano',                                41.8956, 12.4869),
  ('Iglesia de San Luigi dei Francesi',                  41.8994, 12.4741),
  ('Plaza Venezia y Monumento a Vittorio Emanuele II',   41.8955, 12.4823),
  ('Barrio EUR',                                         41.8325, 12.4714),
  ('Testaccio – Monte dei Cocci',                        41.8797, 12.4769),
  ('Iglesia de Santa Maria della Vittoria',              41.9033, 12.4944),
  ('Piazza Farnese y Palazzo Farnese',                   41.8958, 12.4706),
  ('Ara Pacis',                                          41.9061, 12.4753),
  ('Aventino – Jardín de los Naranjos y Ojo de la Cerradura', 41.8836, 12.4803),
  ('Piraneseum – Cárcel de las Nuevas',                  41.8894, 12.4742),
  ('Museo Nacional Romano – Palazzo Massimo',            41.9011, 12.4983),
  ('Iglesia del Gesù',                                   41.8961, 12.4800),
  ('Pincio y Terraza del Pincio',                        41.9125, 12.4836),
  ('Cloaca Máxima',                                      41.8914, 12.4828),
  ('Quartiere Pigneto',                                  41.8861, 12.5358),
  ('Ostia Antica',                                       41.7561, 12.2894),
];

List<SorpresaStop> _romaStops(String prefix) => [
  for (int i = 0; i < _kRomaLugares.length; i++)
    SorpresaStop(
      id: '${prefix}_${(i + 1).toString().padLeft(2, '0')}',
      branch: 'shared',
      lugar: _kRomaLugares[i].$1,
      lat: _kRomaLugares[i].$2,
      lng: _kRomaLugares[i].$3,
    ),
];

// ── MARCO AURELIO ─────────────────────────────────────────────
final kMarco = SorpresaPersonaje(
  id: 'marco',
  name: 'Marco Aurelio',
  emoji: '🏛️',
  desc: 'Emperador y filósofo · Roma 161 d.C.',
  resumenES: 'Soy Marco Aurelio. Esta tarde me he quedado solo en el Coliseo, cuando ya no huele a bestia ni a sangre. Soy el Optimus Princeps y el autor de unas notas privadas que nadie debería leer. Debería estar en la frontera del Danubio. En cambio, estoy aquí, pensando.',
  resumenEN: 'I am Marcus Aurelius. This afternoon I stayed alone in the Colosseum, when the smell of beast and blood was gone. I am the Optimus Princeps and the author of private notes no one should read. I should be on the Danube frontier. Instead, I am here, thinking.',
  resumenDE: 'Ich bin Marcus Aurelius. Heute Nachmittag bin ich allein im Kolosseum geblieben, als der Geruch von Tier und Blut verflogen war. Ich bin der Optimus Princeps und der Autor privater Notizen, die niemand lesen sollte. Ich sollte an der Donaugrenze sein. Stattdessen bin ich hier und denke nach.',
  resumenIT: "Sono Marco Aurelio. Questo pomeriggio sono rimasto solo al Colosseo, quando l'odore di bestie e sangue era svanito. Sono l'Optimus Princeps e l'autore di note private che nessuno dovrebbe leggere. Dovrei essere al confine del Danubio. Invece sono qui, a pensare.",
  r2Base: 'https://pub-b20ae9c7d6c140aa868ea5aba6210b5f.r2.dev/audios/sorpresa/roma/marco/v1/',
  duracionMin: 180,
  distanciaKm: 15.0,
  storyLangs: ['es'],
  stops: _romaStops('marco'),
);

// ── GIULIA ────────────────────────────────────────────────────
final kGiulia = SorpresaPersonaje(
  id: 'giulia',
  name: 'Giulia',
  emoji: '🌸',
  desc: 'Dama del Renacimiento · Roma 1506',
  resumenES: 'Me llamo Giulia. Es 1506. Roma está siendo desmontada y reconstruida piedra a piedra por orden del papa Julio II. Bramante tiene planos para todo. Y yo tengo ojos para ver lo que Bramante no ve: que la grandeza de esta ciudad no cabe en ningún plano.',
  resumenEN: 'My name is Giulia. It is 1506. Rome is being dismantled and rebuilt stone by stone on the orders of Pope Julius II. Bramante has plans for everything. And I have eyes to see what Bramante cannot: that the greatness of this city does not fit in any blueprint.',
  resumenDE: 'Ich heiße Giulia. Es ist 1506. Rom wird auf Befehl von Papst Julius II. Stein für Stein abgetragen und neu errichtet. Bramante hat Pläne für alles. Und ich habe Augen, um zu sehen, was Bramante nicht sieht: dass die Größe dieser Stadt in keinen Plan passt.',
  resumenIT: 'Mi chiamo Giulia. È il 1506. Roma viene smontata e ricostruita pietra su pietra per ordine di papa Giulio II. Bramante ha piani per tutto. E io ho occhi per vedere ciò che Bramante non vede: che la grandezza di questa città non sta in nessun progetto.',
  r2Base: 'https://pub-b20ae9c7d6c140aa868ea5aba6210b5f.r2.dev/audios/sorpresa/roma/giulia/v1/',
  duracionMin: 180,
  distanciaKm: 15.0,
  storyLangs: ['es'],
  stops: _romaStops('giulia'),
);

// ── ARTEMISIA GENTILESCHI ─────────────────────────────────────
final kArtemisia = SorpresaPersonaje(
  id: 'artemisia',
  name: 'Artemisia Gentileschi',
  emoji: '🎨',
  desc: 'Pintora barroca · Roma 1610',
  resumenES: 'Me llamo Artemisia Gentileschi. He venido a ver cómo la luz de octubre cae sobre estas piedras rotas. No me interesan las ruinas ni los emperadores muertos. A mí me interesa la luz. Y en Roma, la luz nunca miente.',
  resumenEN: 'My name is Artemisia Gentileschi. I have come to see how the October light falls on these broken stones. I am not interested in ruins or dead emperors. What interests me is the light. And in Rome, the light never lies.',
  resumenDE: 'Ich heiße Artemisia Gentileschi. Ich bin gekommen, um zu sehen, wie das Oktoberlicht auf diese zerbrochenen Steine fällt. Ruinen und tote Kaiser interessieren mich nicht. Was mich interessiert, ist das Licht. Und in Rom lügt das Licht nie.',
  resumenIT: 'Mi chiamo Artemisia Gentileschi. Sono venuta a vedere come la luce di ottobre cade su queste pietre rotte. Non mi interessano le rovine né gli imperatori morti. Mi interessa la luce. E a Roma, la luce non mente mai.',
  r2Base: 'https://pub-b20ae9c7d6c140aa868ea5aba6210b5f.r2.dev/audios/sorpresa/roma/artemisia/v1/',
  duracionMin: 180,
  distanciaKm: 15.0,
  storyLangs: ['es'],
  stops: _romaStops('artemisia'),
);

// ── LUCA ──────────────────────────────────────────────────────
final kLuca = SorpresaPersonaje(
  id: 'luca',
  name: 'Luca',
  emoji: '🛵',
  desc: 'Romano de barrio · Roma 1950',
  resumenES: 'Me llamo Luca, tengo diecinueve años y las ruinas de Roma son mi barrio. No soy un guía turístico. Soy el que sabe dónde dar la sombra buena, dónde vende el mejor tramezzino y qué hay debajo de cada piedra que los turistas fotografían sin entender.',
  resumenEN: 'My name is Luca, I am nineteen years old and the ruins of Rome are my neighbourhood. I am not a tourist guide. I am the one who knows where to find good shade, where to get the best tramezzino, and what lies beneath every stone the tourists photograph without understanding.',
  resumenDE: 'Ich heiße Luca, ich bin neunzehn Jahre alt und die Ruinen Roms sind mein Viertel. Ich bin kein Fremdenführer. Ich bin derjenige, der weiß, wo der gute Schatten ist, wo der beste Tramezzino verkauft wird und was unter jedem Stein liegt, den die Touristen fotografieren, ohne ihn zu verstehen.',
  resumenIT: "Mi chiamo Luca, ho diciannove anni e le rovine di Roma sono il mio quartiere. Non sono una guida turistica. Sono quello che sa dove trovare la buona ombra, dove si vende il miglior tramezzino e cosa c'è sotto ogni pietra che i turisti fotografano senza capire.",
  r2Base: 'https://pub-b20ae9c7d6c140aa868ea5aba6210b5f.r2.dev/audios/sorpresa/roma/luca/v1/',
  duracionMin: 180,
  distanciaKm: 15.0,
  storyLangs: ['es'],
  stops: _romaStops('luca'),
);

// ── SOFIA ─────────────────────────────────────────────────────
final kSofia = SorpresaPersonaje(
  id: 'sofia',
  name: 'Sofia',
  emoji: '🎬',
  desc: 'Maquilladora de cine · Roma 1960',
  resumenES: 'Me llamo Sofia, tengo veintiocho años y vivo en Trastevere, pero trabajo en Cinecittà. Ayudo a maquillar actrices que creen que Roma es solo una postal para sus películas. Esta ciudad es mía, aunque no me lo agradezca.',
  resumenEN: 'My name is Sofia, I am twenty-eight years old and I live in Trastevere, but I work at Cinecittà. I help make up actresses who believe Rome is just a backdrop for their films. This city is mine, even if it does not thank me for it.',
  resumenDE: 'Ich heiße Sofia, bin achtundzwanzig Jahre alt und lebe in Trastevere, arbeite aber in Cinecittà. Ich schminke Schauspielerinnen, die glauben, Rom sei nur eine Kulisse für ihre Filme. Diese Stadt gehört mir, auch wenn sie mir nicht dafür dankt.',
  resumenIT: 'Mi chiamo Sofia, ho ventotto anni e vivo a Trastevere, ma lavoro a Cinecittà. Aiuto a truccare attrici che credono che Roma sia solo una cartolina per i loro film. Questa città è mia, anche se non me ne è grata.',
  r2Base: 'https://pub-b20ae9c7d6c140aa868ea5aba6210b5f.r2.dev/audios/sorpresa/roma/sofia/v1/',
  duracionMin: 180,
  distanciaKm: 15.0,
  storyLangs: ['es'],
  stops: _romaStops('sofia'),
);

// ── HELPERS ───────────────────────────────────────────────────
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

// ── HELPER DISTANCIA ─────────────────────────────────────────
String _fmtDistS(double m) =>
    m < 1000 ? '${m.round()}m' : '${(m / 1000).toStringAsFixed(1)} km';

// ── SELECTOR DE PERSONAJE ─────────────────────────────────────
class SorpresaScreen extends StatefulWidget {
  final String lang;
  final String? initialCity;
  const SorpresaScreen({super.key, required this.lang, this.initialCity});
  @override
  State<SorpresaScreen> createState() => _SorpresaScreenState();
}

class _SorpresaScreenState extends State<SorpresaScreen> {
  late String _lang;
  late String _ciudad;

  bool _showMap = false;
  Position? _userPos;
  StreamSubscription<Position>? _geoSub;
  SorpresaPersonaje? _selectedPersonaje;

  @override
  void initState() {
    super.initState();
    _lang = widget.lang;
    _ciudad = widget.initialCity ?? 'Berlin';
    if (_lang == 'fr' && _ciudad != 'París') _lang = 'es';
    if (_ciudad == 'Berlin' && _lang == 'fr') _lang = 'es';
    _startGps();
  }

  @override
  void dispose() {
    _geoSub?.cancel();
    super.dispose();
  }

  Future<void> _startGps() async {
    try {
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.deniedForever) return;
      _geoSub = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high, distanceFilter: 10),
      ).listen((pos) { if (mounted) setState(() => _userPos = pos); });
    } catch (_) {}
  }

  double? _distanceTo(SorpresaPersonaje p) {
    if (_userPos == null || p.contentStops.isEmpty) return null;
    final s = p.contentStops.first;
    return _haversine(_userPos!.latitude, _userPos!.longitude, s.lat, s.lng);
  }

  List<SorpresaPersonaje> _sorted(List<SorpresaPersonaje> list) {
    if (_userPos == null) return list;
    final copy = List<SorpresaPersonaje>.from(list);
    copy.sort((a, b) {
      final da = _distanceTo(a) ?? double.infinity;
      final db = _distanceTo(b) ?? double.infinity;
      return da.compareTo(db);
    });
    return copy;
  }

  Widget _buildPersonajePopup(SorpresaPersonaje p) {
    final dist = _distanceTo(p);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: kSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kGold)),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(p.emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(p.name,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: kText)),
            Text(p.desc, style: const TextStyle(fontSize: 11, color: kMuted)),
            if (dist != null)
              Text('📍 ${_fmtDistS(dist)}', style: const TextStyle(fontSize: 12, color: kGold)),
          ])),
          GestureDetector(
            onTap: () => setState(() => _selectedPersonaje = null),
            child: Container(
                width: 28, height: 28,
                decoration: BoxDecoration(color: kSurface2,
                    borderRadius: BorderRadius.circular(8), border: Border.all(color: kBorder)),
                child: const Icon(Icons.close, color: kMuted, size: 14)),
          ),
        ]),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () {
            setState(() => _selectedPersonaje = null);
            Navigator.push(context, MaterialPageRoute(
                builder: (_) => SorpresaPlayerScreen(personaje: p, lang: _lang)));
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(color: kGold, borderRadius: BorderRadius.circular(10)),
            child: Center(child: Text(ts(_lang, 'start'),
                style: const TextStyle(fontSize: 13, color: Colors.black, fontWeight: FontWeight.w600))),
          ),
        ),
      ]),
    );
  }

  Widget _buildMapView(List<SorpresaPersonaje> personajes) {
    final valid = personajes.where((p) => p.contentStops.isNotEmpty).toList();
    if (valid.isEmpty) return const Center(child: CircularProgressIndicator(color: kGold));

    double minLat = 90, maxLat = -90, minLng = 180, maxLng = -180;
    for (final p in valid) {
      final s = p.contentStops.first;
      minLat = math.min(minLat, s.lat); maxLat = math.max(maxLat, s.lat);
      minLng = math.min(minLng, s.lng); maxLng = math.max(maxLng, s.lng);
    }
    if (_userPos != null) {
      minLat = math.min(minLat, _userPos!.latitude);
      maxLat = math.max(maxLat, _userPos!.latitude);
      minLng = math.min(minLng, _userPos!.longitude);
      maxLng = math.max(maxLng, _userPos!.longitude);
    }

    return Stack(children: [
      FlutterMap(
        options: MapOptions(
          initialCameraFit: CameraFit.bounds(
            bounds: LatLngBounds(LatLng(minLat, minLng), LatLng(maxLat, maxLng)),
            padding: const EdgeInsets.all(60),
          ),
          onTap: (_, __) => setState(() => _selectedPersonaje = null),
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.citylore.app',
          ),
          MarkerLayer(markers: [
            ...valid.map((p) {
              final s = p.contentStops.first;
              final isSelected = _selectedPersonaje?.id == p.id;
              return Marker(
                point: LatLng(s.lat, s.lng),
                width: isSelected ? 52 : 40,
                height: isSelected ? 52 : 40,
                child: GestureDetector(
                  onTap: () => setState(() => _selectedPersonaje = isSelected ? null : p),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isSelected ? kGold : kSurface,
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: kGold, width: isSelected ? 2.5 : 1.5),
                    ),
                    child: Center(child: Text(p.emoji,
                        style: TextStyle(fontSize: isSelected ? 18 : 14))),
                  ),
                ),
              );
            }),
            if (_userPos != null)
              Marker(
                point: LatLng(_userPos!.latitude, _userPos!.longitude),
                width: 20, height: 20,
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.blue, shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2)),
                ),
              ),
          ]),
        ],
      ),
      if (_selectedPersonaje != null)
        Positioned(
            bottom: 24, left: 16, right: 16,
            child: _buildPersonajePopup(_selectedPersonaje!)),
    ]);
  }

  void _setCity(String ciudad) {
    setState(() {
      _ciudad = ciudad;
      if ((ciudad == 'Berlin' || ciudad == 'Roma') && _lang == 'fr') _lang = 'es';
      _showMap = false;
      _selectedPersonaje = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isParis = _ciudad == 'París';
    return Scaffold(
      backgroundColor: kBg,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => setState(() { _showMap = !_showMap; _selectedPersonaje = null; }),
        backgroundColor: kGold,
        icon: Icon(_showMap ? Icons.list : Icons.map_outlined, color: Colors.black),
        label: Text(_showMap ? ts(_lang, 'see_list') : ts(_lang, 'see_map'),
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
      ),
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
                  child: const Icon(Icons.arrow_back, color: kText, size: 18)),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(ts(_lang, 'title'),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: kText))),
            langPill(_lang, (l) => setState(() => _lang = l)),
          ]),
        ),

        // ── SELECTOR DE CIUDAD (solo desde pantalla principal) ──
        if (widget.initialCity == null)
        Container(
          color: kSurface,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Row(children: [
            _SorpresaCityBtn(
              label: '🇩🇪 Berlín',
              active: _ciudad == 'Berlin',
              onTap: () => _setCity('Berlin'),
              rightMargin: 8,
            ),
            _SorpresaCityBtn(
              label: '🇫🇷 París',
              active: isParis,
              onTap: () => _setCity('París'),
              rightMargin: 8,
            ),
            _SorpresaCityBtn(
              label: '🇮🇹 Roma',
              active: _ciudad == 'Roma',
              onTap: () => _setCity('Roma'),
              rightMargin: 0,
            ),
          ]),
        ),

        // ── CONTENIDO ──
        Expanded(child: Builder(builder: (_) {
          final List<SorpresaPersonaje> personajes;
          if (_ciudad == 'París') {
            personajes = _sorted([kVictor, kLouise, kDaudet, kStein, kCurie]);
          } else if (_ciudad == 'Roma') {
            personajes = _sorted([kMarco, kGiulia, kArtemisia, kLuca, kSofia]);
          } else {
            personajes = _sorted([kLena, kKlaus, kClara, kOtto]);
          }
          if (_showMap) return _buildMapView(personajes);
          if (_ciudad == 'París') return _buildParisPersonajes(personajes);
          if (_ciudad == 'Roma') return _buildRomaPersonajes(personajes);
          return _buildBerlinPersonajes(personajes);
        })),
      ])),
    );
  }

  Widget _buildBerlinPersonajes(List<SorpresaPersonaje> sorted) {
    return SingleChildScrollView(
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
        ...sorted.asMap().entries.map((e) => Padding(
          padding: EdgeInsets.only(bottom: e.key < sorted.length - 1 ? 12 : 0),
          child: _PersonajeCard(
            personaje: e.value,
            lang: _lang,
            distanceM: _distanceTo(e.value),
            isNearest: _userPos != null && e.key == 0 && sorted.length > 1,
            onTap: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => SorpresaPlayerScreen(personaje: e.value, lang: _lang))),
          ),
        )),
      ]),
    );
  }

  Widget _buildParisPersonajes(List<SorpresaPersonaje> sorted) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(children: [
        const SizedBox(height: 16),
        const Text('🗼', style: TextStyle(fontSize: 56)),
        const SizedBox(height: 16),
        Text(ts(_lang, 'choose_guide'),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: kGold)),
        const SizedBox(height: 8),
        Text(ts(_lang, 'subtitle_paris'),
            style: const TextStyle(fontSize: 14, color: kMuted), textAlign: TextAlign.center),
        const SizedBox(height: 32),
        ...sorted.asMap().entries.map((e) => Padding(
          padding: EdgeInsets.only(bottom: e.key < sorted.length - 1 ? 12 : 0),
          child: _PersonajeCard(
            personaje: e.value,
            lang: _lang,
            distanceM: _distanceTo(e.value),
            isNearest: _userPos != null && e.key == 0 && sorted.length > 1,
            onTap: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => SorpresaPlayerScreen(personaje: e.value, lang: _lang))),
          ),
        )),
      ]),
    );
  }

  Widget _buildRomaPersonajes(List<SorpresaPersonaje> sorted) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(children: [
        const SizedBox(height: 16),
        const Text('🏛️', style: TextStyle(fontSize: 56)),
        const SizedBox(height: 16),
        Text(ts(_lang, 'choose_guide'),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: kGold)),
        const SizedBox(height: 8),
        Text(ts(_lang, 'subtitle_roma'),
            style: const TextStyle(fontSize: 14, color: kMuted), textAlign: TextAlign.center),
        const SizedBox(height: 32),
        ...sorted.asMap().entries.map((e) => Padding(
          padding: EdgeInsets.only(bottom: e.key < sorted.length - 1 ? 12 : 0),
          child: _PersonajeCard(
            personaje: e.value,
            lang: _lang,
            distanceM: _distanceTo(e.value),
            isNearest: _userPos != null && e.key == 0 && sorted.length > 1,
            onTap: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => SorpresaPlayerScreen(personaje: e.value, lang: _lang))),
          ),
        )),
      ]),
    );
  }
}

// ── CITY TOGGLE BUTTON (SORPRESA) ─────────────────────────────
class _SorpresaCityBtn extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  final double rightMargin;
  const _SorpresaCityBtn({
    required this.label, required this.active,
    required this.onTap, required this.rightMargin,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: EdgeInsets.only(right: rightMargin),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: active ? kGold.withOpacity(0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: active ? kGold : kBorder),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: active ? kGoldLight : kMuted,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── PERSONAJE CARD ────────────────────────────────────────────
class _PersonajeCard extends StatelessWidget {
  final SorpresaPersonaje personaje;
  final String lang;
  final VoidCallback onTap;
  final double? distanceM;
  final bool isNearest;

  const _PersonajeCard({
    required this.personaje,
    required this.lang,
    required this.onTap,
    this.distanceM,
    this.isNearest = false,
  });

  @override
  Widget build(BuildContext context) {
    final p = personaje;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        decoration: BoxDecoration(
            color: kSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: isNearest ? kGold : kBorder,
                width: isNearest ? 1.5 : 0.5)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(p.emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(child: Text(p.name,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600, color: kText))),
                  if (isNearest)
                    Container(
                      margin: const EdgeInsets.only(left: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: kGold.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: kGold.withOpacity(0.5)),
                      ),
                      child: Text('⭐ ${ts(lang, 'nearest')}',
                          style: const TextStyle(
                              fontSize: 9, color: kGold, fontWeight: FontWeight.w600)),
                    ),
                ]),
                const SizedBox(height: 2),
                Text(p.desc,
                    style: const TextStyle(fontSize: 12, color: kMuted)),
                const SizedBox(height: 8),
                Wrap(spacing: 6, runSpacing: 4, children: [
                  _SorpresaPill(icon: Icons.place_outlined, label: '${p.contentStops.length} ${ts(lang, 'stops')}'),
                  _SorpresaPill(icon: Icons.schedule_outlined, label: p.duracionLabel(lang)),
                  _SorpresaPill(icon: Icons.directions_walk, label: '${p.distanciaKm} ${ts(lang, 'km')} ${ts(lang, 'approx')}'),
                  if (distanceM != null)
                    _SorpresaPill(
                      icon: Icons.my_location,
                      label: _fmtDistS(distanceM!),
                      highlight: isNearest,
                    ),
                ]),
              ])),
              const Icon(Icons.chevron_right, color: kMuted, size: 20),
            ]),
          ),

          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: kGold.withOpacity(0.06),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: kGold.withOpacity(0.15)),
            ),
            child: Text(p.resumen(lang),
                style: const TextStyle(fontSize: 12, color: kMuted, height: 1.55)),
          ),
        ]),
      ),
    );
  }
}

// ── SORPRESA PILL ─────────────────────────────────────────────
class _SorpresaPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool highlight;
  const _SorpresaPill({required this.icon, required this.label, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    final color = highlight ? kGoldLight : kGold;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(highlight ? 0.18 : 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(highlight ? 0.5 : 0.25)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 10, color: color.withOpacity(0.8)),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 10, color: color.withOpacity(0.9), fontWeight: FontWeight.w500)),
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
  late List<SorpresaStop> _route;
  int _idx = 0;
  String? _chosenBranch;
  bool get _hasBranches => widget.personaje.contentStops.any((s) => s.branch == 'A' || s.branch == 'B');
  bool get _atBifurcation => _hasBranches && _chosenBranch == null && _idx == _route.length - 1;

  late AudioPlayer _player;
  bool _playing = false;
  Duration _pos = Duration.zero, _dur = Duration.zero;

  StreamSubscription<Position>? _geoSub;
  double? _userLat, _userLng;
  bool _nearStop = false;
  static const _proximityRadius = 30.0;

  bool _showStory = false;
  final MapController _mapController = MapController();
  Map<String, Map<String, String>> _textos = {};
  bool _textosLoaded = false;

  @override
  void initState() {
    super.initState();
    _lang = widget.lang;
    _route = widget.personaje.contentStops.where((s) => s.branch == 'shared').toList();
    _loadTextos();
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
  void dispose() { _player.dispose(); _geoSub?.cancel(); super.dispose(); }

  SorpresaStop get _currentStop => _route[_idx];

  Future<void> _loadTextos() async {
    final t = await fetchSorpresaTexts();
    if (mounted) setState(() { _textos = t; _textosLoaded = true; });
  }

  String _audioUrl(SorpresaStop stop) {
    final langSuffix = _lang == 'en' ? 'en' : _lang == 'de' ? 'de' : 'es';
    return '${widget.personaje.r2Base}${stop.id}_$langSuffix.mp3';
  }

  Future<void> _loadAudio() async {
    try {
      await _player.stop();
      setState(() { _pos = Duration.zero; _dur = Duration.zero; _playing = false; });
      await _player.setUrl(_audioUrl(_currentStop));
    } catch (_) {}
  }

  Future<void> _togglePlay() async {
    if (_playing) await _player.pause(); else await _player.play();
  }

  void _chooseBranch(String branch) {
    final branchStops = widget.personaje.contentStops.where((s) => s.branch == branch).toList();
    setState(() {
      _chosenBranch = branch;
      _route = [..._route, ...branchStops];
      _idx++;
      _nearStop = false;
      _showStory = false;
    });
    _loadAudio();
    _centerMap();
  }

  void _nextStop() {
    if (_idx < _route.length - 1) {
      setState(() { _idx++; _nearStop = false; _showStory = false; });
      _player.stop();
      _loadAudio();
      _centerMap();
    }
  }

  void _centerMap() {
    _mapController.move(LatLng(_currentStop.lat, _currentStop.lng), 15);
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
    if (_userLat == null || _userLng == null || _atBifurcation) return;
    final dist = _haversine(_userLat!, _userLng!, _currentStop.lat, _currentStop.lng);
    if (dist <= _proximityRadius && !_nearStop) setState(() => _nearStop = true);
  }

  Widget _buildMap() {
    final stop = _currentStop;
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(initialCenter: LatLng(stop.lat, stop.lng), initialZoom: 14),
      children: [
        TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'com.citylore.app'),
        MarkerLayer(markers: [
          ..._route.asMap().entries.map((e) {
            final s = e.value;
            final isCurrent = e.key == _idx;
            final isDone = e.key < _idx;
            return Marker(
              point: LatLng(s.lat, s.lng),
              width: isCurrent ? 44 : 32, height: isCurrent ? 44 : 32,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color: isCurrent ? kGold : (isDone ? kGold.withOpacity(0.4) : kSurface),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isCurrent ? kGoldLight : (isDone ? kGold.withOpacity(0.6) : kBorder),
                    width: isCurrent ? 2.5 : 1.5),
                ),
                child: Center(child: Text('${e.key + 1}',
                    style: TextStyle(fontSize: isCurrent ? 14 : 10, fontWeight: FontWeight.bold,
                        color: isCurrent ? Colors.black : (isDone ? kGold : kMuted)))),
              ),
            );
          }),
          if (_userLat != null)
            Marker(
              point: LatLng(_userLat!, _userLng!), width: 20, height: 20,
              child: Container(decoration: BoxDecoration(
                  color: Colors.blue, shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2))),
            ),
        ]),
      ],
    );
  }

  Widget _buildIntroPanel(SorpresaStop introStop) {
    final langSupported = widget.personaje.storyLangs.contains(_lang);
    final text = !langSupported
        ? ts(_lang, 'soon')
        : _textosLoaded
            ? sorpresaStopText(introStop.id, _lang, _textos)
            : null;
    if (text != null && text.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: kGold.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kGold.withOpacity(0.25)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(widget.personaje.emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 8),
          Text(widget.personaje.name.toUpperCase(),
              style: const TextStyle(fontSize: 10, color: kGold, letterSpacing: 1.5, fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(height: 8),
        text == null
            ? const Center(child: Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: CircularProgressIndicator(color: kGold, strokeWidth: 2)))
            : Text(text, style: const TextStyle(fontSize: 13, color: kText, height: 1.65)),
      ]),
    );
  }

  Widget _buildStoryPanel() {
    final langSupported = widget.personaje.storyLangs.contains(_lang);
    final storyText = !langSupported
        ? ts(_lang, 'soon')
        : _textosLoaded
            ? sorpresaStopText(_currentStop.id, _lang, _textos)
            : null; // null = cargando
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: _showStory
          ? Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              decoration: BoxDecoration(
                color: kSurface, borderRadius: BorderRadius.circular(14),
                border: Border.all(color: kGold.withOpacity(0.4))),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
                  decoration: BoxDecoration(
                    color: kGold.withOpacity(0.08),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(13)),
                    border: Border(bottom: BorderSide(color: kGold.withOpacity(0.2)))),
                  child: Row(children: [
                    Text(ts(_lang, 'story'),
                        style: const TextStyle(fontSize: 10, color: kGold, letterSpacing: 1.5, fontWeight: FontWeight.w600)),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => setState(() => _showStory = false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(color: kSurface2, borderRadius: BorderRadius.circular(8), border: Border.all(color: kBorder)),
                        child: Text(ts(_lang, 'close'), style: const TextStyle(fontSize: 10, color: kMuted)),
                      ),
                    ),
                  ]),
                ),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: storyText == null
                      ? const Center(child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: CircularProgressIndicator(color: kGold, strokeWidth: 2)))
                      : storyText.isEmpty
                          ? Text(ts(_lang, 'no_text'), style: const TextStyle(fontSize: 13, color: kMuted, height: 1.65))
                          : Text(storyText, style: const TextStyle(fontSize: 13, color: kText, height: 1.65)),
                ),
              ]),
            )
          : const SizedBox.shrink(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final stop = _currentStop;
    final isBif = _atBifurcation;
    final progress = _dur.inMilliseconds > 0
        ? (_pos.inMilliseconds / _dur.inMilliseconds).clamp(0.0, 1.0) : 0.0;
    final isLast = !isBif && _idx == _route.length - 1 && (_chosenBranch != null || !_hasBranches);
    final p = widget.personaje;
    const hasStory = true;

    return Scaffold(
      backgroundColor: kBg,
      body: SafeArea(child: Column(children: [

        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: kSurface,
          child: Row(children: [
            GestureDetector(
              onTap: () { _player.stop(); Navigator.pop(context); },
              child: Container(width: 36, height: 36,
                  decoration: BoxDecoration(border: Border.all(color: kBorder), borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.arrow_back, color: kText, size: 18)),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: kGold.withOpacity(0.15), borderRadius: BorderRadius.circular(20), border: Border.all(color: kGold)),
              child: Text('${p.emoji} ${p.name.toUpperCase()}',
                  style: const TextStyle(fontSize: 10, color: kGold, letterSpacing: 2, fontWeight: FontWeight.w600)),
            ),
            const Spacer(),
            langPill(_lang, (l) => setState(() { _lang = l; _loadAudio(); })),
          ]),
        ),

        SizedBox(height: 220, child: _buildMap()),

        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Row(children: List.generate(_route.length, (i) {
            final c = i < _idx ? kGold : (i == _idx ? kGoldLight : kBorder);
            return Expanded(child: Container(height: 3, margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(2))));
          })),
        ),

        Expanded(child: SingleChildScrollView(child: Column(children: [
          const SizedBox(height: 12),

          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: kSurface, borderRadius: BorderRadius.circular(14), border: Border.all(color: isBif ? kGold : kBorder)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(width: 8, height: 8, decoration: const BoxDecoration(color: kGold, shape: BoxShape.circle)),
                const SizedBox(width: 8),
                Text(isBif ? ts(_lang, 'branch_label') : ts(_lang, 'clue'),
                    style: const TextStyle(fontSize: 10, color: kGold, letterSpacing: 2, fontWeight: FontWeight.w600)),
              ]),
              const SizedBox(height: 8),
              Text(isBif ? ts(_lang, 'who_is') : stop.lugar,
                  style: const TextStyle(fontSize: 14, color: kText, fontStyle: FontStyle.italic, height: 1.5)),
            ]),
          ),
          const SizedBox(height: 10),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(children: [
              Expanded(child: Text(stop.lugar, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: kText))),
              if (_userLat != null && !isBif)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: kSurface2, borderRadius: BorderRadius.circular(8), border: Border.all(color: kBorder)),
                  child: Text('${_haversine(_userLat!, _userLng!, stop.lat, stop.lng).round()}m',
                      style: const TextStyle(fontSize: 11, color: kMuted)),
                ),
            ]),
          ),
          const SizedBox(height: 10),

          // ── INTRO (solo en parada 1 para personajes con intro) ──
          if (_idx == 0 && widget.personaje.introStop != null) ...[
            _buildIntroPanel(widget.personaje.introStop!),
            const SizedBox(height: 10),
          ],

          if (isBif) Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(children: [
              Expanded(child: GestureDetector(
                onTap: () => _chooseBranch('A'),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: kSurface, borderRadius: BorderRadius.circular(14), border: Border.all(color: kBorder)),
                  child: Column(children: [
                    const Text('💨', style: TextStyle(fontSize: 24)),
                    const SizedBox(height: 6),
                    Text(p.branchATitle, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: kText), textAlign: TextAlign.center),
                    const SizedBox(height: 4),
                    Text(p.branchADesc, style: const TextStyle(fontSize: 11, color: kMuted), textAlign: TextAlign.center),
                  ]),
                ),
              )),
              const SizedBox(width: 10),
              Expanded(child: GestureDetector(
                onTap: () => _chooseBranch('B'),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: kSurface, borderRadius: BorderRadius.circular(14), border: Border.all(color: kBorder)),
                  child: Column(children: [
                    const Text('🏠', style: TextStyle(fontSize: 24)),
                    const SizedBox(height: 6),
                    Text(p.branchBTitle, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: kText), textAlign: TextAlign.center),
                    const SizedBox(height: 4),
                    Text(p.branchBDesc, style: const TextStyle(fontSize: 11, color: kMuted), textAlign: TextAlign.center),
                  ]),
                ),
              )),
            ]),
          ),

          if (!isBif) ...[
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: kSurface, borderRadius: BorderRadius.circular(16), border: Border.all(color: kBorder)),
              child: Column(children: [
                Row(children: [
                  GestureDetector(
                    onTap: _togglePlay,
                    child: Container(width: 48, height: 48,
                        decoration: const BoxDecoration(color: kGold, shape: BoxShape.circle),
                        child: Icon(_playing ? Icons.pause : Icons.play_arrow, color: Colors.black, size: 22)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: Column(children: [
                    SliderTheme(
                      data: const SliderThemeData(trackHeight: 3, activeTrackColor: kGold, inactiveTrackColor: kSurface2, thumbColor: kGold),
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
                if (hasStory) ...[
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () => setState(() => _showStory = !_showStory),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      decoration: BoxDecoration(
                        color: _showStory ? kGold.withOpacity(0.12) : kSurface2,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _showStory ? kGold.withOpacity(0.5) : kBorder)),
                      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(_showStory ? Icons.menu_book : Icons.menu_book_outlined, size: 14, color: _showStory ? kGold : kMuted),
                        const SizedBox(width: 6),
                        Text(_showStory ? ts(_lang, 'close') : ts(_lang, 'read_story'),
                            style: TextStyle(fontSize: 12, color: _showStory ? kGold : kMuted, fontWeight: FontWeight.w500)),
                      ]),
                    ),
                  ),
                ],
              ]),
            ),
          ],

          if (!isBif && hasStory) ...[
            const SizedBox(height: 8),
            _buildStoryPanel(),
          ],

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
                  Icon(_nearStop ? Icons.location_on : Icons.navigation, color: _nearStop ? kGold : kMuted, size: 16),
                  const SizedBox(width: 8),
                  Expanded(child: Text(
                    _nearStop ? ts(_lang, 'near_stop') : '${ts(_lang, 'walk_to')} ${stop.lugar}',
                    style: TextStyle(fontSize: 12, color: _nearStop ? kGold : kMuted))),
                  if (_nearStop) GestureDetector(
                    onTap: _nextStop,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: kGold, borderRadius: BorderRadius.circular(8)),
                      child: Text(ts(_lang, 'next'), style: const TextStyle(fontSize: 12, color: Colors.black, fontWeight: FontWeight.w600)),
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
                  width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(color: kSurface2, borderRadius: BorderRadius.circular(14), border: Border.all(color: kBorder)),
                  child: Center(child: Text(ts(_lang, 'next_stop'), style: const TextStyle(fontSize: 13, color: kMuted))),
                ),
              ),
            ),
          ],

          if (isLast) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                width: double.infinity, padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: kGold.withOpacity(0.08), borderRadius: BorderRadius.circular(16), border: Border.all(color: kGold)),
                child: Column(children: [
                  Text(p.emoji, style: const TextStyle(fontSize: 32)),
                  const SizedBox(height: 8),
                  Text(ts(_lang, 'end_title'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kGold)),
                  const SizedBox(height: 4),
                  Text(ts(_lang, 'end_sub'), style: const TextStyle(fontSize: 13, color: kMuted)),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () { _player.stop(); Navigator.pop(context); Navigator.pop(context); },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                      decoration: BoxDecoration(color: kGold, borderRadius: BorderRadius.circular(10)),
                      child: Text(ts(_lang, 'back_home'), style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
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