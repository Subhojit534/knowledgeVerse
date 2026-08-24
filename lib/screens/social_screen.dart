import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/player_profile.dart';
import '../models/pvp_models.dart';
import '../services/api_service.dart';
import '../services/pvp_service.dart';
import 'pvp/pvp_arena_hub_screen.dart';
import 'pvp/pvp_battle_screen.dart';




class FriendModel {
  final String id;
  final String name;
  final String title;
  final int level;
  final int xp;
  final String avatarInitial;
  final Color avatarColor;
  final String district;
  final bool isOnline;
  final String lastActive;
  final int streakDays;
  final String guildName;
  final Map<String, double> subjectProgress;

  const FriendModel({
    required this.id,
    required this.name,
    required this.title,
    required this.level,
    required this.xp,
    required this.avatarInitial,
    required this.avatarColor,
    required this.district,
    required this.isOnline,
    required this.lastActive,
    required this.streakDays,
    required this.guildName,
    required this.subjectProgress,
  });
}

class PendingFriendRequestModel {
  final String friendshipId;
  final FriendModel user;

  const PendingFriendRequestModel({
    required this.friendshipId,
    required this.user,
  });
}

class GuildModel {
  final String id;
  final String name;
  final String tag;
  final String motto;
  final int memberCount;
  final int maxMembers;
  final int level;

  const GuildModel({
    required this.id,
    required this.name,
    required this.tag,
    required this.motto,
    required this.memberCount,
    required this.maxMembers,
    required this.level,
  });
}

class GuildMemberModel {
  final String id;
  final String name;
  final String role;
  final int level;
  final int weeklyXp;
  final bool isOnline;

  const GuildMemberModel({
    required this.id,
    required this.name,
    required this.role,
    required this.level,
    required this.weeklyXp,
    required this.isOnline,
  });
}

class GuildChatMessage {
  final String sender;
  final String role;
  final String text;
  final String time;

  const GuildChatMessage({
    required this.sender,
    required this.role,
    required this.text,
    required this.time,
  });
}

class SocialScreen extends StatefulWidget {
  const SocialScreen({super.key});

  @override
  State<SocialScreen> createState() => _SocialScreenState();
}

class _SocialScreenState extends State<SocialScreen> {
  int _activeRailIndex = 0; // 0: Friends, 1: Guild, 2: Add
  int _guildSubTab = 0; // 0: My Guild, 1: Create Guild, 2: Join Guild

  FriendModel? _selectedFriend;
  List<FriendModel> _allAvailableProfiles = [];
  List<FriendModel> _myAcceptedFriends = [];
  List<PendingFriendRequestModel> _pendingReceivedList = [];
  Set<String> _pendingSentFriendIds = {};
  List<PvPChallengeItem> _incomingDuelChallenges = [];

  // Guild State
  bool _hasGuild = false;
  String _myGuildId = '';
  String _myGuildName = '';
  String _myGuildTag = '';
  String _myGuildMotto = '';
  String _myGuildRole = 'Member';
  List<GuildMemberModel> _guildMembers = [];
  List<GuildChatMessage> _chatMessages = [];
  List<GuildModel> _publicGuilds = [];

  // Form Controllers
  final TextEditingController _createGuildNameController = TextEditingController();
  final TextEditingController _createGuildTagController = TextEditingController();
  final TextEditingController _createGuildMottoController = TextEditingController();
  final TextEditingController _chatController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  Timer? _chatPollTimer;
  Timer? _duelPollTimer;
  String _myPlayerName = 'Explorer';
  String _myUserId = 'demo-user-123';
  bool _isAutoJoiningDuel = false;
  bool _isRespondingToDuel = false;
  List<PvPChallengeItem> _sentDuelChallenges = [];
  final Set<String> _consumedChallengeIds = {};
  final Set<String> _mySentChallengeIds = {};

  @override
  void initState() {
    super.initState();
    _loadStateAndProfiles();
    _startChatPollingTimer();
    _startDuelPollingTimer();
  }

  @override
  void dispose() {
    _chatPollTimer?.cancel();
    _duelPollTimer?.cancel();
    _createGuildNameController.dispose();
    _createGuildTagController.dispose();
    _createGuildMottoController.dispose();
    _chatController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _startDuelPollingTimer() {
    _duelPollTimer?.cancel();
    _duelPollTimer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_activeRailIndex == 0 && !_isAutoJoiningDuel) {
        _loadDuelChallenges();
      }
    });
  }

  Future<void> _loadDuelChallenges() async {
    try {
      final challenges = await PvPService.getChallenges();
      if (!mounted) return;

      final received = (challenges['received'] ?? []).where((c) => !_consumedChallengeIds.contains(c.id)).toList();
      final sent = (challenges['sent'] ?? []).where((c) => !_consumedChallengeIds.contains(c.id)).toList();

      setState(() {
        _incomingDuelChallenges = received;
        _sentDuelChallenges = sent;
      });

      // Check if any sent challenge was ACCEPTED by friend -> AUTOMATICALLY START MATCH!
      if (!_isAutoJoiningDuel) {
        final acceptedChallenge = sent.firstWhere(
          (c) => c.status == 'active' &&
                 c.sessionId != null &&
                 c.sessionId!.isNotEmpty &&
                 !_consumedChallengeIds.contains(c.id) &&
                 (_mySentChallengeIds.contains(c.id) || _mySentChallengeIds.contains(c.challengedId) || c.challengerId == _myUserId || c.challengerName.toLowerCase() == _myPlayerName.toLowerCase()),
          orElse: () => PvPChallengeItem(
            id: '',
            challengerId: '',
            challengerName: '',
            challengedId: '',
            challengedName: '',
            subject: '',
            stakeCoins: 0,
            status: '',
            createdAt: '',
          ),
        );

        if (acceptedChallenge.id.isNotEmpty && acceptedChallenge.sessionId != null) {
          _isAutoJoiningDuel = true;
          _consumedChallengeIds.add(acceptedChallenge.id);

          final session = await PvPService.getSession(acceptedChallenge.sessionId!);
          if (session != null && mounted) {
            PvPService.consumeChallenge(challengeId: acceptedChallenge.id, sessionId: session.id);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('⚔️ DUEL ACCEPTED BY ${acceptedChallenge.challengedName?.toUpperCase() ?? "FRIEND"}! STARTING MATCH...',
                    style: GoogleFonts.pressStart2p(fontSize: 7.5, color: Colors.black)),
                backgroundColor: const Color(0xFFF2CA50),
                duration: const Duration(seconds: 2),
              ),
            );

            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => PvPBattleScreen(session: session)),
            );

            if (mounted) {
              _isAutoJoiningDuel = false;
              _loadStateAndProfiles();
              _loadDuelChallenges();
            }
          } else {
            _isAutoJoiningDuel = false;
          }
        }
      }
    } catch (_) {}
  }


  Future<void> _acceptDuelChallenge(PvPChallengeItem challenge) async {
    if (_isRespondingToDuel) return;
    setState(() => _isRespondingToDuel = true);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('ACCEPTING DUEL... ⚔️', style: GoogleFonts.pressStart2p(fontSize: 7.5, color: Colors.black)),
        backgroundColor: const Color(0xFF82C0A0),
        duration: const Duration(seconds: 1),
      ),
    );

    try {
      PvPSession? session = await PvPService.respondToChallenge(
        challengeId: challenge.id,
        accept: true,
        subject: challenge.subject,
      );

      // Fallback: If session not returned directly, check by challenge session ID
      if (session == null && challenge.sessionId != null && challenge.sessionId!.isNotEmpty) {
        session = await PvPService.getSession(challenge.sessionId!);
      }

      if (session == null) {
        final freshChallenges = await PvPService.getChallenges();
        final match = (freshChallenges['received'] ?? []).firstWhere(
          (c) => c.id == challenge.id,
          orElse: () => challenge,
        );
        if (match.sessionId != null && match.sessionId!.isNotEmpty) {
          session = await PvPService.getSession(match.sessionId!);
        }
      }

      if (session != null && mounted) {
        _isAutoJoiningDuel = true;
        _consumedChallengeIds.add(challenge.id);
        PvPService.consumeChallenge(challengeId: challenge.id, sessionId: session.id);

        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PvPBattleScreen(session: session!),
          ),
        );
        if (mounted) {
          _isAutoJoiningDuel = false;
          _loadStateAndProfiles();
          _loadDuelChallenges();
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('COULD NOT CONNECT TO DUEL. Try again.', style: GoogleFonts.pressStart2p(fontSize: 7.5, color: Colors.white)),
            backgroundColor: const Color(0xFFFF6B6B),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isRespondingToDuel = false);
    }
  }

  Future<void> _declineDuelChallenge(PvPChallengeItem challenge) async {
    _consumedChallengeIds.add(challenge.id);
    await PvPService.respondToChallenge(
      challengeId: challenge.id,
      accept: false,
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('DUEL DECLINED', style: GoogleFonts.pressStart2p(fontSize: 7.5, color: Colors.white)),
          backgroundColor: const Color(0xFF28283D),
        ),
      );
      _loadDuelChallenges();
    }
  }


  Future<void> _joinActiveDuel(PvPChallengeItem challenge) async {

    if (challenge.sessionId == null || challenge.sessionId!.isEmpty) return;
    _consumedChallengeIds.add(challenge.id);
    PvPService.consumeChallenge(challengeId: challenge.id, sessionId: challenge.sessionId);

    final session = await PvPService.getSession(challenge.sessionId!);
    if (session != null && mounted) {
      _isAutoJoiningDuel = true;
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PvPBattleScreen(session: session)),
      );
      if (mounted) {
        _isAutoJoiningDuel = false;
        _loadStateAndProfiles();
        _loadDuelChallenges();
      }
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('SESSION HAS EXPIRED', style: GoogleFonts.pressStart2p(fontSize: 7.5, color: Colors.white)),
          backgroundColor: const Color(0xFFFF6B6B),
        ),
      );
    }
  }

  void _startChatPollingTimer() {


    _chatPollTimer?.cancel();
    _chatPollTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      // Poll automatically whenever guild tab is active and user is in a guild
      if (_activeRailIndex == 1 && _hasGuild && _myGuildId.isNotEmpty) {
        _pollGuildMessages();
      }
    });
  }


  Future<void> _pollGuildMessages() async {
    if (!_hasGuild || _myGuildId.isEmpty) return;
    try {
      final res = await ApiService.get('/api/guilds/messages?guildId=$_myGuildId');
      if (res.statusCode == 200 && mounted) {
        final data = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
        final messagesList = data['messages'] as List<dynamic>? ?? [];
        final newMessages = messagesList.map((msg) {
          final m = msg as Map<String, dynamic>;
          final timeStr = m['created_at'] != null
              ? DateTime.tryParse(m['created_at'] as String)?.toLocal().toString().substring(11, 16) ?? 'Now'
              : 'Now';
          return GuildChatMessage(
            sender: m['sender_name'] as String? ?? 'Scholar',
            role: m['role'] as String? ?? 'Member',
            text: m['text'] as String? ?? '',
            time: timeStr,
          );
        }).toList();

        // Only setState if new messages arrived
        if (newMessages.length != _chatMessages.length ||
            (newMessages.isNotEmpty && _chatMessages.isNotEmpty && newMessages.last.text != _chatMessages.last.text)) {
          if (mounted) {
            setState(() {
              _chatMessages = newMessages;
            });
          }
        }
      }
    } catch (_) {}
  }

  Future<void> _loadStateAndProfiles() async {
    final profile = PlayerProfile.current ?? await PlayerProfile.load();
    if (profile != null) {
      if (profile.name.trim().isNotEmpty) _myPlayerName = profile.name.trim();
      if (profile.id.trim().isNotEmpty) _myUserId = profile.id.trim();
    }

    try {
      // 1. Fast Unified Dashboard (single-hop parallel request <0.3s)
      final dashboardRes = await ApiService.get('/api/social/dashboard?userId=$_myUserId');
      if (dashboardRes.statusCode == 200) {
        final data = jsonDecode(utf8.decode(dashboardRes.bodyBytes)) as Map<String, dynamic>;

        final rawExplorers = data['availableExplorers'] as List<dynamic>? ?? [];
        final rawFriends = data['friends'] as List<dynamic>? ?? [];
        final rawPendingReceived = data['pendingReceived'] as List<dynamic>? ?? [];
        final rawPendingSent = data['pendingSent'] as List<dynamic>? ?? [];
        final g = data['myGuild'] as Map<String, dynamic>?;
        final membersList = data['guildMembers'] as List<dynamic>? ?? [];
        final messagesList = data['guildMessages'] as List<dynamic>? ?? [];
        final guildsList = data['publicGuilds'] as List<dynamic>? ?? [];

        final colors = [
          const Color(0xFFDEB7FF),
          const Color(0xFF60A5FA),
          const Color(0xFFF2CA50),
          const Color(0xFF82C0A0)
        ];

        FriendModel parseFriendModel(Map<String, dynamic> p, int i) {
          final name = (p['name'] as String? ?? 'Explorer').trim();
          final initial = name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'E';
          return FriendModel(
            id: p['id'] as String? ?? 'f_$i',
            name: name,
            title: p['title'] as String? ?? p['learning_goal'] as String? ?? 'Civilization Architect',
            level: p['level'] as int? ?? 1,
            xp: p['xp'] as int? ?? 100,
            avatarInitial: initial,
            avatarColor: colors[i % colors.length],
            district: p['district'] as String? ?? 'Academy District',
            isOnline: true,
            lastActive: 'Active Now',
            streakDays: p['streakDays'] as int? ?? p['streak_days'] as int? ?? 7,
            guildName: p['guildName'] as String? ?? p['guild_name'] as String? ?? 'Academy District',
            subjectProgress: {'Math': 0.85, 'CS': 0.90, 'Physics': 0.75},
          );
        }

        final parsedExplorers = <FriendModel>[];
        for (int i = 0; i < rawExplorers.length; i++) {
          parsedExplorers.add(parseFriendModel(rawExplorers[i] as Map<String, dynamic>, i));
        }

        final parsedFriends = <FriendModel>[];
        for (int i = 0; i < rawFriends.length; i++) {
          parsedFriends.add(parseFriendModel(rawFriends[i] as Map<String, dynamic>, i));
        }

        final parsedPendingReceived = <PendingFriendRequestModel>[];
        for (int i = 0; i < rawPendingReceived.length; i++) {
          final item = rawPendingReceived[i] as Map<String, dynamic>;
          final u = item['user'] as Map<String, dynamic>? ?? {};
          parsedPendingReceived.add(PendingFriendRequestModel(
            friendshipId: item['friendshipId'] as String? ?? 'req_$i',
            user: parseFriendModel(u, i),
          ));
        }

        final parsedPendingSent = <String>{};
        for (final item in rawPendingSent) {
          parsedPendingSent.add(item.toString());
        }

        // Parse Guild Data
        if (g != null) {
          _hasGuild = true;
          _myGuildId = g['id'] as String? ?? '';
          _myGuildName = g['name'] as String? ?? '';
          _myGuildTag = g['tag'] as String? ?? '';
          _myGuildMotto = g['motto'] as String? ?? '';

          _guildMembers = membersList.map((m) {
            final mm = m as Map<String, dynamic>;
            return GuildMemberModel(
              id: mm['user_id'] as String? ?? mm['id'] as String? ?? '',
              name: mm['name'] as String? ?? 'Scholar',
              role: mm['role'] as String? ?? 'Member',
              level: mm['level'] as int? ?? 1,
              weeklyXp: mm['weekly_xp'] as int? ?? 0,
              isOnline: mm['is_online'] as bool? ?? true,
            );
          }).toList();

          final meMember = _guildMembers.firstWhere(
            (m) => m.id == _myUserId || m.name.toLowerCase() == _myPlayerName.toLowerCase(),
            orElse: () => GuildMemberModel(id: _myUserId, name: _myPlayerName, role: 'Member', level: 1, weeklyXp: 0, isOnline: true),
          );
          _myGuildRole = meMember.role;

          _chatMessages = messagesList.map((msg) {
            final m = msg as Map<String, dynamic>;
            final timeStr = m['created_at'] != null
                ? DateTime.tryParse(m['created_at'] as String)?.toLocal().toString().substring(11, 16) ?? 'Now'
                : 'Now';
            return GuildChatMessage(
              sender: m['sender_name'] as String? ?? 'Scholar',
              role: m['role'] as String? ?? 'Member',
              text: m['text'] as String? ?? '',
              time: timeStr,
            );
          }).toList();
        } else {
          _hasGuild = false;
          _myGuildId = '';
          _myGuildName = '';
          _myGuildTag = '';
          _myGuildMotto = '';
          _guildMembers = [];
          _chatMessages = [];
        }

        _publicGuilds = guildsList.map((gItem) {
          final gg = gItem as Map<String, dynamic>;
          return GuildModel(
            id: gg['id'] as String? ?? '',
            name: gg['name'] as String? ?? '',
            tag: gg['tag'] as String? ?? '',
            motto: gg['motto'] as String? ?? '',
            memberCount: gg['member_count'] as int? ?? 1,
            maxMembers: gg['max_members'] as int? ?? 20,
            level: gg['level'] as int? ?? 1,
          );
        }).toList();

        if (mounted) {
          setState(() {
            _allAvailableProfiles = parsedExplorers;
            _myAcceptedFriends = parsedFriends;
            _pendingReceivedList = parsedPendingReceived;
            _pendingSentFriendIds = parsedPendingSent;
            if (_myAcceptedFriends.isNotEmpty && _selectedFriend == null) {
              _selectedFriend = _myAcceptedFriends.first;
            }
          });
        }
      } else {
        // Fallback: Parallel requests
        await Future.wait([
          _loadFriendsDataFallback(),
          _loadGuildData(),
        ]);
      }
      await _loadDuelChallenges();
    } catch (e) {
      debugPrint('❌ [SocialScreen Load Error]: $e');
    }
  }


  Future<void> _loadFriendsDataFallback() async {
    try {
      final friendsRes = await ApiService.get('/api/social/friends?userId=$_myUserId');
      if (friendsRes.statusCode == 200 && mounted) {
        final data = jsonDecode(utf8.decode(friendsRes.bodyBytes)) as Map<String, dynamic>;
        final rawExplorers = data['availableExplorers'] as List<dynamic>? ?? [];
        final rawFriends = data['friends'] as List<dynamic>? ?? [];
        final colors = [
          const Color(0xFFDEB7FF),
          const Color(0xFF60A5FA),
          const Color(0xFFF2CA50),
          const Color(0xFF82C0A0)
        ];

        FriendModel parseFriendModel(Map<String, dynamic> p, int i) {
          final name = (p['name'] as String? ?? 'Explorer').trim();
          return FriendModel(
            id: p['id'] as String? ?? 'f_$i',
            name: name,
            title: p['title'] as String? ?? p['learning_goal'] as String? ?? 'Civilization Architect',
            level: p['level'] as int? ?? 1,
            xp: p['xp'] as int? ?? 100,
            avatarInitial: name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'E',
            avatarColor: colors[i % colors.length],
            district: p['district'] as String? ?? 'Academy District',
            isOnline: true,
            lastActive: 'Active Now',
            streakDays: p['streakDays'] as int? ?? p['streak_days'] as int? ?? 7,
            guildName: p['guildName'] as String? ?? p['guild_name'] as String? ?? 'Academy District',
            subjectProgress: {'Math': 0.85, 'CS': 0.90, 'Physics': 0.75},
          );
        }

        setState(() {
          _allAvailableProfiles = rawExplorers.asMap().entries.map((e) => parseFriendModel(e.value, e.key)).toList();
          _myAcceptedFriends = rawFriends.asMap().entries.map((e) => parseFriendModel(e.value, e.key)).toList();
        });
      }
    } catch (_) {}
  }

  Future<void> _loadGuildData() async {
    final profile = PlayerProfile.current ?? await PlayerProfile.load();
    if (profile != null) {
      if (profile.name.trim().isNotEmpty) _myPlayerName = profile.name.trim();
      if (profile.id.trim().isNotEmpty) _myUserId = profile.id.trim();
    }

    try {
      // Execute both in parallel
      final results = await Future.wait([
        ApiService.get('/api/guilds/my?userId=$_myUserId'),
        ApiService.get('/api/guilds'),
      ]);

      final myGuildRes = results[0];
      final allGuildsRes = results[1];

      if (myGuildRes.statusCode == 200) {
        final data = jsonDecode(utf8.decode(myGuildRes.bodyBytes)) as Map<String, dynamic>;
        final g = data['guild'] as Map<String, dynamic>?;
        final membersList = data['members'] as List<dynamic>? ?? [];
        final messagesList = data['messages'] as List<dynamic>? ?? [];

        if (g != null) {
          _hasGuild = true;
          _myGuildId = g['id'] as String? ?? '';
          _myGuildName = g['name'] as String? ?? '';
          _myGuildTag = g['tag'] as String? ?? '';
          _myGuildMotto = g['motto'] as String? ?? '';

          _guildMembers = membersList.map((m) {
            final mm = m as Map<String, dynamic>;
            return GuildMemberModel(
              id: mm['user_id'] as String? ?? mm['id'] as String? ?? '',
              name: mm['name'] as String? ?? 'Scholar',
              role: mm['role'] as String? ?? 'Member',
              level: mm['level'] as int? ?? 1,
              weeklyXp: mm['weekly_xp'] as int? ?? 0,
              isOnline: mm['is_online'] as bool? ?? true,
            );
          }).toList();

          final meMember = _guildMembers.firstWhere(
            (m) => m.id == _myUserId || m.name.toLowerCase() == _myPlayerName.toLowerCase(),
            orElse: () => GuildMemberModel(id: _myUserId, name: _myPlayerName, role: 'Member', level: 1, weeklyXp: 0, isOnline: true),
          );
          _myGuildRole = meMember.role;

          _chatMessages = messagesList.map((msg) {
            final m = msg as Map<String, dynamic>;
            final timeStr = m['created_at'] != null
                ? DateTime.tryParse(m['created_at'] as String)?.toLocal().toString().substring(11, 16) ?? 'Now'
                : 'Now';
            return GuildChatMessage(
              sender: m['sender_name'] as String? ?? 'Scholar',
              role: m['role'] as String? ?? 'Member',
              text: m['text'] as String? ?? '',
              time: timeStr,
            );
          }).toList();
        } else {
          _hasGuild = false;
          _myGuildId = '';
          _myGuildName = '';
          _myGuildTag = '';
          _myGuildMotto = '';
          _guildMembers = [];
          _chatMessages = [];
        }
      }

      if (allGuildsRes.statusCode == 200) {
        final data = jsonDecode(utf8.decode(allGuildsRes.bodyBytes)) as Map<String, dynamic>;
        final guildsList = data['guilds'] as List<dynamic>? ?? [];
        _publicGuilds = guildsList.map((g) {
          final gg = g as Map<String, dynamic>;
          return GuildModel(
            id: gg['id'] as String? ?? '',
            name: gg['name'] as String? ?? '',
            tag: gg['tag'] as String? ?? '',
            motto: gg['motto'] as String? ?? '',
            memberCount: gg['member_count'] as int? ?? 1,
            maxMembers: gg['max_members'] as int? ?? 20,
            level: gg['level'] as int? ?? 1,
          );
        }).toList();
      }

      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('❌ [Load Guild Error]: $e');
    }
  }

  Future<void> _sendFriendRequest(FriendModel target) async {
    setState(() {
      _pendingSentFriendIds.add(target.id);
    });

    try {
      final res = await ApiService.post('/api/social/friends/request', body: {
        'requesterId': _myUserId,
        'addresseeId': target.id,
      });
      if (res.statusCode == 200 && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('FRIEND REQUEST SENT TO ${target.name.toUpperCase()}!')),
        );
      }
    } catch (e) {
      debugPrint('❌ [Send Request Error]: $e');
    }
  }

  Future<void> _respondFriendRequest(PendingFriendRequestModel pending, bool accept) async {
    try {
      final res = await ApiService.post('/api/social/friends/respond', body: {
        'friendshipId': pending.friendshipId,
        'accept': accept,
      });
      if (res.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(accept
                  ? 'ACCEPTED ${pending.user.name.toUpperCase()} AS A FRIEND!'
                  : 'DECLINED FRIEND REQUEST.'),
            ),
          );
        }
        await _loadStateAndProfiles();
      }
    } catch (e) {
      debugPrint('❌ [Respond Request Error]: $e');
    }
  }

  Future<void> _createGuild() async {
    final name = _createGuildNameController.text.trim();
    final tag = _createGuildTagController.text.trim().toUpperCase();
    final motto = _createGuildMottoController.text.trim();

    if (name.isEmpty || tag.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PLEASE ENTER GUILD NAME AND TAG!')),
      );
      return;
    }

    try {
      final res = await ApiService.post('/api/guilds/create', body: {
        'leaderId': _myUserId,
        'name': name,
        'tag': tag,
        'motto': motto.isNotEmpty ? motto : 'Knowledge is the Ultimate Spell',
      });

      if (res.statusCode == 200) {
        _createGuildNameController.clear();
        _createGuildTagController.clear();
        _createGuildMottoController.clear();

        await _loadGuildData();
        if (mounted) {
          setState(() {
            _guildSubTab = 0;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('GUILD "$name" CREATED! YOU ARE GUILD LEADER.')),
          );
        }
      }
    } catch (e) {
      debugPrint('❌ [Create Guild Error]: $e');
    }
  }

  Future<void> _joinGuild(GuildModel guild) async {
    try {
      final res = await ApiService.post('/api/guilds/join', body: {
        'userId': _myUserId,
        'guildId': guild.id,
      });

      if (res.statusCode == 200) {
        await _loadGuildData();
        if (mounted) {
          setState(() {
            _guildSubTab = 0;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('JOINED GUILD "${guild.name}"!')),
          );
        }
      }
    } catch (e) {
      debugPrint('❌ [Join Guild Error]: $e');
    }
  }

  Future<void> _leaveGuild() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E32),
        shape: const RoundedRectangleBorder(
          side: BorderSide(color: Color(0xFFFF6B6B), width: 2),
        ),
        title: Row(
          children: [
            const Icon(Icons.exit_to_app_rounded, color: Color(0xFFFF6B6B)),
            const SizedBox(width: 8),
            Text('LEAVE GUILD?', style: GoogleFonts.pressStart2p(fontSize: 10, color: const Color(0xFFFF6B6B))),
          ],
        ),
        content: Text(
          'Are you sure you want to leave "$_myGuildName"?',
          style: GoogleFonts.pressStart2p(fontSize: 7.5, color: const Color(0xFFD0C5AF), height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('CANCEL', style: GoogleFonts.pressStart2p(fontSize: 8, color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF93000A),
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('LEAVE GUILD', style: GoogleFonts.pressStart2p(fontSize: 8)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ApiService.post('/api/guilds/leave', body: {
          'userId': _myUserId,
          'guildId': _myGuildId,
        });
        await _loadGuildData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('YOU HAVE LEFT THE GUILD.')),
          );
        }
      } catch (e) {
        debugPrint('❌ [Leave Guild Error]: $e');
      }
    }
  }

  Future<void> _sendGuildChatMessage() async {
    final text = _chatController.text.trim();
    if (text.isEmpty || !_hasGuild || _myGuildId.isEmpty) return;

    _chatController.clear();

    // 0ms Optimistic UI Append
    final now = DateTime.now();
    final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final optimisticMsg = GuildChatMessage(
      sender: _myPlayerName,
      role: _myGuildRole,
      text: text,
      time: timeStr,
    );

    setState(() {
      _chatMessages.add(optimisticMsg);
    });

    try {
      final res = await ApiService.post('/api/guilds/chat', body: {
        'guildId': _myGuildId,
        'senderId': _myUserId,
        'text': text,
      });

      if (res.statusCode == 200) {
        _pollGuildMessages();
      }
    } catch (e) {
      debugPrint('❌ [Send Guild Chat Error]: $e');
    }
  }

  void _challengeFriend(FriendModel friend) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E32),
        shape: const RoundedRectangleBorder(
          side: BorderSide(color: Color(0xFFF2CA50), width: 2),
        ),
        title: Row(
          children: [
            const Icon(Icons.sports_esports_rounded, color: Color(0xFFF2CA50)),
            const SizedBox(width: 10),
            Text('QUIZ DUEL', style: GoogleFonts.pressStart2p(fontSize: 11, color: const Color(0xFFF2CA50))),
          ],
        ),
        content: Text(
          'Challenge ${friend.name} to a speed quiz duel in ${friend.district}?\n\nENTRY STAKE: 50 COINS 🪙',
          style: GoogleFonts.pressStart2p(fontSize: 8, color: const Color(0xFFD0C5AF), height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('CANCEL', style: GoogleFonts.pressStart2p(fontSize: 8, color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFF2CA50),
              foregroundColor: Colors.black,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('SEND DUEL', style: GoogleFonts.pressStart2p(fontSize: 8)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        _mySentChallengeIds.add(friend.id);

        final res = await ApiService.post('/api/pvp/challenge', body: {
          'challengerId': _myUserId,
          'challengedId': friend.id,
          'challengerName': _myPlayerName,
          'challengedName': friend.name,
          'subject': friend.district.isNotEmpty ? friend.district : 'Mathematics',
          'stakeCoins': 50,
        });

        if (res.statusCode == 200) {
          final data = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
          final duelObj = data['duel'] as Map<String, dynamic>?;
          if (duelObj != null && duelObj['id'] != null) {
            _mySentChallengeIds.add(duelObj['id'].toString());
          }
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('DUEL CHALLENGE SENT TO ${friend.name.toUpperCase()}!',
                  style: GoogleFonts.pressStart2p(fontSize: 8, color: Colors.white)),
              backgroundColor: const Color(0xFF1E1E32),
              action: SnackBarAction(
                label: 'ARENA',
                textColor: const Color(0xFFF2CA50),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PvPArenaHubScreen()),
                  );
                },
              ),
            ),
          );
          _loadDuelChallenges();
        }
      } catch (e) {
        debugPrint('❌ [Duel Challenge Error]: $e');
      }
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopHeaderBar(context),
            Expanded(
              child: Row(
                children: [
                  _buildNavRail(),
                  Container(width: 2, color: const Color(0xFFF2CA50)),
                  SizedBox(
                    width: 280,
                    child: _buildMasterPanel(),
                  ),
                  Container(width: 2, color: const Color(0xFF4D4635)),
                  Expanded(
                    child: _buildDetailInspectorPanel(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopHeaderBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0xFF1E1E32),
        border: Border(bottom: BorderSide(color: Color(0xFFF2CA50), width: 2)),
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF28283D),
                border: Border.all(color: const Color(0xFFF2CA50), width: 2),
              ),
              child: Row(
                children: [
                  const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFFF2CA50), size: 12),
                  const SizedBox(width: 4),
                  Text('BACK', style: GoogleFonts.pressStart2p(fontSize: 8, color: const Color(0xFFF2CA50))),
                ],
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Row(
              children: [
                const Icon(Icons.groups_rounded, color: Color(0xFFF2CA50), size: 18),
                const SizedBox(width: 8),
                Text(
                  'SOCIAL & GUILD HALL',
                  style: GoogleFonts.pressStart2p(fontSize: 10, color: const Color(0xFFF2CA50)),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF28283D),
              border: Border.all(color: const Color(0xFF82C0A0), width: 1.5),
            ),
            child: Row(
              children: [
                Container(width: 8, height: 8, color: const Color(0xFF82C0A0)),
                const SizedBox(width: 6),
                Text('ONLINE', style: GoogleFonts.pressStart2p(fontSize: 7, color: const Color(0xFF82C0A0))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavRail() {
    final navItems = [
      {'label': 'FRIENDS', 'icon': Icons.people_alt_rounded},
      {'label': 'GUILD', 'icon': Icons.shield_rounded},
      {'label': 'ADD', 'icon': Icons.person_add_alt_1_rounded},
    ];

    return Container(
      width: 115,
      color: const Color(0xFF141424),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: List.generate(navItems.length, (idx) {
            final isSelected = _activeRailIndex == idx;
            final item = navItems[idx];
            return GestureDetector(
              onTap: () {
                setState(() => _activeRailIndex = idx);
                if (idx == 1) {
                  _loadGuildData();
                }
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF28283D) : const Color(0xFF1B1B2C),
                  border: Border.all(
                    color: isSelected ? const Color(0xFFF2CA50) : const Color(0xFF3C382A),
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(item['icon'] as IconData,
                        color: isSelected ? const Color(0xFFF2CA50) : const Color(0xFF8C867A), size: 20),
                    const SizedBox(height: 6),
                    Text(
                      item['label'] as String,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.pressStart2p(
                        fontSize: 7.5,
                        color: isSelected ? const Color(0xFFF2CA50) : const Color(0xFF8C867A),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }


  Widget _buildMasterPanel() {
    return Container(
      color: const Color(0xFF18182B),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _activeRailIndex == 0
                ? 'MY FRIENDS (${_myAcceptedFriends.length})'
                : _activeRailIndex == 1
                    ? 'GUILD HALL'
                    : 'SEARCH SCHOLARS',
            style: GoogleFonts.pressStart2p(fontSize: 8, color: const Color(0xFFF2CA50)),
          ),
          const SizedBox(height: 10),
          Expanded(child: _buildMasterContent()),
        ],
      ),
    );
  }

  Widget _buildMasterContent() {
    if (_activeRailIndex == 0) {
      // FRIENDS TAB
      if (_incomingDuelChallenges.isEmpty && _pendingReceivedList.isEmpty && _myAcceptedFriends.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(16),
          color: const Color(0xFF1E1E32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.people_outline_rounded, color: Color(0xFFF2CA50), size: 36),
              const SizedBox(height: 12),
              Text('NO FRIENDS YET', style: GoogleFonts.pressStart2p(fontSize: 9, color: const Color(0xFFF2CA50))),
              const SizedBox(height: 8),
              Text(
                'You have not added any friends yet.\n\nGo to the "ADD" tab, search a scholar\'s name, and send them a request!',
                textAlign: TextAlign.center,
                style: GoogleFonts.pressStart2p(fontSize: 7, color: const Color(0xFFD0C5AF), height: 1.5),
              ),
            ],
          ),
        );
      }

      return ListView(
        children: [
          // Incoming Duel Challenges Section (PROMINENT & ACTIONABLE)
          if (_incomingDuelChallenges.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF2CA50).withOpacity(0.15),
                border: Border.all(color: const Color(0xFFF2CA50)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.flash_on, color: Color(0xFFF2CA50), size: 14),
                  const SizedBox(width: 6),
                  Text(
                    'INCOMING DUEL CHALLENGES (${_incomingDuelChallenges.length})',
                    style: GoogleFonts.pressStart2p(fontSize: 7.5, color: const Color(0xFFF2CA50)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            ..._incomingDuelChallenges.map((duel) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF28283D),
                  border: Border.all(color: const Color(0xFFF2CA50), width: 1.5),
                  boxShadow: const [
                    BoxShadow(color: Colors.black45, offset: Offset(0, 2)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.sports_esports, color: Color(0xFFF2CA50), size: 16),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            duel.challengerName.toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.pressStart2p(fontSize: 8, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${duel.subject} • ${duel.stakeCoins} 🪙 Stake',
                      style: GoogleFonts.jetBrainsMono(fontSize: 9.5, color: const Color(0xFFF2CA50)),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF82C0A0),
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(vertical: 7),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            ),
                            onPressed: () => _acceptDuelChallenge(duel),
                            child: Text('ACCEPT DUEL ⚔️', style: GoogleFonts.pressStart2p(fontSize: 6.5)),
                          ),
                        ),
                        const SizedBox(width: 6),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF6B6B),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          ),
                          onPressed: () => _declineDuelChallenge(duel),
                          child: Text('DECLINE', style: GoogleFonts.pressStart2p(fontSize: 6.5)),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 12),
          ],

          // Outgoing / Sent Duel Challenges Section
          if (_sentDuelChallenges.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF70D6FF).withOpacity(0.15),
                border: Border.all(color: const Color(0xFF70D6FF)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.outbox, color: Color(0xFF70D6FF), size: 14),
                  const SizedBox(width: 6),
                  Text(
                    'OUTGOING DUELS (${_sentDuelChallenges.length})',
                    style: GoogleFonts.pressStart2p(fontSize: 7.5, color: const Color(0xFF70D6FF)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            ..._sentDuelChallenges.map((duel) {
              final bool isAccepted = duel.status == 'active' && duel.sessionId != null && duel.sessionId!.isNotEmpty;

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E32),
                  border: Border.all(color: isAccepted ? const Color(0xFF82C0A0) : const Color(0xFF4D4635), width: isAccepted ? 2 : 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(isAccepted ? Icons.play_circle_fill : Icons.hourglass_top,
                            color: isAccepted ? const Color(0xFF82C0A0) : const Color(0xFF70D6FF), size: 16),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'TO: ${duel.challengedName?.toUpperCase() ?? "FRIEND"}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.pressStart2p(fontSize: 8, color: Colors.white),
                          ),

                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isAccepted
                          ? '⚔️ DUEL ACCEPTED! MATCH IS READY!'
                          : '${duel.subject} • ${duel.stakeCoins} 🪙 • WAITING...',
                      style: GoogleFonts.jetBrainsMono(
                          fontSize: 9.5, color: isAccepted ? const Color(0xFF82C0A0) : const Color(0xFF70D6FF)),
                    ),
                    if (isAccepted) ...[
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF82C0A0),
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 7),
                          ),
                          onPressed: () => _joinActiveDuel(duel),
                          child: Text('JOIN BATTLE NOW! ⚔️', style: GoogleFonts.pressStart2p(fontSize: 7.5)),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }),
            const SizedBox(height: 12),
          ],

          if (_pendingReceivedList.isNotEmpty) ...[
            Text('PENDING REQUESTS (${_pendingReceivedList.length})',
                style: GoogleFonts.pressStart2p(fontSize: 7, color: const Color(0xFFFFB4AB))),
            const SizedBox(height: 6),
            ..._pendingReceivedList.map((req) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B1E1E),
                  border: Border.all(color: const Color(0xFFFF6B6B)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(req.user.name, style: GoogleFonts.pressStart2p(fontSize: 7.5, color: Colors.white)),
                    ),
                    InkWell(
                      onTap: () => _respondFriendRequest(req, true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        color: const Color(0xFF82C0A0),
                        child: Text('ACCEPT', style: GoogleFonts.pressStart2p(fontSize: 6.5, color: Colors.black)),
                      ),
                    ),
                    const SizedBox(width: 6),
                    InkWell(
                      onTap: () => _respondFriendRequest(req, false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                        color: const Color(0xFFFF6B6B),
                        child: Text('DECLINE', style: GoogleFonts.pressStart2p(fontSize: 6.5, color: Colors.black)),
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 12),
          ],


          // Accepted Friends Section
          if (_myAcceptedFriends.isNotEmpty) ...[
            Text('ACCEPTED FRIENDS', style: GoogleFonts.pressStart2p(fontSize: 7, color: const Color(0xFF82C0A0))),
            const SizedBox(height: 6),
            ..._myAcceptedFriends.map((friend) {
              final isSelected = _selectedFriend?.id == friend.id;
              return GestureDetector(
                onTap: () => setState(() => _selectedFriend = friend),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF28283D) : const Color(0xFF1E1E32),
                    border: Border.all(
                      color: isSelected ? const Color(0xFFF2CA50) : const Color(0xFF4D4635),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: const Color(0xFF28283D),
                          border: Border.all(color: friend.avatarColor),
                        ),
                        child: Center(
                          child: Text(
                            friend.avatarInitial,
                            style: GoogleFonts.pressStart2p(fontSize: 10, color: friend.avatarColor),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(friend.name,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.pressStart2p(fontSize: 8, color: Colors.white)),
                            const SizedBox(height: 2),
                            Text(friend.district,
                                style: GoogleFonts.pressStart2p(fontSize: 6.5, color: const Color(0xFFD0C5AF))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ],
      );
    } else if (_activeRailIndex == 1) {
      // GUILD TAB
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              _buildGuildPill(0, 'MY GUILD'),
              const SizedBox(width: 4),
              _buildGuildPill(1, 'CREATE'),
              const SizedBox(width: 4),
              _buildGuildPill(2, 'JOIN'),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(child: _buildGuildTabMasterContent()),
        ],
      );
    } else {
      // ADD FRIENDS TAB (SEARCH ONLY)
      final query = _searchController.text.trim().toLowerCase();
      final searchResults = query.isEmpty
          ? <FriendModel>[]
          : _allAvailableProfiles.where((p) => p.name.toLowerCase().contains(query)).toList();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E32),
              border: Border.all(color: const Color(0xFFF2CA50), width: 1.5),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              style: GoogleFonts.pressStart2p(color: Colors.white, fontSize: 8),
              decoration: InputDecoration(
                hintText: 'TYPE EXPLORER NAME...',
                hintStyle: GoogleFonts.pressStart2p(color: Colors.white38, fontSize: 7),
                isDense: true,
                border: InputBorder.none,
                icon: const Icon(Icons.search, color: Color(0xFFF2CA50), size: 16),
              ),
            ),
          ),
          const SizedBox(height: 10),

          Expanded(
            child: query.isEmpty
                ? Container(
                    padding: const EdgeInsets.all(12),
                    color: const Color(0xFF1E1E32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.search_rounded, color: Color(0xFFF2CA50), size: 32),
                        const SizedBox(height: 10),
                        Text('SEARCH TO ADD FRIENDS',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.pressStart2p(fontSize: 8, color: const Color(0xFFF2CA50))),
                        const SizedBox(height: 6),
                        Text(
                          'Type a user\'s name above to search for them in KnowledgeVerse and send a friend request!',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.pressStart2p(fontSize: 6.5, color: Colors.white70, height: 1.5),
                        ),
                      ],
                    ),
                  )
                : searchResults.isEmpty
                    ? Container(
                        padding: const EdgeInsets.all(12),
                        color: const Color(0xFF1E1E32),
                        child: Center(
                          child: Text('NO EXPLORER FOUND WITH NAME "$query"',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.pressStart2p(fontSize: 7, color: const Color(0xFFFF6B6B))),
                        ),
                      )
                    : ListView.builder(
                        itemCount: searchResults.length,
                        itemBuilder: (ctx, i) {
                          final p = searchResults[i];
                          final isAccepted = _myAcceptedFriends.any((f) => f.id == p.id);
                          final isSent = _pendingSentFriendIds.contains(p.id);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E1E32),
                              border: Border.all(color: const Color(0xFF4D4635)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  color: p.avatarColor,
                                  child: Center(
                                    child: Text(p.avatarInitial,
                                        style: GoogleFonts.pressStart2p(fontSize: 9, color: Colors.black)),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(p.name,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.pressStart2p(fontSize: 7.5, color: Colors.white)),
                                ),
                                InkWell(
                                  onTap: (isAccepted || isSent) ? null : () => _sendFriendRequest(p),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: isAccepted
                                          ? const Color(0xFF28283D)
                                          : isSent
                                              ? const Color(0xFF3C3C50)
                                              : const Color(0xFFF2CA50),
                                      border: Border.all(color: const Color(0xFFF2CA50)),
                                    ),
                                    child: Text(
                                      isAccepted
                                          ? '✓ FRIEND'
                                          : isSent
                                              ? '⌛ SENT'
                                              : '+ SEND REQ',
                                      style: GoogleFonts.pressStart2p(
                                        fontSize: 6.5,
                                        color: (isAccepted || isSent) ? const Color(0xFFF2CA50) : Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      );
    }
  }

  Widget _buildGuildPill(int index, String label) {
    final isSelected = _guildSubTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _guildSubTab = index);
          _loadGuildData();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFF2CA50) : const Color(0xFF1E1E32),
            border: Border.all(color: const Color(0xFFF2CA50)),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.pressStart2p(
              fontSize: 6.5,
              color: isSelected ? Colors.black : const Color(0xFFF2CA50),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGuildTabMasterContent() {
    if (_guildSubTab == 0) {
      // MY GUILD
      if (!_hasGuild) {
        return Container(
          padding: const EdgeInsets.all(16),
          color: const Color(0xFF1E1E32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.shield_outlined, color: Color(0xFFF2CA50), size: 36),
              const SizedBox(height: 12),
              Text('YOU ARE NOT IN A GUILD',
                  style: GoogleFonts.pressStart2p(fontSize: 8.5, color: const Color(0xFFF2CA50))),
              const SizedBox(height: 8),
              Text(
                'You have not joined or created a guild yet.\n\nChoose an option below to found your own guild or join an existing scholar order!',
                textAlign: TextAlign.center,
                style: GoogleFonts.pressStart2p(fontSize: 7, color: Colors.white70, height: 1.5),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF2CA50),
                        foregroundColor: Colors.black,
                      ),
                      onPressed: () => setState(() => _guildSubTab = 1),
                      child: Text('➕ CREATE GUILD', style: GoogleFonts.pressStart2p(fontSize: 6.5)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF82C0A0),
                        foregroundColor: Colors.black,
                      ),
                      onPressed: () => setState(() => _guildSubTab = 2),
                      child: Text('🔍 JOIN GUILD', style: GoogleFonts.pressStart2p(fontSize: 6.5)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Leave Guild Button
          GestureDetector(
            onTap: _leaveGuild,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF2A1010),
                border: Border.all(color: const Color(0xFFFF6B6B), width: 1.5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.exit_to_app_rounded, color: Color(0xFFFF6B6B), size: 14),
                  const SizedBox(width: 6),
                  Text(
                    'LEAVE GUILD',
                    style: GoogleFonts.pressStart2p(fontSize: 7.5, color: const Color(0xFFFF6B6B)),
                  ),
                ],
              ),
            ),
          ),

          // Real Members List from DB
          Text(
            'GUILD MEMBERS (${_guildMembers.length})',
            style: GoogleFonts.pressStart2p(fontSize: 7, color: const Color(0xFFF2CA50)),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: ListView.builder(
              itemCount: _guildMembers.length,
              itemBuilder: (ctx, i) {
                final m = _guildMembers[i];
                final isMe = m.id == _myUserId || m.name.toLowerCase() == _myPlayerName.toLowerCase();
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isMe ? const Color(0xFF1E3A28) : const Color(0xFF1E1E32),
                    border: Border.all(
                      color: isMe ? const Color(0xFF4ADE80) : const Color(0xFF4D4635),
                      width: isMe ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isMe ? '${m.name} (YOU)' : m.name,
                        style: GoogleFonts.pressStart2p(
                          fontSize: 7.5,
                          color: isMe ? const Color(0xFF4ADE80) : Colors.white,
                        ),
                      ),
                      Text(
                        m.role,
                        style: GoogleFonts.pressStart2p(
                          fontSize: 6.5,
                          color: isMe ? const Color(0xFFF2CA50) : const Color(0xFFD0C5AF),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      );
    } else if (_guildSubTab == 1) {
      // CREATE GUILD FORM
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildGuildFormField('GUILD NAME', _createGuildNameController, 'e.g. Order of Arcanists'),
            const SizedBox(height: 8),
            _buildGuildFormField('GUILD TAG', _createGuildTagController, 'e.g. ARC'),
            const SizedBox(height: 8),
            _buildGuildFormField('GUILD MOTTO', _createGuildMottoController, 'e.g. Knowledge is Power'),
            const SizedBox(height: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF2CA50),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              onPressed: _createGuild,
              child: Text('CREATE GUILD 🚀', style: GoogleFonts.pressStart2p(fontSize: 7.5)),
            ),
          ],
        ),
      );
    } else {
      // JOIN GUILD LIST
      if (_publicGuilds.isEmpty) {
        return Center(
          child: Text('NO GUILDS AVAILABLE YET.\nBE THE FIRST TO CREATE ONE!',
              textAlign: TextAlign.center,
              style: GoogleFonts.pressStart2p(fontSize: 7, color: Colors.white54, height: 1.5)),
        );
      }

      return ListView.builder(
        itemCount: _publicGuilds.length,
        itemBuilder: (ctx, i) {
          final g = _publicGuilds[i];
          final isCurrentGuild = _hasGuild && _myGuildId == g.id;

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E32),
              border: Border.all(color: const Color(0xFF4D4635)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${g.name} [${g.tag}]', style: GoogleFonts.pressStart2p(fontSize: 7.5, color: const Color(0xFFF2CA50))),
                    Text('LVL ${g.level}', style: GoogleFonts.pressStart2p(fontSize: 6.5, color: Colors.white70)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(g.motto, style: GoogleFonts.pressStart2p(fontSize: 6.5, color: const Color(0xFFD0C5AF))),
                const SizedBox(height: 6),
                InkWell(
                  onTap: isCurrentGuild ? null : () => _joinGuild(g),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    color: isCurrentGuild ? const Color(0xFF4D4635) : const Color(0xFF82C0A0),
                    alignment: Alignment.center,
                    child: Text(
                      isCurrentGuild ? '✓ CURRENT GUILD' : 'JOIN GUILD',
                      style: GoogleFonts.pressStart2p(
                        fontSize: 6.5,
                        color: isCurrentGuild ? const Color(0xFFF2CA50) : Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    }
  }

  Widget _buildGuildFormField(String label, TextEditingController ctrl, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: GoogleFonts.pressStart2p(fontSize: 6.5, color: const Color(0xFFF2CA50))),
        const SizedBox(height: 4),
        TextField(
          controller: ctrl,
          style: GoogleFonts.pressStart2p(color: Colors.white, fontSize: 7.5),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.pressStart2p(color: Colors.white38, fontSize: 6.5),
            filled: true,
            fillColor: const Color(0xFF141424),
            contentPadding: const EdgeInsets.all(8),
            border: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF4D4635))),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailInspectorPanel() {
    if (_activeRailIndex == 0) {
      final selected = _selectedFriend;
      if (selected == null) {
        return Container(
          color: const Color(0xFF0F0F1A),
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Text(
              'SELECT A FRIEND FROM THE LIST\nTO VIEW DETAILS & DUEL',
              textAlign: TextAlign.center,
              style: GoogleFonts.pressStart2p(fontSize: 8, color: const Color(0xFFF2CA50)),
            ),
          ),
        );
      }

      return Container(
        color: const Color(0xFF0F0F1A),
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E32),
                  border: Border.all(color: const Color(0xFFF2CA50), width: 2),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFF28283D),
                        border: Border.all(color: selected.avatarColor, width: 2),
                      ),
                      child: Center(
                        child: Text(
                          selected.avatarInitial,
                          style: GoogleFonts.pressStart2p(fontSize: 18, color: selected.avatarColor),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(selected.name, style: GoogleFonts.pressStart2p(fontSize: 10, color: const Color(0xFFF2CA50))),
                          const SizedBox(height: 4),
                          Text('${selected.title} • LVL ${selected.level}', style: GoogleFonts.pressStart2p(fontSize: 7.5, color: Colors.white70)),
                          const SizedBox(height: 4),
                          Text('GUILD: ${selected.guildName.toUpperCase()}', style: GoogleFonts.pressStart2p(fontSize: 7, color: const Color(0xFFDEB7FF))),
                        ],
                      ),
                    ),
                    Builder(
                      builder: (context) {
                        final incoming = _incomingDuelChallenges.where(
                          (d) => d.challengerId == selected.id || d.challengerName.toLowerCase() == selected.name.toLowerCase(),
                        ).toList();

                        if (incoming.isNotEmpty) {
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF82C0A0),
                                  foregroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                ),
                                icon: const Icon(Icons.flash_on, color: Colors.black, size: 13),
                                label: Text('ACCEPT ⚔️', style: GoogleFonts.pressStart2p(fontSize: 6.5, color: Colors.black)),
                                onPressed: () => _acceptDuelChallenge(incoming.first),
                              ),
                              const SizedBox(width: 4),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFF6B6B),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                ),
                                onPressed: () => _declineDuelChallenge(incoming.first),
                                child: Text('DECLINE', style: GoogleFonts.pressStart2p(fontSize: 6.5)),
                              ),
                            ],
                          );
                        }

                        return ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF2CA50),
                            foregroundColor: Colors.black,
                          ),
                          icon: const Icon(Icons.sports_esports_rounded, color: Colors.black, size: 14),
                          label: Text('DUEL', style: GoogleFonts.pressStart2p(fontSize: 7, color: Colors.black)),
                          onPressed: () => _challengeFriend(selected),
                        );
                      },
                    ),


                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text('SUBJECT MASTERY & PROGRESS', style: GoogleFonts.pressStart2p(fontSize: 8, color: const Color(0xFFF2CA50))),
              const SizedBox(height: 10),
              Column(
                children: selected.subjectProgress.entries.map((e) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E32),
                      border: Border.all(color: const Color(0xFF4D4635)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(e.key.toUpperCase(), style: GoogleFonts.pressStart2p(fontSize: 8, color: Colors.white)),
                            Text('${(e.value * 100).toInt()}%', style: GoogleFonts.pressStart2p(fontSize: 7.5, color: const Color(0xFF82C0A0))),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Container(
                          height: 8,
                          color: const Color(0xFF141424),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: e.value,
                            child: Container(color: const Color(0xFF82C0A0)),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      );
    } else if (_activeRailIndex == 1) {
      // GUILD CHAT PANEL
      if (!_hasGuild) {
        return Container(
          color: const Color(0xFF0F0F1A),
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Text(
              'JOIN OR CREATE A GUILD TO ACCESS\nTHE GUILD HALL CHAT',
              textAlign: TextAlign.center,
              style: GoogleFonts.pressStart2p(fontSize: 8, color: const Color(0xFFF2CA50), height: 1.5),
            ),
          ),
        );
      }

      return Container(
        color: const Color(0xFF0F0F1A),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('$_myGuildName [$_myGuildTag] ($_myGuildRole)', style: GoogleFonts.pressStart2p(fontSize: 8, color: const Color(0xFFF2CA50))),
                Text(_myGuildMotto, style: GoogleFonts.pressStart2p(fontSize: 6.5, color: Colors.white54)),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E32),
                  border: Border.all(color: const Color(0xFFF2CA50), width: 1.5),
                ),
                child: _chatMessages.isEmpty
                    ? Center(
                        child: Text('NO GUILD CHAT MESSAGES YET.\nBE THE FIRST TO POST!',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.pressStart2p(fontSize: 7, color: Colors.white38, height: 1.5)),
                      )
                    : ListView.builder(
                        itemCount: _chatMessages.length,
                        itemBuilder: (ctx, i) {
                          final msg = _chatMessages[i];
                          final isMyMsg = msg.sender == _myPlayerName;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              '[${msg.time}] ${msg.sender}: ${msg.text}',
                              style: GoogleFonts.pressStart2p(
                                fontSize: 7.5,
                                color: isMyMsg ? const Color(0xFF4ADE80) : const Color(0xFFD0C5AF),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _chatController,
                    style: GoogleFonts.pressStart2p(color: Colors.white, fontSize: 8),
                    onSubmitted: (_) => _sendGuildChatMessage(),
                    decoration: InputDecoration(
                      hintText: 'POST TO GUILD CHAT...',
                      hintStyle: GoogleFonts.pressStart2p(color: Colors.white38, fontSize: 7),
                      filled: true,
                      fillColor: const Color(0xFF141424),
                      contentPadding: const EdgeInsets.all(8),
                      border: const OutlineInputBorder(borderSide: BorderSide(color: Color(0xFF4D4635))),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF2CA50),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                  onPressed: _sendGuildChatMessage,
                  child: Text('SEND', style: GoogleFonts.pressStart2p(fontSize: 8, color: Colors.black)),
                ),
              ],
            ),
          ],
        ),
      );
    } else {
      // ADD FRIENDS INFO
      return Container(
        color: const Color(0xFF0F0F1A),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ADD SCHOLARS TO YOUR CIRCLE', style: GoogleFonts.pressStart2p(fontSize: 8.5, color: const Color(0xFFF2CA50))),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E32),
                border: Border.all(color: const Color(0xFFF2CA50), width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('💡 SEARCH & FRIEND REQUESTS', style: GoogleFonts.pressStart2p(fontSize: 8, color: const Color(0xFF82C0A0))),
                  const SizedBox(height: 8),
                  Text(
                    '1. Type an Explorer Name in the search box on the left.\n2. Tap "+ SEND REQ" to send a pending request.\n3. The recipient accepts the request in their FRIENDS tab!\n4. Once accepted, you become official friends and can duel!',
                    style: GoogleFonts.pressStart2p(fontSize: 7, color: const Color(0xFFD0C5AF), height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }
}
