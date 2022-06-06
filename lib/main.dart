import 'dart:io';

import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:file_selector/file_selector.dart';
import 'package:screenshot/screenshot.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter QR Code Generator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.lightBlue,
      ),
      home: const MyHomePage(title: 'Flutter QR Code Generator'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ScreenshotController controller = ScreenshotController();

  String data = "";
  String? embeddedImageUrl;
  double imageSize = 80;

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(20),
              child: TextField(
                maxLines: 1,
                decoration: const InputDecoration(
                  hintText: "URL or data..."
                ),
                onChanged: (v) => setState(() {
                  data = v;
                }),
              ),
            ),

            data != ""
              ? Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      OutlinedButton(
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 20,
                          ),
                          child: Text("Embed Image"),
                        ),
                        onPressed: () async {
                          final typeGroup = XTypeGroup(label: 'image files', extensions: ['png', 'jpg', 'jpeg']);
                          final result = await openFile(
                            acceptedTypeGroups: [typeGroup],
                            // confirmButtonText
                          );

                          setState(() {
                            embeddedImageUrl = result!.path;
                          });
                        },
                      ),
                      OutlinedButton(
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 20,
                          ),
                          child: Text("Reset"),
                        ),
                        onPressed: () => setState(() {
                          embeddedImageUrl = null;
                        }),
                      ),
                    ],
                  ),
                )
              : SizedBox(),

            Screenshot(
              controller: controller,
              child: QrImage(
                foregroundColor: data != "" ? Colors.black : Colors.transparent,
                data: data,
                version: QrVersions.auto,
                size: 320,
                gapless: false,
                embeddedImage: embeddedImageUrl != null ? FileImage(File(embeddedImageUrl!)) : null,
                embeddedImageStyle: QrEmbeddedImageStyle(
                  size: Size(imageSize, imageSize),
                ),
              ),
            ),

            embeddedImageUrl != null 
              ? Padding(
                  padding: const EdgeInsets.all(20),
                  child: Slider(
                    min: 30.0,
                    max: 150.0,
                    label: imageSize.toString(),
                    value: imageSize,
                    onChanged: (value) {
                      setState(() {
                        imageSize = value;
                      });
                    },
                  )
                )
              : SizedBox(),

            data != ""
              ? Padding(
                  padding: const EdgeInsets.only(top: 15),
                  child: OutlinedButton(
                    child: const Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 20,
                      ),
                      child: Text("Export Image"),
                    ),
                    onPressed: () async {
                      final typeGroup = XTypeGroup(label: 'png files', extensions: ['png']);
                      final result = await getSavePath(
                        acceptedTypeGroups: [typeGroup],
                        confirmButtonText: "Set save location"
                      );

                      controller.captureAndSave(
                        dirname(result!),
                        fileName: basename(result),
                      );
                    },
                  ),
                )
              : SizedBox(),
          ],
        ),
      ),
    );
  }
}
