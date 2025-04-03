extends Node2D


func _on_create_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://SpriteCreate/sprite_create.tscn")


func _on_list_btn_pressed() -> void:
	get_tree().change_scene_to_file("res://SavedSprites/saved_sprites.tscn")


func _on_window_btn_pressed() -> void:
	var current_mode = DisplayServer.window_get_mode()
	if current_mode != DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		$IconContainer/WindowChange/Label.text = "Windowed"
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		$IconContainer/WindowChange/Label.text = "Full Screen"
