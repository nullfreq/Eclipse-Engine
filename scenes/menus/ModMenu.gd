extends Node2D

var userFolder = DirAccess.open("user://")
var modList = []
var modLabels = []
var curMod = 0
var modCount = -1
var time = 0
@onready var cam = $Camera2D

func _ready():
	if !userFolder.dir_exists("mods"):
		makeModFolder()
	getMods()

func _process(delta: float):
	time += delta
	if visible:
		if modCount > -1:
			for i in modLabels:
				if curMod == modLabels.find(i,0):
					i.modulate.a = 1
					$Camera2D.position = i.position
				else:
					i.modulate.a = 0.6
		if Input.is_action_just_pressed("up"):
			curMod -= 1
			if curMod < 0:
				curMod = modCount
			Global.playSound("scroll")
		
		if Input.is_action_just_pressed("down"):
			curMod += 1
			if curMod > modCount:
				curMod = 0
			Global.playSound("scroll")
		
		if Input.is_action_just_pressed("ui_accept"):
			for i in modLabels:
				if i == modLabels[curMod]:
					i.modulate.r = 0
					i.modulate.b = 0
				else:
					i.modulate.r = 1
					i.modulate.b = 1
			Global.playSound("confirm")
			if modList[curMod] != "Close Menu":
				var mod2load = "user://mods/"+str(modList[curMod])
				print(mod2load+".pck")
				ProjectSettings.load_resource_pack(mod2load+".pck",true)
				$CanvasLayer/CurrentMod.text = mod2load+".pck"
				DisplayServer.window_set_title(modList[curMod])
				var modIcon = ""
				if FileAccess.file_exists(mod2load+".png"):
					modIcon = mod2load+".png"
				else:
					modIcon = "res://assets/misc/iconOG.png"
				DisplayServer.set_icon(Image.load_from_file(modIcon))
				Global.switchScene("res://scenes/menus/TitleScene.tscn")
			if modList[curMod] == "Close Menu":
				queue_free()
				get_parent().inModMenu = false
		#for i in modLabels:
			#i.rotation += cos(time*4)*.5

func getMods():
	modCount = -1
	for i in modLabels:
		i.queue_free()
	modList.clear()
	modLabels.clear()
	var mods = DirAccess.get_files_at("user://mods/")
	for i in mods:
		if i.ends_with(".pck"):
			#print(i)
			modList.append(i.trim_suffix(".pck"))
			modCount += 1
	modList.append("Close Menu")
	modCount += 1
	for i in modList:
		var MODLABEL = Alphabet.new()
		MODLABEL.text = i
		MODLABEL.position.x = (7 * modList.find(i,0))+40
		MODLABEL.position.x += 40
		MODLABEL.position.y = (100 * modList.find(i,0))+120
		modLabels.append(MODLABEL)
		add_child(MODLABEL)

func _on_mods_folder_pressed():
	var yeah = OS.get_user_data_dir()+"/mods/"
	OS.shell_show_in_file_manager(yeah,true)

func makeModFolder():
	userFolder.make_dir("mods")

func _on_refresh_pressed():
	getMods()
