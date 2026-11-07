import 'dart:async';
import 'package:flutter/material.dart';
import '../models/lead_model.dart';
import '../services/api_service.dart';
import '../services/mandatory_recorder_service.dart';
import '../services/phone_call_service.dart';
import '../theme/app_theme.dart';
import 'disposition_screen.dart';

class InAppDialerScreen extends StatefulWidget {
  final Lead lead;

  const InAppDialerScreen({super.key, required this.lead});

  @override
  State<InAppDialerScreen> createState() => _InAppDialerScreenState();
}

class _InAppDialerScreenState extends State<InAppDialerScreen> with SingleTickerProviderStateMixin {
  late Timer _timer;
  int _callSeconds = 0;
  bool _isMuted = false;
  bool _isSpeaker = true;
  bool _isEndingCall = false;

  final TextEditingController _notesController = TextEditingController();
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _initiateMandatoryCall();
  }

  Future<void> _initiateMandatoryCall() async {
    // 1. Lock in hardware microphone recording FIRST while app is in foreground
    final recOk = await mandatoryRecorder.startMandatoryRecording();
    debugPrint('Hardware audio recording active: $recOk');

    // 2. Start server session
    apiService.startCallSession(widget.lead.phoneNumber);

    // 3. Start call timer
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _callSeconds++;
        });
      }
    });

    // 4. Trigger the cellular phone call
    PhoneCallService.makeDirectCall(widget.lead.phoneNumber);
  }

  Future<void> _handleEndCall() async {
    setState(() => _isEndingCall = true);
    _timer.cancel();

    // Mandatory upload to server
    final uploadResult = await mandatoryRecorder.stopAndUploadRecording();

    if (mounted) {
      final recFileName = uploadResult['recordingFileName'] ?? 'rec_verified.wav';
      final duration = uploadResult['durationSeconds'] ?? _callSeconds;
      final localPath = uploadResult['localPath'] as String?;

      // Navigate to mandatory disposition screen with recording for instant playback
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => DispositionScreen(
            lead: widget.lead,
            recordingFileName: recFileName,
            durationSeconds: duration,
            prefilledNotes: _notesController.text,
            localAudioPath: localPath,
          ),
        ),
      );
    }
  }

  String _formatTimer(int secs) {
    final m = secs ~/ 60;
    final s = secs % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer.cancel();
    _pulseController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // Prevent telecaller from pressing back button to escape recording
      onWillPop: () async {
        if (_isEndingCall) return false;
        final shouldEnd = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('End Consultation Call?'),
            content: const Text(
              'Leaving will immediately stop the call and save the mandatory recording for quality review.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('Stay on Call'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.dangerRed),
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('End Call & Save'),
              ),
            ],
          ),
        );
        if (shouldEnd == true) {
          _handleEndCall();
        }
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF13151A),
        body: SafeArea(
          child: _isEndingCall
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(color: AppTheme.primaryGold),
                      const SizedBox(height: 20),
                      const Text(
                        'Encrypting & Uploading Recording...',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Linking to ${widget.lead.customerName} on Lemuria server',
                        style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Top Bar & Mandatory Badge
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.red.withOpacity(0.5)),
                            ),
                            child: Row(
                              children: [
                                FadeTransition(
                                  opacity: _pulseController,
                                  child: const CircleAvatar(radius: 4, backgroundColor: Colors.red),
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  'REC ACTIVE (MANDATORY)',
                                  style: TextStyle(
                                    color: Colors.redAccent,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            _formatTimer(_callSeconds),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Avatar & Patient Info
                    CircleAvatar(
                      radius: 42,
                      backgroundColor: AppTheme.primaryGold.withOpacity(0.2),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.primaryGold, width: 2),
                        ),
                        child: const Center(
                          child: Icon(Icons.person, size: 48, color: AppTheme.primaryGold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      widget.lead.customerName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'serif',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.lead.phoneNumber,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Condition Badge
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 32),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: Text(
                        widget.lead.painSummary,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: AppTheme.goldLight, fontSize: 12),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Speakerphone Guidance Tip for Dual Voice
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      margin: const EdgeInsets.symmetric(horizontal: 32),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGold.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppTheme.primaryGold.withOpacity(0.35)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.volume_up, color: AppTheme.goldLight, size: 16),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Tip: Turn on Speakerphone or use Headset to record both voices clearly',
                              style: TextStyle(color: Colors.white70, fontSize: 10.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Live Mic Equalizer Visualizer
                    AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, child) {
                        final val = _pulseController.value;
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          margin: const EdgeInsets.symmetric(horizontal: 32),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1F2430),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppTheme.hotGreen.withOpacity(0.5)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // 5-bar equalizer wave
                              ...List.generate(5, (index) {
                                final heights = [12.0 + 16.0 * val, 24.0 - 14.0 * val, 18.0 + 12.0 * val, 26.0 - 16.0 * val, 14.0 + 14.0 * val];
                                return Container(
                                  width: 4,
                                  height: heights[index],
                                  margin: const EdgeInsets.symmetric(horizontal: 2),
                                  decoration: BoxDecoration(
                                    color: AppTheme.hotGreen,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                );
                              }),
                              const SizedBox(width: 12),
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'RECORDER RUNNING',
                                    style: TextStyle(
                                      color: AppTheme.hotGreen,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  Text(
                                    'Dual-voice audio capturing live',
                                    style: TextStyle(color: Colors.white70, fontSize: 10),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),

                    // Direct SIM Call Indicator & Quick Re-Dial Button
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 32),
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.phone_in_talk, color: Colors.black, size: 18),
                        label: Text(
                          '📞 Tap to Call (${widget.lead.phoneNumber})',
                          style: const TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryGold,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                        ),
                        onPressed: () => PhoneCallService.makeDirectCall(widget.lead.phoneNumber),
                      ),
                    ),

                    const Spacer(),

                    // In-Call Live Notes Scratchpad
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: TextField(
                        controller: _notesController,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        maxLines: 2,
                        decoration: const InputDecoration(
                          hintText: 'Jot down patient symptoms during call...',
                          hintStyle: TextStyle(color: Colors.white38, fontSize: 12),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                      ),
                    ),

                    // In-Call Audio Controls
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _circleButton(
                            icon: _isMuted ? Icons.mic_off : Icons.mic,
                            label: _isMuted ? 'Muted' : 'Mute',
                            active: _isMuted,
                            onTap: () => setState(() => _isMuted = !_isMuted),
                          ),
                          _circleButton(
                            icon: _isSpeaker ? Icons.volume_up : Icons.volume_down,
                            label: 'Speaker',
                            active: _isSpeaker,
                            onTap: () => setState(() => _isSpeaker = !_isSpeaker),
                          ),
                        ],
                      ),
                    ),

                    // Big End Call Button
                    Padding(
                      padding: const EdgeInsets.only(left: 32, right: 32, bottom: 24),
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.call_end, size: 24, color: Colors.white),
                          label: const Text(
                            'END CALL & GENERATE REPORT',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.dangerRed,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: _handleEndCall,
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _circleButton({
    required IconData icon,
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(30),
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: active ? AppTheme.primaryGold : Colors.white.withOpacity(0.12),
            ),
            child: Icon(icon, color: active ? Colors.black : Colors.white, size: 24),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
      ],
    );
  }
}

