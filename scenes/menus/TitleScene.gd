extends MusicBeatState

var credits = ["nullfrequency"]
var introText = []
var skippedIntro = Global.skippedTitleIntro
var transitioned = false
var time = 0.0
var secretRevealed = false

func _ready():
	$Logo.position.x = $Logo.sprite_frames.get_frame_texture("logo bumpin",0).get_width()/2*-0.25
	$Logo.position.y = $Logo.sprite_frames.get_frame_texture("logo bumpin",0).get_height()/2*-0.25
	$GF.position.x = $GF.sprite_frames.get_frame_texture("gfDance",0).get_width()/2*2.5
	$GF.position.y = $GF.sprite_frames.get_frame_texture("gfDance",0).get_height()/2*1.15
	reset()
	print("Skipped title intro? "+str(Global.skippedTitleIntro))
	if !Global.bgm.playing:
		Global.bgm.stream = preload("res://assets/music/freakyMenu.ogg")
		Global.bgm.play()
		Global.loopBGM = true
		Global.fadeBGMusic(true,4.0,0.7)
	$PressEnter.play("Press Enter to Begin")
	$Intro.show()
	connect("beat",onBeatHit,0)
	connect("step",onStepHit,0)
	Conductor.bpm = 102
	getIntroTextShit()
	#introText[1] = "\n"+introText[1]
	if Global.skippedTitleIntro:
		skipIntro()

func _physics_process(delta: float):
	super._physics_process(delta)
	if Input.is_action_just_pressed("debugA") && !secretRevealed && skippedIntro:
		Global.bgm.stream = preload("res://assets/music/girlfriendsRingtone.ogg")
		#Global.fadeBGMusic(false,0.47,0.7)
		#await Global.audioFadeFinished
		Global.bgm.play()
		Global.fadeBGMusic(true,0.47,0.7)
		secretRevealed = true
	Conductor.songPosition += (delta * 1000)*Conductor.bpm/100
	time += delta
	if secretRevealed:
		$AwesomeRect.color = Color.from_hsv(time*0.047,1,1,1)
	#print($AwesomeRect.color)
	
	if !skippedIntro && Input.is_action_just_pressed("ui_accept"):
		skipIntro()
	
	if skippedIntro && Global.flashRect.modulate.a < .9 && !transitioned && Input.is_action_just_pressed("ui_accept"):
		$CONFIRM.play()
		$PressEnter.play("ENTER PRESSED")
		$PressEnter.offset = Vector2(8,6)
		transitioned = true
		await $CONFIRM.finished
		Global.switchScene("res://scenes/menus/MainMenu.tscn")

func onStepHit(step:= curStep):
	pass

func onBeatHit(beat:= curBeat):
	$Logo.frame = 0
	$Logo.play("logo bumpin")
	if beat % 2 == 0:
		$GF.play("gfDance",Conductor.bpm/100)
		$GF.frame = 0
	if !skippedIntro:
		match beat:
			1:
				$Intro/FunnyText.show()
				for i in credits:
					if credits.find(i,0) > 0:
						$Intro/FunnyText.text += "\n"+i
					else:
						$Intro/FunnyText.text += i
			3:
				$Intro/FunnyText.text += "\npresents..."
			4:
				$Intro/FunnyText.hide()
			5:
				$Intro/FunnyText.show()
				$Intro/FunnyText.text = "NOT in association\nwith"
			7:
				$Intro/FunnyText.text += "\nNewgrounds"
			8:
				$Intro/FunnyText.hide()
			9:
				$Intro/FunnyText.show()
				$Intro/FunnyText.text = introText[0]
			11:
				$Intro/FunnyText.text += "\n"+introText[1]
			12:
				$Intro/FunnyText.hide()
			13:
				$Intro/FunnyText.show()
				$Intro/FunnyText.text = "Friday Night Funkin'"
			14:
				$Intro/FunnyText.text += "\nEclipse"
			15:
				$Intro/FunnyText.text += "\nEngine"
			16:
				skipIntro()

func getIntroTextShit():
	var fullText = FileAccess.get_file_as_string("res://assets/data/introText.txt")
	var firstArray = fullText.split("\n")
	var swagGoodArray = []
	
	for i in firstArray:
		swagGoodArray.append(i.split("--"))
	introText = swagGoodArray[randi_range(0,swagGoodArray.size()-1)]

func skipIntro():
	$Intro.hide()
	Global.flash(Color.WHITE,4.0,false)
	skippedIntro = true
	Global.skippedTitleIntro = true
