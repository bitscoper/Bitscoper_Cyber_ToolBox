/* By Abdullah As-Sadeed */

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:bitscoper_cyber_toolbox/dns_record_retriever.dart';
import 'package:bitscoper_cyber_toolbox/file_hash_calculator.dart';
import 'package:bitscoper_cyber_toolbox/pinger.dart';
import 'package:bitscoper_cyber_toolbox/route_tracer.dart';
import 'package:bitscoper_cyber_toolbox/series_uri_crawler.dart';
import 'package:bitscoper_cyber_toolbox/string_encoder.dart';
import 'package:bitscoper_cyber_toolbox/tcp_port_scanner.dart';
import 'package:bitscoper_cyber_toolbox/whois_retriever.dart';

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
              leading: const Icon(Icons.dark_mode_rounded),
              onTap: () {
                toggleTheme();
              },
            ),
            ListTile(
              title: const Text('GitHub Repository'),
              leading: const Icon(Icons.code_rounded),
              onTap: () {
                launchUrl(
                  Uri.parse(
                      'https://github.com/bitscoper/Bitscoper_Cyber_ToolBox/'),
                );
              },
            ),
            ListTile(
              title: const Text('Developer'),
              leading: const Icon(Icons.person_rounded),
              onTap: () {
                launchUrl(
                  Uri.parse('https://github.com/bitscoper/'),
                );
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
                Icons.network_ping_rounded,
                const TCPPortScannerPage(),
              ),
              buildToolCard(
                'Route Tracer',
                Icons.track_changes_rounded,
                const RouteTracerPage(),
              ),
              buildToolCard(
                'Pinger',
                Icons.network_ping_rounded,
                const PingerPage(),
              ),
              buildToolCard(
                'File Hash Calculator',
                Icons.file_present_rounded,
                const FileHashCalculatorPage(),
              ),
              buildToolCard(
                'String Encoder',
                Icons.short_text_rounded,
                const StringEncoderPage(),
              ),
              buildToolCard(
                'Series URI Crawler',
                Icons.web_rounded,
                const SeriesURICrawlerPage(),
              ),
              buildToolCard(
                'DNS Record Retriever',
                Icons.dns_rounded,
                const DNSRecordRetrieverPage(),
              ),
              buildToolCard(
                'WHOIS Retriever',
                Icons.domain_rounded,
                const WHOISRetrieverPage(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
