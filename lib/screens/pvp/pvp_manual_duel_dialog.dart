import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/player_profile.dart';
import '../../models/pvp_models.dart';
import '../../services/pvp_service.dart';
import '../../services/api_service.dart';

class PvPManualDuelDialog extends StatefulWidget {
  final String initialSubject;
  final int initialStake;

  const PvPManualDuelDialog({
    super.key,
    required this.initialSubject,
    required this.initialStake,
  });

  @override
  State<PvPManualDuelDialog> createState() => _PvPManualDuelDialogState();
}

class _PvPManualDuelDialogState extends State<PvPManualDuelDialog> {
  // Theme Colors
  static const Color _bgDark = Color(0xFF0D0D18);
  static const Color _bgPanel = Color(0xFF161626);
  static const Color _bgCard = Color(0xFF1F1F36);
  static const Color _borderDim = Color(0xFF2E2E50);
  static const Color _gold = Color(0xFFF2CA50);
  static const Color _cyan = Color(0xFF70D6FF);
  static const Color _green = Color(0xFF82C0A0);
  static const Color _crimson = Color(0xFFFF6B6B);

  int _selectedTab = 0; // 0: Room Code, 1: Challenge Friend
  int _roomSubTab = 0; // 0: Create Room, 1: Join Room

  late String _selectedSubject;
  late int _selectedStake;

  // Create Room State
  bool _isCreatingRoom = false;
  String? _createdRoomCode;
  Timer? _roomHostPollTimer;

  // Join Room State
  final TextEditingController _joinCodeController = TextEditingController();
  bool _isJoining = false;
  String? _joinError;

  // Friend Challenge State
  bool _isLoadingFriends = false;
  List<dynamic> _friends = [];
  List<PvPChallengeItem> _incomingChallenges = [];
  String? _challengeSuccessMessage;

  @override
  void initState() {
    super.initState();
    _selectedSubject = widget.initialSubject;
    _selectedStake = widget.initialStake > 0 ? widget.initialStake : 50;
    _loadFriends();
  }

  @override
  void dispose() {
    _roomHostPollTimer?.cancel();
    _joinCodeController.dispose();
    super.dispose();
  }

  Future<void> _loadFriends() async {
    setState(() => _isLoadingFriends = true);
    final profile = PlayerProfile.current ?? const PlayerProfile();
    final userId = profile.id.isNotEmpty ? profile.id : 'demo-user-123';

    try {
      final results = await Future.wait([
        ApiService.get('/api/social/friends?userId=$userId'),
        PvPService.getChallenges(),
      ]);

      final response = results[0] as dynamic;
      final challenges = results[1] as Map<String, List<PvPChallengeItem>>;

      if (response.statusCode == 200) {
        final data = response.body.isNotEmpty ? (response.body.startsWith('{') ? (jsonDecode(response.body) as Map<String, dynamic>) : {}) : {};
        if (mounted) {
          setState(() {
            _friends = (data['friends'] as List<dynamic>?) ?? (data['availableExplorers'] as List<dynamic>?) ?? [];
            _incomingChallenges = challenges['received'] ?? [];
            _isLoadingFriends = false;
          });
          return;
        }
      }
    } catch (_) {}

    if (mounted) {
      setState(() => _isLoadingFriends = false);
    }
  }

  Future<void> _handleAcceptIncomingChallenge(PvPChallengeItem challenge) async {
    final session = await PvPService.respondToChallenge(
      challengeId: challenge.id,
      accept: true,
      subject: challenge.subject,
    );

    if (session != null && mounted) {
      PvPService.consumeChallenge(challengeId: challenge.id, sessionId: session.id);
      Navigator.pop(context, session);
    } else {
      // Try fetching active session
      if (challenge.sessionId != null) {
        final existing = await PvPService.getSession(challenge.sessionId!);
        if (existing != null && mounted) {
          PvPService.consumeChallenge(challengeId: challenge.id, sessionId: existing.id);
          Navigator.pop(context, existing);
        }
      }
    }
  }

  Future<void> _handleDeclineIncomingChallenge(PvPChallengeItem challenge) async {
    PvPService.consumeChallenge(challengeId: challenge.id);
    await PvPService.respondToChallenge(
      challengeId: challenge.id,
      accept: false,
    );
    if (mounted) {
      setState(() {
        _incomingChallenges.removeWhere((c) => c.id == challenge.id);
      });
    }
  }




  // ─── ROOM HOST FLOW ────────────────────────────────────────────────────────
  Future<void> _handleCreateRoom() async {
    final profile = PlayerProfile.current ?? const PlayerProfile();
    if (profile.coins < _selectedStake) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('INSUFFICIENT COINS! Need $_selectedStake 🪙', style: GoogleFonts.pressStart2p(fontSize: 8, color: Colors.white)),
          backgroundColor: _crimson,
        ),
      );
      return;
    }

    setState(() {
      _isCreatingRoom = true;
      _createdRoomCode = null;
    });

    final data = await PvPService.createRoom(
      subject: _selectedSubject,
      stakeCoins: _selectedStake,
    );

    if (!mounted) return;

    if (data != null && data['roomCode'] != null) {
      setState(() {
        _isCreatingRoom = false;
        _createdRoomCode = data['roomCode'].toString();
      });

      // Start polling waiting for guest to join room
      _startHostPolling(_createdRoomCode!);
    } else {
      setState(() => _isCreatingRoom = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('FAILED TO CREATE ROOM! Check network.', style: GoogleFonts.pressStart2p(fontSize: 8, color: Colors.white)),
          backgroundColor: _crimson,
        ),
      );
    }
  }

  void _startHostPolling(String code) {
    _roomHostPollTimer?.cancel();
    _roomHostPollTimer = Timer.periodic(const Duration(milliseconds: 700), (_) async {
      final statusData = await PvPService.getRoomStatus(code);
      if (!mounted) return;

      if (statusData['status'] == 'ready' && statusData['session'] != null) {
        _roomHostPollTimer?.cancel();
        final session = statusData['session'] as PvPSession;
        Navigator.pop(context, session);
      }
    });
  }

  // ─── ROOM JOIN FLOW ────────────────────────────────────────────────────────
  Future<void> _handleJoinRoom() async {
    final code = _joinCodeController.text.trim();
    if (code.isEmpty) {
      setState(() => _joinError = 'PLEASE ENTER A ROOM CODE');
      return;
    }

    setState(() {
      _isJoining = true;
      _joinError = null;
    });

    final result = await PvPService.joinRoom(roomCode: code);
    if (!mounted) return;

    setState(() => _isJoining = false);

    if (result['success'] == true && result['session'] != null) {
      Navigator.pop(context, result['session'] as PvPSession);
    } else {
      setState(() => _joinError = result['error']?.toString() ?? 'INVALID OR EXPIRED CODE');
    }
  }

  // ─── DIRECT FRIEND CHALLENGE ───────────────────────────────────────────────
  Future<void> _sendFriendChallenge(dynamic friend) async {
    final friendId = (friend['id'] ?? '').toString();
    final friendName = (friend['name'] ?? 'Friend').toString();

    final success = await PvPService.sendChallenge(
      challengedId: friendId,
      subject: _selectedSubject,
      stakeCoins: _selectedStake,
    );

    if (!mounted) return;

    if (success) {
      setState(() {
        _challengeSuccessMessage = 'CHALLENGE SENT TO $friendName! ⚔️';
      });
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) setState(() => _challengeSuccessMessage = null);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: _bgDark,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: _gold, width: 2),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 600),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.flash_on, color: _gold, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'CUSTOM DUEL',
                      style: GoogleFonts.pressStart2p(fontSize: 12, color: _gold),
                    ),
                  ],
                ),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.close, color: Colors.white54, size: 20),
                  onPressed: () {
                    if (_createdRoomCode != null) {
                      PvPService.cancelRoom(_createdRoomCode!);
                    }
                    Navigator.pop(context);
                  },
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Top Mode Tabs (Room Code vs Challenge Friend)
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _selectedTab = 0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: _selectedTab == 0 ? _gold : _bgPanel,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _selectedTab == 0 ? _gold : _borderDim),
                      ),
                      child: Center(
                        child: Text(
                          '🔑 ROOM CODE',
                          style: GoogleFonts.pressStart2p(
                            fontSize: 7.5,
                            color: _selectedTab == 0 ? Colors.black : Colors.white70,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _selectedTab = 1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: _selectedTab == 1 ? _cyan : _bgPanel,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _selectedTab == 1 ? _cyan : _borderDim),
                      ),
                      child: Center(
                        child: Text(
                          '👥 DUEL FRIEND',
                          style: GoogleFonts.pressStart2p(
                            fontSize: 7.5,
                            color: _selectedTab == 1 ? Colors.black : Colors.white70,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Content Area
            Expanded(
              child: _selectedTab == 0
                  ? _buildRoomCodeContent()
                  : _buildChallengeFriendContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomCodeContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Sub Tabs: Create vs Join
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => setState(() {
                  _roomSubTab = 0;
                  _joinError = null;
                }),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  decoration: BoxDecoration(
                    color: _roomSubTab == 0 ? _bgCard : _bgDark,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: _roomSubTab == 0 ? _gold : _borderDim),
                  ),
                  child: Center(
                    child: Text(
                      'CREATE ROOM',
                      style: GoogleFonts.pressStart2p(
                        fontSize: 7,
                        color: _roomSubTab == 0 ? _gold : Colors.white54,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: InkWell(
                onTap: () => setState(() {
                  _roomSubTab = 1;
                  _joinError = null;
                }),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 7),
                  decoration: BoxDecoration(
                    color: _roomSubTab == 1 ? _bgCard : _bgDark,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: _roomSubTab == 1 ? _cyan : _borderDim),
                  ),
                  child: Center(
                    child: Text(
                      'JOIN ROOM',
                      style: GoogleFonts.pressStart2p(
                        fontSize: 7,
                        color: _roomSubTab == 1 ? _cyan : Colors.white54,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Expanded(
          child: _roomSubTab == 0 ? _buildCreateRoomView() : _buildJoinRoomView(),
        ),
      ],
    );
  }

  Widget _buildCreateRoomView() {
    if (_createdRoomCode != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _bgPanel,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _gold),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'ROOM CODE GENERATED!',
              style: GoogleFonts.pressStart2p(fontSize: 9, color: _gold),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: _bgDark,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _gold, width: 2),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _createdRoomCode!,
                    style: GoogleFonts.pressStart2p(fontSize: 18, color: _gold),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: const Icon(Icons.copy, color: _gold, size: 18),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: _createdRoomCode!));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('ROOM CODE COPIED!', style: GoogleFonts.pressStart2p(fontSize: 8, color: Colors.white)),
                          backgroundColor: _green,
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2, color: _gold),
                ),
                const SizedBox(width: 8),
                Text(
                  'Waiting for friend to join...',
                  style: GoogleFonts.jetBrainsMono(fontSize: 11, color: Colors.white70),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Subject: $_selectedSubject • Stake: $_selectedStake 🪙',
              style: GoogleFonts.jetBrainsMono(fontSize: 10, color: _cyan),
            ),
            const SizedBox(height: 14),
            TextButton(
              onPressed: () {
                PvPService.cancelRoom(_createdRoomCode!);
                setState(() => _createdRoomCode = null);
              },
              child: Text(
                'CANCEL ROOM',
                style: GoogleFonts.pressStart2p(fontSize: 7.5, color: _crimson),
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _bgPanel,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _borderDim),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('DUEL SUBJECT:', style: GoogleFonts.pressStart2p(fontSize: 7.5, color: Colors.white70)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: _bgCard,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _gold.withOpacity(0.5)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.school, color: _gold, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _selectedSubject,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.pressStart2p(fontSize: 8.5, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Text('ENTRY STAKE:', style: GoogleFonts.pressStart2p(fontSize: 7.5, color: Colors.white70)),
            const SizedBox(height: 6),
            Row(
              children: [50, 100, 250].map((stake) {
                final isSel = _selectedStake == stake;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: InkWell(
                      onTap: () => setState(() => _selectedStake = stake),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isSel ? _gold : _bgCard,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: isSel ? _gold : _borderDim),
                        ),
                        child: Center(
                          child: Text(
                            '$stake 🪙',
                            style: GoogleFonts.pressStart2p(
                              fontSize: 7,
                              color: isSel ? Colors.black : Colors.white70,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _gold,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: _isCreatingRoom ? null : _handleCreateRoom,
              child: _isCreatingRoom
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                  : Text('GENERATE ROOM CODE 🔑', style: GoogleFonts.pressStart2p(fontSize: 8)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJoinRoomView() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _bgPanel,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _borderDim),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('ENTER 6-DIGIT ROOM CODE:', style: GoogleFonts.pressStart2p(fontSize: 7.5, color: Colors.white70)),
            const SizedBox(height: 10),
            TextField(
              controller: _joinCodeController,
              style: GoogleFonts.pressStart2p(fontSize: 16, color: _cyan, letterSpacing: 3),
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: '849201',
                hintStyle: GoogleFonts.pressStart2p(fontSize: 14, color: Colors.white24),
                filled: true,
                fillColor: _bgDark,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: _cyan, width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: _cyan, width: 2),
                ),
              ),
            ),
            if (_joinError != null) ...[
              const SizedBox(height: 8),
              Text(
                _joinError!,
                style: GoogleFonts.pressStart2p(fontSize: 7, color: _crimson),
              ),
            ],
            const SizedBox(height: 18),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _cyan,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: _isJoining ? null : _handleJoinRoom,
              child: _isJoining
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                  : Text('JOIN DUEL ROOM ⚔️', style: GoogleFonts.pressStart2p(fontSize: 8.5)),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildChallengeFriendContent() {
    if (_isLoadingFriends) {
      return const Center(child: CircularProgressIndicator(color: _cyan));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_challengeSuccessMessage != null)
          Container(
            padding: const EdgeInsets.all(8),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: _green.withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: _green),
            ),
            child: Text(
              _challengeSuccessMessage!,
              textAlign: TextAlign.center,
              style: GoogleFonts.pressStart2p(fontSize: 7, color: _green),
            ),
          ),

        // Incoming Duels Section
        if (_incomingChallenges.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            margin: const EdgeInsets.only(bottom: 6),
            decoration: BoxDecoration(
              color: _gold.withOpacity(0.15),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: _gold),
            ),
            child: Row(
              children: [
                const Icon(Icons.flash_on, color: _gold, size: 14),
                const SizedBox(width: 6),
                Text(
                  'INCOMING DUELS (${_incomingChallenges.length})',
                  style: GoogleFonts.pressStart2p(fontSize: 7, color: _gold),
                ),
              ],
            ),
          ),
          ..._incomingChallenges.map((c) {
            return Container(
              margin: const EdgeInsets.only(bottom: 6),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _bgCard,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: _gold, width: 1.5),
              ),
              child: Row(
                children: [
                  const Icon(Icons.sports_esports, color: _gold, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          c.challengerName.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.pressStart2p(fontSize: 7.5, color: Colors.white),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${c.subject} • ${c.stakeCoins} 🪙',
                          style: GoogleFonts.jetBrainsMono(fontSize: 9.5, color: _gold),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _green,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
                          minimumSize: Size.zero,
                        ),
                        onPressed: () => _handleAcceptIncomingChallenge(c),
                        child: Text('ACCEPT ⚔️', style: GoogleFonts.pressStart2p(fontSize: 6.5)),
                      ),
                      const SizedBox(width: 4),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _crimson,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
                          minimumSize: Size.zero,
                        ),
                        onPressed: () => _handleDeclineIncomingChallenge(c),
                        child: Text('DECLINE', style: GoogleFonts.pressStart2p(fontSize: 6.5)),
                      ),
                    ],
                  ),

                ],
              ),
            );
          }),
          const SizedBox(height: 6),
          Text('ALL FRIENDS:', style: GoogleFonts.pressStart2p(fontSize: 7, color: Colors.white54)),
          const SizedBox(height: 6),
        ],

        if (_friends.isEmpty && _incomingChallenges.isEmpty)
          Expanded(
            child: Center(
              child: Text(
                'NO ONLINE FRIENDS FOUND.\nInvite friends from the Social tab!',
                textAlign: TextAlign.center,
                style: GoogleFonts.jetBrainsMono(fontSize: 10, color: Colors.white54),
              ),
            ),
          )
        else
          Expanded(
            child: ListView.separated(
              itemCount: _friends.length,
              separatorBuilder: (_, __) => const SizedBox(height: 6),
              itemBuilder: (context, index) {
                final f = _friends[index];
                final fName = (f['name'] ?? 'Scholar').toString();
                final fInitial = (f['avatarInitial'] ?? (fName.isNotEmpty ? fName.substring(0, 1) : 'S')).toString();

                return Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _bgPanel,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _borderDim),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: _cyan.withOpacity(0.2),
                        child: Text(fInitial, style: GoogleFonts.pressStart2p(fontSize: 10, color: _cyan)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              fName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.pressStart2p(fontSize: 8, color: Colors.white),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Level ${f['level'] ?? 1} Scholar',
                              style: GoogleFonts.jetBrainsMono(fontSize: 9, color: Colors.white54),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _gold,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          minimumSize: Size.zero,
                        ),
                        onPressed: () => _sendFriendChallenge(f),
                        child: Text('DUEL ⚔️', style: GoogleFonts.pressStart2p(fontSize: 6.5)),
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

