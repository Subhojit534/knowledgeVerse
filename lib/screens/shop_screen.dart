import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/player_profile.dart';
import '../services/api_service.dart';
import '../services/inventory_catalog.dart';

/// Authentic 16-Bit Arcane Shop & Bazaar Screen.
/// Connected with live player coins, gems, and persistent inventory storage.
class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  int _activeNavIndex = 0; // 0: Featured, 1: Gear, 2: Boosts, 3: Vault

  PlayerProfile? _profile;
  int _playerCoins = 500;
  int _playerGems = 25;
  List<String> _ownedItems = [];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final p = PlayerProfile.current ?? await PlayerProfile.load();
    if (p != null && mounted) {
      setState(() {
        _profile = p;
        _playerCoins = p.coins;
        _playerGems = p.gems;
        _ownedItems = List<String>.from(p.ownedItems);
      });
    }
  }

  void _handlePurchase(GameItem item) async {
    if (_ownedItems.contains(item.id) && item.category != 'CONSUMABLE') {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'YOU ALREADY OWN ${item.name.toUpperCase()}!',
            style: GoogleFonts.pressStart2p(fontSize: 8, color: const Color(0xFFF2CA50)),
          ),
          backgroundColor: const Color(0xFF1E1E32),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

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

    final currentProfile = _profile ?? PlayerProfile.current ?? const PlayerProfile();
    final updatedProfile = currentProfile.withPurchasedItem(
      itemId: item.id,
      price: item.price,
      currency: item.currency,
    );

    await updatedProfile.save();

    // Async notify backend DB
    Future(() async {
      try {
        final targetUserId = updatedProfile.id.isNotEmpty ? updatedProfile.id : updatedProfile.name;
        await ApiService.post('/api/shop/purchase', body: {
          'userId': targetUserId,
          'shopItemId': item.id,
        });
      } catch (_) {}
    });

    if (mounted) {
      setState(() {
        _profile = updatedProfile;
        _playerCoins = updatedProfile.coins;
        _playerGems = updatedProfile.gems;
        _ownedItems = List<String>.from(updatedProfile.ownedItems);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Color(0xFF82C0A0)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'ACQUIRED ${item.name.toUpperCase()}! ITEM ADDED TO INVENTORY.',
                  style: GoogleFonts.pressStart2p(fontSize: 8, color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF065F46),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
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

          // Live Currency Counters
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
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
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
                  color: isSelected ? const Color(0xFF28283D) : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? const Color(0xFFF2CA50) : const Color(0xFF333348),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      item['icon'] as IconData,
                      color: isSelected ? const Color(0xFFF2CA50) : const Color(0xFF8888A0),
                      size: 20,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item['label'] as String,
                      style: GoogleFonts.pressStart2p(
                        fontSize: 6.5,
                        color: isSelected ? const Color(0xFFF2CA50) : const Color(0xFF8888A0),
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


  // ─── 2. SHOP GRID VIEWPORT ──────────────────────────────────────────────────
  Widget _buildShopGridArea() {
    List<GameItem> items;
    if (_activeNavIndex == 0) {
      items = InventoryCatalog.getFeaturedItems();
    } else if (_activeNavIndex == 1) {
      items = InventoryCatalog.getGearItems();
    } else if (_activeNavIndex == 2) {
      items = InventoryCatalog.getBoostItems();
    } else {
      items = InventoryCatalog.getVaultItems();
    }

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

  /// Single Shop Item Card matching 16-bit RPG theme
  Widget _buildReferenceShopCard(GameItem item) {
    final bool isOwned = _ownedItems.contains(item.id) && item.category != 'CONSUMABLE';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E32),
        border: Border.all(
          color: isOwned ? const Color(0xFF82C0A0) : const Color(0xFFF2CA50),
          width: 2,
        ),
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
                        item.icon,
                        size: 48,
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

                  // Owned indicator badge
                  if (isOwned)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF065F46),
                          border: Border.all(color: const Color(0xFF82C0A0)),
                        ),
                        child: Text(
                          'OWNED',
                          style: GoogleFonts.pressStart2p(fontSize: 6, color: Colors.white),
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
                    color: isOwned ? const Color(0xFF82C0A0) : const Color(0xFFF2CA50),
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

          // Purchase / Owned Action Button
          InkWell(
            onTap: isOwned ? null : () => _handlePurchase(item),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isOwned ? const Color(0xFF28283D) : const Color(0xFFF2CA50),
                border: Border.all(
                  color: isOwned ? const Color(0xFF82C0A0) : Colors.white,
                  width: 2,
                ),
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
                  Icon(
                    isOwned ? Icons.check_circle_rounded : Icons.shopping_cart_rounded,
                    color: isOwned ? const Color(0xFF82C0A0) : Colors.black,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isOwned ? 'OWNED' : 'PURCHASE',
                    style: GoogleFonts.pressStart2p(
                      fontSize: 9,
                      color: isOwned ? const Color(0xFF82C0A0) : Colors.black,
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
