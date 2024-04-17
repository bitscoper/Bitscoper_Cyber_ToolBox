/* By Abdullah As-Sadeed */

import 'package:flutter/material.dart';

import 'package:bitscoper_cyber_toolbox/dns_record_retriever_page.dart';
import 'package:bitscoper_cyber_toolbox/file_hash_calculator_page.dart';
import 'package:bitscoper_cyber_toolbox/route_tracer_page.dart';
import 'package:bitscoper_cyber_toolbox/series_uri_crawler_page.dart';
import 'package:bitscoper_cyber_toolbox/tcp_port_scanner_page.dart';
import 'package:bitscoper_cyber_toolbox/whois_retriever_page.dart';

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
              leading: const Icon(Icons.dark_mode_rounded),
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
                Icons.network_ping_rounded,
                const TCPPortScannerPage(),
              ),
              buildToolCard(
                'Route Tracer',
                Icons.track_changes_rounded,
                const RouteTracerPage(),
              ),
              buildToolCard(
                'File Hash Calculator',
                Icons.file_present_rounded,
                const FileHashCalculatorPage(),
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
