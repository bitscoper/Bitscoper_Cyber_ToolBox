/* By Abdullah As-Sadeed */

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tcp_scanner/tcp_scanner.dart';

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
          Center(
            child: isScanning
                ? const CircularProgressIndicator()
                : ElevatedButton(
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
