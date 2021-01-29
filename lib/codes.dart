//
// TODO: load current and active from team. Do it in model.dart.
// active games as Array in Team doc.
Task currentTask = Task(center_char, otherChars.join(), solution);
List<Task> activeTasks = <Task>[currentTask];

// TODO: finn bedre navn - Task, Game, activeGame, solutions, guesses...
// TODO: load global tasks
List<Task> globalTasks = <Task>[];

class Task {
  String center;
  String other;
  List<String> solutions;

  int maxPoints;
  RegExp legalCharacters;
  RegExp illegalCharacters;

  Task(this.center, this.other, this.solutions) {
    assert(this.center.length == 1 && this.other.length == 6);

    this.legalCharacters = RegExp("[$center]");
    this.illegalCharacters = RegExp("[^$other]");
    this.maxPoints = points();
  }

  Task.fromCode(String code, List<String> solutions) {
    assert(code[1] == '-');
    Task(code[0], code.substring(2), solutions);
  }

  String get sequence => center + other;
  String get key => '$center-$other';

  int points() {
    return calcPoints(solutions);
  }
}

// TODO: Remove all below. For testing only.
const center_char = 'Ø';
List<String> otherChars = <String>['D', 'G', 'N', 'T', 'I', 'U'];
RegExp legalCharacters = RegExp(r"[ø]");
RegExp illegalCharacters = RegExp(r"[^døgntiu]");

// const center_char = 'G';
// List<String> otherChars = <String>['D', 'H', 'I', 'E', 'R', 'T'];
// RegExp legalCharacters = RegExp(r"[g]");
// RegExp illegalCharacters = RegExp(r"[^dhiert]");
const List<String> solution = [
  "dødning",
  "dødtid",
  "døgn",
  "døgntid",
  "døing",
  "dønn",
  "dønn",
  "dønning",
  "nødig",
  "nøding",
  "nødt",
  "nøgd",
  "nøgd",
  "nøing",
  "nøtt",
  "tøing",
  "unødig",
  "utdø",
  "utdødd",
  "utdøing",
  "øding",
];

const List<String> solution2 = [
  "degge",
  "deig",
  "deiget",
  "deigete",
  "diger",
  "digge",
  "digger",
  "dirigere",
  "dregg",
  "dregge",
  "egde",
  "egge",
  "eierrettighet",
  "ergre",
  "erigere",
  "ettergi",
  "geir",
  "geire",
  "geire",
  "geit",
  "geite",
  "geitet",
  "geitete",
  "gerere",
  "gett",
  "gidde",
  "gigg",
  "gigge",
  "gire",
  "gire",
  "girere",
  "gitre",
  "gitt",
  "gitter",
  "grei",
  "greie",
  "greit",
  "greihet",
  "grid",
  "hegd",
  "hegde",
  "hegg",
  "hegre",
  "herdig",
  "hige",
  "idig",
  "igde",
  "iherdig",
  "iherdighet",
  "irrigere",
  "redig",
  "redigere",
  "regi",
  "regredere",
  "rettidig",
  "rettighet",
  "rigg",
  "rigge",
  "riggeier",
  "rigger",
  "rigid",
  "rigiditet",
  "tege",
  "teig",
  "terge",
  "tertedeig",
  "tidig",
  "tiger",
  "tigge",
  "tigger",
  "tiggeri",
  "tigret",
  "tigrete",
  "treg",
  "trege",
  "treghet",
  "treig",
  "trigge",
  "trigger",
];

const solution4 = [
  "alperose",
  "alpesol",
  "apal",
  "apollo",
  "appell",
  "appellere",
  "apropos",
  "eple",
  "epos",
  "espresso",
  "lapp",
  "lappe",
  "lapper",
  "lapprose",
  "laps",
  "leppe",
  "lepra",
  "lesesalsplass",
  "lesp",
  "lespe",
  "lesper",
  "lopp",
  "loppe",
  "losseplass",
  "opal",
  "opel",
  "opera",
  "operarolle",
  "operere",
  "oppasser",
  "oppe",
  "oppleser",
  "opprop",
  "oppsop",
  "oppsoper",
  "oppspore",
  "paella",
  "palass",
  "pall",
  "palé",
  "papp",
  "pappa",
  "parallell",
  "parasoll",
  "pare",
  "parere",
  "parese",
  "parole",
  "parre",
  "parsell",
  "parsellere",
  "pass",
  "passe",
  "passer",
  "passere",
  "pelle",
  "pels",
  "pepper",
  "pepre",
  "perle",
  "pers",
  "perse",
  "perser",
  "pese",
  "peso",
  "pessar",
  "plapre",
  "plass",
  "plassere",
  "plopp",
  "polar",
  "polere",
  "polerer",
  "polo",
  "pols",
  "popp",
  "poppe",
  "poppel",
  "pore",
  "poresopp",
  "pose",
  "posere",
  "pral",
  "prale",
  "praler",
  "prelle",
  "preparere",
  "preppe",
  "preses",
  "press",
  "presse",
  "presser",
  "prolaps",
  "propell",
  "proper",
  "propp",
  "proppe",
  "prosa",
  "prosess",
  "prosessere",
  "prosessor",
  "rape",
  "raper",
  "rapp",
  "rappe",
  "rappellere",
  "rapper",
  "raps",
  "rasp",
  "raspe",
  "rasper",
  "reparere",
  "repos",
  "rope",
  "roseeple",
  "salplass",
  "separere",
  "slapp",
  "slappe",
  "slaps",
  "slep",
  "slepe",
  "sleper",
  "sope",
  "soper",
  "sopp",
  "spar",
  "spare",
  "sparer",
  "sparess",
  "sparre",
  "spas",
  "spasere",
  "sperre",
  "spol",
  "spole",
  "spoler",
  "spolere",
  "spor",
  "spore",
  "spre",
  "sprell",
  "sprelle",
  "spreller",
  "sprosse",
];

final int solutionMaxPoints = calcPoints(solution);

int calcPoints(List<String> words) {
  var points = 0;
  if (words != null) {
    words.forEach((e) {
      if (e.length == 4) {
        points += 1;
      } else {
        points += e.length;
      }
      if (e.toLowerCase() == 'alperose' || e.toLowerCase() == 'lapprose') {
        points += 17;
      }
    });
  }
  print('points: $points');
  return points;
}
