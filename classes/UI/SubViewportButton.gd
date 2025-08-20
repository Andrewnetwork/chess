class_name SubViewportButton
extends Button

var subviewport: SubViewport

func add(node: Node):
	subviewport.add_child(node)
func _init() -> void:
	child_entered_tree.connect(_child_entered_tree)
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
func _enter_tree() -> void:
	if subviewport == null:
		update_configuration_warnings()
func _child_entered_tree(node: Node):
	if node is SubViewport:
		subviewport = node
func _get_configuration_warnings() -> PackedStringArray:
	if subviewport == null:
		return ["No child viewport! Must have a child viewport to render the button's texture."]
	return []
func _draw() -> void:
	if subviewport != null:
		draw_texture(subviewport.get_texture(), Vector2.ZERO)
	else:
		update_configuration_warnings()
