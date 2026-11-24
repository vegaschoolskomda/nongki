PRD Alur --- NONGKI Mobile App
Nama file: prd-alur-nongki.md
Produk: NONGKI
Platform: Aplikasi mobile Android (prioritas awal)
Versi: 1.0
Status: Draft awal untuk acuan implementasi
Dokumen pendamping: prd-design.md

1. Tujuan Dokumen
Dokumen ini menjelaskan alur pengguna, perpindahan layar, kondisi
keputusan, validasi, dan respons sistem pada aplikasi mobile NONGKI.
Dokumen ini menjadi acuan implementasi agar alur aplikasi tidak dibuat
berdasarkan asumsi yang berbeda-beda.

Dokumen ini melengkapi prd-design.md: - prd-design.md menjelaskan
bagaimana tampilan dan komponen UI dirancang. - prd-alur-nongki.md
menjelaskan bagaimana pengguna bergerak dari satu langkah ke langkah
berikutnya dan apa yang dilakukan sistem.
2. Ringkasan Produk
NONGKI membantu pengguna menemukan tempat nongkrong berdasarkan
kebutuhan, termasuk budget dan lokasi jika tersedia, melihat detail
tempat dan menu, membuat pesanan, memilih metode pembayaran yang
didukung, serta melihat riwayat transaksi dan menulis ulasan.

Prinsip produk: 1. Pengguna dapat menjelajahi informasi tempat tanpa
harus langsung memesan. 2. Informasi harga dan biaya harus transparan
sebelum konfirmasi. 3. Sistem harus memberikan feedback untuk setiap
aksi penting. 4. Data tempat, menu, stok, harga, status pesanan, dan
pembayaran harus mengikuti data aktual. 5. Versi konsep saat ini tidak
menggunakan AI. 6. Fitur dan metode pembayaran yang belum didukung
tidak boleh ditampilkan sebagai fitur aktif.
3. Ruang Lingkup
3.1 Termasuk dalam aplikasi pelanggan
- Splash screen dan onboarding.
- Daftar akun, login, dan pemulihan kata sandi jika didukung.
- Beranda.
- Pencarian dan jelajah tempat.
- Filter budget, kategori, dan lokasi jika datanya tersedia.
- Detail tempat.
- Daftar menu dan pemilihan jumlah.
- Keranjang.
- Pemilihan metode pembayaran yang benar-benar tersedia.
- Status pesanan dan ringkasan transaksi.
- Riwayat transaksi.
- Ulasan.
- Favorit.
- Profil dan logout.
3.2 Di luar cakupan utama dokumen ini
- Dashboard operasional pemilik usaha/admin.
- Pengelolaan stok dan menu dari sisi pemilik.
- Pengelolaan absensi dan laporan keuangan.
- Implementasi teknis backend, database, API, dan payment gateway.
- Sistem rekomendasi AI.
Peran operasional yang telah dibahas: kasir menangani pesanan, sedangkan
admin mengelola stok, absensi, struk manual, dan laporan keuangan. Jika
dashboard operasional dibangun, buat PRD alur terpisah untuk dashboard
tersebut.
4. Peran dan Hak Akses
4.1 Pengunjung (belum login)
Pengunjung dapat: - Melihat onboarding. - Menjelajahi tempat dan
detailnya jika informasi publik tersedia. - Mencari tempat dan
menggunakan filter publik yang tersedia. - Melihat menu jika menu
bersifat publik.

Pengunjung perlu login untuk aksi yang memerlukan akun, misalnya: -
Menyimpan favorit ke akun. - Membuat pesanan jika produk menetapkan
login wajib. - Melihat riwayat transaksi. - Mengirim ulasan. - Mengubah
profil.

Jika pengguna mencoba aksi yang membutuhkan login, arahkan ke halaman
login. Setelah login berhasil, kembalikan pengguna ke konteks sebelumnya
jika aman dan memungkinkan.
4.2 Pengguna terdaftar
Pengguna terdaftar dapat memakai fitur publik dan fitur akun yang
tersedia. Pengguna hanya boleh melihat transaksi dan data profil
miliknya sendiri.
4.3 Pemilik usaha, admin, dan kasir
Akses operasional tidak termasuk alur aplikasi pelanggan ini. Jangan
memberikan akses operasional melalui menu profil pelanggan atau
menampilkan menu "Simulasi Peran".
5. Peta Navigasi Utama
Navigasi bawah aplikasi pelanggan:
- Beranda: pencarian, budget, kategori, dan tempat pilihan.
- Jelajah: hasil pencarian, daftar tempat, dan filter.
- Pesanan: pesanan aktif atau daftar pesanan sesuai keputusan
  implementasi.
- Favorit: tempat yang disimpan.
- Profil: informasi akun, riwayat transaksi, pengaturan yang
  tersedia, dan logout.
Layar autentikasi dan proses checkout dapat menggunakan navigasi khusus
agar pengguna fokus menyelesaikan tugasnya.
5.1 Peta hubungan layar
Splash
  └─ Onboarding (pengguna baru / belum selesai)
       ├─ Lewati / Mulai
       └─ Login atau Beranda sesuai status sesi

Beranda
  ├─ Pencarian / Jelajah
  │    ├─ Filter dan budget
  │    └─ Hasil → Detail Tempat
  ├─ Tempat pilihan → Detail Tempat
  └─ Navigasi bawah

Detail Tempat
  ├─ Favorit (login bila diwajibkan)
  ├─ Lihat Menu
  │    └─ Menu → Keranjang
  └─ Peta / arah (jika tersedia)

Keranjang
  ├─ Ubah jumlah / hapus item
  ├─ Keranjang kosong → kembali ke menu
  └─ Lanjut → Konfirmasi Pesanan / Pembayaran

Checkout
  ├─ Periksa ringkasan dan biaya
  ├─ Pilih metode pembayaran yang tersedia
  └─ Konfirmasi
       ├─ Berhasil / pesanan diterima
       ├─ Menunggu pembayaran
       └─ Gagal / dibatalkan

Pesanan / Riwayat
  ├─ Detail transaksi
  └─ Tulis ulasan (jika memenuhi syarat)

Favorit
  └─ Detail Tempat

Profil
  ├─ Edit Profil
  ├─ Riwayat Transaksi
  ├─ Pengaturan (jika tersedia)
  └─ Logout
6. Alur Pertama Kali Membuka Aplikasi
6.1 Splash dan onboarding
1. Pengguna membuka aplikasi.
2. Sistem menampilkan splash screen.
3. Sistem memeriksa status sesi secara aman.
4. Jika onboarding belum pernah diselesaikan, tampilkan onboarding.
5. Pengguna dapat memilih Lanjut, Lewati jika disediakan, atau
   Mulai pada halaman terakhir.
6. Setelah onboarding, sistem mengarahkan pengguna ke beranda atau
   halaman autentikasi sesuai keputusan produk dan status sesi.
7. Jika sesi pengguna masih valid, pengguna dapat langsung masuk ke
   area aplikasi.
Kondisi khusus: - Jika pemeriksaan sesi gagal karena koneksi, jangan
menganggap pengguna berhasil login. Tampilkan aplikasi sesuai kebijakan
offline yang tersedia atau pesan untuk mencoba kembali. - Onboarding
tidak boleh muncul terus-menerus setelah selesai kecuali pengguna
menghapus data aplikasi atau produk memang mengatur demikian. - Splash
tidak boleh menahan pengguna terlalu lama.
7. Alur Daftar Akun
7.1 Alur normal
1. Pengguna memilih Buat Akun/Daftar dari halaman login.
2. Sistem menampilkan formulir pendaftaran.
3. Pengguna mengisi nama, email atau nomor telepon sesuai metode
   autentikasi, dan kata sandi.
4. Pengguna menyetujui syarat dan kebijakan privasi jika dokumennya
   tersedia dan persetujuan diwajibkan.
5. Pengguna menekan Buat Akun.
6. Sistem memvalidasi kolom wajib dan format input.
7. Jika valid, sistem mengirim permintaan pendaftaran.
8. Jika verifikasi email/nomor telepon diwajibkan, sistem meminta
   pengguna menyelesaikan verifikasi.
9. Setelah pendaftaran berhasil, sistem membuat akun pelanggan biasa.
10. Sistem mengarahkan pengguna ke beranda atau login sesuai mekanisme
    autentikasi.
7.2 Validasi dan kondisi gagal
- Kolom wajib kosong → tampilkan pesan pada kolom terkait.
- Format email/nomor tidak valid → jelaskan format yang benar.
- Kata sandi tidak memenuhi ketentuan → tampilkan aturan kata sandi.
- Konfirmasi kata sandi berbeda jika digunakan → minta pengguna
  memeriksa kembali.
- Email/nomor sudah terdaftar → tampilkan pesan dan tautan untuk login
  atau pemulihan akun.
- Koneksi gagal → pertahankan input yang aman dan sediakan aksi coba
  lagi.
- Pendaftaran gagal di server → tampilkan pesan umum yang tidak
  membocorkan detail teknis.
Aturan akses: pendaftaran mandiri hanya membuat akun pelanggan.
Jangan menyediakan pilihan untuk mendaftar sebagai admin, pemilik usaha,
atau kasir melalui formulir pelanggan.
8. Alur Login dan Logout
8.1 Login
1. Pengguna membuka halaman login.
2. Pengguna mengisi email/nomor telepon dan kata sandi.
3. Pengguna menekan Masuk ke Akun.
4. Sistem memvalidasi input.
5. Sistem memeriksa kredensial.
6. Jika benar, sistem membuat atau memulihkan sesi pengguna.
7. Sistem mengarahkan pengguna ke tujuan sebelumnya jika ada, atau ke
   beranda.
8. Jika salah, sistem menampilkan pesan yang mudah dipahami dan tetap
   berada di halaman login.
8.2 Lupa kata sandi
1. Pengguna memilih Lupa kata sandi?.
2. Sistem meminta email/nomor yang terdaftar sesuai mekanisme pemulihan
   yang dipilih.
3. Sistem mengirim instruksi pemulihan melalui kanal yang didukung.
4. Pengguna mengikuti instruksi.
5. Setelah proses berhasil, pengguna dapat login dengan kata sandi
   baru.
Jika pemulihan kata sandi belum diimplementasikan, jangan menampilkan
tautan yang tampak aktif.
8.3 Logout
1. Pengguna membuka Profil.
2. Pengguna memilih Keluar.
3. Sistem menampilkan dialog konfirmasi.
4. Jika pengguna membatalkan, tetap berada di profil.
5. Jika pengguna mengonfirmasi, sistem mengakhiri sesi dan membersihkan
   data sesi lokal yang relevan.
6. Sistem mengarahkan pengguna ke halaman publik atau login.
Jangan menghapus riwayat transaksi yang tersimpan di server ketika
pengguna logout.
9. Alur Mencari Tempat Sesuai Budget
1. Pengguna membuka Beranda atau Jelajah.
2. Pengguna dapat mengetik nama tempat atau kata kunci pada kolom
   pencarian.
3. Pengguna dapat memasukkan atau memilih rentang budget.
4. Pengguna dapat memilih kategori atau filter lain yang tersedia.
5. Jika menggunakan lokasi, sistem meminta izin lokasi dengan
   penjelasan yang sesuai.
6. Jika izin diberikan dan layanan tersedia, sistem menggunakan lokasi
   untuk menghitung hasil yang relevan.
7. Jika izin ditolak, pengguna tetap dapat mencari berdasarkan kata
   kunci atau memilih lokasi secara manual jika fitur tersebut
   tersedia.
8. Sistem menampilkan hasil yang sesuai dengan filter dan data yang
   tersedia.
9. Pengguna memilih kartu tempat untuk membuka Detail Tempat.
10. Pengguna dapat mengubah atau menghapus filter untuk memperluas
    hasil.
9.1 Aturan pencarian
- Budget harus diperlakukan sebagai rentang atau batas yang jelas,
  bukan sekadar label dekoratif.
- Jika tidak ada hasil, tampilkan empty state dan sarankan pengguna
  mengubah budget, kategori, atau lokasi.
- Jangan mengklaim tempat "terdekat" jika data jarak/lokasi tidak
  tersedia.
- Jangan menampilkan rating, kisaran harga, jam buka, atau promosi
  yang tidak memiliki data valid.
- Hasil pencarian harus memiliki loading dan error state.
- Pencarian kosong tidak boleh menyebabkan aplikasi crash atau
  menampilkan hasil palsu.
9.2 Alur izin lokasi
Pengguna memilih fitur berbasis lokasi
  └─ Sistem menjelaskan kebutuhan lokasi
       ├─ Izin diberikan → tampilkan hasil berbasis lokasi
       └─ Izin ditolak
            ├─ Lokasi manual tersedia → pengguna memilih lokasi
            └─ Lokasi manual tidak tersedia → lanjutkan pencarian nonlokasi
10. Alur Detail Tempat dan Favorit
10.1 Detail tempat
1. Pengguna memilih tempat dari hasil pencarian, kategori, atau
   favorit.
2. Sistem membuka halaman Detail Tempat.
3. Sistem menampilkan informasi yang tersedia: foto, nama, kategori,
   alamat, jam operasional, deskripsi, fasilitas, kisaran harga,
   rating, dan menu.
4. Pengguna membaca detail.
5. Pengguna memilih Lihat Menu jika ingin memesan.
6. Pengguna memilih tombol peta/arah jika integrasi lokasi tersedia.
7. Pengguna dapat kembali ke hasil sebelumnya tanpa kehilangan konteks
   pencarian jika memungkinkan.
10.2 Menambah atau menghapus favorit
1. Pengguna menekan ikon favorit.
2. Jika login diwajibkan dan pengguna belum login, sistem mengarahkan
   ke login.
3. Setelah login, sistem melanjutkan aksi favorit jika aman dan
   memungkinkan.
4. Sistem menyimpan atau menghapus tempat dari daftar favorit.
5. Ikon diperbarui untuk menunjukkan status terbaru.
6. Jika penyimpanan gagal, sistem menampilkan pesan dan mengembalikan
   status UI agar tidak seolah-olah tersimpan.
11. Alur Memilih Menu dan Mengisi Keranjang
11.1 Memilih menu
1. Pengguna membuka menu dari Detail Tempat.
2. Sistem menampilkan kategori dan item menu yang tersedia.
3. Pengguna memilih item.
4. Pengguna menekan tombol tambah atau mengubah jumlah.
5. Sistem memperbarui jumlah item dan subtotal.
6. Pengguna dapat memilih item lain.
7. Pengguna menekan Lihat Keranjang untuk memeriksa pesanan.
11.2 Aturan keranjang
- Setiap item memiliki harga dan status ketersediaan.
- Item yang tidak tersedia tidak dapat ditambahkan.
- Jumlah item tidak boleh kurang dari nol.
- Jika jumlah menjadi nol, item dihapus dari keranjang atau ditangani
  dengan perilaku yang konsisten.
- Subtotal harus dihitung dari harga aktual dan jumlah item.
- Jika satu keranjang hanya boleh berisi menu dari satu tempat,
  pengguna harus diberi peringatan yang jelas ketika mencoba
  menambahkan item dari tempat berbeda.
- Harga dan ketersediaan perlu divalidasi ulang sebelum checkout.
- Jika harga atau stok berubah, beri tahu pengguna sebelum pesanan
  dikonfirmasi.
11.3 Melihat dan mengubah keranjang
1. Pengguna membuka Keranjang.
2. Sistem menampilkan tempat, daftar item, jumlah, harga satuan,
   subtotal, biaya tambahan yang berlaku, dan total.
3. Pengguna dapat mengubah jumlah atau menghapus item.
4. Sistem memperbarui perhitungan.
5. Jika keranjang kosong, sistem menampilkan empty state dan tombol
   kembali ke menu.
6. Jika sudah sesuai, pengguna menekan Lanjut ke Pembayaran atau
   tombol checkout yang ditetapkan.
12. Alur Checkout dan Pembayaran
Detail metode pembayaran harus mengikuti integrasi yang benar-benar
tersedia. Jangan mengaktifkan metode hanya karena metode tersebut
muncul pada referensi desain.

12.1 Pemeriksaan sebelum checkout
1. Pengguna memilih lanjut dari Keranjang.
2. Sistem memeriksa apakah pengguna sudah login jika login diwajibkan
   untuk transaksi.
3. Sistem memeriksa item, harga, ketersediaan, dan ketentuan pemesanan.
4. Jika ada perubahan, sistem menampilkan perubahan dan meminta
   pengguna meninjau ulang.
5. Jika data valid, sistem menampilkan ringkasan checkout.
12.2 Konfirmasi pesanan
1. Pengguna meninjau daftar item.
2. Sistem menampilkan subtotal dan setiap biaya tambahan yang berlaku.
3. Sistem menampilkan total akhir sebelum pengguna mengonfirmasi.
4. Pengguna memilih metode pembayaran yang tersedia.
5. Sistem menampilkan instruksi metode tersebut.
6. Pengguna menekan tombol konfirmasi atau Bayar Sekarang.
7. Sistem mengirim permintaan checkout secara aman dan mencegah pesanan
   ganda akibat tombol ditekan berkali-kali.
12.3 Hasil checkout
Sistem mengarahkan pengguna sesuai hasil aktual:

A. Berhasil / pesanan diterima - Tampilkan nomor pesanan dan
ringkasan transaksi. - Tampilkan status sesuai konfirmasi server. -
Berikan akses ke detail pesanan.

B. Menunggu pembayaran - Tampilkan instruksi pembayaran dan batas
waktu jika memang ditentukan oleh sistem. - Status tetap menunggu hingga
ada konfirmasi yang valid. - Sediakan cara memeriksa status terbaru.

C. Gagal - Tampilkan pesan yang mudah dipahami. - Jangan menampilkan
transaksi sebagai berhasil. - Jika aman, biarkan pengguna mencoba
kembali tanpa membuat transaksi ganda.

D. Dibatalkan - Tampilkan status dibatalkan jika pembatalan memang
tercatat. - Jelaskan langkah berikutnya jika ada.
12.4 Aturan pembayaran penting
- Status pembayaran harus bersumber dari hasil sistem atau penyedia
  pembayaran yang terverifikasi.
- Jangan menyimpan data kartu sensitif secara langsung di aplikasi.
- Jangan menganggap pengguna telah membayar hanya karena kembali dari
  halaman penyedia pembayaran.
- Tampilkan biaya sebelum konfirmasi.
- Metode pembayaran tunai, transfer, kartu, dompet digital, atau
  metode lain hanya ditampilkan jika didukung.
- Jika versi awal hanya mendukung pembayaran di kasir atau tunai,
  sederhanakan layar sesuai kemampuan itu.
13. Alur Status Pesanan
Status final harus disepakati bersama implementasi backend dan proses
operasional tempat. Contoh alur awal:
Checkout dikirim
  └─ Menunggu konfirmasi sistem/tempat
       ├─ Diterima / diproses
       │    └─ Selesai
       ├─ Menunggu pembayaran (jika berlaku)
       │    ├─ Pembayaran terkonfirmasi → status berikutnya
       │    └─ Kedaluwarsa / gagal
       └─ Ditolak / dibatalkan
Ketentuan: - Jangan menampilkan status "Diproses" jika pesanan belum
diterima. - Jangan menampilkan status "Selesai" sebelum ada
konfirmasi. - Perubahan status harus konsisten di halaman Pesanan,
Detail Transaksi, dan Riwayat. - Jika pembaruan status tidak dapat
dimuat, tampilkan status terakhir yang diketahui dengan keterangan bahwa
pembaruan gagal, jika data lokal tersedia. - Aturan pembatalan dan
pengembalian dana harus ditentukan dalam kebijakan produk sebelum
diimplementasikan.
14. Alur Riwayat dan Detail Transaksi
1. Pengguna membuka tab Pesanan atau menu Riwayat Transaksi di Profil.
2. Sistem mengambil transaksi milik pengguna yang sedang login.
3. Sistem menampilkan daftar transaksi dengan nama tempat, tanggal,
   total, dan status.
4. Pengguna memilih salah satu transaksi.
5. Sistem menampilkan Detail Transaksi.
6. Jika transaksi memenuhi syarat dan belum diulas, tampilkan tombol
   Tulis Ulasan.
7. Jika tidak ada transaksi, tampilkan empty state dan tombol untuk
   kembali mencari tempat.
8. Jika data gagal dimuat, tampilkan error state dan aksi coba lagi.
Privasi: pengguna hanya boleh mengakses transaksi miliknya sendiri.
15. Alur Menulis Ulasan
1. Pengguna membuka Detail Transaksi atau Detail Tempat.
2. Sistem memeriksa apakah pengguna login dan apakah transaksi memenuhi
   syarat ulasan.
3. Jika tidak memenuhi syarat, tombol ulasan tidak ditampilkan atau
   diberi penjelasan yang tepat.
4. Jika memenuhi syarat, pengguna memilih rating bintang.
5. Pengguna menulis ulasan.
6. Pengguna menambahkan foto secara opsional jika fitur tersedia.
7. Pengguna menekan Kirim Ulasan.
8. Sistem memvalidasi rating dan isi ulasan sesuai aturan produk.
9. Jika berhasil, sistem menyimpan ulasan dan menampilkan konfirmasi.
10. Jika gagal, sistem memberi pesan dan mempertahankan input yang aman
    agar pengguna tidak harus menulis ulang.
Ketentuan: - Rating harus berada dalam rentang yang ditetapkan, misalnya
1--5 bintang. - Batas panjang teks dan format foto harus ditentukan
sebelum implementasi. - Hindari ulasan ganda untuk transaksi yang sama
jika kebijakan produk menetapkan satu ulasan per transaksi. - Jangan
menampilkan rating baru sebagai rating publik sebelum data tersimpan
berhasil.
16. Alur Favorit
1. Pengguna membuka tab Favorit.
2. Sistem memuat daftar tempat yang disimpan pada akun.
3. Pengguna memilih tempat untuk membuka detailnya.
4. Pengguna dapat menghapus tempat dari favorit.
5. Sistem memperbarui daftar.
6. Jika daftar kosong, tampilkan pesan dan tombol ke Jelajah.
7. Jika pemuatan gagal, tampilkan error state dan tombol coba lagi.
17. Alur Profil
1. Pengguna membuka tab Profil.
2. Sistem menampilkan data akun milik pengguna.
3. Pengguna dapat memilih Edit Profil jika fitur tersedia.
4. Pengguna dapat membuka Riwayat Transaksi atau Favorit.
5. Pengguna dapat membuka Pengaturan jika tersedia.
6. Pengguna dapat memilih Logout dan mengonfirmasi tindakan tersebut.
17.1 Edit profil
- Tampilkan data saat ini.
- Pengguna mengubah kolom yang diperbolehkan.
- Sistem memvalidasi input.
- Jika berhasil, tampilkan data terbaru.
- Jika gagal, tampilkan pesan tanpa menghapus input yang masih valid.
Jangan menampilkan menu "Simulasi Peran".
18. Aturan Login Saat Mengakses Fitur
  Aksi                    Perlu login?            Perilaku jika belum
                                                  login
  Melihat beranda         Tidak, jika konten      Tetap dapat melihat
                          publik tersedia         beranda

  Mencari tempat          Tidak, jika fitur       Tetap dapat mencari
                          publik                  

  Melihat detail tempat   Tidak, jika konten      Tetap dapat melihat
                          publik                  

  Melihat menu            Tidak, jika menu publik Tetap dapat melihat

  Menyimpan favorit       Ya jika favorit terikat Arahkan ke login, lalu
                          akun                    kembali ke konteks
                                                  sebelumnya bila
                                                  memungkinkan

  Membuat pesanan         Ya jika transaksi       Arahkan ke login
                          membutuhkan akun        sebelum checkout

  Melihat riwayat         Ya                      Arahkan ke login
  transaksi                                       

  Mengirim ulasan         Ya                      Arahkan ke login
  Mengubah profil         Ya                      Arahkan ke login
Tabel ini adalah rekomendasi awal. Keputusan login wajib untuk checkout
harus ditetapkan secara eksplisit sebelum implementasi.
19. Notifikasi dan Feedback
Gunakan feedback sesuai tingkat pentingnya aksi:
- Aksi ringan: snackbar/toast, misalnya favorit berhasil
  diperbarui.
- Validasi formulir: pesan di dekat kolom terkait.
- Konfirmasi penting: dialog, misalnya logout atau aksi yang
  menghapus item.
- Proses berjalan: indikator loading dan tombol nonaktif
  sementara.
- Kegagalan: pesan yang jelas dengan opsi coba lagi jika masuk
  akal.
- Transaksi: status dan nomor transaksi ditampilkan pada halaman
  yang sesuai.
Notifikasi push tidak dianggap tersedia sampai sistem notifikasi dan
izin perangkat telah diimplementasikan.
20. Penanganan Edge Case
  Kondisi                             Respons yang diharapkan
  Tidak ada hasil pencarian           Empty state dan opsi mengubah
                                      filter

  Lokasi ditolak                      Pencarian tetap bisa dilakukan
                                      tanpa lokasi jika didukung

  Internet terputus                   Pesan koneksi dan opsi coba lagi

  Foto tempat gagal dimuat            Placeholder gambar

  Menu habis setelah masuk keranjang  Beri tahu pengguna dan minta
                                      menghapus/mengganti item

  Harga berubah saat checkout         Tampilkan harga baru dan minta
                                      pengguna meninjau ulang

  Tombol checkout ditekan             Cegah transaksi ganda
  berkali-kali                        

  Pembayaran belum terkonfirmasi      Tampilkan status menunggu, bukan
                                      berhasil

  Pembayaran gagal                    Tampilkan status gagal dan opsi
                                      berikutnya yang valid

  Sesi kedaluwarsa                    Minta login kembali dengan cara
                                      yang aman

  Favorit gagal disimpan              Pulihkan status ikon dan tampilkan
                                      pesan

  Ulasan gagal dikirim                Pertahankan isi yang aman dan
                                      izinkan mencoba lagi

  Pengguna tidak punya riwayat        Empty state dan tombol kembali ke
                                      Jelajah

  Item keranjang tidak lagi tersedia  Beri tahu pengguna sebelum checkout
                                  dilanjutkan
21. Data Minimum yang Dibutuhkan oleh UI
Bagian ini adalah kebutuhan informasi untuk UI, bukan rancangan skema
database final.
Tempat
- ID tempat.
- Nama.
- Foto.
- Kategori.
- Deskripsi jika tersedia.
- Alamat/lokasi jika tersedia.
- Kisaran harga atau informasi harga yang valid.
- Jam operasional jika tersedia.
- Rating jika tersedia.
- Status menerima pesanan jika fitur ini ada.
Menu
- ID item.
- ID tempat.
- Nama menu.
- Deskripsi jika tersedia.
- Foto jika tersedia.
- Harga.
- Status ketersediaan.
Pesanan
- ID/nomor pesanan.
- Pengguna pemilik transaksi.
- Tempat.
- Daftar item, kuantitas, dan harga pada saat transaksi.
- Subtotal.
- Rincian biaya.
- Total.
- Metode pembayaran.
- Status pembayaran.
- Status pesanan.
- Waktu dibuat dan diperbarui.
Ulasan
- ID ulasan.
- Pengguna.
- Tempat.
- Referensi transaksi jika ulasan berbasis transaksi.
- Rating.
- Isi ulasan.
- Foto jika fitur tersedia.
- Waktu dibuat.
Akun
- ID pengguna.
- Nama.
- Email atau nomor telepon sesuai mekanisme autentikasi.
- Data profil yang diizinkan.
- Status sesi dikelola secara aman oleh sistem autentikasi.
22. Kriteria Penerimaan
Autentikasi
- [ ] Pengguna dapat mendaftar dengan kolom yang diwajibkan.
- [ ] Pendaftaran mandiri hanya menghasilkan akun pelanggan.
- [ ] Login menampilkan error yang sesuai saat kredensial tidak valid.
- [ ] Logout mengakhiri sesi dan meminta konfirmasi.
- [ ] Fitur pemulihan kata sandi hanya tampil jika benar-benar
  didukung.
Pencarian
- [ ] Pengguna dapat mencari tempat berdasarkan kata kunci.
- [ ] Budget dan filter hanya menampilkan hasil sesuai data yang
  tersedia.
- [ ] Pengguna tetap dapat mencari tanpa izin lokasi jika mode
  tersebut didukung.
- [ ] Hasil kosong, loading, dan error memiliki tampilan yang jelas.
Tempat dan menu
- [ ] Detail tempat menampilkan data yang valid.
- [ ] Item menu menampilkan harga dan ketersediaan.
- [ ] Jumlah item dan subtotal diperbarui dengan benar.
- [ ] Item tidak tersedia tidak dapat dipesan.
Checkout
- [ ] Pengguna melihat ringkasan, rincian biaya, dan total sebelum
  konfirmasi.
- [ ] Sistem memvalidasi ulang harga dan ketersediaan.
- [ ] Tombol konfirmasi mencegah pengiriman ganda.
- [ ] Status pembayaran mencerminkan hasil aktual.
- [ ] Metode pembayaran yang tidak didukung tidak ditampilkan.
Akun dan transaksi
- [ ] Pengguna hanya melihat riwayat miliknya sendiri.
- [ ] Favorit dapat ditambah dan dihapus.
- [ ] Ulasan hanya dapat dikirim sesuai aturan kelayakan.
- [ ] Profil tidak menampilkan menu Simulasi Peran.
- [ ] Semua halaman data memiliki loading, empty, dan error state yang
  sesuai.
23. Keputusan yang Harus Ditetapkan Sebelum Coding
Beberapa keputusan berikut belum boleh diasumsikan final:
1. Apakah pengguna wajib login sebelum checkout atau boleh checkout
   sebagai tamu.
2. Metode pembayaran apa yang benar-benar akan didukung pada versi
   pertama.
3. Apakah pesanan dibuat untuk dibayar di kasir, dibayar online, atau
   keduanya.
4. Apakah satu keranjang hanya boleh berisi menu dari satu tempat.
5. Apakah pengguna dapat membatalkan pesanan dan dalam kondisi apa.
6. Status pesanan final yang dipakai oleh operasional tempat.
7. Apakah rating/ulasan hanya dapat diberikan setelah transaksi
   selesai.
8. Apakah lokasi otomatis, lokasi manual, atau keduanya akan tersedia.
9. Apakah fitur peta, unggah foto ulasan, notifikasi, dan promosi masuk
   ke versi pertama.
10. Mekanisme verifikasi email/nomor telepon dan pemulihan kata sandi.
Selama keputusan belum dibuat, desain dan implementasi harus menggunakan
pilihan paling sederhana yang benar-benar didukung, serta tidak
menampilkan fitur yang belum tersedia seolah-olah sudah aktif.
24. Prioritas Implementasi
Prioritas 1 --- Fondasi
- Navigasi utama.
- Splash dan onboarding.
- Daftar, login, dan logout.
- Beranda.
- Pencarian dan daftar tempat.
- Detail tempat dan menu.
Prioritas 2 --- Pemesanan
- Keranjang.
- Validasi harga dan ketersediaan.
- Checkout.
- Metode pembayaran yang telah diputuskan.
- Status dan detail transaksi.
Prioritas 3 --- Fitur akun
- Favorit.
- Riwayat transaksi.
- Profil.
- Ulasan.
Prioritas 4 --- Penyempurnaan
- Peta dan lokasi jika disetujui.
- Notifikasi jika sistem mendukung.
- Empty state, error state, aksesibilitas, performa, dan pengujian
  pada beberapa ukuran layar.
25. Hubungan dengan Dokumen Lain
- prd-design.md --- acuan tampilan visual, komponen, tipografi,
  warna, dan spesifikasi layar.
- prd-alur-nongki.md --- acuan navigasi, user flow, aturan
  keputusan, validasi, dan respons sistem.
- Dokumen teknis/API --- dibuat setelah kebutuhan produk dan alur
  utama disepakati.
- Dokumen dashboard operasional --- dibuat terpisah jika fitur
  pemilik usaha/admin/kasir dikembangkan.
Dokumen ini adalah draft awal. Perbarui setelah keputusan tentang
checkout, pembayaran, dan status pesanan ditetapkan.