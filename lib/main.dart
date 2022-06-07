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

  makeBlackMove() async {
    String fen = controller.getFen();
    print(fen.split(' '));
    bool white;
    if (fen.split(' ')[1] == 'w') {
      white = false;
    } else {
      white = true;
    }
    Chess copyBoard = Chess.fromFEN(fen);
    Node start = Node(null, copyBoard, []);
    MCTS compbrain = MCTS();
    compbrain
        .getPrediction(start, controller.isGameOver(), white, iterations: 1)
        .then((move) =>
            {print(move), controller.makeMove(from: move[0], to: move[1])});
    print("nodesvisited: "+ compbrain.NodesVisited.toString());

    // get move from MCTS
    // make move
    // move=Move(int from, int to)
    // controller.makeMove(move);
    //.makeMoveWithNormalNotation(move);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // appBar: AppBar(
        //   title: const Text('Chess Demo'),
        // ),
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
                    onMove: () => makeBlackMove(),
                    // enableUserMoves: false,

                    controller: controller,
                    boardColor: BoardColor.green,
                    // arrows: [
                    // BoardArrow(
                    //   from: 'd2',
                    //   to: 'd4',
                    //   color: Colors.blue.withOpacity(0.5),
                    // ),
                    // BoardArrow(
                    //   from: 'e7',
                    //   to: 'e5',
                    //   color: Colors.red.withOpacity(0.7),
                    // ),
                    // ],
                    boardOrientation: PlayerColor.white,
                  ),
                ),
              ),
            ),
          ),
          // FutureBuilder(
          //   future: makeBlackMove(),
          //   builder: (context, snapshot) {
          //     if (snapshot.hasData) {
          //       return const Text('Your Turn');
          //     } else {
          //       return const CircularProgressIndicator();
          //     }
          //   },
          // ),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              margin: const EdgeInsets.fromLTRB(10, 80, 10, 10),
              child: FloatingActionButton(
                onPressed: () {
                  // controller.getPossibleMoves().forEach((element) {
                  //   print("from: " +
                  //       element.fromAlgebraic +
                  //       " to: " +
                  //       element.toAlgebraic);
                  //   print("from: " +
                  //       element.from.toString() +
                  //       " to: " +
                  //       element.to.toString());
                  // });
                  controller.resetBoard();
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
