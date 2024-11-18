extends Node2D

var curAnim = "idle"
var character = ""
var onUI = false
var offsetIncrement = 1

func _ready():
	$CanvasLayer/Window/CodeEdit.text = str(JSON.stringify($Character.charData,"\t"))
	$Character.charData.animations.keys()
	$Ghost.isPlayer = $Ghost.charData.isPlayer
	$Character.isPlayer = $Character.charData.isPlayer
	for i in $Character.charData.animations.keys():
		$CanvasLayer/DataPanel/animList.add_item(i,null,true)
	getJsons()

func getJsons():
	$CanvasLayer/CharacterList.clear()
	var jsons = []
	jsons.append(DirAccess.get_files_at("res://assets/data/characters/"))
	print(jsons)
	for file in jsons[0]:
		$CanvasLayer/CharacterList.add_item(str(file).trim_suffix(".json"),null,true)

func _on_load_pressed():
	Global.playSound("confirm")
	curAnim = "idle"
	var curItem = str($CanvasLayer/CharacterList.get_selected_items()).replace("[","").replace("]","")
	character = $CanvasLayer/CharacterList.get_item_text(int(curItem))
	$Character.loadChar(character)
	$Character.frame = 0
	$Ghost.loadChar(character)
	$Ghost.frame = 0
	$Ghost.isPlayer = $Ghost.charData.isPlayer
	$Character.isPlayer = $Character.charData.isPlayer
	$CanvasLayer/DataPanel/animList.clear()
	for i in $Character.charData.animations.keys():
		$CanvasLayer/DataPanel/animList.add_item(i,null,true)
	$CanvasLayer/Window/CodeEdit.text = str(JSON.stringify($Character.charData,"\t"))

func _process(delta: float):
	if $CanvasLayer/NewCharWindow.visible || $CanvasLayer/AddAnimWindow.visible:
		$CanvasLayer/BlurBG.show()
	else:
		$CanvasLayer/BlurBG.hide()
	#if $Character.frame > 2:
		#$Ghost.frame = $Character.frame - 2
	#$Ghost.offset = $Character.offset
	#$Ghost.animation = $Character.animation
	if !$CanvasLayer/BlurBG.visible:
		if !onUI:
			if Input.is_action_just_released("scrollDown"):
				$Character/Camera2D.position.y -= 5
			if Input.is_action_just_released("scrollUp"):
				$Character/Camera2D.position.y += 5
			if Input.is_action_just_released("scrollLeft"):
				$Character/Camera2D.position.x += 5
			if Input.is_action_just_released("scrollRight"):
				$Character/Camera2D.position.x -= 5
			if Input.is_action_just_pressed("left"):
				$Character.offset.x -= offsetIncrement
			if Input.is_action_just_pressed("right"):
				$Character.offset.x += offsetIncrement
			if Input.is_action_just_pressed("up"):
				$Character.offset.y -= offsetIncrement
			if Input.is_action_just_pressed("down"):
				$Character.offset.y += offsetIncrement
	#if Input.is_action_just_pressed("left"):
		#curAnim -= 1
		#if curAnim < 0:
			#curAnim = $Character.animShit.size()-1
		#$Character.playAnim(curAnim)
	#if Input.is_action_just_pressed("right"):
		#curAnim += 1
		#if curAnim > $Character.animShit.size()-1:
			#curAnim = 0
		#$Character.playAnim(curAnim)
			if Input.is_action_just_pressed("space"):
				$Character.playAnim(curAnim)
			if Input.is_action_just_pressed("editorZoomIn"):
				$Character/Camera2D.zoom.x += 0.05
				$Character/Camera2D.zoom.y += 0.05
			if Input.is_action_just_pressed("editorZoomOut"):
				$Character/Camera2D.zoom.x -= 0.05
				$Character/Camera2D.zoom.y -= 0.05
			if Input.is_action_just_pressed("resetCam"):
				$Character/Camera2D.position = Vector2(0,0)
				$Character/Camera2D.zoom = Vector2(1,1)

	$CanvasLayer/DataPanel/Offset.text = "Offset: "+str($Character.offset)
	$CanvasLayer/DataPanel/Source.text = "Source: "+str($Character.animation)

func _on_save_pressed():
	var file = FileAccess.open("res://assets/data/characters/"+character+".json",FileAccess.READ_WRITE)
	file.store_string(JSON.stringify($Character.charData,"\t"))
	print("Saved @ "+"res://assets/data/characters/"+character+".json !")

func _on_view_json_pressed():
	$CanvasLayer/Window.show()

func _on_code_edit_mouse_entered():
	onUI = true

func _on_code_edit_mouse_exited():
	onUI = false

func _on_character_list_mouse_entered():
	onUI = true

func _on_character_list_mouse_exited():
	onUI = false

func _on_data_panel_mouse_entered():
	onUI = true

func _on_data_panel_mouse_exited():
	onUI = false

func _on_window_close_requested():
	$CanvasLayer/Window.hide()

func _on_anim_list_item_selected(index: int):
	Global.playSound("scroll")
	curAnim = $CanvasLayer/DataPanel/animList.get_item_text(index)
	$Character.playAnim(curAnim)
	print(curAnim)

func _on_anim_list_mouse_entered():
	onUI = true

func _on_anim_list_mouse_exited():
	onUI = false

func _on_new_pressed():
	$CanvasLayer/NewCharWindow.show()

func _on_new_char_window_close_requested():
	$CanvasLayer/NewCharWindow.hide()

func _on_new_char_window_visibility_changed():
	getJsons()

func _on_add_anim_pressed():
	$CanvasLayer/AddAnimWindow.show()

func _on_add_anim_window_close_requested():
	$CanvasLayer/AddAnimWindow.hide()

func _on_character_list_item_selected(index: int):
	Global.playSound("scroll")
