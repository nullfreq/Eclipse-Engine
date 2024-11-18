extends Node2D

func _on_texture_rect_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("leftClick"):
		print("click the bart")
