extends Node2D

const CHARACTER_SPRITES_SCENE = preload("res://character_sprites/character_sprites.tscn")

# The grid dimensions
@export var rows = 8
@export var columns = 8

# Spritesheet total size (for 8×8 = 384×384)
@export var sheet_width = 384
@export var sheet_height = 384

# Cycle directions 4 frames at a time:
var frame_directions = [
	"front",
	"back",
	"left",
	"right"
]

func _ready():
	$SubViewportContainer/SubViewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	$SubViewportContainer/SubViewport.render_target_clear_mode = SubViewport.CLEAR_MODE_ALWAYS


func create_spritesheet(state, parent = null):
	var target = parent if parent else $SubViewportContainer/SubViewport
	for frame in target.get_children():
		frame.queue_free()
		
	var cell_width = float(sheet_width) / columns  # e.g. 384 / 8 = 48
	var cell_height = float(sheet_height) / rows   # e.g. 384 / 8 = 48

	# We want 64 frames total in an 8×8 arrangement
	for i in range(rows * columns):
		# Calculate which row and column this frame belongs to
		var row = int(i / columns)
		var col = i % columns

		# Determine direction in blocks of 4 frames:
		var direction_index = int(i / 4) % frame_directions.size()
		var direction = frame_directions[direction_index]

		# Create the sprite scene
		var frame_instance = CHARACTER_SPRITES_SCENE.instantiate()

		# Pass a unique frame index (i), the total vframes/hframes, and a direction
		frame_instance.init(
			i,            # unique frame index
			rows,         # total vertical frames = 8
			columns,      # total horizontal frames = 8
			direction
		)
		
		# Center the instance within its (col, row) cell
		frame_instance.position = Vector2(
			(col + 0.5) * cell_width,
			(row + 0.5) * cell_height
		)
	
		if parent:
			parent.add_child(frame_instance)
		else:
			# Add it to the viewport for rendering
			$SubViewportContainer/SubViewport.add_child(frame_instance)
			
		# Apply the sprite_state
		frame_instance.create_character(state)


func export_spritesheet():
	await save_img()
	
	queue_free()

func save_img():
	await RenderingServer.frame_post_draw  # Ensures the viewport is fully rendered

	var image = $SubViewportContainer/SubViewport.get_texture().get_image()
	image.convert(Image.FORMAT_RGBA8)

	var file_name = "spritesheet_%s.png" % str(Time.get_ticks_msec())
	var file_path = "user://%s" % file_name
	var err = image.save_png(file_path)
	if err == OK:
		print("Saved spritesheet to: %s" % file_path)
	else:
		print("Error saving image: ", err)
