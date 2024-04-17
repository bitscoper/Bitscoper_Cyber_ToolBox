/* By Abdullah As-Sadeed */

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_traceroute/flutter_traceroute.dart';
import 'package:flutter_traceroute/flutter_traceroute_platform_interface.dart';

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
