extends NinePatchRect

@onready var screen = get_parent()

func _ready():
	if screen and screen.name:
		match screen.name:
			'Desktop':
				for btn in $Buttons.get_children():
					btn.hide()
			'SpriteCreate':
				pass
			'SavedSprites':
				$Buttons/Save.hide()
				$Buttons/Export.hide()

func _on_back_pressed() -> void:
	if screen and screen.name:
		match screen.name:
			'SpriteCreate':
				get_tree().change_scene_to_file("res://Destop/desktop.tscn")
			'SavedSprites':
				get_tree().change_scene_to_file("res://Destop/desktop.tscn")


func _on_save_pressed() -> void:
	if screen and screen.name:
		match screen.name:
			'SpriteCreate':
				pass
			'SavedSprites':
				pass


func _on_export_pressed() -> void:
	if screen and screen.name:
		match screen.name:
			'SpriteCreate':
				screen.export_sheet()
			'SavedSprites':
				pass
