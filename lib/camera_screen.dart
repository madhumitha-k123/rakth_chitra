import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'processing_screen.dart';

class CameraScreen extends StatefulWidget {
  static const routeName = '/camera';

  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _setupCamera();
  }

  Future<void> _setupCamera() async {
    final cameras = await availableCameras();
    if (cameras.isNotEmpty) {
      _controller = CameraController(
        cameras.first,
        ResolutionPreset.medium,
      );
      _initializeControllerFuture = _controller!.initialize();
      setState(() {});
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Lower Eyelid'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.shade100,
                          blurRadius: 16,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: _controller == null
                        ? const Center(child: CircularProgressIndicator())
                        : FutureBuilder<void>(
                            future: _initializeControllerFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.done) {
                                return Stack(
                                  children: [
                                    CameraPreview(_controller!),
                                    Positioned(
                                      right: 16,
                                      top: 16,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white70,
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 8,
                                        ),
                                        child: const Text(
                                          'Keep lower eyelid within the frame',
                                          style: TextStyle(
                                            color: Colors.black87,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              }
                              return const Center(child: CircularProgressIndicator());
                            },
                          ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        final navigator = Navigator.of(context);
                        final image = await _controller!.takePicture();
                        if (!mounted) return;
                        navigator.push(
                          MaterialPageRoute(
                            builder: (_) => ProcessingScreen(imagePath: image.path),
                          ),
                        );
                      } catch (e) {
                        debugPrint('Camera capture error: $e');
                      }
                    },
                    child: const Text('Start Scan'),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Use natural light and keep the phone steady. Capture only the lower eyelid area.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.black87,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
