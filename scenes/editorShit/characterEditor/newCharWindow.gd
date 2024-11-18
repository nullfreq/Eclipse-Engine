extends Window

var jsonName = ""
var newCharData = {}
var flipX = false
var isPlayer = false

func _ready():
	pass # Replace with function body.

func _process(delta: float):
	pass

func _on_json_input_text_submitted(new_text: String):
	jsonName = new_text

func _on_ss_input_text_submitted(new_text: String):
	newCharData.spritesheet = new_text

func _on_x_check_toggled(toggled_on: bool):
	flipX = toggled_on
	newCharData.flipX = flipX

func _on_player_check_toggled(toggled_on: bool):
	isPlayer = toggled_on
	newCharData.isPlayer = isPlayer

func _on_create_char_pressed():
	if !$BoxContainer/SsInput.text == "" && !$BoxContainer/JsonInput.text == "":
		var file = FileAccess.open("res://assets/data/characters/"+jsonName+".json",FileAccess.WRITE_READ)
		file.store_string(JSON.stringify(newCharData,"\t"))
		print("Saved @ "+"res://assets/data/characters/"+jsonName+".json !")
		isPlayer = false
		flipX = false
		$BoxContainer/JsonInput.clear()
		$BoxContainer/SsInput.clear()
		$BoxContainer/FlipX/XCheck.button_pressed = flipX
		$BoxContainer/IsPlayer/PlayerCheck.button_pressed = isPlayer
		hide()

func _on_idle_input_text_submitted(new_text: String):
	var animationArray = {"animations": {
		"idle": {"source": new_text,
		"offsetX": 0,
		"offsetY": 0}
		}
	}
	newCharData.merge(animationArray,true)
