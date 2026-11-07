import 'package:flutter/material.dart';
import '../models/lead_model.dart';
import '../theme/app_theme.dart';
import 'in_app_dialer_screen.dart';

class DialpadScreen extends StatefulWidget {
  const DialpadScreen({super.key});

  @override
  State<DialpadScreen> createState() => _DialpadScreenState();
}

class _DialpadScreenState extends State<DialpadScreen> {
  String _phoneNumber = '';
  final TextEditingController _nameController = TextEditingController();

  void _onKeyPress(String val) {
    if (_phoneNumber.length < 15) {
      setState(() {
        _phoneNumber += val;
      });
    }
  }

  void _onBackspace() {
    if (_phoneNumber.isNotEmpty) {
      setState(() {
        _phoneNumber = _phoneNumber.substring(0, _phoneNumber.length - 1);
      });
    }
  }

  void _onClear() {
    setState(() {
      _phoneNumber = '';
    });
  }

  void _initiateCall() {
    final clean = _phoneNumber.trim();
    if (clean.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid phone number (at least 8-10 digits).'),
          backgroundColor: AppTheme.dangerRed,
        ),
      );
      return;
    }

    final custName = _nameController.text.trim().isNotEmpty
        ? _nameController.text.trim()
        : 'Outbound Contact ($clean)';

    final manualLead = Lead(
      id: 'manual_${DateTime.now().millisecondsSinceEpoch}',
      sNo: 999,
      customerName: custName,
      phoneNumber: clean.startsWith('+') ? clean : '+91 $clean',
      details: 'Direct outbound telecaller consultation call.',
      newStatus: 'On Discussion-(OD)',
      status: 'interested',
      reasonForContact: 'Therapy',
      telecaller: 'Sudha',
    );

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => InAppDialerScreen(lead: manualLead),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      appBar: AppBar(
        title: const Text('Manual Phone Dialer'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Mandatory Recording Indicator
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.goldBg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.primaryGold.withOpacity(0.35)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.fiber_manual_record, color: Colors.red, size: 12),
                  SizedBox(width: 6),
                  Text(
                    'Mandatory In-App Dual Call Recording Enforced',
                    style: TextStyle(
                      color: AppTheme.goldDark,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Customer Name (Optional field)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
              child: TextField(
                controller: _nameController,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  hintText: 'Customer / Patient Name (Optional)',
                  hintStyle: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                  prefixIcon: const Icon(Icons.person_outline, size: 18, color: AppTheme.primaryGold),
                  filled: true,
                  fillColor: AppTheme.cardWhite,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  isDense: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.black.withOpacity(0.08)),
                  ),
                ),
              ),
            ),

            // Number Display Box
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppTheme.cardWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.primaryGold.withOpacity(0.4)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Text(
                    '+91 ',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.goldDark,
                      fontFamily: 'monospace',
                    ),
                  ),
                  Expanded(
                    child: Text(
                      _phoneNumber.isEmpty ? 'Enter Phone Number' : _phoneNumber,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: _phoneNumber.isEmpty ? AppTheme.textMuted : AppTheme.textMain,
                        fontFamily: 'monospace',
                        letterSpacing: 1.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (_phoneNumber.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.backspace_outlined, color: AppTheme.goldDark, size: 22),
                      onPressed: _onBackspace,
                    ),
                ],
              ),
            ),

            const Spacer(),

            // Keypad Grid (1-9, *, 0, #)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 36),
              child: Column(
                children: [
                  _keypadRow(['1', '2', '3'], ['', 'ABC', 'DEF']),
                  const SizedBox(height: 12),
                  _keypadRow(['4', '5', '6'], ['GHI', 'JKL', 'MNO']),
                  const SizedBox(height: 12),
                  _keypadRow(['7', '8', '9'], ['PQRS', 'TUV', 'WXYZ']),
                  const SizedBox(height: 12),
                  _keypadRow(['*', '0', '#'], ['', '+', '']),
                ],
              ),
            ),

            const Spacer(),

            // Big Call Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.phone_in_talk, size: 24, color: Colors.white),
                  label: const Text(
                    'CALL THIS NUMBER (RECORDED)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.hotGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 3,
                  ),
                  onPressed: _phoneNumber.isEmpty ? null : _initiateCall,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _keypadRow(List<String> digits, List<String> subtitles) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(3, (i) {
        return _keypadButton(digits[i], subtitles[i]);
      }),
    );
  }

  Widget _keypadButton(String digit, String subtitle) {
    return InkWell(
      onTap: () => _onKeyPress(digit),
      onLongPress: () {
        if (digit == '0') _onKeyPress('+');
      },
      borderRadius: BorderRadius.circular(35),
      child: Container(
        width: 68,
        height: 68,
        decoration: BoxDecoration(
          color: AppTheme.cardWhite,
          shape: BoxShape.circle,
          border: Border.all(color: AppTheme.primaryGold.withOpacity(0.25)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              digit,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.textMain,
              ),
            ),
            if (subtitle.isNotEmpty)
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textMuted,
                  letterSpacing: 1,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

