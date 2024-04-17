/* By Abdullah As-Sadeed */

import 'package:flutter/material.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' as parser;
import 'package:http/http.dart' as http;

import 'package:bitscoper_cyber_toolbox/copy_to_clipboard.dart';

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
                      leading: const Icon(Icons.link_rounded),
                      title: Text(
                        entry.value,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.copy_rounded),
                        onPressed: () {
                          copyToClipBoard(
                            'URI',
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
