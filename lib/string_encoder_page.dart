/* By Abdullah As-Sadeed */

import "dart:convert";
import 'package:b/b.dart';
import 'package:flutter/material.dart';

import 'package:bitscoper_cyber_toolbox/copy_to_clipboard.dart';

class StringEncoderPage extends StatelessWidget {
  const StringEncoderPage({super.key});

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('String Encoder'),
        centerTitle: true,
      ),
      body: const StringEncoderBody(),
    );
  }
}

class StringEncoderBody extends StatefulWidget {
  const StringEncoderBody({super.key});

  @override
  StringEncoderBodyState createState() => StringEncoderBodyState();
}

class StringEncoderBodyState extends State<StringEncoderBody> {
  final _formKey = GlobalKey<FormState>();
  late String inputAsBase64 = '';

  final baseSystems = {
    'Binary (Base2)': base2,
    'Ternary (Base3)': base3,
    'Quaternary (Base4)': base4,
    'Quinary (Base5)': base5,
    'Senary (Base6)': base6,
    'Octal (Base8)': base8,
    'Decimal (Base10)': base10,
    'Duodecimal (Base12)': base12,
    'Hexadecimal (Base16)': base16,
    'Base32': base32,
    'Base32Hex': base32hex,
    'Base36': base36,
    'Base58': base58,
    'Base62': base62,
    'Base64': base64,
    'Base64 URL': base64url,
  };

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
            child: TextFormField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'String',
                hintText: 'Abdullah As-Sadeed',
              ),
              onChanged: (value) {
                setState(
                  () {
                    inputAsBase64 =
                        base64Encode(utf8.encode(value)).replaceAll('=', '');
                  },
                );
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a string!';
                }

                return null;
              },
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          inputAsBase64.isEmpty
              ? const Center(
                  child: Text(
                    'Start typing a string to encode.',
                    textAlign: TextAlign.center,
                  ),
                )
              : Column(
                  children: baseSystems.entries.map(
                    (entry) {
                      String output = '';

                      try {
                        final converter = BaseConversion(
                          from: base64,
                          to: entry.value,
                          zeroPadding: true,
                        );
                        output = converter(inputAsBase64);
                      } catch (error) {
                        output = error.toString();
                      }

                      return Padding(
                        padding: const EdgeInsets.only(
                          bottom: 8,
                        ),
                        child: Card(
                          child: ListTile(
                            title: Text(entry.key),
                            subtitle: Text(output),
                            trailing: IconButton(
                              icon: const Icon(Icons.copy_rounded),
                              onPressed: () {
                                copyToClipBoard(
                                  entry.key,
                                  output,
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ).toList(),
                )
        ],
      ),
    );
  }
}
