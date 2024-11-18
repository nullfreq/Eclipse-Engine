extends Node

class BPMChangeEvent:
	var stepTime:int
	var songTime:float
	var bpm:float

var bpm:float = 100
var crochet:float = (60/bpm) * 1000
var stepCrochet:float = crochet / 4
var songPosition:float
var lastSongPos:float
var offset:float = 0

var safeFrames:int = 10
var safeZoneOffset:float = (safeFrames/60) * 1000

var bpmChangeMap:Array = []

func _process(delta: float):
	crochet = (60/bpm) * 1000
	stepCrochet = crochet / 4

func mapBPMChanges(song:Song.SwagSong):
	bpmChangeMap = []
	
	var curBPM:float = song.bpm
	var totalSteps:int = 0
	var totalPos:float = 0
	for i in song.notes.size():
		if song.notes[i].changeBPM && song.notes[i].bpm != curBPM:
			curBPM = song.notes[i].bpm
			var event = {
				"stepTIme": totalSteps,
				"songTime": totalPos,
				"bpm": curBPM
			}
			bpmChangeMap.append(event)
		var deltaSteps:int = song.notes[i].lengthInSteps
		totalSteps += deltaSteps
		totalPos += ((60/curBPM)) * 1000/4 * deltaSteps
	print("new BPM map BUDDY "+str(bpmChangeMap))

func changeBPM(newBPM:int):
	bpm = newBPM
	crochet = ((60/bpm) * 1000)
	stepCrochet = crochet / 4
