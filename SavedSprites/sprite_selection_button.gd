extends Button

@onready var sprite_creator = get_node("/root/SpriteCreate")

var file_path
var sprite

var sprite_reference_atlas_dict = {
	'Eyes': Rect2(15, 9, 18, 18),
	'AccessoryA': Rect2(15, 9, 18, 18),
	'AccessoryB': Rect2(15, 5, 18, 18),
	'AccessoryC': Rect2(15, 9, 18, 18),
	'HairA': Rect2(15, 5, 18, 18),
	'HairB': Rect2(8, 3, 32, 32),
	'HairC': Rect2(11, 3, 26, 26),
}

func _ready():
	pass

func set_sprite(_sprite: String, _file_path: String):
	sprite = _sprite
	file_path = _file_path
	var atlas_texture := AtlasTexture.new()
	atlas_texture.atlas = load(file_path)

	if sprite_reference_atlas_dict.has(sprite):
		atlas_texture.region = sprite_reference_atlas_dict[sprite]
	else:
		atlas_texture.region = Rect2(0, 0, 48, 48)

	$TextureRect.texture = atlas_texture


func _on_pressed() -> void:
	sprite_creator.set_sprite_texture(sprite, file_path)
