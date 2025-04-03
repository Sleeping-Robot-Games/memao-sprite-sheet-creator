extends Node

func _ready():
	pass

func files_in_dir(path: String, keyword: String = "") -> Array:
	var files = []
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		while true:
			var file = dir.get_next()
			if file == "":
				break
			if keyword != "" and file.find(keyword) == -1:
				continue
			if not file.begins_with(".") and file.ends_with(".import"):
				files.append(file.replace(".import", ""))
			elif file.ends_with(".save") or file.ends_with(".cache"):
				files.append(file)
		dir.list_dir_end()
	else:
		push_error("ERROR: failed to open folder " + path)
	return files

func folders_in_dir(path: String) -> Array:
	var folders = []
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		while true:
			var folder = dir.get_next()
			if folder == "":
				break
			if not folder.begins_with(".") and dir.current_is_dir():
				folders.append(folder)
		dir.list_dir_end()
	return folders

func save_sprite(sprite_state: Dictionary, palette_state: Dictionary, player_name: String):
	var json_text := ""
	var file := FileAccess.open("user://characters.save", FileAccess.READ)
	if file:
		json_text = file.get_as_text()
		file.close()
	
	var data_array: Array = []
	if json_text != "":
		var parse_result = JSON.parse_string(json_text)
		if typeof(parse_result) == TYPE_ARRAY:
			data_array = parse_result

	var state = {
		"name": player_name,
		"sprite_state": sprite_state,
		"palette_state": palette_state
	}
	data_array.append(state)

	file = FileAccess.open("user://characters.save", FileAccess.WRITE)
	file.store_string(JSON.stringify(data_array, "\t"))
	file.close()

func load_all_sprites() -> Array:
	var file := FileAccess.open("user://characters.save", FileAccess.READ)
	if not file:
		return []
	var json_text = file.get_as_text()
	file.close()

	var result = JSON.parse_string(json_text)
	if typeof(result) != TYPE_ARRAY:
		return []

	var character_array: Array = result
	character_array = remove_sprites_with_no_names(character_array)

	file = FileAccess.open("user://characters.save", FileAccess.WRITE)
	file.store_string(JSON.stringify(character_array, "\t"))
	file.close()

	return character_array

func load_sprite(sprite_holder: Node2D, state: Dictionary):
	for part in sprite_holder.get_children():
		if part.name == "JacketB":
			continue
		if part.name in state["sprite_state"]:
			var sprite = state["sprite_state"][part.name]
			if sprite:
				part.texture = load(sprite)
		var palette_name = get_palette_name_from_sprite(part)
		var palette = load("res://Assets/Palettes/" + palette_name + "/palette.png")
		var rows = palette.get_height()
		var number = state["palette_state"][palette_name]
		set_sprite_color(part, palette, number, rows)

func get_palette_name_from_sprite(sprite: Sprite2D) -> String:
	var reverse_palette_dictionary = {
		"AccessoryA": "AccessoryA",
		"AccessoryB": "AccessoryB",
		"AccessoryC": "AccessoryC",
		"Arms": "Skintone",
		"Body": "Skintone",
		"BottomA": "Bottom",
		"BottomB": "Bottom",
		"Eyes": "Eye",
		"HairA": "Hair",
		"HairB": "Hair",
		"HairC": "Hair",
		"HairD": "Hair",
		"Head": "Skintone",
		"JacketA": "Jacket",
		"JacketB": "Jacket",
		"Shoes": "Shoe",
		"TopA": "Top",
		"TopB": "Top"
	}
	return reverse_palette_dictionary.get(sprite.name, "")

func set_sprite_color(sprite: Sprite2D, palette: Texture2D, number: int, rows: int) -> void:
	sprite.material.set_shader_parameter("palette", palette)
	sprite.material.set_shader_parameter("color_row", number)
	sprite.material.set_shader_parameter("total_rows", rows)
	make_shaders_unique(sprite)

func make_shaders_unique(sprite: Sprite2D):
	var mat = sprite.material.duplicate()
	sprite.material = mat

func find_sprite_by_name(character_array: Array, character_name: String):
	for character in character_array:
		if character["name"] == character_name:
			return character
	return null

func remove_sprites_with_no_names(character_array: Array) -> Array:
	var filtered := []
	for character in character_array:
		if character.get("name", "") != "":
			filtered.append(character)
	return filtered

func remove_sprite_by_name(character_name: String):
	var sprite_array = load_all_sprites()
	var sprite_to_delete = find_sprite_by_name(sprite_array, character_name)
	if sprite_to_delete:
		sprite_array.erase(sprite_to_delete)
		var f = FileAccess.open("user://characters.save", FileAccess.WRITE)
		f.store_string(JSON.stringify(sprite_array, "\t"))
		f.close()

func sprite_name_exists(p_name: String) -> bool:
	var f = FileAccess.open("user://characters.save", FileAccess.READ)
	if not f:
		return false
	var json_text = f.get_as_text()
	f.close()
	var result = JSON.parse_string(json_text)
	if typeof(result) == TYPE_ARRAY:
		for character in result:
			if character["name"] == p_name:
				return true
	return false
