# ScoutPro PWA Starter

Starter kit untuk aplikasi pencatatan pemain SSB dan tim tarkam.

## Isi paket
- `index.html`: antarmuka responsif untuk HP dan desktop.
- `app.js`: pencatatan aksi manual, statistik langsung, data lokal, ekspor CSV.
- `manifest.webmanifest`: metadata instalasi PWA.
- `sw.js`: cache shell agar aplikasi dapat dibuka saat offline setelah kunjungan pertama.
- `schema.sql`: rancangan database PostgreSQL + RLS awal untuk Supabase.
- `assets/icon.svg`: ikon aplikasi.

## Status implementasi
Starter ini dapat dijalankan lokal melalui browser, mencatat pemain/aksi, menghitung akurasi passing, menampilkan statistik, serta ekspor CSV dan backup JSON. Data disimpan di localStorage pada perangkat yang sama.

**Integrasi Supabase tersedia dalam paket ini:** login email/kata sandi, tabel `scoutpro_records`, kebijakan RLS per pemilik akun, pengiriman antrean lokal, dan pembaruan Realtime antar perangkat. Tetap uji dengan akun dan dua perangkat sebelum digunakan untuk pertandingan sungguhan.

## Menjalankan secara lokal
1. Ekstrak ZIP ke sebuah folder.
2. Buka terminal pada folder `scoutpro_pwa_starter` (folder yang berisi `index.html`).
3. Jalankan server statis, misalnya Python:
   `python -m http.server 8000`
4. Buka `http://localhost:8000` di browser.
5. Untuk HP, unggah seluruh isi folder ke hosting HTTPS; jangan hanya mengunggah `index.html`.

Sesi pertandingan yang masih berstatus `live` dipulihkan saat halaman dibuka kembali. Tanggal mengikuti zona waktu lokal perangkat. Data tetap lokal sampai integrasi backend benar-benar dibuat.

Untuk uji PWA di HP, deploy ke hosting yang memakai HTTPS. Service Worker tidak berjalan dari `file://`.

## Mengaktifkan sinkronisasi Supabase
1. Buka Supabase Dashboard proyek Anda → **SQL Editor**.
2. Buka file `schema.sql` yang ada di paket ini, salin seluruh isinya ke SQL Editor, lalu tekan **Run**. File ini membuat tabel `scoutpro_records` dan RLS yang cocok dengan aplikasi pada paket ini. Ini tambahan untuk tabel lain yang mungkin sudah dibuat.
3. Di **Project Settings → API** (atau Connect), salin **Project URL** dan **publishable key** (atau anon key lama). Jangan gunakan `service_role`.
4. Unggah seluruh isi folder aplikasi ke hosting HTTPS.
5. Buka aplikasi, menu **Koneksi**, isi URL dan key, lalu tekan **Simpan konfigurasi**.
6. Pada panel **Akun ScoutPro**, masukkan email dan kata sandi akun yang sudah ada di Supabase Auth, lalu tekan **Masuk**. Jika konfirmasi email aktif, konfirmasikan email dahulu.
7. Buka aplikasi pada laptop dan HP, gunakan URL/key yang sama dan **akun yang sama**, lalu catat aksi uji. Perubahan harus muncul di perangkat lain saat tersambung internet.

Catatan penting:
- Paket ini memakai tabel `scoutpro_records` (payload JSON) dan bukan tabel `scoutpro_matches`/`scoutpro_stats` atau skema organisasi lama. Jalankan SQL yang disertakan di ZIP ini agar nama tabel dan kebijakan cocok.
- Akun yang berbeda hanya dapat melihat rekaman milik akunnya sendiri. Untuk berbagi data, login di perangkat-perangkat dengan akun yang sama.
- Saat offline, perubahan antre di browser dan dicoba dikirim setelah online kembali. Jangan menghapus data browser sebelum antrean tersinkron.
- Data yang sudah tersimpan sebelumnya hanya di browser perangkat lama tidak otomatis muncul di perangkat lain; tambahkan ulang atau ekspor/backup terlebih dahulu.
- Jangan pernah meletakkan `service_role` key di HTML/JavaScript browser.

## Model data inti
- `organizations`: unit pengelola data (SSB, tim tarkam, komunitas).
- `organization_members`: hubungan akun dan peran.
- `teams`: tim di dalam organisasi.
- `players`: profil pemain.
- `matches`: sesi pertandingan/latihan.
- `match_roster`: pemain yang terdaftar pada pertandingan.
- `match_events`: satu baris untuk satu aksi yang dicatat.
- `scouting_reports`: evaluasi kualitatif scout/pelatih.
- `topsis_configs`: bobot kriteria TOPSIS per posisi.

## Definisi statistik
Akurasi passing = `pass_ok / (pass_ok + pass_fail) * 100`.
Jika total passing nol, tampilkan `—`, bukan 0%.

Metrik lain:
- Shot accuracy = `shot_on / (shot_on + shot_off) * 100`.
- Gol, assist, peluang, save, intersep, duel, tackle, dribel = hitung event masing-masing.
- Simpan event mentah; hitung agregasi dari event agar statistik bisa diaudit dan diperbaiki.

## Roadmap menuju produksi
1. Login dan pemilihan organisasi aktif.
2. Sinkronisasi multi-perangkat dengan retry, idempotensi, dan indikator antrean.
3. Roster, tim A/B, pergantian pemain, babak, waktu pertandingan dan koreksi aksi.
4. View statistik SQL dan filter rentang tanggal, tim, kompetisi, posisi.
5. TOPSIS per posisi: normalisasi vektor, bobot kriteria, ideal positif/negatif, skor preferensi.
6. Laporan PDF/CSV, histori pemain, audit perubahan dan backup.
7. Pengujian keamanan, privasi, consent wali untuk pemain anak, dan uji lapangan.

## Catatan statistik
Aplikasi tidak dapat mengetahui aksi secara otomatis. Statistik mencerminkan aksi yang dicatat pencatat di lapangan. Untuk akurasi tinggi, sediakan definisi event yang seragam, pelatihan pencatat, dan proses koreksi.
