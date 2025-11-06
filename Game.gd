extends Node2D

@onready var scene_transition_player = $SceneTransitionPlayer
const SCENE_BELAJAR = "res://Ruangbelajar.tscn" 

func _ready():
	scene_transition_player.animation_finished.connect(_on_fade_in_finished)
	pass


func _on_icon_belajar_pressed():
	scene_transition_player.play("fade_in")

func _on_fade_in_finished(anim_name):
	if anim_name == "fade_in":
		get_tree().change_scene_to_file(SCENE_BELAJAR)
