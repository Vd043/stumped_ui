import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/supabase_config.dart';
import 'data/match_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize Supabase whenever URL looks like a real project (not placeholder)
  if (SupabaseConfig.url.contains('supabase.co') &&
      SupabaseConfig.anonKey.isNotEmpty &&
      !SupabaseConfig.anonKey.startsWith('YOUR_')) {
    try {
      await Supabase.initialize(
        url: SupabaseConfig.url,
        anonKey: SupabaseConfig.anonKey,
      );
    } catch (_) {
      // If init fails (e.g. bad key), app still runs; Match History will show the error
    }
  }
  runApp(const StumpedApp());
}

class StumpedApp extends StatelessWidget {
  const StumpedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'STUMPED',
      theme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'SF Pro Display',
        scaffoldBackgroundColor: const Color(0xFF021A10),
      ),
      home: const SplashScreen(),
    );
  }
}

/// SCREEN 1 - Landing / Initialize Match
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF06351E),
              Color(0xFF02140C),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(height: 32),
              Column(
                children: const [
                  Text(
                    'THE GENTLEMAN\'S GAME',
                    style: TextStyle(
                      color: Color(0xFFB9C5B8),
                      letterSpacing: 3,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'STUMPED',
                    style: TextStyle(
                      color: Color(0xFFF9D96B),
                      fontSize: 40,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 3,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Precision scoring for the modern\nelite.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFFBEC7C0),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              // Cricket ball hero image placeholder
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 32),
                height: 220,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(24),
                  image: const DecorationImage(
                    image: AssetImage(
                        'assets/images/Screenshot 2026-01-27 at 8.58.30 PM.png'),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 32,
                      offset: const Offset(0, 24),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: 32,
                  right: 32,
                  bottom: 40,
                ),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: const Color(0xFF0D2F20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 18,
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const SetupMatchScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'Initialize Match',
                          style: TextStyle(
                            color: Color(0xFFF9D96B),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFBEC7C0),
                          side: const BorderSide(color: Color(0xFF3D4A3E)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(32),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const MatchHistoryScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.history, size: 20),
                        label: const Text(
                          'Match history',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'DESIGNED FOR ELITES',
                      style: TextStyle(
                        color: Color(0xFF5E6A5F),
                        fontSize: 10,
                        letterSpacing: 3,
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
}

/// Match history list (from Supabase).
class MatchHistoryScreen extends StatefulWidget {
  const MatchHistoryScreen({super.key});

  @override
  State<MatchHistoryScreen> createState() => _MatchHistoryScreenState();
}

class _MatchHistoryScreenState extends State<MatchHistoryScreen> {
  List<MatchSummary>? _matches;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final list = await MatchRepository().getMatchHistory(limit: 50);
      if (mounted) setState(() {
        _matches = list;
        _loading = false;
      });
    } catch (e, st) {
      if (mounted) setState(() {
        _error = _formatHistoryError(e);
        _matches = [];
        _loading = false;
      });
      debugPrint('MatchHistory load error: $e\n$st');
    }
  }

  static String _formatHistoryError(Object e) {
    final s = e.toString().toLowerCase();
    if (s.contains('failed host lookup') ||
        s.contains('no address associated with hostname') ||
        s.contains('network is unreachable') ||
        s.contains('socketexception') ||
        s.contains('connection refused')) {
      return 'No internet or connection problem.\nCheck Wi‑Fi or mobile data and try again.';
    }
    if (s.contains('401') || s.contains('unauthorized') || s.contains('invalid api key')) {
      return 'Invalid Supabase API key.\nCheck Settings → API in your Supabase project.';
    }
    return e.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF06351E), Color(0xFF02140C)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const Expanded(
                      child: Text(
                        'MATCH HISTORY',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFFF9D96B),
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _loading ? null : _load,
                      icon: const Icon(
                          Icons.refresh, color: Color(0xFFBEC7C0)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _loading
                    ? const Center(
                        child: CircularProgressIndicator(color: Color(0xFFF9D96B)),
                      )
                        : _error != null
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.cloud_off_outlined,
                                    size: 48,
                                    color: Colors.white.withOpacity(0.3),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _error!,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Color(0xFFBEC7C0),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : _matches!.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.sports_cricket,
                                      size: 56,
                                      color: Colors.white.withOpacity(0.2),
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'No matches yet',
                                      style: TextStyle(
                                        color: Color(0xFFBEC7C0),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Save a match from Live Arena\nto see it here.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Color(0xFF6A7B6E),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                itemCount: _matches!.length,
                                itemBuilder: (context, i) {
                                  final m = _matches![i];
                                  final dateStr = '${m.playedAt.day}/${m.playedAt.month}/${m.playedAt.year}';
                                  final inningsStr = m.innings
                                      .map((e) => '${e.totalRuns}/${e.totalWickets} (${e.oversText})')
                                      .join(' & ');
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Material(
                                      color: const Color(0xFF0D2F20),
                                      borderRadius: BorderRadius.circular(12),
                                      child: InkWell(
                                        onTap: () => _showMatchCardOptions(context, m),
                                        borderRadius: BorderRadius.circular(12),
                                        child: Padding(
                                          padding: const EdgeInsets.all(16),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    dateStr,
                                                    style: const TextStyle(
                                                      color: Color(0xFF6A7B6E),
                                                      fontSize: 12,
                                                      letterSpacing: 1,
                                                    ),
                                                  ),
                                                  const Spacer(),
                                                  const Icon(
                                                    Icons.chevron_right,
                                                    color: Color(0xFF6A7B6E),
                                                    size: 20,
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                '${m.battingTeamName} vs ${m.bowlingTeamName}',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                inningsStr,
                                                style: const TextStyle(
                                                  color: Color(0xFFF9D96B),
                                                  fontSize: 14,
                                                ),
                                              ),
                                              if (m.oversLimit > 0)
                                                Text(
                                                  '${m.oversLimit} overs match',
                                                  style: const TextStyle(
                                                    color: Color(0xFF6A7B6E),
                                                    fontSize: 11,
                                                  ),
                                                ),
                                              const SizedBox(height: 4),
                                              const Text(
                                                'Tap to view scorecard',
                                                style: TextStyle(
                                                  color: Color(0xFF6A7B6E),
                                                  fontSize: 10,
                                                  fontStyle: FontStyle.italic,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMatchCardOptions(BuildContext context, MatchSummary m) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF0D2F20),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '${m.battingTeamName} vs ${m.bowlingTeamName}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 48,
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => MatchDetailScreen(matchId: m.id),
                      ),
                    ).then((value) {
                      if (value == true && mounted) _load();
                    });
                  },
                  icon: const Icon(Icons.scoreboard, color: Color(0xFFF9D96B), size: 22),
                  label: const Text(
                    'View scorecard',
                    style: TextStyle(color: Color(0xFFF9D96B), fontSize: 15),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 48,
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    _confirmDeleteMatch(context, m.id);
                  },
                  icon: const Icon(Icons.delete_outline, color: Color(0xFFBEC7C0), size: 22),
                  label: const Text(
                    'Delete match',
                    style: TextStyle(color: Color(0xFFBEC7C0), fontSize: 15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDeleteMatch(BuildContext context, String matchId) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete match?'),
        content: const Text(
          'This will permanently delete this match and all player stats for it. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    try {
      await MatchRepository().deleteMatch(matchId);
      if (mounted) _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not delete: $e')),
        );
      }
    }
  }
}

/// Full scorecard view for a single match (entry point from Match History).
class MatchDetailScreen extends StatefulWidget {
  final String matchId;

  const MatchDetailScreen({super.key, required this.matchId});

  @override
  State<MatchDetailScreen> createState() => _MatchDetailScreenState();
}

class _MatchDetailScreenState extends State<MatchDetailScreen> {
  MatchDetail? _detail;
  String? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final d = await MatchRepository().getMatchDetail(widget.matchId);
      if (mounted) setState(() {
        _detail = d;
        _loading = false;
      });
    } catch (e) {
      if (mounted) setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _confirmDeleteMatch(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete match?'),
        content: const Text(
          'This will permanently delete this match and all player stats for it. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    try {
      await MatchRepository().deleteMatch(widget.matchId);
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not delete: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF06351E), Color(0xFF02140C)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    const Expanded(
                      child: Text(
                        'SCORECARD',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFFF9D96B),
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _detail == null ? null : () => _confirmDeleteMatch(context),
                      icon: const Icon(Icons.delete_outline, color: Color(0xFFBEC7C0), size: 22),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _loading
                    ? const Center(
                        child: CircularProgressIndicator(color: Color(0xFFF9D96B)),
                      )
                    : _error != null
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Text(
                                _error!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Color(0xFFBEC7C0)),
                              ),
                            ),
                          )
                        : _detail == null
                            ? const Center(
                                child: Text(
                                  'Match not found',
                                  style: TextStyle(color: Color(0xFFBEC7C0)),
                                ),
                              )
                            : SingleChildScrollView(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: _buildContent(_detail!),
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(MatchDetail d) {
    final dateStr = '${d.playedAt.day}/${d.playedAt.month}/${d.playedAt.year}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          color: const Color(0xFF0D2F20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateStr,
                  style: const TextStyle(
                    color: Color(0xFF6A7B6E),
                    fontSize: 12,
                    letterSpacing: 1,
                  ),
                ),
                if (d.venue != null && d.venue!.isNotEmpty)
                  Text(
                    d.venue!,
                    style: const TextStyle(
                      color: Color(0xFF6A7B6E),
                      fontSize: 12,
                    ),
                  ),
                const SizedBox(height: 8),
                Text(
                  '${d.battingTeamName} vs ${d.bowlingTeamName}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (d.oversLimit > 0)
                  Text(
                    '${d.oversLimit} overs match',
                    style: const TextStyle(
                      color: Color(0xFF6A7B6E),
                      fontSize: 12,
                    ),
                  ),
                if (d.resultSummary != null && d.resultSummary!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    d.resultSummary!,
                    style: const TextStyle(
                      color: Color(0xFFF9D96B),
                      fontSize: 14,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        ...d.innings.map((inn) => _buildInnings(inn)),
      ],
    );
  }

  Widget _buildInnings(InningsDetail inn) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Innings ${inn.inningsNumber} — ${inn.battingTeamName}',
          style: const TextStyle(
            color: Color(0xFFF9D96B),
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${inn.totalRuns}/${inn.totalWickets} (${inn.oversText} overs)',
          style: const TextStyle(
            color: Color(0xFFBEC7C0),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 12),
        if (inn.batting.isNotEmpty) ...[
          const Text(
            'Batting',
            style: TextStyle(
              color: Color(0xFF6A7B6E),
              fontSize: 11,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 6),
          _battingTable(inn.batting),
          const SizedBox(height: 16),
        ] else if (inn.bowling.isEmpty) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              'No player stats for this innings. Add batting & bowling players in Set up match, then Save match and fill the scorecard to see details here.',
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 13,
              ),
            ),
          ),
        ],
        if (inn.bowling.isNotEmpty) ...[
          const Text(
            'Bowling',
            style: TextStyle(
              color: Color(0xFF6A7B6E),
              fontSize: 11,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 6),
          _bowlingTable(inn.bowling),
          const SizedBox(height: 24),
        ],
      ],
    );
  }

  Widget _battingTable(List<BattingEntry> batting) {
    return Card(
      color: const Color(0xFF0D2F20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          _tableRow(
            ['#', 'Batter', 'R', 'B', '4s', '6s', 'Out'],
            isHeader: true,
            firstColumnIsPosition: true,
          ),
          const Divider(height: 1, color: Color(0xFF2A3A2E)),
          ...batting.asMap().entries.map((e) => _tableRow(
                [
                  '${e.key + 1}',
                  e.value.playerName,
                  '${e.value.runs}',
                  '${e.value.ballsFaced}',
                  '${e.value.fours}',
                  '${e.value.sixes}',
                  e.value.outType ?? 'not out',
                ],
                firstColumnIsPosition: true,
              )),
        ],
      ),
    );
  }

  Widget _bowlingTable(List<BowlingEntry> bowling) {
    return Card(
      color: const Color(0xFF0D2F20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          _tableRow(
            ['Bowler', 'O', 'M', 'R', 'W', 'Wd', 'NB'],
            isHeader: true,
            firstColumnIsPosition: false,
          ),
          const Divider(height: 1, color: Color(0xFF2A3A2E)),
          ...bowling.map((b) => _tableRow(
                [
                  b.playerName,
                  b.oversText,
                  '${b.maidens}',
                  '${b.runsConceded}',
                  '${b.wickets}',
                  '${b.wides}',
                  '${b.noBalls}',
                ],
                firstColumnIsPosition: false,
              )),
        ],
      ),
    );
  }

  Widget _tableRow(List<String> cells,
      {bool isHeader = false, bool firstColumnIsPosition = false}) {
    final usePositionLayout = firstColumnIsPosition && cells.length >= 2;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          if (usePositionLayout) ...[
            SizedBox(
              width: 28,
              child: Text(
                cells[0],
                style: TextStyle(
                  color: isHeader ? const Color(0xFF6A7B6E) : const Color(0xFFBEC7C0),
                  fontSize: isHeader ? 11 : 13,
                  fontWeight: isHeader ? FontWeight.w600 : FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                cells[1],
                style: TextStyle(
                  color: isHeader ? const Color(0xFF6A7B6E) : Colors.white,
                  fontSize: isHeader ? 11 : 14,
                  fontWeight: isHeader ? FontWeight.w600 : FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            ...cells.skip(2).map((c) => SizedBox(
                  width: 32,
                  child: Text(
                    c,
                    style: TextStyle(
                      color: isHeader ? const Color(0xFF6A7B6E) : const Color(0xFFBEC7C0),
                      fontSize: isHeader ? 11 : 13,
                      fontWeight: isHeader ? FontWeight.w600 : FontWeight.normal,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )),
          ] else ...[
            Expanded(
              flex: 2,
              child: Text(
                cells[0],
                style: TextStyle(
                  color: isHeader ? const Color(0xFF6A7B6E) : Colors.white,
                  fontSize: isHeader ? 11 : 14,
                  fontWeight: isHeader ? FontWeight.w600 : FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 12),
            ...cells.skip(1).map((c) => SizedBox(
                  width: 36,
                  child: Text(
                    c,
                    style: TextStyle(
                      color: isHeader ? const Color(0xFF6A7B6E) : const Color(0xFFBEC7C0),
                      fontSize: isHeader ? 11 : 13,
                      fontWeight: isHeader ? FontWeight.w600 : FontWeight.normal,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )),
          ],
        ],
      ),
    );
  }
}

/// SCREEN 2 - Set up your match
class SetupMatchScreen extends StatefulWidget {
  const SetupMatchScreen({super.key});

  @override
  State<SetupMatchScreen> createState() => _SetupMatchScreenState();
}

class _SetupMatchScreenState extends State<SetupMatchScreen> {
  final TextEditingController _battingController =
      TextEditingController(text: 'Street 11');
  final TextEditingController _bowlingController =
      TextEditingController(text: 'Office 11');
  final TextEditingController _battingPlayerController = TextEditingController();
  final TextEditingController _bowlingPlayerController = TextEditingController();
  int _overs = 10;
  final List<String> _battingPlayers = [];
  final List<String> _bowlingPlayers = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFF8F7FB),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        titleSpacing: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                const Text(
                  'Set up your match',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Name teams, add players, choose overs, then go live.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6C6C6C),
                  ),
                ),
                const SizedBox(height: 24),
                _buildTextField(
                  label: 'Batting team name',
                  controller: _battingController,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  label: 'Bowling team name',
                  controller: _bowlingController,
                ),
                const SizedBox(height: 24),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Overs',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF111111),
                      ),
                    ),
                    const Spacer(),
                    _OversStepper(
                      value: _overs,
                      onChanged: (v) => setState(() => _overs = v),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'overs',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF3C3C3C),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                const Text(
                  'Batting team players',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111111),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Add batters to record runs and how out.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6C6C6C),
                  ),
                ),
                const SizedBox(height: 10),
                _buildPlayerList(
                  label: '',
                  hint: 'Player name',
                  controller: _battingPlayerController,
                  players: _battingPlayers,
                  onAdd: () {
                    final name = _battingPlayerController.text.trim();
                    if (name.isNotEmpty) {
                      setState(() {
                        _battingPlayers.add(name);
                        _battingPlayerController.clear();
                      });
                    }
                  },
                  onRemove: (i) {
                    setState(() => _battingPlayers.removeAt(i));
                  },
                ),
                const SizedBox(height: 24),
                const Text(
                  'Bowling team players',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111111),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Add bowlers to record overs, wickets, runs conceded.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6C6C6C),
                  ),
                ),
                const SizedBox(height: 10),
                _buildPlayerList(
                  label: '',
                  hint: 'Player name',
                  controller: _bowlingPlayerController,
                  players: _bowlingPlayers,
                  onAdd: () {
                    final name = _bowlingPlayerController.text.trim();
                    if (name.isNotEmpty) {
                      setState(() {
                        _bowlingPlayers.add(name);
                        _bowlingPlayerController.clear();
                      });
                    }
                  },
                  onRemove: (i) {
                    setState(() => _bowlingPlayers.removeAt(i));
                  },
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => LiveScoringScreen(
                            battingTeam: _battingController.text,
                            bowlingTeam: _bowlingController.text,
                            overs: _overs,
                            battingPlayers: List.from(_battingPlayers),
                            bowlingPlayers: List.from(_bowlingPlayers),
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      'Start live scoring',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerList({
    required String label,
    required String hint,
    required TextEditingController controller,
    required List<String> players,
    required VoidCallback onAdd,
    required void Function(int) onRemove,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1F1F1F),
            ),
          ),
          const SizedBox(height: 8),
        ],
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: controller,
                  onSubmitted: (_) => onAdd(),
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 15,
                  ),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: const TextStyle(color: Color(0xFF9E9E9E)),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: onAdd,
              style: IconButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.add),
            ),
          ],
        ),
        if (players.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: List.generate(players.length, (i) {
              return Chip(
                label: Text(players[i]),
                deleteIcon: const Icon(Icons.close, size: 18),
                onDeleted: () => onRemove(i),
                backgroundColor: const Color(0xFFF0F0F0),
              );
            }),
          ),
        ],
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF1F1F1F),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
            decoration: const InputDecoration(
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}

class _OversStepper extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const _OversStepper({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFD0D0D0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _stepperButton(
            icon: Icons.keyboard_arrow_up,
            onTap: () => onChanged(value + 1),
          ),
          Container(
            width: 40,
            alignment: Alignment.center,
            child: Text(
              '$value',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111111),
              ),
            ),
          ),
          _stepperButton(
            icon: Icons.keyboard_arrow_down,
            onTap: () {
              if (value > 1) onChanged(value - 1);
            },
          ),
        ],
      ),
    );
  }

  Widget _stepperButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: SizedBox(
        width: 26,
        child: Icon(
          icon,
          size: 18,
          color: Colors.black87,
        ),
      ),
    );
  }
}

/// SCREEN 3 - Live Arena
class LiveScoringScreen extends StatefulWidget {
  final String battingTeam;
  final String bowlingTeam;
  final int overs;
  final List<String> battingPlayers;
  final List<String> bowlingPlayers;

  const LiveScoringScreen({
    super.key,
    required this.battingTeam,
    required this.bowlingTeam,
    required this.overs,
    this.battingPlayers = const [],
    this.bowlingPlayers = const [],
  });

  @override
  State<LiveScoringScreen> createState() => _LiveScoringScreenState();
}

/// Snapshot of scoring state for undo.
class _ScoringSnapshot {
  final int runs, wickets, balls;
  final int strikerIndex, nonStrikerIndex, bowlerIndex;
  final List<int> batsmanRuns, batsmanBalls, batsmanFours, batsmanSixes;
  final List<int> bowlerBalls, bowlerRuns, bowlerWickets, bowlerWides, bowlerNoBalls;
  final List<String> currentOverBalls;
  final List<int> dismissedBatsmen;
  final bool lastManStanding;
  _ScoringSnapshot({
    required this.runs,
    required this.wickets,
    required this.balls,
    required this.strikerIndex,
    required this.nonStrikerIndex,
    required this.bowlerIndex,
    required this.batsmanRuns,
    required this.batsmanBalls,
    required this.batsmanFours,
    required this.batsmanSixes,
    required this.bowlerBalls,
    required this.bowlerRuns,
    required this.bowlerWickets,
    required this.bowlerWides,
    required this.bowlerNoBalls,
    required this.currentOverBalls,
    required this.dismissedBatsmen,
    this.lastManStanding = false,
  });
}

class _LiveScoringScreenState extends State<LiveScoringScreen> {
  String _phase = 'openers'; // 'openers' | 'scoring'
  int? _strikerIndex;
  int? _nonStrikerIndex;
  int? _bowlerIndex;
  int _runs = 0;
  int _wickets = 0;
  int _balls = 0;
  bool _isSaving = false;
  List<int> _batsmanRuns = [];
  List<int> _batsmanBalls = [];
  List<int> _batsmanFours = [];
  List<int> _batsmanSixes = [];
  List<int> _bowlerBalls = [];
  List<int> _bowlerRuns = [];
  List<int> _bowlerWickets = [];
  List<int> _bowlerWides = [];
  List<int> _bowlerNoBalls = [];
  List<String> _currentOverBalls = [];
  List<int> _dismissedBatsmen = [];
  final List<_ScoringSnapshot> _history = [];
  int? _openersStriker;
  int? _openersNonStriker;
  int? _openersBowler;
  bool _lastManStanding = false;
  bool _inningsEnded = false;
  int _currentInnings = 1;
  String get _currentBattingTeam =>
      _currentInnings == 1 ? widget.battingTeam : _innings2BattingTeam!;
  String get _currentBowlingTeam =>
      _currentInnings == 1 ? widget.bowlingTeam : _innings2BowlingTeam!;
  List<String> get _currentBattingPlayers =>
      _currentInnings == 1 ? widget.battingPlayers : _innings2BattingPlayers!;
  List<String> get _currentBowlingPlayers =>
      _currentInnings == 1 ? widget.bowlingPlayers : _innings2BowlingPlayers!;
  String? _innings2BattingTeam;
  String? _innings2BowlingTeam;
  List<String>? _innings2BattingPlayers;
  List<String>? _innings2BowlingPlayers;
  int _innings1Runs = 0;
  int _innings1Wickets = 0;
  int _innings1Balls = 0;
  List<int> _innings1BatsmanRuns = [];
  List<int> _innings1BatsmanBalls = [];
  List<int> _innings1BatsmanFours = [];
  List<int> _innings1BatsmanSixes = [];
  List<int> _innings1BowlerBalls = [];
  List<int> _innings1BowlerRuns = [];
  List<int> _innings1BowlerWickets = [];
  List<int> _innings1BowlerWides = [];
  List<int> _innings1BowlerNoBalls = [];
  List<int> _innings1DismissedBatsmen = [];
  /// Batting order (player indices) for current innings: openers first, then order they came in.
  List<int> _battingOrder = [];
  /// Innings 1 batting order, stored when first innings ends.
  List<int> _innings1BattingOrder = [];

  bool get _hasPlayerTracking =>
      widget.battingPlayers.length >= 2 && widget.bowlingPlayers.length >= 1;

  @override
  void initState() {
    super.initState();
    if (!_hasPlayerTracking) _phase = 'scoring';
  }

  void _startInnings(int strikerIdx, int nonStrikerIdx, int bowlerIdx) {
    setState(() {
      _strikerIndex = strikerIdx;
      _nonStrikerIndex = nonStrikerIdx;
      _bowlerIndex = bowlerIdx;
      _battingOrder = [strikerIdx, nonStrikerIdx];
      final nBat = _currentBattingPlayers.length;
      final nBowl = _currentBowlingPlayers.length;
      _batsmanRuns = List.filled(nBat, 0);
      _batsmanBalls = List.filled(nBat, 0);
      _batsmanFours = List.filled(nBat, 0);
      _batsmanSixes = List.filled(nBat, 0);
      _bowlerBalls = List.filled(nBowl, 0);
      _bowlerRuns = List.filled(nBowl, 0);
      _bowlerWickets = List.filled(nBowl, 0);
      _bowlerWides = List.filled(nBowl, 0);
      _bowlerNoBalls = List.filled(nBowl, 0);
      _currentOverBalls = [];
      _dismissedBatsmen = [];
      _lastManStanding = false;
      _phase = 'scoring';
    });
  }

  void _pushSnapshot() {
    _history.add(_ScoringSnapshot(
      runs: _runs,
      wickets: _wickets,
      balls: _balls,
      strikerIndex: _strikerIndex ?? -1,
      nonStrikerIndex: _nonStrikerIndex ?? -1,
      bowlerIndex: _bowlerIndex ?? -1,
      batsmanRuns: List.from(_batsmanRuns),
      batsmanBalls: List.from(_batsmanBalls),
      batsmanFours: List.from(_batsmanFours),
      batsmanSixes: List.from(_batsmanSixes),
      bowlerBalls: List.from(_bowlerBalls),
      bowlerRuns: List.from(_bowlerRuns),
      bowlerWickets: List.from(_bowlerWickets),
      bowlerWides: List.from(_bowlerWides),
      bowlerNoBalls: List.from(_bowlerNoBalls),
      currentOverBalls: List.from(_currentOverBalls),
      dismissedBatsmen: List.from(_dismissedBatsmen),
      lastManStanding: _lastManStanding,
    ));
  }

  void _applySnapshot(_ScoringSnapshot s) {
    _runs = s.runs;
    _wickets = s.wickets;
    _balls = s.balls;
    _strikerIndex = s.strikerIndex >= 0 ? s.strikerIndex : null;
    _nonStrikerIndex = s.nonStrikerIndex >= 0 ? s.nonStrikerIndex : null;
    _bowlerIndex = s.bowlerIndex >= 0 ? s.bowlerIndex : null;
    _batsmanRuns = List.from(s.batsmanRuns);
    _batsmanBalls = List.from(s.batsmanBalls);
    _batsmanFours = List.from(s.batsmanFours);
    _batsmanSixes = List.from(s.batsmanSixes);
    _bowlerBalls = List.from(s.bowlerBalls);
    _bowlerRuns = List.from(s.bowlerRuns);
    _bowlerWickets = List.from(s.bowlerWickets);
    _bowlerWides = List.from(s.bowlerWides);
    _bowlerNoBalls = List.from(s.bowlerNoBalls);
    _currentOverBalls = List.from(s.currentOverBalls);
    _dismissedBatsmen = List.from(s.dismissedBatsmen);
    _lastManStanding = s.lastManStanding;
  }

  void _endOver() {
    _currentOverBalls.clear();
    final s = _strikerIndex;
    final n = _nonStrikerIndex;
    if (s != null && n != null) {
      _strikerIndex = n;
      _nonStrikerIndex = s;
    }
  }

  void _handleAction(String label) {
    if (_inningsEnded) return;
    if (widget.overs > 0 && _balls >= widget.overs * 6) {
      setState(() {
        _inningsEnded = true;
        if (_currentInnings == 1) _storeInnings1Data();
      });
      return;
    }
    if (_hasPlayerTracking && (_strikerIndex == null || _bowlerIndex == null)) return;
    final lu = label.toUpperCase();
    int dr = 0, dw = 0, db = 0;
    String overLabel = lu;
    bool isWideOrNoball = false;
    switch (lu) {
      case '0':
        db = 1;
        overLabel = '0';
        break;
      case '1':
        dr = 1;
        db = 1;
        overLabel = '1';
        break;
      case '2':
        dr = 2;
        db = 1;
        overLabel = '2';
        break;
      case '3':
        dr = 3;
        db = 1;
        overLabel = '3';
        break;
      case '4':
        dr = 4;
        db = 1;
        overLabel = '4';
        break;
      case '6':
        dr = 6;
        db = 1;
        overLabel = '6';
        break;
      case 'WIDE':
        dr = 1;
        db = 0; // extra run only, not a legal ball
        overLabel = 'Wd';
        isWideOrNoball = true;
        break;
      case 'NO BALL':
        dr = 1;
        db = 0; // extra run only, not a legal ball
        overLabel = 'Nb';
        isWideOrNoball = true;
        break;
      case 'WICKET':
        dw = 1;
        db = 1;
        overLabel = 'W';
        break;
    }
    setState(() {
      _pushSnapshot();
      _runs += dr;
      _wickets += dw;
      _balls += db;
      _currentOverBalls.add(overLabel);
      if (_hasPlayerTracking && _bowlerIndex != null) {
        _bowlerRuns[_bowlerIndex!] += dr;
        _bowlerBalls[_bowlerIndex!] += db; // only legal balls
        if (lu == 'WIDE') _bowlerWides[_bowlerIndex!]++;
        if (lu == 'NO BALL') _bowlerNoBalls[_bowlerIndex!]++;
        if (lu == 'WICKET') _bowlerWickets[_bowlerIndex!]++;
      }
      if (_hasPlayerTracking && _strikerIndex != null && !isWideOrNoball) {
        _batsmanRuns[_strikerIndex!] += dr;
        if (db > 0) _batsmanBalls[_strikerIndex!] += db;
        if (lu == '4') _batsmanFours[_strikerIndex!]++;
        if (lu == '6') _batsmanSixes[_strikerIndex!]++;
      }
      if (lu == 'WICKET' && _hasPlayerTracking && _strikerIndex != null) {
        _dismissedBatsmen.add(_strikerIndex!);
        _strikerIndex = null;
        if (_lastManStanding) {
          _inningsEnded = true;
          if (_currentInnings == 1) _storeInnings1Data();
        }
      } else if (dr.isOdd &&
          _strikerIndex != null &&
          _nonStrikerIndex != null &&
          !_lastManStanding) {
        final t = _strikerIndex;
        _strikerIndex = _nonStrikerIndex;
        _nonStrikerIndex = t;
      } else if (dr.isOdd && _lastManStanding && _strikerIndex != null) {
        // last man: no strike rotation
      }
      // Over ends after 6 legal balls (Wd/Nb are extras, not counted)
      final legalBallsInOver =
          _currentOverBalls.where((s) => s != 'Wd' && s != 'Nb').length;
      if (legalBallsInOver >= 6) {
        _endOver();
        if (widget.overs == 0 || _balls < widget.overs * 6) _nextBowlerAfterOver();
      }
      if (widget.overs > 0 && _balls >= widget.overs * 6) {
        _inningsEnded = true;
        if (_currentInnings == 1) _storeInnings1Data();
      }
    });
    if (lu == 'WICKET' && _hasPlayerTracking && !_inningsEnded) {
      if (_lastManStanding) return;
      if (_dismissedBatsmen.length == _currentBattingPlayers.length - 1) {
        _showLastManDialog();
      } else {
        _showNewBatsmanPicker();
      }
    }
  }

  void _showLastManDialog() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Text('Last wicket down'),
          content: const Text(
            'Last man rule: the remaining batsman can continue with a runner (society cricket).\n\nContinue with last man?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                setState(() {
                  _inningsEnded = true;
                  if (_currentInnings == 1) _storeInnings1Data();
                });
              },
              child: const Text('No, end innings'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                setState(() {
                  _lastManStanding = true;
                  _strikerIndex = _nonStrikerIndex;
                  _nonStrikerIndex = null;
                });
              },
              child: const Text('Yes, continue'),
            ),
          ],
        ),
      );
    });
  }

  void _storeInnings1Data() {
    _innings1Runs = _runs;
    _innings1Wickets = _wickets;
    _innings1Balls = _balls;
    _innings1BatsmanRuns = List.from(_batsmanRuns);
    _innings1BatsmanBalls = List.from(_batsmanBalls);
    _innings1BatsmanFours = List.from(_batsmanFours);
    _innings1BatsmanSixes = List.from(_batsmanSixes);
    _innings1BowlerBalls = List.from(_bowlerBalls);
    _innings1BowlerRuns = List.from(_bowlerRuns);
    _innings1BowlerWickets = List.from(_bowlerWickets);
    _innings1BowlerWides = List.from(_bowlerWides);
    _innings1BowlerNoBalls = List.from(_bowlerNoBalls);
    _innings1DismissedBatsmen = List.from(_dismissedBatsmen);
    _innings1BattingOrder = List.from(_battingOrder);
  }

  void _onStartSecondInnings() {
    setState(() {
      _innings2BattingTeam = widget.bowlingTeam;
      _innings2BowlingTeam = widget.battingTeam;
      _innings2BattingPlayers = List.from(widget.bowlingPlayers);
      _innings2BowlingPlayers = List.from(widget.battingPlayers);
      _currentInnings = 2;
      _inningsEnded = false;
      _runs = 0;
      _wickets = 0;
      _balls = 0;
      _currentOverBalls = [];
      _history.clear();
      _openersStriker = null;
      _openersNonStriker = null;
      _openersBowler = null;
      _phase = 'openers';
    });
  }

  void _nextBowlerAfterOver() {
    if (!_hasPlayerTracking || _currentBowlingPlayers.length < 2) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final players = _currentBowlingPlayers;
      showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Bowler for next over?'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ...players.asMap().entries.map((e) {
                  return ListTile(
                    title: Text(players[e.key]),
                    subtitle: _bowlerIndex == e.key
                        ? Text(
                            '${_bowlerRuns[e.key]} runs, ${_bowlerWickets[e.key]} wkts',
                            style: const TextStyle(fontSize: 12),
                          )
                        : null,
                    onTap: () {
                      setState(() => _bowlerIndex = e.key);
                      Navigator.of(ctx).pop();
                    },
                  );
                }),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Keep same bowler'),
            ),
          ],
        ),
      );
    });
  }

  void _showNewBatsmanPicker() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final players = _currentBattingPlayers;
      final available = <int>[];
      for (var i = 0; i < players.length; i++) {
        if (_dismissedBatsmen.contains(i)) continue;
        if (i == _nonStrikerIndex) continue;
        available.add(i);
      }
      if (available.isEmpty) return;
      if (available.length == 1) {
        setState(() => _strikerIndex = available[0]);
        return;
      }
      showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('New batsman (on strike)'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: available
                  .map((i) => ListTile(
                        title: Text(players[i]),
                        onTap: () {
                          setState(() {
                            _strikerIndex = i;
                            if (!_battingOrder.contains(i)) _battingOrder.add(i);
                          });
                          Navigator.of(ctx).pop();
                        },
                      ))
                  .toList(),
            ),
          ),
        ),
      );
    });
  }

  void _undoLastAction() {
    if (_history.isEmpty) return;
    setState(() {
      _applySnapshot(_history.removeLast());
    });
  }

  String get _oversText {
    final completedOvers = _balls ~/ 6;
    final ballsThisOver = _balls % 6;
    return '$completedOvers.$ballsThisOver';
  }

  Future<void> _saveMatchToHistory() async {
    if (_isSaving) return;
    if (!SupabaseConfig.url.contains('supabase.co') ||
        SupabaseConfig.anonKey.startsWith('YOUR_')) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Configure Supabase to save history. See docs/SUPABASE_SETUP.md',
            ),
            backgroundColor: Color(0xFF3A1515),
          ),
        );
      }
      return;
    }
    setState(() => _isSaving = true);
    try {
      final repo = MatchRepository();
      if (_currentInnings == 2) {
        final res = await repo.createMatchWithFirstInnings(
          playedAt: DateTime.now(),
          battingTeamName: widget.battingTeam,
          bowlingTeamName: widget.bowlingTeam,
          oversLimit: widget.overs,
          totalRuns: _innings1Runs,
          totalWickets: _innings1Wickets,
          totalBalls: _innings1Balls,
        );
        final innings2Id = await repo.addSecondInnings(
          matchId: res.matchId,
          battingTeamName: widget.bowlingTeam,
          bowlingTeamName: widget.battingTeam,
          totalRuns: _runs,
          totalWickets: _wickets,
          totalBalls: _balls,
        );
        if (_hasPlayerTracking &&
            _innings1BatsmanRuns.isNotEmpty &&
            widget.battingPlayers.isNotEmpty) {
          final bat1 = <BattingEntry>[];
          final order1 = _innings1BattingOrder.isNotEmpty
              ? _innings1BattingOrder
              : List.generate(widget.battingPlayers.length, (i) => i);
          final rest1 = [
            for (var i = 0; i < widget.battingPlayers.length; i++)
              if (!order1.contains(i)) i
          ];
          for (final i in [...order1, ...rest1]) {
            bat1.add(BattingEntry(
              playerName: widget.battingPlayers[i],
              runs: _innings1BatsmanRuns[i],
              ballsFaced: _innings1BatsmanBalls[i],
              fours: _innings1BatsmanFours[i],
              sixes: _innings1BatsmanSixes[i],
              outType: _innings1DismissedBatsmen.contains(i) ? 'out' : null,
            ));
          }
          final bowl1 = <BowlingEntry>[];
          for (var i = 0; i < widget.bowlingPlayers.length; i++) {
            if (_innings1BowlerBalls[i] > 0 ||
                _innings1BowlerRuns[i] > 0 ||
                _innings1BowlerWickets[i] > 0) {
              bowl1.add(BowlingEntry(
                playerName: widget.bowlingPlayers[i],
                ballsBowled: _innings1BowlerBalls[i],
                maidens: 0,
                runsConceded: _innings1BowlerRuns[i],
                wickets: _innings1BowlerWickets[i],
                wides: _innings1BowlerWides[i],
                noBalls: _innings1BowlerNoBalls[i],
              ));
            }
          }
          await repo.saveScorecard(
            inningsId: res.inningsId,
            batting: bat1,
            bowling: bowl1,
          );
        }
        if (_hasPlayerTracking &&
            _batsmanRuns.isNotEmpty &&
            _innings2BattingPlayers != null) {
          final bat2 = <BattingEntry>[];
          final order2 = _battingOrder.isNotEmpty
              ? _battingOrder
              : List.generate(_innings2BattingPlayers!.length, (i) => i);
          final rest2 = [
            for (var i = 0; i < _innings2BattingPlayers!.length; i++)
              if (!order2.contains(i)) i
          ];
          for (final i in [...order2, ...rest2]) {
            bat2.add(BattingEntry(
              playerName: _innings2BattingPlayers![i],
              runs: _batsmanRuns[i],
              ballsFaced: _batsmanBalls[i],
              fours: _batsmanFours[i],
              sixes: _batsmanSixes[i],
              outType: _dismissedBatsmen.contains(i) ? 'out' : null,
            ));
          }
          final bowl2 = <BowlingEntry>[];
          if (_innings2BowlingPlayers != null) {
            for (var i = 0; i < _innings2BowlingPlayers!.length; i++) {
              if (_bowlerBalls[i] > 0 ||
                  _bowlerRuns[i] > 0 ||
                  _bowlerWickets[i] > 0) {
                bowl2.add(BowlingEntry(
                  playerName: _innings2BowlingPlayers![i],
                  ballsBowled: _bowlerBalls[i],
                  maidens: 0,
                  runsConceded: _bowlerRuns[i],
                  wickets: _bowlerWickets[i],
                  wides: _bowlerWides[i],
                  noBalls: _bowlerNoBalls[i],
                ));
              }
            }
          }
          await repo.saveScorecard(
            inningsId: innings2Id,
            batting: bat2,
            bowling: bowl2,
          );
        }
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Match and scorecard saved'),
              backgroundColor: Color(0xFF0D2F20),
            ),
          );
          Navigator.of(context).popUntil((r) => r.isFirst);
        }
        return;
      }
      final inningsId = await repo.saveMatch(
        playedAt: DateTime.now(),
        battingTeamName: widget.battingTeam,
        bowlingTeamName: widget.bowlingTeam,
        oversLimit: widget.overs,
        totalRuns: _runs,
        totalWickets: _wickets,
        totalBalls: _balls,
      );
      if (!mounted) return;
      final hasFullTracking = _hasPlayerTracking &&
          _batsmanRuns.isNotEmpty &&
          _bowlerRuns.isNotEmpty;
      if (hasFullTracking) {
        final batting = <BattingEntry>[];
        for (var i = 0; i < widget.battingPlayers.length; i++) {
          batting.add(BattingEntry(
            playerName: widget.battingPlayers[i],
            runs: _batsmanRuns[i],
            ballsFaced: _batsmanBalls[i],
            fours: _batsmanFours[i],
            sixes: _batsmanSixes[i],
            outType: _dismissedBatsmen.contains(i) ? 'out' : null,
          ));
        }
        final bowling = <BowlingEntry>[];
        for (var i = 0; i < widget.bowlingPlayers.length; i++) {
          if (_bowlerBalls[i] > 0 || _bowlerRuns[i] > 0 || _bowlerWickets[i] > 0) {
            bowling.add(BowlingEntry(
              playerName: widget.bowlingPlayers[i],
              ballsBowled: _bowlerBalls[i],
              maidens: 0,
              runsConceded: _bowlerRuns[i],
              wickets: _bowlerWickets[i],
              wides: _bowlerWides[i],
              noBalls: _bowlerNoBalls[i],
            ));
          }
        }
        await repo.saveScorecard(
          inningsId: inningsId,
          batting: batting,
          bowling: bowling,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Match and scorecard saved'),
              backgroundColor: Color(0xFF0D2F20),
            ),
          );
        }
      } else if (widget.battingPlayers.isNotEmpty || widget.bowlingPlayers.isNotEmpty) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ScorecardEntryScreen(
              inningsId: inningsId,
              battingPlayerNames: List.from(widget.battingPlayers),
              bowlingPlayerNames: List.from(widget.bowlingPlayers),
              matchSummary: '${widget.battingTeam} ${_runs}/$_wickets (${_oversText}) vs ${widget.bowlingTeam}',
            ),
          ),
        ).then((_) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Match and scorecard saved'),
                backgroundColor: Color(0xFF0D2F20),
              ),
            );
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Match saved to history'),
            backgroundColor: Color(0xFF0D2F20),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not save: $e'),
            backgroundColor: const Color(0xFF3A1515),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_inningsEnded) {
      return _buildInningsCompleteScreen(context);
    }
    if (_phase == 'openers' && _hasPlayerTracking) {
      return _buildOpenersScreen(context);
    }
    return _buildScoringScreen(context);
  }

  String _oversTextFromBalls(int balls) {
    return '${balls ~/ 6}.${balls % 6}';
  }

  Widget _buildInningsCompleteScreen(BuildContext context) {
    final isFirstInnings = _currentInnings == 1;
    final runs = isFirstInnings ? _innings1Runs : _runs;
    final wickets = isFirstInnings ? _innings1Wickets : _wickets;
    final balls = isFirstInnings ? _innings1Balls : _balls;
    final oversStr = _oversTextFromBalls(balls);
    final batTeam = isFirstInnings ? widget.battingTeam : _innings2BattingTeam!;
    final bowlTeam = isFirstInnings ? widget.bowlingTeam : _innings2BowlingTeam!;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF041D12), Color(0xFF020D08)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    Expanded(
                      child: Text(
                        isFirstInnings
                            ? '1st innings complete'
                            : '2nd innings complete',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFFF9D96B),
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$batTeam',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$runs/$wickets ($oversStr overs)',
                          style: const TextStyle(
                            color: Color(0xFFF9D96B),
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'vs $bowlTeam',
                          style: const TextStyle(
                            color: Color(0xFF6A7B6E),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving
                        ? null
                        : () {
                            if (isFirstInnings) {
                              _onStartSecondInnings();
                            } else {
                              _saveMatchToHistory();
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0D2F20),
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              color: Color(0xFFF9D96B),
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            isFirstInnings
                                ? 'Start 2nd innings'
                                : 'Save match to history',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFF9D96B),
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOpenersScreen(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF041D12), Color(0xFF020D08)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    Expanded(
                      child: Text(
                        _currentInnings == 2
                            ? '2nd INNINGS — OPEN'
                            : 'OPEN THE INNINGS',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFFF9D96B),
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Striker (facing)',
                        style: TextStyle(
                          color: Color(0xFF6A7B6E),
                          fontSize: 11,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 8),
                          DropdownButtonFormField<int>(
                            value: _openersStriker,
                            dropdownColor: const Color(0xFF0D2F20),
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: Color(0xFF071C12),
                            ),
                            style: const TextStyle(color: Colors.white),
                            items: _currentBattingPlayers
                                .asMap()
                                .entries
                                .map((e) => DropdownMenuItem(
                                      value: e.key,
                                      child: Text(e.value),
                                    ))
                                .toList(),
                            onChanged: (v) => setState(() {
                              _openersStriker = v;
                              if (_openersNonStriker == v) _openersNonStriker = null;
                            }),
                          ),
                      const SizedBox(height: 20),
                      const Text(
                        'Non-striker',
                        style: TextStyle(
                          color: Color(0xFF6A7B6E),
                          fontSize: 11,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 8),
                          DropdownButtonFormField<int>(
                            value: _openersNonStriker,
                            dropdownColor: const Color(0xFF0D2F20),
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: Color(0xFF071C12),
                            ),
                            style: const TextStyle(color: Colors.white),
                            items: _currentBattingPlayers
                                .asMap()
                                .entries
                                .where((e) => e.key != _openersStriker)
                                .map((e) => DropdownMenuItem(
                                      value: e.key,
                                      child: Text(e.value),
                                    ))
                                .toList(),
                            onChanged: (v) => setState(() => _openersNonStriker = v),
                          ),
                      const SizedBox(height: 20),
                      const Text(
                        'Opening bowler',
                        style: TextStyle(
                          color: Color(0xFF6A7B6E),
                          fontSize: 11,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 8),
                          DropdownButtonFormField<int>(
                            value: _openersBowler,
                            dropdownColor: const Color(0xFF0D2F20),
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: Color(0xFF071C12),
                            ),
                            style: const TextStyle(color: Colors.white),
                            items: _currentBowlingPlayers
                                .asMap()
                                .entries
                                .map((e) => DropdownMenuItem(
                                      value: e.key,
                                      child: Text(e.value),
                                    ))
                                .toList(),
                            onChanged: (v) => setState(() => _openersBowler = v),
                          ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: (_openersStriker != null &&
                                  _openersNonStriker != null &&
                                  _openersBowler != null &&
                                  _openersStriker != _openersNonStriker)
                              ? () => _startInnings(
                                    _openersStriker!,
                                    _openersNonStriker!,
                                    _openersBowler!,
                                  )
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0D2F20),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Start innings'),
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

  Widget _buildScoringScreen(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF041D12), Color(0xFF020D08)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    TextButton.icon(
                      onPressed: _history.isEmpty ? null : _undoLastAction,
                      icon: const Icon(Icons.undo, color: Color(0xFFBEC7C0), size: 20),
                      label: Text(
                        'Undo',
                        style: TextStyle(
                          color: _history.isEmpty ? const Color(0xFF4D5B50) : const Color(0xFFBEC7C0),
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Column(
                      children: [
                        const Text(
                          'LIVE ARENA',
                          style: TextStyle(
                            color: Color(0xFFB7C0B9),
                            fontSize: 10,
                            letterSpacing: 3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_currentBattingTeam}  vs  ${_currentBowlingTeam}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                decoration: BoxDecoration(
                  color: const Color(0xFF071C12),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.6),
                      blurRadius: 26,
                      offset: const Offset(0, 22),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'SCORE',
                          style: TextStyle(
                            color: Color(0xFF6A7B6E),
                            fontSize: 11,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$_runs/$_wickets',
                          style: const TextStyle(
                            color: Color(0xFFF9D96B),
                            fontSize: 40,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _currentOverBalls.isEmpty
                              ? 'This over: —'
                              : 'This over: ${_currentOverBalls.join(' ')}',
                          style: const TextStyle(
                            color: Color(0xFFBEC7C0),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'OVERS',
                          style: TextStyle(
                            color: Color(0xFF6A7B6E),
                            fontSize: 11,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _oversText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${widget.overs} overs',
                          style: const TextStyle(
                            color: Color(0xFF4D5B50),
                            fontSize: 11,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (_hasPlayerTracking && _strikerIndex != null && _bowlerIndex != null) ...[
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF071C12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF2A3A2E)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'STRIKER',
                                style: TextStyle(
                                  color: Color(0xFF6A7B6E),
                                  fontSize: 9,
                                  letterSpacing: 2,
                                ),
                              ),
                              Text(
                                _currentBattingPlayers[_strikerIndex!],
                                style: const TextStyle(
                                  color: Color(0xFFF9D96B),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${_batsmanRuns[_strikerIndex!]} (${_batsmanBalls[_strikerIndex!]}b)',
                                style: const TextStyle(
                                  color: Color(0xFF6A7B6E),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'NON-STRIKER',
                                style: TextStyle(
                                  color: Color(0xFF6A7B6E),
                                  fontSize: 9,
                                  letterSpacing: 2,
                                ),
                              ),
                              Text(
                                _lastManStanding
                                    ? '—'
                                    : _currentBattingPlayers[_nonStrikerIndex!],
                                style: const TextStyle(
                                  color: Color(0xFFBEC7C0),
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                _lastManStanding
                                    ? '—'
                                    : '${_batsmanRuns[_nonStrikerIndex!]} (${_batsmanBalls[_nonStrikerIndex!]}b)',
                                style: const TextStyle(
                                  color: Color(0xFF6A7B6E),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text(
                                'BOWLER',
                                style: TextStyle(
                                  color: Color(0xFF6A7B6E),
                                  fontSize: 9,
                                  letterSpacing: 2,
                                ),
                              ),
                              Text(
                                _currentBowlingPlayers[_bowlerIndex!],
                                style: const TextStyle(
                                  color: Color(0xFFBEC7C0),
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                '${_bowlerRuns[_bowlerIndex!]}-${_bowlerWickets[_bowlerIndex!]}',
                                style: const TextStyle(
                                  color: Color(0xFF6A7B6E),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Expanded(
                child: Column(
                  children: [
                    const Text(
                      'ACTION PANEL',
                      style: TextStyle(
                        color: Color(0xFF4D5B50),
                        fontSize: 11,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        children: [
                          _actionRow(['0', '1', '2'], _handleAction),
                          const SizedBox(height: 12),
                          _actionRow(['3', '4', '6'], _handleAction),
                          const SizedBox(height: 12),
                          _actionRow(
                            ['WIDE', 'NO BALL', 'WICKET'],
                            _handleAction,
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    const Padding(
                      padding: EdgeInsets.only(bottom: 24),
                      child: Text(
                        'TACTICAL SURFACE',
                        style: TextStyle(
                          color: Color(0xFF364137),
                          fontSize: 10,
                          letterSpacing: 4,
                        ),
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

  Widget _actionRow(
    List<String> labels,
    void Function(String) onAction,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: labels
          .map(
            (label) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: _ActionButton(
                  label: label,
                  isDanger: label.toUpperCase() == 'WICKET',
                  onTap: () => onAction(label),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

/// Screen to enter per-player batting and bowling stats after saving a match.
class ScorecardEntryScreen extends StatefulWidget {
  final String inningsId;
  final List<String> battingPlayerNames;
  final List<String> bowlingPlayerNames;
  final String matchSummary;

  const ScorecardEntryScreen({
    super.key,
    required this.inningsId,
    required this.battingPlayerNames,
    required this.bowlingPlayerNames,
    required this.matchSummary,
  });

  @override
  State<ScorecardEntryScreen> createState() => _ScorecardEntryScreenState();
}

class _ScorecardEntryScreenState extends State<ScorecardEntryScreen> {
  late List<_BattingRowData> _batting;
  late List<_BowlingRowData> _bowling;
  bool _saving = false;

  static const List<String> _outTypes = [
    'Not out',
    'Bowled',
    'Caught',
    'LBW',
    'Run out',
    'Stumped',
    'Hit wicket',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _batting = widget.battingPlayerNames
        .map((n) => _BattingRowData(name: n))
        .toList();
    _bowling = widget.bowlingPlayerNames
        .map((n) => _BowlingRowData(name: n))
        .toList();
  }

  Future<void> _submit() async {
    setState(() => _saving = true);
    try {
      await MatchRepository().saveScorecard(
        inningsId: widget.inningsId,
        batting: _batting
            .map((r) => BattingEntry(
                  playerName: r.name,
                  runs: r.runs,
                  ballsFaced: r.balls,
                  fours: r.fours,
                  sixes: r.sixes,
                  outType: r.outType == 'Not out' ? null : r.outType,
                ))
            .toList(),
        bowling: _bowling
            .map((r) => BowlingEntry(
                  playerName: r.name,
                  ballsBowled: r.overs * 6 + r.ballsInOver,
                  maidens: r.maidens,
                  runsConceded: r.runsConceded,
                  wickets: r.wickets,
                  wides: r.wides,
                  noBalls: r.noBalls,
                ))
            .toList(),
      );
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save scorecard: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FB),
      appBar: AppBar(
        title: const Text('Enter scorecard', style: TextStyle(color: Colors.black87)),
        backgroundColor: const Color(0xFFF8F7FB),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                widget.matchSummary,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6C6C6C),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Batting',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._batting.asMap().entries.map((e) => _buildBattingRow(e.key, e.value)),
                    const SizedBox(height: 24),
                    const Text(
                      'Bowling',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._bowling.asMap().entries.map((e) => _buildBowlingRow(e.key, e.value)),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _saving
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Save scorecard'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBattingRow(int i, _BattingRowData r) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              r.name,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _numberField('Runs', r.runs, (v) => setState(() => _batting[i] = _BattingRowData(name: r.name, runs: v, balls: r.balls, fours: r.fours, sixes: r.sixes, outType: r.outType))),
                const SizedBox(width: 8),
                _numberField('Balls', r.balls, (v) => setState(() => _batting[i] = _BattingRowData(name: r.name, runs: r.runs, balls: v, fours: r.fours, sixes: r.sixes, outType: r.outType))),
                const SizedBox(width: 8),
                _numberField('4s', r.fours, (v) => setState(() => _batting[i] = _BattingRowData(name: r.name, runs: r.runs, balls: r.balls, fours: v, sixes: r.sixes, outType: r.outType))),
                _numberField('6s', r.sixes, (v) => setState(() => _batting[i] = _BattingRowData(name: r.name, runs: r.runs, balls: r.balls, fours: r.fours, sixes: v, outType: r.outType))),
              ],
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: r.outType,
              decoration: const InputDecoration(
                labelText: 'How out',
                border: OutlineInputBorder(),
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: _outTypes.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (v) {
                if (v != null) setState(() => _batting[i] = _BattingRowData(name: r.name, runs: r.runs, balls: r.balls, fours: r.fours, sixes: r.sixes, outType: v));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBowlingRow(int i, _BowlingRowData r) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              r.name,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _numberField('Overs', r.overs, (v) => setState(() => _bowling[i] = _BowlingRowData(name: r.name, overs: v, ballsInOver: r.ballsInOver, runsConceded: r.runsConceded, wickets: r.wickets, maidens: r.maidens, wides: r.wides, noBalls: r.noBalls))),
                _numberField('B', r.ballsInOver, (v) => setState(() => _bowling[i] = _BowlingRowData(name: r.name, overs: r.overs, ballsInOver: v.clamp(0, 5), runsConceded: r.runsConceded, wickets: r.wickets, maidens: r.maidens, wides: r.wides, noBalls: r.noBalls))),
                _numberField('Runs', r.runsConceded, (v) => setState(() => _bowling[i] = _BowlingRowData(name: r.name, overs: r.overs, ballsInOver: r.ballsInOver, runsConceded: v, wickets: r.wickets, maidens: r.maidens, wides: r.wides, noBalls: r.noBalls))),
                _numberField('Wkts', r.wickets, (v) => setState(() => _bowling[i] = _BowlingRowData(name: r.name, overs: r.overs, ballsInOver: r.ballsInOver, runsConceded: r.runsConceded, wickets: v, maidens: r.maidens, wides: r.wides, noBalls: r.noBalls))),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                _numberField('M', r.maidens, (v) => setState(() => _bowling[i] = _BowlingRowData(name: r.name, overs: r.overs, ballsInOver: r.ballsInOver, runsConceded: r.runsConceded, wickets: r.wickets, maidens: v, wides: r.wides, noBalls: r.noBalls))),
                _numberField('Wd', r.wides, (v) => setState(() => _bowling[i] = _BowlingRowData(name: r.name, overs: r.overs, ballsInOver: r.ballsInOver, runsConceded: r.runsConceded, wickets: r.wickets, maidens: r.maidens, wides: v, noBalls: r.noBalls))),
                _numberField('NB', r.noBalls, (v) => setState(() => _bowling[i] = _BowlingRowData(name: r.name, overs: r.overs, ballsInOver: r.ballsInOver, runsConceded: r.runsConceded, wickets: r.wickets, maidens: r.maidens, wides: r.wides, noBalls: v))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _numberField(String label, int value, ValueChanged<int> onChanged) {
    return SizedBox(
      width: label.length <= 2 ? 48 : 64,
      child: TextFormField(
        key: ValueKey('$label-$value'),
        initialValue: value.toString(),
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        ),
        onChanged: (s) {
          final v = int.tryParse(s);
          if (v != null && v >= 0) onChanged(v);
        },
      ),
    );
  }
}

class _BattingRowData {
  final String name;
  final int runs;
  final int balls;
  final int fours;
  final int sixes;
  final String outType;

  _BattingRowData({
    required this.name,
    this.runs = 0,
    this.balls = 0,
    this.fours = 0,
    this.sixes = 0,
    this.outType = 'Not out',
  });
}

class _BowlingRowData {
  final String name;
  final int overs;
  final int ballsInOver;
  final int runsConceded;
  final int wickets;
  final int maidens;
  final int wides;
  final int noBalls;

  _BowlingRowData({
    required this.name,
    this.overs = 0,
    this.ballsInOver = 0,
    this.runsConceded = 0,
    this.wickets = 0,
    this.maidens = 0,
    this.wides = 0,
    this.noBalls = 0,
  });
}

class _ActionButton extends StatelessWidget {
  final String label;
  final bool isDanger;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    this.isDanger = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isPrimaryNumber =
        ['0', '1', '2', '3', '4', '6'].contains(label);

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: isDanger
              ? const Color(0xFF3A1515)
              : const Color(0xFF0A2415),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.7),
              blurRadius: 16,
              offset: const Offset(0, 14),
            ),
          ],
          border: isDanger
              ? Border.all(color: const Color(0xFFE65B5B))
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isDanger
                ? const Color(0xFFE65B5B)
                : (isPrimaryNumber
                    ? const Color(0xFFF9D96B)
                    : const Color(0xFFBEC7C0)),
            fontSize: isPrimaryNumber ? 24 : 14,
            fontWeight:
                isPrimaryNumber ? FontWeight.w700 : FontWeight.w500,
            letterSpacing: isPrimaryNumber ? 0 : 2,
          ),
        ),
      ),
    );
  }
}

