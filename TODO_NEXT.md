# Rencana Pengembangan Studiv (Besok)

Berikut adalah daftar fitur dan peningkatan yang direncanakan untuk dilanjutkan besok:

## 1. Desain & UX (Aesthetics)
- [ ] **Dukungan Dark Mode**:
  - Menambahkan `darkTheme` di `lib/theme/app_theme.dart`.
  - Mengonfigurasi warna latar belakang gelap, kartu abu-abu gelap, dan teks terang.
  - Menghubungkan penggantian tema secara dinamis di `main.dart`.
- [ ] **Efek Loading Shimmer**:
  - Menambahkan package `shimmer`.
  - Membuat placeholder shimmer untuk kartu jadwal di Dashboard dan halaman Jadwal saat memuat data.

## 2. Fitur Akademik Baru
- [ ] **Simulator IPK & Target Nilai**:
  - Membuat kalkulator interaktif untuk memprediksi IPK berdasarkan simulasi nilai mata kuliah semester ini.
- [ ] **Pendeteksi Jadwal Bentrok**:
  - Menambahkan validasi saat menambah/mengedit jadwal kuliah agar memunculkan peringatan jika ada waktu yang tumpang tindih.

---
*Dibuat otomatis sebagai pengingat sesi pengembangan berikutnya.*
