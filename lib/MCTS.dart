import 'dart:math' as math;
import 'dart:core';
import 'package:flutter_chess_board/flutter_chess_board.dart';

class MCTS {
  Stopwatch stopwatch = Stopwatch()..start();
  int nodesVisited = 0;
  Node root =
      Node(null, "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1");
  // Node curNode;

  bool moveRoot(String fenMove) {
    for (Node child in root.children) {
      if (child.board == fenMove) {
        root = child;
        return true;
      }
    }
    return false;
  }

  // List<String> getMoveSuggestion(bool white) {
  //   if (white) {
  //     double mx = double.negativeInfinity;
  //     List<String> selectedMove = [];
  //     for (Node child in root.children) {
  //       double ucb = ucbl(child);
  //       if (ucb > mx) {
  //         mx = ucb;
  //         selectedMove = [
  //           stateMoveMap[child]!.fromAlgebraic,
  //           stateMoveMap[child]!.toAlgebraic
  //         ];
  //       }
  //     }
  //     return selectedMove;
  //   } else {
  //     double mn = double.infinity;
  //     List<String> selectedMove = [];
  //     for (Node child in curNode.children) {
  //       double ucb = ucbl(child);
  //       if (ucb < mn) {
  //         mn = ucb;
  //         selectedMove = [
  //           stateMoveMap[child]!.fromAlgebraic,
  //           stateMoveMap[child]!.toAlgebraic
  //         ];
  //       }
  //     }
  //     return selectedMove;
  //   }
  // }

  double ucbl(Node curNode) {
    nodesVisited += 1;
    return curNode.V + 2 * math.sqrt(math.log(curNode.N) / curNode.ni);
  }

  Node expansion(Node curNode, bool white) {
    if (curNode.children.isEmpty) {
      return curNode;
    }
    Node selectedChild = curNode.children[0];
    if (white) {
      double maxUcb = double.negativeInfinity;

      for (Node child in curNode.children) {
        if (child.ni == 0) {
          selectedChild = child;
          break;
        }
        double ucb = ucbl(child);
        if (ucb > maxUcb) {
          maxUcb = ucb;
          selectedChild = child;
        }
      }
    } else {
      double minUcb = double.infinity;

      for (Node child in curNode.children) {
        if (child.ni == 0) {
          selectedChild = child;
          break;
        }
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
          return 1;
        } else if (temp.turn == Color.WHITE) {
          return -1;
        }
      }
      if (temp.in_stalemate) {
        return 0;
      }
      if (temp.in_threefold_repetition) {
        return 0;
      }
      if (temp.in_draw) {
        return 0;
      }
      if (temp.insufficient_material) {
        return 0;
      }
    }

    List movelist = temp.generate_moves();
    for (int i = 0; i < movelist.length; i++) {
      Chess newboard = temp.copy();
      Move move = movelist[i];
      newboard.move(move);
      curNode.children.add(Node(curNode, newboard.generate_fen()));
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

  Future<List<String>> getPrediction(
      Node curNode, bool over, bool white, int moveNumber) async {
    if (over) {
      return [];
    }
    stopwatch.start();
    int minGames;
    int duration;
    if (moveNumber < 2) {
      moveNumber = 2;
    }
    duration = 120 ~/ math.log(moveNumber);
    minGames = 50 ~/ math.log(moveNumber);
    Map<Node, Move> stateMoveMap = {};

    Chess temp = Chess.fromFEN(curNode.board);
    if (curNode.children.isEmpty) {
      List movelist = temp.generate_moves();
      for (int i = 0; i < movelist.length; i++) {
        Move move = movelist[i];
        Chess newboard = temp.copy();
        newboard.move(move);
        Node newNode = Node(curNode, newboard.generate_fen());
        curNode.children.add(newNode);
        stateMoveMap[newNode] = move;
      }
    }

    while (minGames > 0 ||
        stopwatch.elapsedMilliseconds <
            Duration(seconds: duration).inMilliseconds) {
      print("${stopwatch.elapsedMilliseconds ~/ 1000} games left: $minGames");
      if (white) {
        double maxUcb = double.negativeInfinity;
        Node selectedChild = curNode.children[0];
        for (Node child in curNode.children) {
          if (child.ni == 0) {
            selectedChild = child;
            break;
          }
          double ucb = ucbl(child);
          if (ucb > maxUcb) {
            maxUcb = ucb;
            selectedChild = child;
          }
        }
        Node exChild = expansion(selectedChild, false);
        double reward = rollout(exChild);
        curNode = backPropagation(exChild, reward);
        minGames -= 1;
      } else {
        double minUcb = double.infinity;
        Node selectedChild = curNode.children[0];
        for (Node child in curNode.children) {
          if (child.ni == 0) {
            selectedChild = child;
            break;
          }
          double ucb = ucbl(child);
          if (ucb < minUcb) {
            minUcb = ucb;
            selectedChild = child;
          }
        }
        Node exChild = expansion(selectedChild, true);
        double reward = rollout(exChild);
        curNode = backPropagation(exChild, reward);
        minGames -= 1;
      }
    }
    stopwatch.reset();
    if (white) {
      double mx = double.negativeInfinity;
      List<String> selectedMove = [];
      for (Node child in curNode.children) {
        double ucb = ucbl(child);
        if (ucb > mx) {
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
        if (ucb < mn) {
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
  List<Node> children = [];
  String action = '';
  double V; //winning score of current node
  int N; //number of times parent visited
  int ni; // number of times children visited

  Node(this.parent, this.board, {this.V = 0.0, this.N = 0, this.ni = 0});
}
