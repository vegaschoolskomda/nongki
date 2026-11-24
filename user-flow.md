USER FLOW --- NONGKI Website
File: user-flow.md
Product: NONGKI
Platform: Website responsif (desktop, tablet, mobile)
Version: 1.0
Status: Draft untuk panduan AI coding agent Antigravity
Dokumen terkait: prd-design.md, prd-alur-nongki.md

1. Tujuan
Dokumen ini menjadi sumber acuan utama untuk membangun alur website
NONGKI. Antigravity harus mengikuti struktur halaman, hubungan navigasi,
hak akses, kondisi keputusan, dan perilaku interaksi di bawah ini.

Website harus terasa seperti satu produk yang konsisten: pengunjung
dapat menemukan tempat nongkrong, pelanggan dapat mengelola pesanan, dan
staf usaha dapat mengakses area operasional sesuai hak aksesnya.

Jangan hanya membuat tampilan statis. Setiap tombol, link, filter,
form, menu navigasi, tab, dan aksi utama harus memiliki perilaku yang
masuk akal. Jika backend belum tersedia, gunakan data mock yang
konsisten dan tandai sebagai data demo; jangan berpura-pura bahwa
pembayaran, pesanan, atau penyimpanan data sungguhan sudah berhasil.
2. Prinsip Produk
1. NONGKI membantu pengguna menemukan tempat nongkrong berdasarkan
   budget, kategori, dan lokasi jika tersedia.
2. Website berfokus pada pencarian tempat, informasi menu, pemesanan,
   dan pengelolaan transaksi sesuai peran.
3. Konsep NONGKI saat ini tidak menggunakan AI. Jangan menambahkan
   chatbot AI, AI recommendation, atau klaim fitur AI.
4. Gunakan Bahasa Indonesia yang santai, jelas, dan konsisten.
5. Harga, biaya, jam operasional, rating, stok, dan status transaksi
   harus berasal dari data yang tersedia.
6. Pengunjung boleh menjelajahi konten publik tanpa login. Aksi yang
   membutuhkan akun harus diarahkan ke login dengan cara yang jelas.
7. Area pelanggan dan area operasional harus dipisahkan.
8. Jangan menampilkan fitur sebagai aktif jika belum dibuat atau belum
   terhubung.
9. Desain harus responsif dan memiliki loading, empty, error, success,
   serta disabled state.
10. Pertahankan identitas visual NONGKI: cokelat tua, cokelat sedang,
    krem hangat, dan putih.
3. Peran Pengguna
3.1 Pengunjung (belum login)
Boleh: - Membuka halaman beranda. - Menjelajahi tempat. - Mencari
berdasarkan nama/kata kunci. - Menggunakan filter publik yang
benar-benar tersedia. - Melihat detail tempat dan menu publik.

Saat mencoba aksi yang membutuhkan akun, arahkan ke login dan kembalikan
ke konteks sebelumnya setelah berhasil jika memungkinkan.
3.2 Pelanggan (sudah login)
Boleh: - Melakukan semua aktivitas pengunjung. - Mengelola favorit. -
Melakukan checkout jika pemesanan tersedia. - Melihat pesanan dan
riwayat transaksi miliknya. - Mengelola profil. - Menulis ulasan jika
memenuhi aturan produk.

Pelanggan tidak boleh membuka halaman operasional usaha.
3.3 Admin usaha
Sesuai konsep NONGKI, admin usaha dapat mengelola: - Data menu dan
stok. - Absensi. - Struk manual jika fitur ini disediakan. - Laporan
keuangan.

Akses admin hanya diberikan oleh sistem yang berwenang. Jangan
menyediakan pilihan "Daftar sebagai Admin" pada pendaftaran publik.
3.4 Kasir
Kasir berfokus pada: - Melihat pesanan yang masuk. - Membuka detail
pesanan. - Memperbarui status sesuai kewenangannya.

Kasir tidak otomatis memiliki akses ke pengaturan admin, absensi, atau
laporan keuangan.
3.5 Pemilik usaha
Jika role pemilik usaha memang diaktifkan, pemilik melihat ringkasan
usaha dan data operasional yang diizinkan. Jika dashboard pemilik belum
termasuk versi awal, jangan membuatnya sebagai role aktif hanya untuk
melengkapi UI.
Catatan: Peran operasional ini adalah acuan awal berdasarkan
konsep NONGKI. Jika sistem autentikasi atau pembagian role final
berbeda, sesuaikan akses berdasarkan keputusan produk---jangan membuat
akses role berdasarkan pilihan bebas dari frontend.

4. Peta Website
4.1 Halaman publik
/
├── /jelajah
├── /tempat/:slug
│   └── /tempat/:slug/menu (atau bagian menu pada halaman detail)
├── /login
├── /daftar
├── /lupa-kata-sandi (jika didukung)
├── /kebijakan-privasi (jika tersedia)
└── /syarat-ketentuan (jika tersedia)
4.2 Area pelanggan
/akun
├── /akun/profil
├── /akun/favorit
├── /akun/pesanan
├── /akun/pesanan/:id
├── /akun/checkout
└── /akun/ulasan/:id (jika didukung)
Rute dapat disesuaikan dengan framework, tetapi fungsi dan proteksi
aksesnya harus tetap setara.
4.3 Area operasional
/dashboard
├── /dashboard/pesanan
├── /dashboard/pesanan/:id
├── /dashboard/menu
├── /dashboard/stok
├── /dashboard/absensi
├── /dashboard/struk-manual
├── /dashboard/laporan
└── /dashboard/pengaturan (jika diizinkan)
Tidak semua role dapat mengakses semua rute. Menu navigasi dan
pemeriksaan akses harus mengikuti role yang telah diverifikasi.
5. Global Navigation
Header website publik
Elemen yang disarankan: - Logo NONGKI yang mengarah ke beranda. - Menu
Beranda. - Menu Jelajah Tempat. - Kolom pencarian atau tombol
untuk membuka pencarian. - Tombol Masuk dan Daftar saat belum
login. - Menu profil atau akun saat sudah login. - Indikator
keranjang/pesanan hanya jika fitur tersebut benar-benar tersedia.
Footer
Tampilkan: - Logo dan deskripsi singkat NONGKI. - Link ke halaman utama
dan jelajah. - Link bantuan, kebijakan privasi, dan syarat ketentuan
jika halaman tersebut tersedia. - Informasi kontak hanya jika datanya
valid. - Copyright.

Jangan membuat link yang menuju # atau halaman kosong. Jika sebuah
halaman belum dibuat, sembunyikan link tersebut atau buat halaman
sederhana yang benar-benar berfungsi.
Navigasi dashboard
Dashboard operasional menggunakan sidebar pada desktop dan drawer/menu
responsif pada layar kecil. Sidebar menampilkan hanya menu yang boleh
diakses oleh role yang sedang login.
6. User Flow Utama --- Pengunjung Menemukan Tempat
Mulai
  ↓
Buka website NONGKI
  ↓
Beranda
  ├─ Ketik nama tempat → Hasil pencarian
  ├─ Pilih kategori → Hasil kategori
  ├─ Isi budget → Hasil sesuai budget
  └─ Pilih kartu tempat → Detail tempat
                         ↓
                  Baca informasi
                         ├─ Lihat menu
                         ├─ Simpan favorit → Perlu login?
                         └─ Pesan → Perlu login/checkout?
Aturan
1. Logo selalu membawa pengguna ke beranda.
2. Kartu tempat dapat diklik untuk membuka detail.
3. Tombol favorit tidak boleh ikut memicu klik kartu tempat.
4. Pencarian berjalan ketika pengguna menekan Enter, memilih tombol
   cari, atau setelah debounce yang wajar.
5. Filter aktif terlihat dan dapat dihapus satu per satu atau melalui
   tombol reset.
6. Jika hasil kosong, tampilkan pesan dan tindakan untuk mengubah kata
   kunci atau filter.
7. Jika lokasi tidak tersedia, jangan membuat jarak palsu. Pencarian
   tetap berjalan tanpa lokasi bila memungkinkan.
7. User Flow --- Beranda dan Pencarian
Beranda
Urutan konten yang disarankan: 1. Hero dengan headline yang jelas,
misalnya "Temukan tempat nongkrong yang cocok buat kamu." 2.
Penjelasan singkat manfaat NONGKI. 3. Kolom pencarian tempat. 4.
Input/pilihan budget. 5. Kategori tempat. 6. Daftar tempat pilihan atau
tempat terbaru jika datanya tersedia. 7. Ajakan menjelajah. 8. Footer.

Hindari hero yang terlalu tinggi hingga pengguna tidak dapat melihat
cara mencari tempat tanpa scroll panjang. Beranda harus mengarahkan
pengguna pada tindakan utama: cari tempat.
Pencarian dan filter
1. Pengguna membuka Jelajah atau menggunakan pencarian dari beranda.
2. Sistem menampilkan kolom pencarian dan daftar tempat.
3. Pengguna memasukkan kata kunci.
4. Pengguna dapat menyaring hasil berdasarkan:
   - Budget/harga.
   - Kategori.
   - Lokasi/jarak jika didukung.
   - Rating jika data rating tersedia.
5. Pengguna memilih urutan hasil yang benar-benar didukung, misalnya
   relevan atau harga terendah.
6. Daftar diperbarui.
7. Pengguna membuka detail tempat.
Kondisi pencarian
- Loading: tampilkan skeleton kartu.
- Hasil tersedia: tampilkan kartu tempat.
- Tidak ada hasil: tampilkan empty state dan tombol reset filter.
- Gagal memuat: tampilkan pesan dan tombol coba lagi.
- Filter tidak berlaku: jangan menampilkan filter itu sebagai
  kontrol aktif.
8. User Flow --- Detail Tempat
Hasil pencarian
  ↓
Detail tempat
  ├─ Informasi tempat
  ├─ Foto
  ├─ Harga/kisaran harga jika tersedia
  ├─ Alamat dan jam buka jika tersedia
  ├─ Rating jika tersedia
  ├─ Menu
  ├─ Simpan favorit
  └─ Pesan / Lihat menu jika pemesanan tersedia
Aturan
- Detail tempat menampilkan data yang tersedia dan terverifikasi.
- Bagian tanpa data tidak boleh diisi angka atau klaim palsu.
- Tombol Lihat Peta hanya muncul jika alamat/lokasi dan link peta
  tersedia.
- Tombol Pesan hanya aktif jika tempat mendukung pemesanan.
- Jika tempat tutup atau tidak menerima pesanan, tampilkan status yang
  valid dan jelaskan aksi yang masih bisa dilakukan.
- Navigasi kembali membawa pengguna ke hasil pencarian sebelumnya jika
  memungkinkan.
9. User Flow --- Login dan Daftar
Daftar
Klik Daftar
  ↓
Form daftar pelanggan
  ↓
Isi data wajib
  ↓
Validasi form
  ├─ Tidak valid → tampilkan error di field terkait
  └─ Valid → kirim pendaftaran
                 ├─ Berhasil → login otomatis atau halaman login
                 └─ Gagal → tampilkan pesan dan coba lagi
Aturan: - Form daftar hanya untuk pelanggan. - Jangan menampilkan role
admin/kasir sebagai pilihan pendaftaran. - Tampilkan label input dan
pesan validasi. - Jangan menghapus seluruh input ketika terjadi error
yang tidak berkaitan. - Jika verifikasi email/nomor belum didukung,
jangan berpura-pura telah mengirim kode verifikasi.
Login
Klik Masuk
  ↓
Isi kredensial
  ↓
Validasi
  ├─ Tidak valid → pesan error
  └─ Valid → autentikasi
              ├─ Pelanggan → halaman sebelumnya atau akun
              ├─ Admin → dashboard admin
              ├─ Kasir → dashboard kasir
              └─ Role tidak diizinkan → tolak akses dan beri pesan
Role ditentukan dari data autentikasi yang tepercaya, bukan dari
parameter URL atau pilihan yang bisa diubah pengguna.
Redirect setelah login
- Jika login dipicu ketika ingin menyimpan favorit, kembalikan
  pengguna ke tempat yang sama dan lanjutkan aksi jika aman.
- Jika login dipicu saat checkout, kembalikan pengguna ke
  keranjang/checkout.
- Jika pengguna membuka halaman operasional tanpa izin, jangan
  tampilkan dashboard; tampilkan halaman akses ditolak atau arahkan ke
  area yang sesuai.
10. User Flow --- Favorit
1. Pengguna menekan ikon favorit di kartu atau halaman detail.
2. Jika belum login, arahkan ke login.
3. Setelah login, lanjutkan ke konteks sebelumnya jika memungkinkan.
4. Jika sudah login, simpan/hapus favorit.
5. Berikan feedback berhasil atau gagal.
6. Halaman Favorit menampilkan daftar yang tersimpan.
7. Pengguna dapat membuka detail atau menghapus favorit.
8. Jika tidak ada favorit, tampilkan empty state dengan tombol
   Jelajahi Tempat.
Jangan hanya mengubah ikon secara visual tanpa memperbarui state
aplikasi atau data yang digunakan.
11. User Flow --- Pesanan dan Checkout
Checkout hanya boleh diaktifkan jika fitur pemesanan memang menjadi
bagian versi website yang dibangun.

Detail tempat
  ↓
Lihat menu
  ↓
Pilih item dan jumlah
  ↓
Keranjang
  ↓
Periksa item, subtotal, dan biaya
  ↓
Login jika diwajibkan
  ↓
Validasi harga dan stok
  ↓
Pilih metode pembayaran yang didukung
  ↓
Konfirmasi
  ├─ Berhasil → detail pesanan
  ├─ Menunggu pembayaran → instruksi/status menunggu
  └─ Gagal → pesan gagal dan opsi yang valid
Aturan checkout
- Harga dan ketersediaan divalidasi ulang sebelum pesanan dibuat.
- Perubahan harga atau stok harus diberitahukan sebelum pengguna
  mengonfirmasi.
- Total dan biaya tambahan ditampilkan sebelum konfirmasi.
- Klik ganda pada tombol konfirmasi tidak boleh membuat transaksi
  ganda.
- Jangan menampilkan status "Berhasil" sebelum mendapat konfirmasi
  dari sistem.
- Jangan menampilkan metode pembayaran yang belum tersedia.
- Jika pembayaran online belum terintegrasi, jangan membuat halaman
  pembayaran palsu yang mengklaim transaksi nyata.
- Jika checkout masih berupa demo, tampilkan label demo dan gunakan
  data simulasi yang jelas.
- Aturan apakah satu keranjang hanya boleh berisi satu tempat harus
  konsisten.
Halaman detail pesanan
Tampilkan: - Nomor pesanan. - Tempat dan daftar item. - Jumlah dan harga
pada saat transaksi. - Total dan metode pembayaran. - Status pembayaran
dan status pesanan. - Waktu transaksi. - Langkah berikutnya sesuai
status.
12. User Flow --- Area Pelanggan
Setelah login, pelanggan dapat membuka area akun melalui menu profil.
Profil
- Lihat data akun.
- Edit data yang diizinkan.
- Buka Favorit.
- Buka Pesanan/Riwayat.
- Logout.
Pesanan dan riwayat
1. Pelanggan membuka Pesanan.
2. Sistem menampilkan pesanan milik pelanggan tersebut.
3. Pelanggan memilih pesanan untuk melihat detail.
4. Jika transaksi memenuhi syarat dan belum diulas, tampilkan opsi
   Tulis Ulasan.
5. Jika belum ada transaksi, tampilkan empty state.
6. Pelanggan tidak boleh membuka transaksi milik pengguna lain dengan
   mengganti ID pada URL.
Ulasan
1. Pelanggan memilih Tulis Ulasan pada transaksi yang memenuhi syarat.
2. Pelanggan memberikan rating dan isi ulasan.
3. Sistem memvalidasi input.
4. Setelah berhasil disimpan, tampilkan konfirmasi.
5. Jika gagal, tampilkan error dan pertahankan isi yang aman.
13. User Flow --- Dashboard Admin Usaha
Dashboard ini hanya dibuat jika memang masuk ruang lingkup implementasi
website.
Login dan akses
Login
  ↓
Sistem memverifikasi sesi dan role
  ├─ Admin usaha → Dashboard Admin
  ├─ Kasir → Dashboard Kasir
  └─ Role lain → akses ditolak atau diarahkan ke area pelanggan
Dashboard admin
Menu yang disarankan berdasarkan konsep saat ini: - Ringkasan usaha. -
Menu dan stok. - Absensi. - Struk manual. - Laporan keuangan.
Alur kelola menu dan stok
1. Admin membuka Menu/Stok.
2. Sistem menampilkan daftar data.
3. Admin memilih tambah, edit, atau ubah stok.
4. Sistem memvalidasi kolom dan nilai.
5. Admin menyimpan.
6. Sistem memperbarui data dan menampilkan feedback.
7. Jika gagal, perubahan tidak boleh dianggap tersimpan.
Alur laporan
1. Admin membuka Laporan.
2. Admin memilih rentang tanggal jika filter periode tersedia.
3. Sistem menampilkan data yang sesuai.
4. Jika tidak ada data, tampilkan empty state.
5. Jika gagal memuat, tampilkan error dan aksi coba lagi.
Jangan menampilkan angka pendapatan, stok, atau jumlah transaksi yang
tampak seperti data produksi jika hanya memakai data mock. Beri label
Data Demo pada dashboard prototipe.
14. User Flow --- Dashboard Kasir
Kasir hanya melihat fitur yang diperlukan untuk menangani pesanan.
Login sebagai kasir
  ↓
Dashboard Kasir
  ↓
Daftar pesanan masuk
  ↓
Pilih pesanan
  ↓
Periksa detail pesanan
  ↓
Perbarui status sesuai kewenangan
  ↓
Sistem menyimpan perubahan
  ↓
Status terbaru terlihat di daftar dan detail
Aturan: - Kasir tidak otomatis mendapat akses ke laporan keuangan,
absensi, atau pengaturan admin. - Aksi perubahan status harus sesuai
status sebelumnya dan aturan sistem. - Jika perubahan gagal, tampilkan
pesan dan pertahankan status terakhir yang benar. - Pesanan yang sudah
selesai atau dibatalkan tidak boleh diubah sembarangan. - Jika pembaruan
real-time belum tersedia, sediakan tombol refresh atau mekanisme
pemuatan ulang yang jelas.
15. Proteksi Rute dan Hak Akses
Antigravity wajib menerapkan proteksi akses pada sisi aplikasi dan
server/backend bila tersedia.
- Pengunjung hanya dapat membuka halaman publik.
- Pelanggan hanya dapat membuka data akun dan transaksi miliknya
  sendiri.
- Kasir hanya dapat membuka fitur operasional yang diizinkan.
- Admin usaha dapat mengakses fitur admin yang diizinkan.
- Jangan mengandalkan menyembunyikan tombol sebagai satu-satunya
  proteksi.
- Jika pengguna tidak login, arahkan ke login.
- Jika pengguna login tetapi tidak memiliki izin, tampilkan halaman
  akses ditolak atau redirect aman.
- Jangan menentukan role hanya berdasarkan path, query string, atau
  state frontend.
- Jangan mengekspos secret atau kredensial server di frontend.
16. Responsive Flow dan Perilaku Layout
Desktop
- Header publik horizontal.
- Konten utama menggunakan lebar maksimum yang nyaman dibaca.
- Hasil jelajah dapat memakai grid kartu beberapa kolom.
- Filter dapat berada di sidebar atau panel horizontal.
- Dashboard menggunakan sidebar dan area konten utama.
Tablet
- Grid kartu menyesuaikan lebar layar.
- Filter dapat berubah menjadi panel collapsible.
- Sidebar dashboard dapat dipersempit atau menjadi drawer.
Mobile web
- Header ringkas dengan menu drawer jika diperlukan.
- Kartu tempat satu kolom atau dua kolom sesuai lebar.
- Filter dibuka melalui tombol Filter dan tampil sebagai
  drawer/modal yang dapat ditutup.
- Form dan tombol utama memenuhi lebar yang sesuai.
- Dashboard menggunakan navigasi drawer atau menu responsif.
- Tidak boleh ada scroll horizontal yang tidak disengaja.
Perubahan ukuran layar tidak boleh menghilangkan fungsi penting atau
mengubah hak akses pengguna.
17. State Wajib pada Setiap Halaman
Antigravity perlu mempertimbangkan state berikut sesuai kebutuhan
halaman:
- Loading: data sedang diambil.
- Success: data berhasil dimuat atau aksi berhasil.
- Empty: belum ada data.
- Error: data gagal dimuat atau aksi gagal.
- Disabled: aksi tidak dapat dilakukan.
- Unauthorized: sesi tidak ada atau sudah kedaluwarsa.
- Forbidden: pengguna tidak memiliki izin.
- Offline/network error: koneksi bermasalah, jika dapat dideteksi.
Setiap state harus punya tampilan yang jelas. Jangan meninggalkan
halaman kosong atau spinner tanpa akhir.
18. Aturan Interaksi untuk Antigravity
1. Semua link dan tombol harus mengarah ke halaman atau menjalankan
   aksi yang benar.
2. Jangan gunakan href="#" untuk menggantikan fungsi yang belum
   dibuat.
3. Form harus memiliki validasi, pesan sukses/gagal, dan status
   loading.
4. Tombol submit harus mencegah pengiriman berulang selama proses
   berlangsung.
5. Filter, pencarian, sort, pagination, dan reset harus bekerja jika
   ditampilkan.
6. Tombol favorit harus memperbarui state secara konsisten.
7. Menu navigasi aktif harus menunjukkan halaman yang sedang dibuka.
8. Tombol kembali harus membawa pengguna ke konteks yang wajar.
9. Dialog harus dapat ditutup dengan tombol batal dan tidak menghilang
   sebelum aksi penting dikonfirmasi.
10. Gunakan komponen UI yang dapat dipakai ulang.
11. Gunakan satu sumber data/state yang konsisten untuk kartu, detail,
    keranjang, dan transaksi.
12. Jangan membuat data dummy berbeda untuk daftar dan detail sehingga
    informasinya bertentangan.
13. Jika backend belum ada, buat mock service atau data fixture yang
    terpusat, bukan data palsu tersebar di banyak komponen.
14. Tandai alur simulasi sebagai demo dan jangan menyatakan transaksi
    sungguhan berhasil.
15. Jangan menambahkan fitur AI.
16. Jangan membuat pendaftaran role admin/kasir untuk publik.
17. Jangan menampilkan menu Simulasi Peran.
18. Pertahankan palet warna, tipografi, dan komponen dari
    prd-design.md.
19. Prioritas Implementasi
P0 --- Harus berfungsi untuk prototipe awal
- Navigasi publik.
- Beranda.
- Pencarian dan filter dasar.
- Daftar tempat.
- Detail tempat.
- Login dan daftar pelanggan.
- Responsive layout.
- Loading, empty, dan error state.
P1 --- Alur pelanggan
- Favorit.
- Menu dan keranjang.
- Checkout sesuai kemampuan yang benar-benar tersedia.
- Riwayat dan detail transaksi.
- Profil dan logout.
P2 --- Operasional usaha (jika termasuk scope)
- Dashboard admin.
- Pengelolaan menu/stok.
- Dashboard kasir.
- Perubahan status pesanan.
- Absensi, struk manual, dan laporan sesuai hak akses.
P3 --- Penyempurnaan
- Aksesibilitas.
- Optimasi gambar dan performa.
- Pengujian responsif lintas ukuran layar.
- Pengujian seluruh state dan proteksi rute.
20. Checklist Pengujian User Flow
Pengunjung
- [ ] Logo mengarah ke beranda.
- [ ] Pencarian membuka hasil yang sesuai.
- [ ] Filter dapat diterapkan dan dihapus.
- [ ] Kartu tempat membuka detail yang cocok.
- [ ] Empty state muncul ketika tidak ada hasil.
Autentikasi
- [ ] Daftar membuat akun pelanggan, bukan admin/kasir.
- [ ] Login berhasil mengarahkan pengguna ke area sesuai role.
- [ ] Error login ditampilkan dengan benar.
- [ ] Logout mengakhiri sesi.
- [ ] Halaman yang membutuhkan login tidak dapat diakses tanpa sesi.
Pelanggan
- [ ] Favorit memerlukan login bila kebijakan menetapkannya.
- [ ] Pelanggan hanya dapat melihat transaksi sendiri.
- [ ] Keranjang menghitung total dengan benar.
- [ ] Checkout tidak membuat transaksi ganda.
- [ ] Status transaksi sesuai hasil sistem.
- [ ] Ulasan hanya dapat dikirim sesuai aturan.
Dashboard
- [ ] Admin dan kasir melihat navigasi berbeda sesuai izin.
- [ ] Kasir tidak dapat membuka fitur khusus admin.
- [ ] Data demo diberi label.
- [ ] Perubahan menu/stok/status memiliki feedback berhasil atau
  gagal.
Responsif dan kualitas
- [ ] Website dapat digunakan pada desktop, tablet, dan mobile.
- [ ] Tidak ada tombol utama yang inert.
- [ ] Tidak ada link ke halaman kosong atau #.
- [ ] Loading, empty, error, dan forbidden state tersedia.
- [ ] Tidak ada klaim fitur AI.
- [ ] Tidak ada data transaksi atau pembayaran demo yang diklaim
  sebagai transaksi nyata.
21. Instruksi Final untuk AI Antigravity
Gunakan dokumen ini bersama prd-design.md dan prd-alur-nongki.md
sebagai sumber acuan. Sebelum mengubah kode:
1. Periksa struktur repository dan teknologi yang sudah digunakan.
2. Jangan mengganti framework atau merombak struktur proyek tanpa
   alasan kuat.
3. Petakan halaman dan komponen yang sudah ada.
4. Implementasikan user flow secara bertahap, mulai dari P0.
5. Pastikan setiap rute, tombol, form, filter, dan navigasi benar-benar
   berfungsi.
6. Jika backend belum tersedia, buat mock data/service yang terpusat
   dan tandai alur demo.
7. Jangan mengklaim integrasi autentikasi, database, peta, notifikasi,
   atau pembayaran sudah berfungsi kecuali benar-benar terhubung dan
   diuji.
8. Setelah implementasi, jalankan lint/build/test yang tersedia dan
   perbaiki error yang muncul.
9. Laporkan halaman yang selesai, alur yang sudah diuji, dan integrasi
   yang masih memerlukan backend.
10. Jika keputusan produk belum final, pilih implementasi paling
    sederhana yang aman dan catat asumsi tersebut---jangan menciptakan
    fitur baru.
Hasil yang diharapkan: website NONGKI yang memiliki alur jelas,
navigasi konsisten, responsif, dan interaktif, bukan sekadar kumpulan
halaman dengan tampilan menarik.