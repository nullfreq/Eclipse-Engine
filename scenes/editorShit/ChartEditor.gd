extends MusicBeatState

@onready var previewNote = $"General HUD/PreviewNote"
@onready var landRect = $"General HUD/Notes/LandRect"
var notePosOffset = 120
var time = 0
var posDiv = 0
var curSection = 0
var maxSection = 0
var playing = false
var length = 0
var camOnBF = null
var sectionNotes = []
var sectionEvents = []
var curSelectedNote:ChartNote = null
var initialized = false
var events = ["Play Animation", "Change BPM", "Change Character", "Subtitles", "Change Health"]
var hitSoundsOn = false
var metronomeOn = false
var curEvent = 0
var path = ""
var sectionData = {"lengthInSteps": 16, "mustHitSection": false, "sectionNotes": [], "sectionEvents": []}

func _ready():
	connect("beat",onBeatHit,0)
	connect("step",onStepHit,0)
	if Song.song == null || Song.song == "":
		Song.song = "bopeebo"
		Song.difficulty = "hard"
	initializeSong(Song.song,Song.difficulty)
	#DisplayServer.mouse_set_mode(DisplayServer.MOUSE_MODE_HIDDEN)
	Global.bgm.stream = preload("res://assets/music/chartEditorLoop.ogg")
	Global.fadeBGMusic(true,0.47,0.7)
	Global.loopBGM = true
	Global.bgm.play()
	#previewNote.hide()
	previewNote.collisionShape.shape.extents = Vector2(15,15)
	previewNote.collisionShape.position.x -= 10
	previewNote.collisionShape.position.y -= 10
	for i in events:
		$"General HUD/Panel/TabContainer/Events/EventList".add_item(i,load("res://assets/images/editors/chart/events/"+i+".png"),true)
	var stageList = []
	var stageDir = DirAccess.open("res://scenes/gameplay/stages/")
	for stage in stageDir.get_files():
		$"General HUD/Panel/TabContainer/Song Info/Stage/stageSelector".add_item(stage.trim_suffix(".tscn"))

func onBeatHit(beat:= curBeat):
	if playing:
		$"General HUD/Panel/TabContainer/Song Info/Whimsy/Tacoman".play("Shell")
	if metronomeOn && playing:
		if beat % 4 == 0:
			$Metronome1.play()
		else:
			$Metronome2.play()
func onStepHit(step:= curStep):
	#	broken ass hitsound shit
	for i in sectionNotes:
		if is_instance_valid(i):
			if hitSoundsOn && playing:
				if $"General HUD/Notes/SongPosIndic8r".position.y > i.noteData[0]/Conductor.stepCrochet*40 && !i.indWentPast:
					#print(i.noteData[0])
					#print(i.position.y)
					if is_instance_valid(i):
						i.indWentPast = true
						if camOnBF && i.displayDirection > 3:
							$HitNoteOpp.play()
						if camOnBF && i.displayDirection < 4:
							$HitNotePlayer.play()
						if !camOnBF && i.displayDirection > 3:
							$HitNotePlayer.play()
						if !camOnBF && i.displayDirection < 4:
							$HitNoteOpp.play()

func initializeSong(song,difficulty):
	$"General HUD/Notes/SongPosIndic8r".position.y = 0
	$"General HUD/Notes/FakeIndicator".position.y = 0
	curSection = 0
	initialized = false
	reset()
	Song.loadFromJson(song,difficulty)
	print("Initialized song with bpm of: "+str(Conductor.bpm))
	$"General HUD/Panel/TabContainer/Song Info/BPM/bpmChanger".set_value_no_signal(Conductor.bpm)
	$"General HUD/Panel/TabContainer/Song Info/Speed/speedChanger".set_value_no_signal(Song.songData.song.speed)
	$Inst.stream = load("assets/songs/"+song.to_lower()+"/audio/Inst.ogg")
	$Voices.stream = load("assets/songs/"+song.to_lower()+"/audio/Voices.ogg")
	#maxSection = Song.songData.notes.size()-1
	length = $Inst.stream.get_length()*1000
	#length = sectionStartTime()*maxSection
	print("max section test: "+str(getSectionCount()))
	maxSection = getSectionCount()
	initialized = true
	generateSection(curSection)
	$"General HUD/Panel/TabContainer/Song Info/Whimsy/Tacoman".speed_scale = Conductor.bpm/100
	Global.playlist = [Song.song.to_lower()]
	Global.curDiff = difficulty
	for i in getSectionCount():
		if !Song.songData.notes.has(i):
			Song.songData.notes.append(sectionData)
	if $Voices.stream != null:
		$"General HUD/Notes/WaveformViz".start(4)
	else:
		$"General HUD/Notes/WaveformViz".start(3)

func getSectionCount():
	return round(length/sectionStartTime())

func _process(delta: float):
	if Input.is_action_just_pressed("ui_accept"):
		Global.switchScene("res://scenes/gameplay/PlayScene.tscn")
	if initialized:
		if Song.songData.notes[curSection].mustHitSection:
			camOnBF = true
		else:
			camOnBF = false
#	Vocal resync! woohoo!
	if $Voices.get_playback_position() < $Inst.get_playback_position():
		$Voices.seek($Inst.get_playback_position())
	
	if !camOnBF:
		$"General HUD/Notes/OppIcon".position.x = 200
		$"General HUD/Notes/PlayerIcon".position.x = 360
	if camOnBF:
		$"General HUD/Notes/OppIcon".position.x = 360
		$"General HUD/Notes/PlayerIcon".position.x = 200
	$"General HUD/Notes/FakeIndicator".position.y = $"General HUD/Notes/SongPosIndic8r".position.y-640*curSection
	$"General HUD/ChartShit/Section".text = "Section: "+str(curSection)+" / "+str(maxSection)
	$"General HUD/ChartShit/SongPos".text = "Song Position: "+str(round(Conductor.songPosition))+" / "+str(round(length))+" | Beat: "+str(curBeat)+" | Step: "+str(curStep)+" | BPM: "+str(Conductor.bpm)
	$"General HUD/Panel/TabContainer/Current Section JSON/View".text = str(Song.songData.notes[curSection])
	if Input.is_action_just_pressed("space"):
		playing = not playing
		if playing:
			Global.fadeBGMusic(false,0.1175,0.7)
			$Inst.play(Conductor.songPosition/1000)
			$Voices.play(Conductor.songPosition/1000)
		if !playing:
			Global.fadeBGMusic(true,0.94,0.7)
			$Inst.stop()
			$Voices.stop()
	if playing && Conductor.songPosition < length:
		#Conductor.songPosition += ((delta * 1000)*Conductor.bpm/100)
		Conductor.songPosition = $Inst.get_playback_position()*1000
		$"General HUD/Notes/SongPosIndic8r".position.y = Conductor.songPosition/Conductor.stepCrochet*40
	elif playing && Conductor.songPosition > length:
		playing = false
		#$"General HUD/Notes/SongPosIndic8r".position.y = 0
	#Global.watermark.text = str((delta * 1000)*Conductor.bpm/100)
	if Input.is_action_just_pressed("editorZoomOut"):
		if curSection > 0:
			curSection -= 1
		generateSection(curSection)
		Conductor.songPosition = 0 + sectionStartTime() * curSection
		$Inst.seek(Conductor.songPosition/1000)
		$Voices.seek(Conductor.songPosition/1000)
	if Input.is_action_just_pressed("editorZoomIn"):
		Conductor.songPosition = curSection
		if curSection < maxSection:
			curSection += 1
			generateSection(curSection)
		Conductor.songPosition = 0 + sectionStartTime() * curSection
		$Inst.seek(Conductor.songPosition/1000)
		$Voices.seek(Conductor.songPosition/1000)
		if Conductor.songPosition > length:
			curSection = 0
			Conductor.songPosition = 0
	if $"General HUD/Notes/SongPosIndic8r".position.y >= 640+(640*curSection):
		#print(Conductor.songPosition)
		if curSection < maxSection:
			curSection += 1
			generateSection(curSection)
	time += delta
	previewNote.position.x = get_local_mouse_position().x
	previewNote.position.y = get_local_mouse_position().y
	if Input.is_action_just_pressed("leftClick"):
		#print(getStrumTime($"General HUD/Notes/LandRect".position.y)+(curSection*sectionStartTime()))
		if !previewNote.area2d.has_overlapping_areas() && !$"General HUD/Panel/TabContainer/Song Info/LoadJSON".visible:
			var babyNote = ChartNote.new()
			babyNote.position.x = (floor($"General HUD/PreviewNote".position.x/40)*40)
			babyNote.position.y = (floor(($"General HUD/PreviewNote".position.y/40))*40)-(40*posDiv)
			$"General HUD/Notes".add_child(babyNote)
			babyNote.direction = floor($"General HUD/PreviewNote".position.x/40)-3
			babyNote.displayDirection = floor($"General HUD/PreviewNote".position.x/40)-3
			if babyNote.direction > 3:
				babyNote.direction -= 4
			#print(babyNote.direction)
			babyNote.centered = false
			if babyNote.displayDirection > 7 || babyNote.displayDirection < 0:
				babyNote.queue_free()
			if babyNote.position.y < 40 || babyNote.position.y > 640:
				babyNote.queue_free()
			if landRect.visible && landRect.position.x > 80:
				Global.playSound("noteLay")
				babyNote.noteData = [getStrumTime($"General HUD/Notes/LandRect".position.y)+(curSection*sectionStartTime()),babyNote.displayDirection,0]
				Song.songData.notes[curSection].sectionNotes.append(babyNote.noteData)
				curSelectedNote = babyNote
			if landRect.visible && landRect.position.x > 40 && landRect.position.x <= 80:
				Global.playSound("noteLay")
				var event = EventHolder.new()
				var eventData = [getStrumTime($"General HUD/Notes/LandRect".position.y)+(curSection*sectionStartTime()),$"General HUD/Panel/TabContainer/Events/EventList".get_item_text(curEvent)]
				event.eventData = eventData
				event.position.x = (floor($"General HUD/PreviewNote".position.x/40)*40)
				event.position.y = (floor(($"General HUD/PreviewNote".position.y/40))*40)-(40*posDiv)
				event.texture = $"General HUD/Panel/TabContainer/Events/EventList".get_item_icon(curEvent)
				event.tooltip_text = str(eventData)
				$"General HUD/Notes".add_child(event)
				if event.position.y < 40 || event.position.y > 640:
					event.queue_free()
				Song.songData.notes[curSection].get_or_add("sectionEvents",[])
				Song.songData.notes[curSection].sectionEvents.append(eventData)
				sectionEvents.append(event)

	if (landRect.position.y < 40 || landRect.position.y > 640) || (landRect.position.x < 80 || landRect.position.x > 400):
		landRect.hide()
	else:
		landRect.show()
	if Input.is_action_pressed("rightClick"):
		for i in previewNote.area2d.get_overlapping_areas():
			if is_instance_of(i.get_parent(),ChartNote):
				if landRect.visible && !$"General HUD/Panel/TabContainer/Song Info/LoadJSON".visible:
					Global.playSound("noteErase")
					for j in Song.songData.notes[curSection].sectionNotes:
						if j == i.get_parent().noteData:
							#print("a "+str(j[0]))
							#print("b "+str(i.get_parent().noteData[0]))
							Song.songData.notes[curSection].sectionNotes.erase(j)
					i.get_parent().queue_free()
			if is_instance_of(i.get_parent(),EventHolder):
				if landRect.visible && !$"General HUD/Panel/TabContainer/Song Info/LoadJSON".visible:
					Global.playSound("noteErase")
					Song.songData.notes[curSection].get_or_add("sectionEvents",[])
					for j in Song.songData.notes[curSection].sectionEvents:
						if j == i.get_parent().eventData:
							Song.songData.notes[curSection].sectionEvents.erase(j)
						i.get_parent().queue_free()
			
	
	landRect.position.x = (floor($"General HUD/PreviewNote".position.x/40)*40)
	landRect.position.y = (floor(($"General HUD/PreviewNote".position.y/40))*40)+posDiv
	#landRect.modulate.a += time
	#previewNote.rotation += 0.05
	
	if Input.is_action_just_pressed("e"):
		changeNoteSustain(Conductor.stepCrochet/2)
		#print(curSelectedNote.susViz.points[1].y)
	if Input.is_action_just_pressed("q"):
		changeNoteSustain(Conductor.stepCrochet/2*-1)
		#print(curSelectedNote.susViz.points[1].y)

func generateSection(sec:int):
	for i in $"General HUD/Notes".get_children():
		if is_instance_of(i,ChartNote):
			i.queue_free()
		if is_instance_of(i,EventHolder):
			i.queue_free()
	sectionNotes.clear()
	sectionEvents.clear()
	
	var chartData = Song.songData.notes
	$"General HUD/Panel/TabContainer/Section/CFB/CFBtoggle".button_pressed = chartData[curSection].mustHitSection
	Song.bpm = Song.songData.bpm
	Conductor.bpm = Song.bpm
	for note in chartData[sec].sectionNotes:
		var babyNote = ChartNote.new()
		babyNote.noteData = note
		babyNote.position.x = 120+((note[1])*40)
		babyNote.position.y = getYfromStrum(note[0])-(640*curSection)
		$"General HUD/Notes".add_child(babyNote)
		babyNote.direction = note[1]
		babyNote.displayDirection = note[1]
		if babyNote.direction > 3:
			babyNote.direction -= 4
		babyNote.centered = false
		sectionNotes.append(babyNote)
	Song.songData.notes[sec].get_or_add("sectionEvents",[])
	for e in chartData[sec].sectionEvents:
		var event = EventHolder.new()
		#var eventData = [getStrumTime($"General HUD/Notes/LandRect".position.y)+(curSection*sectionStartTime()),$"General HUD/Panel/TabContainer/Events/EventList".get_item_text(curEvent)]
		event.eventData = e
		var evIndex = events.find(event.eventData[1],0)
		event.position.x = 80
		event.position.y = getYfromStrum(event.eventData[0])-(640*curSection)
		event.texture = $"General HUD/Panel/TabContainer/Events/EventList".get_item_icon(evIndex)
		event.tooltip_text = str(event.eventData)
		$"General HUD/Notes".add_child(event)
		sectionEvents.append(e)

func sectionStartTime():
	var daPos:float = 0.0
	daPos += 4 * (1000*60/Conductor.bpm)
	return daPos

func getYfromStrum(strumTime:float):
	return remap(strumTime,0,16*Conductor.stepCrochet,40,680)

func getStrumTime(yPos:float):
	return remap(yPos,40,680,0,16*Conductor.stepCrochet)

func changeNoteSustain(value:float):
	if curSelectedNote != null:
		if curSelectedNote.noteData[2] != null:
			curSelectedNote.noteData[2] += value
			curSelectedNote.noteData[2] = max(curSelectedNote.noteData[2],0)

func _on_hitsounds_check_toggled(toggled_on: bool):
	hitSoundsOn = toggled_on

func _on_metronome_check_toggled(toggled_on: bool):
	metronomeOn = toggled_on

func _on_event_list_item_selected(index: int):
	curEvent = index

func _on_load_pressed():
	$"General HUD/Panel/TabContainer/Song Info/LoadJSON".show()

func _on_save_pressed():
	$"General HUD/Panel/TabContainer/Song Info/SaveJSON".show()

func _on_load_json_file_selected(path: String):
	initializeSong(path.get_slice("/",4),str($"General HUD/Panel/TabContainer/Song Info/LoadJSON".current_file).trim_suffix(".json"))

func _on_save_json_file_selected(path: String):
	var saveData = Song.songData
	var file2save2 = FileAccess.open(path,FileAccess.WRITE)
	if FileAccess.file_exists(path):
		file2save2.store_string(JSON.stringify(saveData,"\t"))
		print("file saved @ "+str(path)+", "+str(file2save2.get_error()))

func _on_new_pressed():
	$"General HUD/Panel/TabContainer/Song Info/NewChart".show()

func _on_new_chart_file_selected(path: String):
	self.path = path
	$"General HUD/Panel/TabContainer/Song Info/ChartInfo".show()
	
func _on_bpm_changer_value_changed(value: float):
	Song.songData.bpm = value
	Conductor.bpm = value

func _on_speed_changer_value_changed(value: float):
	Song.songData.song.speed = value

func _on_okay_pressed():
	print(path)
	$"General HUD/Notes/SongPosIndic8r".position.y = 0
	$"General HUD/Notes/FakeIndicator".position.y = 0
	curSection = 0
	initialized = false
	reset()
	$Inst.stream = load(path.get_base_dir().get_base_dir()+"/audio/Inst.ogg")
	$Voices.stream = load(path.get_base_dir().get_base_dir()+"/audio/Voices.ogg")
	var g = path.get_base_dir().get_base_dir().get_file()
	print("My new song. "+g+". Chart it. NOW...")
	length = $Inst.stream.get_length()*1000
	Song.songData = {}
	Song.songData.notes = []
	Song.songData.song = {"song": g, "speed": $"General HUD/Panel/TabContainer/Song Info/ChartInfo/BoxContainer/Speed/speedChanger".value}
	Song.songData.bpm = $"General HUD/Panel/TabContainer/Song Info/ChartInfo/BoxContainer/BPM/bpmChanger".value
	for i in getSectionCount():
		Song.songData.notes.append(sectionData)
		#Song.songData.notes = sectionData.duplicate(true)
	print(Song.songData)
	var saveData = Song.songData
	var file2save2 = FileAccess.open(path,FileAccess.WRITE)
	if FileAccess.file_exists(path):
		file2save2.store_string(JSON.stringify(saveData,"\t"))
		print("file saved @ "+str(path)+", "+str(file2save2.get_error()))
		print("CONTENT = "+str(saveData))
	#Song.songData
	#print(path.get_base_dir().get_base_dir()+"/audio/Inst.ogg")
	#maxSection = Song.songData.notes.size()-1
	print("max section test: "+str(getSectionCount()))
	maxSection = getSectionCount()
	$"General HUD/Panel/TabContainer/Song Info/Whimsy/Tacoman".speed_scale = Conductor.bpm/100
	Song.song = g
	Global.curDiff = path.get_file().trim_suffix(".json")
	Global.playlist = [Song.song.to_lower()]
	initialized = true
	print("Initialized song with bpm of: "+str(Conductor.bpm))
	$"General HUD/Panel/TabContainer/Song Info/BPM/bpmChanger".set_value_no_signal(Song.songData.bpm)
	$"General HUD/Panel/TabContainer/Song Info/Speed/speedChanger".set_value_no_signal(Song.songData.song.speed)
	generateSection(curSection)
	$"General HUD/Panel/TabContainer/Song Info/ChartInfo".hide()
	if $Voices.stream.get_length() != 0:
		$"General HUD/Notes/WaveformViz".start(4)
	else:
		$"General HUD/Notes/WaveformViz".start(3)

func _on_cf_btoggle_button_up():
	#print("before: "+str(Song.songData.notes[curSection].mustHitSection))
	var fuck = $"General HUD/Panel/TabContainer/Section/CFB/CFBtoggle".button_pressed
	Song.songData.notes[curSection].mustHitSection = fuck
	swapNotes()

func _on_playback_speed_slider_value_changed(value: float):
	$"General HUD/ChartShit/PlaybackSpeedLabel".text = "Playback Speed: "+str(Global.round_to_dec(value,2))
	$Inst.pitch_scale = value
	$Voices.pitch_scale = value

func swapNotes():
	for i in Song.songData.notes[curSection].sectionNotes:
		if i[1] > 3:
			i[1] = i[1]+4
		else:
			if i[1] < 4:
				i[1] = i[1]-4
		if i[1] < 0:
			i[1] = i[1]+8
		if i[1] > 7:
			i[1] = i[1]-8
	generateSection(curSection)

func _on_swap_notes_pressed():
	swapNotes()
