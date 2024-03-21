import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tcp_scanner/tcp_scanner.dart';

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
              title: const Text('Port Scanner'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const PortScannerPage()),
                );
              },
            ),
            ListTile(
              title: const Text('Tool 2'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Tool2Page()),
                );
              },
            ),
            // Add more ListTiles for each tool
          ],
        ),
      ),
      body: const Center(
        child: Text('Select a tool from the drawer.'),
      ),
    );
  }
}

class PortScannerPage extends StatelessWidget {
  const PortScannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Port Scanner'),
        centerTitle: true,
      ),
      body: const PortScannerBody(),
    );
  }
}

class PortScannerBody extends StatefulWidget {
  const PortScannerBody({super.key});

  @override
  PortScannerBodyState createState() => PortScannerBodyState();
}

class PortScannerBodyState extends State<PortScannerBody> {
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

  Future<void> scanPorts() async {
    final String host = hostController.text.trim();
    if (host.isEmpty) {
      setState(() {
        scanResult = 'Enter a valid host or IP address!';
      });
      return;
    }

    stopwatch.start();
    isScanning = true;

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

                      await scanPorts();
                    },
                    child: const Text('Scan Ports'),
                  ),
                ),
          const SizedBox(height: 16),
          if (scanProgress == 1.0) ...[Text(scanResult)],
        ],
      ),
    );
  }
}

class Tool2Page extends StatelessWidget {
  const Tool2Page({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tool 2'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text('This is the page for Tool 2.'),
      ),
    );
  }
}
