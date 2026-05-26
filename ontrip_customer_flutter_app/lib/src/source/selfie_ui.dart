import 'dart:io';
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ontrip_customer_flutter_app/src/core/app_theme_colors.dart';
import 'package:ontrip_customer_flutter_app/src/core/constants.dart';

class SelfieUI extends StatefulWidget {
  final String distributorName;
  final bool isProfile;
  final String? communityId;

  const SelfieUI({super.key, required this.distributorName, required this.isProfile, this.communityId});

  @override
  State<SelfieUI> createState() => _SelfieUIState();
}

class _SelfieUIState extends State<SelfieUI> with TickerProviderStateMixin {
  List<CameraDescription> cameras = [];
  CameraController? cameraController;
  bool _isCapturing = false, isFrontCamera = true;
  bool isCameraSwitching = false, _isInitializing = true;

  late AnimationController _captureAnimationController;
  late Animation<double> _captureAnimation;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _initializeAnimations();
    _initializeCamera();
  }

  void _initializeAnimations() {
    _captureAnimationController = AnimationController(duration: const Duration(milliseconds: 300), vsync: this);
    _captureAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(CurvedAnimation(parent: _captureAnimationController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    cameraController?.dispose();
    _captureAnimationController.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    if (mounted) setState(() => _isInitializing = true);
    try {
      if (cameras.isEmpty) cameras = await availableCameras();
      final camera = cameras.firstWhere(
        (c) => c.lensDirection == (isFrontCamera ? CameraLensDirection.front : CameraLensDirection.back),
        orElse: () => cameras.first,
      );
      cameraController = CameraController(camera, ResolutionPreset.high, enableAudio: false, imageFormatGroup: ImageFormatGroup.jpeg);
      await cameraController!.initialize();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Camera error: Please try again')));
    } finally {
      if (mounted) setState(() => _isInitializing = false);
    }
  }

  Future<void> _switchCamera() async {
    if (isCameraSwitching) return;
    setState(() => isCameraSwitching = true);
    isFrontCamera = !isFrontCamera;
    await cameraController?.dispose();
    await _initializeCamera();
    setState(() => isCameraSwitching = false);
  }

  Future<void> _takePicture() async {
    if (cameraController == null || !cameraController!.value.isInitialized || _isCapturing || isCameraSwitching) return;
    setState(() => _isCapturing = true);
    try {
      HapticFeedback.mediumImpact();
      _captureAnimationController.forward().then((_) => _captureAnimationController.reverse());
      final XFile file = await cameraController!.takePicture();
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) Navigator.pop(context, File(file.path));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error taking picture: $e')));
    } finally {
      if (mounted) setState(() => _isCapturing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Fullscreen camera preview ──
          _buildFullscreenPreview(),

          // ── Dashed face frame overlay ──
          Positioned.fill(
            child: CustomPaint(painter: DashedFramePainter(color: AppThemeColors.primaryOrange)),
          ),

          // ── Top bar ──
          Positioned(top: 0, left: 0, right: 0, child: _buildTopBar()),

          // ── Bottom controls ──
          Positioned(bottom: 0, left: 0, right: 0, child: _buildBottomControls()),
        ],
      ),
    );
  }

  Widget _buildFullscreenPreview() {
    if (_isInitializing || cameraController == null || !cameraController!.value.isInitialized) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }

    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: cameraController!.value.previewSize!.height,
          height: cameraController!.value.previewSize!.width,
          child: CameraPreview(cameraController!),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Close button
            _glassIconButton(icon: Icons.close, onTap: () => Navigator.pop(context)),
            const Text(
              "Take a Selfie",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                shadows: [Shadow(blurRadius: 8, color: Colors.black54)],
              ),
            ),
            // Flip camera button
            _glassIconButton(icon: Icons.flip_camera_ios_outlined, onTap: isCameraSwitching ? null : _switchCamera),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 16, 32, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "Position your face within the frame",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.white.withValues(alpha: 0.8),
                shadows: const [Shadow(blurRadius: 6, color: Colors.black87)],
              ),
            ),
            const SizedBox(height: 20),
            _buildCaptureButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildCaptureButton() {
    return AnimatedBuilder(
      animation: _captureAnimation,
      builder: (context, _) => Transform.scale(
        scale: _captureAnimation.value,
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isCapturing ? null : _takePicture,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppThemeColors.primaryOrange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 6,
            ),
            child: _isCapturing
                ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt_outlined),
                      SizedBox(width: 12),
                      Text("Capture Photo", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _glassIconButton({required IconData icon, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.35),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white24),
        ),
        child: Icon(icon, color: onTap == null ? Colors.white38 : Colors.white, size: 22),
      ),
    );
  }
}

class DashedFramePainter extends CustomPainter {
  final Color color;
  DashedFramePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    // Oval face guide — centred, takes ~55% width
    final double ovalW = size.width * 0.55;
    final double ovalH = ovalW * 1.3;
    final Rect ovalRect = Rect.fromCenter(center: Offset(size.width / 2, size.height * 0.42), width: ovalW, height: ovalH);

    final Path path = Path()..addOval(ovalRect);
    canvas.drawPath(_dashPath(path, 12, 6), paint);

    // Subtle dark vignette around the oval
    final Paint vignette = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        radius: 0.75,
        colors: [Colors.transparent, Colors.black.withValues(alpha: 0.55)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), vignette);
  }

  Path _dashPath(Path source, double dashWidth, double dashSpace) {
    final Path dest = Path();
    for (final PathMetric metric in source.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        dest.addPath(metric.extractPath(distance, distance + dashWidth), Offset.zero);
        distance += dashWidth + dashSpace;
      }
    }
    return dest;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
