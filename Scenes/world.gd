extends Node2D

@onready var fade_anim: AnimationPlayer = $CanvasLayer/FadeRect/AnimationPlayer
@onready var fade_rect: ColorRect = $CanvasLayer/FadeRect

func _ready():
	fade_rect.visible = true
	fade_anim.play("fade_in")
