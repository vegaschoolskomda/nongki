// =============================================================================
// [DEVELOPMENT MOCK DATA]
// Data ini HANYA digunakan untuk tahap pengembangan dan preview UI.
// Struktur data diselaraskan dengan skema database Supabase PostgreSQL.
// =============================================================================

import '../models/user_model.dart';
import '../models/place_model.dart';
import '../models/menu_item_model.dart';
import '../models/order_model.dart';
import '../models/review_model.dart';

class MockData {
  MockData._();

  /// Mock User untuk session awal development (Vega dari Sidoarjo)
  static final UserModel defaultUser = UserModel(
    id: 'usr_dev_001',
    name: 'Vega',
    username: 'vega',
    email: 'vega@nongki.id',
    phone: '081234567890',
    avatarUrl: null,
    role: 'customer',
    createdAt: DateTime.now().subtract(const Duration(days: 30)),
  );

  /// Mock Places yang mencakup berbagai kategori dan budget sesuai desain
  static final List<PlaceModel> places = [
    // 1. Featured Place pada Beranda
    PlaceModel(
      id: 'plc_featured',
      name: 'Es Coklat Impian',
      category: 'Kafe',
      description:
          'Tempat nongki viral bernuansa industrial kayu yang nyaman dengan menu es coklat legendaris dan roti celup empuk.',
      address: 'Kavling DPR, Sidoarjo',
      imageUrl: 'https://images.unsplash.com/photo-1554118811-1e0d58224f24?auto=format&fit=crop&w=800&q=80',
      imageUrls: [
        'https://images.unsplash.com/photo-1554118811-1e0d58224f24?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?auto=format&fit=crop&w=800&q=80',
      ],
      rating: 4.7,
      reviewCount: 120,
      priceMin: 12000,
      priceMax: 30000,
      openingHours: '09:00 - 22:00 WIB',
      isOpen: true,
      facilities: ['Wi-Fi Cepat', 'Stopkontak', 'Area Ber-AC', 'Musholla', 'Parkir Luas'],
      latitude: -7.4478,
      longitude: 112.7183,
      acceptsOrder: true,
    ),

    // 2. Ruang Temu Coffee (Budget pilihan)
    PlaceModel(
      id: 'plc_budget_1',
      name: 'Ruang Temu Coffee',
      category: 'Kafe',
      description:
          'Kafe bernuansa santai yang pas buat nugas dan ngobrol bareng teman, dengan stopkontak di setiap sudut dan Wi-Fi kencang.',
      address: 'Setiabudi · 1.2 km',
      imageUrl: 'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?auto=format&fit=crop&w=800&q=80',
      imageUrls: [
        'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?auto=format&fit=crop&w=800&q=80',
      ],
      rating: 4.8,
      reviewCount: 96,
      priceMin: 15000,
      priceMax: 35000,
      openingHours: '08:00 - 23:00 WIB',
      isOpen: true,
      facilities: ['Wi-Fi', 'Stopkontak', 'Musholla', 'Outdoor'],
      latitude: -7.4421,
      longitude: 112.7150,
      acceptsOrder: true,
    ),

    // 3. Sudut Senja Coffee
    PlaceModel(
      id: 'plc_budget_2',
      name: 'Sudut Senja Coffee',
      category: 'Outdoor',
      description:
          'Konsep nongki outdoor asri yang sejuk di sore hari. Tempat favorit untuk ngobrol santai menikmati senja.',
      address: 'Dago · 2.4 km',
      imageUrl: 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=800&q=80',
      imageUrls: [
        'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=800&q=80',
      ],
      rating: 4.6,
      reviewCount: 78,
      priceMin: 14000,
      priceMax: 32000,
      openingHours: '14:00 - 00:00 WIB',
      isOpen: true,
      facilities: ['Outdoor', 'Tenang', 'Live Music'],
      latitude: -7.4510,
      longitude: 112.7210,
      acceptsOrder: true,
    ),

    // 4. Kopi Kenangan Senja
    PlaceModel(
      id: 'plc_001',
      name: 'Kopi Kenangan Senja',
      category: 'Kafe',
      description:
          'Kafe bernuansa hangat dengan aroma seduhan biji kopi pilihan nusantara. Tempat yang tenang untuk bercengkerama santai.',
      address: 'Jl. Riau No. 42, Sidoarjo',
      imageUrl: 'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?auto=format&fit=crop&w=800&q=80',
      imageUrls: [
        'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?auto=format&fit=crop&w=800&q=80',
      ],
      rating: 4.8,
      reviewCount: 124,
      priceMin: 18000,
      priceMax: 45000,
      openingHours: '08:00 - 22:00 WIB',
      isOpen: true,
      facilities: ['Wi-Fi Cepat', 'Stopkontak', 'Area Ber-AC'],
      latitude: -7.4430,
      longitude: 112.7160,
      acceptsOrder: true,
    ),

    // 5. Kedai Sedap Sudut Kota
    PlaceModel(
      id: 'plc_004',
      name: 'Kedai Sedap Sudut Kota',
      category: 'Kedai',
      description:
          'Kedai kopi ramah kantong dengan cemilan lokal otentik seperti roti bakar pandan dan pisang goreng karamel.',
      address: 'Jl. Dipati Ukur No. 23, Sidoarjo',
      imageUrl: 'https://images.unsplash.com/photo-1509042239860-f550ce710b93?auto=format&fit=crop&w=800&q=80',
      imageUrls: [
        'https://images.unsplash.com/photo-1509042239860-f550ce710b93?auto=format&fit=crop&w=800&q=80',
      ],
      rating: 4.9,
      reviewCount: 210,
      priceMin: 10000,
      priceMax: 28000,
      openingHours: '09:00 - 23:00 WIB',
      isOpen: true,
      facilities: ['Wi-Fi Gratis', 'Stopkontak', 'Harga Mahasiswa'],
      latitude: -7.4490,
      longitude: 112.7190,
      acceptsOrder: true,
    ),

    // 6. Kopi Nusantara — Demo Merchant Store 2
    PlaceModel(
      id: 'plc_kopi_nusantara',
      name: 'Kopi Nusantara',
      category: 'Kafe',
      description: 'Kafe kopi lokal nusantara dengan biji kopi pilihan dari berbagai daerah Indonesia. Suasana hangat dan nyaman.',
      address: 'Jl. Raya Trosobo No. 12, Sidoarjo',
      imageUrl: 'https://images.unsplash.com/photo-1521017432531-fbd92d768814?auto=format&fit=crop&w=800&q=80',
      imageUrls: [
        'https://images.unsplash.com/photo-1521017432531-fbd92d768814?auto=format&fit=crop&w=800&q=80',
        'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?auto=format&fit=crop&w=800&q=80',
      ],
      rating: 4.5,
      reviewCount: 87,
      priceMin: 10000,
      priceMax: 32000,
      openingHours: '08:00 - 22:00 WIB',
      isOpen: true,
      facilities: ['Wi-Fi Cepat', 'Stopkontak', 'Area Non-Smoking', 'Parkir Motor'],
      latitude: -7.4460,
      longitude: 112.7160,
      acceptsOrder: true,
      ownerId: 'usr_merchant_002',
      verificationStatus: 'verified',
    ),
  ];

  /// Mock Menu Items
  static final List<MenuItemModel> menuItems = [
    // Menu Es Coklat Impian (plc_featured)
    const MenuItemModel(
      id: 'mnu_imp_001',
      placeId: 'plc_featured',
      name: 'Es Coklat Impian Klasik',
      description: 'Coklat kental manis legit dingin disajikan dengan es batu segar dan aroma kakao pekat.',
      price: 15000,
      imageUrl: 'https://images.unsplash.com/photo-1541167760496-1628856ab772?auto=format&fit=crop&w=400&q=80',
      category: 'Non-Kopi',
      isAvailable: true,
    ),
    const MenuItemModel(
      id: 'mnu_imp_002',
      placeId: 'plc_featured',
      name: 'Roti Panggang Celup Mentega',
      description: 'Roti sobek empuk dipanggang gurih dengan butter, pasangan sempurna es coklat.',
      price: 10000,
      imageUrl: 'https://images.unsplash.com/photo-1555507036-ab1f4038808a?auto=format&fit=crop&w=400&q=80',
      category: 'Camilan',
      isAvailable: true,
    ),
    const MenuItemModel(
      id: 'mnu_imp_003',
      placeId: 'plc_featured',
      name: 'Kopi Susu Coklat Aren',
      description: 'Paduan espresso arabika, susu segar, lelehan coklat murni, dan gula aren organik.',
      price: 20000,
      imageUrl: 'https://images.unsplash.com/photo-1517701550927-30cf4ba1dba5?auto=format&fit=crop&w=400&q=80',
      category: 'Kopi',
      isAvailable: true,
    ),

    // Menu Ruang Temu Coffee (plc_budget_1)
    const MenuItemModel(
      id: 'mnu_rt_001',
      placeId: 'plc_budget_1',
      name: 'Kopi Susu Ruang Temu',
      description: 'Espresso creamy dengan susu pilihan dan sentuhan sirup karamel gurih.',
      price: 18000,
      imageUrl: 'https://images.unsplash.com/photo-1541167760496-1628856ab772?auto=format&fit=crop&w=400&q=80',
      category: 'Kopi',
      isAvailable: true,
    ),
    const MenuItemModel(
      id: 'mnu_rt_002',
      placeId: 'plc_budget_1',
      name: 'Kentang Goreng Truffle Herb',
      description: 'Kentang renyah dengan aroma minyak truffle alami dan taburan peterseli gurih.',
      price: 20000,
      imageUrl: 'https://images.unsplash.com/photo-1573080496219-bb080dd4f877?auto=format&fit=crop&w=400&q=80',
      category: 'Camilan',
      isAvailable: true,
    ),

    // Menu Sudut Senja Coffee (plc_budget_2)
    const MenuItemModel(
      id: 'mnu_ss_001',
      placeId: 'plc_budget_2',
      name: 'Es Kopi Senja Lemonade',
      description: 'Paduan segar espresso pekat dengan perasan lemon dan soda berkilau.',
      price: 20000,
      imageUrl: 'https://images.unsplash.com/photo-1517701550927-30cf4ba1dba5?auto=format&fit=crop&w=400&q=80',
      category: 'Kopi',
      isAvailable: true,
    ),
    const MenuItemModel(
      id: 'mnu_ss_002',
      placeId: 'plc_budget_2',
      name: 'Americano Ice Senja',
      description: 'Espresso arabika dingin yang menyegarkan dahaga sore hari.',
      price: 15000,
      imageUrl: 'https://images.unsplash.com/photo-1509042239860-f550ce710b93?auto=format&fit=crop&w=400&q=80',
      category: 'Kopi',
      isAvailable: true,
    ),
    const MenuItemModel(
      id: 'mnu_ss_003',
      placeId: 'plc_budget_2',
      name: 'Sunset Peach Tea',
      description: 'Teh melati dingin dengan sirup buah persik manis dan irisan buah asli.',
      price: 16000,
      imageUrl: 'https://images.unsplash.com/photo-1556679343-c7306c1976bc?auto=format&fit=crop&w=400&q=80',
      category: 'Non-Kopi',
      isAvailable: true,
    ),
    const MenuItemModel(
      id: 'mnu_ss_004',
      placeId: 'plc_budget_2',
      name: 'Choco Lava Toast',
      description: 'Roti panggang dengan lelehan cokelat hangat dan es krim vanilla.',
      price: 22000,
      imageUrl: 'https://images.unsplash.com/photo-1584776296944-ab6fb57b0bdd?auto=format&fit=crop&w=400&q=80',
      category: 'Makanan',
      isAvailable: true,
    ),

    // Menu Kopi Kenangan Senja (plc_001)
    const MenuItemModel(
      id: 'mnu_kks_001',
      placeId: 'plc_001',
      name: 'Kopi Kenangan Mantan',
      description: 'Kopi susu dengan gula aren asli pilihan yang manis dan creamy.',
      price: 18000,
      imageUrl: 'https://images.unsplash.com/photo-1541167760496-1628856ab772?auto=format&fit=crop&w=400&q=80',
      category: 'Kopi',
      isAvailable: true,
    ),
    const MenuItemModel(
      id: 'mnu_kks_002',
      placeId: 'plc_001',
      name: 'Americano Klasik',
      description: 'Espresso murni diseduh dengan air dingin, nikmat dan kuat.',
      price: 15000,
      imageUrl: 'https://images.unsplash.com/photo-1509042239860-f550ce710b93?auto=format&fit=crop&w=400&q=80',
      category: 'Kopi',
      isAvailable: true,
    ),
    const MenuItemModel(
      id: 'mnu_kks_003',
      placeId: 'plc_001',
      name: 'Matcha Latte Kenangan',
      description: 'Matcha premium berpadu lembut dengan susu segar kental manis.',
      price: 22000,
      imageUrl: 'https://images.unsplash.com/photo-1515823064-d6e0c04616a7?auto=format&fit=crop&w=400&q=80',
      category: 'Non-Kopi',
      isAvailable: true,
    ),
    const MenuItemModel(
      id: 'mnu_kks_004',
      placeId: 'plc_001',
      name: 'Es Teh Melati Spesial',
      description: 'Teh melati wangi dingin segar pelepas dahaga.',
      price: 9000,
      imageUrl: 'https://images.unsplash.com/photo-1556679343-c7306c1976bc?auto=format&fit=crop&w=400&q=80',
      category: 'Non-Kopi',
      isAvailable: true,
    ),
    const MenuItemModel(
      id: 'mnu_kks_005',
      placeId: 'plc_001',
      name: 'Roti Bakar Keju Coklat',
      description: 'Roti tebal bakar dengan limpahan keju parut gurih dan meses cokelat.',
      price: 17000,
      imageUrl: 'https://images.unsplash.com/photo-1584776296944-ab6fb57b0bdd?auto=format&fit=crop&w=400&q=80',
      category: 'Makanan',
      isAvailable: true,
    ),
    const MenuItemModel(
      id: 'mnu_kks_006',
      placeId: 'plc_001',
      name: 'Kentang Goreng Krispi',
      description: 'Kentang goreng renyah bumbu gurih dengan saus sambal.',
      price: 15000,
      imageUrl: 'https://images.unsplash.com/photo-1576107232684-1279f3908594?auto=format&fit=crop&w=400&q=80',
      category: 'Makanan',
      isAvailable: true,
    ),

    // Menu Kedai Sedap Sudut Kota (plc_004)
    const MenuItemModel(
      id: 'mnu_kss_001',
      placeId: 'plc_004',
      name: 'Kopi Tubruk Robusta Giling',
      description: 'Kopi tubruk tradisional diseduh panas dengan aroma kuat biji robusta.',
      price: 10000,
      imageUrl: 'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?auto=format&fit=crop&w=400&q=80',
      category: 'Kopi',
      isAvailable: true,
    ),
    const MenuItemModel(
      id: 'mnu_kss_002',
      placeId: 'plc_004',
      name: 'Kopi Tarik Susu',
      description: 'Kopi hitam ditarik berbuih dengan krimer manis lembut khas kedai.',
      price: 13000,
      imageUrl: 'https://images.unsplash.com/photo-1541167760496-1628856ab772?auto=format&fit=crop&w=400&q=80',
      category: 'Kopi',
      isAvailable: true,
    ),
    const MenuItemModel(
      id: 'mnu_kss_003',
      placeId: 'plc_004',
      name: 'Es Jeruk Nipis Madu',
      description: 'Perasan jeruk nipis segar dengan madu alami penambah stamina.',
      price: 12000,
      imageUrl: 'https://images.unsplash.com/photo-1556679343-c7306c1976bc?auto=format&fit=crop&w=400&q=80',
      category: 'Non-Kopi',
      isAvailable: true,
    ),
    const MenuItemModel(
      id: 'mnu_kss_004',
      placeId: 'plc_004',
      name: 'Pisang Goreng Keju Aren',
      description: 'Pisang kepok manis digoreng tepung krispi dengan gula aren dan keju.',
      price: 14000,
      imageUrl: 'https://images.unsplash.com/photo-1584776296944-ab6fb57b0bdd?auto=format&fit=crop&w=400&q=80',
      category: 'Makanan',
      isAvailable: true,
    ),
    const MenuItemModel(
      id: 'mnu_kss_005',
      placeId: 'plc_004',
      name: 'Roti Bakar Pandan Cokelat',
      description: 'Roti pandan harum dibakar dengan olesan mentega dan cokelat lumer.',
      price: 15000,
      imageUrl: 'https://images.unsplash.com/photo-1484723091739-30a097e8f929?auto=format&fit=crop&w=400&q=80',
      category: 'Makanan',
      isAvailable: true,
    ),
  ];

  /// Mock Reviews
  static final List<ReviewModel> reviews = [
    ReviewModel(
      id: 'rev_001',
      placeId: 'plc_featured',
      userId: 'usr_dev_002',
      userName: 'Nadia Putri',
      userAvatar: null,
      orderId: 'ord_mock_prev_1',
      rating: 4.7,
      comment:
          'Es Coklat Impian-nya beneran mantap! Rotinya dicelup pas banget. Suasananya nyaman dan cozy di Kavling DPR.',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    ReviewModel(
      id: 'rev_002',
      placeId: 'plc_budget_1',
      userId: 'usr_dev_003',
      userName: 'Budi Santoso',
      userAvatar: null,
      orderId: 'ord_mock_prev_2',
      rating: 4.8,
      comment:
          'Tempat yang pas banget buat nugas. Wi-Fi kencang dan stopkontak ada di tiap meja.',
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];

  /// Menu Kopi Nusantara (plc_kopi_nusantara) — Merchant Demo 2
  static final List<MenuItemModel> menuKopiNusantara = [
    const MenuItemModel(
      id: 'mnu_kn_001',
      placeId: 'plc_kopi_nusantara',
      name: 'Kopi Susu Gula Aren',
      description: 'Espresso arabika blend dengan susu segar dan gula aren asli Jawa.',
      price: 18000,
      imageUrl: 'https://images.unsplash.com/photo-1541167760496-1628856ab772?auto=format&fit=crop&w=400&q=80',
      category: 'Kopi',
      isAvailable: true,
    ),
    const MenuItemModel(
      id: 'mnu_kn_002',
      placeId: 'plc_kopi_nusantara',
      name: 'Americano Ice',
      description: 'Double shot espresso dengan es batu segar, pahit menyegarkan.',
      price: 15000,
      imageUrl: 'https://images.unsplash.com/photo-1509042239860-f550ce710b93?auto=format&fit=crop&w=400&q=80',
      category: 'Kopi',
      isAvailable: true,
    ),
    const MenuItemModel(
      id: 'mnu_kn_003',
      placeId: 'plc_kopi_nusantara',
      name: 'Es Teh Manis',
      description: 'Teh melati wangi dengan es batu dan gula asli, segar melepas dahaga.',
      price: 8000,
      imageUrl: 'https://images.unsplash.com/photo-1556679343-c7306c1976bc?auto=format&fit=crop&w=400&q=80',
      category: 'Non-Kopi',
      isAvailable: true,
    ),
    const MenuItemModel(
      id: 'mnu_kn_004',
      placeId: 'plc_kopi_nusantara',
      name: 'Matcha Latte',
      description: 'Matcha premium Jepang dengan steamed milk creamy dan sedikit foam.',
      price: 22000,
      imageUrl: 'https://images.unsplash.com/photo-1515823064-d6e0c04616a7?auto=format&fit=crop&w=400&q=80',
      category: 'Non-Kopi',
      isAvailable: true,
    ),
    const MenuItemModel(
      id: 'mnu_kn_005',
      placeId: 'plc_kopi_nusantara',
      name: 'Roti Bakar Coklat Keju',
      description: 'Roti tawar panggang dengan lelehan coklat dan keju mozarella meleleh.',
      price: 16000,
      imageUrl: 'https://images.unsplash.com/photo-1484723091739-30a097e8f929?auto=format&fit=crop&w=400&q=80',
      category: 'Makanan',
      isAvailable: true,
    ),
    const MenuItemModel(
      id: 'mnu_kn_006',
      placeId: 'plc_kopi_nusantara',
      name: 'Kentang Goreng Crispy',
      description: 'Kentang goreng renyah dengan bumbu gurih dan saus tomat pedas.',
      price: 14000,
      imageUrl: 'https://images.unsplash.com/photo-1573080496219-bb080dd4f877?auto=format&fit=crop&w=400&q=80',
      category: 'Makanan',
      isAvailable: true,
    ),
  ];

  /// Mock Initial Orders (Termasuk 1 pesanan aktif untuk menampilkan badge '1' pada tab Pesanan)
  static final List<OrderModel> orders = [
    OrderModel(
      id: 'ord_dev_101',
      orderNumber: 'NGK-20261029-001',
      userId: 'usr_dev_001',
      placeId: 'plc_budget_1',
      placeName: 'Ruang Temu Coffee',
      placeAddress: 'Setiabudi · 1.2 km',
      placeImageUrl: 'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?auto=format&fit=crop&w=800&q=80',
      items: const [
        OrderItemModel(
          menuItemId: 'mnu_rt_001',
          name: 'Kopi Susu Ruang Temu',
          price: 18000,
          quantity: 1,
          subtotal: 18000,
        ),
      ],
      subtotal: 18000,
      serviceFee: 2000,
      total: 20000,
      paymentMethod: 'cash',
      paymentStatus: 'unpaid',
      status: 'processing',
      diningOption: 'dine_in',
      tableNumber: 'Meja 07',
      hasReviewed: false,
      createdAt: DateTime.now().subtract(const Duration(minutes: 15)),
    ),
  ];
}
