@tool
class_name EditorGrid
extends Control

## How many squares are generated horizontally
@export var width = 4
## How many squares are generated vertically
@export var height = 16
## Size of squares in grid // EX: 40 = 40x40 
@export var squareSize = 40
## Primary color of the grid
@export var primaryColor:Color = Color.ORANGE
@export var secondaryColor:Color = Color.DARK_ORANGE

func _ready():
	generateGrid()

func generateGrid():
	for x in width:
		for y in height:
			var tile = ColorRect.new()
			tile.position.x = squareSize * x
			tile.position.y = squareSize * y
			tile.size = Vector2(squareSize,squareSize)
			if x % 2 == 0 && y % 2 == 0:
				tile.color = primaryColor
			elif x % 2 == 1 && y % 2 == 1:
				tile.color = primaryColor
			else:
				tile.color = secondaryColor
			add_child(tile)
