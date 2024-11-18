class_name EventHolder
extends TextureRect

var eventData = []
var area2d:Area2D = Area2D.new()
var collisionShape = CollisionShape2D.new()

func _ready():
	add_child(area2d)
	var rect = RectangleShape2D.new()
	rect.extents = Vector2(10, 10)
	collisionShape.shape = rect
	collisionShape.position.x += 30
	collisionShape.position.y += 30
	area2d.add_child(collisionShape)
