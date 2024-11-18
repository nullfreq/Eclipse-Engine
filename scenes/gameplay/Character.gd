@tool
class_name Character
extends AnimatedSprite2D

@export var isPlayer = false
@onready var animShit = []
var loaded = false
@export var character = "bf"
var charData = {}

func _ready():
	loadChar(character)

func loadChar(character:String):
	animShit.clear()
	var charJson = "res://assets/data/characters/"+character+".json"
	charData = JSON.parse_string(FileAccess.get_file_as_string(charJson))
	for a in charData.animations:
		animShit.append(charData.animations[a])
	sprite_frames = load("res://assets/images/characters/"+charData.spritesheet+".xml")
	centered = false
	loaded = true
	self.character = character
	playAnim("idle")

func playAnim(anim:String):
	#print(anim)
	if loaded:
		frame = 0
		for i in charData.animations.keys():
			if anim == i:
				var result = charData.animations.keys().find(i,0)
				#print(int(i))
				play(animShit[result]["source"])
				offset.x = animShit[result]["offsetX"]
				offset.y = animShit[result]["offsetY"]

func findAnim(anim:String):
	if loaded:
		for i in charData.animations.keys():
			if anim == i:
				var result = charData.animations.keys().find(i,0)
				return animShit[result]["source"]

func _process(delta: float):
#	worst pile of if statements ever
	if isPlayer && charData.isPlayer && charData.flipX:
		flip_h = true
	if isPlayer && charData.isPlayer && !charData.flipX:
		flip_h = false
	if !isPlayer && charData.isPlayer && !charData.flipX:
		flip_h = true
	if !isPlayer && charData.isPlayer && charData.flipX:
		flip_h = false
		
	if !isPlayer && !charData.isPlayer && charData.flipX:
		flip_h = true
	if !isPlayer && !charData.isPlayer && !charData.flipX:
		flip_h = false
	if isPlayer && !charData.isPlayer && !charData.flipX:
		flip_h = true
	if isPlayer && !charData.isPlayer && charData.flipX:
		flip_h = false

func getMidpoint():
	var midX = sprite_frames.get_frame_texture(findAnim("idle"),0).get_width()/2
	var midY = sprite_frames.get_frame_texture(findAnim("idle"),0).get_height()/2
	return Vector2(position.x/2+midX,position.y/2+midY)
