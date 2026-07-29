import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ShopItemModel {
  final String id;
  final String name;
  final String category;
  final String rarity;
  final Color rarityColor;
  final String imagePath;
  final String description;
  final String perkText;
  final int price;
  final String currency; // 'COINS' or 'GEMS'
  final String tagText;

  const ShopItemModel({
    required this.id,
    required this.name,
    required this.category,
    required this.rarity,
    required this.rarityColor,
    required this.imagePath,
    required this.description,
    required this.perkText,
    required this.price,
    required this.currency,
    this.tagText = '',
  });
}

/// Authentic 16-Bit Arcane Shop & Bazaar Screen.
/// Features chiseled obsidian cards, double-gold pixel borders (#F2CA50),
/// zero-blur pixel shadows, Press Start 2P typography, and reference item grid layout.
class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  int _activeNavIndex = 0; // 0: Featured, 1: Gear, 2: Boosts, 3: Vault

  int _playerCoins = 2450;
  int _playerGems = 340;

  static const List<ShopItemModel> _featuredItems = [
    ShopItemModel(
      id: 'f_robe',
      name: 'Void-Walker Mantle',
      category: 'LEGENDARY ROBE',
      rarity: 'LEGENDARY',
      rarityColor: Color(0xFFF2CA50),
      imagePath: 'assets/images/pixel_robe.jpg',
      description:
          'Woven from the silk of abyss spiders. Grants temporary invisibility in shadowed corridors and +30% Focus XP.',
      perkText: '+30% XP & SHADOW CLOAK',
      price: 250,
      currency: 'GEMS',
      tagText: 'HOT DEAL',
    ),
    ShopItemModel(
      id: 'f_wand',
      name: 'Arcane Code Wand',
      category: 'WEAPON SKIN',
      rarity: 'LEGENDARY',
      rarityColor: Color(0xFFF2CA50),
      imagePath: 'assets/images/pixel_wand.jpg',
      description:
          'Forged in coding towers to cast swift logic algorithms. Emits cyan sparks during quiz trials.',
      perkText: '+15% SPEED ANSWER BONUS',
      price: 350,
      currency: 'GEMS',
      tagText: 'BESTSELLER',
    ),
    ShopItemModel(
      id: 'f_shield',
      name: 'Dragon Boss Shield',
      category: 'LEGENDARY RELIC',
      rarity: 'LEGENDARY',
      rarityColor: Color(0xFFF2CA50),
      imagePath: 'assets/images/pixel_shield.jpg',
      description:
          'Protects your daily streak even if a lesson quest is missed due to real-life duties.',
      perkText: 'STREAK SHIELD PROTECTION',
      price: 180,
      currency: 'GEMS',
    ),
    ShopItemModel(
      id: 'f_scroll',
      name: 'Ancient Lore Scroll',
      category: 'LORE ARTIFACT',
      rarity: 'EPIC',
      rarityColor: Color(0xFFDEB7FF),
      imagePath: 'assets/images/pixel_scroll.jpg',
      description:
          'Contains forgotten history lore of ancient civilizations. Unlocks extra History Tower trials.',
      perkText: '+25 HISTORY LORE XP',
      price: 800,
      currency: 'COINS',
    ),
  ];

  static const List<ShopItemModel> _gearItems = [
    ShopItemModel(
      id: 'g_robe',
      name: 'Void-Walker Mantle',
      category: 'ROBE',
      rarity: 'LEGENDARY',
      rarityColor: Color(0xFFF2CA50),
      imagePath: 'assets/images/pixel_robe.jpg',
      description:
          'Woven from the silk of abyss spiders. Grants temporary invisibility in shadowed corridors.',
      perkText: '+30% FOCUS XP',
      price: 250,
      currency: 'GEMS',
    ),
    ShopItemModel(
      id: 'g_wand',
      name: 'Arcane Code Wand',
      category: 'WEAPON',
      rarity: 'LEGENDARY',
      rarityColor: Color(0xFFF2CA50),
      imagePath: 'assets/images/pixel_wand.jpg',
      description: 'Casts glowing cyan particles whenever you submit quiz answers.',
      perkText: '+10% SPEED ANSWER BONUS',
      price: 350,
      currency: 'GEMS',
    ),
  ];

  static const List<ShopItemModel> _boostItems = [
    ShopItemModel(
      id: 'b_potion',
      name: 'Alchemy Health Potion',
      category: 'CONSUMABLE',
      rarity: 'COMMON',
      rarityColor: Color(0xFF82C0A0),
      imagePath: 'assets/images/pixel_potion.jpg',
      description: 'Instantly restores 50 Explorer Energy points to continue world quests.',
      perkText: '+50 EXPLORER ENERGY',
      price: 200,
      currency: 'COINS',
    ),
    ShopItemModel(
      id: 'b_gem',
      name: 'Math Sorcerer Gem',
      category: 'CATALYST',
      rarity: 'LEGENDARY',
      rarityColor: Color(0xFFF2CA50),
      imagePath: 'assets/images/pixel_gem.jpg',
      description: 'Amplifies numerical calculations during boss quiz challenges.',
      perkText: '+25% MATH SPEED',
      price: 150,
      currency: 'GEMS',
    ),
  ];

  void _handlePurchase(ShopItemModel item) {
    final bool canAfford = item.currency == 'COINS'
        ? _playerCoins >= item.price
        : _playerGems >= item.price;

    if (!canAfford) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'INSUFFICIENT ${item.currency == 'COINS' ? 'COINS' : 'GEMS'} FOR ${item.name.toUpperCase()}!',
            style: GoogleFonts.pressStart2p(fontSize: 8, color: Colors.white),
          ),
          backgroundColor: const Color(0xFF8B0000),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      if (item.currency == 'COINS') {
        _playerCoins -= item.price;
      } else {
        _playerGems -= item.price;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Color(0xFF82C0A0)),
            const SizedBox(width: 8),
            Text(
              'SUCCESSFULLY PURCHASED ${item.name.toUpperCase()}!',
              style: GoogleFonts.pressStart2p(fontSize: 8, color: Colors.white),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1E1E32),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: SafeArea(
        child: Column(
          children: [
            // Top Header Bar
            _buildTopHeaderBar(context),

            // Main Viewport: Left Sidebar + Grid of Item Cards
            Expanded(
              child: Row(
                children: [
                  // 1. Left Sidebar Navigation Rail
                  _buildNavRail(),

                  // Vertical Gold Pixel Separator
                  Container(width: 2, color: const Color(0xFFF2CA50)),

                  // 2. Combined Middle & Right Area: Grid of Reference Shop Cards
                  Expanded(
                    child: _buildShopGridArea(),
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
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E32),
        border: const Border(
          bottom: BorderSide(color: Color(0xFFF2CA50), width: 2),
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black, offset: Offset(0, 3), blurRadius: 0),
        ],
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
                  const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Color(0xFFF2CA50), size: 12),
                  const SizedBox(width: 4),
                  Text(
                    'BACK',
                    style: GoogleFonts.pressStart2p(
                      fontSize: 8,
                      color: const Color(0xFFF2CA50),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 14),

          Expanded(
            child: Row(
              children: [
                const Icon(Icons.storefront_rounded,
                    color: Color(0xFFF2CA50), size: 18),
                const SizedBox(width: 8),
                Text(
                  'ARCANE BAZAAR',
                  style: GoogleFonts.pressStart2p(
                    fontSize: 10,
                    color: const Color(0xFFF2CA50),
                  ),
                ),
              ],
            ),
          ),

          // Currency Counters
          Row(
            children: [
              _buildCurrencyBadge('$_playerCoins', '🪙', const Color(0xFFF2CA50)),
              const SizedBox(width: 8),
              _buildCurrencyBadge('$_playerGems', '💎', const Color(0xFFDEB7FF)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyBadge(String value, String icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF28283D),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 11)),
          const SizedBox(width: 4),
          Text(
            value,
            style: GoogleFonts.pressStart2p(fontSize: 8, color: color),
          ),
        ],
      ),
    );
  }

  // ─── 1. LEFT SIDEBAR NAVIGATION ────────────────────────────────────────────
  Widget _buildNavRail() {
    final navItems = [
      {'label': 'FEATURED', 'icon': Icons.local_fire_department_rounded},
      {'label': 'GEAR', 'icon': Icons.checkroom_rounded},
      {'label': 'BOOSTS', 'icon': Icons.bolt_rounded},
      {'label': 'VAULT', 'icon': Icons.account_balance_wallet_rounded},
    ];

    return Container(
      width: 115,
      color: const Color(0xFF141424),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: List.generate(navItems.length, (idx) {
          final isSelected = _activeNavIndex == idx;
          final item = navItems[idx];
          return GestureDetector(
            onTap: () => setState(() => _activeNavIndex = idx),
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF28283D) : const Color(0xFF1B1B2C),
                border: Border.all(
                  color: isSelected ? const Color(0xFFF2CA50) : const Color(0xFF3C382A),
                  width: 2,
                ),
                boxShadow: isSelected
                    ? const [
                        BoxShadow(
                            color: Colors.black,
                            offset: Offset(2, 2),
                            blurRadius: 0),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    item['icon'] as IconData,
                    color: isSelected
                        ? const Color(0xFFF2CA50)
                        : const Color(0xFF8C867A),
                    size: 20,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item['label'] as String,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.pressStart2p(
                      fontSize: 7.5,
                      color: isSelected
                          ? const Color(0xFFF2CA50)
                          : const Color(0xFF8C867A),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  // ─── 2. MAIN SHOP GRID (REFERENCE IMAGE MATCH) ──────────────────────────────
  Widget _buildShopGridArea() {
    final items = _activeNavIndex == 0
        ? _featuredItems
        : _activeNavIndex == 1
            ? _gearItems
            : _boostItems;

    return Container(
      color: const Color(0xFF0F0F1A),
      padding: const EdgeInsets.all(16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final int crossAxisCount = constraints.maxWidth > 700 ? 3 : 2;

          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: 0.65,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: items.length,
            itemBuilder: (ctx, i) => _buildReferenceShopCard(items[i]),
          );
        },
      ),
    );
  }

  /// Single Shop Item Card matching the reference image layout in 16-bit RPG theme!
  Widget _buildReferenceShopCard(ShopItemModel item) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E32),
        border: Border.all(color: const Color(0xFFF2CA50), width: 2),
        boxShadow: const [
          BoxShadow(
            color: Colors.black,
            blurRadius: 0,
            offset: Offset(3, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Showcase Stage Frame holding Pixel Art Image
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF141424),
                border: Border.all(color: const Color(0xFF4D4635), width: 1.5),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Pixel Art Image Artwork
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Image.asset(
                      item.imagePath,
                      fit: BoxFit.contain,
                      errorBuilder: (ctx, err, stack) => Icon(
                        Icons.workspace_premium_rounded,
                        size: 56,
                        color: item.rarityColor,
                      ),
                    ),
                  ),

                  // Tag Badge (if any)
                  if (item.tagText.isNotEmpty)
                    Positioned(
                      top: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2CA50),
                          border: Border.all(color: Colors.black),
                        ),
                        child: Text(
                          item.tagText,
                          style: GoogleFonts.pressStart2p(
                            fontSize: 6,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Title & Price Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  item.name,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.pressStart2p(
                    fontSize: 8.5,
                    color: const Color(0xFFF2CA50),
                  ),
                ),
              ),
              const SizedBox(width: 6),

              // Price Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF28283D),
                  border: Border.all(color: const Color(0xFFF2CA50)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.currency == 'COINS' ? '🪙' : '💎',
                      style: const TextStyle(fontSize: 10),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '${item.price}',
                      style: GoogleFonts.pressStart2p(
                        fontSize: 8,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Description Text
          Text(
            item.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.pressStart2p(
              fontSize: 6.5,
              color: const Color(0xFFD0C5AF),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 10),

          // Golden Pixel Purchase Button
          InkWell(
            onTap: () => _handlePurchase(item),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF2CA50),
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black,
                    blurRadius: 0,
                    offset: Offset(2, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.shopping_cart_rounded,
                    color: Colors.black,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'PURCHASE',
                    style: GoogleFonts.pressStart2p(
                      fontSize: 9,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
