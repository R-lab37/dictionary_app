import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: DictionaryApp(),
    );
  }
}

class DictionaryApp extends StatefulWidget {
  const DictionaryApp({Key? key}) : super(key: key);

  @override
  State<DictionaryApp> createState() => _DictionaryAppState();
}

class _DictionaryAppState extends State<DictionaryApp> {
  final TextEditingController _queryController = TextEditingController();
  Map<String, dynamic>? _definition;

  Future<void> _fetchData() async {
    final String word = _queryController.text.trim();
    if (word.isNotEmpty) {
      final response = await http.get(
          Uri.parse('https://api.dictionaryapi.dev/api/v2/entries/en/$word'));
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        setState(() {
          _definition =
              jsonResponse[0]; // Take the first definition for simplicity
        });
      } else {
        setState(() {
          _definition = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Dictionary',
          style: TextStyle(fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _queryController,
              maxLines: null,
              onChanged: (text) {
                setState(() {});
              },
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.book_outlined),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                hintText: 'Enter the word to search..',
                suffixIcon: _queryController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _queryController.clear();
                            _definition = null;
                          });
                        },
                      )
                    : null,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            OutlinedButton(
              onPressed: _fetchData,
              child: const Text('Search In Dictionary'),
            ),
            const SizedBox(height: 20),
            if (_definition != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Word: ${_definition!['word']}',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Phonetic: ${_definition!['phonetic']}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Meanings:',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      for (var meaning in _definition!['meanings']) ...[
                        const SizedBox(height: 10),
                        Text(
                          '${meaning['partOfSpeech']}:',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        for (var definition in meaning['definitions']) ...[
                          const SizedBox(height: 5),
                          Text(
                            '- ${definition['definition']}',
                            style: const TextStyle(fontSize: 16),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          if (definition['example'] != null)
                            Padding(
                              padding: const EdgeInsets.only(left: 20),
                              child: Text(
                                'Example: ${definition['example']}',
                                style: const TextStyle(
                                    fontSize: 16, fontStyle: FontStyle.italic),
                              ),
                            ),
                        ],
                      ],
                      if (_definition!['synonyms'] != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          'Synonyms:',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: Text(
                            _definition!['synonyms'].join(', '),
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            if (_definition == null && _queryController.text.isNotEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'No definition found for the entered word.',
                  style: TextStyle(fontSize: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
