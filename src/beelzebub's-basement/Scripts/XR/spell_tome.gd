extends Node3D

## Spell Tome Script
##
## Tracks spell pose progress and provides visual feedback for spell sequences.
## Connects to SpellDetector instances to receive pose progress updates.

# Dictionary to track progress for each spell: spell_name -> current_pose_index
var _spell_progress : Dictionary[String, int] = {}

# Dictionary to store spell data: spell_name -> {hand, sequence}
# This should match the SPELLS constant in spell_detector.gd
var _spell_data : Dictionary[String, Dictionary] = {}

# Dictionary to store pose indicators: spell_name -> [Array of Node3D indicators]
var _pose_indicators : Dictionary[String, Array] = {}

# Reference to book model
var _book_model : Node3D

# Exported properties
@export_group("Visual")
@export var pose_indicator_scene : PackedScene
@export var use_pose_images : bool = true
@export var pose_image_paths : Dictionary = {
	"metal": "res://textures/poses/metal.png",
	"point": "res://textures/poses/point.png",
	"thumbs_up": "res://textures/poses/thumbs_up.png",
	"peace_sign": "res://textures/poses/peace_sign.png",
}
@export var inactive_color : Color = Color(0.141, 0.145, 0.146, 1.0)
@export var active_color : Color = Color(0.0, 0.719, 0.128, 1.0)  # Green for active/completed
@export var image_scale : float = 0.07 # Size of pose images

@export_group("Book")
@export var book_model_path : NodePath = NodePath("Book")
@export var use_book_relative_positioning : bool = true

@export_group("Layout")
@export var spell_spacing : float = 0.15
@export var pose_spacing : float = 0.07
@export var header_text_size : float = 0.0012  # Size of page header text
@export var spell_name_text_size : float = 0.001  # Size of spell name text
@export var header_offset : float = 0.12  # Distance above top spell row
@export var spell_name_offset : float = -0.05  # Distance below spell sequence

# Page positions for each spell (relative to book or world space)
# These can be set in the inspector or calculated automatically
@export_group("Page Positions")
@export var left_page_center : Vector3 = Vector3(-0.12, 0, 0.01)
@export var right_page_center : Vector3 = Vector3(0.12, 0, 0.01)
@export var left_page_spell_positions : Array[Vector3] = []
@export var right_page_spell_positions : Array[Vector3] = []


func _ready() -> void:
	# Find book model
	_find_book_model()
	
	# Get spell definitions from the spell detector script
	_load_spell_definitions()
	
	# Initialize page positions if not set
	_init_page_positions()
	
	# Find all spell detectors in the scene and connect to them
	_connect_to_spell_detectors()
	
	# Initialize progress tracking
	_init_spell_progress()


func _load_spell_definitions() -> void:
	# Define spells directly (must match spell_detector.gd SPELLS constant)
	_spell_data = {
		"reveal_demon": {
			"hand": "right",
			"sequence": ["peace_sign", "thumbs_up", "point"],
		},
		"slow_demon": {
			"hand": "right",
			"sequence": ["point", "metal", "thumbs_up"],
		},
		"empower_throw_fire": {
			"hand": "left",
			"sequence": ["metal", "point", "peace_sign"],
		},
		"empower_throw_ice": {
			"hand": "left",
			"sequence": ["thumbs_up", "metal", "peace_sign"],
		},
	}


func _connect_to_spell_detectors() -> void:
	# Find all SpellDetector nodes in the scene tree
	var spell_detectors = _find_spell_detectors(get_tree().root)
	
	for detector in spell_detectors:
		if detector.has_signal("pose_progress"):
			detector.pose_progress.connect(_on_pose_progress)
			detector.spell_cast.connect(_on_spell_cast)
			print("SpellTome: Connected to SpellDetector at ", detector.get_path())


func _find_spell_detectors(node: Node) -> Array:
	var detectors : Array = []
	
	# Check if this node is a SpellDetector
	if node.get_script() and node.get_script().resource_path.ends_with("spell_detector.gd"):
		detectors.append(node)
	
	# Recursively search children
	for child in node.get_children():
		detectors.append_array(_find_spell_detectors(child))
	
	return detectors


func _init_spell_progress() -> void:
	# Create page headers first
	_create_page_headers()
	
	# Initialize progress tracking for each spell
	for spell_name in _spell_data.keys():
		_spell_progress[spell_name] = 0
		# Create indicators for all spells upfront so they're visible
		var sequence : Array = _spell_data[spell_name]["sequence"]
		_create_spell_indicators(spell_name, sequence)
		# Initialize all indicators to inactive
		_reset_spell_indicators(spell_name)


func _on_pose_progress(spell_name: String, pose_index: int, total_poses: int, hand: String) -> void:
	# Update progress for this spell
	var previous_progress = _spell_progress.get(spell_name, 0)
	_spell_progress[spell_name] = pose_index
	
	# If progress was reset to 0 (wrong pose detected), reset all indicators
	if pose_index == 0 and previous_progress > 0:
		_reset_spell_indicators(spell_name)
	else:
		# Update visual indicators normally
		_update_spell_indicators(spell_name, pose_index)
	
	print("SpellTome: ", spell_name, " progress: ", pose_index, "/", total_poses, " (", hand, " hand)")


func _on_spell_cast(spell_name: String, hand: String) -> void:
	# Spell completed - reset progress and show completion
	_spell_progress[spell_name] = 0
	_update_spell_indicators(spell_name, 0, true)
	
	print("SpellTome: ", spell_name, " completed! Resetting indicators.")


func _reset_spell_indicators(spell_name: String) -> void:
	# Reset all indicators to inactive state
	if not _spell_data.has(spell_name):
		return
	
	var sequence : Array = _spell_data[spell_name]["sequence"]
	
	# Get or create indicators for this spell
	if not _pose_indicators.has(spell_name):
		_create_spell_indicators(spell_name, sequence)
	
	var indicators = _pose_indicators[spell_name]
	
	# Set all indicators to inactive
	for indicator in indicators:
		if is_instance_valid(indicator):
			_set_indicator_color(indicator, inactive_color)


func _update_spell_indicators(spell_name: String, current_index: int, completed: bool = false) -> void:
	if not _spell_data.has(spell_name):
		return
	
	var sequence : Array = _spell_data[spell_name]["sequence"]
	
	# Get or create indicators for this spell
	if not _pose_indicators.has(spell_name):
		_create_spell_indicators(spell_name, sequence)
	
	var indicators = _pose_indicators[spell_name]
	
	# Update each indicator's visual state
	# current_index represents the next pose to do (0-based)
	# So poses 0 to (current_index - 1) are completed, current_index is next
	for i in range(indicators.size()):
		var indicator = indicators[i]
		if not is_instance_valid(indicator):
			continue
		
		if completed:
			# All poses completed - show green
			_set_indicator_color(indicator, active_color)
		elif i < current_index:
			# This pose has been completed - show green
			_set_indicator_color(indicator, active_color)
		else:
			# Not reached yet (including current_index which is next to do) - show grey
			_set_indicator_color(indicator, inactive_color)


func _find_book_model() -> void:
	if book_model_path and has_node(book_model_path):
		_book_model = get_node(book_model_path)
		print("SpellTome: Found book model at ", book_model_path)
	else:
		# Try to find book by name
		_book_model = _find_node_by_name(self, "Book")
		if _book_model:
			print("SpellTome: Found book model by name")
		else:
			print("SpellTome: Warning - No book model found. Using world space positioning.")


func _find_node_by_name(node: Node, name: String) -> Node:
	if node.name == name:
		return node
	for child in node.get_children():
		var result = _find_node_by_name(child, name)
		if result:
			return result
	return null


func _init_page_positions() -> void:
	# If positions not set, calculate them automatically
	if left_page_spell_positions.is_empty() or right_page_spell_positions.is_empty():
		var left_spells = []
		var right_spells = []
		
		# Separate spells by hand
		for spell_name in _spell_data.keys():
			var hand = _spell_data[spell_name]["hand"]
			if hand == "left":
				left_spells.append(spell_name)
			else:
				right_spells.append(spell_name)
		
		# Calculate positions for left page (left hand spells)
		# Book is lying flat, so use Z axis for vertical spacing (up/down on the page)
		left_page_spell_positions.clear()
		for i in range(left_spells.size()):
			var z_offset = (left_spells.size() - 1 - i) * spell_spacing - (left_spells.size() - 1) * spell_spacing / 2.0
			left_page_spell_positions.append(left_page_center + Vector3(0, 0, z_offset))
		
		# Calculate positions for right page (right hand spells)
		right_page_spell_positions.clear()
		for i in range(right_spells.size()):
			var z_offset = (right_spells.size() - 1 - i) * spell_spacing - (right_spells.size() - 1) * spell_spacing / 2.0
			right_page_spell_positions.append(right_page_center + Vector3(0, 0, z_offset))


func _get_spell_page_position(spell_name: String) -> Vector3:
	var hand = _spell_data[spell_name]["hand"]
	var spell_list = []
	var positions_list : Array[Vector3] = []
	
	if hand == "left":
		spell_list = []
		for s in _spell_data.keys():
			if _spell_data[s]["hand"] == "left":
				spell_list.append(s)
		positions_list = left_page_spell_positions
	else:
		spell_list = []
		for s in _spell_data.keys():
			if _spell_data[s]["hand"] == "right":
				spell_list.append(s)
		positions_list = right_page_spell_positions
	
	var index = spell_list.find(spell_name)
	if index >= 0 and index < positions_list.size():
		return positions_list[index]
	
	# Fallback to calculated position (book is flat, use Z axis)
	var spell_index = _spell_data.keys().find(spell_name)
	var z_offset = -spell_index * spell_spacing
	return Vector3(0, 0, z_offset)


func _create_spell_indicators(spell_name: String, sequence: Array) -> void:
	# Skip if indicators already exist
	if _pose_indicators.has(spell_name):
		return
	
	# Create a container node for this spell's indicators
	var spell_container = Node3D.new()
	spell_container.name = spell_name + "_indicators"
	
	# Position spell containers on the appropriate page
	var page_position = _get_spell_page_position(spell_name)
	
	if use_book_relative_positioning and _book_model:
		# Position relative to book model
		# Book is lying flat, so rotate container to match book's orientation
		spell_container.position = page_position
		# Rotate 90 degrees around X axis to align with flat book (pages face up)
		spell_container.rotation_degrees = Vector3(-90, 0, 0)
		_book_model.add_child(spell_container)
	else:
		# Position in world space (fallback)
		spell_container.position = page_position
		add_child(spell_container)
	
	var indicators : Array = []
	
	# Create an indicator for each pose in the sequence
	for i in range(sequence.size()):
		var pose_name = sequence[i]
		var indicator = _create_pose_indicator(pose_name, i, sequence.size())
		spell_container.add_child(indicator)
		indicators.append(indicator)
	
	# Create spell name label below the sequence
	var formatted_spell_name = _format_spell_name(spell_name)
	var spell_name_label = _create_text_label(formatted_spell_name, spell_name_text_size)
	spell_name_label.position = Vector3(0, spell_name_offset, 0.035)  # Below the sequence, raised above page
	spell_container.add_child(spell_name_label)
	
	_pose_indicators[spell_name] = indicators


func _format_spell_name(spell_name: String) -> String:
	# Convert "reveal_demon" to "Reveal Demon"
	# Split by underscores, capitalize each word, join with spaces
	var words = spell_name.split("_")
	var formatted_words : Array[String] = []
	for word in words:
		if word.length() > 0:
			# Capitalize first letter, lowercase the rest
			var first_char = word[0].to_upper()
			var rest = word.substr(1).to_lower() if word.length() > 1 else ""
			var capitalized = first_char + rest
			formatted_words.append(capitalized)
	return " ".join(formatted_words)


func _create_text_label(text: String, text_size: float) -> Label3D:
	# Create a Label3D node for 3D text
	var label = Label3D.new()
	label.text = text
	label.font_size = int(text_size * 200000)  # Convert to font size (increased multiplier for larger text)
	label.billboard = BaseMaterial3D.BILLBOARD_DISABLED  # Keep fixed orientation
	label.no_depth_test = true  # Always visible
	label.modulate = Color(0, 0, 0, 1)  # Black text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR  # Smooth text rendering
	label.pixel_size = 0.0001  # Small pixel size for crisp text
	return label


func _create_page_headers() -> void:
	if not use_book_relative_positioning or not _book_model:
		return
	
	# Get lists of spells for each hand
	var left_spells : Array = []
	var right_spells : Array = []
	
	for spell_name in _spell_data.keys():
		var hand = _spell_data[spell_name]["hand"]
		if hand == "left":
			left_spells.append(spell_name)
		else:
			right_spells.append(spell_name)
	
	# Calculate header positions (above the top spell row)
	# Headers should be positioned above the highest spell on each page
	var header_z_offset = header_offset + (max(left_spells.size(), right_spells.size()) - 1) * spell_spacing / 2.0
	
	# Create left page header
	if left_spells.size() > 0:
		var left_header = _create_text_label("Left Handed Spells", header_text_size)
		left_header.position = left_page_center + Vector3(0, 0, -header_z_offset) + Vector3(-0.01, 0.03, 0.02)
		left_header.rotation_degrees = Vector3(-90, 0, 0)  # Align with book pages
		_book_model.add_child(left_header)
	
	# Create right page header
	if right_spells.size() > 0:
		var right_header = _create_text_label("Right Handed Spells", header_text_size)
		right_header.position = right_page_center + Vector3(0, 0, -header_z_offset) + Vector3(0.01, 0.03, 0.02)
		right_header.rotation_degrees = Vector3(-90, 0, 0)  # Align with book pages
		_book_model.add_child(right_header)


func _create_pose_indicator(pose_name: String, index: int, total: int) -> Node3D:
	# Create a container for the indicator
	var indicator = Node3D.new()
	indicator.name = "Pose_" + pose_name + "_" + str(index)
	
	if use_pose_images and pose_image_paths.has(pose_name):
		# Use QuadMesh with texture for consistent sizing
		var image_path = pose_image_paths[pose_name]
		var texture = load(image_path) as Texture2D
		
		if texture:
			# Create a QuadMesh with fixed size to ensure all images are the same size
			var mesh_instance = MeshInstance3D.new()
			var quad_mesh = QuadMesh.new()
			quad_mesh.size = Vector2(image_scale, image_scale)  # Fixed size for all images
			mesh_instance.mesh = quad_mesh
			
			# Create material with texture
			var material = StandardMaterial3D.new()
			material.albedo_texture = texture
			material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST  # Keep crisp pixels
			material.flags_transparent = true  # Support transparency
			material.flags_unshaded = true  # No lighting
			material.albedo_color = Color(1.0, 1.0, 1.0, 1.0)  # Start with full color (inactive)
			mesh_instance.material_override = material
			
			indicator.add_child(mesh_instance)
			
			# Store reference for color tinting
			indicator.set_meta("mesh_instance", mesh_instance)
			indicator.set_meta("is_image", true)
		else:
			print("SpellTome: Warning - Could not load pose image: ", image_path)
			# Fallback to box
			_create_box_indicator(indicator, inactive_color)
	else:
		# Use box mesh as fallback
		_create_box_indicator(indicator, inactive_color)
	
	# Position indicator horizontally along the page
	# Since book is rotated -90 degrees on X, X axis is now horizontal on the page
	var offset = (index - (total - 1) / 2.0) * pose_spacing
	indicator.position = Vector3(offset, 0, 0.035)  # Raised above page surface to prevent clipping
	
	# Store pose name and visual reference for reference
	indicator.set_meta("pose_name", pose_name)
	indicator.set_meta("pose_index", index)
	
	return indicator


func _create_box_indicator(indicator: Node3D, color: Color) -> void:
	# Create a simple box mesh as placeholder
	var mesh_instance = MeshInstance3D.new()
	var mesh = BoxMesh.new()
	mesh.size = Vector3(0.04, 0.04, 0.02)  # Smaller boxes for tighter layout
	mesh_instance.mesh = mesh
	
	# Create material
	var material = StandardMaterial3D.new()
	material.albedo_color = color
	material.emission_enabled = true
	material.emission = color
	material.emission_energy_multiplier = 2.0
	mesh_instance.material_override = material
	
	indicator.add_child(mesh_instance)
	indicator.set_meta("mesh_instance", mesh_instance)


func _set_indicator_color(indicator: Node3D, color: Color) -> void:
	if not is_instance_valid(indicator):
		return
	
	# Check if using image (pose images)
	var is_image = indicator.get_meta("is_image", false)
	var mesh_instance = indicator.get_meta("mesh_instance", null)
	
	if not mesh_instance:
		# Try to find MeshInstance3D child
		for child in indicator.get_children():
			if child is MeshInstance3D:
				mesh_instance = child
				break
	
	if mesh_instance and mesh_instance.material_override:
		var material = mesh_instance.material_override as StandardMaterial3D
		if material:
			if is_image:
				# For images, modulate the albedo color to tint the texture
				if color == active_color:
					# Active - bright and green tinted
					material.albedo_color = active_color * 1.5
					material.emission_enabled = true
					material.emission = active_color * 1.5
					material.emission_energy_multiplier = 2.0
				else:
					# Inactive - show PNG as-is (white, no tinting)
					material.albedo_color = Color(1.0, 1.0, 1.0, 1.0)
					material.emission_enabled = false
			else:
				# For boxes, use standard material coloring
				material.albedo_color = color
				material.emission = color
				# Increase emission when active (green)
				if color == active_color:
					material.emission_energy_multiplier = 3.0
				else:
					material.emission_energy_multiplier = 1.0


## Public API: Get current progress for a spell
func get_spell_progress(spell_name: String) -> int:
	return _spell_progress.get(spell_name, 0)


## Public API: Get total poses for a spell
func get_spell_total_poses(spell_name: String) -> int:
	if not _spell_data.has(spell_name):
		return 0
	return _spell_data[spell_name]["sequence"].size()


## Public API: Check if a spell is currently in progress
func is_spell_in_progress(spell_name: String) -> bool:
	return _spell_progress.get(spell_name, 0) > 0
