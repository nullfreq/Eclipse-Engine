class_name ChartNote
extends AnimatedSprite2D

@export var direction = 0
var displayDirection = 0
var area2d:Area2D = Area2D.new()
var collisionShape = CollisionShape2D.new()
var dumbLabel = Label.new()
var indWentPast = false
var noteData = []
var susViz = Line2D.new()

func _ready():
	susViz.add_point(Vector2(20,0),0)
	susViz.add_point(Vector2(20,0),1)
	susViz.z_index = 4096
	susViz.antialiased = true
	susViz.z_index = z_index-1
	add_child(susViz)
	sprite_frames = load("res://assets/misc/ChartNote.tres")
	add_child(area2d)
	var rect = RectangleShape2D.new()
	rect.extents = Vector2(10, 10)
	collisionShape.shape = rect
	collisionShape.position.x += 30
	collisionShape.position.y += 30
	area2d.add_child(collisionShape)
	add_child(dumbLabel)

func _process(delta: float):
	if noteData.size() > 0:
		dumbLabel.text = str(noteData[1])
	if direction == 0:
		play("left")
		susViz.default_color = Color.DARK_MAGENTA
	elif direction == 1:
		play("down")
		susViz.default_color = Color.ROYAL_BLUE
	elif direction == 2:
		play("up")
		susViz.default_color = Color.DARK_OLIVE_GREEN
	else:
		play("right")
		susViz.default_color = Color.DARK_RED
	if noteData.size() >= 3:
		#susViz.points[1].y = 20+noteData[2]
		if noteData[2] > 0:
			susViz.points[1].y = 40+floor(remap(noteData[2],0,Conductor.stepCrochet*16,0,640))
		else:
			susViz.points[1].y = 0
