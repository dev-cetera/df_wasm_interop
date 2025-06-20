import 'package:flutter/material.dart';
import 'package:df_wasm_interop/df_wasm_interop.dart';

import 'rust_api.dart'; // Our custom wrapper

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Wasm Interop Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // A Future to hold our initialized Wasm module's API.
  late final Future<RustApi> _futureApi;

  @override
  void initState() {
    super.initState();
    // Initialize the module when the widget is first created.
    _futureApi = _initializeWasm();
  }

  // The initialization logic.
  Future<RustApi> _initializeWasm() async {
    // Initialize the module using the .path to the JS glue file.
    final module = await WasmModule.initialize(jsPath: 'assets/rust_lib/pkg/rust_lib.js');
    // Cast the module's instance to our type-safe wrapper.
    return module.instance as RustApi;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Flutter Wasm Interop Demo'),
      ),
      body: Center(
        // FutureBuilder handles the loading/error/data states for us.
        child: FutureBuilder<RustApi>(
          future: _futureApi,
          builder: (context, snapshot) {
            // If the future is still running, show a loader.
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            // If there was an error, show it.
            if (snapshot.hasError) {
              print(snapshot.error);
              return Text('Error: ${snapshot.error}');
            }

            // If we have data (the API is ready), build the UI.
            if (snapshot.hasData) {
              final api = snapshot.data!;
              final isIt42 = api.is_answer_forty_two(43);
              final sum = api.add(15, 27);

              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text(
                      'Result from Rust `greet("Flutter")`:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(isIt42 ? 'Yes' : 'No', style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 24),
                    const Text(
                      'Result from Rust `add(15, 27)`:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text('$sum', style: Theme.of(context).textTheme.headlineMedium),
                  ],
                ),
              );
            }

            // Default case.
            return const Text('Initializing Wasm module...');
          },
        ),
      ),
    );
  }
}
