extends Control

# --- REFERENSI NODE DAN PATH ---

# Pastikan path ke node yang ada di scene (Mode_LukisBatik.tscn) lo
@onready var btn_pilih_kawung = $Bingkai_9x16/Padding_Container/Content_VBox/Pilihan_Kawung/Thumbnail_Kawung/Btn_Pilih_Kawung

# Pastikan path ke node yang ada di scene saat ini (LukisBatik_Kawung.tscn)
@onready var btn_kembali = $Btn_Kembali
@onready var panel_pola_kuas1 = $Panel_Pola_Kuas1
@onready var panel_pola_kuas2 = $Panel_Pola_Kuas2
@onready var panel_pola_kuas3 = $Panel_Pola_Kuas3
@onready var btn_klaim_reward = $Panel_Pola_Kuas3/Btn_Klaim_Reward

# Tombol-tombol di dalam panel
@onready var btn_kuas_1 = $Panel_Pola_Kuas1/Btn_Kuas_1
@onready var btn_kuas_2 = $Panel_Pola_Kuas2/Btn_Kuas_2

const SCENE_KEMBALI_PATH = "res://node_2d.tscn" 
const SCENE_LUKIS_KAWUNG_PATH = "res://LukisBatik_Kawung.tscn" 
const SCENE_PILIHAN_BATIK_PATH = "res://node_2d.tscn" # Path kembali ke pilihan batik

const ENERGI_KREATIF_REWARD = 40


func _ready():
	# --- VERIFIKASI AWAL: Pastikan Layer 2 dan Layer 3 tersembunyi ---
	
	# PENTING: Lakukan hide() hanya jika node itu valid, ini mencegah crash NULL.
	if is_instance_valid(panel_pola_kuas2):
		panel_pola_kuas2.hide()
	
	if is_instance_valid(panel_pola_kuas3):
		panel_pola_kuas3.hide()
	
	
	# --- KONEKSI LOGIKA LAYERING (KUAS) ---
	
	# Hanya koneksikan jika node valid (mencegah crash)
	if is_instance_valid(btn_kuas_1):
		btn_kuas_1.pressed.connect(_on_btn_kuas_1_pressed)
	
	if is_instance_valid(btn_kuas_2):
		btn_kuas_2.pressed.connect(_on_btn_kuas_2_pressed)
	
	if is_instance_valid(btn_klaim_reward):
		btn_klaim_reward.pressed.connect(_on_btn_klaim_reward_pressed)
	
	# --- KONEKSI TOMBOL PILIH KAWUNG (Fokus Utama) ---
	# Cek validasi sebelum connect untuk menghindari error NULL
	if is_instance_valid(btn_pilih_kawung):
		btn_pilih_kawung.pressed.connect(_on_btn_pilih_kawung_pressed)
		print("DEBUG: Koneksi Tombol Kawung BERHASIL!")
	else:
		# Jika ini muncul, lo harus cek casing path lagi!
		print("DEBUG: ERROR! btn_pilih_kawung BERNILAI NULL. Cek path.")
	
	
	# --- KONEKSI TOMBOL KEMBALI ---
	if is_instance_valid(btn_kembali):
		btn_kembali.pressed.connect(_on_btn_kembali_pressed)
		
	
	print("Mode Lukis Kawung: Layer 1 aktif.")

# --- FUNGSI PINDAH SCENE PILIH KAWUNG (FUNGSI INI SEHARUSNYA TIDAK ADA DI SCRIPT INI) ---
# Func ini hanya dipakai di Mode_LukisBatik.gd, gue komen aja biar clean.
# func _on_btn_pilih_kawung_pressed():
# 	get_tree().change_scene_to_file(SCENE_LUKIS_KAWUNG_PATH)
# 	print("Pindah ke Mode Kreasi Batik Kawung!")

func _on_btn_kembali_pressed() -> void:
	# Kembali ke Menu Utama
	get_tree().change_scene_to_file(SCENE_KEMBALI_PATH)
	print("Kembali ke Studio.")
	
# --- FUNGSI PINDAH KE SCENE MELUKIS ---
func _on_btn_pilih_kawung_pressed():
	# INI LOGIKA YANG LO MAU: pindah ke SCENE_LUKIS_KAWUNG_PATH
	get_tree().change_scene_to_file(SCENE_LUKIS_KAWUNG_PATH)
	print("Pindah ke Mode Kreasi Batik Kawung!")
	
func _on_btn_kuas_1_pressed():
	# Progress: Layer 1 --> Layer 2
	if is_instance_valid(panel_pola_kuas1):
		panel_pola_kuas1.hide()
	if is_instance_valid(panel_pola_kuas2):
		panel_pola_kuas2.show()
	print("Progres Lukisan: Kuas 1 selesai. Layer 2 aktif (Kuas 2 siap).")


func _on_btn_kuas_2_pressed():
	# Progress: Layer 2 --> Layer 3
	if is_instance_valid(panel_pola_kuas2):
		panel_pola_kuas2.hide()
	if is_instance_valid(panel_pola_kuas3):
		panel_pola_kuas3.show()
	print("Progres Lukisan: Kuas 2 selesai. Layer 3 aktif (Klaim siap).")


# --- FUNGSI KLAIM REWARD (Sudah di-UNCOMMENT dan diperbaiki) ---
# Ganti nama Global di fungsi ini untuk mengatasi masalah casing
func _on_btn_klaim_reward_pressed():
	# 1. KLAIM REWARD (Ganti Global. menjadi global.)
	Global.energi_kreatif += ENERGI_KREATIF_REWARD
	Global.energi_kreatif = min(Global.energi_kreatif, Global.ENERGI_MAKS)
	
	# 2. Tambahkan Notifikasi (Ganti Global. menjadi global.)
	Global.show_notification("KREASI SELESAI! +" + str(ENERGI_KREATIF_REWARD) + " Energi Kreatif.")

	# 3. Log dan Pindah Scene
	print("KREASI LUKIS BATIK SELESAI! Energi Kreatif:", Global.energi_kreatif)
	get_tree().change_scene_to_file(SCENE_PILIHAN_BATIK_PATH)
