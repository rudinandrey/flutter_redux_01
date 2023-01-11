import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

enum Actions { Increment, SetName, AddName }

class ReducerAction {
  Actions action;
  dynamic payload;

  ReducerAction({required this.action, this.payload});
}

class AppStore {
  int counter = 0;
  String name = "";
  List<String> names = <String>["Andrey", "Irina", "Arseniy", "Caroline"];
}

AppStore counterReducer(AppStore state, dynamic action) {
  ReducerAction a = action as ReducerAction;
  if (a.action == Actions.Increment) {
    state.counter += 1;
    return state;
  }

  if (a.action == Actions.SetName) {
    state.name = a.payload as String;
  }

  if (a.action == Actions.AddName) {
    state.names.add(state.name);
    log('add name ${state.name}');
    log(state.names.toString());
    state.name = "";
    return state;
  }

  return state;
}

void main() {
  final store = Store<AppStore>(counterReducer, initialState: AppStore());
  runApp(MyApp(
    store: store,
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.store});
  final Store<AppStore> store;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return StoreProvider<AppStore>(
      store: store,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          useMaterial3: true,
          primarySwatch: Colors.blue,
        ),
        home: const MyHomePage(title: 'Flutter Demo Home Page'),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final myController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: StoreConnector<AppStore, List<String>>(
              converter: (store) => store.state.names,
              builder: (context, names) {
                log(names.toString());
                return ListView.builder(
                  itemCount: names.length,
                  itemBuilder: (context, index) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(names[index]),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          StoreConnector<AppStore, VoidCallback>(builder: (context, vm) {
            return TextField(
              controller: myController,
              onChanged: (value) {
                log(value);
                vm();
              },
            );
          }, converter: (store) {
            return () => store.dispatch(ReducerAction(
                action: Actions.SetName, payload: myController.text));
          })
        ],
      ),
      floatingActionButton: StoreConnector<AppStore, VoidCallback>(
        converter: (store) {
          return () => store.dispatch(ReducerAction(action: Actions.AddName));
        },
        builder: (context, callback) {
          log("Builder in floatingActionButton");
          return FloatingActionButton(
            onPressed: () {
              myController.text = "";
              callback();
            },
            tooltip: 'Increment',
            child: Text("Add"),
          );
        },
      ),
    );
  }

  Widget text(String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.headline4,
    );
  }
}
