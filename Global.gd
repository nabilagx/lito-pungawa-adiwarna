extends Node

# --- 1. VARIABEL UTAMA (DATABASE GAME) ---
var koin_cipta = 990          # Modal awal 100 (biar ga langsung kalah)
var literasi_level = 100
var energi_kreatif = 100
var inventory_aset = 0        # Stok barang siap jual
var mode_kreasi = ""
var sudah_menang = false

const LITERASI_MAKS = 100
const ENERGI_MAKS = 100

# --- 2. PENGATURAN LOGIKA GAME (BALANCING) ---
const BIAYA_SEWA = 30         # Jumlah koin dipotong buat sewa 20, lustrik 10
const WAKTU_TAGIHAN = 600.0    # Detik (seberapa cepat tagihan datang)
const TARGET_MENANG = 1000    # Target koin untuk tamat
const HARGA_JUAL = 150        # Pendapatan saat jual
const COST_LITERASI = 10      # Biaya ilmu saat jual
const COST_KREATIF = 10       # Biaya tenaga saat jual

# --- 3. SISTEM AUDIO & NOTIFIKASI ---
var bgm_player: AudioStreamPlayer
const TRACK_BGM = preload("res://Aset New/audio/trackA.mp3") 
var bgm_mute_state = false

@onready var main_notif_label = get_node_or_null("/root/Node2D/UI_utama/NotifLabel")

# ==========================================================
#                    FUNGSI UTAMA GODOT
# ==========================================================

func _ready():
	# A. SETUP MUSIK GLOBAL
	# Kita bikin node musik lewat kode biar nempel terus di Global
	bgm_player = AudioStreamPlayer.new()
	add_child(bgm_player)
	bgm_player.stream = TRACK_BGM
	bgm_player.volume_db = -10.0 # Atur volume (makin minus makin kecil)
	bgm_player.play()
	print("Sistem Global: Musik dimulai.")

	# B. SETUP TIMER TAGIHAN (ANCAMAN GAME OVER)
	var sewa_timer = Timer.new()
	sewa_timer.wait_time = WAKTU_TAGIHAN
	sewa_timer.autostart = true
	sewa_timer.connect("timeout", Callable(self, "_on_sewa_tagihan"))
	add_child(sewa_timer)
	print("Sistem Global: Timer tagihan berjalan.")

# ==========================================================
#                  CORE LOOP GAMEPLAY
# ==========================================================

# 1. BELAJAR (Nambah Literasi)
func aksi_belajar():
	if literasi_level < LITERASI_MAKS:
		literasi_level = clamp(literasi_level + 20, 0, LITERASI_MAKS)
		show_notification("Belajar Budaya Selesai! (+20 Literasi)")
	else:
		show_notification("Otak sudah penuh ilmu!")

# 2. MEMBUAT (Tukar Literasi jadi Kreatif & Stok)
func aksi_bikin():
	if literasi_level >= 10:
		energi_kreatif = clamp(energi_kreatif + 20, 0, ENERGI_MAKS)
		inventory_aset += 1
		show_notification("Karya Jadi! (+Stok, +20 Kreatif)")
	else:
		show_notification("Gagal! Kurang baca buku (Literasi rendah)")

# 3. MENJUAL (Tukar Energi & Stok jadi Uang) -> INI CARA MENANG
func aksi_jual():
	if inventory_aset > 0:
		if literasi_level >= COST_LITERASI and energi_kreatif >= COST_KREATIF:
			# Kurangi Resource
			literasi_level -= COST_LITERASI
			energi_kreatif -= COST_KREATIF
			inventory_aset -= 1
			
			# Tambah Duit
			koin_cipta += HARGA_JUAL
			show_notification("LAKU KERAS! (+" + str(HARGA_JUAL) + " Koin)")
			
			cek_kondisi_menang()
		else:
			show_notification("Energi habis! Lito kecapekan.")
	else:
		show_notification("Gak ada barang buat dijual!")

# ==========================================================
#               LOGIKA MENANG & KALAH
# ==========================================================

# Dipanggil otomatis oleh Timer setiap 30 detik
func _on_sewa_tagihan():
	# Cek pause standar
	if get_tree().paused:
		return

	# --- [BAGIAN INI YANG ELO LUPA PASANG!] ---
	# Kita suruh Timer ngintip saldo dulu.
	# Kalau saldo udah 1000+ DAN belum dicap menang, panggil fungsi menang SEKARANG JUGA!
	if koin_cipta >= TARGET_MENANG and sudah_menang == false:
		cek_kondisi_menang()
		return # <--- INI KUNCINYA! Dia bakal stop di sini dan GAK BAKAL motong duit.

	# --- KE BAWAHNYA SAMA AJA ---
	var bayar_berapa = 0

	# CEK STATUS: Udah jadi juragan belum?
	if sudah_menang == true:
		bayar_berapa = 10 # Diskon Juragan
		show_notification("Pajak Juragan! (-10 Koin)")
	else:
		bayar_berapa = BIAYA_SEWA # Masih 20 (Rakyat Jelata)
		show_notification("Bayar Listrik Sanggar! (-20 Koin)")

	# Potong Duitnya
	koin_cipta -= bayar_berapa
	print("Tagihan ditarik: ", bayar_berapa, " | Sisa: ", koin_cipta)
	
	# Tetep cek kalah kalau misal bangkrut lagi
	if koin_cipta < 0:
		game_over()

func cek_kondisi_menang():
	# Cek duit cukup DAN belum pernah menang sebelumnya
	if koin_cipta >= TARGET_MENANG and sudah_menang == false:
		print("MENANG!")
		
		# 1. Tandain kalau dia udah pernah menang (biar gak muncul terus tiap jual barang)
		sudah_menang = true 
		
		# 2. Pause Game (Biar momennya dapet)
		get_tree().paused = true 
		
		# 3. Panggil Layar Menang
		tampilkan_popup_menang()
	
func tampilkan_popup_menang():
	if has_node("LayarGameMenang"): return

	var layer = CanvasLayer.new()
	layer.name = "LayarGameMenang"
	layer.process_mode = Node.PROCESS_MODE_ALWAYS 
	add_child(layer)
	
	# Background
	var bg = ColorRect.new()
	bg.color = Color(0.2, 0.2, 0, 0.9)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	layer.add_child(bg)
	
	# Center Container
	var center_con = CenterContainer.new()
	center_con.set_anchors_preset(Control.PRESET_FULL_RECT)
	layer.add_child(center_con)
	
	# VBox
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 20)
	center_con.add_child(vbox)
	
	# --- TEKS JUDUL ---
	var judul = Label.new()
	judul.text = "SANGGAR SUKSES!" 
	judul.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	judul.add_theme_font_size_override("font_size", 80) 
	judul.add_theme_color_override("font_color", Color(1, 0.84, 0)) # Emas
	vbox.add_child(judul)
	
	var pesan = Label.new()
	pesan.text = "Selamat! Target 1000 Koin Tercapai.\nSanggar kini aman dari penggusuran."
	pesan.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(pesan)
	
	# Spacer
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 30)
	vbox.add_child(spacer)
	
	# --- TOMBOL 1: LANJUT JADI JURAGAN (Sesuai Request Lo) ---
	var btn_lanjut = Button.new()
	btn_lanjut.text = " ▶ LANJUT (MODE JURAGAN) "
	btn_lanjut.custom_minimum_size = Vector2(350, 60)
	btn_lanjut.add_theme_font_size_override("font_size", 24)
	# Warna Ijo Duit
	btn_lanjut.add_theme_color_override("font_color", Color(0.5, 1, 0.5)) 
	
	# Konek ke fungsi baru buat lanjutin game
	btn_lanjut.pressed.connect(self._on_lanjut_clicked)
	
	var con_lanjut = CenterContainer.new()
	con_lanjut.add_child(btn_lanjut)
	vbox.add_child(con_lanjut)
	
	# Spacer Kecil
	var spacer2 = Control.new()
	spacer2.custom_minimum_size = Vector2(0, 10)
	vbox.add_child(spacer2)

	# --- TOMBOL 2: ULANG DARI NOL (Opsional kalo mau tobat) ---
	var btn_ulang = Button.new()
	btn_ulang.text = " ↻ TAMATKAN & ULANG "
	btn_ulang.flat = true # Tombol tipis aja
	btn_ulang.pressed.connect(self._on_restart_clicked)
	
	var con_ulang = CenterContainer.new()
	con_ulang.add_child(btn_ulang)
	vbox.add_child(con_ulang)
	
func _on_lanjut_clicked():
	print("Lanjut Mode Juragan...")
	
	# 1. Hapus Layar Menang
	if has_node("LayarGameMenang"):
		get_node("LayarGameMenang").queue_free()
	
	# 2. Jalanin Game Lagi (UNPAUSE)
	get_tree().paused = false
	
	# 3. Kasih tau player statusnya
	show_notification("Mode Juragan Aktif! Listrik cuma 10 Koin.")
	
	# Catatan: Variabel 'sudah_menang' kan udah jadi TRUE pas di cek_kondisi_menang tadi.
	# Jadi otomatis fungsi _on_sewa_tagihan lo bakal baca itu dan kasih diskon.

# ==========================================================
#              LAYAR KEMATIAN (DRAMATIS)
# ==========================================================

func game_over():
	print("GAME OVER TRIGGERED")
	
	# 1. Matikan Musik
	if bgm_player:
		bgm_player.stop()
	
	# 2. Pause Game (Semua berhenti bergerak)
	get_tree().paused = true
	
	# 3. Kosongkan Data (Hukuman)
	literasi_level = 0
	energi_kreatif = 0
	inventory_aset = 0
	
	# 4. Munculkan UI Game Over
	tampilkan_popup_kalah()

func tampilkan_popup_kalah():
	# Cek biar gak double
	if has_node("LayarGameOver"): 
		return

	var layer = CanvasLayer.new()
	layer.name = "LayarGameOver"
	layer.process_mode = Node.PROCESS_MODE_ALWAYS 
	add_child(layer)
	
	# 1. Background Gelap (Full Layar)
	var bg = ColorRect.new()
	bg.color = Color(0, 0, 0, 0.9)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	layer.add_child(bg)
	
	# 2. WADAH PENENGAH OTOMATIS (CenterContainer)
	# Ini rahasianya! Dia bakal maksa anak-anaknya ke tengah layar.
	var center_con = CenterContainer.new()
	center_con.set_anchors_preset(Control.PRESET_FULL_RECT)
	layer.add_child(center_con)
	
	# 3. WADAH SUSUN VERTIKAL (VBoxContainer)
	# Biar Judul, Teks, sama Tombol tersusun rapi ke bawah
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 30) # Jarak antar baris
	center_con.add_child(vbox)
	
	# --- ISI KONTENNYA ---
	
	# Judul Besar
	var judul = Label.new()
	judul.text = "SANGGAR TUTUP!"   # <--- GANTI JUDUL DISINI
	judul.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	# Ganti angka 64 jadi 80 biar makin gede nampol
	judul.add_theme_font_size_override("font_size", 80) 
	judul.add_theme_color_override("font_color", Color(1, 0.2, 0.2)) # Merah agak terang
	vbox.add_child(judul)
	
	# Pesan Moral (Unik)
	var pesan = Label.new()
	# GANTI PESAN DISINI (Pake \n buat ganti baris)
	pesan.text = "Tanpa kemandirian ekonomi,\nbudaya sulit bertahan di era modern.\n\nKamu gagal menyeimbangkan\nantara 'Berkarya' dan 'Berniaga'."
	pesan.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	# Ganti ukuran font jadi 28 biar jelas di HP
	pesan.add_theme_font_size_override("font_size", 28)
	pesan.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9)) # Putih agak abu
	vbox.add_child(pesan)
	
	# Jarak Kosong Dikit (Spacer)
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 40) # Kasih jarak lebih lega
	vbox.add_child(spacer)
	
	# --- TOMBOL YANG LEBIH JELAS & GAGAH ---
	var tombol = Button.new()
	tombol.text = " ↻ ULANGI PERJUANGAN " # Tambah ikon panah biar keren
	
	# 1. Bikin Ukuran Tombol Gede
	tombol.custom_minimum_size = Vector2(350, 80) 
	
	# 2. Bikin Tulisan di Dalemnya Gede
	tombol.add_theme_font_size_override("font_size", 30)
	
	# 3. Warna Teks KUNING EMAS (Biar Kelihatan Harapan)
	tombol.add_theme_color_override("font_color", Color(1, 0.8, 0.2)) 
	# Opsional: Kasih outline hitam di teks biar makin jelas
	tombol.add_theme_constant_override("outline_size", 2)
	tombol.add_theme_color_override("font_outline_color", Color.BLACK)
	
	# Sambungin fungsi restart
	tombol.pressed.connect(self._on_restart_clicked)
	
	# Masukin ke container biar tetep di tengah
	var tombol_container = CenterContainer.new() 
	tombol_container.add_child(tombol)
	vbox.add_child(tombol_container)

func _on_restart_clicked():
	print("Restarting Game...")
	
	# 1. HAPUS UI (Cek dua-duanya: Kalah atau Menang)
	if has_node("LayarGameOver"):
		get_node("LayarGameOver").queue_free()
	if has_node("LayarGameMenang"):
		get_node("LayarGameMenang").queue_free()
	
	# 2. Reset Variabel (Pilih satu nilai modal awal, misal 1000 kayak di deklarasi atas)
	koin_cipta = 1000 
	literasi_level = 100
	energi_kreatif = 100
	inventory_aset = 0 
	
	# 3. Nyalakan Musik & Waktu
	if bgm_player:
		bgm_player.play()
	
	get_tree().paused = false 
	get_tree().reload_current_scene()

# ==========================================================
#                   HELPER (AUDIO & NOTIF)
# ==========================================================

func toggle_mute():
	bgm_mute_state = !bgm_mute_state
	bgm_player.stream_paused = bgm_mute_state

func show_notification(message):
	# Mencari node 'NotifLabel' di scene manapun yang sedang aktif
	var current_scene = get_tree().current_scene
	if current_scene:
		var label = current_scene.find_child("NotifLabel", true, false)
		if label:
			label.text = message
			label.show()
			await get_tree().create_timer(2.0).timeout
			label.hide()
		else:
			print("Notif (Tanpa Label): ", message)
