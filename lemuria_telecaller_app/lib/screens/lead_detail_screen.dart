import 'package:flutter/material.dart';
import '../models/lead_model.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/audio_player_card.dart';
import 'in_app_dialer_screen.dart';

class LeadDetailScreen extends StatelessWidget {
  final Lead lead;

  const LeadDetailScreen({super.key, required this.lead});

  Future<void> _sendQuickWhatsApp(BuildContext context, String actionType) async {
    final ok = await apiService.sendWhatsAppAction(
      phoneNumber: lead.phoneNumber,
      actionType: actionType,
      patientName: lead.customerName,
    );
    if (ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ WhatsApp $actionType sent to ${lead.phoneNumber}!'),
          backgroundColor: AppTheme.hotGreen,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final newStatusBg = LeadStatusConfig.getNewStatusBgColor(lead.newStatus);
    final newStatusFg = LeadStatusConfig.getNewStatusTextColor(lead.newStatus);
    final mainStatusColor = LeadStatusConfig.getMainStatusColor(lead.status);

    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      appBar: AppBar(
        title: Text(lead.customerName.isNotEmpty ? lead.customerName : 'Lead Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, size: 20),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Lead #${lead.sNo} exported to clipboard')),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardWhite,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SizedBox(
          height: 52,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.phone_in_talk, size: 20),
            label: const Text(
              'CALL (MANDATORY RECORDING)',
              style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, letterSpacing: 0.5),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.hotGreen,
              foregroundColor: Colors.white,
              elevation: 2,
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => InAppDialerScreen(lead: lead),
                ),
              );
            },
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Lead Header Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.cardWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.primaryGold.withOpacity(0.35)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: AppTheme.primaryGold.withOpacity(0.2),
                        child: Text(
                          lead.customerName.isNotEmpty ? lead.customerName[0].toUpperCase() : 'P',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.goldDark),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    lead.customerName.isNotEmpty ? lead.customerName : 'Patient (No Name)',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textMain,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppTheme.goldBg,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: AppTheme.primaryGold.withOpacity(0.5)),
                                  ),
                                  child: Text(
                                    'S.No #${lead.sNo}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.goldDark,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              lead.phoneNumber,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            if (lead.altNumber.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                'Alt: ${lead.altNumber}',
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 12,
                                  color: AppTheme.textMuted,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Divider(height: 1),
                  const SizedBox(height: 12),

                  // Pill Badges: New Status & Core Status
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      // Exact New Status Pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: newStatusBg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.black.withOpacity(0.12)),
                        ),
                        child: Text(
                          lead.newStatus,
                          style: TextStyle(
                            color: newStatusFg,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      // Core Status
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: mainStatusColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: mainStatusColor.withOpacity(0.6)),
                        ),
                        child: Text(
                          'Status: ${lead.status}',
                          style: TextStyle(
                            color: mainStatusColor,
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      // Follow-up count
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.bgCream,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.black.withOpacity(0.1)),
                        ),
                        child: Text(
                          'Follow-up #${lead.followUpCount}',
                          style: const TextStyle(
                            color: AppTheme.textMain,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 2. WhatsApp Instant Actions
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF86EFAC)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.chat, color: Color(0xFF15803D), size: 20),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      '1-Click WhatsApp Handoff',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF15803D)),
                    ),
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.school, size: 14, color: Color(0xFF15803D)),
                    label: const Text('Brochure', style: TextStyle(fontSize: 11, color: Color(0xFF15803D))),
                    onPressed: () => _sendQuickWhatsApp(context, 'COURSE_BROCHURE'),
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.location_on, size: 14, color: Color(0xFF15803D)),
                    label: const Text('Clinic Map', style: TextStyle(fontSize: 11, color: Color(0xFF15803D))),
                    onPressed: () => _sendQuickWhatsApp(context, 'LOCATION_PIN'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 3. Complete 19-Column CRM Fields Grid
            const Text(
              'Spreadsheet Record (19 Columns)',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textMain),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.cardWhite,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.black.withOpacity(0.06)),
              ),
              child: Column(
                children: [
                  _infoRow('Source of Contact', lead.source),
                  _infoRow('Reason for Contact', lead.reasonForContact),
                  _infoRow('Leads Reason', lead.leadsReason),
                  _infoRow('Location', lead.location),
                  _infoRow('Assigned Telecaller', lead.telecaller),
                  _infoRow('Lead Date', lead.leadDate.isNotEmpty ? lead.leadDate : '—'),
                  _infoRow('Last Call Date', lead.callDate.isNotEmpty ? lead.callDate : '—'),
                  _infoRow('Details / Caller Log', lead.details.isNotEmpty ? lead.details : '—'),
                  _infoRow('Entered By', lead.enteredBy.isNotEmpty ? lead.enteredBy : '—'),
                  _infoRow('New Leads Category', lead.newLeads.isNotEmpty ? lead.newLeads : '—'),
                  if (lead.remark.isNotEmpty) _infoRow('Remark', lead.remark),
                  if (lead.varmaVisitorNote.isNotEmpty) _infoRow('Varma Visitor Note', lead.varmaVisitorNote),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 4. Multi-Touchpoint Historical Timeline
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Multi-Touchpoint Timeline',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textMain),
                ),
                Text(
                  '${lead.interactions.length} interactions',
                  style: const TextStyle(fontSize: 11, color: AppTheme.textMuted, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),

            if (lead.interactions.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.cardWhite,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black.withOpacity(0.05)),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.history, color: AppTheme.textMuted, size: 28),
                    const SizedBox(height: 6),
                    Text(
                      'Initial contact registered by ${lead.telecaller} on ${lead.callDate.isNotEmpty ? lead.callDate : "earlier date"}.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: lead.interactions.length,
                itemBuilder: (ctx, idx) {
                  final inter = lead.interactions[idx];
                  final interBg = LeadStatusConfig.getNewStatusBgColor(inter.newStatus);
                  final interFg = LeadStatusConfig.getNewStatusTextColor(inter.newStatus);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.cardWhite,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.primaryGold.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.phone_callback, size: 14, color: AppTheme.goldDark),
                                const SizedBox(width: 6),
                                Text(
                                  inter.date,
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.textMain),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: interBg,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                inter.newStatus,
                                style: TextStyle(color: interFg, fontSize: 10.5, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Text(
                              'Telecaller: ${inter.telecaller}',
                              style: const TextStyle(fontSize: 11.5, color: AppTheme.textSecondary, fontWeight: FontWeight.w600),
                            ),
                            const Spacer(),
                            Text(
                              'Reason: ${inter.reasonForContact}',
                              style: const TextStyle(fontSize: 11.5, color: AppTheme.goldDark, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        if (inter.details.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppTheme.bgCream,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              inter.details,
                              style: const TextStyle(fontSize: 11.5, color: AppTheme.textMain, fontStyle: FontStyle.italic),
                            ),
                          ),
                        ],
                        if (inter.audioFileName != null && inter.audioFileName!.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          AudioPlayerCard(
                            title: 'Recording: ${inter.date}',
                            audioFileName: inter.audioFileName,
                            durationSeconds: inter.durationSeconds,
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 12.5,
                color: AppTheme.textMain,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
