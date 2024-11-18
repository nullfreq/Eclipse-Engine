class_name Note
extends AnimatedSprite2D

var direction = 0
var time = 0.0
var length = 0.0
var noteSkin = "default"
var playerNote = 0
var initOffset = 90
var made = false
var canBeHit = true
var area2d:Area2D = Area2D.new()
var collisionShape = CollisionShape2D.new()
# Used for player notes.
@onready var end: AnimatedSprite2D = $End
@onready var hold: AnimatedSprite2D = $Hold
@onready var susVizCheck: VisibleOnScreenNotifier2D = $End/SusChecker

func _ready():
	pass

func makeNote(direction:int = 0, time:float = 0.0, length:float = 0.0, noteSkin:String = "default",playerNote:int = 0):
	add_child(area2d)
	match direction:
		0:
			area2d.name = "leftNote"
		1:
			area2d.name = "downNote"
		2:
			area2d.name = "upNote"
		3:
			area2d.name = "rightNote"
	var rect = RectangleShape2D.new()
	rect.extents = Vector2(56*Global.dumbBitch.x, (56*1.8)*Global.dumbBitch.y)
	collisionShape.shape = rect
	collisionShape.position.x += 80*Global.dumbBitch.x
	collisionShape.position.y += 80*Global.dumbBitch.x
	area2d.add_child(collisionShape)
	scale = Vector2(0.7*Global.dumbBitch.x,0.7*Global.dumbBitch.x)
	sprite_frames = load("res://assets/images/notes/"+noteSkin+".xml")
	for i in [$".",$Hold,$End]:
		i.sprite_frames = load("res://assets/images/notes/"+noteSkin+".xml")
	match direction:
		0:
			play("purple")
			$Hold.play("purple hold piece")
			$End.play("pruple end hold")
			position.x += initOffset
			position.x += (160 * (0.7*Global.dumbBitch.x)) * 0
			position.x += Global.rootSize.x/2 * playerNote
		1:
			play("blue")
			$Hold.play("blue hold piece")
			$End.play("blue hold end")
			position.x += initOffset
			position.x += (160 * (0.7*Global.dumbBitch.x)) * 1
			position.x += Global.rootSize.x/2 * playerNote
		2:
			play("green")
			$Hold.play("green hold piece")
			$End.play("green hold end")
			position.x += initOffset
			position.x += (160 * (0.7*Global.dumbBitch.x)) * 2
			position.x += Global.rootSize.x/2 * playerNote
		3:
			play("red")
			$Hold.play("red hold piece")
			$End.play("red hold end")
			position.x += initOffset
			position.x += (160 * (0.7*Global.dumbBitch.x)) * 3
			position.x += Global.rootSize.x/2 * playerNote
	self.direction = direction
	self.time = time
	self.length = length
	self.playerNote = playerNote

	for i in [$End, $Hold]:
		i.offset.x = ($".".sprite_frames.get_frame_texture($".".animation,$".".frame).get_width()*0.35)-4
		#i.modulate.a = 0.6
	$Hold.position.y += $Hold.sprite_frames.get_frame_texture($Hold.animation,$Hold.frame).get_height()+22
	#print($Hold.sprite_frames.get_frame_texture($Hold.animation,$Hold.frame).get_height())
	#print($End.offset.y)
	if length == 0:
		$Hold.hide()
		$End.hide()
	else:
		$Hold.scale.y = absi(length/100) * 1.5 * Song.speed*1.5 * Global.dumbBitch.x
	position.y += time
	made = true

func _process(delta: float):
	if made:
		$End.offset.y = $Hold.sprite_frames.get_frame_texture($Hold.animation,$Hold.frame).get_height()*$Hold.scale.y+44
		susVizCheck.position.y = $End.offset.y*Global.dumbBitch.x
