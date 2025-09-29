@tool
extends Node2D

enum BuildingType {
	BUILDING,
	PILLAR_PLATFORM,
	FLOATING_PLATFORM,
	WALL,
}

@export_range(3, 1000)
var width := 10: 
	set(v):
		width = v
		regenerate_building()
@export
var type := BuildingType.BUILDING:
	set(v):
		type = v
		regenerate_building()
@export var allow_player_damage := true:
	set(v):
		allow_player_damage = v
		if has_node("TileMapLayer"):
			$TileMapLayer.allow_player_damage = v
		else:
			(func():
				$TileMapLayer.allow_player_damage = allow_player_damage
			).call_deferred()
@export var hit_points := 3:
	set(v):
		hit_points = v
		if has_node("TileMapLayer"):
			$TileMapLayer.hit_points = v
		else:
			(func():
				$TileMapLayer.hit_points = v
			).call_deferred()


func regenerate_building() -> void:
	var tmap: TileMapLayer = $TileMapLayer
	tmap.clear()
	@warning_ignore("integer_division")
	var hwidth := width / 2
	if type == BuildingType.BUILDING:
		for y in range(-1, 100):
			var row: int
			if y == -1:
				row = 0
			elif y <= 5 and y >= 0:
				row = 1
			elif y <= 14:
				row = 2
			else:
				row = 3
			var roffset := 1 if width % 2 == 0 else 0
			tmap.set_cell(Vector2i(-hwidth, y), 0, Vector2i(4, row))
			tmap.set_cell(Vector2i(hwidth - roffset, y), 0, Vector2i(7, row))
			for x in range(-hwidth + 1, hwidth - roffset):
				tmap.set_cell(Vector2i(x, y), 0, Vector2i(6 if y % 3 == 1 else 5, row))
	elif type == BuildingType.FLOATING_PLATFORM:
		var roffset := 1 if width % 2 == 0 else 0
		tmap.set_cell(Vector2i(-hwidth, -1), 0, Vector2i(1, 2))
		tmap.set_cell(Vector2i(hwidth - roffset, -1), 0, Vector2i(3, 2))
		for x in range(-hwidth + 1, hwidth - roffset):
			tmap.set_cell(Vector2i(x, -1), 0, Vector2i(2, 2))
	elif type == BuildingType.PILLAR_PLATFORM:
		var roffset := 1 if width % 2 == 0 else 0
		# Construct top layer
		tmap.set_cell(Vector2i(-hwidth, 0), 0, Vector2i(1, 2))
		tmap.set_cell(Vector2i(hwidth - roffset, 0), 0, Vector2i(3, 2))
		for x in range(-hwidth + 1, hwidth - roffset):
				tmap.set_cell(Vector2i(x, 0), 0, Vector2i(2, 2))
		# add pillar supports to top layer
		for x in range(0, hwidth, 4):
			tmap.set_cell(Vector2i(x, 0), 0, Vector2i(2, 0))
			tmap.set_cell(Vector2i(-x, 0), 0, Vector2i(2, 0))
		# construct pillars
		for y in range(1, 100):
			for x in range(0, hwidth, 4):
				tmap.set_cell(Vector2i(x, y), 0, Vector2i(randi_range(0, 3), 1))
				tmap.set_cell(Vector2i(-x, y), 0, Vector2i(randi_range(0, 3), 1))
	elif type == BuildingType.WALL:
		tmap.set_cell(Vector2i(0, 0), 0, Vector2i(8, 0))
		for y in range(1, 100):
			tmap.set_cell(Vector2i(0, y), 0, Vector2i(8, 1))
		
