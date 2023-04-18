import 'package:flutter/material.dart';

class EmptyList extends StatelessWidget {
  const EmptyList({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
              child: Icon(Icons.inbox_outlined,
                  size: 80.0, color: Color(0xff0D3257))),
          Container(
            padding: const EdgeInsets.only(top: 4.0),
            child: const Text(
              "Don't have any tasks",
              style: TextStyle(fontSize: 20.0),
            ),
          )
        ],
      ),
    );
  }
}
