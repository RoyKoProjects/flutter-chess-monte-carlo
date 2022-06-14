import 'dart:math' as math;
import 'dart:core';
import 'package:flutter_chess_board/flutter_chess_board.dart';

class MCTS {
  double _ucbl(Node curNode) {
    return curNode.V + 100 * math.sqrt(math.log(curNode.N) / curNode.ni);
  }

  Node _expansion(Node curNode, bool white) {
    if (curNode.children.isEmpty) {
      return curNode;
    }
    Node selectedChild = curNode.children[0];
    if (white) {
      double maxUcb = double.negativeInfinity;

      for (Node child in curNode.children) {
        if (child.ni < 5) {
          selectedChild = child;
          break;
        }
        double ucb = _ucbl(child);
        if (ucb > maxUcb) {
          maxUcb = ucb;
          selectedChild = child;
        }
      }
    } else {
      double minUcb = double.infinity;

      for (Node child in curNode.children) {
        if (child.ni < 5) {
          selectedChild = child;
          break;
        }
        double ucb = _ucbl(child);
        if (ucb < minUcb) {
          minUcb = ucb;
          selectedChild = child;
        }
      }
    }

    return _expansion(selectedChild, !white);
  }

  double _rollout(Node curNode) {
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
    final random = math.Random();
    Move randomMove = movelist[random.nextInt(movelist.length)];
    temp.move(randomMove);
    Node childNode = Node(curNode, temp.generate_fen(), randomMove);
    curNode.children.add(childNode);

    return _rollout(childNode);
  }

  Node _backPropagation(Node curNode, double reward) {
    while (curNode.parent != null) {
      curNode.ni += 1;
      curNode.N += 1;
      curNode.V += reward;
      curNode = curNode.parent ?? curNode;
    }
    return curNode;
  }

  Future<Move?> getPrediction(Map input) async {
    Stopwatch stopwatch = Stopwatch()..start();
    Map<Node, Move> stateMoveMap = {};

    Chess temp = Chess.fromFEN(input["curNode"].board);
    if (input["curNode"].children.isEmpty) {
      List movelist = temp.generate_moves();
      for (int i = 0; i < movelist.length; i++) {
        Move move = movelist[i];
        Chess newboard = temp.copy();
        newboard.move(move);
        Node newNode = Node(input["curNode"], newboard.generate_fen(), move);
        input["curNode"].children.add(newNode);
        stateMoveMap[newNode] = move;
      }
    }

    while (
        stopwatch.elapsedMilliseconds < const Duration(seconds: 12).inMilliseconds) {
      if (input["white"]) {
        double maxUcb = double.negativeInfinity;
        Node selectedChild = input["curNode"].children[0];
        for (Node child in input["curNode"].children) {
          if (child.ni < 5) {
            selectedChild = child;
            break;
          }
          double ucb = _ucbl(child);
          if (ucb > maxUcb) {
            maxUcb = ucb;
            selectedChild = child;
          }
        }
        Node exChild = _expansion(selectedChild, false);
        double reward = _rollout(exChild);
        input["curNode"] = _backPropagation(exChild, reward);
      } else {
        double minUcb = double.infinity;
        Node selectedChild = input["curNode"].children[0];
        for (Node child in input["curNode"].children) {
          if (child.ni < 5) {
            selectedChild = child;
            break;
          }
          double ucb = _ucbl(child);
          if (ucb < minUcb) {
            minUcb = ucb;
            selectedChild = child;
          }
        }
        Node exChild = _expansion(selectedChild, true);
        double reward = _rollout(exChild);
        input["curNode"] = _backPropagation(exChild, reward);
      }
    }
    if (input["white"]) {
      double mx = double.negativeInfinity;
      Move? selectedMove;
      for (Node child in input["curNode"].children) {
        double ucb = _ucbl(child);
        if (ucb > mx) {
          mx = ucb;
          selectedMove = child.lastAction;
        }
      }
      return selectedMove;
    } else {
      double mn = double.infinity;
      Move? selectedMove;
      for (Node child in input["curNode"].children) {
        double ucb = _ucbl(child);
        if (ucb < mn) {
          mn = ucb;
          selectedMove = child.lastAction;
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
  Move? lastAction;
  double V; //winning score of current node
  int N; //number of times parent visited
  int ni; // number of times children visited

  Node(this.parent, this.board, this.lastAction,
      {this.V = 0.0, this.N = 0, this.ni = 0});

  Node copy() {
    return Node(parent, board, lastAction, V: V, N: N, ni: ni);
  }
}
