extends ShapedNode

@export var off_color: Color = Color(0.8, 0.2, 0.2)
@export var on_color: Color = Color(0.2, 0.8, 0.2)
var color: Color = off_color

func _draw():
	draw_colored_polygon(get_shape(), color)

func _ready():
	super._ready()
	if GameInfo.editing:
		return
	GameInfo.switches_for_goal += 1
	GameInfo.goal_inactive.emit()
	GameInfo.reload.connect(reload)

@export var state = false
@export var toggle = false

func _on_body_entered(body):
	if GameInfo.editing:
		return
	if body is Ball:
		toggle_state()

func set_state(s: bool):
	if !state && s:
		color = on_color
		GameInfo.switches_for_goal_active += 1
		if GameInfo.switches_for_goal_active >= GameInfo.switches_for_goal:
			GameInfo.goal_active.emit()
	elif state && !s:
		color = off_color
		GameInfo.switches_for_goal_active -= 1
		if GameInfo.switches_for_goal_active < GameInfo.switches_for_goal:
			GameInfo.goal_inactive.emit()
	state = s
	queue_redraw()

func toggle_state():
	if !state:
		set_state(true)
	elif toggle:
		set_state(false)

func reload():
	state = false
	color = off_color
	queue_redraw()
	GameInfo.switches_for_goal += 1
	GameInfo.goal_inactive.emit()

func get_menu_edit_attributes() -> Array:
	var base = super.get_menu_edit_attributes()
	base.append(ToggleAttribute.create(
					"toggle",
					self,
					"Toggle",
				))
	return base

