import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
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
  },
};

String ts(String lang, String key) =>
    kTS[lang]?[key] ?? kTS['es']![key] ?? key;

// ── FETCH DATOS MODO SORPRESA ─────────────────────────────────
// Columnas: audio_id(0) ciudad(1) narrador(2) parada_num(3) branch(4)
//           lugar(5) lat(6) lng(7) texto_ES(8) texto_EN(9) texto_DE(10) texto_IT(11)
//           audio_ES(12) audio_EN(13)
Future<Map<String, Map<String, String>>> fetchSorpresaTexts() async {
  const sheetId = '1K1iMpmKiYMC3A05V9byG1duokRJK-2eYMQKti_wc2Fg';
  final url =
      'https://docs.google.com/spreadsheets/d/$sheetId/gviz/tq?tqx=out:json&sheet=Modo_Sorpresa';
  final res = await http.get(Uri.parse(url));
  if (res.statusCode != 200) throw Exception('Error al cargar textos');

  String body = res.body;
  final start = body.indexOf('{');
  final end = body.lastIndexOf('}');
  if (start == -1 || end == -1) throw Exception('Formato inesperado');
  body = body.substring(start, end + 1);
  final data = json.decode(body);
  final rows = data['table']['rows'] as List;

  final Map<String, Map<String, String>> result = {};
  for (final row in rows) {
    final cells = row['c'] as List;
    String cell(int i) {
      if (i >= cells.length || cells[i] == null) return '';
      final v = cells[i]['v'];
      return v == null ? '' : v.toString().trim();
    }
    final id = cell(0);
    if (id.isEmpty) continue;
    result[id] = {
      'ES':       cell(8),
      'EN':       cell(9),
      'DE':       cell(10),
      'IT':       cell(11),
      'audio_ES': cell(12),
      'audio_EN': cell(13),
    };
  }
  return result;
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
  });

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
  emoji: '🎸',
  desc: 'Punk del Oeste · Berlín 1983',
  resumenES: 'Berlín Occidental, 1983. Clara tiene diecinueve años, una guitarra y demasiadas preguntas sobre el Muro. Un día decide cruzar al otro lado. Lo que encuentra ahí no es lo que esperaba.',
  resumenEN: 'West Berlin, 1983. Clara is nineteen, has a guitar and too many questions about the Wall. One day she decides to cross to the other side. What she finds there is not what she expected.',
  resumenDE: 'West-Berlin, 1983. Clara ist neunzehn, hat eine Gitarre und zu viele Fragen über die Mauer. Eines Tages beschließt sie, auf die andere Seite zu gehen. Was sie dort findet, überrascht sie.',
  resumenIT: 'Berlino Ovest, 1983. Clara ha diciannove anni, una chitarra e troppe domande sul Muro. Un giorno decide di attraversare dall\'altra parte. Quello che trova lì non è quello che si aspettava.',
  r2Base: 'https://pub-b20ae9c7d6c140aa868ea5aba6210b5f.r2.dev/audios/sorpresa/berlin/clara/v1/',
  duracionMin: 100,
  distanciaKm: 3.7,
  branchATitle: 'La que cruzó',
  branchADesc:  'Pasa al Berlín Oriental',
  branchBTitle: 'La que se quedó',
  branchBDesc:  'Permanece en el Oeste',
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

// ── SELECTOR DE PERSONAJE ─────────────────────────────────────
class SorpresaScreen extends StatefulWidget {
  final String lang;
  const SorpresaScreen({super.key, required this.lang});
  @override
  State<SorpresaScreen> createState() => _SorpresaScreenState();
}

class _SorpresaScreenState extends State<SorpresaScreen> {
  late String _lang;
  SorpresaPersonaje? _selected;

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

            _PersonajeCard(personaje: kLena,  lang: _lang, selected: _selected?.id == kLena.id,  onTap: () => setState(() => _selected = kLena)),
            const SizedBox(height: 12),
            _PersonajeCard(personaje: kKlaus, lang: _lang, selected: _selected?.id == kKlaus.id, onTap: () => setState(() => _selected = kKlaus)),
            const SizedBox(height: 12),
            _PersonajeCard(personaje: kClara, lang: _lang, selected: _selected?.id == kClara.id, onTap: () => setState(() => _selected = kClara)),
            const SizedBox(height: 12),
            _PersonajeCard(personaje: kOtto,  lang: _lang, selected: _selected?.id == kOtto.id,  onTap: () => setState(() => _selected = kOtto)),
            const SizedBox(height: 32),

            GestureDetector(
              onTap: _selected != null
                  ? () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => SorpresaPlayerScreen(personaje: _selected!, lang: _lang)))
                  : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                    gradient: _selected != null
                        ? const LinearGradient(colors: [kGold, kGoldLight])
                        : null,
                    color: _selected != null ? null : kSurface2,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _selected != null ? kGold : kBorder)),
                child: Center(child: Text(ts(_lang, 'start'),
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _selected != null ? Colors.black : kMuted))),
              ),
            ),
          ]),
        )),
      ])),
    );
  }
}

// ── PERSONAJE CARD ────────────────────────────────────────────
class _PersonajeCard extends StatelessWidget {
  final SorpresaPersonaje personaje;
  final String lang;
  final bool selected;
  final VoidCallback onTap;

  const _PersonajeCard({
    required this.personaje,
    required this.lang,
    required this.selected,
    required this.onTap,
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
            color: selected ? kGold.withOpacity(0.1) : kSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: selected ? kGold : kBorder,
                width: selected ? 1.5 : 0.5)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(p.emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(p.name,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600, color: kText)),
                const SizedBox(height: 2),
                Text(p.desc,
                    style: const TextStyle(fontSize: 12, color: kMuted)),
                const SizedBox(height: 8),
                Wrap(spacing: 6, children: [
                  _SorpresaPill(icon: Icons.place_outlined, label: '9 ${ts(lang, 'stops')}'),
                  _SorpresaPill(icon: Icons.schedule_outlined, label: p.duracionLabel(lang)),
                  _SorpresaPill(icon: Icons.directions_walk, label: '${p.distanciaKm} ${ts(lang, 'km')} ${ts(lang, 'approx')}'),
                ]),
              ])),
              if (selected)
                const Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: Icon(Icons.check_circle, color: kGold, size: 20),
                ),
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
  const _SorpresaPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: kGold.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kGold.withOpacity(0.25)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 10, color: kGold.withOpacity(0.8)),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 10, color: kGold.withOpacity(0.9), fontWeight: FontWeight.w500)),
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
  bool get _atBifurcation => _chosenBranch == null && _idx == _route.length - 1;

  late AudioPlayer _player;
  bool _playing = false;
  Duration _pos = Duration.zero, _dur = Duration.zero;

  StreamSubscription<Position>? _geoSub;
  double? _userLat, _userLng;
  bool _nearStop = false;
  static const _proximityRadius = 30.0;

  bool _showStory = false;
  final MapController _mapController = MapController();
  Map<String, Map<String, String>> _texts = {};

  @override
  void initState() {
    super.initState();
    _lang = widget.lang;
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
    fetchSorpresaTexts()
        .then((t) { if (mounted) setState(() => _texts = t); })
        .catchError((_) {});
  }

  @override
  void dispose() { _player.dispose(); _geoSub?.cancel(); super.dispose(); }

  SorpresaStop get _currentStop => _route[_idx];

  String _stopText(String stopId) {
    final map = _texts[stopId];
    if (map == null) return '';
    switch (_lang) {
      case 'en': return map['EN'] ?? map['ES'] ?? '';
      case 'de': return map['DE'] ?? map['ES'] ?? '';
      case 'it': return map['IT'] ?? map['ES'] ?? '';
      default:   return map['ES'] ?? '';
    }
  }

  String _audioUrl(SorpresaStop stop) {
    final key = (_lang == 'en') ? 'audio_EN' : 'audio_ES';
    final sheetUrl = _texts[stop.id]?[key] ?? '';
    if (sheetUrl.isNotEmpty) return sheetUrl;
    final langSuffix = (_lang == 'en') ? 'en' : 'es';
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
    final branchStops = widget.personaje.stops.where((s) => s.branch == branch).toList();
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

  Widget _buildStoryPanel() {
    final storyText = _stopText(_currentStop.id);
    if (storyText.isEmpty) return const SizedBox.shrink();
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
            child: Text(storyText, style: const TextStyle(fontSize: 13, color: kText, height: 1.65)),
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
    final isLast = !isBif && _idx == _route.length - 1 && _chosenBranch != null;
    final p = widget.personaje;
    final storyText = _stopText(stop.id);
    final hasStory = storyText.isNotEmpty;

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
