import 'package:flutter/material.dart';
import '../models/lead_model.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/audio_player_card.dart';
import 'main_crm_screen.dart';

class DispositionScreen extends StatefulWidget {
  final Lead lead;
  final String recordingFileName;
  final int durationSeconds;
  final String prefilledNotes;
  final String? localAudioPath;

  const DispositionScreen({
    super.key,
    required this.lead,
    required this.recordingFileName,
    required this.durationSeconds,
    this.prefilledNotes = '',
    this.localAudioPath,
  });

  @override
  State<DispositionScreen> createState() => _DispositionScreenState();
}

class _DispositionScreenState extends State<DispositionScreen> {
  late String _selectedNewStatus;
  late String _selectedMainStatus;
  late String _selectedReason;
  late TextEditingController _detailsController;
  late TextEditingController _altNumberController;
  late TextEditingController _locationController;
  late TextEditingController _remarkController;
  late TextEditingController _varmaNoteController;

  bool _isSaving = false;
  bool _whatsAppSent = false;

  @override
  void initState() {
    super.initState();
    _selectedNewStatus = widget.lead.newStatus.isNotEmpty
        ? widget.lead.newStatus
        : 'On Discussion-(OD)';
    _selectedMainStatus = widget.lead.status.isNotEmpty
        ? widget.lead.status
        : 'interested';
    _selectedReason = widget.lead.reasonForContact.isNotEmpty
        ? widget.lead.reasonForContact
        : 'Therapy';

    _detailsController = TextEditingController(
      text: widget.prefilledNotes.isNotEmpty
          ? widget.prefilledNotes
          : widget.lead.details,
    );
    _altNumberController = TextEditingController(text: widget.lead.altNumber);
    _locationController = TextEditingController(text: widget.lead.location);
    _remarkController = TextEditingController(text: widget.lead.remark);
    _varmaNoteController = TextEditingController(text: widget.lead.varmaVisitorNote);
  }

  @override
  void dispose() {
    _detailsController.dispose();
    _altNumberController.dispose();
    _locationController.dispose();
    _remarkController.dispose();
    _varmaNoteController.dispose();
    super.dispose();
  }

  Future<void> _handleSaveDisposition() async {
    setState(() => _isSaving = true);

    final success = await apiService.submitDisposition(
      phoneNumber: widget.lead.phoneNumber,
      customerName: widget.lead.customerName,
      status: _selectedMainStatus,
      newStatus: _selectedNewStatus,
      reasonForContact: _selectedReason,
      details: _detailsController.text.trim(),
      altNumber: _altNumberController.text.trim(),
      location: _locationController.text.trim(),
      remark: _remarkController.text.trim(),
      varmaVisitorNote: _varmaNoteController.text.trim(),
      sNo: widget.lead.sNo,
      recordingFileName: widget.recordingFileName,
      durationSeconds: widget.durationSeconds,
    );

    setState(() => _isSaving = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 Call disposition saved & appended to lead history!'),
          backgroundColor: AppTheme.hotGreen,
        ),
      );
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainCrmScreen()),
        (route) => false,
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save disposition. Please verify connection.'),
          backgroundColor: AppTheme.dangerRed,
        ),
      );
    }
  }

  Future<void> _sendWhatsAppAction(String actionType) async {
    final ok = await apiService.sendWhatsAppAction(
      phoneNumber: widget.lead.phoneNumber,
      actionType: actionType,
      patientName: widget.lead.customerName,
    );
    if (ok && mounted) {
      setState(() => _whatsAppSent = true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ WhatsApp $actionType sent to ${widget.lead.phoneNumber}!'),
          backgroundColor: AppTheme.hotGreen,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Strictly mandatory disposition
      child: Scaffold(
        backgroundColor: AppTheme.bgCream,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text('Post-Call Disposition (Mandatory)'),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Call Summary & Verified Recording Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.cardWhite,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.primaryGold.withOpacity(0.35)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.lead.customerName.isNotEmpty
                                      ? widget.lead.customerName
                                      : 'Patient (${widget.lead.phoneNumber})',
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.textMain,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  widget.lead.phoneNumber,
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 12.5,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryGold.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Duration: ${widget.durationSeconds}s',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.goldDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Interactive Call Recording Playback
                      AudioPlayerCard(
                        title: 'Listen to Call Recording',
                        audioFileName: widget.recordingFileName,
                        localAudioPath: widget.localAudioPath,
                        durationSeconds: widget.durationSeconds,
                      ),
                      const SizedBox(height: 8),
                      // Verified Audio File Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                        decoration: BoxDecoration(
                          color: AppTheme.hotGreenBg,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.hotGreen.withOpacity(0.4)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.verified, color: AppTheme.hotGreen, size: 16),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Audio Verified & Locked: ${widget.recordingFileName}',
                                style: const TextStyle(
                                  color: AppTheme.hotGreen,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 2. Exact 9 "New Status" Pills from Reference
                const Row(
                  children: [
                    Text(
                      'New status (Select 1 pill)',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textMain),
                    ),
                    Text(' *', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: LeadStatusConfig.allNewStatuses.map((pill) {
                    final isSelected = _selectedNewStatus == pill;
                    final bg = LeadStatusConfig.getNewStatusBgColor(pill);
                    final fg = LeadStatusConfig.getNewStatusTextColor(pill);

                    return GestureDetector(
                      onTap: () => setState(() => _selectedNewStatus = pill),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                        decoration: BoxDecoration(
                          color: bg,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: isSelected ? Colors.black : Colors.black.withOpacity(0.12),
                            width: isSelected ? 2.2 : 0.8,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isSelected) ...[
                              Icon(Icons.check, size: 14, color: fg),
                              const SizedBox(width: 5),
                            ],
                            Text(
                              pill,
                              style: TextStyle(
                                color: fg,
                                fontSize: 12.5,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // 3. Strict 6 "Status" Choices
                const Row(
                  children: [
                    Text(
                      'Status (CRM Core Status)',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textMain),
                    ),
                    Text(' *', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: LeadStatusConfig.allMainStatuses.map((st) {
                    final isSelected = _selectedMainStatus == st;
                    return ChoiceChip(
                      label: Text(st),
                      selected: isSelected,
                      selectedColor: AppTheme.primaryGold.withOpacity(0.25),
                      backgroundColor: AppTheme.cardWhite,
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? AppTheme.goldDark : AppTheme.textSecondary,
                      ),
                      side: BorderSide(
                        color: isSelected ? AppTheme.goldDark : Colors.black.withOpacity(0.12),
                        width: isSelected ? 1.5 : 1,
                      ),
                      onSelected: (_) => setState(() => _selectedMainStatus = st),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // 4. Reason for Contact Dropdown
                const Text(
                  'Reason for contact',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textMain),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: AppTheme.cardWhite,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.primaryGold.withOpacity(0.3)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedReason,
                      isExpanded: true,
                      items: LeadStatusConfig.allContactReasons.map((r) {
                        return DropdownMenuItem(value: r, child: Text(r, style: const TextStyle(fontSize: 13)));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedReason = val);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // 5. Details / Telecaller Log Notes
                const Text(
                  'Details / Call Notes',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textMain),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _detailsController,
                  maxLines: 3,
                  style: const TextStyle(fontSize: 13),
                  decoration: const InputDecoration(
                    hintText: 'e.g. Switch off / Not Rechable / Patient requested weekend slot / Discussed pain',
                  ),
                ),
                const SizedBox(height: 18),

                // 6. Alternative Number & Location (Row)
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Alternative Number',
                            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppTheme.textMain),
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _altNumberController,
                            keyboardType: TextInputType.phone,
                            style: const TextStyle(fontSize: 12.5),
                            decoration: const InputDecoration(
                              hintText: 'Alt Phone Number',
                              isDense: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Location',
                            style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: AppTheme.textMain),
                          ),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _locationController,
                            style: const TextStyle(fontSize: 12.5),
                            decoration: const InputDecoration(
                              hintText: 'e.g. Chennai, Coimbatore',
                              isDense: true,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // 7. Remark & Varma Visitor Note
                const Text(
                  'Remark',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textMain),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _remarkController,
                  style: const TextStyle(fontSize: 12.5),
                  decoration: const InputDecoration(
                    hintText: 'Additional telecaller remark',
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 16),

                const Text(
                  'Varma Visitor Note',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppTheme.textMain),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _varmaNoteController,
                  style: const TextStyle(fontSize: 12.5),
                  decoration: const InputDecoration(
                    hintText: 'Clinical or visit notes',
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 22),

                // 8. 1-Click WhatsApp Follow-up Section
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF86EFAC)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.chat, color: Color(0xFF15803D), size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Instant WhatsApp Handoff (Lemuria Official)',
                            style: TextStyle(
                              color: Color(0xFF15803D),
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.location_on, size: 15, color: Color(0xFF15803D)),
                              label: const Text('Send Clinic Pin', style: TextStyle(fontSize: 11, color: Color(0xFF15803D))),
                              onPressed: () => _sendWhatsAppAction('LOCATION_PIN'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(Icons.school, size: 15, color: Color(0xFF15803D)),
                              label: const Text('Send Brochure', style: TextStyle(fontSize: 11, color: Color(0xFF15803D))),
                              onPressed: () => _sendWhatsAppAction('COURSE_BROCHURE'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _handleSaveDisposition,
                    child: _isSaving
                        ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                        : const Text(
                            'SAVE DISPOSITION & NEXT LEAD ➔',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
