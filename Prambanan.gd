extends Control

# --- REFERENSI NODE ---
@onready var panel_layer1 = $Prambanan1
@onready var panel_layer2 = $Prambanan2 
@onready var panel_layer3 = $Prambanan3

@onready var btn_layer1 = $Prambanan1/Btn_Prambanan_1
@onready var btn_layer2 = $Prambanan2/Btn_Prambanan_2
@onready var btn_klaim = $Prambanan3/Btn_Prambanan_3 

# --- REWARD & PATH ---
const KOIN_REWARD = 50
const SCENE_KEMBALI_PATH = "res://node_2d.tscn" 



func _ready():
	
	panel_layer2.hide()
	panel_layer3.hide()
	
	# KONEKSI
	btn_layer1.pressed.connect(_on_btn_layer1_pressed)
	btn_layer2.pressed.connect(_on_btn_layer2_pressed)
	btn_klaim.pressed.connect(_on_btn_klaim_pressed)
	
	# Tambahkan koneksi tombol kembali jika ada
	# @onready var btn_kembali = $Btn_Kembali
	# btn_kembali.pressed.connect(_on_btn_kembali_pressed)
	
	print("Puzzle Prambanan dimulai.")


func _on_btn_layer1_pressed():
	# Progress: Layer 1 --> Layer 2 (Menghilangkan lapisan puzzle pertama)
	panel_layer1.hide()
	panel_layer2.show()
	print("Layer 1 Selesai. Lanjut Layer 2.")


func _on_btn_layer2_pressed():
	# Progress: Layer 2 --> Layer 3
	panel_layer2.hide()
	panel_layer3.show()
	print("Layer 2 Selesai. Klaim Reward siap.")


func _on_btn_klaim_pressed():
	# --- LOGIKA KLAIM KOIN CIPTA ---
	
	# 1. TAMBAH KOIN CIPTA (+50)
	Global.koin_cipta += KOIN_REWARD
	
	# 2. Notifikasi
	Global.show_notification("PUZZLE SELESAI! +" + str(KOIN_REWARD) + " Koin Cipta!")

	# 3. Log dan Pindah Scene
	print("Klaim Sukses! Koin Cipta: ", Global.koin_cipta)
	get_tree().change_scene_to_file(SCENE_KEMBALI_PATH)
