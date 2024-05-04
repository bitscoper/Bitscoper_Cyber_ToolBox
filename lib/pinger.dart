/* By Abdullah As-Sadeed */

import 'package:flutter/material.dart';
import 'package:dart_ping/dart_ping.dart';

class PingerPage extends StatelessWidget {
  const PingerPage({super.key});

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pinger'),
        centerTitle: true,
      ),
      body: const PingerBody(),
    );
  }
}

class PingerBody extends StatefulWidget {
  const PingerBody({super.key});

  @override
  PingerBodyState createState() => PingerBodyState();
}

class PingerBodyState extends State<PingerBody> {
  final _formKey = GlobalKey<FormState>();
  late String host;

  bool isRetrieving = false;
  String result = '';

  Future<void> ping() async {
    if (_formKey.currentState!.validate()) {
      isRetrieving = true;

      result = (
        await Ping(
          host,
          count: 1,
        ).stream.first,
      ).toString();

      setState(
        () {
          isRetrieving = false;
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
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Enter a Host or IP Address',
                    hintText: 'bitscoper.live',
                  ),
                  onChanged: (value) {
                    host = value.trim();
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a host or IP Address!';
                    }

                    return null;
                  },
                  onFieldSubmitted: (value) async {
                    await ping();
                  },
                ),
                const SizedBox(
                  height: 16,
                ),
                Center(
                  child: ElevatedButton(
                    onPressed: isRetrieving
                        ? null
                        : () async {
                            await ping();
                          },
                    child: const Text('Ping'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          Text(result),
        ],
      ),
    );
  }
}
