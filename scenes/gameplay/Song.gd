extends Node

class SwagSong:
	var song:String
	#var notes:Array[SwagSection]
	var bpm:float
	var needsVoices:bool
	var speed:float
	
	var player1:String
	var player2:String
	var validScore:bool

var song:String
var notes:Array[Section.SwagSection]
var bpm:float
var needsVoices:bool
var speed:float
var difficulty:String

var player1:String = "bf"
var player2:String = "dad"
var validScore:bool

var songData = {}

func loadFromJson(song:String, difficulty:String):
	if difficulty == "": difficulty = "hard"
	print("Song being loaded from JSON: "+"assets/songs/"+song.to_lower()+"/charts/"+difficulty.to_lower()+".json")
	songData = JSON.parse_string(FileAccess.get_file_as_string("assets/songs/"+song.to_lower()+"/charts/"+difficulty.to_lower()+".json"))
	self.song = song
	self.difficulty = difficulty
	self.bpm = songData.bpm
	Conductor.bpm = Song.bpm
