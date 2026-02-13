import 'package:supabase_flutter/supabase_flutter.dart';

/// Saves and loads match history. Backed by Supabase; can be swapped later.
class MatchRepository {
  MatchRepository({SupabaseClient? client}) : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  /// Saves one completed match with one innings. Returns the innings id for scorecard.
  Future<String> saveMatch({
    required DateTime playedAt,
    required String battingTeamName,
    required String bowlingTeamName,
    required int oversLimit,
    required int totalRuns,
    required int totalWickets,
    required int totalBalls,
    String? venue,
    String? resultSummary,
  }) async {
    final match = await _client.from('matches').insert({
      'played_at': playedAt.toIso8601String().split('T').first,
      'venue': venue,
      'batting_team_name': battingTeamName,
      'bowling_team_name': bowlingTeamName,
      'overs_limit': oversLimit,
      'status': 'completed',
      'result_summary': resultSummary,
    }).select('id').single();

    final matchId = match['id'] as String;
    final innings = await _client.from('innings').insert({
      'match_id': matchId,
      'innings_number': 1,
      'batting_team_name': battingTeamName,
      'bowling_team_name': bowlingTeamName,
      'total_runs': totalRuns,
      'total_wickets': totalWickets,
      'total_balls': totalBalls,
    }).select('id').single();

    return innings['id'] as String;
  }

  /// Creates a match and inserts one innings; returns (matchId, inningsId).
  Future<({String matchId, String inningsId})> createMatchWithFirstInnings({
    required DateTime playedAt,
    required String battingTeamName,
    required String bowlingTeamName,
    required int oversLimit,
    required int totalRuns,
    required int totalWickets,
    required int totalBalls,
    String? venue,
    String? resultSummary,
  }) async {
    final match = await _client.from('matches').insert({
      'played_at': playedAt.toIso8601String().split('T').first,
      'venue': venue,
      'batting_team_name': battingTeamName,
      'bowling_team_name': bowlingTeamName,
      'overs_limit': oversLimit,
      'status': 'completed',
      'result_summary': resultSummary,
    }).select('id').single();
    final matchId = match['id'] as String;
    final innings = await _client.from('innings').insert({
      'match_id': matchId,
      'innings_number': 1,
      'batting_team_name': battingTeamName,
      'bowling_team_name': bowlingTeamName,
      'total_runs': totalRuns,
      'total_wickets': totalWickets,
      'total_balls': totalBalls,
    }).select('id').single();
    return (matchId: matchId, inningsId: innings['id'] as String);
  }

  /// Inserts second innings for an existing match. Returns innings id.
  Future<String> addSecondInnings({
    required String matchId,
    required String battingTeamName,
    required String bowlingTeamName,
    required int totalRuns,
    required int totalWickets,
    required int totalBalls,
  }) async {
    final innings = await _client.from('innings').insert({
      'match_id': matchId,
      'innings_number': 2,
      'batting_team_name': battingTeamName,
      'bowling_team_name': bowlingTeamName,
      'total_runs': totalRuns,
      'total_wickets': totalWickets,
      'total_balls': totalBalls,
    }).select('id').single();
    return innings['id'] as String;
  }

  /// Deletes a match and all its innings and scorecards (cascade).
  Future<void> deleteMatch(String matchId) async {
    await _client.from('matches').delete().eq('id', matchId);
  }

  /// Saves batting and bowling scorecard for an innings.
  Future<void> saveScorecard({
    required String inningsId,
    required List<BattingEntry> batting,
    required List<BowlingEntry> bowling,
  }) async {
    for (var i = 0; i < batting.length; i++) {
      final e = batting[i];
      await _client.from('batting_scorecard').insert({
        'innings_id': inningsId,
        'player_name': e.playerName,
        'runs': e.runs,
        'balls_faced': e.ballsFaced,
        'fours': e.fours,
        'sixes': e.sixes,
        'out_type': e.outType,
        'batting_position': i + 1,
      });
    }
    for (var i = 0; i < bowling.length; i++) {
      final e = bowling[i];
      await _client.from('bowling_scorecard').insert({
        'innings_id': inningsId,
        'player_name': e.playerName,
        'balls_bowled': e.ballsBowled,
        'maidens': e.maidens,
        'runs_conceded': e.runsConceded,
        'wickets': e.wickets,
        'wides': e.wides,
        'no_balls': e.noBalls,
        'bowling_position': i + 1,
      });
    }
  }

  /// Loads match history (match + innings) ordered by date descending.
  Future<List<MatchSummary>> getMatchHistory({int limit = 50}) async {
    final res = await _client
        .from('matches')
        .select('id, played_at, venue, batting_team_name, bowling_team_name, overs_limit, result_summary, status')
        .order('played_at', ascending: false)
        .limit(limit);

    final matches = res as List<dynamic>;
    final list = <MatchSummary>[];

    for (final m in matches) {
      final map = m as Map<String, dynamic>;
      final inningsRes = await _client
          .from('innings')
          .select('total_runs, total_wickets, total_balls')
          .eq('match_id', map['id'])
          .order('innings_number');

      final inningsList = inningsRes as List<dynamic>;
      list.add(MatchSummary(
        id: map['id'] as String,
        playedAt: DateTime.parse(map['played_at'] as String),
        venue: map['venue'] as String?,
        battingTeamName: map['batting_team_name'] as String,
        bowlingTeamName: map['bowling_team_name'] as String,
        oversLimit: map['overs_limit'] as int,
        resultSummary: map['result_summary'] as String?,
        status: map['status'] as String? ?? 'completed',
        innings: inningsList
            .map((i) => InningsSummary(
                  totalRuns: i['total_runs'] as int,
                  totalWickets: i['total_wickets'] as int,
                  totalBalls: i['total_balls'] as int,
                ))
            .toList(),
      ));
    }

    return list;
  }

  /// Loads full match detail including batting and bowling scorecards for each innings.
  Future<MatchDetail?> getMatchDetail(String matchId) async {
    final matchRes = await _client
        .from('matches')
        .select('id, played_at, venue, batting_team_name, bowling_team_name, overs_limit, result_summary, status')
        .eq('id', matchId)
        .maybeSingle();
    if (matchRes == null) return null;
    final m = matchRes as Map<String, dynamic>;

    final inningsRes = await _client
        .from('innings')
        .select('id, innings_number, batting_team_name, bowling_team_name, total_runs, total_wickets, total_balls')
        .eq('match_id', matchId)
        .order('innings_number');
    final inningsList = inningsRes as List<dynamic>;
    final inningsDetails = <InningsDetail>[];

    for (final inv in inningsList) {
      final invMap = inv as Map<String, dynamic>;
      final inningsId = invMap['id'] as String;

      final battingRes = await _client
          .from('batting_scorecard')
          .select('player_name, runs, balls_faced, fours, sixes, out_type')
          .eq('innings_id', inningsId)
          .order('batting_position');
      final bowlingRes = await _client
          .from('bowling_scorecard')
          .select('player_name, balls_bowled, maidens, runs_conceded, wickets, wides, no_balls')
          .eq('innings_id', inningsId)
          .order('bowling_position');

      final batting = (battingRes as List<dynamic>).map((r) {
        final row = r as Map<String, dynamic>;
        return BattingEntry(
          playerName: row['player_name'] as String,
          runs: (row['runs'] as int?) ?? 0,
          ballsFaced: (row['balls_faced'] as int?) ?? 0,
          fours: (row['fours'] as int?) ?? 0,
          sixes: (row['sixes'] as int?) ?? 0,
          outType: row['out_type'] as String?,
        );
      }).toList();
      final bowling = (bowlingRes as List<dynamic>).map((r) {
        final row = r as Map<String, dynamic>;
        return BowlingEntry(
          playerName: row['player_name'] as String,
          ballsBowled: (row['balls_bowled'] as int?) ?? 0,
          maidens: (row['maidens'] as int?) ?? 0,
          runsConceded: (row['runs_conceded'] as int?) ?? 0,
          wickets: (row['wickets'] as int?) ?? 0,
          wides: (row['wides'] as int?) ?? 0,
          noBalls: (row['no_balls'] as int?) ?? 0,
        );
      }).toList();

      final totalBalls = (invMap['total_balls'] as int?) ?? 0;
      final oversText = '${totalBalls ~/ 6}.${totalBalls % 6}';
      inningsDetails.add(InningsDetail(
        inningsNumber: invMap['innings_number'] as int,
        battingTeamName: invMap['batting_team_name'] as String,
        bowlingTeamName: invMap['bowling_team_name'] as String,
        totalRuns: (invMap['total_runs'] as int?) ?? 0,
        totalWickets: (invMap['total_wickets'] as int?) ?? 0,
        totalBalls: totalBalls,
        oversText: oversText,
        batting: batting,
        bowling: bowling,
      ));
    }

    return MatchDetail(
      id: m['id'] as String,
      playedAt: DateTime.parse(m['played_at'] as String),
      venue: m['venue'] as String?,
      battingTeamName: m['batting_team_name'] as String,
      bowlingTeamName: m['bowling_team_name'] as String,
      oversLimit: m['overs_limit'] as int,
      resultSummary: m['result_summary'] as String?,
      status: m['status'] as String? ?? 'completed',
      innings: inningsDetails,
    );
  }
}

/// Full match detail with scorecards per innings.
class MatchDetail {
  final String id;
  final DateTime playedAt;
  final String? venue;
  final String battingTeamName;
  final String bowlingTeamName;
  final int oversLimit;
  final String? resultSummary;
  final String status;
  final List<InningsDetail> innings;

  MatchDetail({
    required this.id,
    required this.playedAt,
    this.venue,
    required this.battingTeamName,
    required this.bowlingTeamName,
    required this.oversLimit,
    this.resultSummary,
    required this.status,
    required this.innings,
  });
}

/// One innings with batting and bowling scorecards.
class InningsDetail {
  final int inningsNumber;
  final String battingTeamName;
  final String bowlingTeamName;
  final int totalRuns;
  final int totalWickets;
  final int totalBalls;
  final String oversText;
  final List<BattingEntry> batting;
  final List<BowlingEntry> bowling;

  InningsDetail({
    required this.inningsNumber,
    required this.battingTeamName,
    required this.bowlingTeamName,
    required this.totalRuns,
    required this.totalWickets,
    required this.totalBalls,
    required this.oversText,
    required this.batting,
    required this.bowling,
  });
}

class MatchSummary {
  final String id;
  final DateTime playedAt;
  final String? venue;
  final String battingTeamName;
  final String bowlingTeamName;
  final int oversLimit;
  final String? resultSummary;
  final String status;
  final List<InningsSummary> innings;

  MatchSummary({
    required this.id,
    required this.playedAt,
    this.venue,
    required this.battingTeamName,
    required this.bowlingTeamName,
    required this.oversLimit,
    this.resultSummary,
    required this.status,
    required this.innings,
  });
}

class InningsSummary {
  final int totalRuns;
  final int totalWickets;
  final int totalBalls;

  InningsSummary({
    required this.totalRuns,
    required this.totalWickets,
    required this.totalBalls,
  });

  String get oversText {
    final completed = totalBalls ~/ 6;
    final balls = totalBalls % 6;
    return '$completed.$balls';
  }
}

/// One batsman's entry for the scorecard.
class BattingEntry {
  final String playerName;
  final int runs;
  final int ballsFaced;
  final int fours;
  final int sixes;
  final String? outType;

  BattingEntry({
    required this.playerName,
    this.runs = 0,
    this.ballsFaced = 0,
    this.fours = 0,
    this.sixes = 0,
    this.outType,
  });
}

/// One bowler's entry for the scorecard.
class BowlingEntry {
  final String playerName;
  final int ballsBowled;
  final int maidens;
  final int runsConceded;
  final int wickets;
  final int wides;
  final int noBalls;

  BowlingEntry({
    required this.playerName,
    this.ballsBowled = 0,
    this.maidens = 0,
    this.runsConceded = 0,
    this.wickets = 0,
    this.wides = 0,
    this.noBalls = 0,
  });

  String get oversText {
    final o = ballsBowled ~/ 6;
    final b = ballsBowled % 6;
    return '$o.$b';
  }
}
