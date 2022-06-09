class Player {
  bool white = false;
  bool enPassante = false;
}

class ComputerPlayer extends Player {
  ComputerPlayer(bool white) {
    this.white = white;
  }
  void generateMove(board) {}
}

class HumanPlayer extends Player {
  HumanPlayer(bool white) {
    this.white = white;
  }
}
