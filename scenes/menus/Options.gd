extends Node2D

var actions = ["left","down","up","right","ui_left","ui_down","ui_up","ui_right","debugA","debugB"]
var leavin = false

func _ready():
	$CanvasLayer/Panel/Options/Audio/BGMLabel/BGMToggle.button_pressed = Global.bgmEnabled
	for i in actions:
		var option = RemapButton.new()
		option.action = i
		$CanvasLayer/Panel/Options/Controls.add_child(option)
	$CanvasLayer/Panel/Options.set_anchors_preset(Control.PRESET_CENTER)

func _physics_process(delta: float):
	if Input.is_action_just_pressed("ui_unfocus") && !leavin:
		leavin = true
		var fuckballs = Global.configData.controls
		for action in actions:
			fuckballs.erase(action)
			var fucker = InputMap.action_get_events(action)[0]
			var fucker2 = fucker["keycode"]
			fuckballs.get_or_add(action,fucker2)
		Global.configData.erase("bgmEnabled")
		Global.configData.get_or_add("bgmEnabled",$CanvasLayer/Panel/Options/Audio/BGMLabel/BGMToggle.button_pressed)
		Global.saveData(JSON.stringify(Global.configData,"\t"),"config",1)
		Global.playSound("cancel")
		Global.switchScene("res://scenes/menus/MainMenu.tscn")
