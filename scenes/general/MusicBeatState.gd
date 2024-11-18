class_name MusicBeatState

extends Node2D

signal beat
signal step

var lastBeat:float = 0
var lastStep:float = 0

var curStep:int = 0
var curBeat:int = 0

func _physics_process(delta: float):
	var oldStep:int = curStep
	
	updateCurStep()
	updateBeat()
	
	if oldStep != curStep && curStep > 0:
		stepHit()

func updateBeat():
	curBeat = floor(curStep/4)

func updateCurStep():
	curStep = floor(Conductor.songPosition / Conductor.stepCrochet)

func stepHit():
	if curStep % 4 == 0:
		beatHit()
	emit_signal("step")

func beatHit():
	emit_signal("beat")

func reset():
	Conductor.bpm = 100
	Conductor.crochet = (60/Conductor.bpm) * 1000
	Conductor.stepCrochet = Conductor.crochet / 4
	Conductor.songPosition = 0
	Conductor.lastSongPos = 0
	curBeat = 0
	curStep = 0
	lastBeat = 0
	lastStep = 0
