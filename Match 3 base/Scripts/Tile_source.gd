extends Node2D

#the declared nodes for this scene
@export var image:Sprite2D
@export var internal_image_effect:Sprite2D
#the game data in the tile, status effects are applied "externally", tile effects are applied "internally", tile type is what matches, or are unique tiles
@export var status_effect_types:Array [int]
@export var tile_type: int
@export var tile_effect: int
#graphical elements that are held that can be displayed, if desiring to put in more images, split it up more as accordingly.
@export var images:Array [Texture2D]
@export var colors:Array[Color]
@export var static_internal_effects:Array[Texture2D]
@export var static_external_effects:Array[Texture2D]
@export var animated_internal_effects: Array[AnimatedTexture]
@export var animated_external_effects: Array[AnimatedTexture]
@export var container: Node2D
@export var timer: Timer
var disposable_image_path =  preload("res://Scenes/Disposable_image.tscn")
var disposable_image = disposable_image_path.instantiate()
var matched: bool = false
var number: int = 0
#for now, no animation will be considered for the time being, so it will simplify the whole thing.

# Called when the node enters the scene tree for the first time.
func _ready():
	#if desired, the color can be adjusted and changed as accordingly if needed by setting another variable.
	image.texture = images[tile_type]
	image.self_modulate = colors[tile_type]
	#this is the effects
	internal_image_effect.texture = static_internal_effects[tile_effect]
	timer.connect("timeout", _timeout)

#this function serves the purposes of having a cycling effect

func _timeout():
	if(status_effect_types.size()>0):
		if(status_effect_types.size()<number):
			number =0
			container.get_child(0).texture = preload("res://Assets/Effects/Empty.png")
			return
		container.get_child(0).texture = static_external_effects[status_effect_types[number]]
	
	else:
		container.get_child(0).texture = preload("res://Assets/Effects/Empty.png")

#the function for animated movement.
func move(position: Vector2):
	var movement =create_tween()
	movement.tween_property(self, "position", position, .2)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	image.texture = images[tile_type]
	image.self_modulate = colors[tile_type]
	internal_image_effect.texture = static_internal_effects[tile_effect]

func dimmer():
	var sprite = get_node("Image")
	sprite.modulate = Color(1,1,1,.5)
	matched =true

func match_effect():
	pass
