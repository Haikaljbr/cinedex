# Catatan Bahan Laporan UTS: CineDex

Catatan ini disusun selama pengerjaan aplikasi dan mengikuti struktur bab laporan (Bab I sampai III).
Semua potongan kode berasal dari file asli di repository ini.

---

## Untuk 1.1 dan 1.2: Latar Belakang, Tujuan, dan Fitur

### Ringkasan tujuan aplikasi
CineDex adalah aplikasi mobile penjelajah film berbasis Flutter yang mengambil data dinamis dari
**TMDB (The Movie Database) API v3**. Aplikasi ini membantu pengguna menemukan film yang sedang tayang,
populer, berperingkat tinggi, dan yang akan tayang, mencari film berdasarkan judul, lalu melihat
informasi lengkap film (sinopsis, durasi, genre, pemeran, rating, dan trailer).

### Target pengguna
- Penikmat film yang ingin mencari referensi tontonan dengan cepat.
- Pengguna yang ingin mengecek informasi film (rating, durasi, pemeran, trailer) sebelum menonton di bioskop
  atau layanan streaming.
- Pengguna berbahasa Indonesia (data diminta dengan `language=id-ID` dan tanggal ditampilkan dalam format Indonesia).

### Daftar fitur
| No | Fitur | Halaman |
|----|-------|---------|
| 1 | Hero carousel 5 film yang sedang tayang (PageView + indikator halaman) | Beranda |
| 2 | Chip genre horizontal untuk memfilter film (chip "Semua" mengembalikan tampilan awal) | Beranda |
| 3 | Section horizontal: Populer, Top Rated, Akan Tayang | Beranda |
| 4 | Pull-to-refresh | Beranda |
| 5 | Pencarian film dengan debounce 500 ms, hasil dalam grid poster | Pencarian |
| 6 | State kosong, tidak ada hasil, loading, dan error pada pencarian | Pencarian |
| 7 | Detail film: backdrop, poster (animasi Hero), judul, tagline, rating bintang, jumlah vote, durasi, genre, tanggal rilis | Detail |
| 8 | Sinopsis yang bisa di-expand ("Selengkapnya") | Detail |
| 9 | Daftar 10 pemeran teratas (horizontal) | Detail |
| 10 | Tombol "Tonton Trailer" yang membuka YouTube | Detail |
| 11 | Loading shimmer, pesan error ramah + tombol "Coba Lagi", deteksi tanpa koneksi internet | Semua |
| 12 | Bottom navigation (Beranda, Cari) dan halaman Tentang berisi atribusi TMDB | Umum |

---

## Untuk 2.1: Persiapan Project dan Package

### Versi tools
| Tool | Versi |
|------|-------|
| Flutter | 3.44.0 (channel stable) |
| Dart | 3.12.0 |
| Android SDK | 36 (build-tools 36.1.0) |
| Java (JDK Android Studio) | OpenJDK 21 |
| Emulator uji | Pixel 5 (Android) |

### Perintah pembuatan project
```bash
flutter create --platforms=android --org com.example cinedex
cd cinedex
flutter pub add http provider flutter_dotenv cached_network_image intl google_fonts shimmer url_launcher
```
> Catatan: project awalnya terbuat untuk semua platform, lalu folder `ios/`, `linux/`, `macos/`, `web/`,
> dan `windows/` dihapus karena target aplikasi hanya Android.

### Tabel package
| Package | Versi | Fungsi | Alasan dipilih |
|---------|-------|--------|----------------|
| `http` | ^1.6.0 | Melakukan request HTTP GET ke TMDB API | Package resmi tim Dart, ringan, cukup untuk REST API sederhana |
| `provider` | ^6.1.5+1 | State management (ChangeNotifier) | Direkomendasikan dokumentasi Flutter, mudah dipahami, minim boilerplate |
| `flutter_dotenv` | ^6.0.1 | Membaca token TMDB dari file `.env` | Token tidak ditulis di kode sehingga aman untuk repo public |
| `cached_network_image` | ^4.0.3 | Menampilkan dan meng-cache gambar poster/backdrop | Gambar tidak diunduh ulang, scroll lebih mulus, ada placeholder dan error widget |
| `intl` | ^0.20.2 | Format tanggal ke bahasa Indonesia (`id_ID`) | Standar internasionalisasi di Dart |
| `google_fonts` | ^8.2.1 | Font Poppins untuk tipografi | Tidak perlu menyimpan file font manual |
| `shimmer` | ^4.0.0 | Efek loading skeleton | Loading terlihat lebih modern daripada spinner |
| `url_launcher` | ^6.3.3 | Membuka trailer di aplikasi YouTube/browser | Package resmi Flutter untuk membuka URL eksternal |

### Struktur folder
(diperbarui di bagian akhir pengerjaan, lihat bagian "Struktur folder final" di bawah)

### Konfigurasi `.env` dan permission
1. Buat akun di themoviedb.org, buka **Settings → API**, salin **API Read Access Token** (v4 auth).
2. Salin `.env.example` menjadi `.env`, lalu isi:
   ```
   TMDB_READ_TOKEN=eyJhbGciOi...
   ```
3. `.env` didaftarkan sebagai asset di `pubspec.yaml` dan dimasukkan ke `.gitignore`:
   ```yaml
   flutter:
     assets:
       - .env
   ```
4. Permission di `android/app/src/main/AndroidManifest.xml`:
   ```xml
   <uses-permission android:name="android.permission.INTERNET"/>
   <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
   ```
5. Konfigurasi `queries` agar `url_launcher` bisa membuka link `https` di Android 11+:
   ```xml
   <queries>
       <intent>
           <action android:name="android.intent.action.VIEW"/>
           <data android:scheme="https"/>
       </intent>
   </queries>
   ```
