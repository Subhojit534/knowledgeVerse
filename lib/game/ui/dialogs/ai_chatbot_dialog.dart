import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../models/chat_message.dart';
import '../../../models/player_profile.dart';
import '../../../services/chatbot_service.dart';

/// Fullscreen fantasy RPG-themed dialog for interacting with Archmage Aetherius,
/// the AI Scholar Tutor powered by Groq AI with persistent multi-turn conversational memory.
class AiChatbotDialog extends StatefulWidget {
  final String? initialSubject;
  final String? initialTopic;

  const AiChatbotDialog({
    super.key,
    this.initialSubject,
    this.initialTopic,
  });

  /// Static helper to display the AI Chatbot dialog from anywhere in the application
  static Future<void> show(
    BuildContext context, {
    String? subject,
    String? topic,
  }) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'AI Tutor Chatbot',
      barrierColor: Colors.black.withValues(alpha: 0.75),
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (_, __, ___) => AiChatbotDialog(
        initialSubject: subject,
        initialTopic: topic,
      ),
      transitionBuilder: (_, anim, __, child) {
        return Transform.scale(
          scale: 0.9 + 0.1 * Curves.easeOutBack.transform(anim.value),
          child: Opacity(
            opacity: anim.value.clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
    );
  }

  @override
  State<AiChatbotDialog> createState() => _AiChatbotDialogState();
}

class _AiChatbotDialogState extends State<AiChatbotDialog> with SingleTickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  final ChatbotService _service = ChatbotService.instance;

  late AnimationController _pulseController;

  static const List<String> _kSuggestedPrompts = [
    'Explain this topic simply with an example',
    'What are the key formulas and rules?',
    'Give me a step-by-step practice problem',
    'How does this apply in real life?',
    'Quiz me on this concept with 1 MCQ',
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _service.setContext(
      subject: widget.initialSubject,
      topic: widget.initialTopic,
    );
    _service.initialize().then((_) => _scrollToBottom(immediate: true));
    _service.addListener(_onServiceUpdate);
  }

  @override
  void dispose() {
    _service.removeListener(_onServiceUpdate);
    _pulseController.dispose();
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onServiceUpdate() {
    if (mounted) {
      setState(() {});
      _scrollToBottom();
    }
  }

  void _scrollToBottom({bool immediate = false}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      if (immediate) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      } else {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutQuad,
        );
      }
    });
  }

  void _sendMessage([String? presetText]) {
    final text = (presetText ?? _textController.text).trim();
    if (text.isEmpty || _service.isGenerating) return;

    if (presetText == null) {
      _textController.clear();
    }
    final profile = PlayerProfile.current;
    _service.sendMessage(text, profile: profile);
    _scrollToBottom();
  }

  Future<void> _confirmClearChat() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFF2CA50), width: 1.5),
        ),
        title: Text(
          'Purge Chat Memory?',
          style: GoogleFonts.cinzel(
            color: const Color(0xFFF2CA50),
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'This will clear our conversation history. Archmage Aetherius will start a fresh tutoring session.',
          style: GoogleFonts.spectral(color: const Color(0xFFE2E8F0), fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel', style: GoogleFonts.jetBrainsMono(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF991B1B),
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Clear All', style: GoogleFonts.jetBrainsMono(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _service.clearHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final isMobile = media.size.width < 700;
    final profile = PlayerProfile.current;

    final activeGrade = profile?.grade.isNotEmpty == true ? profile!.grade : 'Class 10';
    final activeBoard = profile?.curriculum.isNotEmpty == true ? profile!.curriculum : 'CBSE';
    final activeSubject = _service.currentSubject ??
        (profile?.subjects.isNotEmpty == true ? profile!.subjects.first : 'Mathematics');
    final activeTopic = _service.currentTopic ?? profile?.activeTopicName ?? 'Academic Studies';

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 8 : 40,
        vertical: isMobile ? 12 : 32,
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 860, maxHeight: 920),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A), // Deep Slate
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFFF2CA50), // Antique Gold
              width: 2.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.25),
                blurRadius: 32,
                spreadRadius: 4,
              ),
              const BoxShadow(
                color: Colors.black,
                offset: Offset(0, 12),
                blurRadius: 28,
              ),
            ],
          ),
          child: Column(
            children: [
              // ── 1. Ornate Header ──
              _buildHeader(isMobile),

              // ── 2. Study Context Banner ──
              _buildContextBanner(activeGrade, activeBoard, activeSubject, activeTopic, isMobile),

              // ── 3. Messages Stream ──
              Expanded(
                child: _buildMessagesList(isMobile),
              ),

              // ── 4. Suggestion Chips ──
              _buildSuggestionChips(isMobile),

              // ── 5. Input Bar ──
              _buildInputBar(isMobile),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 20,
        vertical: isMobile ? 10 : 14,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF1E293B),
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        border: Border(
          bottom: BorderSide(color: Color(0xFF334155), width: 1.5),
        ),
      ),
      child: Row(
        children: [
          // Archmage Avatar
          Container(
            width: isMobile ? 40 : 46,
            height: isMobile ? 40 : 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                colors: [Color(0xFF8B5CF6), Color(0xFF4C1D95)],
              ),
              border: Border.all(color: const Color(0xFFF2CA50), width: 2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.5),
                  blurRadius: 10,
                ),
              ],
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Color(0xFFF2CA50),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),

          // Title & Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        'ARCHMAGE AETHERIUS',
                        style: GoogleFonts.cinzel(
                          color: const Color(0xFFF2CA50),
                          fontSize: isMobile ? 15 : 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.1,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Online Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF065F46),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF10B981), width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFF34D399),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'GROQ AI',
                            style: GoogleFonts.jetBrainsMono(
                              color: const Color(0xFFD1FAE5),
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Text(
                  'Conversational AI Scholar • Memory Active',
                  style: GoogleFonts.spectral(
                    color: const Color(0xFF94A3B8),
                    fontSize: isMobile ? 11 : 13,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),

          // Clear Chat History Button
          IconButton(
            key: const Key('chatbot_clear_history_btn'),
            icon: const Icon(Icons.delete_sweep_rounded, color: Color(0xFFEF4444)),
            tooltip: 'Clear Chat History',
            onPressed: _confirmClearChat,
          ),

          // Close Button
          IconButton(
            key: const Key('chatbot_close_dialog_btn'),
            icon: const Icon(Icons.close_rounded, color: Color(0xFFE2E8F0)),
            tooltip: 'Close Dialogue',
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildContextBanner(
    String grade,
    String board,
    String subject,
    String topic,
    bool isMobile,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 20,
        vertical: 6,
      ),
      color: const Color(0xFF131C2E),
      child: Row(
        children: [
          const Icon(Icons.menu_book_rounded, color: Color(0xFFF2CA50), size: 14),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              '$grade ($board) • $subject • Chapter: $topic',
              style: GoogleFonts.jetBrainsMono(
                color: const Color(0xFFCBD5E1),
                fontSize: isMobile ? 10 : 12,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF7A1C2E),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'ATTUNED',
              style: GoogleFonts.jetBrainsMono(
                color: const Color(0xFFFDE68A),
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList(bool isMobile) {
    final messages = _service.messages;

    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 20,
        vertical: 12,
      ),
      itemCount: messages.length + (_service.isGenerating ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == messages.length && _service.isGenerating) {
          return _buildTypingIndicator(isMobile);
        }
        final msg = messages[index];
        return _buildMessageBubble(msg, isMobile);
      },
    );
  }

  Widget _buildMessageBubble(ChatMessage msg, bool isMobile) {
    final isUser = msg.isUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF4C1D95),
                border: Border.all(color: const Color(0xFFF2CA50), width: 1.5),
              ),
              child: const Icon(Icons.school, color: Color(0xFFF2CA50), size: 18),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isUser ? const Color(0xFF6B13AF) : const Color(0xFF1E293B),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
                border: Border.all(
                  color: isUser
                      ? const Color(0xFFF2CA50).withValues(alpha: 0.6)
                      : const Color(0xFF475569),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    offset: const Offset(0, 3),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment:
                    isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Text(
                    isUser ? 'Explorer' : 'Archmage Aetherius',
                    style: GoogleFonts.cinzel(
                      color: isUser ? const Color(0xFFFDE68A) : const Color(0xFFF2CA50),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  SelectableText(
                    msg.content,
                    style: GoogleFonts.spectral(
                      color: Colors.white,
                      fontSize: isMobile ? 14 : 15,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF7A1C2E),
                border: Border.all(color: const Color(0xFFF2CA50), width: 1.5),
              ),
              child: const Icon(Icons.person, color: Color(0xFFF2CA50), size: 18),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator(bool isMobile) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF4C1D95),
              border: Border.all(color: const Color(0xFFF2CA50), width: 1.5),
            ),
            child: const Icon(Icons.school, color: Color(0xFFF2CA50), size: 18),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF8B5CF6), width: 1.2),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (_, __) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(3, (i) {
                        final val = (_pulseController.value + (i * 0.3)) % 1.0;
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color.lerp(
                              const Color(0xFFF2CA50),
                              const Color(0xFF8B5CF6),
                              val,
                            ),
                          ),
                        );
                      }),
                    );
                  },
                ),
                const SizedBox(width: 8),
                Text(
                  'Archmage is weaving an explanation...',
                  style: GoogleFonts.spectral(
                    color: const Color(0xFF94A3B8),
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionChips(bool isMobile) {
    return Container(
      height: 40,
      margin: const EdgeInsets.only(bottom: 8),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 20),
        itemCount: _kSuggestedPrompts.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final prompt = _kSuggestedPrompts[index];
          return ActionChip(
            backgroundColor: const Color(0xFF1E293B),
            side: const BorderSide(color: Color(0xFF334155), width: 1),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            label: Text(
              prompt,
              style: GoogleFonts.spectral(
                color: const Color(0xFFE2E8F0),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            onPressed: () => _sendMessage(prompt),
          );
        },
      ),
    );
  }

  Widget _buildInputBar(bool isMobile) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 10 : 16,
        vertical: isMobile ? 8 : 12,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF1E293B),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(22)),
        border: Border(
          top: BorderSide(color: Color(0xFF334155), width: 1.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              key: const Key('chatbot_input_field'),
              controller: _textController,
              focusNode: _focusNode,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
              style: GoogleFonts.spectral(color: Colors.white, fontSize: 15),
              decoration: InputDecoration(
                hintText: 'Ask Archmage Aetherius anything about your studies...',
                hintStyle: GoogleFonts.spectral(
                  color: const Color(0xFF64748B),
                  fontSize: isMobile ? 13 : 14,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                filled: true,
                fillColor: const Color(0xFF0F172A),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFF475569), width: 1.2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFFF2CA50), width: 1.8),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            key: const Key('chatbot_send_btn'),
            onTap: () => _sendMessage(),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFF2CA50), Color(0xFFD97706)],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white, width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF2CA50).withValues(alpha: 0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.send_rounded,
                color: Color(0xFF1E1B4B),
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
