import 'package:fakecez_key_gen/networks/fetch_reop.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:progress_indicators/progress_indicators.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  ValueNotifier<String> _data = ValueNotifier<String>("You Dont have any key!");
  static const snackBar = SnackBar(
    content: Text('Yay! Key Copied'),
  );
  @override
  Widget build(BuildContext context) {
    int count = 0;
    return Scaffold(
      appBar: AppBar(title: Text("Fakecez Modz Key Generator!!")),
      body: Center(
        child: ValueListenableBuilder<String>(
          builder: (BuildContext context, String value, Widget? child) {
            // This builder will only get called when the _counter
            // is updated.
            return InkWell(
              onTap: value != "You Dont have any key!" &&
                      value != "Loading..." &&
                      value != "Error!Try Again?"
                  ? () async {
                      await Clipboard.setData(ClipboardData(text: value));
                      HapticFeedback.vibrate();
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    }
                  : null,
              child: value == "Loading..."
                  ? JumpingText(
                      value,
                      style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.w600),
                    )
                  : Text(value,
                      style: const TextStyle(
                          fontSize: 25, fontWeight: FontWeight.bold)),
            );
          },
          valueListenable: _data,
          // The child parameter is most helpful if the child is
          // expensive to build and does not depend on the value from
          // the notifier.
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          if (_data.value != "Loading...") {
            _data.value = "Loading...";
            _data.value = await Repo.userSignUp();
          }
        },
        backgroundColor: Colors.green,
        label: const Text('Get Key'),
        icon: const Icon(Icons.key),
      ),
    );
  }
}
