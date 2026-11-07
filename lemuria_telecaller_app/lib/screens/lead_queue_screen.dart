import 'dart:async';
import 'package:flutter/material.dart';
import '../models/lead_model.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import 'dialpad_screen.dart';
import 'in_app_dialer_screen.dart';
import 'lead_detail_screen.dart';
import 'login_screen.dart';

class LeadQueueScreen extends StatefulWidget {
  const LeadQueueScreen({super.key});

  @override
  State<LeadQueueScreen> createState() => _LeadQueueScreenState();
}

class _LeadQueueScreenState extends State<LeadQueueScreen> {
  List<Lead> _allLeads = [];
  bool _isLoading = true;
  String _selectedPillFilter = 'ALL';
  String _selectedDateFilter = 'ALL';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  bool _isBannerExpanded = true;
  Timer? _autoHideTimer;

  final List<String> _dateOptions = [
    'ALL',
    'March 2026',
    'April 2026',
    'Oct 2026',
    'Jan 2026',
    'Nov 2025',
    'Dec 2025',
  ];

  @override
  void initState() {
    super.initState();
    _loadLeads();

    // Show initially, then automatically collapse after 3.5s to free up CRM queue screen space
    _autoHideTimer = Timer(const Duration(milliseconds: 3500), () {
      if (mounted && _isBannerExpanded) {
        setState(() => _isBannerExpanded = false);
      }
    });
  }

  @override
  void dispose() {
    _autoHideTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadLeads() async {
    setState(() => _isLoading = true);
    final leads = await apiService.fetchLeads();
    setState(() {
      _allLeads = leads;
      _isLoading = false;
    });
  }

  List<Lead> get _filteredLeads {
    return _allLeads.where((lead) {
      // 1. New Status Pill Filter
      if (_selectedPillFilter != 'ALL') {
        if (_selectedPillFilter == 'HOT') {
          if (!lead.isHotLead) return false;
        } else if (lead.newStatus != _selectedPillFilter) {
          return false;
        }
      }

      // 2. Date Filter
      if (_selectedDateFilter != 'ALL') {
        final d = lead.callDate.isNotEmpty ? lead.callDate : lead.leadDate;
        if (_selectedDateFilter == 'March 2026' && !d.contains('03-2026')) return false;
        if (_selectedDateFilter == 'April 2026' && !d.contains('04-2026')) return false;
        if (_selectedDateFilter == 'Oct 2026' && !d.contains('10-2026')) return false;
        if (_selectedDateFilter == 'Jan 2026' && !d.contains('01-2026')) return false;
        if (_selectedDateFilter == 'Nov 2025' && !d.contains('11-2025')) return false;
        if (_selectedDateFilter == 'Dec 2025' && !d.contains('12-2025')) return false;
      }

      // 3. Search query
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchName = lead.customerName.toLowerCase().contains(q);
        final matchPhone = lead.phoneNumber.contains(q) || lead.altNumber.contains(q);
        final matchLoc = lead.location.toLowerCase().contains(q);
        final matchReason = lead.reasonForContact.toLowerCase().contains(q);
        final matchTelecaller = lead.telecaller.toLowerCase().contains(q);
        final matchDetails = lead.details.toLowerCase().contains(q);
        return matchName || matchPhone || matchLoc || matchReason || matchTelecaller || matchDetails;
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final rep = apiService.currentTelecaller;

    return Scaffold(
      backgroundColor: AppTheme.bgCream,
      appBar: AppBar(
        title: const Text('Lemuria Telecaller Queue'),
        actions: [
          IconButton(
            icon: const Icon(Icons.dialpad, color: AppTheme.goldDark),
            tooltip: 'Manual Keypad Dialer',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const DialpadScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadLeads,
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: AppTheme.textMuted, size: 20),
            tooltip: 'Switch Telecaller Line',
            onPressed: () {
              apiService.logout();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTheme.primaryGold,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.dialpad, size: 20),
        label: const Text('Dial Any Number', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const DialpadScreen()),
          );
        },
      ),
      body: RefreshIndicator(
        onRefresh: _loadLeads,
        color: AppTheme.primaryGold,
        child: Column(
          children: [
            // Collapsible Rep Profile Header & Compliance Banner (Auto-collapses to save space)
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 320),
              crossFadeState: _isBannerExpanded
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              // Full Banner View (shown at first, then minimized)
              firstChild: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2D241E), Color(0xFF1E1B18)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: AppTheme.primaryGold.withOpacity(0.3),
                          child: Text(
                            rep?.avatar ?? '👩‍⚕️',
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                rep?.name ?? 'Sudha',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                rep?.line ?? 'Line 02 (+91 80562 94950)',
                                style: const TextStyle(
                                  color: AppTheme.goldLight,
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                rep?.role == 'Super Administrator'
                                    ? '👑 Master Queue (${_allLeads.length} leads across all reps)'
                                    : '📋 Assigned Queue: ${_allLeads.length} Leads for ${rep?.name}',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.hotGreen.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppTheme.hotGreen),
                          ),
                          child: const Row(
                            children: [
                              CircleAvatar(radius: 3, backgroundColor: AppTheme.hotGreen),
                              SizedBox(width: 5),
                              Text(
                                'Line Active',
                                style: TextStyle(
                                  color: AppTheme.hotGreen,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        // Manual minimize button
                        IconButton(
                          icon: const Icon(Icons.keyboard_arrow_up, color: Colors.white70, size: 20),
                          tooltip: 'Minimize Banner',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {
                            _autoHideTimer?.cancel();
                            setState(() => _isBannerExpanded = false);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.35),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.primaryGold.withOpacity(0.4)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.verified_user, color: AppTheme.goldLight, size: 13),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Mandatory In-App Dual Recording Active (Quality Assurance)',
                              style: TextStyle(color: Colors.white70, fontSize: 10),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Compact, Sleek 1-Line Status Strip (Saves over 110px vertical space)
              secondChild: GestureDetector(
                onTap: () => setState(() => _isBannerExpanded = true),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.cardWhite,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppTheme.primaryGold.withOpacity(0.35)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Text(rep?.avatar ?? '👩‍⚕️', style: const TextStyle(fontSize: 14)),
                      const SizedBox(width: 6),
                      Text(
                        rep?.name ?? 'Sudha',
                        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, color: AppTheme.textMain),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.hotGreen.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(
                          children: [
                            CircleAvatar(radius: 2.5, backgroundColor: AppTheme.hotGreen),
                            SizedBox(width: 3),
                            Text('Active', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: AppTheme.hotGreen)),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          const Icon(Icons.fiber_manual_record, size: 8, color: Colors.red),
                          const SizedBox(width: 4),
                          Text(
                            'REC Mandatory (${_allLeads.length} leads)',
                            style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: AppTheme.goldDark),
                          ),
                        ],
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.keyboard_arrow_down, size: 16, color: AppTheme.textMuted),
                    ],
                  ),
                ),
              ),
            ),

            // Search Bar & Date Filter Dropdown
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(fontSize: 12.5),
                      decoration: InputDecoration(
                        hintText: 'Search Name, Phone, Location, Reason...',
                        hintStyle: const TextStyle(fontSize: 11.5, color: AppTheme.textMuted),
                        prefixIcon: const Icon(Icons.search, size: 18, color: AppTheme.goldDark),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 16),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: AppTheme.cardWhite,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.black.withOpacity(0.08)),
                        ),
                      ),
                      onChanged: (val) => setState(() => _searchQuery = val.trim()),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.cardWhite,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.black.withOpacity(0.08)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedDateFilter,
                        icon: const Icon(Icons.filter_alt_outlined, size: 16, color: AppTheme.goldDark),
                        style: const TextStyle(fontSize: 11.5, color: AppTheme.textMain, fontWeight: FontWeight.bold),
                        items: _dateOptions.map((d) {
                          return DropdownMenuItem(value: d, child: Text(d));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedDateFilter = val);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Horizontal Status Pills Filter Bar
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                children: [
                  _pillFilterChip('All Leads (${_allLeads.length})', 'ALL'),
                  const SizedBox(width: 6),
                  _pillFilterChip(
                    '🔥 Hot (${_allLeads.where((l) => l.isHotLead).length})',
                    'HOT',
                  ),
                  const SizedBox(width: 6),
                  ...LeadStatusConfig.allNewStatuses.map((pill) {
                    final count = _allLeads.where((l) => l.newStatus == pill).length;
                    if (count == 0 && _selectedPillFilter != pill) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(right: 6.0),
                      child: _pillFilterChip('$pill ($count)', pill),
                    );
                  }),
                ],
              ),
            ),

            // Leads List
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppTheme.primaryGold),
                    )
                  : _filteredLeads.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.search_off, size: 38, color: AppTheme.textMuted),
                              const SizedBox(height: 8),
                              const Text('No leads match the selected filter/search.',
                                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _selectedPillFilter = 'ALL';
                                    _selectedDateFilter = 'ALL';
                                    _searchController.clear();
                                    _searchQuery = '';
                                  });
                                },
                                child: const Text('Reset All Filters'),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          itemCount: _filteredLeads.length,
                          itemBuilder: (context, index) {
                            final lead = _filteredLeads[index];
                            return _buildLeadCard(lead);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pillFilterChip(String label, String value) {
    final selected = _selectedPillFilter == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      selectedColor: AppTheme.primaryGold.withOpacity(0.25),
      backgroundColor: AppTheme.cardWhite,
      labelStyle: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: selected ? AppTheme.goldDark : AppTheme.textSecondary,
      ),
      side: BorderSide(
        color: selected ? AppTheme.goldDark : Colors.black.withOpacity(0.08),
      ),
      onSelected: (_) => setState(() => _selectedPillFilter = value),
    );
  }

  Widget _buildLeadCard(Lead lead) {
    final newStatusBg = LeadStatusConfig.getNewStatusBgColor(lead.newStatus);
    final newStatusFg = LeadStatusConfig.getNewStatusTextColor(lead.newStatus);
    final mainStatusColor = LeadStatusConfig.getMainStatusColor(lead.status);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => LeadDetailScreen(lead: lead)),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: S.No + Name + Phone + New Status Pill
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // S.No Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.goldBg,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppTheme.primaryGold.withOpacity(0.4)),
                    ),
                    child: Text(
                      '#${lead.sNo}',
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.goldDark,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Name & Phone
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lead.customerName.isNotEmpty ? lead.customerName : 'Patient (No Name)',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textMain,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          lead.phoneNumber,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Exact New Status Pill
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: newStatusBg,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.black.withOpacity(0.1)),
                    ),
                    child: Text(
                      lead.newStatus,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        color: newStatusFg,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Details snippet / Caller log
              if (lead.details.isNotEmpty) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.bgCream,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.black.withOpacity(0.04)),
                  ),
                  child: Text(
                    '📝 ${lead.details}',
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: AppTheme.textMain,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 8),
              ],

              // Tag Badges: Reason, Location, Telecaller, Follow-up
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  _tagBadge('🎯 ${lead.reasonForContact}', AppTheme.primaryGold.withOpacity(0.15), AppTheme.goldDark),
                  _tagBadge('📍 ${lead.location}', Colors.black.withOpacity(0.05), AppTheme.textSecondary),
                  _tagBadge('📞 #${lead.followUpCount}', AppTheme.bgCream, AppTheme.textMain),
                  _tagBadge('👤 ${lead.telecaller}', Colors.black.withOpacity(0.04), AppTheme.textMuted),
                  _tagBadge(lead.status, mainStatusColor.withOpacity(0.12), mainStatusColor),
                ],
              ),
              const SizedBox(height: 12),

              // Action Buttons: Call (Recorded) + Inspect
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.phone_in_talk, size: 15),
                      label: const Text('Call Patient (Recorded)', style: TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.hotGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 9),
                        elevation: 0,
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
                  const SizedBox(width: 8),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                      side: BorderSide(color: AppTheme.primaryGold.withOpacity(0.5)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Inspect', style: TextStyle(color: AppTheme.goldDark, fontSize: 12)),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => LeadDetailScreen(lead: lead)),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tagBadge(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: fg),
      ),
    );
  }
}
