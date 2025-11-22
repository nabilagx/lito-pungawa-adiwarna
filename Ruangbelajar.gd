extends Node2D # Pastikan Root Scene Ruangbelajar lo bertipe Control

# --- REFERENSI NODE LITERASI DAN UMUM ---
@onready var btn_topeng_malin = $Btn_TopengMalin
@onready var popup_pilihan = $PopUp_Pilihan
@onready var btn_malin_kundang = $PopUp_Pilihan/Btn_MalinKundang
@onready var btn_timun_mas = $PopUp_Pilihan/Btn_TimunMas 
@onready var popup_kisah_card = $PopUp_Kisah_Card
@onready var cerita_label = $PopUp_Kisah_Card/Cerita_Label
@onready var btn_klaim_selesai = $PopUp_Kisah_Card/Btn_KlaimSelesai
@onready var literasi_bar = $Literasi_Bar 
@onready var notif_label = $NotifLabel 


const SCENE_UTAMA_PATH = "res://node_2d.tscn"
const LITERASI_REWARD = 25 
# --- DATA CERITA (Wajib Ada) ---
const KISAH_NUSANTARA = {
	"Malin Kundang": {
		"judul": "Kisah Malin Kundang",
		"isi": "Malin Kundang adalah seorang anak yang durhaka kepada ibunya. Setelah sukses, ia lupa asal-usulnya dan akhirnya dikutuk menjadi batu..." 
	},
	"Timun Mas": {
		"judul": "Kisah Timun Mas",
		"isi": "Timun Mas adalah seorang gadis yang dikejar raksasa karena perjanjian orang tuanya. Ia harus menggunakan biji-biji ajaib untuk bertahan hidup..."
	}
}


func _ready():
	# Sembunyikan semua Pop-up di awal
	popup_pilihan.hide()
	popup_kisah_card.hide()
	

	btn_topeng_malin.pressed.connect(_on_btn_topeng_malin_pressed)
	btn_malin_kundang.pressed.connect(_on_btn_malin_kundang_pressed)
	btn_klaim_selesai.pressed.connect(_on_btn_klaim_selesai_pressed)
	

	btn_timun_mas.pressed.connect(_on_btn_timun_mas_pressed) 
	
	if is_instance_valid(literasi_bar):
		literasi_bar.value = Global.literasi_level 
	
	$Exit_Area.input_event.connect(_on_exit_area_input_event) 




func go_to_main_menu():
	get_tree().change_scene_to_file(SCENE_UTAMA_PATH)
	print("Kembali ke Menu Utama.")


func _on_exit_area_input_event(viewport: Node, event: InputEvent, shape_idx: int):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		go_to_main_menu()


func _on_btn_topeng_malin_pressed():
	popup_pilihan.show()

func _on_btn_malin_kundang_pressed():
	var data = KISAH_NUSANTARA["Malin Kundang"]
	
	cerita_label.text = "[center][b]" + data.judul + "[/b][/center]\n\n" + data.isi
	
	popup_pilihan.hide()
	popup_kisah_card.show()

func _on_btn_timun_mas_pressed():
	var data = KISAH_NUSANTARA["Timun Mas"]
	
	cerita_label.text = "[center][b]" + data.judul + "[/b][/center]\n\n" + data.isi
	
	popup_pilihan.hide()
	popup_kisah_card.show()

func _on_btn_klaim_selesai_pressed():
	# 1. KLAIM ENERGI LITERASI
	Global.literasi_level += LITERASI_REWARD
	
	# 2. Update Visual Bar 
	if is_instance_valid(literasi_bar):
		literasi_bar.value = Global.literasi_level 
	
	# 3. Sembunyikan Kartu Cerita
	popup_kisah_card.hide()
	
	# Tampilkan notifikasi singkat (Wajib)
	show_notification("LITERASI BERHASIL! +" + str(LITERASI_REWARD) + " Energi Literasi.")
	
	print("Energi Literasi bertambah! Current: ", Global.literasi_level)
	
	# Opsional: Matikan tombol Topeng agar tidak bisa diklaim lagi
	btn_topeng_malin.disabled = true

func show_notification(message):
	# Pastikan lo punya Node Label bernama NotifLabel di Ruangbelajar
	var timer_duration = 2.5 
	
	if is_instance_valid(notif_label):
		notif_label.text = message
		notif_label.show()
		
		# Timer untuk menyembunyikan notifikasi
		var timer = get_tree().create_timer(timer_duration)
		await timer.timeout
		notif_label.hide()
	else:
		# Jika Node NotifLabel tidak ada, tampilkan di konsol
		print("Notifikasi:", message)
