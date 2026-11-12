# KIEE STURR — Free Fire Store

Starter project Next.js + Tailwind + Supabase untuk katalog **Akun FF, ID Cantik, Rental Akun, dan Jasa Post / Titip Jual**. Tidak menyediakan top up atau game lain.

## Fitur yang sudah disiapkan
- Katalog dan pencarian dari tabel Supabase, filter kategori/status/harga/terbaru.
- Halaman detail produk dan tombol WhatsApp dengan format pesan.
- Form pengajuan titip jual dan upload foto ke Supabase Storage.
- Login admin Supabase Auth, middleware proteksi `/admin`.
- Dashboard admin untuk tambah/edit/hapus/status produk, review pengajuan, dan pengaturan toko.
- Produk titipan yang di-ACC otomatis dibuat sebagai produk katalog.
- SQL schema + RLS policies.

## 1. Siapkan Supabase
1. Buat project di https://supabase.com.
2. Buka **SQL Editor**, jalankan seluruh isi `supabase/schema.sql`.
3. Buka **Project Settings → API**, salin Project URL dan anon/public key.
4. Buka **Authentication → Providers → Email**, aktifkan Email.
5. Buat akun admin pertama melalui **Authentication → Users → Add user** (email + password). Konfirmasi email jika diminta.
6. Setelah akun dibuat, buka daftar Users dan salin UUID user. Jalankan SQL berikut di SQL Editor (ganti nilainya):
   ```sql
   insert into public.admins(user_id,email)
   values('UUID_USER_ADMIN','email-admin-kamu@example.com');
   ```
   Baris di tabel `admins` inilah yang memberi hak admin. Jangan memasukkan service-role key ke frontend.

## 2. Jalankan di komputer
1. Install Node.js 20 atau lebih baru.
2. Ekstrak ZIP project, buka folder project di terminal.
3. Salin `.env.example` menjadi `.env.local`.
4. Isi `NEXT_PUBLIC_SUPABASE_URL` dan `NEXT_PUBLIC_SUPABASE_ANON_KEY`.
5. Jalankan:
   ```bash
   npm install
   npm run dev
   ```
6. Buka `http://localhost:3000`. Login dashboard di `/admin/login`.

## 3. Deploy ke Vercel
1. Upload project ke repository GitHub.
2. Di https://vercel.com pilih **Add New → Project**, import repository.
3. Di Environment Variables isi:
   - `NEXT_PUBLIC_SUPABASE_URL`
   - `NEXT_PUBLIC_SUPABASE_ANON_KEY`
   - `NEXT_PUBLIC_SITE_URL` dengan URL deployment
4. Tekan Deploy. Setiap push baru ke branch production akan membuat deployment baru.
5. Pastikan URL website dapat membuka halaman utama dan admin dapat login.

## 4. Pengaturan awal toko
1. Login `/admin/login`.
2. Buka tab **Pengaturan Toko**.
3. Isi nama toko (default KIEE STURR), WhatsApp admin format internasional tanpa `+` (contoh `62812...`), fee dan syarat jasa post, serta teks garansi.
4. Simpan pengaturan.

## 5. Tambah produk pertama
1. Dashboard → Produk.
2. Pilih kategori Akun FF / ID Cantik / Rental Akun.
3. Isi kode unik, judul, harga atau tarif rental, detail dan status.
4. Upload foto utama. Simpan.
5. Produk langsung diambil dari database pada halaman toko; refresh halaman untuk melihat perubahan.

## 6. Alur titip jual
1. Buyer buka `/jasa-post`, isi formulir, upload foto.
2. Pengajuan masuk ke tab **Pengajuan Titip Jual** di admin.
3. Admin dapat chat buyer via WhatsApp, lalu tekan **ACC** atau **Tolak**.
4. ACC akan membuat produk Akun FF berlabel titipan di katalog.
5. Ubah status produk ke Terjual saat transaksi selesai.

## Penting sebelum dipakai publik
- Isi WhatsApp admin dengan benar; tombol order menggunakan nomor itu.
- Supabase Storage bucket `store-media` dibuat oleh SQL dan bersifat public untuk menampilkan foto katalog.
- RLS membatasi operasi katalog/settings ke user yang terdaftar di `public.admins`. Jangan pernah expose service-role key.
- Form pengajuan titip jual sengaja hanya menerima data dan foto; jangan meminta password akun, OTP, atau data sensitif. Verifikasi kepemilikan dan kesepakatan secara aman di luar formulir.
- Jadwal rental pada versi awal meminta tanggal dan durasi lalu mengarahkan buyer ke admin untuk konfirmasi. Kalender booking otomatis dan blokir tanggal belum diaktifkan; jangan mengiklankan slot sebagai terjamin sebelum admin mengonfirmasi.
- Pengelolaan banner/testimoni, galeri multi-foto, omset/order terstruktur, dan duplikasi produk belum tersedia di UI awal ini. Tabel database pendukung untuk banner/testimoni sudah dibuat; fitur tersebut bisa ditambahkan pada iterasi berikutnya.
- Sebelum transaksi akun digital, jelaskan status bind, kepemilikan, risiko pemulihan akun, syarat garansi, dan aturan platform game kepada pembeli.

## Struktur ringkas
- `src/app` halaman publik, detail, jasa-post, admin
- `src/components` komponen toko, detail, form titip, dashboard
- `src/lib` Supabase, tipe data, WhatsApp
- `supabase/schema.sql` tabel, RLS, storage bucket
