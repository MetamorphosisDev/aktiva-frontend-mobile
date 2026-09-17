# AKTIVA

**Aplikasi Blog Berbasis Mobile**

AKTIVA adalah aplikasi blog berbasis mobile yang dibangun menggunakan Flutter dan Dart. Aplikasi ini digunakan untuk membaca, menulis, dan mengelola artikel langsung dari perangkat mobile.

Aplikasi berjalan sebagai *client* yang berkomunikasi dengan REST API untuk menangani data artikel, kategori, komentar, bookmark, profil pengguna, serta autentikasi berbasis JWT.

---

## Tentang Project

AKTIVA dibuat sebagai frontend mobile untuk sebuah platform blog. Pengguna dapat membuat akun, masuk ke aplikasi, membaca artikel yang sudah dipublikasikan, menyimpan artikel untuk dibaca nanti, berkomentar, dan mengelola artikel miliknya sendiri.

Project ini dibangun dengan pendekatan *client-server*: aplikasi Flutter tidak menyimpan data artikel secara lokal, melainkan mengambil dan mengirim data ke backend melalui REST API. Data yang disimpan di perangkat hanya token autentikasi, supaya sesi pengguna tetap aktif saat aplikasi dibuka kembali.

Repository ini hanya mencakup sisi mobile/Frontend. Backend REST API berada di luar repository ini dan harus berjalan terpisah.

---

## Fitur

### Autentikasi

- Register dua tahap: data akun (nama, email, nomor telepon) lalu password, dengan validasi password minimal 8 karakter dan konfirmasi password.
- Login menggunakan email dan password.
- Penyimpanan token JWT secara lokal di perangkat.
- Pemeriksaan sesi saat aplikasi dibuka: jika token tersedia pengguna langsung diarahkan ke beranda, jika tidak diarahkan ke halaman login.

### Artikel

- Beranda menampilkan artikel berstatus `published` dalam grid dua kolom.
- Pencarian artikel berdasarkan judul, ringkasan, dan kategori.
- Filter kategori pada beranda.
- Pull-to-refresh untuk memuat ulang daftar artikel.
- Halaman detail artikel: cover, kategori, judul, penulis, tanggal, ringkasan, isi, lokasi, sumber, dan galeri gambar.
- Halaman "My Posts" berisi daftar artikel dengan aksi Edit dan Hapus (dengan dialog konfirmasi), serta badge status Draft/Published.
- Membuat artikel baru, termasuk memilih gambar sampul dari galeri dan memilih kategori dari API.
- Mengedit artikel yang sudah ada.

### Bookmark

- Menyimpan artikel dari halaman detail.
- Halaman Bookmarks menampilkan daftar artikel yang disimpan.
- Menghapus bookmark dari halaman detail maupun dari daftar bookmark.
- Status bookmark artikel ditandai otomatis saat halaman detail dibuka.

### Komentar

- Menampilkan daftar komentar pada halaman detail artikel.
- Menambahkan komentar baru.
- Menghapus komentar milik sendiri; kepemilikan diambil dari klaim `id` pada payload JWT.

### Profil

- Menampilkan data profil pengguna (nama, email, nomor telepon).
- Memperbarui data profil.
- Menghapus akun pengguna.

---

## Tech Stack

| Teknologi | Kegunaan |
| --- | --- |
| Flutter | Framework aplikasi mobile |
| Dart | Bahasa pemrograman (SDK `^3.12.2`) |
| REST API | Komunikasi data dengan backend |
| JWT | Autentikasi pengguna |
| `http` | HTTP client untuk request ke REST API |
| `shared_preferences` | Penyimpanan token JWT secara lokal |
| `image_picker` | Memilih gambar sampul dari galeri |
| `google_fonts` | Font Plus Jakarta Sans |
| `google_nav_bar` | Bottom navigation bar |
| `cupertino_icons` | Ikon bergaya iOS |

State management menggunakan `StatefulWidget` dan `setState` bawaan Flutter. Tidak ada package state management tambahan pada project ini.

`flutter_floating_bottom_bar` tercatat sebagai dependency di `pubspec.yaml`, namun belum direferensikan di dalam `lib/`.

---

## Struktur Project

```text
lib/
├── main.dart                       # Entry point + MaterialApp
├── auth.dart                       # AuthCheck: pemeriksaan token saat startup
├── components/
│   ├── bottom_navbar.dart          # Bottom navigation (Beranda, Tersimpan, Postingan, Profil)
│   ├── comments/
│   │   ├── comment_item.dart       # Item komentar
│   │   └── comment_section.dart    # Daftar + form komentar
│   └── ui/
│       └── app_ui.dart             # Komponen UI reusable (button, field, tag, empty state, dll)
├── config/
│   └── api_config.dart             # Base URL REST API
├── pages/
│   ├── auth/
│   │   ├── login_page.dart
│   │   ├── register_page.dart
│   │   └── register_password.dart
│   ├── book/
│   │   └── bookmarks_page.dart
│   ├── mypost/
│   │   ├── mypost_page.dart
│   │   ├── addpost/
│   │   │   └── addpost_page.dart
│   │   └── editpost/
│   │       └── editpost_page.dart
│   ├── posts/
│   │   ├── posts_page.dart
│   │   └── post_detail_page.dart
│   └── profile/
│       └── profile_page.dart
├── services/
│   ├── api_service.dart            # Helper HTTP GET/DELETE/POST + penyisipan token
│   ├── auth.service.dart           # Login & register
│   ├── bookmarks_service.dart      # CRUD bookmark
│   ├── categories_service.dart     # Daftar kategori
│   ├── comment_service.dart        # CRUD komentar
│   ├── post_service.dart           # CRUD artikel + upload gambar
│   ├── profile_service.dart        # Profil pengguna
│   └── token_storage.dart          # Simpan/ambil/hapus token
└── theme/
    └── app_theme.dart              # Warna, spacing, radius, dan tipografi aplikasi
```

Keterangan folder utama:

```text
pages/       → Halaman/screen aplikasi, dikelompokkan per fitur
services/    → Komunikasi dengan REST API dan penyimpanan token
components/  → Widget reusable, termasuk komponen UI dan komentar
config/      → Konfigurasi aplikasi (base URL API)
theme/       → Design token aplikasi (warna, spacing, tipografi)
```

Project ini belum memiliki folder `models/`. Data dari API digunakan langsung sebagai `Map`/`List` dinamis, bukan melalui class model.

---

## Arsitektur

Aplikasi Flutter bertindak sebagai client yang mengirim HTTP request ke REST API dan menampilkan hasilnya ke pengguna.

```text
┌─────────────────────────┐
│     Flutter Mobile      │
│         AKTIVA          │
└───────────┬─────────────┘
            │  HTTP / REST API  (Authorization: Bearer <token>)
            ▼
┌─────────────────────────┐
│      Backend API        │
└───────────┬─────────────┘
            │
            ▼
┌─────────────────────────┐
│        Database         │
└─────────────────────────┘
```

Alur request pada sisi mobile:

1. Halaman memanggil service terkait (misalnya `PostService`).
2. Service memanggil `ApiService` (`get`, `post`, `delete`) atau `http` langsung untuk kebutuhan khusus seperti upload multipart.
3. `ApiService` mengambil token dari `TokenStorage` dan menambahkan header `Authorization: Bearer <token>`.
4. Response JSON di-parse, field `data` dikembalikan ke halaman, dan field `message` dipakai sebagai pesan error.

---

## Authentication

Autentikasi menggunakan JWT dengan alur sebagai berikut:

1. Pengguna melakukan register atau login dari aplikasi.
2. Backend mengembalikan token pada response login (`token`).
3. Aplikasi menyimpan token tersebut di perangkat melalui `TokenStorage`.
4. Setiap request yang membutuhkan autentikasi menyertakan token pada header.
5. Saat aplikasi dibuka, `AuthCheck` membaca token: jika ada, pengguna diarahkan ke beranda; jika tidak, ke halaman login.

Format header yang digunakan:

```http
Authorization: Bearer <token>
```

Endpoint login dan register dipanggil tanpa header autentikasi. Endpoint lain (artikel, bookmark, komentar, profil) menggunakan header di atas.

Untuk menentukan kepemilikan komentar, aplikasi membaca payload JWT dan mengambil klaim `id` pengguna. Aplikasi tidak memverifikasi signature token; verifikasi tetap dilakukan oleh backend.

> Catatan: belum ada fitur logout pada UI. Method `TokenStorage.deleteToken()` sudah tersedia pada service, tetapi belum dipanggil dari halaman mana pun.

---

## API Integration

Seluruh komunikasi data ditangani oleh `ApiService` dan service per fitur. Base URL aplikasi didefinisikan pada `lib/config/api_config.dart` sebagai `ApiConfig.baseUrl`, dan setiap endpoint ditambahkan sebagai path relatif terhadap base URL tersebut.

Beberapa hal yang perlu diketahui saat membaca layer ini:

- `ApiService.get()` menganggap status `200` sebagai sukses dan mengembalikan field `data` dari body JSON.
- `ApiService.post()` dan `ApiService.delete()` dianggap sukses pada status `200`, `201`, atau `204`.
- Error dari backend diambil dari field `message` dan dilempar sebagai `Exception`.
- Upload gambar sampul menggunakan `MultipartRequest` dengan field `coverImage`, karena endpoint artikel menerima `multipart/form-data`.

### Endpoint yang digunakan

| Method | Endpoint | Fungsi |
| --- | --- | --- |
| POST | `/auth/register` | Registrasi pengguna baru |
| POST | `/auth/login` | Login dan memperoleh token |
| GET | `/auth/profile` | Mengambil data profil |
| PATCH | `/auth/profile` | Memperbarui data profil |
| DELETE | `/auth/profile` | Menghapus akun |
| GET | `/posts` | Mengambil daftar artikel |
| GET | `/posts/:id` | Mengambil detail artikel |
| POST | `/posts` | Membuat artikel (multipart) |
| PATCH | `/posts/:id` | Mengubah artikel (multipart) |
| DELETE | `/posts/:id` | Menghapus artikel |
| GET | `/categories` | Mengambil daftar kategori |
| GET | `/bookmarks` | Mengambil daftar bookmark |
| POST | `/bookmarks/:postId` | Menambahkan bookmark |
| DELETE | `/bookmarks/:postId` | Menghapus bookmark |
| GET | `/comments/post/:postId` | Mengambil komentar sebuah artikel |
| POST | `/comments/post/:postId` | Menambahkan komentar |
| DELETE | `/comments/:id` | Menghapus komentar |

Semua path di atas bersifat relatif terhadap `ApiConfig.baseUrl`.

---

## Token Storage

Token autentikasi disimpan secara lokal menggunakan `shared_preferences` melalui class `TokenStorage`, sehingga sesi pengguna tetap bertahan ketika aplikasi ditutup dan dibuka kembali.

Kunci penyimpanan yang digunakan:

```text
jwt_token
```

`TokenStorage` menyediakan tiga operasi: `saveToken`, `getToken`, dan `deleteToken`.

---

## Search & Filter

Pencarian dan filter artikel dilakukan di sisi client pada halaman beranda:

- **Pencarian** — mencocokkan kata kunci dengan judul, ringkasan, dan kategori artikel (tidak case-sensitive).
- **Filter kategori** — memilih salah satu kategori yang tersedia pada chip di beranda.

Daftar chip kategori di beranda didefinisikan langsung di `posts_page.dart` (Semua, Teknologi, Pertanian, Pendidikan, Kesehatan, Bisnis), sedangkan halaman tambah/edit artikel mengambil daftar kategori dari endpoint `GET /categories`.

---

## Alur Aplikasi

```text
Register (data akun → password)
        ↓
      Login
        ↓
  Token disimpan
        ↓
   Beranda (Posts)
        ↓
  Detail Artikel ──── Tambah / Edit / Hapus Artikel
        │                    (via halaman Postingan)
        ├── Bookmark artikel ──→ Halaman Tersimpan
        └── Komentar (tambah/hapus)
        ↓
      Profil (edit profil / hapus akun)
```

Saat aplikasi dibuka kembali dengan token yang masih tersimpan, pengguna langsung masuk ke beranda tanpa melalui halaman login.

---

## Requirements

- Flutter SDK (channel stable) dengan Dart SDK `^3.12.2`
- Android SDK, emulator, atau perangkat Android untuk menjalankan versi Android
- Xcode dan macOS apabila ingin menjalankan versi iOS
- Backend AKTIVA REST API yang berjalan dan dapat diakses dari perangkat
- Koneksi internet (untuk request API, memuat gambar, dan mengunduh font dari `google_fonts`)

---

## Instalasi

```bash
git clone https://github.com/MetamorphosisDev/aktiva-frontend-mobile.git
cd aktiva-frontend-mobile
flutter pub get
```

---

## Konfigurasi

Konfigurasi API dilakukan pada satu file:

```text
lib/config/api_config.dart
```

```dart
class ApiConfig {
  static const String baseUrl = 'https://<backend-host>/api';
}
```

Ubah nilai `baseUrl` agar mengarah ke alamat backend yang sedang digunakan, dengan format berakhiran `/api`.

Nilai yang ada di repository saat ini mengarah ke sebuah URL development tunnel (devtunnels). URL seperti ini bersifat sementara dan hanya aktif selama tunnel dijalankan, jadi ganti dengan alamat backend milikmu sebelum menjalankan aplikasi.

Project ini tidak menggunakan file `.env` maupun environment variable. Seluruh konfigurasi endpoint berada pada `ApiConfig`.

---

## Menjalankan Aplikasi

```bash
flutter pub get
flutter run
```

Untuk memilih perangkat tertentu:

```bash
flutter devices
flutter run -d <device-id>
```

Pastikan backend sudah berjalan dan `ApiConfig.baseUrl` sudah mengarah ke backend tersebut, karena aplikasi tidak menyediakan data lokal.

---

## Build APK

```bash
flutter build apk --release
```

Hasil build default berada di:

```text
build/app/outputs/flutter-apk/app-release.apk
```

Untuk format App Bundle:

```bash
flutter build appbundle --release
```

Belum ada file APK yang disertakan di dalam repository ini; APK perlu dibangun sendiri dari source code.

---

## Testing

Repository ini belum memiliki automated testing yang mencerminkan aplikasi. Satu-satunya file test adalah `test/widget_test.dart` yang masih berupa template bawaan Flutter dan menguji widget counter yang tidak ada di aplikasi.

Perintah test tetap dapat dijalankan, tetapi belum ada test yang relevan dengan fitur AKTIVA:

```bash
flutter test
```

---

## Troubleshooting

### Dependency bermasalah atau build gagal

```bash
flutter clean
flutter pub get
```

### Perangkat/emulator tidak terdeteksi

```bash
flutter devices
```

Pastikan emulator sudah berjalan atau perangkat sudah mengaktifkan USB debugging.

### Data tidak muncul atau API tidak dapat diakses

Periksa hal berikut:

- Backend sedang berjalan dan dapat diakses.
- Nilai `ApiConfig.baseUrl` sudah benar dan mengarah ke backend yang aktif.
- Perangkat memiliki koneksi internet dan dapat menjangkau host backend.
- Token masih valid. Jika token sudah kedaluwarsa, aplikasi perlu login ulang.
- Jika memakai tunnel development, pastikan tunnel masih aktif karena URL-nya berubah ketika tunnel dijalankan ulang.

### Gambar sampul tidak tampil

Gambar dimuat dari URL yang dikembalikan API. Jika URL tidak valid atau tidak dapat diakses, aplikasi akan menampilkan placeholder gambar.

---

## Status Project

**Active Development.**

Kondisi saat ini:

- Fitur autentikasi, artikel, bookmark, komentar, dan profil sudah terimplementasi.
- Aplikasi bergantung penuh pada backend REST API dan belum bisa digunakan tanpa backend.
- Belum ada automated testing yang relevan.
- Identifier platform masih menggunakan nilai bawaan template Flutter:
  - Package Dart: `mobile`
  - Android `applicationId`/`namespace`: `com.example.mobile`
  - Label Android/iOS: `mobile` / `Mobile`

---

## Dokumentasi Tambahan

Panduan penulisan commit untuk repository ini tersedia di:

```text
docs/CONVENTIONAL_COMMITS.md
```

---

## Author

**Jona Al Farros** — [github.com/MetamorphosisDev](https://github.com/MetamorphosisDev)

---

## Lisensi

Repository ini tidak menyertakan file LICENSE, sehingga belum ada lisensi resmi yang ditetapkan untuk project ini.
