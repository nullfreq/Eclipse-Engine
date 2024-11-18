extends AnimatedSprite2D

@export var direction = 0
@export var noteSkin = "default"
@export var playerNote = 0
var initOffset = 90
var unpressed = ""
var pressed = ""
var confirm = ""
var area2d:Area2D = Area2D.new()
var collisionShape = CollisionShape2D.new()

func _ready():
	add_child(area2d)
	match direction:
		0:
			area2d.name = "leftStrumNote"
		1:
			area2d.name = "downStrumNote"
		2:
			area2d.name = "upStrumNote"
		3:
			area2d.name = "rightStrumNote"
	var rect = RectangleShape2D.new()
	rect.extents = Vector2(56*Global.dumbBitch.x, 56*2*Global.dumbBitch.x)
	collisionShape.shape = rect
	collisionShape.position.x += 80*Global.dumbBitch.x
	collisionShape.position.y += 80*Global.dumbBitch.x
	area2d.add_child(collisionShape)
	scale = Vector2(0.7*Global.dumbBitch.x,0.7*Global.dumbBitch.x)
	sprite_frames = load("res://assets/images/notes/"+noteSkin+".xml")
	var animShit = FileAccess.open("res://assets/images/notes/"+noteSkin+".txt",FileAccess.READ).get_as_text()
	match direction:
		0:
			unpressed = animShit.get_slice("\n",0)
			pressed = animShit.get_slice("\n",1)
			confirm = animShit.get_slice("\n",2)
			position.x += initOffset
			position.x += (160 * 0.7*Global.dumbBitch.x) * 0
			position.x += Global.rootSize.x/2 * playerNote
		1:
			unpressed = animShit.get_slice("\n",3)
			pressed = animShit.get_slice("\n",4)
			confirm = animShit.get_slice("\n",5)
			position.x += initOffset
			position.x += (160 * 0.7*Global.dumbBitch.x) * 1
			position.x += Global.rootSize.x/2 * playerNote
		2:
			unpressed = animShit.get_slice("\n",6)
			pressed = animShit.get_slice("\n",7)
			confirm = animShit.get_slice("\n",8)
			position.x += initOffset
			position.x += (160 * 0.7*Global.dumbBitch.x) * 2
			position.x += Global.rootSize.x/2 * playerNote
		3:
			unpressed = animShit.get_slice("\n",9)
			pressed = animShit.get_slice("\n",10)
			confirm = animShit.get_slice("\n",11)
			position.x += initOffset
			position.x += (160 * 0.7*Global.dumbBitch.x) * 3
			position.x += Global.rootSize.x/2 * playerNote
	play(unpressed)

func _process(delta: float):
	if animation == confirm:
		offset = Vector2(-40*Global.dumbBitch.x,-44*Global.dumbBitch.x)
	else:
		offset = Vector2(0,0)
