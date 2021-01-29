// TODO: farge på logg inn-knapp
// TODO: label på felter
// TODO: gul hake bak på resultatene
// TODO: flytt poengpanel
// TODO: last guesses for alle spillere i teamet

import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'codes.dart';
import 'myslider.dart';
import 'model.dart';
import 'honeycomb.dart';

void main() async {
  await Firebase.initializeApp();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nordheim',
      theme: ThemeData(
        iconTheme: IconThemeData(size: 16),
        elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
                minimumSize: Size(64, 36),
                shape: StadiumBorder(),
                padding: EdgeInsets.all(8))),
        primarySwatch: Colors.amber,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Stavebien'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class ZoomValue {
  var fontSize;
  var radius;

  ZoomValue(this.radius, this.fontSize);
}

class _MyHomePageState extends State<MyHomePage> {
  // final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  Timer timer;
  var _formKey = GlobalKey<FormState>();
  var _scaffoldKey = GlobalKey<ScaffoldState>();

  var _items =
      List<bool>.generate(100, (index) => (index % 5 == 0) ? true : false);
  var _items2 =
      List<bool>.generate(100, (index) => (index % 5 == 0) ? true : false);

  TextEditingController _teamController;
  TextEditingController _bieUserController;
  ScrollController _scrollController;
  TextEditingController _guessController;
  FocusNode _guessFocusNode;

  var _myGuesses = List<String>();
  var _teamScores = Map<String, int>();
  // var _guessed = <String, List<String>>{'meg': <String>[]};

  String _team = '';
  String _bieUser = '';
  var _isExpanded = false;

  int _zoomLevel = 1;
  final _scaleFactors = [1, 1.5, 2];

  double get _currentScaleFactor => _scaleFactors[_zoomLevel];

  @override
  void initState() {
    super.initState();

    loadUserSession();

    _teamController = TextEditingController(text: _team);
    _bieUserController = TextEditingController(text: _bieUser);
    _scrollController = ScrollController();
    _guessController = TextEditingController();
    _guessFocusNode = FocusNode();

    _load();
    loadGames();
    // signIn();
  }

  // TODO: clean use of global variables for team and user.

  void _load() async {
    var user = await loadPreferred();
    _bieUserController.text = user.userName;
    _teamController.text = user.team;
    _bieUser = user.userName;
    _team = user.team;
    _zoomLevel = user.zoom;

    if (user.userName.isEmpty) {
      return;
    }

    // We have a user and a team, so init and load results.
    initTeam(user);

    loadMyResults(user).then((gameResults) {
      // currentTask and activeTasks have been loaded, so refresh.
      setState(() {});
    });

    loadMembersResults(user).then((m) {
      setState(() {
        _teamScores =
            m.map((player, words) => MapEntry(player, calcPoints(words)));
      });
    });
  }

  void _validateAndSave() {
    if (_guessController.text.isEmpty) {
      return;
    }

    if (!_formKey.currentState.validate()) {
      _guessController.clear();
      return;
    }

    _formKey.currentState.save();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _guessController.dispose();
    _guessFocusNode.dispose();
    super.dispose();
  }

  // ignore:unused_element
  void _incrementCounter() {
    // ignore:unused_element
    if (timer != null && timer.isActive) {
      timer.cancel();
    } else {
      timer = Timer.periodic(Duration(seconds: 1), (timer) {
        setState(() {
          _items.add(_items.length % 5 == 0 ? true : false);
          _items2.add(_items2.length % 5 == 0 ? true : false);
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        toolbarHeight: 45,
        leading: Icon(Icons.android),
        title: Text(widget.title),
        actions: [
          _buildSignInRow(context),
        ],
      ),
      body: Center(child: OrientationBuilder(
        builder: (context, orientation) {
          if (orientation == Orientation.landscape) {
            return _buildHorizontal(context);
          } else {
            return _buildVertical(context);
          }
        },
      )),
    );
  }

  Widget _buildHorizontal(BuildContext context) {
    return Column(
      // mainAxisSize: MainAxisSize.min,
      children: [
        _buildExpansionPoints(context),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(child: _buildGame(context)),
                Expanded(child: _buildResults(context)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVertical(BuildContext context) {
    return Column(
      // mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Card(
          child: Column(
            children: [
              _buildExpansionPoints(context),
              // _buildPoints(context, _players[0], calcPoints(_guessed),
              //     solutionMaxPoints),
              // ..._buildTeamPoints(context),
              SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: MediaQuery(
                        data: MediaQueryData(
                            textScaleFactor: _currentScaleFactor),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildActiveTasks(context),
                            _buildForm(context),
                            _buildHoneycomb(context),
                            _buildButtonRow(context),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment(-0.5, 0),
                    child: _buildZoomSlider(context),
                  ),
                  // Spacer(),
                ],
              ),
            ],
          ),
        ),
        Expanded(child: _buildResults(context)),
      ],
    );
  }

  Widget _buildZoomSlider(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(Icons.add),
            SizedBox.fromSize(
              size: Size(60, 200),
              child: RotatedBox(
                quarterTurns: 3,
                child: Slider(
                  onChanged: (val) {
                    setState(() {
                      _zoomLevel = val.toInt();
                    });
                    savePreferredZoomLevel(_zoomLevel);
                  },
                  value: _zoomLevel.toDouble(),
                  min: 0,
                  max: 2,
                  divisions: 2,
                ),
              ),
            ),
            Text(
              'Zoom',
              style: Theme.of(context).textTheme.bodyText1,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignInRow(BuildContext context) {
    return FocusScope(
      onKey: (node, event) {
        if (event.isKeyPressed(LogicalKeyboardKey.enter)) {
          return _onSignIn();
        }
        return false;
      },
      child: Row(
        children: [
          _buildAppBarTextField(context, 80, _teamController, 'Team'),
          _buildAppBarTextField(context, 80, _bieUserController, 'Kallenavn'),
          Padding(
            padding: const EdgeInsets.all(4),
            child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.amber[300]),
                elevation: MaterialStateProperty.all(4),
                // side: MaterialStateProperty.all(
                //     BorderSide(color: Colors.black12)),
                // minimumSize: MaterialStateProperty.all(Size(16, 80)),
                // padding: MaterialStateProperty.all(EdgeInsets.zero),
              ),
              onPressed: _onSignIn,
              child: Text(
                'Logg inn',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                // textScaleFactor: 0.8,
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool _onSignIn() {
    print(
        'Signing in with ${_bieUserController.text}, ${_teamController.text}');

    _myGuesses.clear();

    // Lagre feltene i globale variable
    _bieUser = _bieUserController.text;
    _team = _teamController.text;

    // TODO: Form with validate
    if (_bieUser.isEmpty) {
      print('Åå, nei. User empty!');
      return true;
    }

    if (_team.isEmpty) {
      _teamController.text = _bieUser;
      _team = _bieUser;
    }

    var user = User(_teamController.text, _bieUserController.text, 1, null);
    savePreferred(user);
    initTeam(user);

    // Nå som self er med i teamet, last self, async
    loadMyResults(user).then((value) {
      setState(() {
        _myGuesses =  ?? <String>[];
      });
    });

    loadMembersResults(user).then((m) {
      setState(() {
        _teamScores =
            m.map((player, words) => MapEntry(player, calcPoints(words)));
      });
    });

    _guessFocusNode.requestFocus();
    return true;
  }

  Widget _buildAppBarTextField(BuildContext context, double width,
      TextEditingController controller, String hintText) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
          // height: 40,
          width: width,
          child: Center(
            child: TextField(
                style: TextStyle(fontSize: 12),
                textAlignVertical: TextAlignVertical.bottom,
                inputFormatters: [LengthLimitingTextInputFormatter(20)],
                // maxLength: 20,
                decoration: InputDecoration(
                  // labelText: 'Team',
                  // alignLabelWithHint: true,
                  // isCollapsed: true,
                  hintText: hintText,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  isDense: true,
                  border: OutlineInputBorder(borderSide: BorderSide.none),
                  filled: true,
                  fillColor: Colors.white,
                ),
                controller: controller),
          )),
    );
  }

  // ignore:unused_element
  Container _buildTicker() {
    return Container(
      width: double.infinity,
      height: 5,
      alignment: Alignment.centerRight,
      color: Colors.black26,
      child: ListView.builder(
          controller: _scrollController,
          reverse: false,
          shrinkWrap: true,
          // padding: EdgeInsets.symmetric(vertical: 5),
          scrollDirection: Axis.horizontal,
          itemCount: _items2.length,
          itemBuilder: (context, index) {
            return Center(
              child: Container(
                decoration: BoxDecoration(
                  color: (_items2[index]) ? Colors.amber : Colors.black54,
                  // border: Border(
                  //   left: BorderSide(color: Colors.grey),
                ),
                width: 2,
                height: 2,
              ),
            );
          }),
    );
  }

  // ignore: unused_element
  GridView _buildGridView() {
    return GridView.builder(
      shrinkWrap: true,
      gridDelegate:
          SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 9),
      itemBuilder: (context, i) {
        return Focus(
          child: Builder(
            builder: (context) => Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: Focus.of(context).hasPrimaryFocus
                      ? Colors.black12
                      : Colors.pink[100],
                  border: Border(
                      right: BorderSide(
                          color: Colors.blueGrey, width: i % 3 == 2 ? 3 : 1),
                      bottom: BorderSide(
                          color: Colors.blueGrey,
                          width: (i / 9).truncate() % 3 == 2 ? 3 : 1)),
                  shape: BoxShape.rectangle),
              width: 10,
              height: 10,
              child: Text('$i'),
            ),
          ),
        );
      },
      itemCount: 81,
    );
  }

  Widget _buildForm(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 200,
        // height: 100,
        child: Form(
          key: _formKey,
          child: FocusScope(
            onKey: (node, event) {
              if (event.isKeyPressed(LogicalKeyboardKey.enter)) {
                _validateAndSave();
                _guessFocusNode.requestFocus();
                return true;
              }
              return false;
            },
            child: TextFormField(
              controller: _guessController,
              focusNode: _guessFocusNode,
              validator: _validateForm,
              onSaved: _saveForm,
              showCursor: true,
              autofocus: true,
              cursorWidth: 3,
              cursorHeight: 30,
              cursorColor: Colors.amber,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                // icon: Icon(Icons.access_alarm),
                border: OutlineInputBorder(),
                // errorText: "Makan!",
                // hintText: 'Hint'
              ),
              inputFormatters: [UpperCaseInputFormatter()],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHoneycomb(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: CustomMultiChildLayout(
        delegate:
            HoneycombLayoutDelegate(50, 50, scaleFactor: _currentScaleFactor),
        children: [
          LayoutId(
              id: -1,
              child: Hexagon(
                  text: center_char,
                  color: Colors.amber,
                  controller: _guessController)),
          ...otherChars
              .asMap()
              .map((i, ch) => MapEntry(
                  i,
                  LayoutId(
                      id: i,
                      child: Hexagon(text: ch, controller: _guessController))))
              .values
              .toList(),
        ],
      ),
    );
  }

  String _validateForm(String guess) {
    guess = guess.toLowerCase();

    if (guess.length <= 3) {
      return "Må være på minst 4 bokstaver.";
    }
    if (!legalCharacters.hasMatch(guess)) {
      return "Må inneholde '$center_char'.";
    }

    if (!illegalCharacters.hasMatch(guess)) {
      return "Ulovlige bokstaver.";
    }
    if (!solution.contains(guess)) {
      return "Finnes ikke.";
    }

    if (_myGuesses.contains(guess)) {
      return "Finnes allerede.";
    }

    // Ja, da er vi gjennom kontrollen.
    print('Yeah $guess');

    return null;
  }

  void _saveForm(String guess) async {
    setState(() {
      _myGuesses.add(guess.toLowerCase());
      _guessController.clear();
    });

    var points = calcPoints([guess]);
    _scaffoldKey.currentState
        .showSnackBar(SnackBar(content: Text('+$points poeng!')));

    saveGuesses(_myGuesses);
  }

  Widget _buildResults(BuildContext context) {
    return MediaQuery(
      data: MediaQueryData(textScaleFactor: _currentScaleFactor),
      child: SizedBox.expand(
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Du har funnet ${_myGuesses.length} ord',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Expanded(
                  child: Wrap(
                    children: _myGuesses.reversed
                        .map<Widget>(
                          (e) => Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                                decoration: BoxDecoration(
                                    border: Border(
                                        bottom: BorderSide(
                                            color: Colors.grey.shade400))),
                                // width: 80,
                                child: Text(
                                  e,
                                  overflow: TextOverflow.ellipsis,
                                )),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButtonRow(BuildContext context) {
    return IconTheme(
      data: IconThemeData(size: 16 * _currentScaleFactor),
      child: ElevatedButtonTheme(
        data: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
          minimumSize: Size(80, 30),
          shape: StadiumBorder(),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        )),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ElevatedButton(
                      onPressed: () {
                        final str = _guessController.text;
                        if (str != null && str.length > 0) {
                          _guessController.value = TextEditingValue(
                              text: str.substring(0, str.length - 1),
                              selection: TextSelection.collapsed(
                                  offset: str.length - 1));
                        }
                      },
                      child: Text('Slett')),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ElevatedButton.icon(
                      icon: Icon(Icons.cached),
                      label: Text('Snurr'),
                      onPressed: () {
                        setState(() {
                          otherChars.shuffle();
                        });
                      }),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ElevatedButton(
                      onPressed: _validateAndSave,
                      style: ButtonStyle(
                          minimumSize: MaterialStateProperty.all(Size(100, 36)),
                          side: MaterialStateProperty.all(
                              BorderSide(color: Colors.amber[800], width: 4))),
                      child: Text('KJØR')),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ElevatedButton(
                    onPressed: () => _newTask(context),
                    child: Text('Ny'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ElevatedButton(
                      onPressed: () => _showSolution(context),
                      child: Text('Løsning')),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  // TODO: scroll hele skjermen på små skjermer
  // TODO: ikke last resultater, hvis det er en ny oppgave.
  // TODO: last resultater sammen med nåværende oppgave
  /* current oppgave må lagres på teamet
  alle oppgavene som teamet jobber med er en collection
  Så vi må ha en current oppgave og en liste av oppgaver - på teamet
  Så må vi ha listen av mulige oppgaver. Globalt, utenfor teamet

   */

  Widget _buildPoints(
      BuildContext context, String player, int currentScore, int maxScore) {
    // Make sure currentScore is inside min-max.
    currentScore ??= 0;
    currentScore = max(0, currentScore);
    currentScore = min(currentScore, maxScore);

    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: SizedBox(
            // fit: BoxFit.fitWidth,
            child: Text(
              player,
              overflow: TextOverflow.ellipsis,
            ),
            width: 80,
          ),
        ),
        Expanded(
          child: SliderTheme(
            data: SliderThemeData(
                thumbShape: MyThumbShape(current: currentScore, max: maxScore),
                trackShape: RoundedRectSliderTrackShape(),
                trackHeight: 1,
                disabledActiveTickMarkColor: Colors.amber,
                disabledInactiveTickMarkColor: Colors.grey[300],
                tickMarkShape: RoundSliderTickMarkShape(tickMarkRadius: 4),
                // disabledActiveTrackColor: Colors.black,
                disabledThumbColor: Colors.amber),
            child: Slider(
                value: currentScore.toDouble(),
                min: 0,
                max: maxScore.toDouble(),
                divisions: 10,
                onChanged: null),
          ),
        ),
      ],
    );
  }

  /// Velg ny oppgave fra en global liste
  /// Null still score.
  /// TODO: class Task. Load tasks. await. codes.dart
  /// TODO: Lagre task med ø-dadfadg som id.
  /// TODO: velg mellom aktive tasks eller nye tasks
  /// Aktive tasks i dropdown
  /// Lagre aktive Tasks og currentTask på Team
  /// showDialog returnere String. Eller Task.
  ///
  void _newTask(BuildContext context) async {
    // solution = _instance.get;
    String task = await showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text(
            'Velg ny oppgave',
            style: Theme.of(context).textTheme.headline5,
          ),
          children: [
            SizedBox(
                width: 200, height: 36, child: ListTile(title: Text('GWIEDX'))),
            SizedBox(
                width: 200, height: 36, child: ListTile(title: Text('GWIEDX')))
          ],
        );
      },
    );

    // TODO: Save task in Team.

    // setState(() {
    //   _myGuesses.clear();
    // });
  }

  void _showSolution(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text(
            'Fikk du det til?',
            style: Theme.of(context).textTheme.headline5,
          ),
          children: [
            Wrap(
              children: solution
                  .map((e) => SizedBox(
                        width: 180,
                        child: ListTile(
                          dense: true,
                          visualDensity: VisualDensity(
                              horizontal: VisualDensity.minimumDensity,
                              vertical: VisualDensity.minimumDensity),
                          leading: Icon(
                            Icons.check,
                            color: _myGuesses.contains(e)
                                ? Colors.amber
                                : Colors.white,
                          ),
                          title: Container(
                              decoration: BoxDecoration(
                                  border: Border(
                                      bottom:
                                          BorderSide(color: Colors.grey[400]))),
                              child: Text(e)),
                        ),
                      ))
                  .toList(),
            )
          ],
        );
      },
    );
  }

  Widget _buildExpansionPoints(BuildContext context) {
    return ExpansionPanelList(
      expansionCallback: (panelIndex, isExpanded) {
        setState(() {
          _isExpanded = !isExpanded;
        });
      },
      children: [
        ExpansionPanel(
            isExpanded: _isExpanded,
            headerBuilder: (context, expanded) {
              return _buildPoints(
                  context, _bieUser, calcPoints(_myGuesses), solutionMaxPoints);
            },
            body: Align(
              alignment: Alignment.bottomRight,
              child: Card(
                elevation: 4,
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Image.network(
                        'https://cdn.vox-cdn.com/thumbor/DhRriPZt9G1atMXRj5h7QZ1ewPk=/0x243:2500x2118/920x613/filters:focal(0x243:2500x2118):format(webp)/cdn.vox-cdn.com/uploads/chorus_image/image/46679984/shutterstock_150559442.0.0.jpg',
                        width: 100,
                        fit: BoxFit.contain,
                        // height: 100,
                      ),
                    ),
                    Expanded(
                      child: FractionallySizedBox(
                        alignment: Alignment.bottomRight,
                        widthFactor: 1,
                        child: _buildCol(context),
                      ),
                    ),
                  ],
                ),
              ),
            )),
      ],
    );
  }

  Widget _buildCol(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: teamDocRef?.collection('players')?.snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('feiiiiil');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text('Waiting....');
        }

        if (snapshot.hasData) {
          var m = snapshot.data.docs.map((e) {
            var data = e.data();
            var guessed = data[guessed_key];
            return MapEntry<String, int>(
                e.id,
                (guessed != null)
                    ? calcPoints(List<String>.from(guessed))
                    : null);
          }).where((element) => element != null && element.key != _bieUser);

          _teamScores = Map.fromEntries(m);

          return Column(
            children: _buildTeamPoints(context),
          );
        }

        return Text('Has no data');
      },
    );
  }

  List<Widget> _buildTeamPoints(BuildContext context) {
    return _teamScores
        .map<String, Widget>((key, value) =>
            MapEntry(key, _buildPoints(context, key, value, solutionMaxPoints)))
        .values
        .toList();
  }

  Widget _buildGame(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildGameboard(context)),
        _buildZoomSlider(context),
      ],
    );
  }

  Widget _buildGameboard(BuildContext context) {
    return MediaQuery(
      data: MediaQueryData(textScaleFactor: _currentScaleFactor),
      child: Column(
        children: [
          SizedBox(height: 4),
          _buildForm(context),
          _buildHoneycomb(context),
          _buildButtonRow(context),
        ],
      ),
    );
  }

  Widget _buildActiveTasks(BuildContext context) {
    return DropdownButton<String>(
      value: currentTask.sequence,
      icon: Icon(Icons.arrow_downward),
      iconSize: 24,
      elevation: 16,
      style: TextStyle(color: Colors.deepPurple),
      underline: Container(
        height: 2,
        color: Colors.deepPurpleAccent,
      ),
      onChanged: (String newValue) {
        setState(() {
          currentTask =
              activeTasks.firstWhere((task) => task.sequence == newValue);
        });
      },
      items: activeTasks.map<DropdownMenuItem<String>>((Task task) {
        return DropdownMenuItem<String>(
          value: task.sequence,
          child: Text(task.sequence),
        );
      }).toList(),
    );
  }
}

class UpperCaseInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
        text: newValue.text.toUpperCase(),
        composing: newValue.composing,
        selection: newValue.selection);
  }
}
