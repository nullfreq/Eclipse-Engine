extends Button
class_name RemapButton

signal action_remapped(action, event)

@export var action: String

func _init():
	focus_mode = FOCUS_NONE
	toggle_mode = true
	
func _ready():
	set_process_unhandled_input(false)
	update_key_text()
	
func _toggled(button_pressed):
	set_process_unhandled_input(button_pressed)
	if button_pressed:
		text = "... Awaiting Input ..."
		release_focus()
	else:
		update_key_text()
		grab_focus()
		
func _unhandled_input(event):
	if !event == InputEventMouse || !event == InputEventMouseButton || !event == InputEventMouseMotion: 
		if event.pressed:
			InputMap.action_erase_events(action)
			InputMap.action_add_event(action, event)
			button_pressed = false
			action_remapped.emit(action, event)
			#Global.configData.erase(action)
			#Global.configData.get_or_add(action, event)
	
func update_key_text():
	text = action.capitalize()+": "+"%s" % InputMap.action_get_events(action)[0].as_text().trim_suffix("(Physical)")
