import 'package:flutter/material.dart';
import 'package:df_wasm_interop/df_wasm_interop.dart';

import 'rust_api.dart';

late final RustApi rustApi;

Future<RustApi> _initializeWasm() async {
  final module = await WasmModule.initialize(
    jsPath: 'assets/rust_lib/pkg/rust_lib.js',
  );
  return module.instance as RustApi;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  rustApi = await _initializeWasm();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter WASM Interop!',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Flutter WASM Interop!'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Result from Rust `rustApi.is_answer_forty_two(42)`:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                rustApi.is_answer_forty_two(42) ? 'Yes' : 'No',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 24),
              const Text(
                'Result from Rust `rustApi.add(15, 27))`:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                '${rustApi.add(15, 27)}',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
