import 'package:flutter/material.dart';
import 'pieces.dart';
// GameBoard class
/*displays the game board and handles the logic of the game*/

class GameBoard extends StatefulWidget {
  const GameBoard({Key? key}) : super(key: key);

  @override
  State<GameBoard> createState() => _GameBoardState();
}

King piece = King(true);

class _GameBoardState extends State<GameBoard> {
  int selectedX = -1;
  int selectedY = -1;
  List<List<ChessPiece?>> defaultBoard = [
    [
      Rook(false),
      Knight(false),
      Bishop(false),
      Queen(false),
      King(false),
      Bishop(false),
      Knight(false),
      Rook(false)
    ],
    [
      Pawn(false),
      Pawn(false),
      Pawn(false),
      Pawn(false),
      Pawn(false),
      Pawn(false),
      Pawn(false),
      Pawn(false),
    ],
    [null, null, null, null, null, null, null, null],
    [null, null, null, null, null, null, null, null],
    [null, null, null, null, null, null, null, null],
    [null, null, null, null, null, null, null, null],
    [
      Pawn(true),
      Pawn(true),
      Pawn(true),
      Pawn(true),
      Pawn(true),
      Pawn(true),
      Pawn(true),
      Pawn(true),
    ],
    [
      Rook(true),
      Knight(true),
      Bishop(true),
      Queen(true),
      King(true),
      Bishop(true),
      Knight(true),
      Rook(true)
    ]
  ];
  List<List<ChessPiece?>> curBoard = [
    [King(false), null, null, null, null, null, null, null],
    [null, null, null, null, null, null, null, null],
    [null, null, null, null, null, null, null, null],
    [null, null, null, null, null, null, null, null],
    [null, null, null, Queen(true), null, Queen(false), null, null],
    [null, null, null, null, null, null, null, null],
    [null, null, King(true), null, null, null, null, Queen(true)],
    [null, null, null, null, null, null, null, null]
  ];
  bool whiteTurn = true;
  bool p1enPassante = false;
  bool p2enPassante = false;
  bool p1Castle = false;
  bool p2Castle = false;
  Set<String> validMoves = {};

  // void flipBoard() {
  //   for (int i = 0; i < 2; i++) {
  //     for (int i = 0; i < curBoard.length; i++) {
  //       for (int j = i; j < curBoard.length; j++) {
  //         String temp = curBoard[i][j];
  //         curBoard[i][j] = curBoard[j][i];
  //         curBoard[j][i] = temp;
  //       }
  //     }

  //     // Then we reverse the elements of each row.
  //     for (int i = 0; i < curBoard.length; i++) {
  //       // Logic to reverse each row i.e 1D Array.
  //       int low = 0;
  //       int high = curBoard.length - 1;

  //       while (low < high) {
  //         String temp = curBoard[i][low];
  //         curBoard[i][low] = curBoard[i][high];
  //         curBoard[i][high] = temp;

  //         low++;
  //         high--;
  //       }
  //     }
  //   }
  // }

  void highlightValidMoves(int row, int col) {
    ChessPiece? piece = curBoard[row][col];
    print(piece.toString() + row.toString() + " " + col.toString());
    if (piece == null) {
      //empty square
      validMoves.clear();
      return;
    }
    if (piece.isWhite() != whiteTurn) {
      //if the piece is not the same color as the turn
      validMoves.clear();
      return;
    }
    validMoves = piece.validMoves(curBoard, row, col);
  }

  void resetGame() {
    setState(() {
      selectedX = -1;
      selectedY = -1;
      curBoard = List.from(defaultBoard);
      whiteTurn = true;
      p1enPassante = false;
      p2enPassante = false;
      p1Castle = false;
      p2Castle = false;
      validMoves.clear();
    });
  }

  void checkWin() {}

  void handleTap(row, col) {
    if (!validMoves.contains(row.toString() + col.toString())) {
      //selecting spot
      highlightValidMoves(row, col);
      setState(() => {selectedX = row, selectedY = col});
    } else {
      //swap locations if curBoard[row][col] is "0"
      if (curBoard[row][col] == null) {
        ChessPiece? temp = curBoard[selectedX][selectedY];
        curBoard[selectedX][selectedY] = curBoard[row][col];
        curBoard[row][col] = temp;
        validMoves.clear();
        setState((() => {whiteTurn = !whiteTurn}));
      } else {
        curBoard[row][col] = curBoard[selectedX][selectedY];
        curBoard[selectedX][selectedY] = null;
        validMoves.clear();
        setState((() => {whiteTurn = !whiteTurn}));
      }
    }
  }

  Widget _buildGridItems(BuildContext context, int index) {
    int gridStateLength = curBoard.length;
    int x, y = 0;
    x = (index / gridStateLength).floor();
    y = (index % gridStateLength);
    return GestureDetector(
      onTap: () => {handleTap(x, y)},
      child: GridTile(
        child: Container(
          decoration: BoxDecoration(
              border: Border.all(color: Colors.black, width: 0.5)),
          child: Container(
            color: (x % 2 == 0 && y % 2 == 0) || (x % 2 == 1 && y % 2 == 1)
                ? (x == selectedX && y == selectedY && curBoard[x][y] != null)
                    ? Colors.green[700]
                    : validMoves.contains(x.toString() + y.toString())
                        ? Colors.blue[300]
                        : Colors.white38
                : (x == selectedX && y == selectedY && curBoard[x][y] != null)
                    ? Colors.green[700]
                    : validMoves.contains(x.toString() + y.toString())
                        ? Colors.blue[300]
                        : Colors.brown[300],
            child: Center(child: _buildPositionItem(x, y)),
          ),
        ),
      ),
    );
  }

  Widget _buildPositionItem(int x, int y) {
    switch (curBoard[x][y]) {
      case null:
        return Container();
      default:
        // return Text(curBoard[x][y].toString());
        return Center(
            child: Text(curBoard[x][y]?.renderChar() ?? "",
                style: TextStyle(
                    fontFamily: 'Chess7',
                    fontSize: MediaQuery.of(context).size.width * 0.1)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      AspectRatio(
          aspectRatio: 1.0,
          child: Container(
              padding: const EdgeInsets.all(8.0),
              margin: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 2.0)),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 8,
                ),
                itemBuilder: _buildGridItems,
                itemCount: 64,
              ))),
      Container(
        margin: const EdgeInsets.fromLTRB(10, 80, 10, 10),
        child: FloatingActionButton(
          onPressed: () {
            resetGame();
          },
          child: const Icon(Icons.refresh),
          backgroundColor: Colors.green,
          // isExtended: true,
        ),
      ),
    ])));
  }
}
