import 'dart:math' as math;
import 'dart:core';
import 'package:flutter_chess_board/flutter_chess_board.dart';

class MCTS {
  Stopwatch stopwatch = Stopwatch()..start();
  int nodesVisited = 0;
  int blackloss = 0;
  int whiteloss = 0;
  int draws = 0;
  int stalemates = 0;
  int insufficientMaterialDraw = 0;
  int threefoldRepetitionDraw = 0;

  double ucbl(Node curNode) {
    nodesVisited += 1;
    double val = (curNode.V/curNode.ni) + math.sqrt(2) * math.sqrt(math.log(curNode.N) / curNode.ni);
    return val;
  }

  // Node selection(Node curNode) {
  //   double maxUcb = double.negativeInfinity;
  //   Node selectedChild = curNode.children[0];
  //   for (Node child in curNode.children) {
  //     double ucb = ucbl(child);
  //     if (ucb > maxUcb) {
  //       maxUcb = ucb;
  //       selectedChild = child;
  //     }
  //   }
  //   return selectedChild;
  // }

  Node expansion(Node curNode, bool white) {
    if (curNode.children.isEmpty) {
      return curNode;
    }
    Node selectedChild = curNode.children[0];
    if (white) {
      double maxUcb = double.negativeInfinity;

      for (Node child in curNode.children) {
        double ucb = ucbl(child);
        if (ucb > maxUcb) {
          maxUcb = ucb;
          selectedChild = child;
        }
      }
    } else {
      double minUcb = double.infinity;

      for (Node child in curNode.children) {
        double ucb = ucbl(child);
        if (ucb < minUcb) {
          minUcb = ucb;
          selectedChild = child;
        }
      }
    }

    return expansion(selectedChild, !white);
  }

  double rollout(Node curNode) {
    Chess temp = Chess.fromFEN(curNode.board);
    if (temp.game_over) {
      if (temp.in_checkmate) {
        if (temp.turn == Color.BLACK) {
          blackloss += 1;
          // print("black loss seen: " +
          //     blackloss.toString() +
          //     " whiteloss seen: " +
          //     whiteloss.toString() +
          //     " stalemate seen: " +
          //     stalemates.toString() +
          //     " draws seen: " +
          //     draws.toString() +
          //     " insufficient material draw seen: " +
          //     insufficientMaterialDraw.toString() +
          //     " threefold repetition draw seen: " +
          //     threefoldRepetitionDraw.toString());
          return 1;
        } else if (temp.turn == Color.WHITE) {
          whiteloss += 1;
          // print("black loss seen: " +
          //     blackloss.toString() +
          //     " whiteloss seen: " +
          //     whiteloss.toString() +
          //     " stalemate seen: " +
          //     stalemates.toString() +
          //     " draws seen: " +
          //     draws.toString() +
          //     " insufficient material draw seen: " +
          //     insufficientMaterialDraw.toString() +
          //     " threefold repetition draw seen: " +
          //     threefoldRepetitionDraw.toString());
          return -1;
        }
      }
      if (temp.in_stalemate) {
        stalemates += 1;
        // print("black loss seen: " +
        //     blackloss.toString() +
        //     " whiteloss seen : " +
        //     whiteloss.toString() +
        //     " stalemate seen: " +
        //     stalemates.toString() +
        //     " draws seen: " +
        //     draws.toString() +
        //     " insufficient material draw seen: " +
        //     insufficientMaterialDraw.toString() +
        //     " threefold repetition draw seen: " +
        //     threefoldRepetitionDraw.toString());
        return .5;
      }
      if (temp.in_threefold_repetition) {
        threefoldRepetitionDraw += 1;
        // print("black loss seen: " +
        //     blackloss.toString() +
        //     " whiteloss seen : " +
        //     whiteloss.toString() +
        //     " stalemate seen: " +
        //     stalemates.toString() +
        //     " draws seen: " +
        //     draws.toString() +
        //     " insufficient material draw seen: " +
        //     insufficientMaterialDraw.toString() +
        //     " threefold repetition draw seen: " +
        //     threefoldRepetitionDraw.toString());
        return .5;
      }
      if (temp.in_draw) {
        draws += 1;
        // print("black loss seen: " +
        //     blackloss.toString() +
        //     " whiteloss seen : " +
        //     whiteloss.toString() +
        //     " stalemate seen: " +
        //     stalemates.toString() +
        //     " draws seen: " +
        //     draws.toString() +
        //     " insufficient material draw seen: " +
        //     insufficientMaterialDraw.toString() +
        //     " threefold repetition draw seen: " +
        //     threefoldRepetitionDraw.toString());
        return .5;
      }
      if (temp.insufficient_material) {
        insufficientMaterialDraw += 1;
        // print("black loss seen: " +
        //     blackloss.toString() +
        //     " whiteloss seen : " +
        //     whiteloss.toString() +
        //     " stalemate seen: " +
        //     stalemates.toString() +
        //     " draws seen: " +
        //     draws.toString() +
        //     " insufficient material draw seen: " +
        //     insufficientMaterialDraw.toString() +
        //     " threefold repetition draw seen: " +
        //     threefoldRepetitionDraw.toString());
        return .5;
      }
    }

    List movelist = temp.generate_moves();
    for (int i = 0; i < movelist.length; i++) {
      Chess newboard = temp.copy();
      Move move = movelist[i];
      newboard.move(move);
      List<String> lastmove = [];
      lastmove.add(move.fromAlgebraic);
      lastmove.add(move.toAlgebraic);
      curNode.children.add(Node(curNode, newboard.generate_fen(), lastmove));
    }
    final random = math.Random();
    return rollout(curNode.children[random.nextInt(curNode.children.length)]);
  }

  Node backPropagation(Node curNode, double reward) {
    while (curNode.parent != null) {
      curNode.ni += 1;
      curNode.N += 1;
      curNode.V += reward;
      curNode = curNode.parent ?? curNode;
    }
    return curNode;
  }

  Future<List<String>> getPrediction(Node curNode, bool over, bool white,
      {iterations = 10, maxTime = 10}) async {
    if (over) {
      return [];
    }
    Map<Node, Move> stateMoveMap = {};

    Chess temp = Chess.fromFEN(curNode.board);
    if (curNode.children.isEmpty) {
      List movelist = temp.generate_moves();
      for (int i = 0; i < movelist.length; i++) {
        Move move = movelist[i];
        Chess newboard = temp.copy();
        newboard.move(move);
        List<String> lastmove = [];
        lastmove.add(move.fromAlgebraic);
        lastmove.add(move.toAlgebraic);
        Node newNode = Node(curNode, newboard.generate_fen(), lastmove);
        curNode.children.add(newNode);
        stateMoveMap[newNode] = move;
      }
    }

    while (iterations > 0 ||
        stopwatch.elapsedMilliseconds <
            Duration(seconds: maxTime).inMilliseconds) {
      if (white) {
        double maxUcb = double.negativeInfinity;
        Node selectedChild = curNode.children[0];
        for (Node child in curNode.children) {
          double ucb = ucbl(child);
          if (ucb > maxUcb) {
            maxUcb = ucb;
            selectedChild = child;
          }
        }
        Node exChild = expansion(selectedChild, false);
        double reward = rollout(exChild);
        curNode = backPropagation(exChild, reward);
        iterations--;
      } else {
        double minUcb = double.infinity;
        Node selectedChild = curNode.children[0];
        for (Node child in curNode.children) {
          double ucb = ucbl(child);
          if (ucb < minUcb) {
            minUcb = ucb;
            selectedChild = child;
          }
        }
        Node exChild = expansion(selectedChild, true);
        double reward = rollout(exChild);
        curNode = backPropagation(exChild, reward);
        iterations--;
      }
    }
    if (white) {
      double mx = double.negativeInfinity;
      List<String> selectedMove = [];
      for (Node child in curNode.children) {
        double ucb = ucbl(child);
        if (ucb > mx) {
          print(mx.toString() + " " + ucb.toString());
          mx = ucb;
          selectedMove = [
            stateMoveMap[child]!.fromAlgebraic,
            stateMoveMap[child]!.toAlgebraic
          ];
        }
      }
      return selectedMove;
    } else {
      double mn = double.infinity;
      List<String> selectedMove = [];
      for (Node child in curNode.children) {
        double ucb = ucbl(child);
        print(ucb.toString() + " " + stateMoveMap[child]!.fromAlgebraic);

        if (ucb < mn) {
          print(mn.toString() + " " + ucb.toString());
          mn = ucb;
          selectedMove = [
            stateMoveMap[child]!.fromAlgebraic,
            stateMoveMap[child]!.toAlgebraic
          ];
        }
      }
      return selectedMove;
    }
  }
}

class Node {
  Node? parent;
  String board = "";
  List<String> move = []; //remove maybe?
  List<Node> children = [];
  String action = '';
  double V; //winning score of current node
  int N; //number of times parent visited
  int ni; // number of times children visited

  Node(this.parent, this.board, this.move,
      {this.V = 0.0, this.N = 0, this.ni = 0});
}
