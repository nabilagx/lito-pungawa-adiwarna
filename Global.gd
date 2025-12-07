extends Node

# --- 1. VARIABEL UTAMA (DATABASE GAME) ---
var koin_cipta = 20          # Modal awal 100 (biar ga langsung kalah)
var literasi_level = 0
var energi_kreatif = 0
var inventory_aset = 0        # Stok barang siap jual
var mode_kreasi = ""

const LITERASI_MAKS = 100
const ENERGI_MAKS = 100

# --- 2. PENGATURAN LOGIKA GAME (BALANCING) ---
const BIAYA_SEWA = 20         # Jumlah koin dipotong buat sewa
const WAKTU_TAGIHAN = 30.0    # Detik (seberapa cepat tagihan datang)
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
	# Jangan potong duit kalau game lagi Game Over/Pause
	if get_tree().paused:
		return

	koin_cipta -= BIAYA_SEWA
	print("Tagihan sewa ditarik! Sisa koin: ", koin_cipta)
	show_notification("Bayar Listrik Sanggar! (-" + str(BIAYA_SEWA) + " Koin)")
	
	# CEK KONDISI KALAH
	if koin_cipta < 0:
		game_over()

func cek_kondisi_menang():
	if koin_cipta >= TARGET_MENANG:
		print("MENANG!")
		show_notification("SANGGAR LUNAS! KAMU MENANG!")
		# Bisa tambahkan: get_tree().change_scene_to_file("res://Scenes/WinScreen.tscn")

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
	print("Tombol Restart Ditekan...")
	
	# 1. HAPUS LAYAR HITAMNYA (Ini solusi bug-nya!)
	var popup = get_node_or_null("LayarGameOver")
	if popup:
		popup.queue_free() # Buang layer ke tempat sampah
	
	# 2. Reset Variabel ke Awal
	koin_cipta = 100
	literasi_level = 0    # Pastikan ini 0
	energi_kreatif = 0    # Pastikan ini 0
	inventory_aset = 0    # Stok barang hilang
	
	# 3. Nyalakan Game Lagi
	if bgm_player:
		bgm_player.play()
	
	get_tree().paused = false # Jalanin waktu lagi
	get_tree().reload_current_scene() # Refresh tampilan level
	print("Restarting Game...")
	
	# Reset Modal
	koin_cipta = 20 
	
	# Nyalakan Musik Lagi
	if bgm_player:
		bgm_player.play()
	
	# Jalankan Game Lagi
	get_tree().paused = false
	
	# Reload Scene (Bersihkan UI Game Over tadi otomatis)
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
