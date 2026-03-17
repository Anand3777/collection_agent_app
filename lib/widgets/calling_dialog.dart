import 'package:flutter/material.dart';
import 'dart:math' as math;

class CallingDialog extends StatefulWidget {
  final String userName;
  final String? userAvatar;
  final VoidCallback onEndCall;
  final VoidCallback? onMute;
  final VoidCallback? onSpeaker;
  final bool isMuted;
  final bool isSpeakerOn;

  const CallingDialog({
    Key? key,
    required this.userName,
    this.userAvatar,
    required this.onEndCall,
    this.onMute,
    this.onSpeaker,
    this.isMuted = false,
    this.isSpeakerOn = false,
  }) : super(key: key);

  @override
  State<CallingDialog> createState() => _CallingDialogState();
}

class _CallingDialogState extends State<CallingDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          maxWidth: 340,
        ),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF1E2A47),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Connecting text
              const Text(
                'Connecting to Call...',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 16),

              // User name
              Text(
                widget.userName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              // Animated avatar with pulsing rings
              Stack(
                alignment: Alignment.center,
                children: [
                  // Pulsing rings
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return CustomPaint(
                        size: const Size(200, 200),
                        painter: PulseRingsPainter(
                          scale: _pulseAnimation.value,
                        ),
                      );
                    },
                  ),

                  // Avatar
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF2A4A7A),
                        width: 3,
                      ),
                      image: widget.userAvatar != null
                          ? DecorationImage(
                              image: AssetImage(widget.userAvatar!),
                              fit: BoxFit.cover,
                            )
                          : null,
                      color: const Color(0xFF5A7A9A),
                    ),
                    child: widget.userAvatar == null
                        ? Center(
                            child: Text(
                              widget.userName.isNotEmpty
                                  ? widget.userName[0].toUpperCase()
                                  : 'U',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : null,
                  ),

                  // Green call icon
                  Positioned(
                    bottom: 5,
                    right: 5,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: Color(0xFF00C853),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.call,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Mute and Speaker buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Mute button
                  _buildControlButton(
                    icon: widget.isMuted ? Icons.mic_off : Icons.mic,
                    label: 'MUTE',
                    onPressed: widget.onMute,
                    isActive: widget.isMuted,
                  ),
                  const SizedBox(width: 32),

                  // Speaker button
                  _buildControlButton(
                    icon: widget.isSpeakerOn ? Icons.volume_up : Icons.volume_down,
                    label: 'SPEAKER',
                    onPressed: widget.onSpeaker,
                    isActive: widget.isSpeakerOn,
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // End call button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: widget.onEndCall,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE53935),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Transform.rotate(
                        angle: 135 * math.pi / 180,
                        child: const Icon(Icons.call, size: 20),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'END CALL',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    VoidCallback? onPressed,
    bool isActive = false,
  }) {
    return Column(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: const Color(0xFF2A3A5A),
            shape: BoxShape.circle,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPressed,
              customBorder: const CircleBorder(),
              child: Center(
                child: Icon(
                  icon,
                  color: isActive ? Colors.red : Colors.white70,
                  size: 24,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 11,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }
}

class PulseRingsPainter extends CustomPainter {
  final double scale;

  PulseRingsPainter({required this.scale});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw multiple rings
    for (int i = 0; i < 3; i++) {
      final radius = (80 + (i * 40)) * scale;
      final opacity = (1.0 - (i * 0.3)) * (2.0 - scale);

      paint.color = const Color(0xFF2A4A7A).withOpacity(opacity.clamp(0.0, 0.5));
      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(PulseRingsPainter oldDelegate) {
    return oldDelegate.scale != scale;
  }
}
