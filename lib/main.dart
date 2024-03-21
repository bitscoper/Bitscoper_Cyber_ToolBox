/* By Abdullah As-Sadeed */

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tcp_scanner/tcp_scanner.dart';
import 'package:flutter_traceroute/flutter_traceroute.dart';
import 'package:flutter_traceroute/flutter_traceroute_platform_interface.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
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
          children: <Widget>[
            ListTile(
              title: const Text('TCP Port Scanner'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const TCPPortScannerPage()),
                );
              },
            ),
            ListTile(
              title: const Text('Route Tracer'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const RouteTracerPage()),
                );
              },
            ),
            ListTile(
              title: const Text('Tool 3'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Tool3Page()),
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
  final List<int> portList = List.generate(65536, (i) => i);
  final Stopwatch stopwatch = Stopwatch();

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
          .transform(StreamTransformer.fromHandlers(handleData: (report, sink) {
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
          }))
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
              hintText: 'Enter a Host or IP Address',
              labelText: 'Enter a Host or IP Address',
              border: OutlineInputBorder(),
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
                    child: const Text('Scan TCP Ports'),
                  ),
                ),
          const SizedBox(height: 16),
          if (scanProgress == 1.0) ...[Text(scanResult)],
        ],
      ),
    );
  }
}

class RouteTracerPage extends StatefulWidget {
  const RouteTracerPage({super.key});

  @override
  State<RouteTracerPage> createState() => RouteTracerPageState();
}

class RouteTracerPageState extends State<RouteTracerPage> {
  List<TracerouteStep> traceResults = [];

  late final FlutterTraceroute routeTracer;
  late final TextEditingController hostController;

  @override
  void initState() {
    super.initState();

    routeTracer = FlutterTraceroute();
    hostController = TextEditingController();
  }

  void onTrace() {
    setState(() {
      traceResults = <TracerouteStep>[];
    });

    final host = hostController.text;

    final arguments = TracerouteArgs(host: host);

    routeTracer.trace(arguments).listen((event) {
      setState(() {
        traceResults = List<TracerouteStep>.from(traceResults)..add(event);
      });
    });
  }

  void onStop() {
    routeTracer.stopTrace();

    setState(() {
      traceResults = <TracerouteStep>[];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Route Tracer'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Enter Host or IP Address',
                labelText: 'Enter Host or IP Address',
              ),
              controller: hostController,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                OutlinedButton(
                  onPressed: onTrace,
                  child: const Text('Trace'),
                ),
                OutlinedButton(
                  onPressed: onStop,
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class Tool3Page extends StatelessWidget {
  const Tool3Page({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tool 3'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text('This is the page for Tool 3.'),
      ),
    );
  }
}
