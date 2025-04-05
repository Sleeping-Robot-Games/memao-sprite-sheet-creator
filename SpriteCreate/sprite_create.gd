extends Node2D

@export var accessory_A_chance = 10
@export var accessory_B_chance = 10
@export var accessory_C_chance = 10
@export var hair_B_chance = 10
@export var hair_C_chance = 10
@export var jacket_A_chance = 10

## If we want to remove these weighted values later, just empty the dictionary in _ready
@onready var sprite_chances: Dictionary = {
	"AccessoryA": accessory_A_chance,
	"AccessoryB": accessory_B_chance,
	"AccessoryC": accessory_C_chance,
	"HairB": hair_B_chance,
	"HairC": hair_C_chance,
	"JacketA": jacket_A_chance,
}


@onready var player_sprite: Dictionary = {
	'AccessoryA': $CharacterSprites/SpriteHolder/AccessoryA,
	'AccessoryB': $CharacterSprites/SpriteHolder/AccessoryB,
	'AccessoryC': $CharacterSprites/SpriteHolder/AccessoryC,
	'Arms': $CharacterSprites/SpriteHolder/Arms,
	'Body': $CharacterSprites/SpriteHolder/Body,
	'BottomA': $CharacterSprites/SpriteHolder/BottomA,
	'BottomB': $CharacterSprites/SpriteHolder/BottomB,
	'Eyes': $CharacterSprites/SpriteHolder/Eyes,
	'HairA': $CharacterSprites/SpriteHolder/HairA,
	'HairB': $CharacterSprites/SpriteHolder/HairB,
	'HairC': $CharacterSprites/SpriteHolder/HairC,
	'HairD': $CharacterSprites/SpriteHolder/HairD,
	'Head': $CharacterSprites/SpriteHolder/Head,
	'JacketA': $CharacterSprites/SpriteHolder/JacketA,
	'JacketB': $CharacterSprites/SpriteHolder/JacketB,
	'Shoes': $CharacterSprites/SpriteHolder/Shoes,
	'TopA': $CharacterSprites/SpriteHolder/TopA,
	'TopB': $CharacterSprites/SpriteHolder/TopB
}

@onready var palette_sprite_dict: Dictionary = {
	'AccessoryA': [player_sprite['AccessoryA']],
	'AccessoryB': [player_sprite['AccessoryB']],
	'AccessoryC': [player_sprite['AccessoryC']],
	'Bottom': [
		player_sprite['BottomA'], player_sprite['BottomB']
	],
	'Eye': [player_sprite['Eyes']],
	'Hair': [
		player_sprite['HairA'],
		player_sprite['HairB'],
		player_sprite['HairC'],
		player_sprite['HairD']
	],
	'Shoe': [player_sprite['Shoes']],
	'Skintone': [
		player_sprite['Body'],
		player_sprite['Arms'],
		player_sprite['Head']
	],
	'Top': [
		player_sprite['TopA'],
		player_sprite['TopB']
	],
	'Jacket': [
		player_sprite['JacketA'],
		player_sprite['JacketB']
	]
}


var palette_sprite_state: Dictionary
var sprite_state: Dictionary = {
	'AccessoryA': '',
	'AccessoryB': '',
	'AccessoryC': '',
	'Arms': '',
	'Body': '',
	'BottomA': '',
	'BottomB': '',
	'Eyes': '',
	'HairA': '',
	'HairB': '',
	'HairC': '',
	'HairD': '',
	'Head': '',
	'JacketA': '',
	'JacketB': '',
	'Shoes': '',
	'TopA': '',
	'TopB': ''
}

var player_name: String

var sprite_generator = preload("res://Generator/generator.tscn")

var sprite_folder_path = "res://Assets/Character/16x32/"
var palette_folder_path = "res://Assets/Palettes"

var current_animation = 0

func _ready():
	## TODO: Wire signals up using 4.4
	#$TabContainer/Character/CharacterTabRandom.connect('button_up', self, '_on_Random_Tab_button_up', [[],['Skintone']])
	#$TabContainer/Head/HeadTabRandom.connect('button_up', self, '_on_Random_Tab_button_up', [['HairA', 'HairB', 'HairC', 'HairD', 'Eyes', 'Head','AccessoryA', 'AccessoryB', 'AccessoryC'],['Hair', 'Eye','AccessoryA', 'AccessoryB', 'AccessoryC']])
	#$TabContainer/Top/TopTabRandom.connect('button_up', self, '_on_Random_Tab_button_up', [['JacketA', 'JacketB', 'TopA', 'TopB'],['Jacket', 'Top']])
	#$TabContainer/Bottom/BottomTabRandom.connect('button_up', self, '_on_Random_Tab_button_up', [['BottomA', 'BottomB', 'Shoes'], ['Bottom', 'Shoe']])
	create_random_character()
	$CharacterSprites/AnimationPlayer.play("idle_front")
	
func _process(delta):
	pass
	
func load_character_from_save():
	pass

func set_sprite_texture(sprite_name: String, texture_path: String) -> void:
	player_sprite[sprite_name].set_texture(load(texture_path))
	sprite_state[sprite_name] = texture_path
	ensure_jacket_state()
	ensure_hair(sprite_name)
	
func random_asset(folder: String, keyword: String = "") -> String:
	var files: Array
	files = g.files_in_dir(folder, keyword)
	if keyword == "":
		files = g.files_in_dir(folder)
	if len(files) == 0:
		return ""
	randomize()
	var random_index = randi() % len(files)
	return folder+"/"+files[random_index]

func random_color(color_rows: int) -> int:
	randomize()
	return randi_range(1, color_rows)
	
func set_random_color(palette_type: String) -> void:
	var palette = load(palette_folder_path+"/"+palette_type+"/palette.png")
	var color_rows = palette.get_height()
	var random_color = random_color(color_rows)
	
	for sprite in palette_sprite_dict[palette_type]:
		g.set_sprite_color(sprite, palette, random_color, color_rows)
		palette_sprite_state[palette_type] = random_color
		
func set_random_texture(sprite_name: String) -> void:
	var folder_path = sprite_folder_path + sprite_name + "/"
	var files = g.files_in_dir(folder_path)

	# Exclude `_000.png` from random selection for chance-controlled sprites
	if sprite_chances.has(sprite_name) and sprite_chances[sprite_name] > 0:
		var filtered_files = []
		for file in files:
			if not file.ends_with("_000.png"):
				filtered_files.append(file)
		files = filtered_files

	# If there are no usable files, fallback is handled elsewhere
	if files.is_empty():
		return

	randomize()
	var random_file = files[randi() % files.size()]
	var random_sprite = folder_path + random_file
	
	if random_sprite == "": # No assets in the folder yet continue to next folder
		return
	if "000" in random_sprite and not "Accessory" in random_sprite: # Prevent some empty sprite sheets
		if sprite_name == "HairA" and "Hair" in random_sprite: # If main hair is bald, leave rest of hair
			return
		if "Top" in sprite_name or "Bottom" in sprite_name: # If no top or no bottom was returned, dont set the texture
			return
	set_sprite_texture(sprite_name, random_sprite)

		
func create_random_character() -> void:
	var sprite_folders = g.folders_in_dir(sprite_folder_path)
	var palette_folders = g.folders_in_dir(palette_folder_path)

	for folder in sprite_folders:
		randomize()

		var folder_path = sprite_folder_path + folder + "/"
		var zero_sprite_path = folder_path + folder.to_lower() + "_000.png"

		# Apply _000 version if sprite is excluded based on chance
		if sprite_chances.has(folder):
			if randi() % 100 >= sprite_chances[folder]:
				if ResourceLoader.exists(zero_sprite_path):
					set_sprite_texture(folder, zero_sprite_path)
				continue

		# Apply default HairD
		if folder == "HairD":
			if ResourceLoader.exists(zero_sprite_path):
				set_sprite_texture("HairD", zero_sprite_path)
			continue

		set_random_texture(folder)

	for folder in palette_folders:
		set_random_color(folder)

func ensure_jacket_state():
	if not '000' in sprite_state['JacketB']:
		sprite_state['TopB'] = sprite_folder_path + 'TopB/topb_001.png'
		player_sprite['TopB'].set_texture(load(sprite_state['TopB']))
	if '000' in sprite_state['JacketA']:
		sprite_state['JacketB'] = sprite_folder_path + 'JacketB/jacketb_000.png'
		player_sprite['JacketB'].set_texture(load(sprite_state['JacketB']))

func ensure_hair(sprite_name):
	if sprite_name == 'HairB':
		var hair_d_texture = sprite_folder_path + '/HairD/' + 'haird_' + get_sprite_number_from_name(sprite_name) + '.png'
		if ResourceLoader.exists(hair_d_texture):
			sprite_state['HairD'] = hair_d_texture
			player_sprite['HairD'].set_texture(load(hair_d_texture))

func get_sprite_number_from_name(sprite_name):
	return sprite_state[sprite_name].substr(len(sprite_state[sprite_name]) - 7, 3)

func _on_Turn_button_up(direction):
	var animations = ['idle_front', 'idle_right', 'idle_back', 'idle_left']
	current_animation += direction
	if current_animation == 4 or current_animation == -4:
		current_animation = 0
	$CharacterSprites/AnimationPlayer.play(animations[current_animation])

func _on_Sprite_Selection_button_up(direction: int, sprite: String):
	var folder_path = sprite_folder_path+sprite+"/"
	var files = g.files_in_dir(folder_path)
	var file = sprite_state[sprite].split("/")[-1]
	var current_index = files.find(file)
	var new_index = current_index + direction
	if new_index > len(files) - 1:
		new_index = 0
	if new_index == -1:
		new_index = len(files) -1
	var new_sprite_path = folder_path + files[new_index]
	print(new_sprite_path)
	set_sprite_texture(sprite, new_sprite_path)


func _on_Color_Selection_button_up(direction: int, palette_sprite: String):
	var palette = load("res://Assets/Palettes/"+palette_sprite+"/palette.png")
	var color_rows = palette.get_height()
	var new_color = int(palette_sprite_state[palette_sprite]) + direction
	if new_color < 1:
		new_color = color_rows - 1  
	elif new_color >= color_rows:
		new_color = 1
	for sprite in palette_sprite_dict[palette_sprite]:
		var color_num = new_color
		g.set_sprite_color(sprite, palette, color_num, color_rows)
		palette_sprite_state[palette_sprite] = color_num
		

func _on_Save_button_up():
	var player_name = $TabContainer/Character/NameLabel/Name.text
	if player_name == "":
		$TabContainer.current_tab = 0
		$TabContainer/Character/NameLabel/Error.text = "Name is Required"
		$TabContainer/Character/NameLabel/Error.show()
	elif g.sprite_name_exists(player_name):
		$TabContainer/Character/NameLabel/Error.text = "Name is Taken"
		$TabContainer/Character/NameLabel/Error.show()
	else:
		g.save_sprite(sprite_state, palette_sprite_state, player_name)
		hide()
		get_node('../Main').show()

func _on_Name_text_changed(new_text):
	if new_text != "":
		$TabContainer/Character/NameLabel/Error.hide()

func _on_Back_button_up():
	hide()
	get_node('../Main').show()

func _on_Random_Tab_button_up(sprites, palettes):
	for sprite in sprites:
		set_random_texture(str(sprite))
	for palette in palettes:
		set_random_color(str(palette))

func export_sheet():
	var state = {'sprite_state': sprite_state, 'palette_state': palette_sprite_state}
	var s_g = sprite_generator.instantiate()
	add_child(s_g)
	s_g.create_spritesheet(state)
	s_g.export_spritesheet()


func _on_random_all_pressed() -> void:
	create_random_character()
