@tool
extends ShapedNode

@export var on_color: Color = Color.from_hsv(0, 0, 0.15)
@export var off_color: Color = Color.from_hsv(0, 0, 0.5)

@export var toggle_state: bool = true

func _draw():
	if toggle_state:
		draw_colored_polygon(get_shape(), on_color)
	else:
		draw_colored_polygon(get_shape(), off_color)

var layer: int
var mask: int

var me: StaticBody2D = self as Node as StaticBody2D

var orig_toggle_state: bool

# Called when the node enters the scene tree for the first time.
func _ready():
	super._ready()
	if Engine.is_editor_hint():
		return
	layer = me.collision_layer
	mask =  me.collision_mask
	GameInfo.contact_stuffs.connect(_on_ball_contact_stuffs)
	GameInfo.reload.connect(reload)
	orig_toggle_state = toggle_state
	if !toggle_state:
		me.collision_layer = 0
		me.collision_mask = 0

func _on_ball_contact_stuffs(stuff: PhysicsDirectBodyState2D, ball: Ball):
	toggle_state = !toggle_state
	queue_redraw()
	if toggle_state:
		me.collision_layer = layer
		me.collision_mask = mask
	else:
		me.collision_layer = 0
		me.collision_mask = 0

func get_menu_edit_attributes() -> Array:
	var base = super.get_menu_edit_attributes()
	base.append(ToggleAttribute.create(
					"toggle_state",
					self,
					"State",
				))
	return base

func reload():
	toggle_state = orig_toggle_state
	if toggle_state:
		me.collision_layer = layer
		me.collision_mask = mask
	else:
		me.collision_layer = 0
		me.collision_mask = 0
	queue_redraw()
