extends VBoxContainer

@export var part: String = ""

var sprite_selection_button_scene = preload("res://SavedSprites/sprite_selection_button.tscn")

func _ready():
	update_header()
	populate_sprite_selection_buttons()

func update_header() -> void:
	var label_node := get_node_or_null("Header/Label")
	if label_node and label_node is Label:
		label_node.text = part.capitalize()

func populate_sprite_selection_buttons():
	if part:
		var folder_path = "res://Assets/Character/16x32/"+part
		for sprite in g.files_in_dir(folder_path):
			if '000' in sprite:
				continue
			var new_sprite_selection_button = sprite_selection_button_scene.instantiate()
			var file_path = folder_path + "/" + sprite
			new_sprite_selection_button.set_sprite(part, file_path)
			$Selections.add_child(new_sprite_selection_button)


func _on_header_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		$Selections.visible = !$Selections.visible
