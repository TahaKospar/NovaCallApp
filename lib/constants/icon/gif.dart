import 'package:flutter/cupertino.dart';

class gif extends StatelessWidget {
  const gif({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Container(child: Image.asset("assets/loading.gif")),
        Container(child: Image.asset("assets/loading1.gif")),
      ],
    );
  }
}
