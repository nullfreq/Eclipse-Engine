extends SongScript

func _process(delta: float):
	pass
	# tbh this is just a test script LMAO

func onBeatHit(beat):
	if beat % 8 == 7:
		game.bf.playAnim("hey")
		await game.bf.animation_finished
		if game.bf.animation != game.bf.findAnim("idle"):
			game.bf.playAnim("idle")
