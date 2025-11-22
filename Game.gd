extends Node2D

# --- PATH SCENE ---
@onready var scene_transition_player = $SceneTransitionPlayer

const SCENE_RUANGBELAJAR_PATH = "res://Ruangbelajar.tscn"
const SCENE_BATIK_PATH = "res://Mode_LukisBatik.tscn"
const SCENE_UTAMA_PATH = "res://node_2d.tscn" 
# Tambahkan path untuk scene Puzzle dan Jepret di sini jika sudah ada
const SCENE_PUZZLE_PATH = "res://Mode_Puzzle.tscn" 
const SCENE_JEPRET_PATH = "res://Mode_Jepret.tscn" 

# --- REFERENSI NODE CIPTA ---
@onready var panel_pilihan_cipta = $UI_utama/Panel_Pilihan_Cipta 
@onready var btn_lukis_batik = $UI_utama/Panel_Pilihan_Cipta/Btn_LukisBatik 
@onready var btn_puzzle = $UI_utama/Panel_Pilihan_Cipta/Btn_Puzzle
@onready var btn_jepret = $UI_utama/Panel_Pilihan_Cipta/Btn_JepretBudaya
@onready var notif_label = $UI_utama/NotifLabel
@onready var btn_jual_aset = $Btn_JualAset

var aset_foto_siap_jual = 0 
const ENERGI_KREATIF_REWARD_JEPŘET = 10 
const BIAYA_LITERASI = 20
const BIAYA_KREATIF = 20
const KOIN_YANG_DIDAPAT = 75


func _ready():
	# Cek apakah AnimationPlayer ditemukan sebelum koneksi
	if is_instance_valid(scene_transition_player):
		scene_transition_player.animation_finished.connect(_on_fade_in_finished)
	else:
		print("FATAL ERROR: SceneTransitionPlayer tidak ditemukan. Transisi tidak akan bekerja.")

	# Sembunyikan panel pilihan cipta saat scene baru dimuat
	panel_pilihan_cipta.hide() 
	
	# KONEKSI TOMBOL-TOMBOL MENU PILIHAN CIPTA (Wajib)
	# Ini memastikan tombol-tombol di dalam panel berfungsi
	btn_lukis_batik.pressed.connect(_on_btn_lukis_batik_pressed)
	btn_puzzle.pressed.connect(_on_Btn_Puzzle_pressed)
	btn_jepret.pressed.connect(_on_Btn_JepretBudaya_pressed)
	btn_jual_aset.pressed.connect(jual_aset_terbuat)
	
	update_tombol_jual() # Panggil sekali saat mulai


# --- FUNGSI UTAMA PINDAH SCENE DENGAN TRANSISI ---

func _on_fade_in_finished(anim_name):
	if anim_name == "fade_in":
		var scene_path = ""
		
		# Penentuan Scene Tujuan Berdasarkan Global.mode_kreasi
		match Global.mode_kreasi:
			"BATIK":
				scene_path = SCENE_BATIK_PATH
			"PUZZLE":
				scene_path = SCENE_PUZZLE_PATH
			"JEPRET":
				scene_path = SCENE_JEPRET_PATH
			# Ini adalah default jika tidak ada mode kreasi yang dipilih (misalnya, klik tombol Belajar)
			_: 
				scene_path = SCENE_RUANGBELAJAR_PATH
		
		get_tree().change_scene_to_file(scene_path)
		print("Pindah scene sukses ke: ", scene_path)


# --- FUNGSI HANDLER TOMBOL IKON UTAMA ---

# TERHUBUNG KE IKON BELAJAR
func _on_icon_belajar_pressed() -> void:
	# Set default ke Ruangbelajar (tempat umum)
	Global.mode_kreasi = "NONE" 
	scene_transition_player.play("fade_in")
	print("Memulai transisi ke Ruangbelajar...")

# TERHUBUNG KE IKON CIPTA
func _on_icon_cipta_pressed():
	# Toggle (Tampilkan/Sembunyikan) panel pilihan saat ikon cipta diklik
	panel_pilihan_cipta.visible = not panel_pilihan_cipta.visible
	print("Toggle menu cipta. Visible: ", panel_pilihan_cipta.visible)


# --- FUNGSI HANDLER MENU PILIHAN CIPTA ---

func _on_btn_lukis_batik_pressed() -> void:
	# Set mode ke Batik, lalu mulai transisi
	Global.mode_kreasi = "BATIK"
	scene_transition_player.play("fade_in")

func _on_Btn_Puzzle_pressed():
	show_launch_notification()
	
	# Optional: Sembunyikan Panel Pilihan Cipta
	panel_pilihan_cipta.hide()
	
func show_launch_notification():
	notif_label.text = "PUZZLE BUDAYA:\nGAME AKAN SEGERA DILUNCURKAN!"
	notif_label.show()
	
	# Buat notifikasi menghilang setelah 2.5 detik
	var timer = get_tree().create_timer(2.5)
	await timer.timeout
	notif_label.hide()

func _on_Btn_JepretBudaya_pressed():
	# 1. Nonaktifkan Menu Pilihan Cipta
	panel_pilihan_cipta.hide() 
	
	# 2. Panggil fungsi simulasi Jepret Instan
	simulasi_jepret_instan()
	
func simulasi_jepret_instan():
	const ENERGI_KREATIF_REWARD_JEPRET = 10
	
	# --- LOGIKA FINAL: HANYA MENAMBAH RESOURCE & STOK ---
	
	# 1. TAMBAH ENERGI KREATIF (+10)
	Global.energi_kreatif += ENERGI_KREATIF_REWARD_JEPŘET
	
	# 2. Tambahkan Aset Siap Jual
	aset_foto_siap_jual += 1
	
	# 3. Feedback Visual yang Menjual
	var pesan = "SUKSES! Aset Foto Budaya siap dijual.\n"
	pesan += "Energi Kreatif bertambah: +" + str(ENERGI_KREATIF_REWARD_JEPRET)
	
	show_notification(pesan)
	
	# 4. Update Log (Final)
	print("Jepret Budaya Selesai. Energi Kreatif:", Global.energi_kreatif, " Aset Siap Jual:", aset_foto_siap_jual)
	
	# Panggil fungsi untuk menampilkan tombol Jual (yang harusnya ada di Scene utama)
	update_tombol_jual()

func show_notification(message):
	# Fungsi ini menampilkan notifikasi dengan timer
	notif_label.text = message
	notif_label.show()
	
	var timer = get_tree().create_timer(2.0)
	await timer.timeout
	notif_label.hide()

# --- FUNGSI NAVIGASI UMUM ---

func go_back():
	get_tree().change_scene_to_file(SCENE_UTAMA_PATH)
	print("Kembali ke Scene Utama.")

func _on_btn_kembali_pressed() -> void:
	# Tombol Kembali di Scene Utama bisa dihubungkan ke fungsi go_back() ini
	go_back()

func jual_aset_terbuat():
	const BIAYA_LITERASI = 20
	const BIAYA_KREATIF = 20
	const KOIN_YANG_DIDAPAT = 75
	
	# 1. CEK KONDISI JUAL: APAKAH ADA ASET?
	if aset_foto_siap_jual <= 0:
		show_notification("❌ TIDAK ADA ASET FOTO YANG SIAP DIJUAL.")
		return
		
	# 2. CEK KONDISI JUAL: APAKAH ENERGI CUKUP?
	# PERBAIKAN: Cek Literasi dan Kreatif (menggunakan nama variabel elo)
	if Global.literasi_level < BIAYA_LITERASI or Global.energi_kreatif < BIAYA_KREATIF: 
		show_notification("❌ TRANSAKSI DIBATALKAN! Biaya Lit. (" + str(BIAYA_LITERASI) + ") atau Kreatif (" + str(BIAYA_KREATIF) + ") tidak cukup.")
		return
		
	# --- PROSES MONETISASI BERHASIL ---

	# 3. BIAYA: KURANGI RESOURCE (-20 Literasi, -20 Kreatif)
	Global.literasi_level -= BIAYA_LITERASI
	Global.energi_kreatif -= BIAYA_KREATIF # AKAN BERKURANG KARENA SEKARANG SUDAH DICEK CUKUP
	
	# 4. PENDAPATAN: TAMBAH KOIN CIPTA
	Global.koin_cipta += KOIN_YANG_DIDAPAT
	
	# 5. KURANGI STOK ASET & UPDATE TOMBOL
	aset_foto_siap_jual -= 1
	update_tombol_jual() # <-- FUNGSI BARU
	
	# 6. Feedback Visual
	var pesan = "✅ PENJUALAN SUKSES! Aset terjual.\nPENDAPATAN: +" + str(KOIN_YANG_DIDAPAT) + " Koin."
	show_notification(pesan)
	# 1. CEK KONDISI JUAL: APAKAH ADA ASET?
	if aset_foto_siap_jual <= 0:
		show_notification("❌ TIDAK ADA ASET FOTO YANG SIAP DIJUAL.")
		return
		
	# 1. CEK KONDISI JUAL: APAKAH ENERGI CUKUP? (Menggunakan NAMA BENAR)
	if Global.literasi_level < BIAYA_LITERASI or Global.energi_kreatif < BIAYA_KREATIF: 
		# Cek ini harus menggunakan NAMA YANG ADA: Global.kreatif_energi
		# Tapi karena Global lo pake energi_kreatif, kita pakai itu.
		# ASUMSI: Global.gd lo yang terakhir sudah benar: var energi_kreatif = 0
		
		show_notification("❌ TRANSAKSI DIBATALKAN! Biaya Lit. (" + str(BIAYA_LITERASI) + ") atau Kreatif (" + str(BIAYA_KREATIF) + ") tidak cukup.")
		return
		
	# --- PROSES MONETISASI BERHASIL (RESOURCE CUKUP) ---

	# 3. BIAYA: KURANGI RESOURCE KARENA DIJUAL
	Global.literasi_level -= BIAYA_LITERASI
	Global.energi_kreatif -= BIAYA_KREATIF
	
	# 4. PENDAPATAN: TAMBAH KOIN CIPTA
	Global.koin_cipta += KOIN_YANG_DIDAPAT
	
	# 5. KURANGI STOK ASET
	aset_foto_siap_jual -= 1
	
	# 6. Feedback Visual
	pesan = "✅ PENJUALAN SUKSES! Aset terjual di Cipta Market.\n"
	pesan += "Biaya Lit. -" + str(BIAYA_LITERASI) + ", Kreatif -" + str(BIAYA_KREATIF) + ". PENDAPATAN: +" + str(KOIN_YANG_DIDAPAT) + " Koin."
	show_notification(pesan)
	
	print("Penjualan Sukses! Koin:", Global.koin_cipta, " Lit:", Global.literasi_level, " Kreatif:", Global.energi_kreatif)


func update_tombol_jual():
	if aset_foto_siap_jual > 0:
		btn_jual_aset.text = "JUAL ASET FOTO (" + str(aset_foto_siap_jual) + " Siap Jual)"
		btn_jual_aset.show()
	else:
		btn_jual_aset.hide()
