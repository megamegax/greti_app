import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rive/rive.dart';
import 'package:flutter/src/painting/gradient.dart' as FlutterGradient;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Számlábló',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: const MyHomePage(title: 'Gréti számláblója'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  Artboard? _riveArtboard;
  late RiveAnimationController _controller;
  late RiveAnimationController _controllerHatch;
  late RiveAnimationController _controllerIdle;
  bool _isPlaying = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    rootBundle.load('assets/baby_dragon.riv').then(
      (data) async {
        final file = RiveFile.import(data);

        final artboard = file.mainArtboard;
        _controller = OneShotAnimation(
          'Intro Idle',
          autoplay: true,
          onStop: () => setState(() => _isPlaying = false),
          onStart: () => setState(() => _isPlaying = true),
        );
        _controllerHatch = OneShotAnimation(
          'Egg Open',
          autoplay: false,
          onStop: () => setState(() {
            _isPlaying = false;
            _controllerIdle.isActive = true;
          }),
          onStart: () => setState(() => _isPlaying = true),
        );
        _controllerIdle = SimpleAnimation('Open Idle', autoplay: false);
        artboard.addController(_controller);
        artboard.addController(_controllerHatch);
        artboard.addController(_controllerIdle);
        _controller.isActive = true;
        //artboard.addController(SimpleAnimation('Open Idle'));
        //artboard.addController(SimpleAnimation('Egg Open'));

        setState(() => _riveArtboard = artboard);
      },
    );
  }

  final limit = 499;
  void _incrementCounter() {
    setState(() {
      if (_counter == limit) {
        _controllerHatch.isActive = true;
      }
      if (_counter <= limit) {
        if (_isPlaying) {
          _controller.isActive = false;
        }

        _counter++;
        _controller.isActive = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        decoration: const BoxDecoration(
            gradient: FlutterGradient.LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.purple, Colors.blue])),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Stack(
                children: <Widget>[
                  // Stroked text as border.
                  Text(
                    'Lábejtések száma:',
                    style: TextStyle(
                      fontSize: 16,
                      foreground: Paint()
                        ..style = PaintingStyle.stroke
                        ..strokeWidth = 1
                        ..color = Colors.black,
                    ),
                  ),
                  // Solid text as fill.
                  const Text(
                    'Lábejtések száma:',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Stack(
                children: <Widget>[
                  // Stroked text as border.
                  Text(
                    '$_counter',
                    style: TextStyle(
                      fontSize: 30,
                      foreground: Paint()
                        ..style = PaintingStyle.stroke
                        ..strokeWidth = 2
                        ..color = Colors.black54,
                    ),
                  ),
                  // Solid text as fill.
                  Text(
                    '$_counter',
                    style: const TextStyle(
                      fontSize: 30,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 400,
                child: GestureDetector(
                  child: _riveArtboard == null
                      ? Container()
                      : Rive(
                          artboard: _riveArtboard!,
                          fit: BoxFit.contain,
                        ),
                  //sötét lila: 370A31
                  //köztes lila: 53114A
                  // világos lila: 6D38CF
                  onTap: () {
                    _incrementCounter();
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
