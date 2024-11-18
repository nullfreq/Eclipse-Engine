extends Node2D

var ssCount = 0
var loopBGM = true
var skippedTitleIntro = false
signal audioFadeFinished
@onready var bgm:AudioStreamPlayer = $BGM
@onready var flashRect = $CanvasLayer/FlashRect
@onready var watermark = $"Debug/Watermark lol"
@onready var alphabet = preload("res://scenes/general/FunnyText.tscn")
var curSong:String = ""
var curDiff:String = ""
var playlist = []
var debugEnabled = EngineDebugger.is_active()
var configData:Dictionary = {"controls":{}}
var actions = ["left","down","up","right","ui_left","ui_down","ui_up","ui_right","debugA","debugB"]
var bgmEnabled = configData.get_or_add("bgmEnabled",true)
@onready var dumbBitch = Vector2(get_tree().root.size.x/1280.0,get_tree().root.size.y/720.0)
@onready var rootSize = Vector2(get_tree().root.size.x,get_tree().root.size.y)

func _ready():
	print("dumbBitch: "+str(dumbBitch))
	#get_tree().root.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP_WIDTH
	#get_tree().root.size = Vector2(800,600)
	$"Debug/Watermark lol".text = "Eclipse Engine "+str(ProjectSettings.get_setting("application/config/version"))
	DisplayServer.window_set_title("Eclipse Engine",0)
#	DISCORD RPC
	DiscordRPC.app_id = 1287547028083179530
	DiscordRPC.details = "Playing Eclipse Engine v"+str(ProjectSettings.get_setting("application/config/version"))
	DiscordRPC.start_timestamp = int(Time.get_unix_time_from_system())
	DiscordRPC.refresh()
	print("Discord working: " + str(DiscordRPC.get_is_discord_working()))
#	SCREENSHIT
	var scDir = DirAccess.open("user://")
	if !scDir.dir_exists("user://screenshots/"):
		scDir.make_dir("screenshots")
	scDir = DirAccess.open("user://screenshots/")
	for n in scDir.get_files():
		ssCount += 1
	var saveDir = DirAccess.open("user://")
	if !saveDir.dir_exists("user://saveData/"):
		saveDir.make_dir("saveData")
	if !FileAccess.file_exists("user://saveData/config.json"):
		configData.get_or_add("bgmEnabled",true)
		#configData.get_or_add("controls","")
		for action in actions:
			var fucker = InputMap.action_get_events(action)[0]
			if fucker["keycode"] == 0:
				configData.controls.get_or_add(action,fucker["physical_keycode"])
				print(action+" "+str(fucker["physical_keycode"]))
			if fucker["physical_keycode"] == 0:
				configData.controls.get_or_add(action,fucker["keycode"])
				print(action+" "+str(fucker["keycode"]))
			#configData.controls.get_or_add(action,fucker)
		saveData(JSON.stringify(configData,"\t"),"config",1)
	configData = JSON.parse_string(loadDataFrom("user://saveData/config.json"))
	for action in configData.controls:
		InputMap.action_erase_events(action)
		var fucker2 = configData.controls[action]
		var actionResult = InputEvent
		var preResult = InputEventKey.new()
		preResult.set_keycode(fucker2)
		actionResult = preResult
		InputMap.action_add_event(action,actionResult)
func _process(delta: float):
	bgmEnabled = configData.bgmEnabled
	AudioServer.set_bus_mute(1,not bgmEnabled)
	if !DisplayServer.window_is_focused(0):
		get_tree().paused = true
	else:
		get_tree().paused = false
	var fps = Engine.get_frames_per_second()
	var curMem = OS.get_static_memory_usage()
	var peakMem = OS.get_static_memory_peak_usage()
	$Debug/FPS.text = "FPS: "+str(fps)
	$Debug/Memory.text = "Memory: "+str(snappedf(curMem/1048576,0.01))+" mb / "+str(snappedf(peakMem/1048576,0.01))+" mb"

func _unhandled_input(event: InputEvent):
	if Input.is_action_just_pressed("screenshot"):
		screenshot()
	if Input.is_action_just_pressed("fullscreen"):
		if !DisplayServer.window_get_mode(0) == DisplayServer.WINDOW_MODE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN,0)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED,0)

func screenshot():
	await RenderingServer.frame_post_draw
	
	var viewport = get_viewport()
	var img = viewport.get_texture().get_image()
	img.save_png("user://screenshots/"+str(ssCount)+".png")
	print("Screenshot taken at "+str(Time.get_datetime_string_from_system(false,true)))
	ssCount += 1
	playSound("screenshot")

## It plays a sound, duh...
func playSound(sound:String):
	var sPlayer = AudioStreamPlayer.new()
	sPlayer.bus = "SFX"
	match sound:
		"confirm":
			sPlayer.stream = preload("res://assets/sounds/confirmMenu.ogg")
		"cancel":
			sPlayer.stream = preload("res://assets/sounds/cancelMenu.ogg")
		"scroll":
			sPlayer.stream = preload("res://assets/sounds/scrollMenu.ogg")
		"screenshot":
			sPlayer.stream = preload("res://assets/sounds/screenshot.ogg")
		"noteLay":
			sPlayer.stream = preload("res://assets/sounds/chartingSounds/noteLay.ogg")
		"noteErase":
			sPlayer.stream = preload("res://assets/sounds/chartingSounds/noteErase.ogg")
		"fav":
			sPlayer.stream = preload("res://assets/sounds/fav.ogg")
		"unfav":
			sPlayer.stream = preload("res://assets/sounds/unfav.ogg")
	add_child(sPlayer)
	sPlayer.play()
	await sPlayer.finished
	sPlayer.queue_free()

func flash(color:Color,duration:float,reverse = false):
	if !reverse:
		$CanvasLayer/FlashRect.modulate.a = 1
	else:
		$CanvasLayer/FlashRect.modulate.a = 0
	$CanvasLayer/FlashRect.color = color
	var tween = get_tree().create_tween()
	if !reverse:
		tween.tween_property($CanvasLayer/FlashRect, "modulate:a", 0, duration)
	else:
		tween.tween_property($CanvasLayer/FlashRect, "modulate:a", 1, duration)

func fadeBGMusic(fadeIn:bool,duration:float,vol:float):
	var tween = get_tree().create_tween()
	if fadeIn:
		$BGM.volume_db = linear_to_db(0.001)
		tween.tween_property($BGM, "volume_db", linear_to_db(vol), duration)
		if tween.finished:
			emit_signal("audioFadeFinished")
			print("audio tween done")
	else:
		$BGM.volume_db = linear_to_db(vol)
		tween.tween_property($BGM, "volume_db", linear_to_db(0.001), duration)
		if tween.finished:
			emit_signal("audioFadeFinished")
			print("audio tween done")
	print("Fade info:")
	print(fadeIn)
	print(duration)
	print(vol)

func _on_bgm_finished():
	if loopBGM:
		bgm.play()

func switchScene(scene:String):
	$AnimationPlayer.play("transition")
	await $AnimationPlayer.animation_finished
	get_tree().change_scene_to_file(scene)
	$AnimationPlayer.play_backwards("transition")

func saveData(what,fileName:String,storeAs:int):
	var saveDir = DirAccess.open("user://saveData/")
	var writeTo = FileAccess.open("user://saveData/"+fileName+".json",FileAccess.WRITE)
	if storeAs == 0:
		writeTo.store_var(what)
	if storeAs == 1:
		writeTo.store_string(what)
	#print(what)
	#print(fileName)
	#print("user://saveData/"+fileName+".json")

func loadDataFrom(where:String):
	var file
	if FileAccess.file_exists(where):
		file = FileAccess.open(where,FileAccess.READ)
		#print(file.get_as_text())
		return file.get_as_text()
	else:
		print(where+" doesn't exist!")

# thx https://forum.godotengine.org/t/how-to-round-to-a-specific-decimal-place/27552/3
func round_to_dec(num, digit):
	return round(num * pow(10.0, digit)) / pow(10.0, digit)
