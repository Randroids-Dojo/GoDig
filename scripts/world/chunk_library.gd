extends Node
## ChunkLibrary - Library of pre-designed cave room templates.
##
## Based on Spelunky's approach: handcrafted room designs that are
## procedurally assembled. Each template defines entry/exit points
## to ensure levels are always completable.
##
## Template Types:
## - chamber: Large open area with ore veins on walls
## - tunnel: Horizontal passage connecting areas
## - shaft: Vertical drop with platforms
## - treasure: Hidden room behind secret wall
## - rest: Safe platform for ladder conservation
## - ore_pocket: Dense ore concentration
## - hazard: Dangerous area (crumbling blocks, etc.)

const ChunkTemplateScript = preload("res://resources/chunks/chunk_template.gd")

## All available templates indexed by ID
var _templates: Dictionary = {}

## Templates indexed by type for quick lookup
var _templates_by_type: Dictionary = {}

## Templates indexed by depth range
var _templates_by_depth: Dictionary = {}

## RNG for template selection
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	_create_builtin_templates()
	_index_templates()
	print("[ChunkLibrary] Ready with %d templates" % _templates.size())


## Create all built-in handcrafted templates
func _create_builtin_templates() -> void:
	# ==========================================
	# CHAMBER TEMPLATES - Large open areas
	# ==========================================

	_add_template(_create_template(
		"chamber_basic",
		"Basic Chamber",
		"A simple open chamber with ore on the walls.",
		"chamber",
		8, 6,
		[
			"<.....>#",
			"#......#",
			"#..O...#",
			"#......#",
			"#...O..#",
			"########",
		],
		0, 0, 2.0
	))

	_add_template(_create_template(
		"chamber_open",
		"Open Cavern",
		"A large open space for exploration.",
		"chamber",
		10, 8,
		[
			"<........>",
			"#........#",
			"#........#",
			"#...O....#",
			"#........#",
			"#....O...#",
			"#........#",
			"##########",
		],
		20, 0, 1.5
	))

	_add_template(_create_template(
		"chamber_pillared",
		"Pillared Hall",
		"A chamber with natural pillar formations.",
		"chamber",
		10, 6,
		[
			"<........>",
			"#..#..#..#",
			"#........#",
			"#..#..#..#",
			"#..O..O..#",
			"##########",
		],
		50, 0, 1.2
	))

	# ==========================================
	# TUNNEL TEMPLATES - Horizontal passages
	# ==========================================

	_add_template(_create_template(
		"tunnel_straight",
		"Straight Tunnel",
		"A simple horizontal passage.",
		"tunnel",
		8, 3,
		[
			"########",
			"<......>",
			"########",
		],
		0, 0, 3.0
	))

	_add_template(_create_template(
		"tunnel_zigzag",
		"Zigzag Tunnel",
		"A winding horizontal passage.",
		"tunnel",
		10, 5,
		[
			"##########",
			"<....#####",
			"####.....>",
			"#####....#",
			"##########",
		],
		30, 0, 1.5
	))

	_add_template(_create_template(
		"tunnel_ore_vein",
		"Ore Vein Tunnel",
		"A tunnel running through an ore deposit.",
		"tunnel",
		8, 4,
		[
			"#O##O###",
			"<......>",
			"##O....#",
			"########",
		],
		20, 0, 1.8
	))

	# ==========================================
	# SHAFT TEMPLATES - Vertical drops
	# ==========================================

	_add_template(_create_template(
		"shaft_basic",
		"Basic Shaft",
		"A simple vertical drop.",
		"shaft",
		4, 8,
		[
			"#^##",
			"#..#",
			"#..#",
			"#..#",
			"#..#",
			"#..#",
			"#..#",
			"#v##",
		],
		0, 0, 2.0
	))

	_add_template(_create_template(
		"shaft_platforms",
		"Platform Shaft",
		"A vertical shaft with platforms for safe descent.",
		"shaft",
		6, 10,
		[
			"##^###",
			"#....#",
			"#.PP.#",
			"#....#",
			"#.PP.#",
			"#....#",
			"#.PP.#",
			"#....#",
			"#....#",
			"##v###",
		],
		30, 0, 1.5
	))

	_add_template(_create_template(
		"shaft_spiral",
		"Spiral Descent",
		"A spiral shaft for controlled falling.",
		"shaft",
		6, 8,
		[
			"##^###",
			"#....#",
			"#PP..#",
			"#....#",
			"#..PP#",
			"#....#",
			"#PP..#",
			"##v###",
		],
		50, 0, 1.3
	))

	# ==========================================
	# TREASURE TEMPLATES - Hidden loot rooms
	# ==========================================

	_add_template(_create_template(
		"treasure_small",
		"Small Treasure Cache",
		"A hidden alcove with treasure.",
		"treasure",
		5, 4,
		[
			"#####",
			"#T..S",
			"#..T#",
			"#####",
		],
		50, 0, 1.0, ["secret"]
	))

	_add_template(_create_template(
		"treasure_vault",
		"Treasure Vault",
		"A proper vault behind a secret wall.",
		"treasure",
		7, 5,
		[
			"#######",
			"#T.T.T#",
			"#.....S",
			"#T.T.T#",
			"#######",
		],
		100, 0, 0.5, ["secret", "rare"]
	))

	_add_template(_create_template(
		"treasure_trapped",
		"Trapped Treasure",
		"Treasure protected by hazardous terrain.",
		"treasure",
		6, 5,
		[
			"######",
			"#T..W#",
			"#.WW.S",
			"#..WT#",
			"######",
		],
		150, 0, 0.7, ["secret", "hazard"]
	))

	# ==========================================
	# REST TEMPLATES - Safe platforms
	# ==========================================

	_add_template(_create_template(
		"rest_ledge",
		"Rest Ledge",
		"A safe platform for catching breath.",
		"rest",
		6, 4,
		[
			"######",
			"<....>",
			"#PPPP#",
			"######",
		],
		0, 0, 1.5, ["safe"]
	))

	_add_template(_create_template(
		"rest_alcove",
		"Safe Alcove",
		"A protected alcove with room to place ladders.",
		"rest",
		5, 5,
		[
			"#####",
			"#...#",
			"#.L.#",
			"#PPP#",
			"##v##",
		],
		30, 0, 1.2, ["safe"]
	))

	_add_template(_create_template(
		"rest_platform_chain",
		"Platform Chain",
		"Multiple platforms for easy vertical traversal.",
		"rest",
		6, 8,
		[
			"######",
			"<....#",
			"#PP..#",
			"#....#",
			"#..PP#",
			"#....#",
			"#PP..>",
			"######",
		],
		50, 0, 1.0, ["safe"]
	))

	# ==========================================
	# ORE POCKET TEMPLATES - Dense resources
	# ==========================================

	_add_template(_create_template(
		"ore_pocket_small",
		"Small Ore Pocket",
		"A concentrated ore deposit.",
		"ore_pocket",
		5, 4,
		[
			"#####",
			"#OOO#",
			"<O.O>",
			"#####",
		],
		20, 0, 1.5
	))

	_add_template(_create_template(
		"ore_pocket_large",
		"Large Ore Deposit",
		"A major ore deposit worth excavating.",
		"ore_pocket",
		7, 6,
		[
			"#######",
			"#OOOOO#",
			"<O...O>",
			"#O...O#",
			"#OOOOO#",
			"#######",
		],
		50, 0, 1.0
	))

	_add_template(_create_template(
		"ore_pocket_vein",
		"Ore Vein",
		"A natural vein of ore running through rock.",
		"ore_pocket",
		8, 4,
		[
			"###O####",
			"<.O...O>",
			"##O..O##",
			"########",
		],
		30, 0, 1.3
	))

	# ==========================================
	# HAZARD TEMPLATES - Dangerous areas
	# ==========================================

	_add_template(_create_template(
		"hazard_crumble",
		"Crumbling Passage",
		"A passage with unstable blocks.",
		"hazard",
		8, 4,
		[
			"########",
			"<WWWWWW>",
			"#......#",
			"########",
		],
		80, 0, 1.2, ["dangerous"]
	))

	_add_template(_create_template(
		"hazard_drop",
		"Dangerous Drop",
		"A shaft with no platforms - careful!",
		"hazard",
		4, 8,
		[
			"#^##",
			"#..#",
			"#..#",
			"#..#",
			"#..#",
			"#WW#",
			"#..#",
			"#v##",
		],
		100, 0, 0.8, ["dangerous"]
	))

	_add_template(_create_template(
		"hazard_maze",
		"Danger Maze",
		"A tight maze with crumbling blocks.",
		"hazard",
		8, 6,
		[
			"########",
			"<.W.W.W>",
			"#W...W.#",
			"#.W.W..#",
			"#...W.T#",
			"########",
		],
		150, 0, 0.6, ["dangerous", "secret"]
	))

	# ==========================================
	# DANGER ZONE TEMPLATES - Optional risk/reward areas
	# ==========================================

	# Collapsed Mine - Falling debris, high ore density
	_add_template(_create_template(
		"danger_collapsed_mine",
		"Collapsed Mine Shaft",
		"Unstable shaft with falling debris. Rich ore deposits!",
		"danger_zone",
		8, 8,
		[
			"#W##W###",
			"<..OO..>",
			"#W....W#",
			"#..OO..#",
			"#W....W#",
			"#..OO..#",
			"#W....W#",
			"########",
		],
		30, 0, 1.0, ["dangerous", "collapsed", "ore_rich"]
	))

	_add_template(_create_template(
		"danger_collapsed_chamber",
		"Crumbling Cavern",
		"Large unstable chamber. Beware falling blocks!",
		"danger_zone",
		10, 6,
		[
			"#WW####WW#",
			"<...OO...>",
			"#W......W#",
			"#..OOOO..#",
			"#W......W#",
			"##########",
		],
		50, 0, 0.8, ["dangerous", "collapsed", "ore_rich"]
	))

	# Lava Pocket - Heat damage, fire gems
	_add_template(_create_template(
		"danger_lava_pocket",
		"Lava Pocket",
		"Extreme heat! Move quickly for fire gems.",
		"danger_zone",
		8, 6,
		[
			"########",
			"<..OO..>",
			"#......#",
			"#..TT..#",
			"#......#",
			"########",
		],
		120, 0, 0.7, ["dangerous", "lava", "heat", "unique_drops"]
	))

	_add_template(_create_template(
		"danger_lava_chamber",
		"Molten Chamber",
		"Scorching hot chamber with rare molten cores.",
		"danger_zone",
		10, 8,
		[
			"##########",
			"<........>",
			"#..OOOO..#",
			"#........#",
			"#...TT...#",
			"#........#",
			"#..OOOO..#",
			"##########",
		],
		150, 0, 0.5, ["dangerous", "lava", "heat", "unique_drops", "rare"]
	))

	# Flooded Section - Drowning damage, water crystals
	_add_template(_create_template(
		"danger_flooded_tunnel",
		"Flooded Tunnel",
		"Water-filled passage. Limited visibility, rare crystals.",
		"danger_zone",
		10, 4,
		[
			"##########",
			"<..OO..OO>",
			"#........#",
			"##########",
		],
		80, 0, 0.9, ["dangerous", "flooded", "water", "unique_drops"]
	))

	_add_template(_create_template(
		"danger_flooded_chamber",
		"Sunken Chamber",
		"Underwater chamber with aquamarine deposits.",
		"danger_zone",
		8, 8,
		[
			"########",
			"<......>",
			"#..OO..#",
			"#......#",
			"#..TT..#",
			"#......#",
			"#..OO..#",
			"########",
		],
		100, 0, 0.6, ["dangerous", "flooded", "water", "unique_drops"]
	))

	# Gas Pocket - Poison damage, fossil artifacts
	_add_template(_create_template(
		"danger_gas_tunnel",
		"Toxic Passage",
		"Poisonous fumes. Don't linger! Fossils within.",
		"danger_zone",
		8, 4,
		[
			"########",
			"<.OO.OO>",
			"#..TT..#",
			"########",
		],
		50, 0, 0.9, ["dangerous", "gas", "toxic", "unique_drops"]
	))

	_add_template(_create_template(
		"danger_gas_chamber",
		"Noxious Cavern",
		"Toxic gas fills this cave. Rare fossils preserved here.",
		"danger_zone",
		8, 6,
		[
			"########",
			"<......>",
			"#.OOOO.#",
			"#..TT..#",
			"#.OOOO.#",
			"########",
		],
		80, 0, 0.7, ["dangerous", "gas", "toxic", "unique_drops"]
	))

	# ==========================================
	# SPECIAL DEPTH-SPECIFIC TEMPLATES
	# ==========================================

	# Crystal caves specific
	_add_template(_create_template(
		"crystal_grotto",
		"Crystal Grotto",
		"A chamber filled with crystal formations.",
		"chamber",
		8, 6,
		[
			"<......>",
			"#.O..O.#",
			"#..OO..#",
			"#.O..O.#",
			"#..OO..#",
			"########",
		],
		450, 550, 1.5, ["crystal"]
	))

	# Deep areas
	_add_template(_create_template(
		"deep_chasm",
		"Deep Chasm",
		"A massive vertical drop into darkness.",
		"shaft",
		6, 12,
		[
			"##^###",
			"#....#",
			"#....#",
			"#....#",
			"#PP..#",
			"#....#",
			"#....#",
			"#..PP#",
			"#....#",
			"#....#",
			"#....#",
			"##v###",
		],
		300, 0, 0.8, ["deep"]
	))

	# Void depths
	_add_template(_create_template(
		"void_chamber",
		"Void Chamber",
		"A strange chamber in the void depths.",
		"chamber",
		10, 8,
		[
			"<........>",
			"#........#",
			"#..OOOO..#",
			"#..O..O..#",
			"#..O..O..#",
			"#..OOOO..#",
			"#...TT...#",
			"##########",
		],
		1200, 0, 0.5, ["void", "rare"]
	))


## Helper to create a template
func _create_template(
	id: String,
	display_name: String,
	description: String,
	template_type: String,
	width: int,
	height: int,
	pattern: Array,
	min_depth: int,
	max_depth: int,
	spawn_weight: float,
	tags: Array = []
) -> ChunkTemplateScript:
	var template := ChunkTemplateScript.new()
	template.id = id
	template.display_name = display_name
	template.description = description
	template.template_type = template_type
	template.width = width
	template.height = height
	template.min_depth = min_depth
	template.max_depth = max_depth
	template.spawn_weight = spawn_weight

	var packed_pattern: PackedStringArray = []
	for row in pattern:
		packed_pattern.append(row)
	template.pattern = packed_pattern

	var packed_tags: PackedStringArray = []
	for tag in tags:
		packed_tags.append(tag)
	template.tags = packed_tags

	return template


## Add a template to the library
func _add_template(template: ChunkTemplateScript) -> void:
	# Validate template
	var validation := template.validate()
	if not validation["valid"]:
		push_warning("[ChunkLibrary] Invalid template %s: %s" % [template.id, str(validation["errors"])])
		return

	_templates[template.id] = template

	# Also add rotated/mirrored variants for variety
	if template.template_type in ["chamber", "tunnel", "ore_pocket"]:
		var mirrored := template.mirrored_horizontal()
		_templates[mirrored.id] = mirrored


## Index templates for quick lookup
func _index_templates() -> void:
	_templates_by_type.clear()
	_templates_by_depth.clear()

	for id in _templates:
		var template: ChunkTemplateScript = _templates[id]

		# Index by type
		if not _templates_by_type.has(template.template_type):
			_templates_by_type[template.template_type] = []
		_templates_by_type[template.template_type].append(template)


## Get a template by ID
func get_template(id: String) -> ChunkTemplateScript:
	return _templates.get(id)


## Get all templates of a specific type
func get_templates_by_type(template_type: String) -> Array:
	return _templates_by_type.get(template_type, [])


## Get all templates valid for a specific depth
func get_templates_at_depth(depth: int) -> Array:
	var result: Array = []
	for id in _templates:
		var template: ChunkTemplateScript = _templates[id]
		if template.can_spawn_at_depth(depth):
			result.append(template)
	return result


## Get templates by type and depth
func get_templates(template_type: String, depth: int) -> Array:
	var result: Array = []
	var type_templates = _templates_by_type.get(template_type, [])
	for template in type_templates:
		if template.can_spawn_at_depth(depth):
			result.append(template)
	return result


## Select a random template with weighted probability
func select_random_template(template_type: String, depth: int, rng: RandomNumberGenerator = null) -> ChunkTemplateScript:
	var candidates := get_templates(template_type, depth)
	if candidates.is_empty():
		return null

	var use_rng := rng if rng != null else _rng

	# Calculate total weight
	var total_weight := 0.0
	for template in candidates:
		total_weight += template.spawn_weight

	# Weighted random selection
	var roll := use_rng.randf() * total_weight
	var cumulative := 0.0

	for template in candidates:
		cumulative += template.spawn_weight
		if roll <= cumulative:
			return template

	return candidates[0]  # Fallback


## Select a random template with tags filter
func select_random_template_with_tags(
	template_type: String,
	depth: int,
	required_tags: Array = [],
	excluded_tags: Array = [],
	rng: RandomNumberGenerator = null
) -> ChunkTemplateScript:
	var candidates := get_templates(template_type, depth)

	# Filter by tags
	var filtered: Array = []
	for template in candidates:
		# Check required tags
		var has_required := true
		for tag in required_tags:
			if not template.has_tag(tag):
				has_required = false
				break

		if not has_required:
			continue

		# Check excluded tags
		var has_excluded := false
		for tag in excluded_tags:
			if template.has_tag(tag):
				has_excluded = true
				break

		if has_excluded:
			continue

		filtered.append(template)

	if filtered.is_empty():
		return null

	var use_rng := rng if rng != null else _rng

	# Weighted random selection
	var total_weight := 0.0
	for template in filtered:
		total_weight += template.spawn_weight

	var roll := use_rng.randf() * total_weight
	var cumulative := 0.0

	for template in filtered:
		cumulative += template.spawn_weight
		if roll <= cumulative:
			return template

	return filtered[0]


## Get statistics about the library
func get_stats() -> Dictionary:
	var stats := {
		"total_templates": _templates.size(),
		"by_type": {},
	}

	for template_type in _templates_by_type:
		stats["by_type"][template_type] = _templates_by_type[template_type].size()

	return stats


## Get all template IDs
func get_all_template_ids() -> Array:
	return _templates.keys()
