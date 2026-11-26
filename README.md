# I'LOOP - Circular Economy & Reuse Marketplace (Flutter Android)

**I'LOOP** adalah aplikasi Android berbasis Flutter dan database Supabase (free tier) yang menerapkan konsep *Circular Economy* dan *Reuse*. Aplikasi ini memfasilitasi transaksi **Jual Beli**, **Tukar Barang (Swap)**, **Donasi Gratis (Share)**, serta feed komunitas untuk edukasi **Reuse & Upcycling**.

---

## 🚀 Fitur Utama

1. **Marketplace (Buy & Sell)**: Pasang iklan barang bekas layak pakai, filter kategori dan kota, negosiasi harga.
2. **Swap (Tukar Barang)**: Sistem proposal barter formal di mana calon penukar mengajukan barang miliknya untuk disetujui oleh pemilik.
3. **Share (Donasi Gratis)**: Bagikan barang yang masih memiliki nilai fungsi kepada orang yang membutuhkan secara cuma-cuma.
4. **Reuse & Upcycling**: Feed komunitas kreatif untuk berbagi panduan tutorial DIY, kreasi barang daur ulang, serta like & komentar.
5. **In-App Realtime Chat**: Obrolan langsung antara pengguna untuk negosiasi dan koordinasi COD/janjian temu menggunakan Supabase Realtime.
6. **Eco-Impact Metrics**: Perhitungan jumlah barang yang diselamatkan dari limbah (*items saved*) dan lencana kontributor sirkular.

---

## 🛠️ Prasyarat & Persiapan Supabase

### 1. Eksekusi Skema Database
1. Buat proyek baru di [Supabase Dashboard](https://supabase.com).
2. Buka menu **SQL Editor**.
3. Buka file `database_schema.sql` pada proyek ini, salin seluruh kodenya, lalu klik **Run**.
4. Skema lengkap (tabel, relasi, Row Level Security, trigger otomatis profil, fungsi RPC, dan channel realtime) akan otomatis aktif.

### 2. Konfigurasi Supabase Storage
1. Buka menu **Storage** di Supabase.
2. Buat 2 bucket baru:
   - `item-photos` (Centang opsi **Public Bucket**)
   - `upcycle-photos` (Centang opsi **Public Bucket**)

### 3. Dapatkan Kredensial API
Buka menu **Project Settings** -> **API**, lalu catat:
- **Project URL** (contoh: `https://xyz.supabase.co`)
- **Anon / Public Key** (contoh: `eyJhbGciOi...`)

---

## 💻 Menjalankan Aplikasi Secara Lokal

Jalankan perintah berikut pada terminal di folder proyek:

```bash
# 1. Unduh paket dependensi
flutter pub get

# 2. Jalankan aplikasi dengan menyuntikkan kredensial Supabase
flutter run \
  --dart-define=SUPABASE_URL="https://YOUR_PROJECT_ID.supabase.co" \
  --dart-define=SUPABASE_ANON_KEY="YOUR_SUPABASE_ANON_KEY"
```

---

## 📦 Build APK via GitHub Actions (CI/CD)

Proyek ini telah dilengkapi dengan workflow GitHub Actions otomatis di `.github/workflows/build_apk.yml`.

### Langkah Pengaturan:
1. Push repository ini ke akun GitHub Anda.
2. Buka halaman repository di GitHub -> **Settings** -> **Secrets and variables** -> **Actions**.
3. Tambahkan 2 **Repository secrets**:
   - `SUPABASE_URL`: URL project Supabase Anda
   - `SUPABASE_ANON_KEY`: Anon key Supabase Anda
4. Setiap kali Anda melakukan `git push` ke branch `main`, GitHub Actions akan otomatis:
   - Menyiapkan JDK 17 dan Flutter stable
   - Menjalankan analisis kode
   - Mengompilasi berkas APK release
   - Menyediakan berkas unduhan `iloop-release-apk` di tab **Actions** -> **Artifacts**

---

## 📁 Struktur Arsitektur Kode

```text
lib/
├── main.dart                          # Inisialisasi Supabase & MultiProvider
├── core/
│   ├── config/app_config.dart         # Pengambilan environment --dart-define
│   ├── constants/                     # Warna, Kategori barang, Kota Indonesia
│   ├── theme/app_theme.dart           # Konfigurasi Tema Material 3
│   └── utils/currency_formatter.dart  # Format Rupiah & tanggal
├── data/
│   ├── models/                        # ItemModel, ProfileModel, SwapProposalModel, dll.
│   └── repositories/                  # Auth, Item, Proposal, Chat, Upcycle Repository
├── state/                             # Provider State Management
└── presentation/
    ├── widgets/                       # ItemCard, CustomButton, EcoBadgeWidget
    └── screens/
        ├── splash/                    # Splash Screen & Auth Gate
        ├── auth/                      # Login & Register
        ├── main_nav.dart              # Bottom Navigation Bar 5-Tab
        ├── home/                      # Beranda, Detail Barang, Proposal Sheet
        ├── upcycle/                   # Feed Upcycle & Form Tulis Panduan
        ├── post/                      # Form Pasang Barang (Jual/Tukar/Donasi)
        ├── chat/                      # Inbox & Realtime Chat Room
        └── profile/                   # Profil & Metrik Dampak Lingkungan
```
