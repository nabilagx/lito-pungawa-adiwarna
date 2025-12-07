extends Control

# --- DEKLARASI NODE ---
# Layer yang berisi GRID ASET (Konten utama yang akan di-hide)
@onready var panel_jual_grid = $jual 
@onready var panel_transaksi_sukses = $terjual 
@onready var btn_kembali_transaksi = $terjual/kembali 

# Tombol di Market Grid (HARUS SELALU VISIBLE)
@onready var btn_kolaborasi_demo = $kolaborasi_demo 

# Layer Detail Kolaborasi
@onready var panel_kolaborasi_detail = $demo
@onready var btn_mulai_tugas = $demo/mulai

# Tombol Jual Aset
@onready var btn_jual_batik = $jual/jual_150_koin

# NOTIFIKASI BARU (Ditarik dari Scene Tree)
@onready var notif_label = $NotifLabel 


# --- KONSTANTA & PATH ---
const HARGA_BATIK = 150
const SCENE_MAIN_HUB_PATH = "res://node_2d.tscn" 
const NOTIF_DURATION = 3.0 

# --- KONSTANTA BIAYA MONETISASI (Dari proposal: Biaya Lit 20, Kreatif 20) ---
const BIAYA_LITERASI = 20
const BIAYA_KREATIF = 20


func _ready():
	# 1. Sembunyikan Layer Transaksional, Detail Kolaborasi, dan Notif di awal
	if is_instance_valid(panel_transaksi_sukses):
		panel_transaksi_sukses.hide()
	if is_instance_valid(panel_kolaborasi_detail):
		panel_kolaborasi_detail.hide()
	if is_instance_valid(notif_label):
		notif_label.hide()
	
	# 2. KONEKSI TOMBOL UTAMA
	if is_instance_valid(btn_jual_batik):
		btn_jual_batik.pressed.connect(_on_jual_150_koin_pressed)
	
	if is_instance_valid(btn_kembali_transaksi):
		btn_kembali_transaksi.pressed.connect(_on_kembali_pressed) 
	
	if is_instance_valid(btn_kolaborasi_demo):
		btn_kolaborasi_demo.pressed.connect(_on_kolaborasi_demo_pressed)
		
	if is_instance_valid(btn_mulai_tugas):
		btn_mulai_tugas.pressed.connect(_on_mulai_pressed)

	print("Cipta Market Aktif.")


# --- FUNGSI NOTIFIKASI LOKAL (3 DETIK) ---

func show_notification(message):
	if is_instance_valid(notif_label):
		notif_label.text = message
		notif_label.show()
		
		var timer = get_tree().create_timer(NOTIF_DURATION)
		timer.timeout.connect(func(): notif_label.hide())
	else:
		print("Notifikasi (UI Gagal): " + message)


# --- FUNGSI JUAL ASET BATIK (DENGAN CHECK BIAYA) ---

func _on_jual_150_koin_pressed() -> void:
	if Global.literasi_level < BIAYA_LITERASI or Global.energi_kreatif < BIAYA_KREATIF:
		var pesan_gagal = "❌ TRANSAKSI GAGAL! Biaya Lit. (" + str(BIAYA_LITERASI) + ") atau Kreatif (" + str(BIAYA_KREATIF) + ") tidak cukup."
		show_notification(pesan_gagal)
		print("Transaksi dibatalkan: Energi tidak cukup.")
		return
		
	# --- PROSES TRANSAKSI BERHASIL ---
	
	# 1. BIAYA: KURANGI RESOURCE 
	Global.literasi_level -= BIAYA_LITERASI
	Global.energi_kreatif -= BIAYA_KREATIF
	
	# 2. MONETISASI: Tambah Koin Cipta
	Global.koin_cipta += HARGA_BATIK 
	
	# 3. TRANSISI LAYER: Market Grid --> Transaksi Sukses
	if is_instance_valid(panel_jual_grid):
		panel_jual_grid.hide() 
		
	if is_instance_valid(btn_kolaborasi_demo):
		btn_kolaborasi_demo.hide()
	
	if is_instance_valid(panel_transaksi_sukses):
		panel_transaksi_sukses.show()
	
	# 4. Nonaktifkan Tombol Jual Batik
	btn_jual_batik.disabled = true
	
	# 5. Feedback Notifikasi SUKSES
	var pesan_sukses = "✅ PENJUALAN SUKSES! -" + str(BIAYA_LITERASI) + " Lit., -" + str(BIAYA_KREATIF) + " Kre.\nPENDAPATAN: +" + str(HARGA_BATIK) + " Koin."
	show_notification(pesan_sukses)
	
	print("Penjualan Sukses! Koin:", Global.koin_cipta, " Lit:", Global.literasi_level, " Kreatif:", Global.energi_kreatif)


# --- FUNGSI KOLABORASI ---

func _on_kolaborasi_demo_pressed() -> void:
	# 1. HIDE MARKET GRID UTAMA
	if is_instance_valid(panel_jual_grid):
		panel_jual_grid.hide()
		
	# 2. SHOW DETAIL TANTANGAN
	if is_instance_valid(panel_kolaborasi_detail):
		panel_kolaborasi_detail.show()
	
	print("Masuk ke Detail Tantangan Kolaborasi.")


func _on_mulai_pressed() -> void:
	# Logic Notifikasi Pengembangan
	var pesan_notif = "FITUR INI DITAHAP PENGEMBANGAN."
	
	# 1. Nonaktifkan tombol mulai
	if is_instance_valid(btn_mulai_tugas):
		btn_mulai_tugas.disabled = true
	
	# 2. Tampilkan Notifikasi LOKAL
	show_notification(pesan_notif)

	# 3. **TUNGGU NOTIFIKASI SEBELUM PINDAH SCENE**
	var timer = get_tree().create_timer(NOTIF_DURATION)
	await timer.timeout # Tunggu 3 detik penuh

	# 4. Transisi kembali ke Main Hub (node_2d.tscn)
	get_tree().change_scene_to_file(SCENE_MAIN_HUB_PATH)
	
	print("Kembali ke Main Hub dari Notifikasi Pengembangan.")


# --- FUNGSI KEMBALI UMUM (DARI LAYER TRANSAKSI/SUKSES) ---

func _on_kembali_pressed():
	# PINDAH SCENE: Kembali ke node_2d.tscn (Main Hub)
	get_tree().change_scene_to_file(SCENE_MAIN_HUB_PATH)
	
	print("Kembali ke Main Hub dari Cipta Market.")
