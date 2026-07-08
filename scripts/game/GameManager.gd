extends Node

var score = 0
var lives = 3
var max_health = 3
var health = max_health

var has_key = false

# Equipment
var has_gun = false
var has_jetpack = false

# Jetpack
var max_jetpack_fuel = 100.0
var jetpack_fuel = max_jetpack_fuel

func add_score(amount: int):
	score += amount

func reset_key():
	has_key = false

func collect_key():
	has_key = true
