extends Node2D

# --- PATH SCENE ---
@onready var scene_transition_player = $SceneTransitionPlayer

const SCENE_RUANGBELAJAR_PATH = "res://Ruangbelajar.tscn"
const SCENE_BATIK_PATH = "res://Mode_LukisBatik.tscn"
const SCENE_UTAMA_PATH = "res://node_2d.tscn"
const SCENE_PUZZLE_PATH = "res://Mode_Puzzle.tscn"
const SCENE_JEPRET_PATH = "res://Mode_Jepret.tscn"
const SCENE_CIPTA_MARKET_PATH = "res://Cipta_Market.tscn"

# --- REFERENSI NODE AUDIO & KONTROL ---
@onready var bgm_player_node = $BGMPlayer
@onready var btn_mute_toggle = $Btn_MuteToggle # Tombol Mute/Unmute
# DIHAPUS: @onready var btn_ganti_audio = $Btn_GantiAudio

# --- REFERENSI NODE CIPTA & UI LAIN ---
@onready var panel_pilihan_cipta = $UI_utama/Panel_Pilihan_Cipta
@onready var btn_lukis_batik = $UI_utama/Panel_Pilihan_Cipta/Btn_LukisBatik
@onready var btn_puzzle = $UI_utama/Panel_Pilihan_Cipta/Btn_Puzzle
@onready var btn_jepret = $UI_utama/Panel_Pilihan_Cipta/Btn_JepretBudaya
@onready var notif_label = $UI_utama/NotifLabel
@onready var btn_jual_aset = $Btn_JualAset
@onready var icon_jual_market = $UI_utama/cotainer_bawah/Panel_jual/icon_jual

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

	panel_pilihan_cipta.hide()
	
	# PENTING: Daftarkan AudioPlayer ke Global.gd saat scene dimuat
	if is_instance_valid(bgm_player_node) and Global.bgm_player == null:
		
		# --- LOGIKA PERSISTENCE ---
		bgm_player_node.reparent(get_tree().root) 
		bgm_player_node.set_process_mode(Node.PROCESS_MODE_ALWAYS) 
		Global.setup_bgm_player(bgm_player_node)
		# HAPUS BARIS INI: bgm_player_node.play() <--- INI KARENA BISA TERPANGGIL GANDA
		
		print("BGM Global berhasil dipindahkan dan mulai diputar.")
	
	# KONEKSI TOMBOL MUTE (PERBAIKAN: DITAMBAHKAN KEMBALI)
	if is_instance_valid(btn_mute_toggle):
		btn_mute_toggle.pressed.connect(Global.toggle_mute)

	# KONEKSI TOMBOL-TOMBOL MENU PILIHAN CIPTA (Wajib)
	btn_lukis_batik.pressed.connect(_on_btn_lukis_batik_pressed)
	btn_puzzle.pressed.connect(_on_Btn_Puzzle_pressed)
	btn_jepret.pressed.connect(_on_Btn_JepretBudaya_pressed)
	btn_jual_aset.pressed.connect(jual_aset_terbuat)
	
	update_tombol_jual()
	
	if is_instance_valid(icon_jual_market):
		icon_jual_market.pressed.connect(_on_icon_jual_market_pressed)
	

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
			"MARKET":
				scene_path = SCENE_CIPTA_MARKET_PATH
			_:
				scene_path = SCENE_RUANGBELAJAR_PATH
		
		get_tree().change_scene_to_file(scene_path)
		print("Pindah scene sukses ke: ", scene_path)


# --- FUNGSI PINDAH KE CIPTA MARKET (DIPICU OLEH ICON JUAL) ---

func _on_icon_jual_market_pressed():
	Global.mode_kreasi = "MARKET"
	scene_transition_player.play("fade_in")
	print("Mulai transisi ke Cipta Market.")


# --- FUNGSI HANDLER TOMBOL IKON UTAMA ---

# TERHUBUNG KE IKON BELAJAR
func _on_icon_belajar_pressed() -> void:
	Global.mode_kreasi = "NONE"
	scene_transition_player.play("fade_in")
	print("Memulai transisi ke Ruangbelajar...")

# TERHUBUNG KE IKON CIPTA
func _on_icon_cipta_pressed():
	panel_pilihan_cipta.visible = not panel_pilihan_cipta.visible
	print("Toggle menu cipta. Visible: ", panel_pilihan_cipta.visible)


# --- FUNGSI HANDLER MENU PILIHAN CIPTA ---

func _on_btn_lukis_batik_pressed() -> void:
	Global.mode_kreasi = "BATIK"
	scene_transition_player.play("fade_in")

func _on_Btn_Puzzle_pressed():
	Global.mode_kreasi = "PUZZLE"
	scene_transition_player.play("fade_in")
	panel_pilihan_cipta.hide()
	print("Mulai transisi ke Scene Puzzle.")
	
func _on_Btn_JepretBudaya_pressed():
	panel_pilihan_cipta.hide()
	simulasi_jepret_instan()

func simulasi_jepret_instan():
	const ENERGI_KREATIF_REWARD_JEPŘET = 10
	
	Global.energi_kreatif += ENERGI_KREATIF_REWARD_JEPŘET
	aset_foto_siap_jual += 1
	
	var pesan = "SUKSES! Aset Foto Budaya siap dijual.\n"
	pesan += "Energi Kreatif bertambah: +" + str(ENERGI_KREATIF_REWARD_JEPŘET)
	
	show_notification(pesan)
	print("Jepret Budaya Selesai. Energi Kreatif:", Global.energi_kreatif, " Aset Siap Jual:", aset_foto_siap_jual)
	update_tombol_jual()

func show_notification(message):
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
	go_back()

# --- FUNGSI MONETISASI ---

func jual_aset_terbuat():
	const BIAYA_LITERASI = 20
	const BIAYA_KREATIF = 20
	const KOIN_YANG_DIDAPAT = 75

	if aset_foto_siap_jual <= 0:
		show_notification("❌ TIDAK ADA ASET FOTO YANG SIAP DIJUAL.")
		return

	if Global.literasi_level < BIAYA_LITERASI or Global.energi_kreatif < BIAYA_KREATIF:
		show_notification("❌ TRANSAKSI DIBATALKAN! energi tidak cukup.")
		return

	Global.literasi_level -= BIAYA_LITERASI
	Global.energi_kreatif -= BIAYA_KREATIF
	Global.koin_cipta += KOIN_YANG_DIDAPAT
	aset_foto_siap_jual -= 1
	update_tombol_jual()

	var pesan = "✅ PENJUALAN SUKSES! Aset terjual di Cipta Market.\n"
	pesan += "Pendapatan: +" + str(KOIN_YANG_DIDAPAT) + " Koin."
	show_notification(pesan)
	
	print("Penjualan Sukses! Koin:", Global.koin_cipta, " Lit:", Global.literasi_level, " Kreatif:", Global.energi_kreatif)


func update_tombol_jual():
	if aset_foto_siap_jual > 0:
		btn_jual_aset.text = "JUAL ASET FOTO (" + str(aset_foto_siap_jual) + " Siap Jual)"
		btn_jual_aset.show()
	else:
		btn_jual_aset.hide()
