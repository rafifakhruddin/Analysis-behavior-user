-- Membuat table cards_data dan tipe data menjadi TEXT agar mudah diimport --
CREATE TABLE public.cards_data
(
	id TEXT,
    client_id TEXT,
    card_brand TEXT,
    card_type TEXT,
    card_number TEXT,
    expires TEXT,
    cvv TEXT,
    has_chip TEXT,
    num_cards_issued TEXT,
    credit_limit TEXT,
    acct_open_date TEXT,
    year_pin_last_changed TEXT,
    card_on_dark_web TEXT
);


-- Mengubah semua tipe data --
ALTER TABLE cards_data 
    DROP COLUMN id,
    ADD COLUMN id SERIAL PRIMARY KEY;

ALTER TABLE cards_data 
    ALTER COLUMN client_id TYPE INT USING client_id::INT,
    ALTER COLUMN card_brand TYPE VARCHAR(50),
    ALTER COLUMN card_type TYPE VARCHAR(50),
    ALTER COLUMN card_number TYPE BIGINT USING card_number::BIGINT,
    ALTER COLUMN expires TYPE VARCHAR(7),
    ALTER COLUMN cvv TYPE INT USING cvv::INT,
    ALTER COLUMN has_chip TYPE VARCHAR(10),
    ALTER COLUMN num_cards_issued TYPE INT USING num_cards_issued::INT,
    ALTER COLUMN credit_limit TYPE VARCHAR(50),
    ALTER COLUMN acct_open_date TYPE VARCHAR(7),
    ALTER COLUMN year_pin_last_changed TYPE INT USING year_pin_last_changed::INT,
    ALTER COLUMN card_on_dark_web TYPE VARCHAR(10);

UPDATE cards_data
SET credit_limit = REPLACE(credit_limit, '$', '')::numeric;


-- Membuat table users_data dan tipe data menjadi TEXT agar mudah diimport --
CREATE TABLE public.users_data
(
	id TEXT,
	current_age TEXT, 
	retirement_age TEXT,
	birth_year TEXT,
	birth_month TEXT,
	gender TEXT,
	address TEXT,
	latitude TEXT,
	longitude TEXT,
	per_capita_income TEXT,
	yearly_income TEXT,
	total_debt TEXT,
	credit_score TEXT,
	num_credit_cards TEXT
);

-- Mengubah semua tipe data Menajadi yang sebenarnya --
ALTER TABLE public.users_data
    ALTER COLUMN id TYPE INT USING id::INT,
    ALTER COLUMN current_age TYPE SMALLINT USING current_age::SMALLINT,
    ALTER COLUMN retirement_age TYPE SMALLINT USING retirement_age::SMALLINT,
    ALTER COLUMN birth_year TYPE SMALLINT USING birth_year::SMALLINT,
    ALTER COLUMN birth_month TYPE SMALLINT USING birth_month::SMALLINT,
    ALTER COLUMN gender TYPE VARCHAR(10),
    ALTER COLUMN address TYPE TEXT,
    ALTER COLUMN latitude TYPE NUMERIC(9,6) USING latitude::NUMERIC,
    ALTER COLUMN longitude TYPE NUMERIC(9,6) USING longitude::NUMERIC,
    ALTER COLUMN per_capita_income TYPE NUMERIC USING REPLACE(per_capita_income, '$','')::NUMERIC, -- Menghapus Tanda $ --
    ALTER COLUMN yearly_income TYPE NUMERIC USING REPLACE(yearly_income, '$','')::NUMERIC, -- Menghapus Tanda $ --
    ALTER COLUMN total_debt TYPE NUMERIC USING REPLACE(total_debt, '$','')::NUMERIC, -- Menghapus Tanda $ --
    ALTER COLUMN credit_score TYPE SMALLINT USING credit_score::SMALLINT,
    ALTER COLUMN num_credit_cards TYPE SMALLINT USING num_credit_cards::SMALLINT;

ALTER TABLE users_data 
    DROP COLUMN id,
    ADD COLUMN id SERIAL PRIMARY KEY;



select * from users_data;

-- Membuat table transaction_data dan tipe data menjadi TEXT agar mudah diimport --
CREATE TABLE public.transaction_data
(
	id TEXT,
	date TEXT,
	client_id TEXT,
	card_id TEXT,
	amount TEXT,
	use_chip TEXT,
	merchant_id TEXT,
	merchant_city TEXT,
	merchant_state TEXT,
	zip TEXT,
	mcc TEXT,
	errors TEXT
);

-- Mengubah semua tipe data Menajadi yang sebenarnya --
UPDATE public.transaction_data
SET merchant_state = LEFT(TRIM(merchant_state), 2);

ALTER TABLE public.transaction_data
    ALTER COLUMN id TYPE BIGINT USING id::BIGINT,
    ALTER COLUMN date TYPE TIMESTAMP USING date::TIMESTAMP,
    ALTER COLUMN client_id TYPE INT USING client_id::INT,
    ALTER COLUMN card_id TYPE BIGINT USING card_id::BIGINT,
    ALTER COLUMN use_chip TYPE VARCHAR(50),
    ALTER COLUMN merchant_id TYPE BIGINT USING merchant_id::BIGINT,
    ALTER COLUMN merchant_city TYPE VARCHAR(100),
    ALTER COLUMN merchant_state TYPE CHAR(2),
    ALTER COLUMN zip TYPE VARCHAR(10),
    ALTER COLUMN mcc TYPE INT USING mcc::INT;

ALTER TABLE public.transaction_data ADD COLUMN amount_num NUMERIC(12,2);

UPDATE public.transaction_data
SET amount_num = CAST(REPLACE(REPLACE(amount,'$',''),',','') AS NUMERIC(12,2));

ALTER TABLE public.transaction_data DROP COLUMN amount;

ALTER TABLE public.transaction_data RENAME COLUMN amount_num TO amount;

ALTER TABLE transaction_data 
    DROP COLUMN id,
    ADD COLUMN id SERIAL PRIMARY KEY;


-- Menghapus kolom errors --
ALTER TABLE transaction_data
DROP COLUMN errors;

-- Mengubah data yang null menjadi UKNOWN karena data masih berguna dalam menganalisis hal lain --
UPDATE transaction_data
SET merchant_state = 'UNKNOWN'
WHERE merchant_state IS NULL;

UPDATE transaction_data
SET zip = 'UNKNOWN'
WHERE zip IS NULL;

-- Melihat data kolom merchant_state dan zip yang memiliki nilai UNKNOWN --
SELECT *
FROM transaction_data
WHERE merchant_state = 'UNKNOWN'
   OR zip = 'UNKNOWN';

select * from transaction_data;

	
								-- Data Preparation --
-- Mencari duplikat kolom id dan card_number. Pada tabel cards_data --
SELECT
    id,
    card_number,
    COUNT(*) AS jumlah_duplikat
FROM
    cards_data
GROUP BY
    id,
    card_number
HAVING
    COUNT(*) > 1;

-- Mencari duplikat kolom id. Pada tabel users_data --
SELECT
    id,
    COUNT(*) AS jumlah_duplikat
FROM
    users_data
GROUP BY
    id
HAVING
    COUNT(*) > 1;

-- Mencari duplikat kolom id. Pada tabel transaction_data --
SELECT
    id,
    COUNT(*) AS jumlah_duplikat
FROM
    transaction_data
GROUP BY
    id
HAVING
    COUNT(*) > 1;



								-- ANALIS --
-- Total kartu yang belum memiliki chip --
SELECT 
    COUNT(*) AS total_cards_no_chip
FROM cards_data
WHERE has_chip = 'NO';

-- total transaksi yang dilakukan oleh setiap gender, dengan jenis kartu kredit. --
SELECT 
    u.gender,
    COUNT(DISTINCT u.id) AS total_users,
    COUNT(t.id) AS total_transactions,
    SUM(t.amount) AS total_amount
FROM users_data u
JOIN cards_data c ON u.id = c.client_id
JOIN transaction_data t ON c.id = t.card_id
WHERE c.card_type = 'Credit'
GROUP BY u.gender
ORDER BY total_amount DESC;

-- Mencari total pendapatan tahunan, jumlah transaksi, dan nilai transaksi untuk setiap gender. --
SELECT 
    u.gender,
    SUM(u.yearly_income) AS total_yearly_income,
    COUNT(t.id) AS total_transactions,
    SUM(t.amount) AS total_amount
FROM users_data u
JOIN cards_data c ON u.id = c.client_id
JOIN transaction_data t ON c.id = t.card_id
GROUP BY u.gender;


-- Mengidentifikasi nasabah dengan pendapatan tinggi dan utang rendah yang memiliki batas kredit rendah --
SELECT
    t1.id,
    t1.yearly_income::NUMERIC,
    t1.total_debt::NUMERIC,
    t2.credit_limit::NUMERIC
FROM
    users_data AS t1
JOIN
    cards_data AS t2 ON t1.id = t2.client_id
WHERE
    t1.yearly_income::NUMERIC > 70000
    AND t1.total_debt::NUMERIC < 50000
    AND t2.credit_limit::NUMERIC < 10000;

-- 3 card_brand yang sering digunakan berdasarkan jumlah transaksi --
SELECT 
    c.card_brand,
    COUNT(t.id) AS total_transactions
FROM transaction_data t
JOIN cards_data c ON t.card_id = c.id
GROUP BY c.card_brand
ORDER BY total_transactions DESC
LIMIT 3;


-- Mencari 3 jenis kartu yang sering dipakai dengan rata-rata income percapita penggunanya --
SELECT 
    c.card_brand,
    COUNT(t.id) AS total_transactions,
    SUM(t.amount) AS total_amount,
    ROUND(AVG(u.per_capita_income), 2) AS avg_per_capita_income
FROM transaction_data t
JOIN cards_data c ON t.card_id = c.id
JOIN users_data u ON t.client_id = u.id
GROUP BY c.card_brand
ORDER BY total_transactions DESC
LIMIT ;

-- Mencari card_type yang sering digunakan anak muda, dengan asumsi anak muda umur 30 kebawah --
SELECT 
    c.card_type,
    COUNT(DISTINCT u.id) AS total_young_users,
    COUNT(t.id) AS total_transactions,
    SUM(t.amount) AS total_amount
FROM users_data u
JOIN cards_data c ON u.id = c.client_id
LEFT JOIN transaction_data t ON c.id = t.card_id
WHERE u.current_age <= 30
  AND c.card_type IN ('Debit', 'Credit', 'Debit (Prepaid)')
GROUP BY c.card_type
ORDER BY total_transactions DESC;

-- Mencari card_type yang sering digunakan Orang Tua, dengan asumsi orang tua umur 50 keatas --
SELECT 
    c.card_type,
    COUNT(DISTINCT u.id) AS total_old_users,
    COUNT(t.id) AS total_transactions,
    SUM(t.amount) AS total_amount
FROM users_data u
JOIN cards_data c ON u.id = c.client_id
LEFT JOIN transaction_data t ON c.id = t.card_id
WHERE u.current_age > 50
  AND c.card_type IN ('Debit', 'Credit', 'Debit (Prepaid)')
GROUP BY c.card_type
ORDER BY total_transactions DESC;

SELECT *
FROM transaction_data
WHERE date >= '2019-01-01'
  AND date < '2019-05-01'
LIMIT 100000;

SELECT 
    EXTRACT(YEAR FROM date) AS tahun,
    COUNT(*) AS total_transaksi
FROM transaction_data
GROUP BY EXTRACT(YEAR FROM date)
ORDER BY tahun;

select * from transaction_data;
select * from cards_data;
select * from users_data;









