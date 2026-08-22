import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/player_profile.dart';
import '../services/inventory_catalog.dart';
import 'shop_screen.dart';

/// 16-Bit RPG Inventory & Backpack Screen.
/// Displays ONLY items actually purchased and owned by the player.
class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  GameItem? _selectedItem;
  int _activeFilterIndex = 0; // 0: ALL, 1: GEAR, 2: RELICS, 3: CONSUMABLES

  PlayerProfile? _profile;
  List<GameItem> _ownedItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInventory();
  }

  Future<void> _loadInventory() async {
    final p = PlayerProfile.current ?? await PlayerProfile.load();
    final List<GameItem> resolved = [];

    if (p != null) {
      for (final id in p.ownedItems) {
        final item = InventoryCatalog.getItemById(id);
        if (item != null) {
          resolved.add(item);
        }
      }
    }

    if (mounted) {
      setState(() {
        _profile = p;
        _ownedItems = resolved;
        if (resolved.isNotEmpty) {
          _selectedItem = resolved.first;
        } else {
          _selectedItem = null;
        }
        _isLoading = false;
      });
    }
  }

  List<GameItem> get _filteredItems {
    if (_activeFilterIndex == 1) {
      return _ownedItems.where((i) => i.category == 'ROBE' || i.category == 'WEAPON' || i.category == 'ACCESSORY').toList();
    } else if (_activeFilterIndex == 2) {
      return _ownedItems.where((i) => i.category == 'RELIC' || i.category == 'LORE ARTIFACT' || i.category == 'ARTIFACT' || i.category == 'EQUIPMENT').toList();
    } else if (_activeFilterIndex == 3) {
      return _ownedItems.where((i) => i.category == 'CONSUMABLE' || i.category == 'CATALYST' || i.category == 'ENCHANTMENT').toList();
    }
    return _ownedItems;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: SafeArea(
        child: Column(
          children: [
            // Top Header Bar
            _buildTopHeaderBar(),

            // Main Viewport: Left Backpack Grid + Right Item Inspector
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Color(0xFFF2CA50)),
                    )
                  : _ownedItems.isEmpty
                      ? _buildEmptyBackpackState()
                      : Row(
                          children: [
                            // 1. Left Backpack Grid Area
                            Expanded(
                              flex: 6,
                              child: _buildBackpackGridArea(),
                            ),

                            // Vertical Gold Separator
                            Container(width: 2, color: const Color(0xFFF2CA50)),

                            // 2. Right Item Inspector Area
                            Expanded(
                              flex: 4,
                              child: _buildInspectorArea(),
                            ),
                          ],
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopHeaderBar() {
    final coins = _profile?.coins ?? 500;
    final gems = _profile?.gems ?? 25;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E32),
        border: const Border(
          bottom: BorderSide(color: Color(0xFFF2CA50), width: 2),
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black, offset: Offset(0, 3)),
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
                const Icon(Icons.backpack_rounded,
                    color: Color(0xFFF2CA50), size: 18),
                const SizedBox(width: 8),
                Text(
                  'EXPLORER BACKPACK',
                  style: GoogleFonts.pressStart2p(
                    fontSize: 10,
                    color: const Color(0xFFF2CA50),
                  ),
                ),
              ],
            ),
          ),

          // Currency Badges
          Row(
            children: [
              _buildCurrencyBadge('$coins', '🪙', const Color(0xFFF2CA50)),
              const SizedBox(width: 8),
              _buildCurrencyBadge('$gems', '💎', const Color(0xFFDEB7FF)),
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

  // ─── EMPTY STATE ──────────────────────────────────────────────────────────
  Widget _buildEmptyBackpackState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 460),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E32),
          border: Border.all(color: const Color(0xFFF2CA50), width: 3),
          boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(4, 4))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.inventory_2_outlined, size: 54, color: Color(0xFFF2CA50)),
            const SizedBox(height: 16),
            Text(
              'BACKPACK IS EMPTY',
              style: GoogleFonts.pressStart2p(fontSize: 12, color: const Color(0xFFF2CA50)),
            ),
            const SizedBox(height: 12),
            Text(
              'You have not purchased any items from the Arcane Bazaar yet. Visit the shop to acquire legendary gear, relics, and booster potions!',
              textAlign: TextAlign.center,
              style: GoogleFonts.pressStart2p(
                fontSize: 7.5,
                color: const Color(0xFFD0C5AF),
                height: 1.6,
              ),
            ),
            const SizedBox(height: 24),
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ShopScreen()),
                ).then((_) => _loadInventory());
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2CA50),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.storefront_rounded, color: Colors.black, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'VISIT ARCANE BAZAAR',
                      style: GoogleFonts.pressStart2p(fontSize: 9, color: Colors.black),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── LEFT: BACKPACK GRID ──────────────────────────────────────────────────
  Widget _buildBackpackGridArea() {
    final filters = ['ALL', 'GEAR', 'RELICS', 'BOOSTS'];
    final items = _filteredItems;

    return Container(
      color: const Color(0xFF141424),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Tabs
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(filters.length, (idx) {
                final isSelected = _activeFilterIndex == idx;
                return GestureDetector(
                  onTap: () => setState(() => _activeFilterIndex = idx),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFF2CA50) : const Color(0xFF28283D),
                      border: Border.all(color: const Color(0xFFF2CA50), width: 1.5),
                    ),
                    child: Text(
                      filters[idx],
                      style: GoogleFonts.pressStart2p(
                        fontSize: 7.5,
                        color: isSelected ? Colors.black : const Color(0xFFD0C5AF),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 16),

          // Items Grid
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.85,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: items.length,
              itemBuilder: (ctx, i) {
                final item = items[i];
                final isSelected = _selectedItem?.id == item.id;

                return GestureDetector(
                  onTap: () => setState(() => _selectedItem = item),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF28283D) : const Color(0xFF1E1E32),
                      border: Border.all(
                        color: isSelected ? const Color(0xFFF2CA50) : const Color(0xFF4D4635),
                        width: isSelected ? 2.5 : 1.5,
                      ),
                      boxShadow: isSelected
                          ? const [BoxShadow(color: Color(0xFFF2CA50), spreadRadius: 1)]
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Image.asset(
                            item.imagePath,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => Icon(
                              item.icon,
                              color: item.rarityColor,
                              size: 32,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.pressStart2p(
                            fontSize: 6.5,
                            color: isSelected ? const Color(0xFFF2CA50) : Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ─── RIGHT: ITEM INSPECTOR ────────────────────────────────────────────────
  Widget _buildInspectorArea() {
    final item = _selectedItem;
    if (item == null) {
      return Container(
        color: const Color(0xFF0F0F1A),
        child: Center(
          child: Text(
            'SELECT AN ITEM\nTO INSPECT',
            textAlign: TextAlign.center,
            style: GoogleFonts.pressStart2p(fontSize: 8, color: const Color(0xFF8888A0), height: 1.6),
          ),
        ),
      );
    }

    return Container(
      color: const Color(0xFF0F0F1A),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Item Image Stage
          Container(
            height: 140,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF141424),
              border: Border.all(color: item.rarityColor, width: 2),
            ),
            child: Image.asset(
              item.imagePath,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Icon(
                item.icon,
                color: item.rarityColor,
                size: 56,
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Name & Rarity
          Text(
            item.name.toUpperCase(),
            style: GoogleFonts.pressStart2p(
              fontSize: 10,
              color: const Color(0xFFF2CA50),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${item.rarity} • ${item.category}',
            style: GoogleFonts.pressStart2p(
              fontSize: 7,
              color: item.rarityColor,
            ),
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFF333348)),
          const SizedBox(height: 8),

          // Stats & Perks
          Text(
            'ACTIVE PERK:',
            style: GoogleFonts.pressStart2p(fontSize: 7, color: const Color(0xFF82C0A0)),
          ),
          const SizedBox(height: 4),
          Text(
            item.stats,
            style: GoogleFonts.pressStart2p(fontSize: 8, color: Colors.white),
          ),
          const SizedBox(height: 12),

          // Lore / Description
          Text(
            'LORE & DESCRIPTION:',
            style: GoogleFonts.pressStart2p(fontSize: 7, color: const Color(0xFF8888A0)),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: SingleChildScrollView(
              child: Text(
                item.description,
                style: GoogleFonts.pressStart2p(
                  fontSize: 7,
                  color: const Color(0xFFD0C5AF),
                  height: 1.6,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Equip / Use Button
          InkWell(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${item.name.toUpperCase()} IS EQUIPPED!',
                    style: GoogleFonts.pressStart2p(fontSize: 8, color: Colors.white),
                  ),
                  backgroundColor: const Color(0xFF065F46),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF2CA50),
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: const [BoxShadow(color: Colors.black, offset: Offset(2, 2))],
              ),
              child: Center(
                child: Text(
                  item.category == 'CONSUMABLE' ? 'CONSUME POTION' : 'EQUIP ITEM',
                  style: GoogleFonts.pressStart2p(fontSize: 8.5, color: Colors.black),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
