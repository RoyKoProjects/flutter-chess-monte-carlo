import 'package:flutter/material.dart';
import 'package:flutter_chess_board/flutter_chess_board.dart';
import 'MCTS.dart';
import 'package:flutter/foundation.dart';

class GamePage extends StatefulWidget {
  const GamePage({Key? key, required this.whitePlayer}) : super(key: key);

  final bool whitePlayer;
  @override
  GamePageState createState() => GamePageState();
}

class GamePageState extends State<GamePage> {
  ChessBoardController controller = ChessBoardController();
  final MCTS _compbrain = MCTS();
  bool _white_thinking = false;
  bool _blackThinking = false;
  String _lmFrom = "";
  String _lmTo = "";
  String _sugFrom = "";
  String _sugTo = "";

  Future<Move?> getSuggestedMove() async {
    String fen = controller.getFen();
    print(fen.split(' '));
    bool white;
    if (fen.split(' ')[1] == 'w') {
      white = true;
    } else {
      white = false;
    }
    Map input = {};
    input["curNode"] = Node(null, fen, null);
    input["white"] = white;
    input["moveCount"] = controller.getMoveCount();
    if (controller.isGameOver()) {
      return null;
    }
    setState(() {
      if (white) {
        _white_thinking = true;
      } else {
        _blackThinking = true;
      }
    });
    Move? move = await think(input);
    print(move?.fromAlgebraic);
    print(move?.toAlgebraic);
    setState(() {
      _blackThinking = false;
      _white_thinking = false;
      _sugFrom = move?.fromAlgebraic ?? "";
      _sugTo = move?.toAlgebraic ?? "";
    });

    Future.delayed(const Duration(seconds: 15), () {
      setState(() {
        _sugFrom = "";
        _sugTo = "";
      });
    });
    return move;
  }

  makeComputerMove() {
    if (controller.isGameOver()) {
      return;
    }

    String fen = controller.getFen();
    bool white;
    if (fen.split(' ')[1] == 'w') {
      white = true;
    } else {
      white = false;
    }

    if (widget.whitePlayer != white) {
      getSuggestedMove().then((move) {
        if (move != null) {
          controller.makeMove(from: move.fromAlgebraic, to: move.toAlgebraic);
        }
      });
    }
  }

  Future<Move?> think(Map input) async {
    return await compute(_compbrain.getPrediction, input);
  }

  void resetGame() {
    controller.resetBoard();
    setState(() {
      _lmFrom = "";
      _lmTo = "";
      _sugFrom = "";
      _sugTo = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Visibility(
            visible: _blackThinking,
            child: Container(
                margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: const LinearProgressIndicator(
                  minHeight: 20,
                  backgroundColor: Colors.black,
                  color: Colors.pink,
                )),
          ),
          AspectRatio(
            aspectRatio: 1.0,
            child: Container(
              padding: const EdgeInsets.all(8.0),
              margin: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 2.0)),
              child: Center(
                child: ChessBoard(
                  onMove: () => {makeComputerMove()},
                  enableUserMoves: !_white_thinking && !_blackThinking,
                  controller: controller,
                  boardColor: BoardColor.green,
                  arrows: _lmFrom.isNotEmpty && _sugFrom.isNotEmpty
                      ? [
                          BoardArrow(
                            from: _lmFrom,
                            to: _lmTo,
                            color: Colors.red.withOpacity(0.5),
                          ),
                          BoardArrow(
                            from: _sugFrom,
                            to: _sugTo,
                            color: Colors.indigo.withOpacity(0.5),
                          )
                        ]
                      : _lmFrom.isNotEmpty
                          ? [
                              BoardArrow(
                                from: _lmFrom,
                                to: _lmTo,
                                color: Colors.red.withOpacity(0.5),
                              ),
                            ]
                          : _sugFrom.isNotEmpty
                              ? [
                                  BoardArrow(
                                    from: _sugFrom,
                                    to: _sugTo,
                                    color: Colors.pink.withOpacity(0.5),
                                  )
                                ]
                              : [],
                  boardOrientation: PlayerColor.white,
                ),
              ),
            ),
          ),
          Visibility(
            visible: !_white_thinking && !_blackThinking,
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(
                margin: const EdgeInsets.fromLTRB(10, 80, 10, 10),
                child: FloatingActionButton(
                  tooltip: "Undo Last Move",
                  heroTag: "undo",
                  onPressed: () {
                    controller.undoMove();
                  },
                  backgroundColor: Colors.deepPurpleAccent,
                  child: const Icon(Icons.undo),
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(10, 80, 10, 10),
                child: FloatingActionButton(
                  tooltip: "Reset Game",
                  heroTag: "reset",
                  onPressed: () {
                    resetGame();
                  },
                  backgroundColor: Colors.green,
                  child: const Icon(Icons.refresh),
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(10, 80, 10, 10),
                child: FloatingActionButton(
                  tooltip: "Suggest Move",
                  heroTag: "suggest",
                  onPressed: () {
                    getSuggestedMove();
                  },
                  backgroundColor: Colors.blue,
                  child: const Icon(Icons.auto_awesome),
                ),
              )
            ]),
          ),
          Visibility(
            visible: _white_thinking,
            child: Container(
                margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: const LinearProgressIndicator(
                  minHeight: 20,
                  backgroundColor: Colors.indigo,
                  color: Colors.white54,
                )),
          )
        ],
      ),
    ));
  }
}