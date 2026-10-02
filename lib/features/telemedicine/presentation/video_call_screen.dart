import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/routing/navigation_helper.dart';
import '../../../core/routing/route_paths.dart';
import '../../../core/widgets/avatar_widget.dart';

class VideoCallScreen extends StatefulWidget {
  final String? doctorName;

  const VideoCallScreen({
    super.key,
    this.doctorName = 'Dr. Sarah Watson',
  });

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  bool _isMuted = false;
  bool _isVideoOff = false;
  bool _isSpeakerOn = true;
  int _callDurationSeconds = 145; // 02:25

  @override
  Widget build(BuildContext context) {
    final minutes = (_callDurationSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_callDurationSeconds % 60).toString().padLeft(2, '0');

    return AppBackScope(
      fallbackRoute: RoutePaths.home,
      child: Scaffold(
        backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Stack(
          children: [
            // Remote Video View (Simulated Doctor Feed)
            Positioned.fill(
              child: Container(
                color: const Color(0xFF1E293B),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AvatarWidget(
                        name: widget.doctorName!,
                        imageUrl: 'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?auto=format&fit=crop&q=80&w=300',
                        size: 110,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.doctorName!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Cardiology Consultation Session',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.fiber_manual_record, color: AppColors.error, size: 12),
                            const SizedBox(width: 6),
                            Text(
                              '$minutes:$seconds',
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Local PiP Window (Patient Preview)
            Positioned(
              top: 20,
              right: 20,
              width: 100,
              height: 140,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF334155),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white24, width: 2),
                  boxShadow: const [
                    BoxShadow(color: Colors.black38, blurRadius: 10, offset: Offset(0, 4)),
                  ],
                ),
                child: Center(
                  child: _isVideoOff
                      ? const Icon(Icons.videocam_off, color: Colors.white54, size: 28)
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.person, color: Colors.white70, size: 36),
                            SizedBox(height: 4),
                            Text('You', style: TextStyle(color: Colors.white70, fontSize: 11)),
                          ],
                        ),
                ),
              ),
            ),

            // Top Status Bar Controls
            Positioned(
              top: 20,
              left: 20,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => context.safePop(null, RoutePaths.home),
              ),
            ),

            // Bottom Call Controls (Directly inspired by reference incoming / active call UI)
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A).withOpacity(0.85),
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Mute
                        _buildCallAction(
                          icon: _isMuted ? Icons.mic_off : Icons.mic,
                          isActive: _isMuted,
                          onTap: () => setState(() => _isMuted = !_isMuted),
                        ),
                        // Video Toggle
                        _buildCallAction(
                          icon: _isVideoOff ? Icons.videocam_off : Icons.videocam,
                          isActive: _isVideoOff,
                          onTap: () => setState(() => _isVideoOff = !_isVideoOff),
                        ),
                        // Speaker
                        _buildCallAction(
                          icon: _isSpeakerOn ? Icons.volume_up : Icons.volume_down,
                          isActive: _isSpeakerOn,
                          onTap: () => setState(() => _isSpeakerOn = !_isSpeakerOn),
                        ),
                        // End Call Button
                        GestureDetector(
                          onTap: () {
                            context.safePop(null, RoutePaths.home);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Telemedicine consultation ended.')),
                            );
                          },
                          child: Container(
                            width: 52,
                            height: 52,
                            decoration: const BoxDecoration(
                              color: AppColors.error,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.call_end, color: Colors.white, size: 26),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildCallAction({
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isActive ? Colors.white24 : Colors.white10,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}
