# Fish and Fih — Progression & Economy Design (Draft)

Status saat ini: **hanya fitur memancing**.  
Catatan teknis: **belum ada save data**, jadi semua progres di bawah ini diasumsikan **berlaku per-session (runtime)** sampai sistem penyimpanan ditambahkan.

---

## 1) Core Loop (Siklus Utama)
1. **Cast** → 2. **Hook / Minigame** → 3. **Catch Fish (dapat berat + rarity)**  
4. **Masuk ke net (backpack)**  
5. **Shop isinya ada fishmonger** → **Sell Fish** → dapat **Coins**  
6. **Upgrade Rod / Beli item** -> lanjut progress ke area baru -> repeat

---

## 2) UI & Menu Minimal
### 2.1 HUD saat memancing
- **Coins** (session)
- **Rod Level** + stat ringkas
- **Spot/Area** (mis. Pond, River, Sea)
- **Net Capacity**: `current / max`

### 2.2 Shop Screen
Tab:
- **Sell**
- **Rod Upgrade**
- **Info Fish (encyclopedia sederhana)**

Karena belum ada save:
- Tombol **“Reset Session”** (opsional) atau otomatis reset saat restart game.

---

## 3) Currency & Balance
### 3.1 Mata uang
- **Coins**: satu-satunya currency awal.

### 3.2 Target pacing (rasa progression)
- Upgrade pertama terasa cepat (1–3 menit).
- Upgrade menengah butuh 5–10 menit.
- Upgrade tinggi butuh 15–30 menit (tanpa save, ini mungkin terasa berat; rekomendasi: batasi max upgrade sampai save ada).

---

## 4) Rarity System
Gunakan rarity berikut:
- **Common (C)**
- **Uncommon (U)**
- **Rare (R)**
- **Epic (E)**
- **Legendary (L)**

### 4.1 Drop rate per area (contoh)
> Angka bisa di-tune nanti.

| Area  | Common | Uncommon | Rare | Epic | Legendary |
|------|--------|----------|------|------|-----------|
| Pond | 70%    | 25%      | 5%   | 0%   | 0%        |
| River| 55%    | 30%      | 12%  | 3%   | 0%        |
| Sea  | 40%    | 30%      | 18%  | 10%  | 2%        |

---

## 5) Berat Ikan (Weight) & Range
Setiap ikan punya:
- `min_weight`, `max_weight` (gram atau kg)
- Distribusi (simple): random uniform / bias ke tengah

Contoh range global per rarity (opsional):
- **Common**: 0.2–1.0 kg
- **Uncommon**: 0.4–1.8 kg
- **Rare**: 0.8–3.0 kg
- **Epic**: 1.5–5.0 kg
- **Legendary**: 3.0–12.0 kg

---

## 6) Harga Ikan (Pricing): Berat + Rarity
### 6.1 Rumus harga yang simpel dan enak di-balance
**Base price per kg** ditentukan oleh rarity, lalu dikali berat, lalu dikali kualitas ukuran.

**A) Base price per kg (contoh awal)**
| Rarity | Base Coins / kg |
|--------|------------------|
| C      | 20               |
| U      | 45               |
| R      | 90               |
| E      | 180              |
| L      | 400              |

**B) Size multiplier (opsional, bikin “dapat ikan besar” terasa spesial)**  
Hitung `size_ratio = (weight - min_weight) / (max_weight - min_weight)` → 0..1  
Lalu:
- `size_mult = 0.85 + (size_ratio * 0.45)` → range **0.85x sampai 1.30x**

**C) Final price**
- `price = round(weight_kg * base_per_kg * size_mult)`

### 6.2 Contoh perhitungan (ilustrasi)
- Rare fish, berat 2.0 kg, size_mult 1.15  
  `price = round(2.0 * 90 * 1.15) = round(207) = 207 coins`

---

## 7) Bucket / Inventori Sementara (tanpa save)
Karena belum ada save data, ikan hasil tangkapan masuk ke **Bucket session**:
- Bucket punya **kapasitas** (jumlah item, bukan berat) untuk kontrol pacing.
- Jika bucket penuh:
  - Opsi A: tidak bisa cast sebelum jual
  - Opsi B: ikan baru menggantikan yang termurah (kurang disarankan)
  - Opsi C: player pilih ikan yang dibuang

**Rekomendasi awal**: Opsi A.

### 7.1 Kapasitas awal & peningkatan
- Default: **10 slot**
- Rod upgrade bisa tambah capacity (lihat bagian rod).

---

## 8) Sell Fish (Dock/Shop)
### 8.1 UX
- Daftar ikan di bucket: nama, rarity, berat, harga.
- Tombol:
  - **Sell All**
  - **Sell Selected**
  - **Sort**: by rarity / price / weight

### 8.2 Anti-micro: “Sell All” penting
Karena game loop cepat, “Sell All” mengurangi friksi.

---

## 9) Rod System (Upgrade & Stats)
Rod mempengaruhi:
1. **Hook Power** (lebih mudah dapet ikan berat)
2. **Line Strength** (batas max weight yang aman)
3. **Reel Speed** (durasi minigame lebih singkat / recovery cepat)
4. **Luck** (sedikit menaikkan chance rarity tinggi)
5. **Bucket Capacity bonus** (opsional)

### 9.1 Stat model (simple)
- `max_safe_weight` (kg): ikan di atas ini punya chance lepas lebih besar
- `luck_bonus` (% additive kecil)
- `reel_speed` (multiplier terhadap durasi minigame)
- `bucket_bonus` (slot tambahan)

### 9.2 Tabel upgrade (contoh awal, 6 level)
> Karena belum ada save, stop di level 6 dulu agar tetap attainable per-session.

| Rod Lv | Cost (Coins) | max_safe_weight | luck_bonus | reel_speed | bucket_bonus |
|--------|--------------|-----------------|-----------:|-----------:|-------------:|
| 1      | -            | 1.5 kg          | 0%         | 1.00x      | +0           |
| 2      | 200          | 2.5 kg          | +1%        | 0.95x      | +2           |
| 3      | 600          | 4.0 kg          | +2%        | 0.92x      | +4           |
| 4      | 1400         | 6.5 kg          | +3%        | 0.88x      | +6           |
| 5      | 3000         | 9.0 kg          | +4%        | 0.85x      | +8           |
| 6      | 6000         | 12.0 kg         | +5%        | 0.82x      | +10          |

**Catatan balancing:**
- `reel_speed` < 1 artinya lebih cepat.
- `luck_bonus` kecil supaya tidak merusak rarity economy.

### 9.3 Mekanik “chance lepas” bila overweight
Jika `weight > max_safe_weight`:
- `over = weight - max_safe_weight`
- `escape_chance = clamp(0.05 + over * 0.08, 0.05, 0.55)`
Saat catch resolution, roll untuk menentukan lepas/tidak.

---

## 10) Area / Spot Unlock (Progression tambahan)
Unlock spot berbasis Rod Level atau Coins total (session).
Rekomendasi: **Rod Level** (lebih jelas).

Contoh:
- **Pond**: default
- **River**: Rod Lv 3
- **Sea**: Rod Lv 5

Setiap area punya:
- Drop rate rarity (lihat 4.1)
- Pool ikan berbeda (nama + weight range)
- Average value lebih tinggi

---

## 11) Fish Catalog (Contoh Konten Awal)
Minimal 3–5 ikan per area.

### Pond
- Carp (C) 0.2–0.9 kg
- Catfish (U) 0.4–1.5 kg
- Golden Minnow (R) 0.2–0.6 kg (rare kecil, “lucunya” mahal per kg)

### River
- Salmon (U) 0.8–2.2 kg
- Pike (R) 1.0–3.5 kg
- Crystal Eel (E) 1.2–2.8 kg

### Sea
- Tuna (R) 2.0–6.0 kg
- Swordfish (E) 3.0–8.0 kg
- Ancient Coelacanth (L) 5.0–12.0 kg

> Harga tetap pakai rumus (bagian 6) agar gampang ditambah konten.

---

## 12) Session Progression (tanpa save) — Rekomendasi Praktis
Karena progres reset saat restart:
- Pastikan **1 sesi 20–40 menit** sudah bisa:
  - naik rod ke Lv 4–5 (kalau main rapi)
  - unlock minimal River
- Hindari “grind” terlalu tinggi:
  - Batasi max rod di Lv 6 (sementara)
  - Legendary drop jangan terlalu jarang di Sea (2% cukup)

---

## 13) Future Hooks (Jika Save Data Sudah Ada)
Saat save sudah ada, progression bisa diperluas:
- Rod level 1–20
- Item tambahan: bait, lure, boat, cooler (kapasitas)
- Daily bonus / quests
- Fish encyclopedia permanent + reward collection

---

## 14) Data Model (Runtime, belum disimpan)
Struktur minimal yang perlu ada di memori:
- `coins: int`
- `rod_level: int`
- `bucket: FishInstance[]`

`FishInstance`:
- `fish_id`
- `rarity`
- `weight`
- `price`

Catatan: saat save ditambahkan, cukup serialize objek-objek ini.

---
