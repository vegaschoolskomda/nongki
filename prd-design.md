PRD Design --- NONGKI Mobile App
Dokumen: prd-design.md
Produk: NONGKI
Platform utama: Aplikasi mobile
Status: Draft desain awal
Bahasa UI: Indonesia
Versi: 1.0

1. Ringkasan Produk
NONGKI adalah aplikasi mobile yang membantu pengguna menemukan tempat
nongkrong atau kafe sesuai kebutuhan, melihat informasi tempat dan menu,
membuat pesanan, memilih metode pembayaran, serta melihat riwayat
transaksi dan memberikan ulasan.

Fokus dokumen ini adalah arah desain UI/UX dan spesifikasi tampilan
sebagai acuan sebelum implementasi. Detail alur bisnis, aturan validasi,
dan alur perpindahan antarlayar akan dijabarkan terpisah dalam
prd-alur-nongki.prd.
Prinsip desain
1. Mudah dipahami: pengguna baru dapat menemukan tempat dan memesan
   tanpa perlu menebak fungsi tombol.
2. Visual menggugah selera: foto tempat dan menu menjadi elemen
   utama.
3. Hangat dan nyaman: nuansa visual terasa seperti suasana
   nongkrong.
4. Ringkas: informasi penting seperti nama tempat, harga, kategori,
   dan status pesanan mudah dipindai.
5. Konsisten: komponen, jarak, ikon, tombol, dan gaya teks
   mengikuti sistem desain yang sama.
2. Tujuan Desain
- Membuat pengalaman mencari tempat nongkrong terasa cepat dan
  menyenangkan.
- Membantu pengguna membandingkan tempat berdasarkan anggaran, lokasi,
  suasana, dan informasi yang tersedia.
- Membuat proses pemilihan menu dan pemesanan terasa jelas dari awal
  hingga selesai.
- Memberikan tampilan yang nyaman digunakan pada layar ponsel.
- Menyediakan desain yang dapat dikembangkan secara konsisten oleh
  developer.
Bukan tujuan dokumen ini
- Menentukan arsitektur backend atau skema database secara rinci.
- Menentukan API, autentikasi teknis, atau integrasi payment gateway.
- Menetapkan bahwa pembayaran online sudah aktif sebelum metode dan
  penyedianya dipastikan.
- Menambahkan fitur AI. Versi konsep NONGKI saat ini tidak
  menggunakan AI.
3. Pengguna dan Kebutuhan Utama
3.1 Pengguna/pelanggan
Pengguna yang ingin mencari tempat nongkrong, menyesuaikan pilihan
dengan anggaran, melihat menu, memesan, membayar, dan meninjau
transaksi.

Kebutuhan desain: - Bisa langsung memahami cara mencari tempat. - Bisa
melihat kisaran harga sebelum memilih. - Bisa menemukan informasi tempat
dan menu tanpa tampilan yang padat. - Bisa mengetahui jumlah pesanan dan
total pembayaran. - Bisa memahami status transaksi dengan jelas.
3.2 Pemilik usaha dan staf
Peran pemilik usaha, admin, dan kasir perlu dibedakan secara visual jika
dashboard operasional masuk dalam cakupan produk. Pada konsep yang telah
dibahas, kasir menerima/menangani pesanan, sedangkan admin
mengelola stok, absensi, struk manual, dan laporan keuangan. Dashboard
ini bukan fokus utama aplikasi pelanggan pada dokumen desain mobile ini.
4. Arah Visual dan Identitas Merek
4.1 Karakter merek
- Akrab
- Hangat
- Modern
- Santai
- Lokal
- Praktis
NONGKI sebaiknya terasa seperti teman yang membantu pengguna menemukan
tempat nyaman untuk menghabiskan waktu, bukan aplikasi pemesanan yang
terlalu formal.
4.2 Palet warna
Gunakan palet cokelat, krem, dan putih yang sesuai dengan logo serta
referensi desain yang diberikan.
  Token                   Warna acuan             Penggunaan
  Primary               Cokelat tua #5B3023   Tombol utama, navigasi
                                                  aktif, judul penting

  Primary Dark          Cokelat pekat #3D211A Teks/elemen dengan
                                                  penekanan tinggi

  Secondary             Cokelat sedang          Tombol sekunder, ikon,
                          #986747               label

  Accent                Krem hangat #F2E5D5   Panel informasi, kartu
                                                  promosi, latar lembut

  Background            Putih hangat #FFFCF8  Latar layar utama

  Surface               Putih #FFFFFF         Kartu dan form

  Text Primary          #2B211D               Teks utama

  Text Secondary        #766A63               Deskripsi dan metadata

  Border                #E5D8CD               Garis tepi input dan
                                                  kartu

  Success               #2E8B57               Status berhasil

  Warning               #C8872B               Status
                                                  menunggu/perhatian
  Error                 #B83B32               Error dan kegagalan
Warna di atas merupakan token awal dan boleh disesuaikan setelah
dibandingkan dengan file logo asli. Pastikan teks memiliki kontras yang
cukup, terutama di atas tombol cokelat dan latar krem.
4.3 Tipografi
Gunakan satu keluarga font sans-serif yang mudah dibaca, misalnya
Poppins untuk heading dan Inter atau font sans-serif sistem
untuk isi. Jika implementasi perlu lebih ringan, gunakan satu keluarga
font saja.

Skala awal: - Display/hero: 28--32 px, semibold/bold - Heading layar:
22--26 px, semibold - Heading bagian: 16--20 px, semibold - Isi utama:
14--16 px, regular - Label dan metadata: 12--13 px, regular/medium -
Tombol: 14--16 px, semibold

Hindari teks isi yang terlalu kecil. Informasi penting tidak boleh hanya
dibedakan melalui warna.
4.4 Bentuk dan ruang
- Radius kartu: 14--18 px.
- Radius input: 10--12 px.
- Radius tombol utama: 10--12 px atau pill jika sesuai komponen.
- Jarak horizontal standar: 20--24 px.
- Jarak antarbagian: 20--28 px.
- Jarak dalam kartu: 12--16 px.
- Gunakan bayangan lembut seperlunya; hindari efek glow atau gradien
  yang berlebihan.
- Pertahankan ruang kosong agar foto dan informasi tidak terasa sesak.
4.5 Fotografi dan ilustrasi
- Foto tempat dan makanan/minuman menjadi fokus pada halaman beranda
  dan daftar tempat.
- Gunakan foto dengan pencahayaan baik dan rasio yang konsisten.
- Foto harus memiliki sudut membulat dan crop yang rapi.
- Hindari penggunaan foto dekoratif yang menutupi teks penting.
- Sediakan placeholder saat gambar belum dimuat atau tidak tersedia.
- Jangan menggunakan foto contoh seolah-olah merupakan data tempat
  sungguhan jika belum diverifikasi.
4.6 Ikon
Gunakan ikon outline yang konsisten, misalnya gaya Material Symbols atau
Lucide. Hindari mencampur ikon outline, filled, dan emoji secara acak.
Ikon yang mewakili navigasi harus memiliki label teks agar mudah
dipahami.
5. Prinsip Layout Mobile
- Desain mengutamakan layar ponsel portrait.
- Gunakan safe area untuk status bar, notch, dan navigation area.
- Konten utama dapat discroll secara vertikal.
- Tombol aksi penting diletakkan pada area yang mudah dijangkau ibu
  jari.
- Pada halaman pemesanan, total dan tombol lanjut dapat dibuat sticky
  di bagian bawah selama tidak menutupi konten.
- Form menggunakan label yang jelas, bukan placeholder saja.
- Sediakan kondisi loading, kosong, error, berhasil, dan offline untuk
  halaman yang mengambil data.
- Hindari terlalu banyak informasi di atas fold; tampilkan ringkasan
  dahulu dan detail setelahnya.
6. Struktur Navigasi Utama
Navigasi bawah untuk area utama aplikasi pelanggan menggunakan lima tab,
sesuai referensi desain:
1. Beranda --- rekomendasi, pencarian, kategori, dan tempat
   pilihan.
2. Jelajah --- daftar tempat yang dapat ditelusuri dan difilter.
3. Pesanan --- keranjang atau pesanan aktif, disesuaikan dengan
   status pengguna.
4. Favorit --- tempat yang disimpan pengguna.
5. Profil --- akun dan pengaturan.
Ketentuan: - Tab aktif menggunakan warna Primary. - Tab tidak aktif
memakai warna netral. - Ikon dan label harus tetap terlihat jelas. -
Navigasi bawah tidak perlu muncul pada splash, onboarding, login,
daftar, atau layar transaksi penuh jika mengganggu fokus. - Jika satu
tab belum memiliki fitur final, jangan membuatnya tampak aktif tanpa
fungsi.
7. Spesifikasi Layar
7.1 Splash Screen
Tujuan: memperkenalkan merek saat aplikasi dibuka.

Komponen: - Logo wordmark NONGKI di tengah. - Latar foto interior kafe
atau warna krem/cokelat dengan overlay gelap jika menggunakan foto. -
Animasi sederhana dan singkat bila diperlukan. - Tidak perlu menampilkan
banyak teks.

Catatan: - Splash tidak boleh terlalu lama. - Setelah proses awal
selesai, arahkan pengguna ke onboarding atau halaman utama sesuai status
sesi.
7.2 Onboarding
Gunakan tiga halaman onboarding yang konsisten, mengikuti referensi
desain:
1. Tempat seru, sesuai budgetmu
   Deskripsi: "Masukkan budget dan temukan tempat nongkrong yang pas
   dengan rencana kamu."
2. Rekomendasi yang ngerti maumu
   Deskripsi: "Jelajahi tempat berdasarkan harga, suasana, fasilitas,
   dan kebutuhanmu."
   Hindari kata-kata yang mengesankan rekomendasi berbasis AI.
3. Budget pas, nongki puas!
   Deskripsi: "Temukan tempat nyaman dan nikmati pengalaman nongkrong
   yang lebih praktis."
Komponen: - Foto utama dengan sudut membulat. - Indikator halaman. -
Tombol Lanjut. - Aksi Lewati pada halaman awal jika diputuskan
diperlukan. - Tombol terakhir berubah menjadi Mulai. - Pastikan teks
singkat dan tidak memenuhi layar.
7.3 Login
Tujuan: pengguna masuk ke akun.

Komponen: - Logo NONGKI. - Sapaan: "Welcome back to NONGKI!" -
Deskripsi singkat: "Masuk dan lanjutkan rencana nongkrongmu." - Input
email atau nomor telepon sesuai keputusan autentikasi. - Input kata
sandi dengan opsi tampil/sembunyikan. - Tombol utama Masuk ke
Akun. - Tautan Lupa kata sandi? - Tautan ke halaman daftar.

Ketentuan desain: - Label input selalu terlihat. - Error validasi tampil
dekat input terkait. - Tombol menampilkan loading saat proses masuk
berlangsung. - Jangan menghapus isi input saat terjadi error yang tidak
berkaitan dengan input tersebut.
7.4 Daftar Akun
Komponen: - Logo NONGKI. - Sapaan: "Yuk, mulai nongki!" - Deskripsi:
"Buat akun agar kamu bisa menyimpan tempat favorit dan mengelola
pesananmu." - Input nama, email/nomor telepon, kata sandi, dan
konfirmasi kata sandi jika dibutuhkan. - Checkbox persetujuan syarat dan
kebijakan privasi jika dokumennya tersedia. - Tombol utama Buat
Akun. - Tautan ke login.

Jangan menampilkan kolom atau opsi yang tidak benar-benar digunakan oleh
sistem.
7.5 Beranda
Tujuan: menjadi titik awal untuk menemukan tempat dan melanjutkan
aktivitas.

Urutan komponen yang disarankan: 1. Header dengan logo NONGKI dan akses
profil/notifikasi jika fitur tersedia. 2. Sapaan singkat, misalnya
"Mau nongki ke mana hari ini?" 3. Kolom pencarian tempat. 4. Kontrol
lokasi atau lokasi aktif, hanya jika izin lokasi dan fitur lokasi
tersedia. 5. Modul Cari sesuai budget dengan input atau pilihan
rentang anggaran. 6. Kategori tempat, misalnya Kafe, Outdoor, Working
Space, atau kategori yang benar-benar tersedia di data. 7. Bagian
Tempat pilihan atau Dekat kamu jika data dan lokasi mendukung.
8. Kartu tempat dengan foto, nama, kategori, kisaran harga, jarak (jika
tersedia), dan rating (jika ada). 9. Kartu promosi hanya jika ada
promosi aktif dan terverifikasi. 10. Navigasi bawah.

Kartu tempat: - Foto sebagai bagian visual utama. - Nama tempat maksimal
dua baris. - Informasi ringkas; hindari terlalu banyak badge. - Tombol
favorit berupa ikon dengan status aktif/nonaktif yang jelas. - Seluruh
kartu dapat membuka detail tempat, tetapi tombol favorit tetap memiliki
aksi tersendiri.

Kondisi kosong: - Jika belum ada hasil, tampilkan pesan "Belum ada
tempat yang cocok." - Berikan opsi mengubah budget, kategori, atau
lokasi.
7.6 Jelajah dan Hasil Pencarian
Tujuan: membantu pengguna menelusuri tempat secara lebih spesifik.

Komponen: - Kolom pencarian. - Ringkasan jumlah hasil jika datanya
tersedia. - Filter budget, kategori, jarak/lokasi, dan rating hanya jika
data tersebut tersedia. - Pengurutan yang jelas, misalnya relevan, harga
terendah, atau terdekat jika didukung. - Daftar kartu tempat. - Tombol
untuk menghapus filter. - Empty state ketika tidak ada hasil.

Ketentuan: - Filter aktif ditampilkan sebagai chip atau ringkasan yang
mudah dihapus. - Jangan menampilkan filter yang tidak bisa diterapkan
oleh sistem. - Pilihan "terdekat" membutuhkan data lokasi yang memadai
dan izin pengguna.
7.7 Detail Tempat
Tujuan: memberi informasi yang cukup sebelum pengguna memutuskan
memesan.

Komponen: - Foto utama atau galeri. - Nama tempat. - Kategori, alamat,
jam operasional, rating, dan kisaran harga jika datanya tersedia. -
Tombol favorit. - Deskripsi tempat. - Informasi fasilitas jika
tersedia. - Tombol peta/arah jika integrasi peta atau tautan lokasi
tersedia. - Daftar menu atau tombol untuk melihat menu. - Tombol aksi
utama yang sesuai, misalnya Lihat Menu atau Pesan, jika tempat
mendukung pemesanan.

Ketentuan: - Jangan mengarang jam operasional, rating, fasilitas, atau
alamat. - Jika data belum tersedia, sembunyikan bagian tersebut atau
tampilkan keterangan yang jujur. - Bedakan tombol membuka lokasi dengan
tombol melakukan pemesanan.
7.8 Menu Tempat
Tujuan: membantu pengguna memilih makanan/minuman.

Komponen: - Header nama tempat dan navigasi kembali. - Kategori menu
jika ada. - Daftar item dengan foto, nama, deskripsi singkat, dan
harga. - Kontrol tambah/kurang jumlah. - Indikator item yang tidak
tersedia. - Ringkasan jumlah item dan subtotal. - Tombol Lihat
Keranjang atau Lanjut ke Keranjang ketika ada item.

Ketentuan: - Harga harus mudah dibaca. - Tombol tambah/kurang memiliki
area sentuh yang memadai. - Perubahan jumlah harus memperbarui subtotal
secara konsisten. - Jangan mengizinkan item yang tidak tersedia
ditambahkan ke pesanan.
7.9 Keranjang
Tujuan: memeriksa pesanan sebelum pembayaran.

Komponen: - Ringkasan tempat. - Daftar item, jumlah, harga satuan, dan
subtotal. - Kontrol mengubah jumlah atau menghapus item. - Catatan untuk
pesanan jika didukung. - Rincian biaya: subtotal, biaya layanan, pajak,
atau biaya lain hanya jika benar-benar berlaku. - Total pembayaran. -
Tombol Lanjut ke Pembayaran.

Ketentuan: - Perubahan jumlah harus memperbarui total. - Biaya tambahan
harus dijelaskan, bukan muncul tiba-tiba. - Jika keranjang kosong,
tampilkan ilustrasi/ikon sederhana dan tombol kembali ke menu. - Jika
satu keranjang hanya boleh berisi menu dari satu tempat, tampilkan
aturan tersebut dengan jelas.
7.10 Pilih Pembayaran
Tujuan: memberi pengguna ringkasan dan pilihan pembayaran yang
didukung.

Komponen: - Ringkasan pesanan. - Pilihan metode pembayaran dalam bentuk
baris/kartu. - Ikon, nama metode, dan deskripsi singkat. - Total
pembayaran yang menonjol. - Tombol Bayar Sekarang.

Metode pada desain referensi mencakup kartu debit/kredit, transfer bank,
PayPal, dan tunai. Ini adalah contoh visual, bukan konfirmasi bahwa
semua metode tersedia. Implementasi hanya boleh menampilkan metode
yang telah disetujui dan benar-benar terintegrasi. Jika versi awal hanya
mendukung tunai atau pembayaran di kasir, desain harus disederhanakan
sesuai kondisi tersebut.

Ketentuan: - Metode terpilih terlihat jelas. - Jangan meminta detail
kartu sensitif jika tidak menggunakan penyedia pembayaran yang aman. -
Tampilkan instruksi tambahan sesuai metode yang dipilih. - Tangani
kondisi pembayaran gagal atau dibatalkan dengan pesan yang jelas.
7.11 Pembayaran Berhasil
Tujuan: memastikan pengguna memahami bahwa pesanan telah diterima
oleh sistem.

Komponen: - Ikon status berhasil. - Judul "Pesananmu sudah
diterima!" hanya jika sistem benar-benar mengonfirmasi status
tersebut. - Nomor pesanan. - Nama tempat. - Waktu transaksi. - Metode
pembayaran. - Total. - Tombol Lihat Detail Transaksi. - Tombol
Tulis Ulasan jika ulasan tersedia. - Tombol kembali ke beranda.

Ketentuan: - Jangan menampilkan status berhasil sebelum ada konfirmasi
dari sistem. - Jika pembayaran masih menunggu, gunakan status Menunggu
Pembayaran atau status aktual yang sesuai.
7.12 Riwayat Transaksi
Tujuan: memudahkan pengguna menemukan transaksi sebelumnya.

Komponen: - Daftar transaksi terbaru. - Nama tempat dan tanggal. - Total
pembayaran. - Status transaksi. - Tombol Lihat Detail atau Tulis
Ulasan jika memenuhi syarat. - Filter status jika jumlah transaksi
sudah memadai.

Kondisi kosong: - Tampilkan pesan bahwa belum ada transaksi. - Berikan
tombol kembali ke jelajah tempat.
7.13 Tulis Ulasan
Komponen: - Nama tempat dan ringkasan transaksi. - Pertanyaan
"Bagaimana pengalaman nongkrongmu hari ini?" - Pilihan rating
bintang 1--5. - Kolom cerita/pesan. - Unggah foto opsional jika fitur
dan batas ukuran sudah ditentukan. - Tombol Kirim Ulasan.

Ketentuan: - Rating yang dipilih harus tampak jelas. - Validasi input
dengan bahasa yang sopan. - Setelah terkirim, tampilkan konfirmasi. -
Jangan meminta ulasan sebelum transaksi memenuhi syarat yang ditetapkan
produk.
7.14 Ulasan Terkirim
Komponen: - Ikon berhasil. - Pesan "Terima kasih, ulasanmu berhasil
dikirim." - Ringkasan ulasan jika sesuai. - Tombol Lihat Halaman
Tempat. - Tombol Kembali ke Beranda.
7.15 Favorit
Tujuan: menyimpan tempat yang ingin dikunjungi lagi.

Komponen: - Judul Favoritku. - Daftar kartu tempat yang disimpan. -
Tombol untuk menghapus/menonaktifkan favorit. - Empty state ketika belum
ada favorit.

Pastikan perubahan favorit terlihat langsung dan statusnya tetap
konsisten setelah aplikasi dibuka kembali jika penyimpanan akun sudah
tersedia.
7.16 Profil
Tujuan: menyediakan akses ke akun dan fitur personal.

Komponen: - Judul Profil. - Kartu ringkasan pengguna: nama dan
email/nomor telepon. - Menu Edit Profil. - Menu Riwayat
Transaksi. - Menu Favorit. - Menu Pengaturan jika tersedia. -
Menu bantuan atau kebijakan privasi jika halaman tersebut sudah
dibuat. - Tombol Keluar.

Ketentuan: - Jangan menampilkan menu Simulasi Peran. - Jangan
menampilkan fungsi yang belum tersedia sebagai fitur aktif. - Aksi
keluar akun sebaiknya meminta konfirmasi.
8. Komponen UI yang Dapat Digunakan Ulang
8.1 Tombol
- Primary: latar cokelat tua, teks putih; untuk aksi utama.
- Secondary: latar krem atau putih dengan border cokelat; untuk
  aksi pendamping.
- Text button: tanpa latar kuat; untuk aksi seperti "Lewati" atau
  "Lihat semua".
- Disabled: kontras tetap cukup, tetapi jelas tidak aktif.
- Loading: tampilkan indikator dan cegah pengiriman ganda.
8.2 Input
- Label di atas input.
- Placeholder sebagai contoh, bukan satu-satunya petunjuk.
- Ikon hanya jika membantu pemahaman.
- Status default, focus, error, disabled, dan success harus konsisten.
- Pesan error spesifik dan ditempatkan dekat input terkait.
8.3 Kartu tempat
Elemen minimum: - Foto. - Nama tempat. - Kategori atau ringkasan suasana
jika tersedia. - Kisaran harga. - Rating/jarak hanya jika data
tersedia. - Tombol favorit.
8.4 Kartu menu
Elemen minimum: - Foto thumbnail jika tersedia. - Nama item. - Deskripsi
singkat jika tersedia. - Harga. - Kontrol jumlah/tambah.
8.5 Status transaksi
Gunakan label teks dan warna: - Menunggu pembayaran - Diproses -
Diterima/siap sesuai status operasional yang benar - Selesai -
Dibatalkan - Gagal

Daftar final status harus diselaraskan dengan sistem pemesanan. Jangan
mengandalkan warna saja untuk membedakan status.
8.6 Feedback sistem
Sediakan: - Snackbar/toast untuk aksi ringan. - Dialog untuk konfirmasi
penting. - Inline error untuk input. - Skeleton/loading indicator untuk
data. - Empty state dengan tindakan berikutnya yang relevan. - Retry
ketika pemuatan data gagal.
9. Status dan Keadaan Layar
Setiap layar yang memuat data dari server perlu mempertimbangkan:
1. Loading: pengguna tahu data sedang dimuat.
2. Success: data tampil normal.
3. Empty: belum ada data, disertai tindakan berikutnya.
4. Error: pesan yang mudah dipahami dan tombol coba lagi bila
   relevan.
5. Offline: jelaskan bahwa koneksi bermasalah; jangan membuat data
   seolah-olah berhasil diperbarui.
6. Disabled/unavailable: item yang tidak tersedia terlihat berbeda
   dan tidak dapat dipilih.
7. Session expired: arahkan pengguna login kembali tanpa
   menghilangkan informasi yang masih aman dipertahankan.
10. Aksesibilitas dan Usability
- Area sentuh tombol dan ikon penting disarankan minimal sekitar 44 ×
  44 px.
- Kontras teks harus memadai.
- Gunakan label teks bersama ikon navigasi.
- Jangan mengandalkan warna sebagai satu-satunya indikator status.
- Ukuran teks dapat dibaca pada layar ponsel umum.
- Form mendukung keyboard yang sesuai dengan jenis input.
- Berikan feedback setelah tombol ditekan.
- Hindari animasi berlebihan dan sediakan transisi yang cepat.
- Pertahankan pola navigasi kembali yang konsisten.
- Pastikan konten tetap dapat digunakan pada layar yang lebih kecil.
11. Responsivitas dan Performa Visual
Walaupun fokusnya mobile, desain harus menyesuaikan ukuran layar Android
yang berbeda.
- Gunakan layout fleksibel, bukan ukuran absolut untuk seluruh layar.
- Foto menggunakan crop yang konsisten.
- Daftar panjang menggunakan scroll.
- Hindari memuat semua foto beresolusi besar sekaligus.
- Tampilkan placeholder saat gambar dimuat.
- Jaga agar tombol utama tidak tertutup keyboard.
- Uji pada layar kecil dan layar dengan rasio tinggi.
12. Motion dan Microinteraction
Animasi digunakan untuk membantu pemahaman, bukan sebagai dekorasi
berlebihan.

Contoh: - Transisi halaman singkat. - Feedback halus ketika menambah
item ke keranjang. - Perubahan ikon saat tempat ditambahkan ke
favorit. - Indikator loading ketika melakukan pencarian atau
pembayaran. - Perubahan jumlah item dan subtotal dengan feedback yang
jelas.

Hindari animasi panjang yang memperlambat pemesanan atau mengganggu
pengguna dengan perangkat kelas menengah.
13. Aturan Konten UI
Gunakan Bahasa Indonesia yang: - Ramah dan santai, tetapi tetap jelas. -
Tidak terlalu formal. - Konsisten dalam penggunaan kata "tempat",
"menu", "pesanan", "pembayaran", dan "ulasan". - Tidak menjanjikan
sesuatu yang belum didukung sistem.

Contoh microcopy: - Pencarian: "Cari tempat atau nama kafe..." -
Budget: "Berapa budget nongkimu?" - Hasil kosong: "Belum ada
tempat yang cocok. Coba ubah budget atau filter kamu." - Keranjang
kosong: "Keranjangmu masih kosong." - Favorit kosong: "Belum ada
tempat favorit. Yuk, temukan tempat yang kamu suka." - Koneksi gagal:
"Koneksi bermasalah. Periksa internetmu lalu coba lagi." - Error
umum: "Ada kendala. Coba lagi sebentar, ya."

Hindari klaim seperti "paling murah", "terdekat", "tersedia sekarang",
atau nilai rating tertentu jika tidak didukung data yang valid.
14. Batasan dan Asumsi
1. Desain awal mengacu pada kumpulan gambar UI yang disertakan dalam
   arsip referensi NONGKI.
2. Warna, tipografi, radius, dan spacing di dokumen ini adalah token
   awal dan dapat disesuaikan saat implementasi.
3. Data tempat, harga, menu, rating, jam buka, dan promosi harus
   berasal dari data yang valid.
4. Filter lokasi/jarak hanya aktif jika kemampuan lokasi tersedia dan
   izin pengguna diberikan.
5. Metode pembayaran harus mengikuti integrasi yang benar-benar
   tersedia.
6. Fitur unggah foto ulasan hanya diaktifkan jika backend mendukungnya.
7. Dashboard pemilik/admin/kasir perlu PRD dan desain tersendiri jika
   akan dibangun sebagai bagian dari produk.
8. NONGKI saat ini tidak menggunakan AI.
9. Detail alur perpindahan layar dan aturan proses akan ditulis dalam
   dokumen prd-alur-nongki.prd.
15. Kriteria Penerimaan Desain
Desain dapat dianggap siap menjadi acuan implementasi awal apabila:
- [ ] Warna, tipografi, spacing, radius, dan gaya ikon konsisten.
- [ ] Semua layar utama pada bagian 7 memiliki spesifikasi komponen.
- [ ] Navigasi bawah konsisten dan menunjukkan tab aktif.
- [ ] Login dan daftar memiliki state normal, loading, dan error.
- [ ] Beranda dan jelajah memiliki state loading, kosong, dan gagal.
- [ ] Kartu tempat menunjukkan informasi yang benar-benar tersedia.
- [ ] Menu, keranjang, dan pembayaran menunjukkan harga serta total
  secara jelas.
- [ ] Status transaksi tidak menyesatkan pengguna.
- [ ] Favorit, riwayat transaksi, ulasan, dan profil memiliki empty
  state yang sesuai.
- [ ] Tombol utama, tombol sekunder, input, kartu, dan status tersedia
  sebagai komponen reusable.
- [ ] Desain dapat dibaca dan digunakan pada beberapa ukuran layar
  ponsel.
- [ ] Tidak ada fitur AI atau metode pembayaran yang ditampilkan
  sebagai fitur aktif tanpa keputusan dan dukungan implementasi.
- [ ] Tidak ada menu Simulasi Peran pada halaman profil.
16. Rekomendasi Urutan Implementasi UI
1. Design tokens dan komponen dasar.
2. Splash dan onboarding.
3. Login dan daftar.
4. Beranda dan navigasi bawah.
5. Jelajah, pencarian, filter, dan detail tempat.
6. Menu tempat dan keranjang.
7. Pilih pembayaran dan status transaksi.
8. Riwayat transaksi dan ulasan.
9. Favorit dan profil.
10. Polishing responsivitas, aksesibilitas, loading, empty state, dan
    error state.
Urutan ini adalah prioritas implementasi UI, bukan pengganti dokumen
alur aplikasi.
17. Referensi Desain
Referensi awal berasal dari aset gambar dalam arsip
folder Referensi-design-apk Nongki, yang mencakup: - Splash screen dan
onboarding. - Login dan daftar. - Beranda dan daftar tempat. - Detail
tempat/menu. - Keranjang. - Pilih pembayaran dan pembayaran berhasil. -
Riwayat transaksi. - Tulis ulasan dan konfirmasi ulasan. - Profil dan
navigasi bawah.

Gunakan aset tersebut sebagai referensi visual, bukan sebagai alasan
untuk menganggap semua fitur sudah final atau sudah tersedia secara
teknis.
untuk logonya dan referensi design ada di folder Referensi-design-apk Nongki
