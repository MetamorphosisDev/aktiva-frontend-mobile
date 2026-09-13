# Conventional Commit Types

Format dasar:

<type>: <description>

---

## Types

| Type | Kapan Dipakai |
|------|---------------|
| `feat` | Menambah fitur baru |
| `fix` | Memperbaiki bug atau error |
| `refactor` | Mengubah atau merapikan struktur kode tanpa mengubah behavior |
| `style` | Mengubah tampilan atau format kode tanpa mengubah logic |
| `docs` | Menambah atau mengubah dokumentasi |
| `test` | Menambah atau mengubah testing |
| `chore` | Maintenance atau perubahan kecil yang bukan fitur maupun bug |
| `perf` | Meningkatkan performa aplikasi |
| `build` | Mengubah build system, dependency, atau package |
| `ci` | Mengubah konfigurasi CI/CD |
| `revert` | Membatalkan commit sebelumnya |

---

## Penjelasan Simpel

### `feat`
Dipakai kalau kamu **menambahkan sesuatu yang baru** ke aplikasi.

### `fix`
Dipakai kalau kamu **memperbaiki sesuatu yang error atau tidak bekerja dengan benar**.

### `refactor`
Dipakai kalau kamu **merapikan atau mengubah struktur kode**, tetapi hasil dan behavior aplikasi tetap sama.

### `style`
Dipakai kalau kamu **mengubah tampilan UI atau formatting kode**, tanpa mengubah logic aplikasi.

### `docs`
Dipakai kalau kamu **menambah, mengubah, atau memperbaiki dokumentasi**.

### `test`
Dipakai kalau kamu **menambah atau mengubah kode untuk testing**.

### `chore`
Dipakai untuk **maintenance project** yang tidak termasuk fitur, bug fix, atau perubahan logic utama.

### `perf`
Dipakai kalau perubahan bertujuan untuk **membuat aplikasi lebih cepat atau lebih efisien**.

### `build`
Dipakai untuk perubahan yang berkaitan dengan **dependency, package, konfigurasi build, atau proses build project**.

### `ci`
Dipakai untuk perubahan yang berkaitan dengan **CI/CD**, seperti automation untuk testing, build, atau deployment.

### `revert`
Dipakai ketika kamu ingin **membatalkan perubahan dari commit sebelumnya**.

---

## Cara Memilih Type

- Ada fitur baru → `feat`
- Ada bug/error yang diperbaiki → `fix`
- Cuma merapikan struktur kode → `refactor`
- Cuma mengubah UI/formatting → `style`
- Dokumentasi → `docs`
- Testing → `test`
- Maintenance → `chore`
- Optimasi performa → `perf`
- Dependency/build → `build`
- CI/CD → `ci`
- Membatalkan commit → `revert`

---

## Aturan Utama

Pilih type berdasarkan **jenis perubahan yang kamu lakukan**, bukan berdasarkan seberapa besar perubahannya.