class_name PlayScene extends MusicBeatState

@onready var playerStrums = []
@onready var comboGroup = [$HUD/ComboAnchor/ComboNumber,$HUD/ComboAnchor/ComboNumber2,$HUD/ComboAnchor/ComboNumber3]
@onready var camGame = $Camera2D 

var controlArray = ["left","down","up","right"]
var notes = []
var camChanges = []
var camOnBF = null
var curSection = -1
@onready var hud: CanvasLayer = $HUD
var generatedSong = false
var songLength = 0
var minutes = 0
var seconds = 0
var displayMinute = "0"
var displaySeconds = "0"
var health = 0.5
var score = 0
## good ranking in og
var adding2score = 200
var iconOffset = 26
var blueballed = false
@onready var gf:Character
@onready var dad:Character
@onready var bf:Character
var curStage:Node2D
@onready var iconGRP = [$HUD/ImportantShit/iconP1,$HUD/ImportantShit/iconP2]
var countdownStep = -1
var countdownFinished = false

## Strumline used for input!
## 0 = opponent and 1 = player;
## Could theoretically be expanded but I don't feel like doing allat rn
@export var curStrumline = 1
var noteInstance = preload("res://scenes/gameplay/Note.tscn")

var combo = 0
var comboArray = ["0"]

func _ready():
	connect("beat",onBeatHit)
	connect("step",onStepHit)
	if Global.playlist.size() == 0:
		Global.playlist.append("milf")
		Global.curDiff = "hard"
	Global.bgm.stop()
	reset()
	Song.loadFromJson(Global.playlist[0],Global.curDiff)
	changePlayer(curStrumline)
	generateSong()
	$HUD/OppNote.hide()
	$HUD/OppNote2.hide()
	$HUD/OppNote3.hide()
	$HUD/OppNote4.hide()
	$HUD/PlayerNote.hide()
	$HUD/PlayerNote2.hide()
	$HUD/PlayerNote3.hide()
	$HUD/PlayerNote4.hide()

func changePlayer(player:int):
	match player:
		0:
			playerStrums.append_array([$HUD/OppNote,$HUD/OppNote2,$HUD/OppNote3,$HUD/OppNote4])
		1:
			playerStrums.append_array([$HUD/PlayerNote,$HUD/PlayerNote2,$HUD/PlayerNote3,$HUD/PlayerNote4])

func _physics_process(delta: float):
	gf.speed_scale = Conductor.bpm/100
	dad.speed_scale = Conductor.bpm/100
	bf.speed_scale = Conductor.bpm/100
	$HUD/ImportantShit/iconP1.position.x = $HUD/ImportantShit/HealthBar.position.x + ($HUD/ImportantShit/HealthBar.size.x * remap($HUD/ImportantShit/HealthBar.value * 100, 0, 100, 100, 0) * 0.01 - iconOffset) + 50
	$HUD/ImportantShit/iconP2.position.x = $HUD/ImportantShit/HealthBar.position.x + ($HUD/ImportantShit/HealthBar.size.x * remap($HUD/ImportantShit/HealthBar.value * 100, 0, 100, 100, 0) * 0.01 - 100 - iconOffset) + 50
	if Input.is_action_just_pressed("debugA"):
		Global.switchScene("res://scenes/editorShit/ChartEditor.tscn")
#	#TIME BS PART 2
	if minutes > 9:
		displayMinute = str(minutes)
	else:
		displayMinute = "0"+str(minutes)
	if seconds > 9:
		displaySeconds = str(seconds)
	else:
		displaySeconds = "0"+str(seconds)
	$HUD/ImportantShit/ScoreTxt.text = ("%02d" % minutes) + (":%02d" % seconds)+" | Score: "+str(score)
	#$HUD/ImportantShit/ScoreTxt.text = "curStep "+str(curStep)+" | curBeat "+str(curBeat)+" | songPosition "+str(round(Conductor.songPosition))
	if seconds == 0 && minutes > 0:
		seconds = 59
		minutes -= 1
	
	#Resyncing... woas
	#if $Inst.get_playback_position() < Conductor.songPosition/1000:
		#$Inst.seek(Conductor.songPosition/1000)
	#if $Inst.get_playback_position() > Conductor.songPosition/1000+20:
		#$Inst.seek(Conductor.songPosition/1000)
	if Conductor.songPosition/1000 < $Inst.get_playback_position():
		Conductor.songPosition = $Inst.get_playback_position()*1000
	if $Voices.get_playback_position() < $Inst.get_playback_position():
		$Voices.seek($Inst.get_playback_position())
	
	$HUD/ImportantShit/HealthBar.value = health
	if generatedSong:
		super._physics_process(delta)
		Conductor.songPosition = $Inst.get_playback_position()*1000
		if camOnBF == true:
			camGame.position = Vector2(bf.getMidpoint().x + 100, bf.getMidpoint().y + 100)
		else:
			camGame.position = Vector2(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100)
	for i in controlArray:
		if Input.is_action_just_pressed(i):
			playerStrums[controlArray.find(i,0)].play(playerStrums[controlArray.find(i,0)].pressed)
		if Input.is_action_just_released(i):
			playerStrums[controlArray.find(i,0)].play(playerStrums[controlArray.find(i,0)].unpressed)
	
	if generatedSong && countdownFinished:
		updateCurStep()
		updateBeat()
		for daNote:Note in notes:
			if is_instance_valid(daNote):
				if daNote.position.y > 28 && !daNote.playerNote == curStrumline:
					daNote.position.y = (0.45 * (Conductor.songPosition - daNote.time)) * -Song.speed
				if daNote.playerNote == curStrumline:
					for i in controlArray:
						if daNote.length == 0 || !Input.is_action_just_pressed(i):
							daNote.position.y = (0.45 * (Conductor.songPosition - daNote.time)) * -Song.speed
				if daNote.position.y <= 28 && !daNote.playerNote == curStrumline:
					if daNote.length == 0:
						dad.playAnim("sing"+str(controlArray[daNote.direction]).to_upper())
						#await $Dad.animation_finished
						#$Dad.playAnim(0)
						notes.remove_at(notes.find(daNote,0))
						daNote.queue_free()
						await dad.animation_finished
						dad.playAnim("idle")
					elif daNote.length > 0 && daNote.end.position.y <= 28:
						daNote.self_modulate.a = 0
						if daNote.hold.scale.y > 1:
							daNote.hold.scale.y -= 0.45*Song.speed
							dad.playAnim("sing"+str(controlArray[daNote.direction]).to_upper())
						else:
							notes.remove_at(notes.find(daNote,0))
							daNote.queue_free()
							await dad.animation_finished
							dad.playAnim("idle")
				if is_instance_valid(daNote) && daNote.position.y < -24 && daNote.length == 0:
					notes.remove_at(notes.find(daNote,0))
					daNote.queue_free()
					var urgh = false
					if daNote.playerNote == curStrumline && urgh == false:
						urgh = true
						health -= 0.04
						combo = 0
						score -= 10
						comboArray.clear()
						for n in str(combo).split():
							comboArray.append(n)
						bf.playAnim("sing"+str(controlArray[daNote.direction]).to_upper()+"miss")
						$MissSFX.play()
						await bf.animation_finished
						bf.playAnim("idle")
				if is_instance_valid(daNote) && daNote.length > 0 && daNote.position.y < daNote.length*-1 && daNote.hold.scale.y > 1 && daNote.susVizCheck.is_on_screen() == false:
					notes.remove_at(notes.find(daNote,0))
					daNote.queue_free()
				if is_instance_valid(daNote) && daNote.length > 0 && daNote.susVizCheck.global_position.y < -24  && daNote.position.y < (daNote.length*-1):
					var urgh = false
					if daNote.playerNote == curStrumline && urgh == false:
						urgh = true
						health -= 0.023*floor((daNote.length/100)/4)
						combo = 0
						score -= 10*floor((daNote.length/100)/2)
						comboArray.clear()
						for n in str(combo).split():
							comboArray.append(n)
						bf.playAnim("sing"+str(controlArray[daNote.direction]).to_upper()+"miss")
						$MissSFX.play()
						await bf.animation_finished
						bf.playAnim("idle")
					
			for i in controlArray:
				if is_instance_valid(daNote) && daNote.playerNote == curStrumline:
					if daNote.length > 0 && daNote.position.y > 28:
						daNote.position.y = (0.45 * (Conductor.songPosition - daNote.time)) * -Song.speed
					for j in playerStrums:
						if is_instance_valid(daNote) && daNote.area2d.overlaps_area(j.area2d):
							if Input.is_action_just_pressed(i) && daNote.direction == controlArray.find(i,0) && is_instance_valid(daNote):
								playerStrums[controlArray.find(i,0)].play(playerStrums[controlArray.find(i,0)].confirm)
								if daNote.length == 0:
									bf.playAnim("sing"+str(controlArray[daNote.direction]).to_upper())
									notes.remove_at(notes.find(daNote,0))
									combo += 1
									health += 0.004
									score += adding2score
									comboArray.clear()
									daNote.queue_free()
									for n in str(combo).split():
										comboArray.append(n)
									if !Input.is_action_just_released(i):
										await bf.animation_finished
										bf.playAnim("idle")
									else:
										bf.playAnim("idle")
								if is_instance_valid(daNote) && daNote.length > 0 && daNote.end.position.y <= 28:
									daNote.self_modulate.a = 0
									playerStrums[controlArray.find(i,0)].play(playerStrums[controlArray.find(i,0)].confirm)
				if is_instance_valid(daNote) && Input.is_action_pressed(i) && daNote.direction == controlArray.find(i,0) && daNote.self_modulate.a == 0:
					if is_instance_valid(daNote):
						for j in playerStrums:
							if is_instance_valid(daNote) && daNote.area2d.overlaps_area(j.area2d):
								if daNote.length > 0 && daNote.end.position.y <= 28 && daNote.playerNote == curStrumline:
									daNote.position.y = 28
									if daNote.hold.scale.y > 1:
										daNote.hold.scale.y -= 0.45*Song.speed
										bf.playAnim("sing"+str(controlArray[daNote.direction]).to_upper())
									else:
										notes.remove_at(notes.find(daNote,0))
										combo += floor(daNote.length/100)
										health += 0.023
										score += adding2score*floor(daNote.length/100)
										comboArray.clear()
										daNote.queue_free()
										for n in str(combo).split():
											comboArray.append(n)
										await bf.animation_finished
										bf.playAnim("idle")
									if Input.is_action_just_released(i) && is_instance_valid(daNote):
										var urgh = false
										if daNote.playerNote == curStrumline && urgh == false:
											urgh = true
											print("should kill sustain")
											notes.remove_at(notes.find(daNote,0))
											combo = 0
											health -= 0.023/2
											score -= 10
											comboArray.clear()
											daNote.queue_free()
											for n in str(combo).split():
												comboArray.append(n)
											bf.playAnim("sing"+str(controlArray[daNote.direction]).to_upper()+"miss")
											$MissSFX.play()
											await bf.animation_finished
											bf.playAnim("idle")
	if comboArray.size() >= 1:
		comboGroup[0].number = comboArray[0]
		comboGroup[0].show()
	else:
		comboGroup[0].show()
		comboGroup[0].number = "0"
	
	if comboArray.size() >= 2:
		comboGroup[1].number = comboArray[1]
		comboGroup[1].show()
	else:
		comboGroup[1].hide()
	
	if comboArray.size() >= 3:
		comboGroup[2].number = comboArray[2]
		comboGroup[2].show()
	else:
		comboGroup[2].hide()

	if health <= 0.05 && !blueballed:
		blueball()
	
	if blueballed && Input.is_action_just_pressed("ui_accept"):
		Global.bgm.stream = preload("res://assets/music/gameOver/gameOverEnd.ogg")
		Global.bgm.volume_db = linear_to_db(0.7)
		Global.loopBGM = false
		Global.bgm.play()
		Global.flash(Color.BLACK,Global.bgm.stream.get_length()/2,true)
		await Global.bgm.finished
		get_tree().reload_current_scene()
		Global.flash(Color.BLACK,0.001,false)

func onStepHit(step:= curStep):
	if $SongScriptLoader.has_method("onStepHit"):
		$SongScriptLoader.call_deferred("onStepHit",curStep)
	$HUD/TimeBar.value = lerp($HUD/TimeBar.value,Conductor.songPosition/1000,0.16)

func onBeatHit(beat:= curBeat):
	if $SongScriptLoader.has_method("onBeatHit"):
		$SongScriptLoader.call_deferred("onBeatHit",curBeat)
	if beat % 2 == 0:
		$AnimationPlayer.play("hudBump",-1,Conductor.bpm/100,false)
		if gf.animation == gf.findAnim("idle"):
			gf.playAnim("idle")
	if beat % 4 == 0:
		if int(curStep/16) < camChanges.size():
			camOnBF = Song.songData.notes[int(curStep/16)].mustHitSection
			if Song.songData.notes[int(curStep/16)].get_or_add("changeBPM",false) == true:
				Conductor.changeBPM(Song.songData.notes[int(curStep/16)].bpm)
	if dad.animation == dad.findAnim("idle"):
		dad.playAnim("idle")
	if bf.animation == bf.findAnim("idle"):
		bf.playAnim("idle")
	$AnimationPlayer2.play("iconBump",-1,Conductor.bpm/100,false)
#	test code, dont mind!
	#if beat % 3 == 1:
		#changeCharacter("dad","dad")
	#if beat % 3 == 2:
		#changeCharacter("gf","dad")
	#if beat % 3 == 0:
		#changeCharacter("bf","dad")

func generateSong():
	#print("before: "+str(Conductor.bpm))
	var chartData = Song.songData.notes
	Song.bpm = Song.songData.bpm
	Song.speed = Song.songData.song.speed
	#print("after: "+str(Conductor.bpm))
	#print("BPM: "+str(Song.bpm))
	#print("Speed: "+str(Song.speed))
	$Inst.stream = load("res://assets/songs/"+Song.song.to_lower()+"/audio/Inst.ogg")
	$Voices.stream = load("res://assets/songs/"+Song.song.to_lower()+"/audio/Voices.ogg")
	#DisplayServer.window_set_title("Eclipse Engine ~ "+Song.songData.song.song+" ["+str(Song.difficulty).capitalize()+"]",0)
	switchStage("mainStage")
	for section in chartData:
		if section.mustHitSection:
			camChanges.append(true)
		else:
			camChanges.append(false)
		for note in section.sectionNotes:
			var babyNote = noteInstance.instantiate()
			var noteSkin = "default"
			var time = note[0]
			babyNote.position.y += 24
			var direction = note[1]
			var length = note[2]
			var playerNote = 0
			# DEFINITIVE NOTE PLACEMENT CODE!
			if section.mustHitSection:
				if direction < 4:
					playerNote = 1
				else:
					playerNote = 0
					direction -= 4
			if !section.mustHitSection:
				if direction < 4:
					playerNote = 0
				else:
					playerNote = 1
					direction -= 4

			babyNote.makeNote(direction,time,length,noteSkin,playerNote)
			$HUD.add_child(babyNote)
			notes.append(babyNote)
			babyNote.hide()
	generatedSong = true
	if FileAccess.file_exists("res://assets/songs/"+str(Song.songData.song.song).to_lower()+"/script.gd"):
		$SongScriptLoader.set_script(load("res://assets/songs/"+str(Song.songData.song.song).to_lower()+"/script.gd"))
		$SongScriptLoader._ready()
		$SongScriptLoader.set_process(true)
		$SongScriptLoader.set_physics_process(true)
		print(str(Song.songData.song.song)+" script found and loaded!")
	else:
		print(str(Song.songData.song.song)+" script not found!")
	$SongTime.start($Inst.stream.get_length())
	$SongTime.paused = true
	# "assuming t has the miliseconds measured value" - https://forum.godotengine.org/t/simple-timer/16362
	var t = $SongTime.time_left*1000
	$HUD/TimeBar.max_value = $SongTime.time_left
	minutes = int(t / 60 / 1000)
	seconds = int(t / 1000) % 60
	#var miliseconds = int(t) % 1000
	print("minutes: "+str(minutes))
	print("seconds: "+str(seconds))
	$HUD/TimeBar/SongName.text = Song.song.capitalize()
	updateIcons()
	$CountdownTimer.start(Conductor.crochet/1000)

func _on_song_time_timeout():
	reset()
	Global.playlist.erase(Global.playlist[0])
	if Global.playlist.size() > 0:
		#get_tree().change_scene_to_file("res://scenes/gameplay/PlayScene.tscn")
		get_tree().reload_current_scene()
	else:
		Global.switchScene("res://scenes/menus/MainMenu.tscn")

func _on_seconds_timeout():
	if generatedSong:
		seconds -= 1

func _on_health_bar_value_changed(value: float):
	if $HUD/ImportantShit/HealthBar.value * 100 < 20:
		$HUD/ImportantShit/iconP1.frame = 1
	else:
		$HUD/ImportantShit/iconP1.frame = 0
	
	if $HUD/ImportantShit/HealthBar.value * 100 > 80:
		$HUD/ImportantShit/iconP2.frame = 1
	else:
		$HUD/ImportantShit/iconP2.frame = 0

func blueball():
	blueballed = true
	$Inst.stream_paused = true
	$Voices.stream_paused = true
	$GameOver.show()
	Global.bgm.stream = preload("res://assets/music/gameOver/gameOver.ogg")
	Global.bgm.volume_db = linear_to_db(0.7)
	Global.loopBGM = true
	Global.bgm.play()

func updateIcons(iconP1:String = bf.character, iconP2:String = dad.character):
	$HUD/ImportantShit/iconP1.texture = load("res://assets/images/gameplay/icons/icon-"+iconP1+".png")
	$HUD/ImportantShit/iconP2.texture = load("res://assets/images/gameplay/icons/icon-"+iconP2+".png")

func _on_countdown_timer_timeout():
	countdownStep += 1
	print(Conductor.crochet/1000)
	match countdownStep:
		0:
			$CountdownSFX.stream = load("res://assets/sounds/gameplay/countdown/funkin/introTHREE.ogg")
			$CountdownSFX.play()
		1:
			$CountdownSFX.stream = load("res://assets/sounds/gameplay/countdown/funkin/introTWO.ogg")
			$CountdownSFX.play()
			$HUD/CountdownSprite.texture = load("res://assets/images/gameplay/countdown/funkin/ready.png")
		2:
			$CountdownSFX.stream = load("res://assets/sounds/gameplay/countdown/funkin/introONE.ogg")
			$CountdownSFX.play()
			$HUD/CountdownSprite.texture = load("res://assets/images/gameplay/countdown/funkin/set.png")
		3:
			$CountdownSFX.stream = load("res://assets/sounds/gameplay/countdown/funkin/introGO.ogg")
			$CountdownSFX.play()
			$HUD/CountdownSprite.texture = load("res://assets/images/gameplay/countdown/funkin/go.png")
		4:
			$Inst.play()
			$Voices.play()
			curSection = curSection+1
			camOnBF = camChanges[curSection]
			$Seconds.start(1)
			countdownFinished = true
			$SongTime.paused = false
			$HUD/OppNote.show()
			$HUD/OppNote2.show()
			$HUD/OppNote3.show()
			$HUD/OppNote4.show()
			$HUD/PlayerNote.show()
			$HUD/PlayerNote2.show()
			$HUD/PlayerNote3.show()
			$HUD/PlayerNote4.show()
			for i in notes:
				i.show()
	if !countdownFinished:
		$CountdownTimer.start(Conductor.crochet/1000)
		if countdownStep > 0:
			$AnimationPlayer3.speed_scale = Conductor.crochet/100
			$AnimationPlayer3.seek(0)
			$AnimationPlayer3.play("cdFade")

# events?
func switchStage(switchinTo:String, preloadStage:bool = false):
	if curStage != null:
		curStage.queue_free()
	var stageInstance
	if !preloadStage:
		stageInstance = load("res://scenes/gameplay/stages/"+switchinTo+".tscn")
	if preloadStage:
		match switchinTo:
			"mainStage":
				stageInstance = load("res://scenes/gameplay/stages/mainStage.tscn")
			"testStage":
				stageInstance = load("res://scenes/gameplay/stages/testStage.tscn")
	var stage = stageInstance.instantiate()
	curStage = stage
	add_child(curStage)
	gf = stage.get_node("GF")
	dad = stage.get_node("Dad")
	bf = stage.get_node("BF")
	updateIcons(bf.character,dad.character)

func changeCharacter(character:String,target:String):
	match target:
		"gf":
			gf.loadChar(character)
		"dad":
			dad.loadChar(character)
		"bf":
			bf.loadChar(character)
	updateIcons(bf.character,dad.character)
