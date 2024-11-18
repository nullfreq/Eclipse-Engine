extends AnimatedSprite2D

var number:String = "0"

func _ready():
	pass

func _process(delta: float):
	play(str(number))
