/* By Abdullah As-Sadeed */

import 'dart:async';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:dnsolve/dnsolve.dart';
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

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  MainAppState createState() => MainAppState();
}

class MainAppState extends State<MainApp> {
  bool isDarkTheme = false;

  void toggleTheme() {
    setState(
      () {
        isDarkTheme = !isDarkTheme;
      },
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: isDarkTheme ? ThemeData.dark() : ThemeData.light(),
      home: HomePage(
        toggleTheme: toggleTheme,
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  final Function toggleTheme;

  const HomePage({super.key, required this.toggleTheme});

  @override
  Widget build(
    BuildContext context,
  ) {
    Widget buildToolCard(
      String title,
      IconData icon,
      Widget page,
    ) {
      return Card(
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) {
                  return page;
                },
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(icon),
                Text(
                  title,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bitscoper Cyber ToolBox'),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            const DrawerHeader(
              child: Text('Bitscoper Cyber WorkBench'),
            ),
            ListTile(
              title: const Text('Toggle Dark Theme'),
              leading: const Icon(Icons.brightness_6),
              onTap: () {
                toggleTheme();
              },
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Wrap(
            alignment: WrapAlignment.center,
            spacing: 16,
            runSpacing: 16,
            children: <Widget>[
              buildToolCard(
                'TCP Port Scanner',
                Icons.network_check,
                const TCPPortScannerPage(),
              ),
              buildToolCard(
                'Route Tracer',
                Icons.track_changes,
                const RouteTracerPage(),
              ),
              buildToolCard(
                'File Hash Calculator',
                Icons.backup_table,
                const FileHashCalculatorPage(),
              ),
              buildToolCard(
                'Series URI Crawler',
                Icons.web,
                const SeriesURICrawlerPage(),
              ),
              buildToolCard(
                'DNS Record Retriever',
                Icons.dns,
                const DNSRecordRetrieverPage(),
              ),
              buildToolCard(
                'WHOIS Retriever',
                Icons.search,
                const WHOISRetrieverPage(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void copyToClipBoard(
  String dataType,
  String string,
) {
  Clipboard.setData(
    ClipboardData(
      text: string,
    ),
  );

  Fluttertoast.showToast(
    msg: "$dataType copied to clipboard",
    gravity: ToastGravity.BOTTOM,
    backgroundColor: Colors.grey,
    textColor: Colors.white,
  );
}

class TCPPortScannerPage extends StatelessWidget {
  const TCPPortScannerPage({super.key});

  @override
  Widget build(
    BuildContext context,
  ) {
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
  late String host;
  final Stopwatch stopwatch = Stopwatch();

  final List<int> portList = List.generate(65536, (i) => i);
  bool isScanning = false;
  double scanProgress = 0.0;
  late List<int> openPorts;
  String scanInformation = '';

  Future<void> scanTCPPorts() async {
    if (host.isEmpty) {
      setState(
        () {
          scanInformation = 'Enter a valid host or IP address!';
        },
      );

      return;
    }

    isScanning = true;
    stopwatch.start();

    try {
      await TcpScannerTask(
        host,
        portList,
        shuffle: true,
        parallelism: 64,
      )
          .start()
          .asStream()
          .transform(
            StreamTransformer.fromHandlers(
              handleData: (
                report,
                sink,
              ) {
                scanProgress = 1.0;

                openPorts = report.openPorts;
                openPorts = openPorts.cast<int>();
                openPorts.sort();

                scanInformation = 'Scanned ports:\t${report.ports.length}\n'
                    'Elapsed:\t${stopwatch.elapsed}';

                setState(
                  () {},
                );

                sink.add(report);
              },
              handleError: (
                error,
                stackTrace,
                sink,
              ) {
                setState(
                  () {
                    scanInformation = 'Error: $error';
                  },
                );

                sink.addError(
                  error,
                  stackTrace,
                );
              },
              handleDone: (sink) {
                sink.close();

                isScanning = false;
              },
            ),
          )
          .toList();
    } catch (error) {
      setState(
        () {
          scanInformation = 'Error: $error';
        },
      );

      isScanning = false;
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextField(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Enter a Host or IP Address',
              hintText: 'bitscoper.live',
            ),
            onChanged: (value) {
              host = value.trim();
            },
          ),
          const SizedBox(
            height: 16,
          ),
          isScanning
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      stopwatch.reset();
                      scanProgress = 0.0;
                      setState(
                        () {},
                      );

                      await scanTCPPorts();
                    },
                    child: const Text('Scan'),
                  ),
                ),
          const SizedBox(
            height: 16,
          ),
          if (scanProgress == 1.0) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                for (var port in openPorts)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: Colors.grey,
                      ),
                    ),
                    child: Text(
                      port.toString(),
                    ),
                  ),
              ],
            ),
          ],
          const SizedBox(
            height: 16,
          ),
          Text(scanInformation),
        ],
      ),
    );
  }
}

class RouteTracerPage extends StatelessWidget {
  const RouteTracerPage({super.key});

  @override
  Widget build(
    BuildContext context,
  ) {
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
  late String host;
  late final FlutterTraceroute routeTracer;
  StreamSubscription? traceSubscription;

  bool isTracing = false;
  List<TracerouteStep> traceResults = [];

  @override
  void initState() {
    super.initState();

    routeTracer = FlutterTraceroute();
  }

  void onTrace() {
    setState(
      () {
        traceResults = <TracerouteStep>[];
        isTracing = true;
      },
    );

    final arguments = TracerouteArgs(
      host: host,
    );

    traceSubscription = routeTracer.trace(arguments).listen(
      (event) {
        setState(
          () {
            traceResults = List<TracerouteStep>.from(traceResults)..add(event);
          },
        );
      },
    );
  }

  void onStop() {
    routeTracer.stopTrace();
    traceSubscription?.cancel();

    setState(
      () {
        isTracing = false;
      },
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextField(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Enter a Host or IP Address',
              hintText: 'bitscoper.live',
            ),
            onChanged: (value) {
              host = value.trim();
            },
          ),
          const SizedBox(
            height: 16,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
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
          const SizedBox(
            height: 16,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              for (final result in traceResults)
                Text(
                  result.toString(),
                  style: TextStyle(
                    fontWeight: result is TracerouteStepFinished
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              if (isTracing) ...[
                const SizedBox(
                  height: 16,
                ),
                const Center(
                  child: CircularProgressIndicator(),
                ),
              ],
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
  Widget build(
    BuildContext context,
  ) {
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

  void calculateHashes(
    List<File> files,
  ) {
    setState(
      () {
        hashValues = files.map(
          (file) {
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
          },
        ).toList();
      },
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Center(
            child: ElevatedButton(
              child: const Text('Select Files'),
              onPressed: () async {
                List<Uint8List> files = [];

                var result = await FilePicker.platform.pickFiles(
                  allowMultiple: true,
                );

                if (result != null) {
                  List<File> selectedFiles = result.paths
                      .where(
                    (path) => path != null,
                  )
                      .map(
                    (path) {
                      return File(path!);
                    },
                  ).toList();

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
          const SizedBox(
            height: 16,
          ),
          ...hashValues.map(
            (hash) {
              return Column(
                children: <Widget>[
                  Card(
                    child: Column(
                      children: hash.entries.map(
                        (entry) {
                          return Column(
                            children: <Widget>[
                              Card(
                                elevation: 0.0,
                                color: Colors.transparent,
                                child: ListTile(
                                  title: Text(entry.key),
                                  subtitle: Text(entry.value),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.copy),
                                    onPressed: () {
                                      copyToClipBoard(
                                        "Hash",
                                        entry.value,
                                      );
                                    },
                                  ),
                                ),
                              ),
                              if (hash.entries.last != entry)
                                const SizedBox(
                                  height: 8,
                                ),
                            ],
                          );
                        },
                      ).toList(),
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class SeriesURICrawlerPage extends StatelessWidget {
  const SeriesURICrawlerPage({super.key});

  @override
  Widget build(
    BuildContext context,
  ) {
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
  final formKey = GlobalKey<FormState>();

  late String uriPrefix, uriSuffix;
  late int lowerLimit, upperLimit;

  bool isCrawling = false;
  Map<String, String> titles = {};

  Future<void> crawl() async {
    setState(
      () {
        titles.clear();
        isCrawling = true;
      },
    );

    for (var i = lowerLimit; i <= upperLimit; i++) {
      if (!isCrawling) return;

      var uri = '$uriPrefix$i$uriSuffix';
      var response = await http.get(
        Uri.parse(uri),
      );
      dom.Document document = parser.parse(response.body);

      dom.Element? titleElement = document.querySelector('title');
      String title = titleElement != null ? titleElement.text : 'NO TITLE';

      setState(
        () {
          titles[uri] = title;
        },
      );
    }

    setState(
      () {
        isCrawling = false;
      },
    );
  }

  void stop() {
    setState(
      () {
        isCrawling = false;
      },
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Form(
            key: formKey,
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'URI Prefix',
                          hintText: 'https://dlhd.sx/stream/stream-',
                        ),
                        onChanged: (value) {
                          uriPrefix = value.trim();
                        },
                      ),
                    ),
                    const SizedBox(
                      width: 16,
                    ),
                    Expanded(
                      flex: 1,
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'URI Suffix',
                          hintText: '.php',
                        ),
                        onChanged: (value) {
                          uriSuffix = value.trim();
                        },
                      ),
                    ),
                  ],
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Lower Limit',
                          hintText: '1',
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          lowerLimit = int.parse(value);
                        },
                      ),
                    ),
                    const SizedBox(
                      width: 16,
                    ),
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Upper Limit',
                          hintText: '100',
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          upperLimit = int.parse(value);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 16,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: isCrawling
                          ? null
                          : () {
                              if (formKey.currentState!.validate()) {
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
          const SizedBox(
            height: 16,
          ),
          Column(
            children: <Widget>[
              for (var entry in titles.entries)
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: 8,
                  ),
                  child: Card(
                    child: ListTile(
                      leading: const Icon(Icons.link),
                      title: Text(
                        entry.value,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.copy),
                        onPressed: () {
                          copyToClipBoard(
                            "URI",
                            entry.key,
                          );
                        },
                      ),
                    ),
                  ),
                ),
              if (isCrawling) ...[
                const SizedBox(
                  height: 8,
                ),
                const Center(
                  child: CircularProgressIndicator(),
                ),
              ],
            ],
          )
        ],
      ),
    );
  }
}

class DNSRecordRetrieverPage extends StatelessWidget {
  const DNSRecordRetrieverPage({super.key});

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DNS Record Retriever'),
        centerTitle: true,
      ),
      body: const DNSRecordRetrieverBody(),
    );
  }
}

class DNSRecordRetrieverBody extends StatefulWidget {
  const DNSRecordRetrieverBody({super.key});

  @override
  DNSRecordRetrieverBodyState createState() => DNSRecordRetrieverBodyState();
}

class DNSRecordRetrieverBodyState extends State<DNSRecordRetrieverBody> {
  late String domainName;
  RecordType recordType = RecordType.A;
  DNSProvider recordProvider = DNSProvider.cloudflare;

  bool isLoading = false;
  List<String> results = [];

  Future<void> retrieveDNSRecord() async {
    setState(
      () {
        isLoading = true;
        results = [];
      },
    );

    final response = await DNSolve().lookup(
      domainName,
      dnsSec: true,
      type: recordType,
      provider: recordProvider,
    );

    if (response.answer!.records != null) {
      for (final record in response.answer!.records!) {
        results.add(record.toBind);
      }
    }

    setState(
      () {
        isLoading = false;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextField(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Enter a Domain Name',
              hintText: 'bitscoper.live',
            ),
            onChanged: (value) {
              domainName = value.trim();
            },
          ),
          const SizedBox(
            height: 16,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: Theme.of(context).colorScheme.onInverseSurface,
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<RecordType>(
                      value: recordType,
                      onChanged: (RecordType? newValue) {
                        setState(() {
                          recordType = newValue!;
                        });
                      },
                      items:
                          RecordType.values.map<DropdownMenuItem<RecordType>>(
                        (RecordType value) {
                          return DropdownMenuItem<RecordType>(
                            value: value,
                            child: Text(value.toString().split('.').last),
                          );
                        },
                      ).toList(),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                width: 16,
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: Theme.of(context).colorScheme.onInverseSurface,
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<DNSProvider>(
                      value: recordProvider,
                      onChanged: (DNSProvider? newValue) {
                        setState(() {
                          recordProvider = newValue!;
                        });
                      },
                      items:
                          DNSProvider.values.map<DropdownMenuItem<DNSProvider>>(
                        (DNSProvider value) {
                          return DropdownMenuItem<DNSProvider>(
                            value: value,
                            child: Text(value.toString().split('.').last),
                          );
                        },
                      ).toList(),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 16,
          ),
          Center(
            child: ElevatedButton(
              onPressed: isLoading ? null : retrieveDNSRecord,
              child: const Text('Lookup'),
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : Column(
                  children: results
                      .map((result) => Padding(
                            padding: const EdgeInsets.only(
                              bottom: 8,
                            ),
                            child: Card(
                              child: ListTile(
                                title: Text(
                                  result,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.copy),
                                  onPressed: () {
                                    copyToClipBoard(
                                      "DNS record",
                                      result,
                                    );
                                  },
                                ),
                              ),
                            ),
                          ))
                      .toList(),
                ),
        ],
      ),
    );
  }
}

class WHOISRetrieverPage extends StatelessWidget {
  const WHOISRetrieverPage({super.key});

  @override
  Widget build(
    BuildContext context,
  ) {
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
  WHOISRetrieverBodyState createState() => WHOISRetrieverBodyState();
}

class WHOISRetrieverBodyState extends State<WHOISRetrieverBody> {
  late String domainName;
  bool isLoading = false;
  Map<String, String> whoisInformation = {};

  void retrieveWHOIS() async {
    setState(
      () {
        whoisInformation.clear();
        isLoading = true;
      },
    );

    var options = const LookupOptions(
      timeout: Duration(
        milliseconds: 10000,
      ),
      port: 43,
    );

    try {
      final whoisResponse = await Whois.lookup(
        domainName,
        options,
      );
      final parsedResponse = Whois.formatLookup(whoisResponse);

      setState(
        () {
          whoisInformation = Map<String, String>.from(parsedResponse);
          isLoading = false;
        },
      );
    } catch (error) {
      setState(
        () {
          whoisInformation = {'Error': error.toString()};
          isLoading = false;
        },
      );
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextField(
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Enter a Domain Name',
              hintText: 'bitscoper.live',
            ),
            onChanged: (value) {
              domainName = value.trim();
            },
          ),
          const SizedBox(
            height: 16,
          ),
          Center(
            child: ElevatedButton(
              onPressed: isLoading ? null : retrieveWHOIS,
              child: const Text('Lookup'),
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(),
            )
          else
            Card(
              child: Column(
                children: whoisInformation.entries.map(
                  (entry) {
                    return ListTile(
                      title: Text(entry.key),
                      subtitle: Text(entry.value),
                    );
                  },
                ).toList(),
              ),
            ),
        ],
      ),
    );
  }
}
