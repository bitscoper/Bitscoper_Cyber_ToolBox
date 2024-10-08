/* By Abdullah As-Sadeed */

import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:bitscoper_cyber_toolbox/copy_to_clipboard.dart';

class FileHashCalculatorPage extends StatelessWidget {
  const FileHashCalculatorPage({super.key});

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('File Hash Calculator'),
        centerTitle: true,
      ),
      body: const FileHashCalculatorBody(),
    );
  }
}

class FileHashCalculatorBody extends StatefulWidget {
  const FileHashCalculatorBody({super.key});

  @override
  FileHashCalculatorBodyState createState() => FileHashCalculatorBodyState();
}

class FileHashCalculatorBodyState extends State<FileHashCalculatorBody> {
  List<Map<String, dynamic>> hashValues = [];

  void calculateHashes(
    List<File> files,
  ) {
    setState(
      () {
        hashValues = files.map(
          (file) {
            var bytes = file.readAsBytesSync();
            var md5Hash = md5.convert(bytes);
            var sha1Hash = sha1.convert(bytes);
            var sha224Hash = sha224.convert(bytes);
            var sha256Hash = sha256.convert(bytes);
            var sha384Hash = sha384.convert(bytes);
            var sha512Hash = sha512.convert(bytes);

            return {
              'File Name': file.path.split('/').last,
              'MD5': md5Hash.toString(),
              'SHA1': sha1Hash.toString(),
              'SHA224': sha224Hash.toString(),
              'SHA256': sha256Hash.toString(),
              'SHA384': sha384Hash.toString(),
              'SHA512': sha512Hash.toString(),
            };
          },
        ).toList();
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
          Center(
            child: ElevatedButton(
              child: const Text('Select Files'),
              onPressed: () async {
                List<Uint8List> files = [];

                var result = await FilePicker.platform.pickFiles(
                  allowMultiple: true,
                );

                if (result != null) {
                  List<File> selectedFiles = result.paths
                      .where(
                    (path) => path != null,
                  )
                      .map(
                    (path) {
                      return File(path!);
                    },
                  ).toList();

                  for (var file in selectedFiles) {
                    files.add(
                      file.readAsBytesSync(),
                    );
                  }

                  calculateHashes(selectedFiles);
                }
              },
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          hashValues.isEmpty
              ? const Center(
                  child: Text(
                    'Select files to calculate their MD5, SHA1, SHA224, SHA256, SHA384, and SHA512 hashes.',
                    textAlign: TextAlign.center,
                  ),
                )
              : Column(
                  children: <Widget>[
                    for (var hashValue in hashValues)
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: 16,
                        ),
                        child: Card(
                          child: Column(
                            children: <Widget>[
                              ListTile(
                                title: Center(
                                  child: Text(
                                    hashValue['File Name'],
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              for (var entry in hashValue.entries)
                                if (entry.key != 'File Name')
                                  ListTile(
                                    title: Text(
                                      entry.key,
                                    ),
                                    subtitle: Text(
                                      entry.value,
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.copy_rounded),
                                      onPressed: () {
                                        copyToClipBoard(
                                          context,
                                          "${entry.key} hash",
                                          entry.value,
                                        );
                                      },
                                    ),
                                  ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
        ],
      ),
    );
  }
}
