import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_chess_board/flutter_chess_board.dart';
import 'mcts.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class GamePage extends StatefulWidget {
  const GamePage({Key? key, required this.whitePlayer}) : super(key: key);

  final bool whitePlayer;
  @override
  GamePageState createState() => GamePageState();
}

class GamePageState extends State<GamePage> {
  ChessBoardController controller = ChessBoardController();
  final Mcts _compbrain = Mcts();
  bool _whiteThinking = false;
  bool _blackThinking = false;
  String _lmFrom = "";
  String _lmTo = "";
  String _sugFrom = "";
  String _sugTo = "";
  final client = http.Client();

  Future<String?> getServerMove({bool longThink = false}) async {
    try {
      var response = await client.get(Uri(
          scheme: 'http',
          host: '18.188.127.184',
          // port:80,
          path: 'getChessMove',
          queryParameters: {
            'fen': controller.getFen(),
            'maxtime': longThink ? '10000' : '1000'
          }));
      var jsonResp = jsonDecode(utf8.decode(response.bodyBytes)) as Map;
      return jsonResp["BESTMOVE"];
    } catch (e) {
      debugPrint(e.toString());
    }

    return null;
  }

  Future<Move?> getSuggestedMove() async {
    String fen = controller.getFen();
    bool white;

    if (controller.isGameOver()) {
      return null;
    }

    if (fen.split(' ')[1] == 'w') {
      white = true;
    } else {
      white = false;
    }

    setState(() {
      if (white) {
        _whiteThinking = true;
      } else {
        _blackThinking = true;
      }
      _sugFrom = "";
      _sugTo = "";
    });

    String? serverMove = await getServerMove(longThink: true);
    if (serverMove != null) {
      setState(() {
        _blackThinking = false;
        _whiteThinking = false;
        _sugFrom = serverMove.substring(0, 2);
        _sugTo = serverMove.substring(
          2,
        );
      });
    } else {
      Map input = {};
      input["curNode"] = Node(null, fen, null);
      input["white"] = white;
      Move? move = await think(input);
      setState(() {
        _blackThinking = false;
        _whiteThinking = false;
        _sugFrom = move?.fromAlgebraic ?? "";
        _sugTo = move?.toAlgebraic ?? "";
      });
    }

    Future.delayed(const Duration(seconds: 5), () {
      setState(() {
        _sugFrom = "";
        _sugTo = "";
      });
    });
  }

  makeComputerMove() async {
    if (controller.isGameOver()) {
      _check4mate();
      return;
    }

    //check if curplayer is human

    String fen = controller.getFen();
    bool white;
    if (fen.split(' ')[1] == 'w') {
      white = true;
    } else {
      white = false;
    }

    if (white == widget.whitePlayer) {
      return;
    }

    setState(() {
      if (white) {
        _whiteThinking = true;
      } else {
        _blackThinking = true;
      }
    });

    if (widget.whitePlayer != white) {
      String? serverMove = await getServerMove();
      if (serverMove != null) {
        controller.makeMove(
            from: serverMove.substring(0, 2),
            to: serverMove.substring(
              2,
            ));

        setState(() {
          _blackThinking = false;
          _whiteThinking = false;
          _lmFrom = serverMove.substring(0, 2);
          _lmTo = serverMove.substring(
            2,
          );
        });
      } else {
        Map input = {};
        input["curNode"] = Node(null, fen, null);
        input["white"] = white;
        await think(input).then((move) {
          if (move != null) {
            controller.makeMove(from: move.fromAlgebraic, to: move.toAlgebraic);
          }
          setState(() {
            _blackThinking = false;
            _whiteThinking = false;
            _lmFrom = move?.fromAlgebraic ?? "";
            _lmTo = move?.toAlgebraic ?? "";
          });
        });
      }
      _check4mate();
    }
  }

  Future<void> _check4mate() async {
    if (!controller.isGameOver()) {
      return;
    }
    if (controller.isCheckMate()) {
      return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return const AlertDialog(
            title: Text('Checkmate!', textAlign: TextAlign.center),
          );
        },
      );
    }
    if (controller.isInCheck()) {
      return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return const AlertDialog(
            title: Text('Check!', textAlign: TextAlign.center),
          );
        },
      );
    }
    if (controller.isDraw()) {
      return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return const AlertDialog(
            title: Text('Draw!', textAlign: TextAlign.center),
          );
        },
      );
    }
    if (controller.isInsufficientMaterial() ||
        controller.isStaleMate() ||
        controller.isThreefoldRepetition()) {
      return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return const AlertDialog(
            title: Text('Stalemate!', textAlign: TextAlign.center),
          );
        },
      );
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
    if (!widget.whitePlayer) {
      makeComputerMove();
    }
  }

  @override
  void initState() {
    super.initState();
    makeComputerMove();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Visibility(
            visible: widget.whitePlayer ? _blackThinking : _whiteThinking,
            child: Container(
                margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: const LinearProgressIndicator(
                  minHeight: 10,
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
                    enableUserMoves: !_whiteThinking && !_blackThinking,
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
                    boardOrientation: widget.whitePlayer
                        ? PlayerColor.white
                        : PlayerColor.black),
              ),
            ),
          ),
          Visibility(
            visible: widget.whitePlayer ? _whiteThinking : _blackThinking,
            child: Container(
                margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: const LinearProgressIndicator(
                  minHeight: 10,
                  backgroundColor: Colors.indigo,
                  color: Colors.white54,
                )),
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              margin: const EdgeInsets.fromLTRB(10, 80, 10, 10),
              child: FloatingActionButton(
                tooltip: "Undo Last Move",
                heroTag: "undo",
                onPressed: () {
                  !_whiteThinking && !_blackThinking
                      ? controller.undoMove()
                      : null;
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
                  !_whiteThinking && !_blackThinking ? resetGame() : null;
                },
                backgroundColor: Colors.green,
                child: const Icon(Icons.refresh),
              ),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(10, 80, 10, 10),
              child: FloatingActionButton(
                tooltip: "Get Help",
                heroTag: "Help",
                onPressed: () {
                  !_whiteThinking && !_blackThinking
                      ? getSuggestedMove()
                      : null;
                },
                backgroundColor: Colors.blue,
                child: const Icon(Icons.auto_awesome),
              ),
            ),
          ]),
        ],
      ),
    ));
  }
}
