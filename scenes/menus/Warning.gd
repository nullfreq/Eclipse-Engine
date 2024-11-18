extends Node2D

var scene2redirect2 = "res://scenes/menus/OptimizedTitle.tscn"
var leavin = false

func _ready():
	pass
	
func _on_warning_text_gui_input(event: InputEvent):
	if event.is_action_pressed("leftClick") && !leavin:
		leavin = true
		Global.playSound("confirm")
		Global.switchScene(scene2redirect2)

func _physics_process(delta: float):
	if Input.is_action_just_pressed("ui_accept") && !leavin:
		leavin = true
		Global.playSound("confirm")
		Global.switchScene(scene2redirect2)
