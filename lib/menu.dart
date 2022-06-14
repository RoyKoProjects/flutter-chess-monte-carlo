import 'package:flutter/material.dart';
import 'game.dart';

class Menu extends StatelessWidget {
  const Menu({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const GamePage(whitePlayer: true),
                    ),
                  );
                },
                hoverColor: Colors.blue[300],
                child: Container(
                    height: 100,
                    color: Colors.black12,
                    alignment: Alignment.center,
                    margin: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * .1,
                        vertical: MediaQuery.of(context).size.height * .03),
                    child: (const Text("Play as White",
                        textAlign: TextAlign.center,
                        style:
                            TextStyle(fontSize: 30, fontFamily: "Roboto"))))),
            InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const GamePage(whitePlayer: false),
                    ),
                  );
                },
                hoverColor: Colors.red,
                child: Container(
                    height: 100,
                    color: Colors.black,
                    alignment: Alignment.center,
                     margin: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width * .1,
                        vertical: MediaQuery.of(context).size.height * .03),
                    child: (const Text(
                      "Play as Black",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontFamily: "Roboto"),
                    ))))
          ],
        ),
      ),
    );
  }
}
