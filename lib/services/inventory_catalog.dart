import 'package:flutter/material.dart';

class GameItem {
  final String id;
  final String name;
  final String category;
  final String rarity;
  final Color rarityColor;
  final IconData icon;
  final String imagePath;
  final String description;
  final String stats;
  final int price;
  final String currency; // 'COINS' or 'GEMS'
  final String tagText;

  const GameItem({
    required this.id,
    required this.name,
    required this.category,
    required this.rarity,
    required this.rarityColor,
    required this.icon,
    required this.imagePath,
    required this.description,
    required this.stats,
    required this.price,
    required this.currency,
    this.tagText = '',
  });
}

abstract final class InventoryCatalog {
  static const List<GameItem> allCatalogItems = [
    GameItem(
      id: 'f_robe',
      name: 'Void-Walker Mantle',
      category: 'ROBE',
      rarity: 'LEGENDARY',
      rarityColor: Color(0xFFF2CA50),
      icon: Icons.shield_moon_rounded,
      imagePath: 'assets/images/pixel_robe.jpg',
      description:
          'Woven from the silk of abyss spiders. Grants temporary invisibility in shadowed corridors and +30% Focus XP.',
      stats: '+30% Focus XP',
      price: 250,
      currency: 'GEMS',
      tagText: 'HOT DEAL',
    ),
    GameItem(
      id: 'f_wand',
      name: 'Arcane Code Wand',
      category: 'WEAPON',
      rarity: 'LEGENDARY',
      rarityColor: Color(0xFFF2CA50),
      icon: Icons.auto_fix_high_rounded,
      imagePath: 'assets/images/pixel_wand.jpg',
      description:
          'Forged in coding towers to cast swift logic algorithms. Emits cyan sparks during quiz trials.',
      stats: '+15% Speed Bonus',
      price: 350,
      currency: 'GEMS',
      tagText: 'BESTSELLER',
    ),
    GameItem(
      id: 'f_shield',
      name: 'Dragon Boss Shield',
      category: 'RELIC',
      rarity: 'LEGENDARY',
      rarityColor: Color(0xFFF2CA50),
      icon: Icons.security_rounded,
      imagePath: 'assets/images/pixel_shield.jpg',
      description:
          'Protects your daily streak even if a lesson quest is missed due to real-life duties.',
      stats: 'Streak Shield Protection',
      price: 180,
      currency: 'GEMS',
    ),
    GameItem(
      id: 'f_scroll',
      name: 'Ancient Lore Scroll',
      category: 'LORE ARTIFACT',
      rarity: 'EPIC',
      rarityColor: Color(0xFFDEB7FF),
      icon: Icons.menu_book_rounded,
      imagePath: 'assets/images/pixel_scroll.jpg',
      description:
          'Contains forgotten history lore of ancient civilizations. Unlocks extra History Tower trials.',
      stats: '+25 History Lore XP',
      price: 800,
      currency: 'COINS',
    ),
    GameItem(
      id: 'b_potion',
      name: 'Alchemy Health Potion',
      category: 'CONSUMABLE',
      rarity: 'COMMON',
      rarityColor: Color(0xFF82C0A0),
      icon: Icons.science_rounded,
      imagePath: 'assets/images/pixel_potion.jpg',
      description: 'Instantly restores 50 Explorer Energy points to continue world quests.',
      stats: '+50 Explorer Energy',
      price: 200,
      currency: 'COINS',
    ),
    GameItem(
      id: 'b_gem',
      name: 'Math Sorcerer Gem',
      category: 'CATALYST',
      rarity: 'LEGENDARY',
      rarityColor: Color(0xFFF2CA50),
      icon: Icons.diamond_rounded,
      imagePath: 'assets/images/pixel_gem.jpg',
      description: 'Amplifies numerical calculations during boss quiz challenges.',
      stats: '+25% Math Speed',
      price: 150,
      currency: 'GEMS',
    ),
    GameItem(
      id: 'ring',
      name: 'Emerald Focus Ring',
      category: 'ACCESSORY',
      rarity: 'RARE',
      rarityColor: Color(0xFF60A5FA),
      icon: Icons.ring_volume_rounded,
      imagePath: 'assets/images/pixel_gem.jpg',
      description: 'Glows brightly when solving complex geometry challenges.',
      stats: '+15 Focus XP',
      price: 600,
      currency: 'COINS',
    ),
    GameItem(
      id: 'telescope',
      name: 'Astronomy Telescope',
      category: 'EQUIPMENT',
      rarity: 'RARE',
      rarityColor: Color(0xFF60A5FA),
      icon: Icons.explore_rounded,
      imagePath: 'assets/images/pixel_scroll.jpg',
      description: 'Allows stargazing to locate hidden physics islands.',
      stats: '+10 Space Vision',
      price: 750,
      currency: 'COINS',
    ),
    GameItem(
      id: 'crystal',
      name: 'Code Mana Crystal',
      category: 'ENCHANTMENT',
      rarity: 'EPIC',
      rarityColor: Color(0xFFDEB7FF),
      icon: Icons.code_rounded,
      imagePath: 'assets/images/pixel_wand.jpg',
      description: 'Accelerates Dart & Flutter algorithm solving speed.',
      stats: '+20 Focus XP',
      price: 220,
      currency: 'GEMS',
    ),
    GameItem(
      id: 'compass',
      name: 'Golden Navigator Compass',
      category: 'ARTIFACT',
      rarity: 'EPIC',
      rarityColor: Color(0xFFDEB7FF),
      icon: Icons.explore,
      imagePath: 'assets/images/pixel_shield.jpg',
      description: 'Points to secret uncharted islands in the archipelago.',
      stats: '+5 Discovery',
      price: 900,
      currency: 'COINS',
    ),
  ];

  static GameItem? getItemById(String id) {
    for (final item in allCatalogItems) {
      if (item.id == id) return item;
    }
    return null;
  }

  static List<GameItem> getFeaturedItems() {
    return allCatalogItems.where((i) => i.tagText.isNotEmpty || i.rarity == 'LEGENDARY').toList();
  }

  static List<GameItem> getGearItems() {
    return allCatalogItems.where((i) => i.category == 'ROBE' || i.category == 'WEAPON' || i.category == 'RELIC' || i.category == 'ACCESSORY').toList();
  }

  static List<GameItem> getBoostItems() {
    return allCatalogItems.where((i) => i.category == 'CONSUMABLE' || i.category == 'CATALYST' || i.category == 'ENCHANTMENT').toList();
  }

  static List<GameItem> getVaultItems() {
    return allCatalogItems.where((i) => i.category == 'LORE ARTIFACT' || i.category == 'ARTIFACT' || i.category == 'EQUIPMENT').toList();
  }
}
