import 'package:flutter/material.dart';
import '../models/lead_model.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/audio_player_card.dart';
import 'in_app_dialer_screen.dart';

class CallHistoryScreen extends StatefulWidget {
  const CallHistoryScreen({super.key});

  @override
  State<CallHistoryScreen> createState() => _CallHistoryScreenState();
}

class _CallHistoryScreenState extends State<CallHistoryScreen> {
  List<Lead> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    final leads = await apiService.fetchLeads();
    setState(() {
      _history = leads.where((l) => l.durationSeconds > 0 || l.audioFileName != null).toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      appBar: AppBar(
        title: const Text('Call Recordings & Logs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadHistory,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadHistory,
        color: AppTheme.primaryGold,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryGold))
            : _history.isEmpty
                ? const Center(
                    child: Text('No call recordings logged yet.'),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _history.length,
                    itemBuilder: (context, index) {
                      final call = _history[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      call.customerName,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.textMain,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    '${call.durationSeconds}s',
                                    style: const TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.goldDark,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                call.phoneNumber,
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 12,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 8),

                              // Outcome Badge
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: call.isHotLead ? AppTheme.hotGreenBg : AppTheme.goldBg,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: call.isHotLead ? AppTheme.hotGreen.withOpacity(0.4) : AppTheme.primaryGold.withOpacity(0.3),
                                  ),
                                ),
                                child: Text(
                                  call.outcomeLabel,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: call.isHotLead ? AppTheme.hotGreen : AppTheme.goldDark,
                                  ),
                                ),
                              ),
                              if (call.audioFileName != null && call.audioFileName!.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                AudioPlayerCard(
                                  title: 'Recording: ${call.customerName}',
                                  audioFileName: call.audioFileName,
                                  durationSeconds: call.durationSeconds,
                                ),
                              ],
                              const SizedBox(height: 10),

                              // Recording audio tag
                              Row(
                                children: [
                                  const Icon(Icons.mic, color: AppTheme.hotGreen, size: 16),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      call.audioFileName != null
                                          ? 'Verified Dual WAV: ${call.audioFileName}'
                                          : 'Transcript logged (Quality audit)',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppTheme.textMuted,
                                        fontStyle: FontStyle.italic,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.phone_forwarded, color: AppTheme.hotGreen, size: 18),
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => InAppDialerScreen(lead: call),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}

