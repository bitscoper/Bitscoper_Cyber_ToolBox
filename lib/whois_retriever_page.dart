/* By Abdullah As-Sadeed */

import 'package:flutter/material.dart';
import 'package:whois/whois.dart';

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

  bool isRetrieving = false;
  Map<String, String> whoisInformation = {};

  void retrieveWHOIS() async {
    setState(
      () {
        isRetrieving = true;
        whoisInformation.clear();
      },
    );

    var lookupOptions = const LookupOptions(
      timeout: Duration(
        milliseconds: 10000,
      ),
      port: 43,
    );

    try {
      final whoisResponse = await Whois.lookup(
        domainName,
        lookupOptions,
      );
      final parsedResponse = Whois.formatLookup(whoisResponse);

      setState(
        () {
          whoisInformation = Map<String, String>.from(parsedResponse);
          isRetrieving = false;
        },
      );
    } catch (error) {
      setState(
        () {
          whoisInformation = {'Error': error.toString()};
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
              onPressed: isRetrieving ? null : retrieveWHOIS,
              child: const Text('Lookup'),
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          if (isRetrieving)
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
