# Studiv (EduFlow) 🎓

**Studiv** (sebelumnya EduFlow) adalah aplikasi "All-in-One Academic & Productivity Hub" yang dirancang khusus untuk mahasiswa yang menghadapi dinamika perkuliahan yang padat, jadwal yang tidak menentu, dan kebutuhan kolaborasi yang tinggi.

Aplikasi ini tidak hanya sekadar kalender, tetapi asisten pribadi yang mengintegrasikan manajemen tugas, pelacakan IPK, dan kolaborasi tim dalam satu antarmuka elegan.

## 🌟 Filosofi Desain
Dibangun dengan filosofi **"Less is More"**. Studiv menggunakan pendekatan *Neumorphism/Glassmorphism* dengan palet warna modern **Indigo & Slate Gray** untuk memberikan pengalaman visual yang profesional, bersih, dan berfokus pada data akademik.

## ✨ Fitur Utama
1. **Smart Schedule**: Jadwal kuliah otomatis dengan dukungan offline (menggunakan database Hive).
2. **Assignment Tracker (Kanban Style)**: Manajemen tugas dengan pemantauan progress mingguan (Sinkronisasi cloud via Firestore).
3. **GPA Calculator & Predictor**: Perhitungan akurat nilai indeks prestasi (IPK) berbasis bobot SKS.
4. *(Mendatang) Group Project Space*: Manajemen tugas kelompok yang transparan.
5. *(Mendatang) PDF Scanner & Document Organizer*: Pemindaian catatan fisik menggunakan kamera bawaan.

## 🛠️ Stack Teknologi
- **Framework**: Flutter / Dart
- **State Management**: Provider
- **Local Storage**: Hive (NoSQL, Sangat Cepat)
- **Cloud Database**: Firebase Cloud Firestore
- **Desain UI**: Google Fonts (Inter) & Curved Navigation Bar

## 🚀 Cara Menjalankan Secara Lokal

1. **Klon Repositori**
   ```bash
   git clone https://github.com/mohdikrullah/Studiv.git
   cd Studiv
   ```

2. **Instal Dependensi**
   ```bash
   flutter pub get
   ```

3. **Jalankan Aplikasi**
   Pastikan Anda sudah menjalankan Emulator atau menyambungkan perangkat fisik.
   ```bash
   flutter run
   ```

## 🧪 Menjalankan Pengujian (Testing)
Logika IPK sangat krusial, oleh karena itu dilengkapi dengan *Unit Test* untuk memastikan perhitungannya selalu 100% akurat.
```bash
flutter test
```

---
*Dibangun untuk Mahasiswa, oleh Mahasiswa.* 💡
