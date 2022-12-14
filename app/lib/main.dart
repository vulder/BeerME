import 'package:app/screens/register.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:app/screens/statistics.dart';
import 'package:app/model/user.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          Provider(create: (context) => UserModel()),
          ChangeNotifierProvider(create: (context) => UserModel()),
        ],
        child: MaterialApp(
          title: 'Hey you, beer me!',
          theme: ThemeData(
            primarySwatch: Colors.yellow,
          ),
          home: const MainPage(title: 'Hey you, beer me!'),
        ));
  }
}

class MainPage extends StatefulWidget {
  const MainPage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Row(children: [
            const Icon(
              Icons.sports_bar,
            ),
            Text(widget.title)
          ]),
          actions: <Widget>[
            if (context.read<UserModel>().hasId()) ...[
              Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: GestureDetector(
                    onTap: () => context.read<UserModel>().resetId(),
                    child: const Icon(
                      Icons.logout_outlined,
                      size: 26.0,
                    ),
                  )),
            ]
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24),
          child: Center(
            child: Provider.of<UserModel>(context).hasId()
                ? const StatisticsScreen()
                : RegisterScreen(),
          ),
        ));
  }
}
