class Player {

  String name;
  int runs;
  int ballsFaced;

  Player({required this.name, this.runs = 0, this.ballsFaced = 0});

  void addRuns(int amount) {
    runs += amount;
  }

  void addBallsFaced() {
    ballsFaced ++;
  }

  int get playerRuns {
    return runs;
  }

  int get playerBallsFaced {
    return ballsFaced;
  }


}




// void main() {

//   var player1 = Player(name: "John Doe");

//   player1.attack();

//   player1.takeDamage(20);

//   print("Player health: ${player1.health}");

// }
