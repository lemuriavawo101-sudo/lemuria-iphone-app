import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'main_crm_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameController = TextEditingController(text: 'sudha');
  final _pinController = TextEditingController(text: '3210');
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    if (!kIsWeb) {
      try {
        await [
          Permission.microphone,
          Permission.phone,
        ].request();
      } catch (e) {
        debugPrint('Permission request error: $e');
      }
    }
  }

  Future<void> _handleLogin() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final res = await apiService.login(
      _usernameController.text,
      _pinController.text,
    );

    setState(() {
      _isLoading = false;
    });

    if (res['success'] == true && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainCrmScreen()),
      );
    } else {
      setState(() {
        _errorMessage = res['error'] ?? 'Login failed. Please check username & PIN.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Luxury Gold Logo Emblem
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.goldDark, AppTheme.primaryGold],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryGold.withOpacity(0.35),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'L',
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'serif',
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'LEMURIA',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3,
                    color: AppTheme.textMain,
                    fontFamily: 'serif',
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Telecaller & Quality Compliance Suite',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: AppTheme.goldDark,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 36),

                // Login Card
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.cardWhite,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.primaryGold.withOpacity(0.3)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Telecaller Access',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textMain,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Enter assigned username and secret PIN',
                        style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                      ),
                      const SizedBox(height: 20),

                      // Username Input
                      TextField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Telecaller Username',
                          prefixIcon: Icon(Icons.person_outline, color: AppTheme.primaryGold),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // PIN Input
                      TextField(
                        controller: _pinController,
                        obscureText: true,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Security PIN',
                          prefixIcon: Icon(Icons.lock_outline, color: AppTheme.primaryGold),
                        ),
                      ),
                      const SizedBox(height: 14),

                      if (_errorMessage != null)
                        Container(
                          padding: const EdgeInsets.all(10),
                          margin: const EdgeInsets.only(bottom: 14),
                          decoration: BoxDecoration(
                            color: AppTheme.dangerRedBg,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppTheme.dangerRed.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline, color: AppTheme.dangerRed, size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: const TextStyle(color: AppTheme.dangerRed, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Login Button
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryGold,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                              : const Text(
                                  'Sign In to Telecaller Line ➔',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Quick Telecaller Line Selector',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textMuted,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),

                // Quick Telecaller Chips
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    _quickUserChip('👩‍💼 Kowsaliya (8 Leads)', 'kowsaliya', '1111'),
                    _quickUserChip('👨‍🏫 Shafeeq (11 Leads)', 'shafeeq', '2222'),
                    _quickUserChip('👩‍⚕️ Sudha (3 Leads)', 'sudha', '3210'),
                    _quickUserChip('👑 Admin (All 22)', 'admin', '9999'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _quickUserChip(String label, String username, String pin) {
    final isCurrent = _usernameController.text == username;
    return ActionChip(
      label: Text(label, style: TextStyle(
        fontSize: 11,
        fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
        color: isCurrent ? AppTheme.goldDark : AppTheme.textMain,
      )),
      backgroundColor: isCurrent ? AppTheme.primaryGold.withOpacity(0.25) : AppTheme.goldBg,
      side: BorderSide(
        color: isCurrent ? AppTheme.goldDark : AppTheme.primaryGold.withOpacity(0.3),
        width: isCurrent ? 1.5 : 1,
      ),
      onPressed: () {
        setState(() {
          _usernameController.text = username;
          _pinController.text = pin;
        });
      },
    );
  }
}

