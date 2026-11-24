import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/foundation.dart';
import 'package:csv/csv.dart';
import '../models/place_model.dart';
import '../models/menu_item_model.dart';

class CsvDataService {
  static List<PlaceModel>? _cachedPlaces;
  static List<MenuItemModel>? _cachedMenuItems;

  // Curated aesthetic cafe imagery for variety
  static const List<String> _cafePhotoPool = [
    'https://images.unsplash.com/photo-1554118811-1e0d58224f24?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1521017432531-fbd92d768814?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1509042239860-f550ce710b93?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1559925393-8be0ec4767c8?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1442512595331-e89e73853f31?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1511920170033-f8396924c348?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1507133750040-4a8f57021571?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1461023058943-07fcbe16d735?auto=format&fit=crop&w=800&q=80',
  ];

  /// Resolves realistic, high-quality photos matching the specific food or beverage name
  static String resolveMenuPhoto(String menuName, [String? existingUrl]) {
    // If merchant explicitly provided a custom image URL that is valid, keep it
    if (existingUrl != null &&
        existingUrl.isNotEmpty &&
        !existingUrl.contains('photo-1509042239860') &&
        !existingUrl.contains('CONTOH_ESTIMASI') &&
        existingUrl.startsWith('http')) {
      // Check if it's already a clean direct photo
      final lowerUrl = existingUrl.toLowerCase();
      // If it's a known mismatched CSV stock url for matcha or chocolate, re-resolve semantically
      if (!lowerUrl.contains('unsplash.com/photo-1542990253') &&
          !lowerUrl.contains('unsplash.com/photo-1517701604599') &&
          !lowerUrl.contains('unsplash.com/photo-1509440159596')) {
        return existingUrl;
      }
    }

    final lower = menuName.toLowerCase();

    // 1. Es Teh / Tea / Lemon Tea
    if (lower.contains('teh') || lower.contains('tea')) {
      return 'https://images.unsplash.com/photo-1556679343-c7306c1976bc?auto=format&fit=crop&w=800&q=80';
    }

    // 2. Matcha / Green Tea
    if (lower.contains('matcha') || lower.contains('green tea')) {
      return 'https://images.unsplash.com/photo-1536256263959-770b48d82b0a?auto=format&fit=crop&w=800&q=80';
    }

    // 3. Coklat / Chocolate
    if (lower.contains('coklat') || lower.contains('cokelat') || lower.contains('chocolate') || lower.contains('choco')) {
      return 'https://images.unsplash.com/photo-1542990253-0b8be8f5f0f7?auto=format&fit=crop&w=800&q=80';
    }

    // 4. Kopi Susu / Gula Aren
    if (lower.contains('susu') || lower.contains('aren') || lower.contains('palm')) {
      return 'https://images.unsplash.com/photo-1517701604599-bb29b565090c?auto=format&fit=crop&w=800&q=80';
    }

    // 5. Americano / Espresso / Long Black
    if (lower.contains('americano') || lower.contains('espresso') || lower.contains('black')) {
      return 'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?auto=format&fit=crop&w=800&q=80';
    }

    // 6. Cafe Latte / Caramel / Cappuccino
    if (lower.contains('latte') || lower.contains('cappuccino') || lower.contains('karamel') || lower.contains('caramel')) {
      return 'https://images.unsplash.com/photo-1534778101976-62847782c213?auto=format&fit=crop&w=800&q=80';
    }

    // 7. Croissant / Pastry
    if (lower.contains('croissant') || lower.contains('pastry')) {
      return 'https://images.unsplash.com/photo-1555507036-ab1f4038808a?auto=format&fit=crop&w=800&q=80';
    }

    // 8. Kentang Goreng / French Fries
    if (lower.contains('kentang') || lower.contains('fries')) {
      return 'https://images.unsplash.com/photo-1576107232684-1279f3908594?auto=format&fit=crop&w=800&q=80';
    }

    // 9. Roti Bakar / Toast / Roti Panggang
    if (lower.contains('roti') || lower.contains('toast') || lower.contains('panggang')) {
      return 'https://images.unsplash.com/photo-1584776296944-ab6fb57b0bdd?auto=format&fit=crop&w=800&q=80';
    }

    // 10. Nasi / Rice
    if (lower.contains('nasi') || lower.contains('rice')) {
      return 'https://images.unsplash.com/photo-1603133872878-684f208fb84b?auto=format&fit=crop&w=800&q=80';
    }

    // 11. Mie / Noodle
    if (lower.contains('mie') || lower.contains('noodle') || lower.contains('ramen')) {
      return 'https://images.unsplash.com/photo-1612927601601-6638404737ce?auto=format&fit=crop&w=800&q=80';
    }

    // 12. Air Mineral / Water
    if (lower.contains('air') || lower.contains('mineral')) {
      return 'https://images.unsplash.com/photo-1548839140-29a749e1bc4e?auto=format&fit=crop&w=800&q=80';
    }

    return 'https://images.unsplash.com/photo-1517701604599-bb29b565090c?auto=format&fit=crop&w=800&q=80';
  }

  /// Resolves realistic, authentic cafe photos based on cafe name and style
  static String resolveCafePhoto(String name, String category, int index) {
    final lower = name.toLowerCase();

    // 1. Franchise / Modern Chain Brands (Janji Jiwa, Kopi Kenangan, dll)
    if (lower.contains('kenangan') || lower.contains('janji jiwa') || lower.contains('point') || lower.contains('tomoro')) {
      return 'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?auto=format&fit=crop&w=800&q=80';
    }

    // 2. Outdoor / Garden / Latar
    if (lower.contains('garden') || lower.contains('latar') || lower.contains('outdoor') || lower.contains('teras') || category == 'Outdoor') {
      const outdoorPool = [
        'https://images.unsplash.com/photo-1554118811-1e0d58224f24?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1559925393-8be0ec4767c8?auto=format&fit=crop&w=800&q=80',
      ];
      return outdoorPool[index % outdoorPool.length];
    }

    // 3. Warkop / Kedai
    if (lower.contains('warkop') || lower.contains('kedai') || lower.contains('depot') || category == 'Kedai') {
      const warkopPool = [
        'https://images.unsplash.com/photo-1442512595331-e89e73853f31?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1511920170033-f8396924c348?auto=format&fit=crop&w=800&q=80',
      ];
      return warkopPool[index % warkopPool.length];
    }

    // 4. Working Space / Roastery
    if (lower.contains('roastery') || lower.contains('space') || lower.contains('bar') || category == 'Working Space') {
      const roasteryPool = [
        'https://images.unsplash.com/photo-1521017432531-fbd92d768814?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1461023058943-07fcbe16d735?auto=format&fit=crop&w=800&q=80',
      ];
      return roasteryPool[index % roasteryPool.length];
    }

    return _cafePhotoPool[index % _cafePhotoPool.length];
  }

  /// Load and parse all coffee shops from assets/data/coffee_shops.csv
  static Future<List<PlaceModel>> loadCoffeeShops() async {
    if (_cachedPlaces != null && _cachedPlaces!.isNotEmpty) {
      return _cachedPlaces!;
    }

    try {
      final rawCsv = await rootBundle.loadString('assets/data/coffee_shops.csv');
      final rows = const CsvToListConverter(
        eol: '\n',
        shouldParseNumbers: false,
      ).convert(rawCsv);

      if (rows.isEmpty) return [];

      final List<PlaceModel> places = [];

      // Skip header row
      for (int i = 1; i < rows.length; i++) {
        final row = rows[i];
        if (row.length < 15) continue;

        final rawOsmId = row[0].toString().trim();
        final osmId = rawOsmId.replaceAll('/', '_');
        final name = row[1].toString().trim();
        if (name.isEmpty) continue;

        final daerah = row[2].toString().trim();
        final kecamatan = row[3].toString().trim();
        final alamat = row[4].toString().trim();
        final jamBuka = row[5].toString().trim();
        final jamTutup = row[6].toString().trim();
        final hargaMin = int.tryParse(row[7].toString().trim()) ?? 10000;
        final hargaMax = int.tryParse(row[8].toString().trim()) ?? 35000;
        final rating = double.tryParse(row[9].toString().trim()) ?? 4.5;
        final deskripsi = row[10].toString().trim();
        final lat = double.tryParse(row[12].toString().trim());
        final lng = double.tryParse(row[13].toString().trim());
        String photo = row[14].toString().trim();

        // Determine category based on name/style
        String category = 'Kafe';
        final lowerName = name.toLowerCase();
        if (lowerName.contains('warkop') || lowerName.contains('kedai') || lowerName.contains('depot')) {
          category = 'Kedai';
        } else if (lowerName.contains('roastery') || lowerName.contains('space') || lowerName.contains('bar')) {
          category = 'Working Space';
        } else if (lowerName.contains('garden') || lowerName.contains('latar') || lowerName.contains('outdoor') || lowerName.contains('teras')) {
          category = 'Outdoor';
        }

        // Assign authentic curated photo for visual variety and realism
        if (photo.isEmpty || photo.contains('unsplash.com/photo-1509042239860')) {
          photo = resolveCafePhoto(name, category, i - 1);
        }

        // Generate opening hours text (e.g. "09:00 - 22:00")
        String openingHours = '';
        if (jamBuka.isNotEmpty && jamTutup.isNotEmpty) {
          final cleanBuka = jamBuka.split(':').take(2).join(':');
          final cleanTutup = jamTutup.split(':').take(2).join(':');
          openingHours = '$cleanBuka - $cleanTutup';
        }

        // Format clean address
        String fullAddress = alamat;
        if (kecamatan.isNotEmpty && !alamat.toLowerCase().contains(kecamatan.toLowerCase())) {
          fullAddress = '$alamat, $kecamatan';
        }

        places.add(
          PlaceModel(
            id: osmId,
            name: name,
            category: category,
            description: deskripsi.isNotEmpty
                ? deskripsi
                : 'Nikmati kopi berkualitas dan suasana nyaman di $name.',
            address: fullAddress,
            daerah: daerah,
            kecamatan: kecamatan,
            imageUrl: photo,
            imageUrls: [
              photo,
              _cafePhotoPool[(i * 3) % _cafePhotoPool.length],
              _cafePhotoPool[(i * 5) % _cafePhotoPool.length],
            ],
            rating: rating,
            reviewCount: 40 + (i * 7) % 180,
            priceMin: hargaMin,
            priceMax: hargaMax,
            openingHours: openingHours.isNotEmpty ? openingHours : '09:00 - 22:00',
            isOpen: true,
            facilities: const [
              'Wi-Fi Cepat',
              'Stopkontak',
              'Area AC',
              'Outdoor',
              'Toilet Bersih',
              'Musholla',
            ],
            latitude: lat,
            longitude: lng,
            acceptsOrder: true,
          ),
        );
      }

      _cachedPlaces = places;
      debugPrint('[CsvDataService] Successfully loaded ${places.length} coffee shops from CSV');
      return places;
    } catch (e, stack) {
      debugPrint('[CsvDataService] Error loading coffee_shops.csv: $e\n$stack');
      return [];
    }
  }

  /// Load and parse all menu items from assets/data/menu_coffeeshop_stok.csv
  static Future<List<MenuItemModel>> loadMenuItems() async {
    if (_cachedMenuItems != null && _cachedMenuItems!.isNotEmpty) {
      return _cachedMenuItems!;
    }

    try {
      String rawCsv;
      try {
        rawCsv = await rootBundle.loadString('assets/data/menu_coffeeshop_stok.csv');
      } catch (_) {
        rawCsv = await rootBundle.loadString('assets/data/menu_coffeeshop_stok_foto.csv');
      }

      final rows = const CsvToListConverter(
        eol: '\n',
        shouldParseNumbers: false,
      ).convert(rawCsv);

      if (rows.isEmpty) return [];

      final List<MenuItemModel> menus = [];

      // Skip header row
      for (int i = 1; i < rows.length; i++) {
        final row = rows[i];
        if (row.length < 10) continue;

        final menuId = row[0].toString().trim();
        final rawOsmId = row[1].toString().trim();
        final osmId = rawOsmId.replaceAll('/', '_');
        final namaMenu = row[3].toString().trim();
        if (namaMenu.isEmpty) continue;

        final kategori = row[4].toString().trim();
        final harga = int.tryParse(row[5].toString().trim()) ?? 18000;
        final stok = int.tryParse(row[6].toString().trim()) ?? 15;
        final satuanStok = row[7].toString().trim();
        final fotoUrl = row[8].toString().trim();
        final deskripsi = row[9].toString().trim();
        final tersediaStr = row.length > 10 ? row[10].toString().trim() : '1';
        final isAvailable = tersediaStr == '1' || tersediaStr.toLowerCase() == 'true';
        final resolvedPhoto = resolveMenuPhoto(namaMenu, fotoUrl);

        menus.add(
          MenuItemModel(
            id: menuId,
            placeId: osmId,
            name: namaMenu,
            category: kategori.isNotEmpty ? kategori : 'Kopi',
            price: harga,
            description: deskripsi.isNotEmpty ? deskripsi : '$namaMenu spesial khas kafe.',
            imageUrl: resolvedPhoto,
            isAvailable: isAvailable,
            stok: stok,
            satuanStok: satuanStok.isNotEmpty ? satuanStok : 'gelas',
          ),
        );
      }

      _cachedMenuItems = menus;
      debugPrint('[CsvDataService] Successfully loaded ${menus.length} menu items from CSV');
      return menus;
    } catch (e, stack) {
      debugPrint('[CsvDataService] Error loading menu CSV: $e\n$stack');
      return [];
    }
  }
}

