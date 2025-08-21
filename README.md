# Credit Card Transaction Analysis – PostgreSQL

## Deskripsi
Project ini menggunakan PostgreSQL untuk melakukan **data preparation** dan **analisis perilaku pengguna kartu** berdasarkan tiga dataset:  
- **cards_data** → informasi kartu  
- **users_data** → informasi pengguna  
- **transaction_data** → detail transaksi  

Tujuan utama adalah membersihkan data, menstandarkan tipe data, menghapus duplikasi, serta menghasilkan insight bisnis.

---

## Cara Menjalankan Kode

### 1. **Persiapan**
- Pastikan PostgreSQL sudah terinstal (versi 13+ disarankan).  
- Buat database baru, misalnya bernama `credit_card_analysis`.  
  ```sql
  CREATE DATABASE credit_card_analysis;
  ```
- Masuk ke database:
  ```bash
  \c credit_card_analysis
  ```

### 2. **Import Dataset**
- Simpan file dataset (`cards_data.csv`, `users_data.csv`, `transaction_data.csv`) di folder lokal.  
- Gunakan perintah berikut untuk import (contoh untuk `cards_data`):  
  ```sql
  \copy cards_data FROM '/path/cards_data.csv' DELIMITER ',' CSV HEADER;
  \copy users_data FROM '/path/users_data.csv' DELIMITER ',' CSV HEADER;
  \copy transaction_data FROM '/path/transaction_data.csv' DELIMITER ',' CSV HEADER;
  ```
  > Ganti `/path/...` dengan path file dataset di komputer kamu.

### 3. **Jalankan Script SQL**
- Buka file `analysis.sql` (isi kode SQL dari project ini).  
- Jalankan script secara berurutan:  
  1. Membuat tabel dengan tipe data `TEXT`.  
  2. Mengubah tipe data sesuai kebutuhan (INT, NUMERIC, TIMESTAMP, dsb.).  
  3. Membersihkan data (`UPDATE`, `REPLACE`, ganti NULL → UNKNOWN).  
  4. Mengecek duplikasi (`SELECT ... HAVING COUNT(*) > 1`).  
  5. Menjalankan query analisis.  

Jika menggunakan `psql` CLI:
```bash
\i /path/analysis.sql
```

### 4. **Validasi Data**
- Cek data setelah proses cleaning:
  ```sql
  SELECT * FROM users_data LIMIT 10;
  SELECT * FROM cards_data LIMIT 10;
  SELECT * FROM transaction_data LIMIT 10;
  ```
- Pastikan kolom sudah sesuai tipe data yang ditentukan.

### 5. **Menjalankan Analisis**
- Gunakan query analisis di script untuk menjawab pertanyaan seperti:
  - Total kartu tanpa chip.  
  - Total transaksi & pengeluaran per gender.  
  - Brand kartu yang paling banyak digunakan.  
  - Nasabah dengan profil finansial ideal.  
  - Perbandingan jenis kartu yang digunakan anak muda vs orang tua.  

---

## Output yang Diharapkan
- Data yang sudah bersih, siap divisualisasikan.  
- Insight mengenai perilaku pengguna kartu berdasarkan gender, usia, brand, dan jenis kartu.  
- Identifikasi risiko (kartu tanpa chip) dan peluang (nasabah ideal, pengguna debit → kredit).  
