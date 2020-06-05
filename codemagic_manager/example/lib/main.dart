import 'package:codemagic_manager/codemagic_manager.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Codemagic example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  CodemagicClient client;
  final List<Build> builds = [];

  @override
  void initState() {
    super.initState();
    client = CodemagicClient(
      apiUrl: 'https://api.codemagic.io',
      authKey: 'SECRET',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            RaisedButton(
              child: Text('Fetch builds'),
              onPressed: onFetch,
            ),
            if (builds.length > 0)
              RaisedButton(
                child: Text('Start latest build again'),
                onPressed: onStart,
              ),
            if (builds.length > 0)
              RaisedButton(
                child: Text('Cancel latest build'),
                onPressed: onCancel,
              ),
            Flexible(
              child: ListView.builder(
                itemCount: builds.length,
                itemBuilder: (context, index) => ListTile(
                  title: Text(builds[index].id ?? 'no id'),
                  subtitle:
                      Text(builds[index].status.toString() ?? 'no status'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void onStart() async {
    try {
      final appId = builds.first.appId;
      final wId = builds.first.workflowId;
      final branch = builds.first.branch;
      final result = await client.startBuild(appId, wId, branch);
      if (result.wasSuccessful) {
        print('Success!');
        onFetch();
      } else {
        print('Something went wrong: ${result.error}');
      }
    } catch (e) {
      print(e);
    }
  }

  void onCancel() async {
    try {
      final buildId = builds.first.id;
      final result = await client.cancelBuild(buildId);
      if (result.wasSuccessful) {
        print('Success!');
        onFetch();
      } else {
        print('Something went wrong: ${result.error}');
      }
    } catch (e) {
      print(e);
    }
  }

  void onFetch() async {
    try {
      final result = await client.getBuilds();
      if (result.wasSuccessful) {
        print('Success! Fetched ${result.data.applications.length}'
            ' apps and ${result.data.builds.length} builds');
        builds.clear();
        builds.addAll(result.data.builds);
        setState(() {});
      } else {
        print('Something went wrong: ${result.error}');
      }
    } catch (e) {
      print(e);
    }
  }
}
