import 'package:flutter/material.dart';

void main() {
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
  int _overs = 10;
  bool _secondInnings = false;

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
                  'Name teams, choose overs, then go live.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6C6C6C),
                  ),
                ),
                const SizedBox(height: 24),
                _buildTextField(
                  label: 'Batting team (optional)',
                  controller: _battingController,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  label: 'Bowling team (optional)',
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
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Second innings',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF111111),
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Chasing a target',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6C6C6C),
                          ),
                        ),
                      ],
                    ),
                    Switch(
                      value: _secondInnings,
                      onChanged: (v) => setState(() => _secondInnings = v),
                      activeColor: Colors.white,
                      activeTrackColor: Colors.black,
                    ),
                  ],
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

  const LiveScoringScreen({
    super.key,
    required this.battingTeam,
    required this.bowlingTeam,
    required this.overs,
  });

  @override
  State<LiveScoringScreen> createState() => _LiveScoringScreenState();
}

class _LiveScoringScreenState extends State<LiveScoringScreen> {
  int _runs = 0;
  int _wickets = 0;
  int _balls = 0;

  void _handleAction(String label) {
    setState(() {
      switch (label.toUpperCase()) {
        case '0':
          _balls++;
          break;
        case '1':
          _runs += 1;
          _balls++;
          break;
        case '2':
          _runs += 2;
          _balls++;
          break;
        case '3':
          _runs += 3;
          _balls++;
          break;
        case '4':
          _runs += 4;
          _balls++;
          break;
        case '6':
          _runs += 6;
          _balls++;
          break;
        case 'WIDE':
          _runs += 1;
          break;
        case 'NO BALL':
          _runs += 1;
          break;
        case 'WICKET':
          _wickets += 1;
          _balls++;
          break;
      }
    });
  }

  String get _oversText {
    final completedOvers = _balls ~/ 6;
    final ballsThisOver = _balls % 6;
    return '$completedOvers.$ballsThisOver';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF041D12),
              Color(0xFF020D08),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
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
                          '${widget.battingTeam}  vs  ${widget.bowlingTeam}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Score card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
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
                        const SizedBox(height: 12),
                        const Text(
                          'LIVE BALL',
                          style: TextStyle(
                            color: Color(0xFF4D5B50),
                            fontSize: 11,
                            letterSpacing: 2,
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
                        const SizedBox(height: 24),
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
              const SizedBox(height: 40),
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

