extends Button

var sprite_reference_atlas_dict = {
	'Eyes': Rect2(15, 9, 18, 18)
}

func _ready():
	pass

func set_sprite(sprite: String, file_path: String):
	var atlas_texture := AtlasTexture.new()
	atlas_texture.atlas = load(file_path)

	if sprite_reference_atlas_dict.has(sprite):
		atlas_texture.region = sprite_reference_atlas_dict[sprite]
	else:
		atlas_texture.region = Rect2(0, 0, 48, 48)

	$TextureRect.texture = atlas_texture
