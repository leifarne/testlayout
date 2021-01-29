import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'codes.dart';

class UserSession {}

// Firestore doc and collection keys.
const guessed_key = 'guessed';
const team_collection_key = 'teams';
const member_collection_key = 'members';
const game_collection_key = 'games';
const active_games_key = 'active_games';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;

DocumentReference bieDocRef = _firestore.doc('/bie/bie');
DocumentReference teamDocRef;
DocumentReference userDocRef;
DocumentReference gameDocRef;
CollectionReference gameCollectionRef =
    bieDocRef.collection(game_collection_key);

// SharePreferences keys
const String user_key = 'user';
const String team_key = 'team';
const String zoom_key = 'zoom';
const String game_key = 'game';

class User {
  final String userName;
  final String team;
  final int zoom;
  final String currentTask;

  User(this.team, this.userName, this.zoom, this.currentTask);
}

Future<User> loadPreferred() async {
  var preferences = await SharedPreferences.getInstance();
  var user = preferences.getString(user_key) ?? '';
  var team = preferences.getString(team_key) ?? '';
  var zoom = preferences.getInt(zoom_key) ?? 0;
  var task = preferences.getString(game_key) ?? null;
  if (team.isEmpty) {
    team = user;
  }
  print('Shared preferences: $team/$user');
  return User(team, user, zoom, task);
}

// Save team and user in Preferences. Don't wait.
Future<void> savePreferred(User user) async {
  var preferences = await SharedPreferences.getInstance();
  preferences.setString(user_key, user.userName);
  preferences.setString(team_key, user.team);
}

Future<void> savePreferredZoomLevel(int zoomLevel) async {
  var preferences = await SharedPreferences.getInstance();
  preferences.setInt(zoom_key, zoomLevel);
}

void initTeam(User user) async {
  // Global docrefs created on Enter.
  teamDocRef = bieDocRef.collection(team_collection_key).doc(user.team);
  userDocRef = teamDocRef.collection(member_collection_key).doc(user.userName);
  gameCollectionRef = bieDocRef.collection(game_collection_key);

  await teamDocRef.set({}, SetOptions(merge: true));
  await userDocRef.set({}, SetOptions(merge: true));
}

// Save guesses for current user. Don't wait.
void saveGuesses(List<String> guesses) {
  // save guess for code for user, f.ex. /bie/bie/teams/familien/members/pappa/games/ø-utding.guesses[]
  userDocRef
      .collection(game_collection_key)
      .doc(currentTask.key)
      .set({guessed_key: guesses});
}

// Save game for current team. Don't wait.
void saveGameForTeam(String game) {
  gameDocRef = bieDocRef.collection(game_collection_key).doc(game);
  teamDocRef.set({'game': game});
}

// Not used.
void saveUser() async {
  await teamDocRef.set(
    {
      member_collection_key: FieldValue.arrayUnion([userDocRef.path])
    },
    SetOptions(merge: true),
  );
}

// Load members and guesses. For all active games
Future<Map<String, List<String>>> loadMembersResults(User me) {
  return teamDocRef.collection(member_collection_key).get().then((shot) {
    var m = shot.docs.map((player) {
      var data = player.data();
      var guessed = data[guessed_key];
      return MapEntry(
          player.id, (guessed != null) ? List<String>.from(guessed) : null);
    }).where((player) => player != null && player.key != me.userName);
    return Map.fromEntries(m);
  });
}

Future<void> loadMyResults(User me) {
  return loadPlayerResults(me, userDocRef);
}
// TODO: init name of self before loading results first time is wrong

/// Load with Future. docRef must be a userDocRef
/// Team doc has collection of active games.
/// Player doc has collection of active games and current results.
/// So a player will have a subset of the team's active games, ie. only the ones
/// he has started. So we will load all active games' results in this function.
/// But the total list of active games for the team, needs a separate function loadActiveGames().
Future<void> loadPlayerResults(User me, DocumentReference docRef) {
  // load collection of active games results for this userdocref
  return docRef.collection(active_games_key).get().then((snapshot) {
    snapshot.docs.forEach((doc) {
      if (doc.exists) {
        var data = doc.data();
        print('loadPlayerResults: data = $data');
        var guessed = data[guessed_key];
        var solutions = (guessed != null) ? List<String>.from(guessed) : null;
        // ... rather guesses than solutions.
        activeTasks.add(Task.fromCode(doc.id, solutions));
      }
    });
    currentTask =
        activeTasks.firstWhere((task) => task.sequence == me.currentTask);
  });
}

void loadGames() {
  gameCollectionRef.get().then((snapshot) {
    snapshot.docs.forEach((doc) {
      if (doc.exists) {
        print('Game id [${doc.id}]');
      }
    });
  });
}
