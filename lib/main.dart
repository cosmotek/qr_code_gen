// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:io';
// ignore: avoid_web_libraries_in_flutter
import 'dart:js' as js;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

void save(Object bytes, String fileName) {
  js.context.callMethod("saveAs", <Object>[
    html.Blob(<Object>[bytes]),
    fileName
  ]);
}

Future<void> writeToFile(ByteData data, String path) async {
  final buffer = data.buffer;
  await File(path).writeAsBytes(
    buffer.asUint8List(data.offsetInBytes, data.lengthInBytes)
  );
}

void pickColor(BuildContext context, Color startColor, onColorPick) {
  Color color = startColor;

  showDialog(
    context: context,
    builder: (context, ) => AlertDialog(
      title: const Text('Select a color'),
      content: SingleChildScrollView(
        child: StatefulBuilder(
          builder: ((context, setState) => ColorPicker(
          pickerColor: color,
          onColorChanged: (newColor) => setState(() {
            color = newColor;
          }),
        )),
        ),
      ),
      actions: <Widget>[
        ElevatedButton(
          child: const Text('Done'),
          onPressed: () {
            onColorPick(color);
            Navigator.of(context).pop();
          },
        ),
      ],
    ),
  );
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter QR Code Generator',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.lightBlue,
      ),
      home: MyHomePage(title: 'Flutter QR Code Generator'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ScreenshotController controller = ScreenshotController();

  String data = "";
  Uint8List? embeddedImageData;
  double imageSize = 80;
  double qrSize = 200;

  Color eyeColor = Colors.black;
  QrEyeStyle qrEyeStyle = QrEyeStyle(
    eyeShape: QrEyeShape.square,
    color: Colors.black,
  );

  Color dataColor = Colors.blue;
  QrDataModuleStyle qrDataModuleStyle = QrDataModuleStyle(
    dataModuleShape: QrDataModuleShape.square,
    color: Colors.blue,
  );

  Color backgroundColor = Colors.transparent;
  bool qrGapless = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
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
                        padding: const EdgeInsets.only(left: 10),
                        child: OutlinedButton(
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 20,
                            ),
                            child: Text("Export Image"),
                          ),
                          onPressed: () async {
                            var img = await controller.captureAsUiImage() as ui.Image;
                            var imgData = await img.toByteData(format: ui.ImageByteFormat.png);

                            save(imgData!, "my_qr_code.png");
                          },
                        ),
                      )
                    : SizedBox(),
                ],
              ),
            ),

            data != "" ? Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Text(
                      "Eye Style",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  OutlinedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(eyeColor),
                      foregroundColor: MaterialStateProperty.all(eyeColor.computeLuminance() > 0.5 ? Colors.black : Colors.white),
                    ),
                    onPressed: () => pickColor(context, eyeColor, (color) => setState(() {
                      eyeColor = color;
                      qrEyeStyle = QrEyeStyle(
                        eyeShape: qrEyeStyle.eyeShape,
                        color: color,
                      );
                    })),
                    child: Text("Pick Eye Color"),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text("Square"),
                      Switch(
                        value: qrEyeStyle.eyeShape == QrEyeShape.circle,
                        onChanged: (value) {
                          setState(() {
                            qrEyeStyle = QrEyeStyle(
                              eyeShape: value ? QrEyeShape.circle : QrEyeShape.square,
                              color: eyeColor,
                            );
                          });
                        },
                      ),
                      Text("Circle"),
                    ],
                  ),

                  SizedBox(height: 20),

                  Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Text(
                      "Data Style",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  OutlinedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(dataColor),
                      foregroundColor: MaterialStateProperty.all(dataColor.computeLuminance() > 0.5 ? Colors.black : Colors.white),
                    ),
                    onPressed: () => pickColor(context, dataColor, (color) => setState(() {
                      dataColor = color;
                      qrDataModuleStyle = QrDataModuleStyle(
                        dataModuleShape: qrDataModuleStyle.dataModuleShape,
                        color: color,
                      );
                    })),
                    child: Text("Pick Data Color"),
                  ),

                  Row(
                    children: [
                      Text("Square"),
                      Switch(
                        value: qrDataModuleStyle.dataModuleShape == QrDataModuleShape.circle,
                        onChanged: (value) {
                          setState(() {
                            qrDataModuleStyle = QrDataModuleStyle(
                              dataModuleShape: value ? QrDataModuleShape.circle : QrDataModuleShape.square,
                              color: dataColor,
                            );
                          });
                        },
                      ),
                      Text("Circle"),
                    ],
                  ),

                  SizedBox(height: 20),

                  Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Text(
                      "QR Code Style",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  OutlinedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(backgroundColor),
                      foregroundColor: MaterialStateProperty.all(backgroundColor == Colors.transparent ? Colors.black : (backgroundColor.computeLuminance() > 0.5 ? Colors.black : Colors.white)),
                    ),
                    onPressed: () => pickColor(context, backgroundColor, (color) => setState(() {
                      backgroundColor = color;
                    })),
                    child: Text("Pick Background Color"),
                  ),

                  Row(
                    children: [
                      Text("Render Gapless"),
                      Switch(
                        value: qrGapless,
                        onChanged: (value) {
                          setState(() {
                            qrGapless = value;
                          });
                        },
                      ),
                    ],
                  ),

                  Row(
                    children: [
                      Text("QR Code Size"),
                      Slider(
                        min: 80.0,
                        max: 800.0,
                        label: qrSize.toString(),
                        value: qrSize,
                        onChanged: (value) {
                          setState(() {
                            qrSize = value;
                          });
                        },
                      ),
                    ],
                  ),

                  SizedBox(height: 20),

                  Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Text(
                      "Embedded Image Options",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  embeddedImageData != null 
                    ? Row(
                        children: [
                          Text("Embedded Image Size"),
                          Slider(
                            min: 30.0,
                            max: 150.0,
                            label: imageSize.toString(),
                            value: imageSize,
                            onChanged: (value) {
                              setState(() {
                                imageSize = value;
                              });
                            },
                          ),
                        ],
                      ) : SizedBox(),

                  data != ""
                    ? Row(
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
                              FilePickerResult? result = await FilePicker.platform.pickFiles(
                                dialogTitle: "Pick an image to embed",
                                type: FileType.custom,
                                allowedExtensions: ["png", "jpg", "jpeg"],
                              );
                              if (result != null) {
                                setState(() {
                                  embeddedImageData = result.files.single.bytes;
                                });
                              }
                            },
                          ),
                          SizedBox(width: 15),
                          OutlinedButton(
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 20,
                              ),
                              child: Text("Reset"),
                            ),
                            onPressed: () => setState(() {
                              embeddedImageData = null;
                            }),
                          ),
                        ],
                      )
                  : SizedBox(),
                ],
              ),
            ) : SizedBox(),

            data != "" ? Screenshot(
              controller: controller,
              child: QrImage(
                backgroundColor: backgroundColor,
                data: data,
                version: QrVersions.auto,
                size: qrSize,
                gapless: qrGapless,
                embeddedImage: embeddedImageData != null ? MemoryImage(embeddedImageData!) : null,
                embeddedImageStyle: QrEmbeddedImageStyle(
                  size: Size(imageSize, imageSize),
                ),
                dataModuleStyle: qrDataModuleStyle,
                eyeStyle: qrEyeStyle,
              ),
            ) : SizedBox(),

            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
