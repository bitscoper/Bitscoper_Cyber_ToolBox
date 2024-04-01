/* By Abdullah As-Sadeed */

import 'dart:async';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_traceroute/flutter_traceroute.dart';
import 'package:flutter_traceroute/flutter_traceroute_platform_interface.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as parser;
import 'package:http/http.dart' as http;
import 'package:tcp_scanner/tcp_scanner.dart';
import 'package:whois/whois.dart';

void main() {
  runApp(
    const MainApp(),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
      // theme: ThemeData.dark(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bitscoper Cyber ToolBox'),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            const DrawerHeader(
              child: Text('Bitscoper Cyber WorkBench'),
            ),
            ListTile(
              title: const Text('TCP Port Scanner'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return const TCPPortScannerPage();
                  }),
                );
              },
            ),
            ListTile(
              title: const Text('Route Tracer'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return const RouteTracerPage();
                  }),
                );
              },
            ),
            ListTile(
              title: const Text('File Hash Calculator'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return const FileHashCalculatorPage();
                  }),
                );
              },
            ),
            ListTile(
              title: const Text('Series URI Crawler'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return const SeriesURICrawlerPage();
                  }),
                );
              },
            ),
            ListTile(
              title: const Text('WHOIS Retriever'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) {
                    return const WHOISRetrieverPage();
                  }),
                );
              },
            ),
          ],
        ),
      ),
      body: const Center(
        child: Text('Select a tool from the drawer.'),
      ),
    );
  }
}

class TCPPortScannerPage extends StatelessWidget {
  const TCPPortScannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TCP Port Scanner'),
        centerTitle: true,
      ),
      body: const TCPPortScannerBody(),
    );
  }
}

class TCPPortScannerBody extends StatefulWidget {
  const TCPPortScannerBody({super.key});

  @override
  TCPPortScannerBodyState createState() => TCPPortScannerBodyState();
}

class TCPPortScannerBodyState extends State<TCPPortScannerBody> {
  final TextEditingController hostController = TextEditingController();
  final Stopwatch stopwatch = Stopwatch();

  final List<int> portList = List.generate(65536, (i) => i);
  bool isScanning = false;
  double scanProgress = 0.0;
  String scanResult = '';

  @override
  void dispose() {
    hostController.dispose();
    super.dispose();
  }

  Future<void> scanTCPPorts() async {
    final String host = hostController.text.trim();

    if (host.isEmpty) {
      setState(() {
        scanResult = 'Enter a valid host or IP address!';
      });

      return;
    }

    isScanning = true;
    stopwatch.start();

    try {
      await TcpScannerTask(host, portList, shuffle: true, parallelism: 64)
          .start()
          .asStream()
          .transform(
            StreamTransformer.fromHandlers(handleData: (report, sink) {
              scanProgress = 1.0;

              scanResult = 'Scanned ports:\t${report.ports.length}\n'
                  'Open ports:\t${report.openPorts}\n'
                  'Elapsed:\t${stopwatch.elapsed}\n';

              setState(() {});

              sink.add(report);
            }, handleError: (error, stackTrace, sink) {
              setState(() {
                scanResult = 'Error: $error';
              });

              sink.addError(error, stackTrace);
            }, handleDone: (sink) {
              sink.close();

              isScanning = false;
            }),
          )
          .toList();
    } catch (error) {
      setState(() {
        scanResult = 'Error: $error';
      });

      isScanning = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: hostController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'bitscoper.live',
              labelText: 'Enter a Host or IP Address',
            ),
          ),
          const SizedBox(height: 16),
          isScanning
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      stopwatch.reset();
                      scanProgress = 0.0;
                      setState(() {});

                      await scanTCPPorts();
                    },
                    child: const Text('Scan'),
                  ),
                ),
          const SizedBox(height: 16),
          if (scanProgress == 1.0) ...[Text(scanResult)],
        ],
      ),
    );
  }
}

class RouteTracerPage extends StatelessWidget {
  const RouteTracerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Route Tracer'),
        centerTitle: true,
      ),
      body: const RouteTracerBody(),
    );
  }
}

class RouteTracerBody extends StatefulWidget {
  const RouteTracerBody({super.key});

  @override
  RouteTracerBodyState createState() => RouteTracerBodyState();
}

class RouteTracerBodyState extends State<RouteTracerBody> {
  late final FlutterTraceroute routeTracer;
  late final TextEditingController hostController;
  StreamSubscription? traceSubscription;

  bool isTracing = false;
  List<TracerouteStep> traceResults = [];

  @override
  void initState() {
    super.initState();

    routeTracer = FlutterTraceroute();
    hostController = TextEditingController();
  }

  void onTrace() {
    setState(() {
      traceResults = <TracerouteStep>[];
      isTracing = true;
    });

    final host = hostController.text;
    final arguments = TracerouteArgs(host: host);

    traceSubscription = routeTracer.trace(arguments).listen((event) {
      setState(() {
        traceResults = List<TracerouteStep>.from(traceResults)..add(event);
      });
    });
  }

  void onStop() {
    routeTracer.stopTrace();
    traceSubscription?.cancel();

    setState(() {
      isTracing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'bitscoper.live',
              labelText: 'Enter a Host or IP Address',
            ),
            controller: hostController,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: isTracing ? null : onTrace,
                child: const Text('Trace'),
              ),
              ElevatedButton(
                onPressed: isTracing ? onStop : null,
                child: const Text('Stop'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final result in traceResults)
                Text(
                  result.toString(),
                  style: TextStyle(
                    fontWeight: result is TracerouteStepFinished
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              if (isTracing)
                const Center(
                  child: CircularProgressIndicator(),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class FileHashCalculatorPage extends StatelessWidget {
  const FileHashCalculatorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('File Hash Calculator'),
        centerTitle: true,
      ),
      body: const FileHashCalculatorBody(),
    );
  }
}

class FileHashCalculatorBody extends StatefulWidget {
  const FileHashCalculatorBody({super.key});

  @override
  FileHashCalculatorBodyState createState() => FileHashCalculatorBodyState();
}

class FileHashCalculatorBodyState extends State<FileHashCalculatorBody> {
  List<Map<String, dynamic>> hashValues = [];

  void calculateHashes(List<File> files) {
    setState(() {
      hashValues = files.map((file) {
        var bytes = file.readAsBytesSync();
        var md5Hash = md5.convert(bytes);
        var sha1Hash = sha1.convert(bytes);
        var sha224Hash = sha224.convert(bytes);
        var sha256Hash = sha256.convert(bytes);
        var sha384Hash = sha384.convert(bytes);
        var sha512Hash = sha512.convert(bytes);

        return {
          'File Name': file.path.split('/').last,
          'MD5': md5Hash.toString(),
          'SHA1': sha1Hash.toString(),
          'SHA224': sha224Hash.toString(),
          'SHA256': sha256Hash.toString(),
          'SHA384': sha384Hash.toString(),
          'SHA512': sha512Hash.toString(),
        };
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: ElevatedButton(
              child: const Text('Select Files'),
              onPressed: () async {
                List<Uint8List> files = [];

                var result =
                    await FilePicker.platform.pickFiles(allowMultiple: true);

                if (result != null) {
                  List<File> selectedFiles =
                      result.paths.where((path) => path != null).map((path) {
                    return File(path!);
                  }).toList();

                  for (var file in selectedFiles) {
                    files.add(
                      file.readAsBytesSync(),
                    );
                  }

                  calculateHashes(selectedFiles);
                }
              },
            ),
          ),
          const SizedBox(height: 16),
          ...hashValues.map((hash) {
            return Card(
              child: Column(
                children: hash.entries.map((entry) {
                  return ListTile(
                    title: Text(entry.key),
                    subtitle: Text(entry.value),
                  );
                }).toList(),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class SeriesURICrawlerPage extends StatelessWidget {
  const SeriesURICrawlerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Series URI Crawler'),
        centerTitle: true,
      ),
      body: const SeriesURICrawlerBody(),
    );
  }
}

class SeriesURICrawlerBody extends StatefulWidget {
  const SeriesURICrawlerBody({super.key});

  @override
  SeriesURICrawlerBodyState createState() => SeriesURICrawlerBodyState();
}

class SeriesURICrawlerBodyState extends State<SeriesURICrawlerBody> {
  final _formKey = GlobalKey<FormState>();

  String uriPrefix = '', uriSuffix = '';
  int lowerLimit = 1, upperLimit = 100;
  bool isCrawling = false;
  Map<String, String> titles = {};

  Future<void> crawl() async {
    setState(() {
      titles.clear();
      isCrawling = true;
    });

    for (var i = lowerLimit; i <= upperLimit; i++) {
      if (!isCrawling) return;

      var uri = '$uriPrefix$i$uriSuffix';
      var response = await http.get(
        Uri.parse(uri),
      );
      dom.Document document = parser.parse(response.body);

      dom.Element? titleElement = document.querySelector('title');
      String title = titleElement != null ? titleElement.text : 'NO TITLE';

      setState(() {
        titles[uri] = title;
      });
    }

    setState(() {
      isCrawling = false;
    });
  }

  void stop() {
    setState(() {
      isCrawling = false;
    });
  }

  void copyToClipboard(String uri) {
    Clipboard.setData(
      ClipboardData(text: uri),
    );

    Fluttertoast.showToast(
      msg: "Link copied to clipboard",
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.grey,
      textColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          decoration: const InputDecoration(
                              hintText: 'https://dlhd.sx/stream/stream-',
                              labelText: 'URI Prefix'),
                          onChanged: (value) {
                            uriPrefix = value;
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 1,
                        child: TextFormField(
                          decoration: const InputDecoration(
                              hintText: '.php', labelText: 'URI Suffix'),
                          onChanged: (value) {
                            uriSuffix = value;
                          },
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(
                              hintText: '1', labelText: 'Lower Limit'),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            lowerLimit = int.parse(value);
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(
                              hintText: '100', labelText: 'Upper Limit'),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            upperLimit = int.parse(value);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        onPressed: isCrawling
                            ? null
                            : () {
                                if (_formKey.currentState!.validate()) {
                                  crawl();
                                }
                              },
                        child: const Text('Crawl'),
                      ),
                      ElevatedButton(
                        onPressed: isCrawling ? stop : null,
                        child: const Text('Stop'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Column(
            children: [
              for (var entry in titles.entries)
                ListTile(
                  title: Text(entry.value),
                  onTap: () {
                    copyToClipboard(entry.key);
                  },
                ),
              if (isCrawling) const CircularProgressIndicator(),
            ],
          )
        ],
      ),
    );
  }
}

class WHOISRetrieverPage extends StatelessWidget {
  const WHOISRetrieverPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WHOIS Retriever'),
        centerTitle: true,
      ),
      body: const WHOISRetrieverBody(),
    );
  }
}

class WHOISRetrieverBody extends StatefulWidget {
  const WHOISRetrieverBody({super.key});

  @override
  SWHOISRetrieverBodyState createState() => SWHOISRetrieverBodyState();
}

class SWHOISRetrieverBodyState extends State<WHOISRetrieverBody> {
  String domainName = '';
  bool isLoading = false;
  Map<String, String> whoisInformation = {};

  void retrieveWHOIS() async {
    setState(() {
      whoisInformation.clear();
      isLoading = true;
    });

    var options = const LookupOptions(
      timeout: Duration(milliseconds: 10000),
      port: 43,
    );

    try {
      final whoisResponse = await Whois.lookup(domainName, options);
      final parsedResponse = Whois.formatLookup(whoisResponse);

      setState(() {
        whoisInformation = Map<String, String>.from(parsedResponse);
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        whoisInformation = {'Error': error.toString()};
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            onChanged: (value) {
              domainName = value;
            },
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'bitscoper.live',
              labelText: 'Enter a Domain Name',
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: ElevatedButton(
              onPressed: isLoading ? null : retrieveWHOIS,
              child: const Text('Lookup'),
            ),
          ),
          const SizedBox(height: 16),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(),
            )
          else
            Card(
              child: Column(
                children: whoisInformation.entries.map((entry) {
                  return ListTile(
                    title: Text(entry.key),
                    subtitle: Text(entry.value),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}
