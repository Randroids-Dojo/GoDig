extends CanvasLayer
## Performance Debug Overlay
##
## Displays real-time performance metrics when enabled.
## Toggle with F3 key or programmatically via show()/hide().
##
## Shows:
## - FPS and frame time
## - Memory usage
## - Chunk loading status
## - Particle counts
## - Quality preset
##
## Useful for mobile profiling and optimization work.

@onready var panel: PanelContainer = $Panel
@onready var stats_label: Label = $Panel/MarginContainer/VBox/StatsLabel
@onready var preset_buttons: HBoxContainer = $Panel/MarginContainer/VBox/PresetButtons
@onready var adaptive_toggle: CheckButton = $Panel/MarginContainer/VBox/AdaptiveToggle

var _update_timer: float = 0.0
const UPDATE_INTERVAL := 0.25  # Update 4 times per second


func _ready() -> void:
	# Start hidden
	visible = false
	layer = 100  # Always on top

	# Connect to PerformanceMonitor signals
	if PerformanceMonitor:
		PerformanceMonitor.performance_warning.connect(_on_performance_warning)
		PerformanceMonitor.quality_preset_changed.connect(_on_preset_changed)

	# Setup preset buttons
	_setup_preset_buttons()

	# Setup adaptive toggle
	if adaptive_toggle and PerformanceMonitor:
		adaptive_toggle.button_pressed = PerformanceMonitor.adaptive_mode
		adaptive_toggle.toggled.connect(_on_adaptive_toggled)


func _setup_preset_buttons() -> void:
	if not preset_buttons:
		return

	# Create buttons for each preset
	for preset in PerformanceMonitor.QualityPreset.values():
		var btn := Button.new()
		btn.text = PerformanceMonitor.QualityPreset.keys()[preset]
		btn.custom_minimum_size = Vector2(60, 30)
		btn.pressed.connect(_on_preset_button_pressed.bind(preset))
		preset_buttons.add_child(btn)

	_update_preset_buttons()


func _update_preset_buttons() -> void:
	if not preset_buttons or not PerformanceMonitor:
		return

	var current := PerformanceMonitor.quality_preset
	for i in preset_buttons.get_child_count():
		var btn := preset_buttons.get_child(i) as Button
		if btn:
			btn.disabled = (i == current)


func _process(delta: float) -> void:
	if not visible:
		return

	_update_timer += delta
	if _update_timer >= UPDATE_INTERVAL:
		_update_timer = 0.0
		_update_stats_display()


func _input(event: InputEvent) -> void:
	# Toggle overlay with F3
	if event is InputEventKey and event.pressed and event.keycode == KEY_F3:
		visible = not visible
		get_viewport().set_input_as_handled()


func _update_stats_display() -> void:
	if not stats_label or not PerformanceMonitor:
		return

	# Update chunk metrics from DirtGrid if available
	var dirt_grid := get_tree().get_first_node_in_group("dirt_grid")
	if dirt_grid and dirt_grid.has_method("debug_chunk_count"):
		var chunks_loaded := dirt_grid.debug_chunk_count()
		var threaded_stats := dirt_grid.debug_threaded_stats() if dirt_grid.has_method("debug_threaded_stats") else {}
		var pending := threaded_stats.get("pending_chunks", 0)
		PerformanceMonitor.update_chunk_metrics(chunks_loaded, pending)

		# Also get sparkle stats
		var sparkle_stats := dirt_grid.debug_sparkle_stats() if dirt_grid.has_method("debug_sparkle_stats") else {}
		var active_sparkles := sparkle_stats.get("active_sparkles", 0)
		PerformanceMonitor.update_sparkle_metrics(active_sparkles)

	stats_label.text = PerformanceMonitor.get_stats_string()


func _on_performance_warning(message: String, severity: int) -> void:
	# Could flash the overlay or change color based on severity
	if severity == PerformanceMonitor.WarningSeverity.CRITICAL:
		stats_label.add_theme_color_override("font_color", Color.RED)
		await get_tree().create_timer(0.5).timeout
		stats_label.remove_theme_color_override("font_color")


func _on_preset_changed(_preset: int) -> void:
	_update_preset_buttons()


func _on_preset_button_pressed(preset: int) -> void:
	if PerformanceMonitor:
		PerformanceMonitor.quality_preset = preset as PerformanceMonitor.QualityPreset


func _on_adaptive_toggled(enabled: bool) -> void:
	if PerformanceMonitor:
		PerformanceMonitor.adaptive_mode = enabled


## Show the overlay
func show_overlay() -> void:
	visible = true


## Hide the overlay
func hide_overlay() -> void:
	visible = false


## Toggle the overlay visibility
func toggle_overlay() -> void:
	visible = not visible
