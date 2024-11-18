extends CanvasLayer

var bsItems = ["Resume","Restart Song","Exit to menu"]
var bsLabels = []
var curSelected = 0

func _ready():
	for i in bsItems:
		var label = Global.alphabet.instantiate()
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
		label.text = i
		bsLabels.append(label)
		add_child(label)

func _physics_process(delta: float):
	if Input.is_action_just_pressed("ui_accept") && !get_parent().blueballed && get_parent().process_mode == PROCESS_MODE_PAUSABLE:
		$ColorRect.modulate.a = 0
		$SongName.visible_ratio = 0
		$Difficulty.visible_ratio = 0
		get_parent().process_mode = PROCESS_MODE_DISABLED
		show()
		Global.playSound("fav")
		for label in bsLabels:
			label.position.x = 0
			label.position.y += (70 * bsLabels.find(label,0)) + 30
	elif Input.is_action_just_pressed("ui_accept") && get_parent().process_mode == PROCESS_MODE_DISABLED:
		match curSelected:
			0:
				get_parent().process_mode = PROCESS_MODE_PAUSABLE
			1:
				get_tree().reload_current_scene()
			2:
				Global.switchScene("res://scenes/menus/MainMenu.tscn")
		hide()
		Global.playSound("unfav")
		Global.bgm.stop()
	if visible:
		if Global.playlist.size() > 0:
			$SongName.text = Global.playlist[0]
			$Difficulty.text = Global.curDiff
		if Input.is_action_just_pressed("up") || Input.is_action_just_pressed("ui_up"):
			curSelected -= 1
			Global.playSound("scroll")
			curSelected = wrap(curSelected,0,bsItems.size())
		if Input.is_action_just_pressed("down") || Input.is_action_just_pressed("ui_down"):
			curSelected += 1
			Global.playSound("scroll")
			curSelected = wrap(curSelected,0,bsItems.size())
		$ColorRect.modulate.a += lerpf(0,1,0.1)
		$SongName.visible_ratio += lerpf(0,1,0.05)
		$Difficulty.visible_ratio += lerpf(0,1,0.05)
		for label in bsLabels:
			#label.position.y = lerp(label.position.y,destinations[destinations.find(label,0)],0.16)
			label.position.x = lerp(float(label.position.x),float((bsLabels.find(label,0)*20))+20,0.16)
			label.position.y = lerp((120.0 * bsLabels.find(label,0)) + 200.0,(70 * bsLabels.find(label,0))+remap(bsLabels.find(label,0),0,1,0,1.3)+(720*0.48),0.16)
			if curSelected == bsLabels.find(label,0):
				label.modulate.a = 1
			else:
				label.modulate.a = 0.6

func _on_visibility_changed():
	if visible:
		Global.bgm.stream = preload("res://assets/music/breakfast.ogg")
		Global.fadeBGMusic(true,0.47,0.7)
		Global.loopBGM = true
		Global.bgm.play()
