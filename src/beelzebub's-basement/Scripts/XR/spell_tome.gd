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

# Exported properties
@export_group("Visual")
@export var pose_indicator_scene : PackedScene
@export var inactive_color : Color = Color(0.141, 0.145, 0.146, 1.0)
@export var active_color : Color = Color(0.0, 0.719, 0.128, 1.0)  # Green for active/completed

@export_group("Layout")
@export var spell_spacing : float = 0.4
@export var pose_spacing : float = 0.3


func _ready() -> void:
	# Get spell definitions from the spell detector script
	_load_spell_definitions()
	
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


func _create_spell_indicators(spell_name: String, sequence: Array) -> void:
	# Skip if indicators already exist
	if _pose_indicators.has(spell_name):
		return
	
	# Create a container node for this spell's indicators
	var spell_container = Node3D.new()
	spell_container.name = spell_name + "_indicators"
	
	# Position spell containers vertically
	var spell_index = _spell_data.keys().find(spell_name)
	var y_offset = -spell_index * spell_spacing
	spell_container.position = Vector3(0, y_offset, 0)
	
	add_child(spell_container)
	
	# Create a label for the spell name (using a simple approach)
	# You can enhance this with Label3D or other 3D text solutions
	
	var indicators : Array = []
	
	# Create an indicator for each pose in the sequence
	for i in range(sequence.size()):
		var pose_name = sequence[i]
		var indicator = _create_pose_indicator(pose_name, i, sequence.size())
		spell_container.add_child(indicator)
		indicators.append(indicator)
	
	_pose_indicators[spell_name] = indicators


func _create_pose_indicator(pose_name: String, index: int, total: int) -> Node3D:
	# Create a container for the indicator
	var indicator = Node3D.new()
	indicator.name = "Pose_" + pose_name + "_" + str(index)
	
	# Create a simple box mesh as placeholder
	var mesh_instance = MeshInstance3D.new()
	var mesh = BoxMesh.new()
	mesh.size = Vector3(0.12, 0.12, 0.02)  # Slightly smaller to prevent overlap
	mesh_instance.mesh = mesh
	
	# Create material
	var material = StandardMaterial3D.new()
	material.albedo_color = inactive_color
	material.emission_enabled = true
	material.emission = inactive_color
	material.emission_energy_multiplier = 2.0
	mesh_instance.material_override = material
	
	indicator.add_child(mesh_instance)
	
	# Create a label to show pose name (using Label3D if available, otherwise just store name)
	# Note: Label3D requires Godot 4.2+, using a simple approach here
	# You can replace this with Label3D or Sprite3D with text texture
	
	# Position indicator
	var offset = (index - (total - 1) / 2.0) * pose_spacing
	indicator.position = Vector3(offset, 0, 0)
	
	# Store pose name and visual reference for reference
	indicator.set_meta("pose_name", pose_name)
	indicator.set_meta("pose_index", index)
	indicator.set_meta("mesh_instance", mesh_instance)
	
	return indicator


func _set_indicator_color(indicator: Node3D, color: Color) -> void:
	if not is_instance_valid(indicator):
		return
	
	# Get the mesh instance from metadata or find it
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
