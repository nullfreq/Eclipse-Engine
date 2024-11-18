extends Node2D

var curSelected = 0
@onready var groups = [$Credits/EED,$Credits/FC,$Credits/SO]
var selectableLabels = []
var leavin = false

func _ready():
	for i in groups:
		for j in i.get_children():
			selectableLabels.append(j)

func _physics_process(delta: float):
	if Input.is_action_just_pressed("ui_unfocus") && !leavin:
		leavin = true
		Global.playSound("cancel")
		Global.switchScene("res://scenes/menus/MainMenu.tscn")
	
	if selectableLabels.size() > 0:
		for i in selectableLabels:
			i.modulate.a = 0.6
		selectableLabels[curSelected].modulate.a = 1
	if Input.is_action_just_pressed("up"):
		curSelected -= 1
		if curSelected < 0:
			curSelected = selectableLabels.size() - 1
		Global.playSound("scroll")
	if Input.is_action_just_pressed("down"):
		curSelected += 1
		if curSelected > selectableLabels.size() - 1:
			curSelected = 0
		Global.playSound("scroll")

	match curSelected:
		0:
			$DescriptionPanel/DescriptionLabel.text = "Did 99% of the code"
		1:
			$DescriptionPanel/DescriptionLabel.text = "Made custom sprites/art just for the engine!"
		2:
			$DescriptionPanel/DescriptionLabel.text = "Lead artist/animator for Funkin'"
		3:
			$DescriptionPanel/DescriptionLabel.text = "Lead programmer for Funkin'\nAlso known for zerkin' it to Hatsune Miku on Twitter"
		4:
			$DescriptionPanel/DescriptionLabel.text = "Lead composer for Funkin'"
		5:
			$DescriptionPanel/DescriptionLabel.text = "Second to lead artist for Funkin'"
		6:
			$DescriptionPanel/DescriptionLabel.text = "Alphabet code"
		7:
			$DescriptionPanel/DescriptionLabel.text = "He's shouted out in one of the intro text lines, so may as well shout him out here!"
