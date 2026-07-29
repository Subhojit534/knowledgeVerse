import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_screen.dart';

class InventoryItem {
  final String id;
  final String name;
  final String category;
  final String rarity;
  final Color rarityColor;
  final IconData icon;
  final String? imagePath;
  final String? imageUrl;
  final String description;
  final String stats;

  const InventoryItem({
    required this.id,
    required this.name,
    required this.category,
    required this.rarity,
    required this.rarityColor,
    required this.icon,
    this.imagePath,
    this.imageUrl,
    required this.description,
    required this.stats,
  });
}

/// 16-Bit RPG Inventory & Backpack Screen with Real Pixel Art Asset Images.
/// Features 16-bit item artwork images in every chest slot box,
/// independent backpack scrolling, stable fixed artifact inspector,
/// Press Start 2P pixel typography, equipped gear slots, and double-gold pixel frames.
class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  static const List<InventoryItem> items = [
    InventoryItem(
      id: 'scroll',
      name: 'Ancient History Scroll',
      category: 'LORE ARTIFACT',
      rarity: 'EPIC',
      rarityColor: Color(0xFFDEB7FF),
      icon: Icons.menu_book_rounded,
      imagePath: 'assets/images/pixel_scroll.jpg',
      description: 'Contains forgotten history lore of ancient civilizations.',
      stats: '+15 History Lore XP',
    ),
    InventoryItem(
      id: 'gem',
      name: 'Math Sorcerer Gem',
      category: 'CATALYST',
      rarity: 'LEGENDARY',
      rarityColor: Color(0xFFFFD167),
      icon: Icons.diamond_rounded,
      imagePath: 'assets/images/pixel_gem.jpg',
      description: 'Amplifies numerical calculations during boss challenges.',
      stats: '+25% Math Speed',
    ),
    InventoryItem(
      id: 'potion',
      name: 'Alchemy Health Potion',
      category: 'CONSUMABLE',
      rarity: 'COMMON',
      rarityColor: Color(0xFF9DDCBB),
      icon: Icons.science_rounded,
      imagePath: 'assets/images/pixel_potion.jpg',
      description: 'Instantly restores 50 Explorer Energy.',
      stats: '+50 Energy',
    ),
    InventoryItem(
      id: 'shield',
      name: 'Dragon Boss Shield',
      category: 'RELIC',
      rarity: 'LEGENDARY',
      rarityColor: Color(0xFFFFD167),
      icon: Icons.security_rounded,
      imagePath: 'assets/images/pixel_shield.jpg',
      description: 'Protects your daily streak even if a quest is missed.',
      stats: 'Streak Shield x1',
    ),
    InventoryItem(
      id: 'wand',
      name: 'Arcane Code Wand',
      category: 'WEAPON',
      rarity: 'LEGENDARY',
      rarityColor: Color(0xFFFFD167),
      icon: Icons.auto_fix_high_rounded,
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuDpOBXVSng3g3XPqB3i178JbmwwHeT4gE_KgkpX-kmm93vQN6FE6THpC8Woy7j9aF_UCmCCPj8pqQDRoV8tPR2Vs0IxDklCo2uwSldNP9gJYAnPQjqMOFLl1E8DHnYTAoDbiCXvhApPrKwb1iuzpAXLoxX1uGMsQsc54z8FmfR8vcjdAv1tl2oRb9M82sr9o6FjrvJpR06jHKMdjok9VTIa9QA_9a24ehIGmQkFlc0_R6Fzx5OsU_9jm_oYHyRjLRI6WIzV5e6rt80',
      description: 'Forged in coding towers to cast swift logic algorithms.',
      stats: '+30% Code Speed',
    ),
    InventoryItem(
      id: 'ring',
      name: 'Emerald Focus Ring',
      category: 'ACCESSORY',
      rarity: 'RARE',
      rarityColor: Color(0xFF60A5FA),
      icon: Icons.ring_volume_rounded,
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuAvZkPkvv5_HNZKcdes7uxB2uZp7O3fR_awP-tTI_IiAbv_1EMHzWN09Qh7QI2IrOIxi8iZQiunvTIkQYlL0vsq7qfubJGVgrajyqDnViwDtoVnqctL5jXj_WY6NDOeLB4xSO3UnA7eoAbzINgGZhhbT7wxNZ6mMcAbUe1OByQOH6kBSB-fOAzMr_u4Z5QbqzdiVSia43fctr9BuJXASATfgFg_ryqAYce-oyT0Zpvn-xKhdImzopU8TB27DVM-9CEB1qz6H4VQLz0',
      description: 'Glows brightly when solving complex geometry challenges.',
      stats: '+15 Focus XP',
    ),
    InventoryItem(
      id: 'telescope',
      name: 'Astronomy Telescope',
      category: 'EQUIPMENT',
      rarity: 'RARE',
      rarityColor: Color(0xFF60A5FA),
      icon: Icons.explore_rounded,
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBOJM6AWyUlYPOJRorfaSSYokhg7YUfd8ztnJzwanpVriIY_jCkMUVogPOxtLdUR-YgFOMdPtIP12RIHFvvOk4cJgqZPjA0KEyI8esWfTCyw1b0YpuT-dkyBtGSryPu_Mx2vHij4vUT5flDNtqTmbK9Yk91bg69p8-SKC3n4jk8urCHr3SQpy7H1q6TpkudGZ3HvpPadgJqRcwBV41K1Xl81-aF3-tYs4J23FrTkzXh5cwUjBsIHmhxIFzsSZkq8ECBPdWnVM85fVE',
      description: 'Allows stargazing to locate hidden physics islands.',
      stats: '+10 Space Vision',
    ),
    InventoryItem(
      id: 'crystal',
      name: 'Code Mana Crystal',
      category: 'ENCHANTMENT',
      rarity: 'EPIC',
      rarityColor: Color(0xFFDEB7FF),
      icon: Icons.code_rounded,
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBRVcxSQsWggVMO5QuLp9NTaMQJAzKClGjF_kOKB3jb5HfRzl5pZFMafY0R1AwThUaUf00-Tznch3Gj9y9OWvCTxuLzdf6k83rqsNSefnwVwtb265w9WcsrVdb71e0pYr5pzv_j6bq4w_Vn5vngod-4kwHL8BQP6X0hPIcwPeyl9DqMyNv8e5XJ74AZUHjJ8vBOMNm-SvmGqXt5HFaxkHstOEWMaVkZViPaobyTpqR1rU2kkn9SNWEGd6MKoO6jD74nNR2HeNHJHxo',
      description: 'Accelerates Dart & Flutter algorithm solving speed.',
      stats: '+20 Focus XP',
    ),
    InventoryItem(
      id: 'compass',
      name: 'Golden Navigator Compass',
      category: 'ARTIFACT',
      rarity: 'EPIC',
      rarityColor: Color(0xFFDEB7FF),
      icon: Icons.explore,
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBZoRwIf7_Wa14ugxVIE7itmwidPzKARcIQFOB9gZbRNnVRQpLskyCaeNfQjzV0brb4Z_c0IBVySdxpqw_rjou-8mxkvm5FNzGG0peqUAcVGScdmveM_XhmoCbCQY-mXhM8w2ULDyXvEZc8Z6CBFmgbPQjOoeYgaMNLj6Tuhqas8-fV9iTZxfXgjjpkUaxW3l4nnSvnVwGsA8rBgONWFfohNcthsgvEIEpyIzIIF8JfIErrPVm_1qrtJX0Okdw2JL1RSoheEZ8-2Sw',
      description: 'Points to secret uncharted islands in the archipelago.',
      stats: '+5 Discovery',
    ),
    InventoryItem(
      id: 'hourglass',
      name: 'Chrono Sands Hourglass',
      category: 'RELIC',
      rarity: 'RARE',
      rarityColor: Color(0xFF60A5FA),
      icon: Icons.hourglass_full_rounded,
      imageUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuD_jwGIQFX-809NFTIzpyodpg-7koVnkBFhHoOPlOVREC91EjJl1Bar6PIe_8O7EJaVa3Uw5eCR3ZVzYNF2-qgyD__gBULHG3GFgwVHt1MFycqxBUy75T7Xnw5Q1wv5Rr_WwPkIFaiLTZ1BaG5Sp9kOZfv0Zhsr2ioiLOfKsDcPDSGwoepOIbhmLM26dTVIrl0Clg1dwtMmqvtH50kRQGlGSLf7NRr54O2uP20vOgjCeRpG98M2bl-rKh8bgtm5COga931-bmtG67k',
      description: 'Grants extra time during boss timed challenges.',
      stats: '+15s Duel Time',
    ),
    InventoryItem(
      id: 'quill',
      name: 'Phoenix Quill Pen',
      category: 'ARTIFACT',
      rarity: 'COMMON',
      rarityColor: Color(0xFF9DDCBB),
      icon: Icons.edit_rounded,
      imagePath: 'assets/images/pixel_scroll.jpg',
      description: 'Writes instant solutions for literature lore quests.',
      stats: '+10 Lore Power',
    ),
    InventoryItem(
      id: 'catalyst',
      name: 'Alchemical Elixir',
      category: 'CONSUMABLE',
      rarity: 'RARE',
      rarityColor: Color(0xFF60A5FA),
      icon: Icons.local_drink_rounded,
      imagePath: 'assets/images/pixel_potion.jpg',
      description: 'A glowing flask of refined mana essence.',
      stats: '+100 Mana',
    ),
  ];

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  InventoryItem? _selectedItem = InventoryScreen.items.first;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: const Color(0xFF111125),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Dark Gothic Castle Background Overlay
          Opacity(
            opacity: 0.35,
            child: Image.asset(
              'assets/images/loading_bg.jpg',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.2,
                    colors: [Color(0xFF1E1E32), Color(0xFF0C0C1F)],
                  ),
                ),
              ),
            ),
          ),

          // 2. Scanlines Shader Overlay
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Color(0x1F000000)],
                    stops: [0.5, 0.5],
                    tileMode: TileMode.repeated,
                  ),
                ),
              ),
            ),
          ),

          // 3. Main Content Area
          SafeArea(
            child: Column(
              children: [
                // Top Header Bar with Back Button & Slot Counter
                _buildHeader(),

                // Main Body: Independent Scrolling Left Pane + Stable Fixed Right Inspector
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1200),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final isWide = constraints.maxWidth >= 768 &&
                                size.height >= 400;

                            if (isWide) {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Left: 24-Slot Backpack Grid & Equipped Gear (SCROLLS INDEPENDENTLY!)
                                  Expanded(
                                    flex: 58,
                                    child: SingleChildScrollView(
                                      physics: const BouncingScrollPhysics(),
                                      padding: const EdgeInsets.only(right: 6),
                                      child: _buildLeftBackpackPane(),
                                    ),
                                  ),
                                  const SizedBox(width: 16),

                                  // Right: Artifact Details Inspector (STABLE & FIXED ON SCREEN!)
                                  Expanded(
                                    flex: 42,
                                    child: _buildItemInspector(),
                                  ),
                                ],
                              );
                            } else {
                              // Stack vertically for compact mobile devices
                              return SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                child: Column(
                                  children: [
                                    _buildLeftBackpackPane(),
                                    const SizedBox(height: 16),
                                    _buildItemInspector(),
                                  ],
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── HEADER BAR BUILDER ─────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          // Back Button to return to game / previous screen
          GestureDetector(
            onTap: () {
              if (Navigator.canPop(context)) {
                Navigator.pop(context);
              } else {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E32),
                border: Border.all(color: const Color(0xFFF2CA50), width: 2),
                boxShadow: const [
                  BoxShadow(color: Colors.black, offset: Offset(2, 2)),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: Color(0xFFF2CA50),
                size: 18,
              ),
            ),
          ),

          const SizedBox(width: 12),
          const Icon(Icons.backpack_rounded,
              color: Color(0xFFF2CA50), size: 22),
          const SizedBox(width: 10),

          // Header Title
          Text(
            'EXPLORER INVENTORY',
            style: GoogleFonts.spaceMono(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: const Color(0xFFF2CA50),
              letterSpacing: 2.0,
              shadows: const [
                Shadow(color: Color(0xFF3C2F00), offset: Offset(2, 2)),
              ],
            ),
          ),

          const Spacer(),

          // Slot Counter Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF28283D),
              border: Border.all(color: const Color(0xFFF2CA50), width: 1.5),
            ),
            child: Text(
              '${InventoryScreen.items.length} / 24 SLOTS',
              style: GoogleFonts.pressStart2p(
                fontSize: 8,
                color: const Color(0xFFF2CA50),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── LEFT BACKPACK PANE (EQUIPPED GEAR + 24 BACKPACK SLOTS) ────────────────
  Widget _buildLeftBackpackPane() {
    return Column(
      children: [
        // 1. Equipped Gear Header Bar
        _OrnateFrameCard(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'EQUIPPED GEAR',
                style: GoogleFonts.pressStart2p(
                  fontSize: 9,
                  color: const Color(0xFFF2CA50),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildEquippedSlot(
                    label: 'WEAPON',
                    item: InventoryScreen.items[4],
                  ),
                  _buildEquippedSlot(
                    label: 'ARMOR',
                    item: InventoryScreen.items[3],
                  ),
                  _buildEquippedSlot(
                    label: 'ACCESSORY',
                    item: InventoryScreen.items[5],
                  ),
                  _buildEquippedSlot(
                    label: 'RELIC',
                    item: InventoryScreen.items[1],
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // 2. 24-Slot Backpack Grid
        _OrnateFrameCard(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'BACKPACK CHEST',
                    style: GoogleFonts.pressStart2p(
                      fontSize: 9,
                      color: const Color(0xFFF2CA50),
                    ),
                  ),
                  Text(
                    'TAP ITEM TO INSPECT',
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 9,
                      color: const Color(0xFFD0C5AF),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: 24,
                itemBuilder: (context, index) {
                  final hasItem = index < InventoryScreen.items.length;
                  final item = hasItem ? InventoryScreen.items[index] : null;
                  final isSelected =
                      item != null && _selectedItem?.id == item.id;

                  return GestureDetector(
                    onTap: () {
                      if (item != null) {
                        setState(() => _selectedItem = item);
                      }
                    },
                    child: Container(
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF333348)
                            : const Color(0xFF111125),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFFF2CA50)
                              : item != null
                                  ? item.rarityColor
                                  : const Color(0xFF333348),
                          width: isSelected ? 2.5 : 1.5,
                        ),
                        boxShadow: isSelected
                            ? const [
                                BoxShadow(
                                    color: Color(0xFFF2CA50), blurRadius: 6)
                              ]
                            : null,
                      ),
                      child: Center(
                        child: item != null
                            ? _ItemGraphicWidget(
                                item: item,
                                iconSize: 26,
                              )
                            : const Icon(
                                Icons.add_rounded,
                                color: Color(0xFF28283D),
                                size: 16,
                              ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEquippedSlot({required String label, InventoryItem? item}) {
    final isSelected = item != null && _selectedItem?.id == item.id;

    return GestureDetector(
      onTap: () {
        if (item != null) {
          setState(() => _selectedItem = item);
        }
      },
      child: Column(
        children: [
          Container(
            width: 54,
            height: 54,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF333348)
                  : const Color(0xFF111125),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFFF2CA50)
                    : item?.rarityColor ?? const Color(0xFF333348),
                width: isSelected ? 2.5 : 1.5,
              ),
              boxShadow: isSelected
                  ? const [
                      BoxShadow(color: Color(0xFFF2CA50), blurRadius: 6)
                    ]
                  : null,
            ),
            child: Center(
              child: item != null
                  ? _ItemGraphicWidget(item: item, iconSize: 28)
                  : const Icon(Icons.shield_outlined,
                      color: Color(0xFF333348), size: 22),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.pressStart2p(
              fontSize: 6,
              color: const Color(0xFFD0C5AF),
            ),
          ),
        ],
      ),
    );
  }

  // ── RIGHT STABLE ARTIFACT DETAILS INSPECTOR (STAYS FIXED ON SCREEN!) ───────
  Widget _buildItemInspector() {
    final activeItem = _selectedItem;

    if (activeItem == null) {
      return _OrnateFrameCard(
        child: Center(
          child: Text(
            'SELECT AN ITEM TO INSPECT',
            style: GoogleFonts.pressStart2p(
              fontSize: 9,
              color: const Color(0xFFD0C5AF),
            ),
          ),
        ),
      );
    }

    return _OrnateFrameCard(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Inspector Header Badge
            Text(
              'ARTIFACT INSPECTOR',
              style: GoogleFonts.pressStart2p(
                fontSize: 9.5,
                color: const Color(0xFFF2CA50),
              ),
            ),
            const SizedBox(height: 10),

            // Real Pixel Art Image Preview Container
            Center(
              child: Container(
                width: 112,
                height: 112,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: const Color(0xFF111125),
                  border: Border.all(color: activeItem.rarityColor, width: 2.5),
                  boxShadow: const [
                    BoxShadow(color: Colors.black, offset: Offset(2, 2)),
                  ],
                ),
                child: Center(
                  child: _ItemGraphicWidget(
                    item: activeItem,
                    iconSize: 56,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Rarity Badge & Category
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  color: activeItem.rarityColor.withValues(alpha: 0.2),
                  child: Text(
                    activeItem.rarity,
                    style: GoogleFonts.pressStart2p(
                      fontSize: 8,
                      color: activeItem.rarityColor,
                    ),
                  ),
                ),
                Text(
                  activeItem.category,
                  style: GoogleFonts.jetBrainsMono(
                    fontWeight: FontWeight.w700,
                    fontSize: 9,
                    color: const Color(0xFFD0C5AF),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Item Name
            Text(
              activeItem.name.toUpperCase(),
              style: GoogleFonts.spaceMono(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: const Color(0xFFF2CA50),
                shadows: const [
                  Shadow(color: Color(0xFF3C2F00), offset: Offset(2, 2)),
                ],
              ),
            ),

            const SizedBox(height: 6),

            // Description
            Text(
              activeItem.description,
              style: GoogleFonts.jetBrainsMono(
                fontSize: 10.5,
                color: const Color(0xFFD0C5AF),
                height: 1.35,
              ),
            ),

            const SizedBox(height: 10),

            // Effect Stats Box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFF111125),
                border: Border.all(color: const Color(0xFF4D4635), width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'STAT EFFECT',
                    style: GoogleFonts.pressStart2p(
                      fontSize: 7,
                      color: const Color(0xFFF2CA50),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    activeItem.stats,
                    style: GoogleFonts.pressStart2p(
                      fontSize: 8,
                      color: const Color(0xFF9DDCBB),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Action Buttons: EQUIP / USE
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${activeItem.name} equipped!',
                            style: GoogleFonts.pressStart2p(fontSize: 9),
                          ),
                          backgroundColor: const Color(0xFF065F46),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      decoration: BoxDecoration(
                        color: const Color(0xFF065F46),
                        border: Border.all(
                            color: const Color(0xFFF2CA50), width: 2),
                        boxShadow: const [
                          BoxShadow(color: Colors.black, offset: Offset(2, 2)),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          'EQUIP ITEM ⚡',
                          style: GoogleFonts.pressStart2p(
                            fontSize: 9,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── ITEM GRAPHIC WIDGET (Renders Image Asset, Network URL, or Icon Fallback) ──
class _ItemGraphicWidget extends StatelessWidget {
  final InventoryItem item;
  final double iconSize;

  const _ItemGraphicWidget({
    required this.item,
    required this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    if (item.imagePath != null) {
      return Image.asset(
        item.imagePath!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildFallbackIcon(),
      );
    } else if (item.imageUrl != null) {
      return Image.network(
        item.imageUrl!,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => _buildFallbackIcon(),
      );
    }
    return _buildFallbackIcon();
  }

  Widget _buildFallbackIcon() {
    return Icon(
      item.icon,
      color: item.rarityColor,
      size: iconSize,
    );
  }
}

// ── ORNATE FRAME CARD ────────────────────────────────────────────────────────
class _OrnateFrameCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _OrnateFrameCard({
    required this.child,
    this.padding = const EdgeInsets.all(14),
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: padding,
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E32).withValues(alpha: 0.95),
            border: Border.all(color: const Color(0xFFF2CA50), width: 3),
            boxShadow: const [
              BoxShadow(
                color: Color(0xFF735C00),
                spreadRadius: 1,
              ),
              BoxShadow(
                color: Colors.black,
                offset: Offset(4, 4),
                blurRadius: 0,
              ),
            ],
          ),
          child: child,
        ),
        // Corner Gems
        const _CornerGem(top: -4, left: -4),
        const _CornerGem(top: -4, right: -4),
        const _CornerGem(bottom: -4, left: -4),
        const _CornerGem(bottom: -4, right: -4),
      ],
    );
  }
}

// ── CORNER GEM WIDGET ────────────────────────────────────────────────────────
class _CornerGem extends StatelessWidget {
  final double? top;
  final double? bottom;
  final double? left;
  final double? right;

  const _CornerGem({
    this.top,
    this.bottom,
    this.left,
    this.right,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: const Color(0xFF6B13AF),
          border: Border.all(
            color: const Color(0xFFF2CA50),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  }
}
