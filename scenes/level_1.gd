extends Node2D

var score = 0


func add_point() -> void:
	score += 1
	
func reset_score() -> void:
	score = 0
	print("Score Reset")
