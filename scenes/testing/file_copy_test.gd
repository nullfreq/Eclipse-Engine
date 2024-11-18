extends Node2D


func _on_file_dialog_file_selected(path: String) -> void:
	print(path)
	print("trying to copy to res://assets/IMPORT_TEST/"+path.get_file())
	var poop = DirAccess
	poop.copy_absolute(path,"res://assets/IMPORT_TEST/"+path.get_file(),-1)
	print(poop.get_open_error())
	#var cock = AudioStreamPlayer.new()
	#cock.stream = load("res://assets/IMPORT_TEST/"+path.get_file())
	#var piss = EditorInterface.get_resource_filesystem()
	#piss.scan()
	#cock.play()
