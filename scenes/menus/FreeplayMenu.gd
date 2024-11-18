extends Node

var songList = []
var songLabels = []
var songColors = []
var songIconNames = []
var songIcons = []
var difficulties = []
var curSelected = 0
var started = false
var leavin = false
var flickerCount = 0
var maxFlicker = 12
var selectedSumthin = false
var curDiffSelected = 0

func _ready():
	#var d = DirAccess.open("res://assets/songs/")
	#for f in d.get_directories():
		#songList.append(f)
	var weekShit:Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://assets/data/weeks.json"))
	#print(weekShit)
	for week in weekShit:
		#print("week found: "+week)
		for song in weekShit[week]["songs"]:
			songList.append(song)
			var color = weekShit[week]["color"]
			songColors.append(color)
			songIconNames.append(weekShit[week]["icon"])
	for i in songList:
		var label = Global.alphabet.instantiate()
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
		label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
		label.text = i
		songLabels.append(label)
		add_child(label)
	for i in songIconNames:
		var icon = Sprite2D.new()
		icon.texture = load("res://assets/images/gameplay/icons/icon-"+i+".png")
		icon.hframes = 2
		icon.frame = 0
		icon.centered = false
		icon.scale = Vector2(0.9,0.9)
		songIcons.append(icon)
		add_child(icon)

func _physics_process(delta: float):
	if !started:
		for label in songLabels:
			label.position.x = 0
			label.position.y += (70 * songLabels.find(label,0)) + 30
		for icon in songIcons:
			icon.position.x = 0
			icon.position.y += (70 * songIcons.find(icon,0)) + 30
		started = true
		Global.bgm.stream = load("res://assets/songs/"+songList[curSelected]+"/audio/Inst.ogg")
		Global.bgm.play()
		getDifficulties()
	if started:
		if Input.is_action_just_pressed("up") || Input.is_action_just_pressed("ui_up"):
			curSelected -= 1
			Global.playSound("scroll")
			curSelected = wrap(curSelected,0,songList.size())
			Global.bgm.stream = load("res://assets/songs/"+songList[curSelected]+"/audio/Inst.ogg")
			Global.bgm.play()
			getDifficulties()
		if Input.is_action_just_pressed("down") || Input.is_action_just_pressed("ui_down"):
			curSelected += 1
			Global.playSound("scroll")
			curSelected = wrap(curSelected,0,songList.size())
			Global.bgm.stream = load("res://assets/songs/"+songList[curSelected]+"/audio/Inst.ogg")
			Global.bgm.play()
			getDifficulties()
		if Input.is_action_just_pressed("left") || Input.is_action_just_pressed("ui_left"):
			curDiffSelected -= 1
			Global.playSound("scroll")
			curDiffSelected = wrap(curDiffSelected,0,difficulties.size())
			$CanvasLayer/Area/Diff.text = "<"+difficulties[curDiffSelected]+">"
		if Input.is_action_just_pressed("right") || Input.is_action_just_pressed("ui_right"):
			curDiffSelected += 1
			Global.playSound("scroll")
			curDiffSelected = wrap(curDiffSelected,0,difficulties.size())
			$CanvasLayer/Area/Diff.text = "<"+difficulties[curDiffSelected]+">"
		$Camera2D.position = songLabels[curSelected].position
		for label in songLabels:
			label.position.x = lerp(float(label.position.x),float((songLabels.find(label,0)*20))+20,0.16)
			label.position.y = lerp((120.0 * songLabels.find(label,0)) + 200.0,(70 * songLabels.find(label,0))+remap(songLabels.find(label,0),0,1,0,1.3)+(720*0.48),0.16)
			if curSelected == songLabels.find(label,0):
				label.modulate.a = 1
			else:
				label.modulate.a = 0.6
		for icon in songIcons:
			icon.position.x = lerp(float(icon.position.x),float((songLabels[songIcons.find(icon,0)].position.x))+(songLabels[songIcons.find(icon,0)].size.x),0.16)
			icon.position.y = lerp((120.0 * songIcons.find(icon,0)) + 150.0,(85 * songIcons.find(icon,0))+remap(songIcons.find(icon,0),0,1,0,1.3)+(720*0.48),0.16)
			if curSelected == songIcons.find(icon,0):
				icon.modulate.a = 1
			else:
				icon.modulate.a = 0.6
		$BGc/BG.modulate = lerp($BGc/BG.modulate,Color.html(songColors[curSelected]),0.16)
			
	if Input.is_action_just_pressed("ui_unfocus") && !leavin:
		leavin = true
		Global.playSound("cancel")
		Global.switchScene("res://scenes/menus/MainMenu.tscn")
	if Input.is_action_just_pressed("ui_accept") && !selectedSumthin:
		Global.playSound("confirm")
		selectedSumthin = true
		songLabels[curSelected].visible = not songLabels[curSelected].visible
		$Timer.start()
		Global.playlist.clear()
		Global.playlist.append(songList[curSelected])
		Global.curDiff = difficulties[curDiffSelected]

func _on_timer_timeout():
	if flickerCount < maxFlicker:
		songLabels[curSelected].visible = not songLabels[curSelected].visible
		flickerCount += 1
		$Timer.start()
	else:
		Global.switchScene("res://scenes/gameplay/PlayScene.tscn")

func getDifficulties():
	difficulties.clear()
	var d = DirAccess.open("res://assets/songs/"+songList[curSelected]+"/charts")
	for f in d.get_files():
		difficulties.append(f.trim_suffix(".json"))
	var baseDiffs = ["easy","normal","hard"]
	for diff in baseDiffs:
		if difficulties.has(diff):
			difficulties.erase(diff)
			difficulties.push_back(diff)
	for diff in difficulties:
		if !baseDiffs.has(diff):
			difficulties.erase(diff)
			difficulties.push_back(diff)
	if curDiffSelected > difficulties.size()-1:
		curDiffSelected = difficulties.size()-1
	$CanvasLayer/Area/Diff.text = "<"+difficulties[curDiffSelected]+">"
	$CanvasLayer/Area/SongName.text = str(songList[curSelected]).capitalize()
