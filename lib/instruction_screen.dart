import 'package:flutter/material.dart';
import 'camera_screen.dart';

class InstructionScreen extends StatelessWidget {
  static const routeName = '/instructions';

  const InstructionScreen({super.key});

  Widget _buildStepCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: const Color(0xFFFFCCBC),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: const Color(0xFFD84315), size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 14, height: 1.4),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('How Rakth-Chitra Works'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Quick Guide',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Capture your lower eyelid image, let the app analyze the color tones, and receive a friendly anemia risk summary.',
                style: TextStyle(fontSize: 16, height: 1.5),
              ),
              const SizedBox(height: 24),
              _buildStepCard(
                icon: Icons.photo_camera,
                title: '1. Capture Clean Image',
                description: 'Use proper lighting and align the lower eyelid inside the frame.',
              ),
              const SizedBox(height: 14),
              _buildStepCard(
                icon: Icons.analytics,
                title: '2. Analyze Color Tones',
                description: 'The app measures redness and paleness from the image data.',
              ),
              const SizedBox(height: 14),
              _buildStepCard(
                icon: Icons.health_and_safety,
                title: '3. Get Risk Summary',
                description: 'Receive an easy-to-understand result with confidence and suggestions.',
              ),
              const Spacer(),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, CameraScreen.routeName);
                  },
                  child: const Text('Begin Scan'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
