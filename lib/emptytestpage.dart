
import 'package:flimmerkiste/profilepage.dart';
import 'package:flutter/material.dart';

class EmptyTestPage extends StatefulWidget {
  static String tag = 'empty-page';

  const EmptyTestPage({super.key});

  @override
  _EmptyTestPage createState() => _EmptyTestPage();
}

class _EmptyTestPage extends State<EmptyTestPage> {
  @override
  Widget build(BuildContext context) {
    final profileButton = Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(12),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
                side: const BorderSide(
                  color: Colors.lightBlueAccent,
                ))),
        onPressed: () {
          Navigator.of(context).pushNamed(ProfilePage.tag);
        },
        child: const Text('See Profile', style: TextStyle(color: Colors.white)),
      ),
    );

    return Scaffold(
        appBar: AppBar(
            title: const Text('Flimmerkiste')),
        body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: Form(
                child: ListView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(50),
                  children: <Widget>[
                    const SizedBox(height: 10.0),
                    profileButton,
                  ],
                ),
              ),
            )));
  }
}
