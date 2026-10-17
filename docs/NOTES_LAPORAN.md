# Catatan Bahan Laporan UTS: CineDex

Catatan ini disusun selama pengerjaan aplikasi dan mengikuti struktur bab laporan (Bab I sampai III).
Semua potongan kode di bawah diambil dari file asli di repository ini (nama file disebutkan di atas tiap potongan).

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
| 1 | Hero carousel 5 film yang sedang tayang (PageView, indikator halaman, bergeser otomatis tiap 5 detik) | Beranda |
| 2 | Chip genre horizontal untuk memfilter film (chip "Semua" mengembalikan tampilan awal) | Beranda |
| 3 | Section horizontal: Populer, Top Rated, Akan Tayang | Beranda |
| 4 | Pull-to-refresh | Beranda |
| 5 | Pencarian film dengan debounce 500 ms, hasil dalam grid poster 3 kolom | Pencarian |
| 6 | State kosong, tidak ada hasil, loading, dan error pada pencarian | Pencarian |
| 7 | Detail film: backdrop, poster (animasi Hero), judul, tagline, rating bintang, jumlah vote, durasi, genre, tanggal rilis | Detail |
| 8 | Sinopsis yang bisa di-expand ("Selengkapnya" / "Sembunyikan") | Detail |
| 9 | Daftar 10 pemeran teratas (horizontal) | Detail |
| 10 | Tombol "Tonton Trailer" yang membuka aplikasi YouTube | Detail |
| 11 | Loading shimmer, pesan error ramah + tombol "Coba Lagi", deteksi tanpa koneksi internet | Semua |
| 12 | Bottom navigation (Beranda, Cari) dan halaman Tentang berisi atribusi TMDB | Umum |

### Kesesuaian dengan persyaratan dosen
| Persyaratan | Pemenuhan di CineDex |
|-------------|----------------------|
| A. Minimal 1 halaman GUI | 3 halaman utama (Beranda, Pencarian, Detail) + halaman Tentang |
| B. Data dinamis dari API | 10 endpoint TMDB API v3 (lihat tabel di 2.3) |
| C. Mengambil, mengolah, menyajikan data | Parsing JSON → model, 8 langkah pengolahan data (lihat 2.3), ditampilkan di UI |
| D. Flutter dan Dart | Flutter 3.44.0, Dart 3.12.0 |

---

## Untuk 2.1: Persiapan Project dan Package

### Versi tools
| Tool | Versi |
|------|-------|
| Flutter | 3.44.0 (channel stable) |
| Dart | 3.12.0 |
| Android SDK | 36 (build-tools 36.1.0) |
| Java (JDK Android Studio) | OpenJDK 21 |
| Emulator uji | Pixel 5, Android 11 (API 30) |

### Perintah pembuatan project
```bash
flutter create --platforms=android cinedex
cd cinedex
flutter pub add http provider flutter_dotenv cached_network_image intl google_fonts shimmer url_launcher
```
> Catatan: project awalnya terbuat untuk semua platform, lalu folder `ios/`, `linux/`, `macos/`, `web/`,
> dan `windows/` dihapus karena target aplikasi hanya Android.

### Tabel package
| Package | Versi | Fungsi | Alasan dipilih |
|---------|-------|--------|----------------|
| `http` | ^1.6.0 | Melakukan request HTTP GET ke TMDB API | Package resmi tim Dart, ringan, cukup untuk REST API sederhana, punya `MockClient` untuk unit test |
| `provider` | ^6.1.5+1 | State management (ChangeNotifier) | Direkomendasikan dokumentasi Flutter, mudah dipahami, minim boilerplate |
| `flutter_dotenv` | ^6.0.1 | Membaca token TMDB dari file `.env` | Token tidak ditulis di kode sehingga aman untuk repo public |
| `cached_network_image` | ^4.0.3 | Menampilkan dan meng-cache gambar poster/backdrop | Gambar tidak diunduh ulang, scroll lebih mulus, ada placeholder dan error widget |
| `intl` | ^0.20.2 | Format tanggal ke bahasa Indonesia (`id_ID`) | Standar internasionalisasi di Dart |
| `google_fonts` | ^8.2.1 | Font Poppins untuk tipografi | Tidak perlu menyimpan file font manual |
| `shimmer` | ^4.0.0 | Efek loading skeleton | Loading terlihat lebih modern daripada spinner |
| `url_launcher` | ^6.3.3 | Membuka trailer di aplikasi YouTube/browser | Package resmi Flutter untuk membuka URL eksternal |

### Struktur folder
```
cinedex/
├── android/                    Konfigurasi proyek Android (manifest, gradle)
├── docs/
│   ├── NOTES_LAPORAN.md        Catatan bahan laporan (file ini)
│   └── screenshots/            Tangkapan layar aplikasi
├── lib/
│   ├── main.dart               Titik masuk: load .env, data tanggal id_ID, runApp
│   ├── app.dart                Root widget: daftar provider, tema, halaman awal
│   ├── core/
│   │   ├── config/env.dart             Membaca TMDB_READ_TOKEN dari .env
│   │   ├── constants/api_constants.dart Base URL, endpoint, ukuran gambar, timeout
│   │   ├── constants/app_strings.dart  Teks statis (nama app, atribusi TMDB)
│   │   ├── theme/                      Warna, ukuran/radius, tipografi, ThemeData
│   │   └── utils/
│   │       ├── formatters.dart         Format rating, durasi, tanggal, jumlah vote
│   │       └── movie_utils.dart        Mapping genre, filter poster, pilih trailer, top cast
│   ├── data/
│   │   ├── models/             Movie, MovieDetail, Genre, CastMember, Video (fromJson)
│   │   ├── services/
│   │   │   ├── tmdb_service.dart       SEMUA panggilan HTTP ke TMDB
│   │   │   └── api_exception.dart      Exception khusus (tanpa internet, timeout, dll)
│   │   └── repositories/
│   │       └── movie_repository.dart   Pengolahan data + cache genre + fallback
│   ├── providers/              State per fitur (ChangeNotifier)
│   │   ├── view_state.dart             Enum LoadStatus + UiError
│   │   ├── home_provider.dart
│   │   ├── search_provider.dart
│   │   └── movie_detail_provider.dart
│   ├── screens/                Halaman: home, search, detail, about, main_screen (bottom nav)
│   └── widgets/                Komponen reusable: movie_card, hero_carousel, genre_chips,
│                               shimmer_loading, state_views, cast_list, expandable_text, dll
├── test/                       Unit test (formatter, model, utils, service, debounce)
├── .env.example                Contoh isi .env (token asli TIDAK di-commit)
└── pubspec.yaml                Daftar package dan asset
```

Alur ketergantungan antar-lapisan (satu arah):
`screens/widgets → providers → repositories → services → TMDB API`

### Konfigurasi `.env` dan permission
1. Buat akun di themoviedb.org, buka **Settings → API**, salin **API Read Access Token**.
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
4. Token dibaca di `lib/core/config/env.dart`:
   ```dart
   static Future<void> load() => dotenv.load(fileName: '.env', isOptional: true);

   static String get tmdbReadToken {
     if (!dotenv.isInitialized) return '';
     final token = dotenv.maybeGet('TMDB_READ_TOKEN')?.trim() ?? '';
     return token == _placeholder ? '' : token;
   }
   ```
   Jika token kosong, aplikasi tidak crash, tetapi menampilkan pesan
   "Token TMDB belum diatur. Salin .env.example menjadi .env lalu isi TMDB_READ_TOKEN."
5. Permission di `android/app/src/main/AndroidManifest.xml`:
   ```xml
   <uses-permission android:name="android.permission.INTERNET"/>
   <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
   ```
6. Konfigurasi `queries` agar `url_launcher` bisa membuka link `https` di Android 11+:
   ```xml
   <queries>
       <intent>
           <action android:name="android.intent.action.VIEW"/>
           <data android:scheme="https"/>
       </intent>
   </queries>
   ```
7. Sebelum push, dicek bahwa `.env` tidak ikut ter-track:
   ```bash
   git ls-files | grep -i env     # hasil: hanya .env.example
   ```

---

## Untuk 2.2: Desain UI

### Daftar halaman dan widget utama
| Halaman | File | Widget utama |
|---------|------|--------------|
| Kerangka utama | `screens/main_screen.dart` | `NavigationBar` (Beranda, Cari), `IndexedStack` (state tab tetap tersimpan) |
| Beranda | `screens/home/home_screen.dart` | `RefreshIndicator`, `CustomScrollView`, `HeroCarousel` (`PageView` + indikator), `GenreChips`, `MovieSection` (ListView horizontal), `SliverMovieGrid` (hasil filter genre), `HomeShimmer`, `ErrorView` |
| Pencarian | `screens/search/search_screen.dart` | `TextField` dengan tombol hapus, `SliverMovieGrid` (grid 3 kolom), `SliverPosterGridShimmer`, `MessageView` (state kosong / tidak ditemukan), `ErrorView` |
| Detail Film | `screens/detail/detail_screen.dart` | `SliverAppBar` yang mengecil (backdrop + poster `Hero` + judul), `StarRating`, info durasi/tanggal, chip genre, `ElevatedButton` "Tonton Trailer", `ExpandableText`, `CastList`, `TmdbAttribution` |
| Tentang | `screens/about/about_screen.dart` | Deskripsi aplikasi, sumber data, atribusi TMDB |

Widget reusable di `lib/widgets/`:
`MovieCard`, `AppNetworkImage` (gambar ber-cache + shimmer + fallback), `RatingBadge`, `StarRating`,
`SectionHeader`, `MovieSection`, `SliverMovieGrid`, `HeroCarousel`, `GenreChips`, `ErrorView`, `MessageView`,
`AppShimmer`, `SkeletonBox`, `ExpandableText`, `CastList`, `TmdbAttribution`.

### Keputusan desain
Semua nilai desain dipusatkan di `lib/core/theme/` (tidak ada warna/ukuran yang di-hardcode di widget).

| Aspek | Keputusan | File |
|-------|-----------|------|
| Mode | Dark theme (nyaman untuk aplikasi film, poster lebih menonjol) | `app_theme.dart` |
| Latar | `#0E0F14` (hitam kebiruan), permukaan kartu `#181A21`, varian `#242731` | `app_colors.dart` |
| Warna aksen (satu) | Oranye `#FF6B3D`, dipakai untuk tombol, chip aktif, bintang rating, indikator, garis judul section | `app_colors.dart` |
| Teks | Utama `#F5F6FA`, sekunder `#A3A6B4`, redup `#6C6F7D` | `app_colors.dart` |
| Tipografi | Poppins (Google Fonts): judul tebal w700-w800, body w400 dengan line-height 1.6 | `app_text_styles.dart` |
| Radius | Poster/kartu 14, carousel 20, chip/pil 100 (bulat penuh) | `app_dimens.dart` |
| Poster | Rasio 2:3 (mengikuti TMDB), lebar 128 di list horizontal, grid 3 kolom | `app_dimens.dart` |
| Loading | Skeleton shimmer berbentuk sama dengan konten asli | `widgets/shimmer_loading.dart` |
| Gambar di atas teks | Gradien gelap (`imageScrim`) agar judul tetap terbaca | `app_colors.dart` |

### Hubungan dengan desain referensi
- Referensi: shot Dribbble "Movie Streaming App" oleh joe.nakul
  (https://dribbble.com/shots/15473335-Movie-Streaming-App), alternatif "CineMe"
  (https://dribbble.com/shots/9091818-CineMe-mobile-app-for-movies-and-tv-shows).
- Yang diadaptasi: arah visual aplikasi streaming bergaya dark mode, poster besar bersudut membulat,
  banner film unggulan di bagian atas, chip kategori horizontal, satu warna aksen, judul tebal,
  dan bottom navigation.
- Yang tidak disalin: logo, nama, dan aset gambar. Nama aplikasi tetap CineDex, warna aksen dan
  komposisi ditentukan sendiri. Semua gambar film berasal dari TMDB.
- Tidak ada file screenshot referensi di `docs/design-reference/`, sehingga detail (warna aksen,
  ukuran kartu) diputuskan sendiri seperti pada tabel di atas.

### Daftar screenshot
Screenshot hasil uji di emulator sudah tersedia di `docs/screenshots/` (boleh diganti dengan tangkapan layar sendiri):

| File | Isi | Untuk |
|------|-----|-------|
| `home.png` | Beranda: carousel, chip genre, section Populer & Top Rated | 2.2 |
| `home_genre.png` | Beranda setelah memilih chip genre "Aksi" (grid hasil discover) | 2.2 / 2.3 |
| `detail.png` | Detail film: backdrop, poster, rating bintang, durasi, tanggal, genre, tombol trailer | 2.2 / 2.3 |
| `detail_cast.png` | Detail: sinopsis di-expand, daftar pemeran, atribusi TMDB | 2.2 |
| `search.png` | Hasil pencarian "interstellar" | 2.2 |
| `search_empty.png` | State awal pencarian (belum mengetik) | 2.2 |
| `search_not_found.png` | State tidak ada hasil | 2.2 |
| `error_offline.png` | Error tanpa koneksi internet | 2.2 / 2.3 |
| `error_token.png` | Error token TMDB belum diatur | 2.1 |

Yang masih perlu diambil sendiri (disarankan):
- `loading.png`: shimmer di Beranda. Cara: buka aplikasi lalu langsung screenshot saat memuat
  (atau aktifkan mode pesawat, buka aplikasi, matikan mode pesawat, lalu tekan "Coba Lagi").
- `about.png`: halaman Tentang (ikon ⓘ di kanan atas Beranda).
- `trailer.png` (opsional): YouTube terbuka setelah menekan "Tonton Trailer".

---

## Untuk 2.3: Pengambilan dan Pengolahan Data

### Tabel endpoint
Base URL: `https://api.themoviedb.org/3`. Semua request memakai header
`Authorization: Bearer <TMDB_READ_TOKEN>` dan parameter `language=id-ID`.

| No | Method | Endpoint | Parameter tambahan | Fungsi di aplikasi |
|----|--------|----------|--------------------|--------------------|
| 1 | GET | `/movie/now_playing` | - | 5 film pertama untuk hero carousel |
| 2 | GET | `/movie/popular` | - | Section "Populer" |
| 3 | GET | `/movie/top_rated` | - | Section "Top Rated" |
| 4 | GET | `/movie/upcoming` | - | Section "Akan Tayang" |
| 5 | GET | `/genre/movie/list` | - | Daftar chip genre + pemetaan id genre → nama |
| 6 | GET | `/discover/movie` | `with_genres`, `sort_by=popularity.desc`, `include_adult=false` | Filter film per genre |
| 7 | GET | `/search/movie` | `query`, `include_adult=false` | Pencarian judul |
| 8 | GET | `/movie/{id}` | (`language=en-US` sebagai cadangan) | Detail: runtime, tagline, genre lengkap |
| 9 | GET | `/movie/{id}/credits` | - | Daftar pemeran |
| 10 | GET | `/movie/{id}/videos` | (`language=en-US` sebagai cadangan) | Mencari trailer YouTube |

Gambar: `https://image.tmdb.org/t/p/{size}{path}`, dengan ukuran poster `w342`/`w500`,
backdrop `w780`, dan foto pemeran `w185`.

### Contoh response JSON (field yang dipakai saja)
`GET /movie/popular?language=id-ID`
```json
{
  "page": 1,
  "results": [
    {
      "id": 969681,
      "title": "Spider-Man: Brand New Day",
      "overview": "Empat tahun setelah peristiwa Spider-Man: No Way Home, ...",
      "poster_path": "/bjiS5ipwxb9JFy3XRRN4OAilSeX.jpg",
      "backdrop_path": "/4tjxYg2AbOzzG9G1YuiT2NzYhlH.jpg",
      "vote_average": 8.467,
      "vote_count": 5604,
      "release_date": "2026-07-29",
      "genre_ids": [878, 28, 12]
    }
  ],
  "total_pages": 1001
}
```

`GET /movie/969681?language=id-ID` (perhatikan `tagline` kosong untuk bahasa Indonesia)
```json
{
  "id": 969681,
  "title": "Spider-Man: Brand New Day",
  "tagline": "",
  "runtime": 145,
  "release_date": "2026-07-29",
  "vote_average": 8.468,
  "genres": [
    { "id": 878, "name": "Cerita Fiksi" },
    { "id": 28, "name": "Aksi" },
    { "id": 12, "name": "Petualangan" }
  ]
}
```

`GET /genre/movie/list?language=id-ID`
```json
{ "genres": [ { "id": 28, "name": "Aksi" }, { "id": 12, "name": "Petualangan" }, { "id": 16, "name": "Animasi" } ] }
```

`GET /movie/969681/credits` (elemen pertama array `cast`)
```json
{ "id": 1136406, "name": "Tom Holland", "character": "Peter Parker / Spider-Man",
  "profile_path": "/adwEBb2sCSzqwnpVgNEG7irl1Ne.jpg", "order": 0 }
```

`GET /movie/969681/videos?language=en-US` (elemen pertama array `results`, ternyata Teaser, bukan Trailer)
```json
{ "key": "lS6TdzVVusY", "name": "The World Is Grey", "site": "YouTube", "type": "Teaser", "official": true }
```

### Potongan kode service: `lib/data/services/tmdb_service.dart`
Semua request melewati satu method `_get` yang menambahkan token, bahasa, timeout 15 detik,
dan memetakan semua kegagalan ke exception sendiri.
```dart
Future<Map<String, dynamic>> _get(
  String path, {
  Map<String, String> query = const {},
  String language = ApiConstants.language,
}) async {
  if (_token.isEmpty) throw const MissingTokenException();

  final uri = Uri.parse(
    '${ApiConstants.baseUrl}$path',
  ).replace(queryParameters: {'language': language, ...query});

  final http.Response response;
  try {
    response = await _client
        .get(
          uri,
          headers: {
            'Authorization': 'Bearer $_token',
            'Accept': 'application/json',
          },
        )
        .timeout(ApiConstants.timeout);
  } on SocketException {
    throw const NoInternetException();
  } on TimeoutException {
    throw const RequestTimeoutException();
  } on http.ClientException {
    throw const NoInternetException();
  }

  if (response.statusCode != 200) {
    throw ServerException.fromStatus(response.statusCode);
  }

  try {
    // Decode manual sebagai UTF-8 agar karakter non-ASCII tidak rusak.
    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    return decoded as Map<String, dynamic>;
  } catch (_) {
    throw const ParsingException();
  }
}
```

Pemetaan error (`lib/data/services/api_exception.dart`):
| Kondisi | Exception | Pesan di layar |
|---------|-----------|----------------|
| Tidak ada internet / host tidak ditemukan | `NoInternetException` | "Tidak ada koneksi internet. Periksa jaringanmu lalu coba lagi." |
| Lebih dari 15 detik | `RequestTimeoutException` | "Server terlalu lama merespons. Silakan coba lagi." |
| Status 401 | `ServerException` | "Token TMDB tidak valid. Periksa isi file .env." |
| Status 404 / 429 / 5xx / lainnya | `ServerException` | Pesan sesuai kode status |
| JSON tidak sesuai | `ParsingException` | "Data dari server tidak dapat dibaca." |
| Token kosong | `MissingTokenException` | "Token TMDB belum diatur. ..." |

### Potongan kode model: `lib/data/models/movie.dart`
```dart
factory Movie.fromJson(Map<String, dynamic> json) {
  return Movie(
    id: (json['id'] as num?)?.toInt() ?? 0,
    title:
        (json['title'] as String?) ??
        (json['original_title'] as String?) ??
        'Tanpa Judul',
    overview: (json['overview'] as String?)?.trim() ?? '',
    posterPath: json['poster_path'] as String?,
    backdropPath: json['backdrop_path'] as String?,
    voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0,
    voteCount: (json['vote_count'] as num?)?.toInt() ?? 0,
    releaseDate: json['release_date'] as String?,
    genreIds: (json['genre_ids'] as List<dynamic>? ?? const [])
        .whereType<num>()
        .map((e) => e.toInt())
        .toList(),
  );
}
```
Setiap field memakai tipe nullable (`as String?`, `as num?`) lalu diberi nilai default dengan `??`,
sehingga aplikasi tidak crash jika TMDB mengirim `null` atau field tidak ada.
`vote_average` dibaca sebagai `num` karena TMDB kadang mengirim bilangan bulat (misal `8`) dan kadang desimal (`8.467`).

### Potongan kode provider: `lib/providers/home_provider.dart`
```dart
Future<void> loadHome() async {
  status = LoadStatus.loading;
  error = null;
  notifyListeners();

  try {
    await _fetchAll();
    status = LoadStatus.success;
  } catch (e) {
    error = UiError.from(e);
    status = LoadStatus.error;
  }
  notifyListeners();
}

Future<void> _fetchAll({bool forceRefresh = false}) async {
  final results = await Future.wait([
    _repository.getNowPlaying(),
    _repository.getPopular(),
    _repository.getTopRated(),
    _repository.getUpcoming(),
  ]);
  genres = await _repository.getGenres(forceRefresh: forceRefresh);
  nowPlaying = results[0];
  popular = results[1];
  topRated = results[2];
  upcoming = results[3];
}
```
`Future.wait` menjalankan 4 request secara paralel sehingga Beranda lebih cepat dimuat
dibandingkan memanggilnya satu per satu.

Debounce pencarian (`lib/providers/search_provider.dart`):
```dart
void onQueryChanged(String value) {
  final trimmed = value.trim();
  _debounce?.cancel();
  if (trimmed == _query && status != LoadStatus.error) return;
  _query = trimmed;

  if (trimmed.isEmpty) {
    _requestId++;
    status = LoadStatus.initial;
    results = const [];
    error = null;
    notifyListeners();
    return;
  }

  _debounce = Timer(debounceDuration, () => _search(trimmed));
}
```
Setiap huruf yang diketik membatalkan timer sebelumnya. Request baru dikirim hanya jika pengguna
berhenti mengetik selama 500 ms. `_requestId` memastikan hasil dari kata kunci lama
(yang datang terlambat) tidak menimpa hasil kata kunci terbaru.

### Alur data dari API sampai tampil di layar
```
[Pengguna membuka Beranda]
        │
        ▼
HomeScreen  ── context.watch<HomeProvider>() ──►  menampilkan sesuai status
        │                                          (loading → shimmer, error → ErrorView,
        │                                           success → carousel + section)
        ▼
HomeProvider.loadHome()   status = loading → notifyListeners()
        │
        ▼
MovieRepository.getPopular()  dll.   ← pengolahan: filter poster, mapping genre, fallback, dll
        │
        ▼
TmdbService.fetchPopular() → _get('/movie/popular')
        │   header Bearer token, language=id-ID, timeout 15 detik
        ▼
TMDB API  ──► JSON
        │
        ▼
jsonDecode → Movie.fromJson (model Dart null-safe)
        │
        ▼
kembali ke HomeProvider: status = success → notifyListeners()
        │
        ▼
Widget dibangun ulang otomatis → MovieCard menampilkan poster (cached_network_image),
judul, tahun, dan rating bintang (Formatters)
```

### Penjelasan tiap langkah pengolahan data

**1. Parsing JSON ke model Dart null-safe**
File: `lib/data/models/*.dart`. Kelas `Movie`, `MovieDetail`, `Genre`, `CastMember`, `Video` masing-masing
punya factory `fromJson`. Lihat potongan `Movie.fromJson` di atas.

**2. Konversi `genre_ids` ke nama genre**
File: `lib/core/utils/movie_utils.dart` + `lib/data/repositories/movie_repository.dart`.
Daftar genre diambil sekali dari `/genre/movie/list`, disimpan sebagai `Map<int, String>`, lalu dipakai untuk
mengubah `[878, 28, 12]` menjadi `["Cerita Fiksi", "Aksi", "Petualangan"]` (tampil di carousel).
```dart
static List<String> mapGenreNames(
  List<int> genreIds,
  Map<int, String> genreMap,
) {
  return genreIds.map((id) => genreMap[id]).whereType<String>().toList();
}
```

**3. Rating 0-10 ke bintang 0-5 (1 desimal)**
File: `lib/core/utils/formatters.dart`. Contoh: `8.467 / 2 = 4.23` → ditampilkan `"4.2"` dan 4 bintang + 1 bintang kosong
(widget `StarRating` memakai bintang penuh, setengah, dan kosong).
```dart
static double toStarScale(double voteAverage) {
  return (voteAverage / 2).clamp(0, 5).toDouble();
}

static String formatStarRating(double voteAverage) {
  return toStarScale(voteAverage).toStringAsFixed(1);
}
```

**4. Durasi menit ke "2j 15m"**
File: `lib/core/utils/formatters.dart`. Contoh: `runtime: 145` → `"2j 25m"`, `120` → `"2j"`, `45` → `"45m"`, `null` → `"-"`.
```dart
static String formatRuntime(int? minutes) {
  if (minutes == null || minutes <= 0) return '-';
  final hours = minutes ~/ 60;
  final mins = minutes % 60;
  if (hours == 0) return '${mins}m';
  if (mins == 0) return '${hours}j';
  return '${hours}j ${mins}m';
}
```

**5. Tanggal rilis ke format Indonesia**
File: `lib/core/utils/formatters.dart`. Contoh: `"2026-07-29"` → `"29 Juli 2026"`.
Data locale diinisialisasi di `main.dart` dengan `await initializeDateFormatting('id_ID');`.
```dart
static String formatReleaseDate(String? rawDate) {
  final date = DateTime.tryParse(rawDate ?? '');
  if (date == null) return 'Belum diketahui';
  return DateFormat('d MMMM y', 'id_ID').format(date);
}
```

**6. Film tanpa poster / tanpa sinopsis**
- Daftar Beranda dan filter genre: film tanpa poster (dan duplikat) disaring
  (`MovieUtils.filterDisplayable`).
- Hasil pencarian: film tanpa poster tetap ditampilkan dengan gambar cadangan (ikon film), agar film
  yang dicari tetap bisa ditemukan.
- Detail: jika `overview` atau `tagline` bahasa Indonesia kosong, detail diambil ulang dengan `en-US`.
  Contoh nyata: tagline Spider-Man: Brand New Day kosong di id-ID, lalu terisi "A brand new day starts now." dari en-US.
  Jika en-US juga kosong, tampil "Sinopsis belum tersedia untuk film ini."
```dart
// lib/data/repositories/movie_repository.dart
Future<MovieDetail> getMovieDetail(int id) async {
  final detail = await _service.fetchMovieDetail(id);
  if (detail.overview.isNotEmpty && detail.tagline.isNotEmpty) return detail;

  try {
    final english = await _service.fetchMovieDetail(
      id,
      language: ApiConstants.fallbackLanguage,
    );
    return detail.copyWith(
      overview: detail.overview.isEmpty ? english.overview : null,
      tagline: detail.tagline.isEmpty ? english.tagline : null,
    );
  } catch (_) {
    // Fallback bersifat opsional: kalau gagal, tetap pakai data id-ID.
    return detail;
  }
}
```

**7. Memilih trailer**
File: `lib/core/utils/movie_utils.dart`. Hanya video YouTube; urutan prioritas: Trailer resmi →
Trailer → Teaser resmi → Teaser. Karena video berbahasa Indonesia jarang ada, jika tidak ditemukan
di `id-ID` repository mencari ulang di `en-US`. Jika tetap tidak ada, tombol menjadi
"Trailer Tidak Tersedia" (nonaktif).
```dart
static Video? pickTrailer(List<Video> videos) {
  final youtube = videos.where((v) => v.isYouTube).toList();

  Video? firstWhere(bool Function(Video v) test) {
    for (final v in youtube) {
      if (test(v)) return v;
    }
    return null;
  }

  return firstWhere((v) => v.type == 'Trailer' && v.official) ??
      firstWhere((v) => v.type == 'Trailer') ??
      firstWhere((v) => v.type == 'Teaser' && v.official) ??
      firstWhere((v) => v.type == 'Teaser');
}
```

**8. Cast 10 teratas diurutkan berdasarkan `order`**
File: `lib/core/utils/movie_utils.dart`.
```dart
static List<CastMember> topCast(List<CastMember> cast, {int limit = 10}) {
  final sorted = [...cast]..sort((a, b) => a.order.compareTo(b.order));
  return sorted.take(limit).toList();
}
```

### Pengujian
- `flutter analyze`: tidak ada issue.
- `flutter test`: 15 test lulus.
  | File test | Yang diuji |
  |-----------|------------|
  | `test/formatters_test.dart` | Konversi rating, format durasi, tanggal Indonesia, jumlah vote |
  | `test/models_test.dart` | `fromJson` semua model, termasuk field null/hilang |
  | `test/movie_utils_test.dart` | Mapping genre, filter poster & duplikat, pemilihan trailer, top cast |
  | `test/tmdb_service_test.dart` | Header Bearer + `language=id-ID`, pemetaan error (offline, 401, JSON rusak, token kosong) memakai `MockClient` |
  | `test/search_provider_test.dart` | Debounce: 3 ketikan cepat hanya memicu 1 request |
- Uji manual di emulator Pixel 5 (Android 11): buka Beranda → pilih genre "Aksi" → buka Detail →
  expand sinopsis → Tonton Trailer (aplikasi YouTube terbuka) → kembali → Cari "interstellar" →
  cari kata acak (tidak ditemukan). Tidak ada crash maupun error/overflow di log.
  State error token kosong dan tanpa internet juga sudah dicoba.

---

## Untuk 3.1 dan 3.2: Kendala, Kekurangan, dan Pengembangan

### Kendala yang ditemui dan solusinya
| No | Kendala | Solusi |
|----|---------|--------|
| 1 | Build Android gagal: `Could not close incremental caches` saat mengompilasi plugin `url_launcher_android`. Penyebabnya, project berada di drive `D:` sedangkan cache package (pub cache) di drive `C:`, sehingga incremental compile Kotlin gagal. | Menambahkan `kotlin.incremental=false` di `android/gradle.properties`. |
| 2 | Token API tidak boleh ikut ter-upload karena repository public. | Token disimpan di `.env` (dibaca `flutter_dotenv`), `.env` masuk `.gitignore`, disediakan `.env.example`, dan dicek dengan `git ls-files`. |
| 3 | Banyak film tidak punya sinopsis/tagline bahasa Indonesia, dan trailer berbahasa Indonesia hampir tidak ada. | Fallback otomatis ke `en-US` untuk detail dan daftar video. |
| 4 | (Diantisipasi saat desain) Film yang sama bisa muncul di beberapa section (misal Populer dan Akan Tayang). Jika tag `Hero` hanya memakai id film, Flutter akan error karena ada dua Hero dengan tag yang sama di satu layar. | Tag Hero diberi awalan per section, misal `popular-969681`, `search-969681`. |
| 5 | Saat mengetik cepat, request lama bisa selesai belakangan dan menimpa hasil terbaru. | Debounce 500 ms + penanda `_requestId` agar hasil lama diabaikan. |
| 6 | Kartu poster di list horizontal overflow 1 piksel karena tinggi list terlalu pas dengan teks judul dan tahun. | Tinggi list dipusatkan di `AppSizes.sectionListHeight` dengan ruang cadangan. |
| 7 | Saat pengujian, emulator kehilangan koneksi DNS (aplikasi menampilkan layar offline). | Emulator di-restart dengan `-dns-server 8.8.8.8`. Kejadian ini sekaligus membuktikan state offline bekerja. |

### Kekurangan aplikasi
- Daftar film hanya memuat halaman pertama dari API (20 film per daftar), belum ada infinite scroll / pagination.
- Belum ada fitur favorit atau watchlist, dan data belum disimpan secara offline (tanpa internet hanya muncul pesan error).
- Font Poppins diunduh saat runtime oleh `google_fonts`, jadi saat pertama kali dibuka tanpa internet
  aplikasi memakai font bawaan.
- Token TMDB ikut dibundel sebagai asset di dalam APK (keterbatasan `flutter_dotenv`). Untuk aplikasi produksi
  sebaiknya request lewat server perantara (backend/proxy).
- Hanya mendukung film (belum serial TV) dan hanya Android.
- Antarmuka hanya berbahasa Indonesia, dan sebagian data (tagline/trailer) tetap berbahasa Inggris karena keterbatasan data TMDB.

### Ide pengembangan lanjutan
- Favorit / watchlist lokal (misalnya memakai `shared_preferences`, `hive`, atau `sqflite`).
- Login akun TMDB untuk memberi rating dan menyinkronkan watchlist.
- Infinite scroll (pagination) di section dan hasil pencarian.
- Serial TV (`/tv/...`), halaman detail aktor, dan rekomendasi film serupa (`/movie/{id}/recommendations`).
- Filter lanjutan: tahun rilis, urutan (rating/terbaru), rating minimal.
- Cache data offline sehingga Beranda tetap tampil tanpa internet.
- Bundle font secara lokal dan dukungan light mode.
- Pemutar trailer di dalam aplikasi (misalnya `youtube_player_flutter`).
