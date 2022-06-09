import 'package:flutter/material.dart';
import 'package:flutter_chess_board/flutter_chess_board.dart';
import 'MCTS.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ChessBoardController controller = ChessBoardController();
  MCTS compbrain = MCTS();
  bool loading = false;
  String lmFrom = "";
  String lmTo = "";

  makeNextMove() {
    String fen = controller.getFen();
    print(fen.split(' '));
    bool white;
    if (fen.split(' ')[1] == 'w') {
      white = true;
    } else {
      white = false;
    }
    Node root = Node(null, fen);

    setState(() {
      loading = true;
    });
    compbrain
        .getPrediction(
            root, controller.isGameOver(), white, controller.getMoveCount())
        .then((move) => {
              setState(() {
                loading = false;
                lmFrom = move[0];
                lmTo = move[1];
              }),
              controller.makeMove(from: move[0], to: move[1])
            });
    print("nodesvisited: , ${compbrain.nodesVisited}");
  }

  void resetGame() {
    controller.resetBoard();
    setState(() {
      lmFrom = "";
      lmTo = "";
      loading = false;
    });
  }

  // @override
  // void initState() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // SingleChildScrollView(
          //     child: ConstrainedBox(
          //   constraints: BoxConstraints(
          //       maxHeight: MediaQuery.of(context).size.height * .10),
          //   child: ValueListenableBuilder<Chess>(
          //     valueListenable: controller,
          //     builder: (context, game, _) {
          //       return Text(
          //         controller.getSan().fold(
          //               '',
          //               (previousValue, element) =>
          //                   previousValue + '\n' + (element ?? ''),
          //             ),
          //       );
          //     },
          //   ),
          // )),
          AspectRatio(
            aspectRatio: 1.0,
            child: Container(
              padding: const EdgeInsets.all(8.0),
              margin: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.black, width: 2.0)),
              child: Expanded(
                child: Center(
                  child: ChessBoard(
                    onMove: () => makeNextMove(),
                    // enableUserMoves: false,
                    controller: controller,
                    boardColor: BoardColor.green,
                    arrows: lmFrom.isNotEmpty
                        ? [
                            BoardArrow(
                              from: lmFrom,
                              to: lmTo,
                              color: Colors.red.withOpacity(0.5),
                            )
                          ]
                        : [],
                    boardOrientation: PlayerColor.white,
                  ),
                ),
              ),
            ),
          ),
          Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: 
              // !loading
              //     ? [
              //         Container(
              //             margin: const EdgeInsets.fromLTRB(10, 80, 10, 10),
              //             child: const LinearProgressIndicator(
              //               color: Colors.purple,
              //             ))
              //       ]
              //     : 
                  [
                      Container(
                        margin: const EdgeInsets.fromLTRB(10, 80, 10, 10),
                        child: FloatingActionButton(
                          onPressed: () {
                            resetGame();
                          },
                          backgroundColor: Colors.green,
                          child: const Icon(Icons.refresh),
                          // isExtended: true,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.fromLTRB(10, 80, 10, 10),
                        child: FloatingActionButton(
                          onPressed: () {
                            controller.undoMove();
                          },
                          backgroundColor: Colors.deepPurpleAccent,
                          child: const Icon(Icons.undo),
                          // isExtended: true,
                        ),
                      )
                    ]),
        ],
      ),
    ));
  }
}
