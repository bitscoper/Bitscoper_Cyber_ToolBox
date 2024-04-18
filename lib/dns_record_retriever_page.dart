/* By Abdullah As-Sadeed */

import 'package:dnsolve/dnsolve.dart';
import 'package:flutter/material.dart';

import 'package:bitscoper_cyber_toolbox/copy_to_clipboard.dart';

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

class DNSRecord {
  final RecordType type;
  final String record;

  DNSRecord(this.type, this.record);
}

class DNSRecordRetrieverBodyState extends State<DNSRecordRetrieverBody> {
  final _formKey = GlobalKey<FormState>();
  late String host;

  DNSProvider recordProvider = DNSProvider.cloudflare;

  bool isRetrieving = false;
  List<DNSRecord> results = [];

  Future<void> retrieveDNSRecord() async {
    setState(
      () {
        isRetrieving = true;
        results = [];
      },
    );

    for (var recordType in RecordType.values) {
      final response = await DNSolve().lookup(
        host,
        dnsSec: true,
        type: recordType,
        provider: recordProvider,
      );

      if (response.answer!.records != null) {
        for (final record in response.answer!.records!) {
          results.add(
            DNSRecord(recordType, record.toBind),
          );
        }
      }
    }

    setState(
      () {
        isRetrieving = false;
      },
    );
  }

  String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

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
                      return 'Please enter a host or IP address!';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 16,
                ),
                DropdownButtonFormField<DNSProvider>(
                  decoration: const InputDecoration(
                    labelText: 'Select DNS Provider',
                  ),
                  value: recordProvider,
                  onChanged: (DNSProvider? newValue) {
                    setState(
                      () {
                        recordProvider = newValue!;
                      },
                    );
                  },
                  items: DNSProvider.values.map<DropdownMenuItem<DNSProvider>>(
                    (DNSProvider value) {
                      return DropdownMenuItem<DNSProvider>(
                        value: value,
                        child: Text(
                          capitalize(value.toString().split('.').last),
                        ),
                      );
                    },
                  ).toList(),
                ),
                const SizedBox(
                  height: 16,
                ),
                Center(
                  child: ElevatedButton(
                    onPressed: isRetrieving
                        ? null
                        : () {
                            if (_formKey.currentState!.validate()) {
                              retrieveDNSRecord();
                            }
                          },
                    child: const Text('Lookup'),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          isRetrieving
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : (results.isEmpty
                  ? const Center(
                      child: Text(
                        'It tries to loop through all types of records and retrieve them, which takes time.',
                        textAlign: TextAlign.center,
                      ),
                    )
                  : Column(
                      children: results
                          .map(
                            (result) => Padding(
                              padding: const EdgeInsets.only(
                                bottom: 8,
                              ),
                              child: Card(
                                child: ListTile(
                                  title: Text(
                                    result.type
                                        .toString()
                                        .split('.')
                                        .last
                                        .toUpperCase(),
                                  ),
                                  subtitle: Text(result.record),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.copy_rounded),
                                    onPressed: () {
                                      copyToClipBoard(
                                        'DNS record',
                                        result.record,
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ))
        ],
      ),
    );
  }
}
