extends CanvasLayer


func _on_button_start_pressed() -> void:
	print("Pressed Start")
	get_tree().change_scene_to_file("res://scenes/levels_scene.tscn")
