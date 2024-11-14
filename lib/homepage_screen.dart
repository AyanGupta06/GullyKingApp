import 'package:flutter/material.dart';

void main() {
  runApp(GullyKing());
}

class GullyKing extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gully King',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 50),
            Text(
              'Gully King',
              style: TextStyle(
                fontSize: 36, // Increased font size
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Gully Cricket Score Tracker',
              style: TextStyle(
                fontSize: 18,
                color: Colors.blue.shade700,
              ),
            ),
            SizedBox(height: 50),
            SizedBox(
              width: 200, // Fixed width for buttons
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NewSinglesMatchPage()),
                  );
                },
                child: Text('New Singles Match'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.blue,
                ),
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: 200, // Fixed width for buttons
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NewDoublesMatchPage()),
                  );
                },
                child: Text('New Doubles Match'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.blue,
                ),
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: 200, // Fixed width for buttons
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PreviousMatchesPage()),
                  );
                },
                child: Text('Previous Matches'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.blue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}




class PreviousMatchesPage extends StatefulWidget {
  @override
  _PreviousMatchesPageState createState() => _PreviousMatchesPageState();
}

class _PreviousMatchesPageState extends State<PreviousMatchesPage> {
  List<String> singlesMatches = [];
  List<String> doublesMatches = [];

  @override
  void initState() {
    super.initState();
    _loadPreviousMatches();
  }

  _loadPreviousMatches() async {
    //SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      //singlesMatches = (prefs.getStringList('singlesMatches') ?? []).reversed.toList();
      //doublesMatches = (prefs.getStringList('doublesMatches') ?? []).reversed.toList();
    });
  }

  _deleteMatch(int index, String type) async {
    //SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> matches;

    if (type == 'singles') {
      matches = singlesMatches;
      matches.removeAt(index);
      //await prefs.setStringList('singlesMatches', matches);
    } else {
      matches = doublesMatches;
      matches.removeAt(index);
      //await prefs.setStringList('doublesMatches', matches);
    }
    _loadPreviousMatches();
  }

  _confirmDelete(int index, String type) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this match?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Yes'),
              onPressed: () {
                _deleteMatch(index, type);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Previous Matches'),
        backgroundColor: Colors.blue,
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: <Widget>[
          Text(
            'Singles Matches',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          ...singlesMatches.map((match) {
            int index = singlesMatches.indexOf(match);
            return ListTile(
              title: Text(match),
              trailing: IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () => _confirmDelete(index, 'singles'),
              ),
            );
          }).toList(),
          SizedBox(height: 20),
          Text(
            'Doubles Matches',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          ...doublesMatches.map((match) {
            int index = doublesMatches.indexOf(match);
            return ListTile(
              title: Text(match),
              trailing: IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () => _confirmDelete(index, 'doubles'),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}

class NewSinglesMatchPage extends StatefulWidget {
  @override
  _NewSinglesMatchPageState createState() => _NewSinglesMatchPageState();
}

class _NewSinglesMatchPageState extends State<NewSinglesMatchPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _player1Controller = TextEditingController();
  final TextEditingController _player2Controller = TextEditingController();
  int player1Score = 0;
  int player2Score = 0;
  DateTime _selectedDate = DateTime.now();

  void _incrementPlayer1Score() {
    setState(() {
      player1Score++;
    });
  }

  void _incrementPlayer2Score() {
    setState(() {
      player2Score++;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate)
      setState(() {
        _selectedDate = picked;
      });
  }

  void _saveMatch() async {
    if (_formKey.currentState!.validate()) {
      final match = '${_player1Controller.text} $player1Score - ${_player2Controller.text} $player2Score on ${_selectedDate.toLocal().toShortDateString()}';
      //SharedPreferences prefs = await SharedPreferences.getInstance();
      //List<String> singlesMatches = (prefs.getStringList('singlesMatches') ?? []);
      //singlesMatches.insert(0, match); // Add to the top of the list
      //await prefs.setStringList('singlesMatches', singlesMatches);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Singles Match'),
        backgroundColor: Colors.blue,
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextFormField(
                controller: _player1Controller,
                decoration: InputDecoration(labelText: 'Player 1 Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Player 1 name';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _player2Controller,
                decoration: InputDecoration(labelText: 'Player 2 Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Player 2 name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              Text(
                'Player 1 Score: $player1Score',
                style: TextStyle(fontSize: 20),
              ),
              ElevatedButton(
                onPressed: _incrementPlayer1Score,
                child: Text('Add Point to Player 1'),
              ),
              SizedBox(height: 20),
              Text(
                'Player 2 Score: $player2Score',
                style: TextStyle(fontSize: 20),
              ),
              ElevatedButton(
                onPressed: _incrementPlayer2Score,
                child: Text('Add Point to Player 2'),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Match Date: ${_selectedDate.toLocal().toShortDateString()}',
                    style: TextStyle(fontSize: 20),
                  ),
                  ElevatedButton(
                    onPressed: () => _selectDate(context),
                    child: Text('Select Date'),
                  ),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveMatch,
                child: Text('Save Match'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NewDoublesMatchPage extends StatefulWidget {
  @override
  _NewDoublesMatchPageState createState() => _NewDoublesMatchPageState();
}

class _NewDoublesMatchPageState extends State<NewDoublesMatchPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _team1Player1Controller = TextEditingController();
  final TextEditingController _team1Player2Controller = TextEditingController();
  final TextEditingController _team2Player1Controller = TextEditingController();
  final TextEditingController _team2Player2Controller = TextEditingController();
  int team1Score = 0;
  int team2Score = 0;
  DateTime _selectedDate = DateTime.now();

  void _incrementTeam1Score() {
    setState(() {
      team1Score++;
    });
  }

  void _incrementTeam2Score() {
    setState(() {
      team2Score++;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate)
      setState(() {
        _selectedDate = picked;
      });
  }

  void _saveMatch() async {
    if (_formKey.currentState!.validate()) {
      final match = '${_team1Player1Controller.text} & ${_team1Player2Controller.text} $team1Score - ${_team2Player1Controller.text} & ${_team2Player2Controller.text} $team2Score on ${_selectedDate.toLocal().toShortDateString()}';
      //SharedPreferences prefs = await SharedPreferences.getInstance();
      //List<String> doublesMatches = (prefs.getStringList('doublesMatches') ?? []);
      //doublesMatches.insert(0, match); // Add to the top of the list
      //await prefs.setStringList('doublesMatches', doublesMatches);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Doubles Match'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      controller: _team1Player1Controller,
                      decoration: InputDecoration(labelText: 'Team 1 Player 1 Name'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter Team 1 Player 1 name';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _team1Player2Controller,
                      decoration: InputDecoration(labelText: 'Team 1 Player 2 Name'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter Team 1 Player 2 name';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _team2Player1Controller,
                      decoration: InputDecoration(labelText: 'Team 2 Player 1 Name'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter Team 2 Player 1 name';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _team2Player2Controller,
                      decoration: InputDecoration(labelText: 'Team 2 Player 2 Name'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter Team 2 Player 2 name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Team 1 Score: $team1Score',
                      style: TextStyle(fontSize: 20),
                    ),
                    ElevatedButton(
                      onPressed: _incrementTeam1Score,
                      child: Text('Add Point to Team 1'),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Team 2 Score: $team2Score',
                      style: TextStyle(fontSize: 20),
                    ),
                    ElevatedButton(
                      onPressed: _incrementTeam2Score,
                      child: Text('Add Point to Team 2'),
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(
                          'Match Date: ${_selectedDate.toLocal().toShortDateString()}',
                          style: TextStyle(fontSize: 20),
                        ),
                        ElevatedButton(
                          onPressed: () => _selectDate(context),
                          child: Text('Select Date'),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _saveMatch,
                      child: Text('Save Match'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


extension DateTimeFormat on DateTime {
  String toShortDateString() {
    return '${this.month}/${this.day}/${this.year}';
  }
}