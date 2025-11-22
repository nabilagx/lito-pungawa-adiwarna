extends Control

# --- Variabel yang di-referensikan ke Node di Scene Tree ---
@onready var koin_cipta_label = $Panel_koin/KoinCipta_Label
@onready var literasi_bar = $Panel_literasi/Literasi_Bar 
@onready var energi_bar = $Panel_energi/Energi_Bar # <--- BARIS INI WAJIB DITAMBAH!

func _ready():
	# Pastikan Label Koin ditemukan
	if not is_instance_valid(koin_cipta_label):
		# Jika Label tidak ada, cetak error di konsol
		print("ERROR: KoinCipta_Label tidak ditemukan di dalam Panel_koin!")
		return

	# Set nilai maksimum Bar Literasi dari variabel Global
	if not is_instance_valid(literasi_bar):
		# Jika bar tidak ditemukan
		print("PERINGATAN: Literasi_Bar tidak ditemukan!")
	else:
		literasi_bar.max_value = Global.LITERASI_MAKS
	
	# Setup Energi Bar
	if not is_instance_valid(energi_bar):
		# Jika bar tidak ditemukan
		print("PERINGATAN: Energi_Bar tidak ditemukan!")
	else:
		energi_bar.max_value = Global.ENERGI_MAKS
	
	# Panggil fungsi update pertama kali saat header dimuat
	update_ui()

func _process(delta):
	# Fungsi ini dipanggil setiap frame untuk memastikan UI selalu up-to-date
	# Karena nilai Koin Cipta dan Literasi bisa berubah kapan saja
	update_ui()

func update_ui():
	# Perbarui Label Koin Cipta
	if is_instance_valid(koin_cipta_label):
		# Membaca nilai koin dari script Global
		koin_cipta_label.text = str(Global.koin_cipta)
		
	# Perbarui Bar Literasi Budaya
	if is_instance_valid(literasi_bar):
		# Membaca level literasi dari script Global
		literasi_bar.value = Global.literasi_level
		
	# Perbarui Bar Energi Kreatif
	if is_instance_valid(energi_bar):
		# Membaca nilai energi dari script Global
		energi_bar.value = Global.energi_kreatif
