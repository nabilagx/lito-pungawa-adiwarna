extends Control 

@onready var btn_kembali = $Btn_kembali # <--- Pastikan nama Node-nya sama!
const SCENE_KEMBALI_PATH = "res://node_2d.tscn"


func _ready():
	# SETUP TOMBOL KEMBALI
	# Hapus baris btn_kembali.pressed.connect(go_back)
	
	# KONEKSI WAJIB: Pastikan tombol terhubung ke fungsi Editor di bawah ini.
	# Jika lo koneksikan secara manual di Editor, ini yang akan dipanggil:
	# btn_kembali.pressed.connect(_on_btn_kembali_pressed)
	
	print("Mode Kreasi Batik berhasil dimuat. Tombol Kembali aktif.")


func _on_btn_kembali_pressed() -> void:
	# PINDAHKAN LOGIKA PINDAH SCENE KE SINI
	get_tree().change_scene_to_file(SCENE_KEMBALI_PATH)
	print("Kembali ke Ruangbelajar (Menu Cipta).")
	
# Hapus juga fungsi go_back() yang lama, karena tidak terpakai
