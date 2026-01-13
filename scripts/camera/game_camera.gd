extends Camera2D
## Camera that follows the player.
## Should be a child of the player node for automatic following.

# Offset from player origin
# X=64 centers on player sprite (player is 128px wide)
# Y=200 looks ahead below the player
const PLAYER_CENTER_X := 64.0
const LOOK_AHEAD_Y := 200.0


func _ready() -> void:
	# Position camera relative to player
	# X centers on player sprite, Y looks below
	position = Vector2(PLAYER_CENTER_X, PLAYER_CENTER_X + LOOK_AHEAD_Y)
	make_current()
