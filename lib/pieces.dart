class ChessPiece {
  bool white = true;
  bool wasMoved = false;

  void setWasMoved() {
    wasMoved = true;
  }

  // ignore the following method, they are just as placeholders for null safety
  String renderChar() {
    return "";
  }

  // ignore the following method, they are just as placeholders for null safety
  Set<String> validMoves(List board, int startRow, int startCol) {
    return {};
  }

  bool isWhite() {
    return white;
  }

  bool checkInbounds(int x, int y) {
    return x >= 0 && x < 8 && y >= 0 && y < 8;
  }

  bool checkMoveExposeKing(bool isWhite) {
    //check valid moves of all enemy pieces and see if any of them land on king's current position

    return false;
  }

  Set<String> horMoves(board, int startRow, int startCol) {
    Set<String> validMoves = {};
    bool leftCollision = false;
    bool rightCollision = false;
    bool curPieceWhite = board[startRow][startCol].isWhite();

    int x = startCol - 1;
    while ((!leftCollision) && 0 <= x) {
      var curSpot = board[startRow][x];
      if (curSpot != null) {
        //collision
        if (curPieceWhite != curSpot.isWhite()) {
          //opponent piece
          leftCollision = true;
          validMoves.add(startRow.toString() + x.toString());
        }
        leftCollision = true;
      } else {
        //no collision
        validMoves.add(startRow.toString() + x.toString());
        x -= 1;
      }
    }
    x = startCol + 1;
    while ((!rightCollision) && x < 8) {
      var curSpot = board[startRow][x];
      if (curSpot != null) {
        //collision
        if (curPieceWhite != curSpot.isWhite()) {
          //opponent piece
          rightCollision = true;
          validMoves.add(startRow.toString() + x.toString());
        }
        rightCollision = true;
      } else {
        //no collision
        validMoves.add(startRow.toString() + x.toString());
        x += 1;
      }
    }
    return validMoves;
  }

  Set<String> verMoves(board, int startRow, int startCol) {
    Set<String> validMoves = {};
    bool topCollision = false;
    bool downCollision = false;
    bool curPieceWhite = board[startRow][startCol].isWhite();

    int y = startRow - 1;
    while ((!topCollision) && 0 <= y) {
      var curSpot = board[y][startCol];
      if (curSpot != null) {
        //collision
        if (curPieceWhite != curSpot.isWhite()) {
          //opponent piece
          topCollision = true;
          validMoves.add(y.toString() + startCol.toString());
        }
        topCollision = true;
      } else {
        //no collision
        validMoves.add(y.toString() + startCol.toString());
        y -= 1;
      }
    }
    y = startRow + 1;
    while ((!downCollision) && y < 8) {
      var curSpot = board[y][startCol];
      if (curSpot != null) {
        //collision
        if (curPieceWhite != curSpot.isWhite()) {
          //opponent piece
          downCollision = true;
          validMoves.add(y.toString() + startCol.toString());
        }
        downCollision = true;
      } else {
        //no collision
        validMoves.add(y.toString() + startCol.toString());
        y += 1;
      }
    }
    return validMoves;
  }

  Set<String> diagMoves(board, int startRow, int startCol) {
    Set<String> validMoves = {};
    bool topRightCollision = false;
    bool topLeftCollision = false;
    bool downRightCollision = false;
    bool downLeftCollision = false;
    bool curPieceWhite = board[startRow][startCol].isWhite();
    int x = startRow + 1;
    int y = startCol + 1;
    while ((!downRightCollision) && x < 8 && y < 8) {
      var curSpot = board[x][y];
      if (curSpot != null) {
        //collision
        if (curPieceWhite != curSpot.isWhite()) {
          //opponent piece
          downRightCollision = true;
          validMoves.add(x.toString() + y.toString());
        }
        downRightCollision = true;
      } else {
        //no collision
        validMoves.add(x.toString() + y.toString());
        x += 1;
        y += 1;
      }
    }
    x = startRow - 1;
    y = startCol + 1;
    while ((!topRightCollision) && 0 <= x && y < 8) {
      var curSpot = board[x][y];
      if (curSpot != null) {
        //collision
        if (curPieceWhite != curSpot.isWhite()) {
          //opponent piece
          topRightCollision = true;
          validMoves.add(x.toString() + y.toString());
        }
        topRightCollision = true;
      } else {
        //no collision
        validMoves.add(x.toString() + y.toString());
        x -= 1;
        y += 1;
      }
    }
    x = startRow - 1;
    y = startCol - 1;
    while ((!topLeftCollision) && 0 <= x && 0 <= y) {
      var curSpot = board[x][y];
      if (curSpot != null) {
        //collision
        if (curPieceWhite != curSpot.isWhite()) {
          //opponent piece
          topLeftCollision = true;
          validMoves.add(x.toString() + y.toString());
        }
        topLeftCollision = true;
      } else {
        //no collision
        validMoves.add(x.toString() + y.toString());
        x -= 1;
        y -= 1;
      }
    }
    x = startRow + 1;
    y = startCol - 1;
    while ((!downLeftCollision) && x < 8 && 0 <= y) {
      var curSpot = board[x][y];
      if (curSpot != null) {
        //collision
        if (curPieceWhite != curSpot.isWhite()) {
          //opponent piece
          downLeftCollision = true;
          validMoves.add(x.toString() + y.toString());
        }
        downLeftCollision = true;
      } else {
        //no collision
        validMoves.add(x.toString() + y.toString());
        x += 1;
        y -= 1;
      }
    }

    return validMoves;
  }
}

class King extends ChessPiece {
  bool canCastle = true;

  King(
    bool white,
  ) {
    this.white = white;
  }

  @override
  String renderChar() {
    return white ? "k" : "l";
  }

  @override
  Set<String> validMoves(List board, int startRow, int startCol) {
    Set<String> validMoves = {};
    for (int x = -1; x <= 1; x++) {
      for (int y = -1; y <= 1; y++) {
        if (x == 0 && y == 0) {
          continue;
        }

        if (checkInbounds(startRow + x, startCol + y)) {
          var curSpot = board[startRow + x][startCol + y];
          if (curSpot == null) {
            validMoves
                .add((startRow + x).toString() + (startCol + y).toString());
          } else if (curSpot.isWhite() != white) {
            validMoves
                .add((startRow + x).toString() + (startCol + y).toString());
          }
        }
      }
    }
    return validMoves;
  }
}

class Queen extends ChessPiece {
  Queen(
    bool white,
  ) {
    this.white = white;
  }

  @override
  String renderChar() {
    return white ? "q" : "w";
  }

  @override
  Set<String> validMoves(List board, int startRow, int startCol) {
    Set<String> legalMoves = {};
    legalMoves = legalMoves.union(horMoves(board, startRow, startCol));
    legalMoves = legalMoves.union(verMoves(board, startRow, startCol));
    legalMoves = legalMoves.union(diagMoves(board, startRow, startCol));
    return legalMoves;
  }
}

class Rook extends ChessPiece {
  Rook(
    bool white,
  ) {
    this.white = white;
  }

  @override
  String renderChar() {
    return white ? "r" : "t";
  }

  @override
  Set<String> validMoves(List board, int startRow, int startCol) {
    Set<String> legalMoves = {};
    legalMoves = legalMoves.union(horMoves(board, startRow, startCol));
    legalMoves = legalMoves.union(verMoves(board, startRow, startCol));
    return legalMoves;
  }
}

class Bishop extends ChessPiece {
  Bishop(
    bool white,
  ) {
    this.white = white;
  }

  @override
  String renderChar() {
    return white ? "b" : "v";
  }

  @override
  Set<String> validMoves(List board, int startRow, int startCol) {
    Set<String> legalMoves = {};
    legalMoves = legalMoves.union(diagMoves(board, startRow, startCol));
    return legalMoves;
  }
}

class Knight extends ChessPiece {
  Knight(
    bool white,
  ) {
    this.white = white;
  }

  @override
  String renderChar() {
    return white ? "n" : "m";
  }

  @override
  Set<String> validMoves(List board, int startRow, int startCol) {
    Set<String> legalMoves = {};
    List moves = [
      [1, 2],
      [2, 1],
      [-1, 2],
      [-2, 1],
      [1, -2],
      [2, -1],
      [-1, -2],
      [-2, -1]
    ];
    for (int i = 0; i < moves.length; i++) {
      int x = moves[i][0];
      int y = moves[i][1];
      if (checkInbounds(startRow + x, startCol + y)) {
        var curSpot = board[startRow + x][startCol + y];
        if (curSpot == null) {
          legalMoves.add((startRow + x).toString() + (startCol + y).toString());
        } else if (curSpot.isWhite() != white) {
          legalMoves.add((startRow + x).toString() + (startCol + y).toString());
        }
      }
    }

    return legalMoves;
  }
}

class Pawn extends ChessPiece {
  Pawn(
    bool white,
  ) {
    this.white = white;
  }

  @override
  String renderChar() {
    return white ? "p" : "o";
  }

  @override
  Set<String> validMoves(List board, int startRow, int startCol) {
    Set<String> validMoves = {};
    if (white) {
      //white
      if (!wasMoved &&
          board[startRow - 2][startCol] == null &&
          board[startRow - 1][startCol] == null) {
        //first move only
        validMoves.add((startRow - 2).toString() + startCol.toString());
      }
      if (checkInbounds(startRow - 1, startCol) &&
          board[startRow - 1][startCol] == null) {
        validMoves.add((startRow - 1).toString() + startCol.toString());
      }
      if (checkInbounds(startRow - 1, startCol - 1) &&
          board[startRow - 1][startCol - 1] != null &&
          board[startRow - 1][startCol - 1].isWhite() != white) {
        validMoves.add((startRow - 1).toString() + (startCol - 1).toString());
      }
      if (checkInbounds(startRow - 1, startCol + 1) &&
          board[startRow - 1][startCol + 1] != null &&
          board[startRow - 1][startCol + 1].isWhite() != white) {
        validMoves.add((startRow - 1).toString() + (startCol + 1).toString());
      }
    } else {
      //black
      if (!wasMoved &&
          board[startRow + 2][startCol] == null &&
          board[startRow + 1][startCol] == null) {
        //first move only
        validMoves.add((startRow + 2).toString() + startCol.toString());
      }
      if (checkInbounds(startRow + 1, startCol) &&
          board[startRow + 1][startCol] == null) {
        validMoves.add((startRow + 1).toString() + startCol.toString());
      }
      if (checkInbounds(startRow + 1, startCol - 1) &&
          board[startRow + 1][startCol - 1] != null &&
          board[startRow + 1][startCol - 1].isWhite() != white) {
        validMoves.add((startRow + 1).toString() + (startCol - 1).toString());
      }
      if (checkInbounds(startRow + 1, startCol + 1) &&
          board[startRow + 1][startCol + 1] != null &&
          board[startRow + 1][startCol + 1].isWhite() != white) {
        validMoves.add((startRow + 1).toString() + (startCol + 1).toString());
      }

      //en passant rules valid moves

    }
    return validMoves;
  }
}
