extends Node2D

const Player = preload("res://Player.tscn")
const Exit = preload("res://ExitDoor.tscn")
var borders = Rect2(1, 1, 348, 211)

onready var tileMap = get_node("TileMap")
onready var forestTile = get_node("Forest")

onready var camera = get_node("Camera2D")

func _ready():
	randomize()
	generate_level()

func generate_level():
	var walker = Walker.new(Vector2(19, 11), borders)
	var map = walker.walk(500)
	
	var player = Player.instance()
	add_child(player)
	player.position = map.front()*34
	
	player.get_node("RemoteTransform2D").remote_path = camera.get_path()
	
	var exit = Exit.instance()
	add_child(exit)
	var rooms = walker.rooms
	exit.position = walker.get_end_room().position*32
	exit.connect("leaving_level", self, "reload_level")
	
	walker.queue_free()
	for location in map:
#		tileMap.set_cellv(location, 0)
		forestTile.set_cellv(location, 0)
	for location in map:
		place_borders(location)
	tileMap.update_bitmask_region()
	forestTile.update_bitmask_region()

func place_borders(location):
	var size = Vector2(20, 20)
	var top_left_corner = (location - size/2).ceil()
	for y in size.y:
		for x in size.x:
			var limit = top_left_corner + Vector2(x, y)
			var cellValue = [forestTile.get_cellv(limit), limit, false]
			if forestTile.get_cellv(limit) == -1:
				tileMap.set_cellv(limit, 0)

	
func reload_level():
	get_tree().reload_current_scene()

#func _input(event):
#	if event.is_action_pressed("ui_accept"):
#		reload_level()
