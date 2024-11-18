extends Node2D

var buttonList = ["storymode","freeplay","options"]
var buttonScenes = ["res://scenes/gameplay/PlayScene.tscn","res://scenes/menus/FreeplayMenu.tscn","res://scenes/menus/Options.tscn"]
#var buttonScenes = ["res://scenes/gameplay/PlayScene.tscn","res://scenes/testing/placeholder.tscn","res://scenes/testing/placeholder.tscn","res://scenes/testing/placeholder.tscn"]
var buttonSprites = []
var curSelected = 0
var selectedSumthin = false
var flickerCount = 0
var maxFlicker = 12
var inModMenu = false
var leavin = false

func _ready():
	#$CanvasLayer/Version.text = "Eclipse Engine v"+str(ProjectSettings.get_setting("application/config/version"))
	if !Global.bgm.playing:
		Global.bgm.stream = preload("res://assets/music/freakyMenu.ogg")
		Global.fadeBGMusic(true,0.01,0.7)
		Global.loopBGM = true
		Global.bgm.play()
	for i in buttonList:
		var button = AnimatedSprite2D.new()
		button.sprite_frames = load("res://assets/images/menus/mainmenu/"+i+".xml")
		button.position.x = 640
		button.position.y = 60+(160*buttonList.find(i,0))
		buttonSprites.append(button)
		add_child(button)

func _process(delta: float):
	if Input.is_action_just_pressed("debugA") && !inModMenu && Global.debug:
		var modMenu = preload("res://scenes/menus/ModMenu.tscn")
		var m = modMenu.instantiate(PackedScene.GEN_EDIT_STATE_MAIN)
		add_child(m)
		inModMenu = true
	
	$Camera2D.position = buttonSprites[curSelected].position
	if inModMenu:
		$Camera2D.enabled = false
		$Camera2D.visible = false

	if !inModMenu:
		$Camera2D.enabled = true
		$Camera2D.visible = false
		if Input.is_action_just_pressed("up") || Input.is_action_just_pressed("ui_up"):
			Global.playSound("scroll")
			curSelected -= 1
			curSelected = wrap(curSelected,0,buttonList.size())
		
		if Input.is_action_just_pressed("down") || Input.is_action_just_pressed("ui_down"):
			Global.playSound("scroll")
			curSelected += 1
			curSelected = wrap(curSelected,0,buttonList.size())

		for i in buttonSprites:
			if buttonSprites.find(i,0) == curSelected:
				i.play(buttonList[curSelected]+" selected")
			else:
				i.play(buttonList[buttonSprites.find(i,0)]+" idle")
		
		if Input.is_action_just_pressed("ui_accept") && !selectedSumthin:
			Global.playSound("confirm")
			selectedSumthin = true
			buttonSprites[curSelected].visible = not buttonSprites[curSelected].visible
			$Timer.start()
			if curSelected == 0:
				Global.playlist = ["bopeebo","fresh","dadbattle"]
				Global.curDiff = "hard"
		
		if Input.is_action_just_pressed("ui_unfocus") && !leavin:
			leavin = true
			Global.playSound("cancel")
			Global.switchScene("res://scenes/menus/OptimizedTitle.tscn")

func _on_timer_timeout():
	if flickerCount < maxFlicker:
		buttonSprites[curSelected].visible = not buttonSprites[curSelected].visible
		flickerCount += 1
		$Timer.start()
	else:
		Global.switchScene(buttonScenes[curSelected])
