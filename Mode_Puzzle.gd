extends Control

# --- SCENE PATH ---
const SCENE_KEMBALI_PATH = "res://Mode_LukisBatik.tscn" # Ganti dengan path ke menu pilihan Batik
const SCENE_PRAMBANAN_PATH = "res://Prambanan.tscn" 

# --- REFERENSI NODE ---
# Asumsi: Card Prambanan adalah yang di tengah, punya tombol pilih (TextureButton)
# Ganti nama node ini sesuai dengan yang lo punya di Scene Tree!
@onready var btn_pilih_prambanan = $Btn_Pilih_Prambanan
@onready var btn_kembali = $Btn_Kembali # Tombol kembali




func _ready():
	# 1. KONEKSI TOMBOL PRAMBANAN
	if is_instance_valid(btn_pilih_prambanan):
		btn_pilih_prambanan.pressed.connect(_on_btn_pilih_prambanan_pressed)
		print("Koneksi Prambanan Aktif.")
	
	# 3. KONEKSI TOMBOL KEMBALI
	if is_instance_valid(btn_kembali):
		btn_kembali.pressed.connect(_on_btn_kembali_pressed)


# --- FUNGSI PINDAH SCENE KE PRAMBANAN ---

func _on_btn_pilih_prambanan_pressed():
	# Pindah Scene Langsung
	get_tree().change_scene_to_file(SCENE_PRAMBANAN_PATH)
	print("Pindah ke Puzzle Prambanan.")

# --- FUNGSI PINDAH KEMBALI ---

func _on_btn_kembali_pressed():
	get_tree().change_scene_to_file(SCENE_KEMBALI_PATH)
	print("Kembali ke Menu Pilihan Cipta.")
