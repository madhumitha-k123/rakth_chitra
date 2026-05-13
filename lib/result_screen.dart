import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;

class ResultScreen extends StatefulWidget {
  final String imagePath;

  const ResultScreen({super.key, required this.imagePath});

  static const routeName = '/result';

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  bool _isAnalyzing = true;
  String _riskLevel = 'Calculating...';
  String _analysisMessage = '';
  double _riskValue = 0.0;
  int _avgR = 0;
  int _avgG = 0;
  int _avgB = 0;
  int _confidence = 0;
  int _rednessPercent = 0;
  int _palenessPercent = 0;

  @override
  void initState() {
    super.initState();
    _analyzeImage();
  }

  Future<void> _analyzeImage() async {
    try {
      final file = File(widget.imagePath);
      final bytes = await file.readAsBytes();
      final decodedImage = img.decodeImage(bytes);

      if (decodedImage == null) {
        setState(() {
          _isAnalyzing = false;
          _riskLevel = 'Analysis failed';
          _analysisMessage = 'Could not decode the image.';
        });
        return;
      }

      final processedImage = img.copyResize(decodedImage, width: 220);
      int sumR = 0;
      int sumG = 0;
      int sumB = 0;

      for (var y = 0; y < processedImage.height; y++) {
        for (var x = 0; x < processedImage.width; x++) {
          final pixel = processedImage.getPixel(x, y);
          final int r = pixel.r.toInt();
          final int g = pixel.g.toInt();
          final int b = pixel.b.toInt();
          sumR += r;
          sumG += g;
          sumB += b;
        }
      }

      final totalPixels = processedImage.width * processedImage.height;
      final avgRf = sumR / totalPixels;
      final avgGf = sumG / totalPixels;
      final avgBf = sumB / totalPixels;
      final avgBrightness = (avgRf + avgGf + avgBf) / 3 / 255;
      final redDominance = avgRf / (avgRf + avgGf + avgBf + 0.001);

      final paleScore = (((avgGf + avgBf) / 2) / 255) * avgBrightness;
      final riskValue = (1 - redDominance) * 0.3 + paleScore * 0.7;

      String riskLevel;
      if (riskValue < 0.35) {
        riskLevel = 'LOW';
      } else if (riskValue < 0.60) {
        riskLevel = 'MEDIUM';
      } else {
        riskLevel = 'HIGH';
      }

      final bucketCenter = riskLevel == 'LOW'
          ? 0.175
          : riskLevel == 'MEDIUM'
              ? 0.475
              : 0.8;
      final bucketRange = riskLevel == 'MEDIUM' ? 0.125 : 0.2;
      final rawConfidence =
          (1 - ((riskValue - bucketCenter).abs() / bucketRange)) * 100;
      final confidence = rawConfidence.clamp(45, 98).round();

      setState(() {
        _isAnalyzing = false;
        _riskLevel = riskLevel;
        _riskValue = riskValue.clamp(0.0, 1.0);
        _analysisMessage =
            'The app compares redness and paleness from your captured eyelid image.';
        _avgR = avgRf.round();
        _avgG = avgGf.round();
        _avgB = avgBf.round();
        _confidence = confidence;
        _rednessPercent = (redDominance * 100).round();
        _palenessPercent = (paleScore * 100).clamp(0, 100).round();
      });
    } catch (e) {
      setState(() {
        _isAnalyzing = false;
        _riskLevel = 'Analysis error';
        _analysisMessage = 'Error reading or processing the image.';
      });
      debugPrint('Image analysis failed: $e');
    }
  }

  Color get _riskColor {
    switch (_riskLevel) {
      case 'LOW':
        return Colors.green;
      case 'MEDIUM':
        return Colors.orange;
      case 'HIGH':
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analysis Result'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.file(File(widget.imagePath)),
            ),
            const SizedBox(height: 24),
            _isAnalyzing
                ? const Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 14),
                      Text(
                        'Processing image... please wait',
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  )
                : Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(18),
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
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Result Summary',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    '$_riskLevel risk of anemia detected.',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: _riskColor,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Confidence: $_confidence%',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: 120,
                              height: 120,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  CircularProgressIndicator(
                                    value: _riskValue,
                                    strokeWidth: 14,
                                    backgroundColor: Colors.orange.shade100,
                                    valueColor:
                                        AlwaysStoppedAnimation(_riskColor),
                                  ),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '${(_riskValue * 100).round()}%',
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: _riskColor,
                                        ),
                                      ),
                                      const Text('Risk'),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          _buildInfoCard(
                            title: 'Average RGB',
                            value: '($_avgR, $_avgG, $_avgB)',
                            icon: Icons.palette,
                          ),
                          _buildInfoCard(
                            title: 'Redness',
                            value: '$_rednessPercent%',
                            icon: Icons.favorite,
                          ),
                          _buildInfoCard(
                            title: 'Paleness',
                            value: '$_palenessPercent%',
                            icon: Icons.opacity,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _analysisMessage.isNotEmpty
                              ? _analysisMessage
                              : 'More red tones usually indicate healthier blood flow, while paler white tones can point to higher anemia risk.',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
            const SizedBox(height: 26),
            ElevatedButton(
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: const Text('Restart Scan'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return SizedBox(
      width: 170,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: Colors.red.shade400, size: 28),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
