extends Node2D
class_name GraphNodes

@export var pathNode:Resource = preload("res://Scenes/path_node.tscn");

var nodes:Array[Array];
var width:int;
var height:int;

static var oddDirections:PackedVector2Array = [
	Vector2(0,1),
	Vector2(1,1),
	Vector2(1,0),
	Vector2(1,-1),
	Vector2(0,-1),
	Vector2(-1,0),
];
static var evenDirections:PackedVector2Array = [
	Vector2(0,1),
	Vector2(1,0),
	Vector2(0,-1),
	Vector2(-1,-1),
	Vector2(-1,0),
	Vector2(-1,1),
];

func GetDistance(_start:PathNode, _end:PathNode) -> int:
	var dx:int = abs(_start.index.x - _end.index.x);
	var dy:int = abs(_start.index.y - _end.index.y);
	return (dy + dx);

func IsWithinBounds(_x:int, _y:int) -> bool:
	return (_x >= 0 && _x < width && _y >= 0 && _y < height);

func GetNeighbors(_x:int, _y:int) -> Array[PathNode]:
	var neighbor_nodes:Array[PathNode] = [];
	var directions:PackedVector2Array;
	if(_y % 2 == 0):
		directions = evenDirections;
	else:
		directions = oddDirections;
	for dir in directions:
		var newX:int = _x + int(dir.x);
		var newY:int = _y + int(dir.y);
		if(IsWithinBounds(newX, newY) && nodes[newX][newY].type != PathNode.Type.BLOCK):
			neighbor_nodes.push_back(nodes[newX][newY]);
	return neighbor_nodes;

func EstablishGraph(_width:int, _height:int, _data:Array[PackedInt32Array]) -> void:
	for i in range(get_child_count()):
		get_child(i).queue_free();
	width = _width;
	height = _height;
	nodes.resize(_width);
	for i in range(nodes.size()):
		nodes[i].resize(_height);
	for x in range(_width):
		for y in range(_height):
			var instance:Node2D = pathNode.instantiate();
			instance = instance as PathNode;
			instance.type = _data[x][y];
			instance.index = Vector2(x,y);
			if(y % 2 == 0):
				instance.position = Vector2(x, y) * 128 + Vector2(64, 64);
			else:
				instance.position = Vector2(x, y) * 128 + Vector2(128, 64);
			instance.ColorTile(MapNodes.GetColorFromNodeType(instance.type));
			nodes[x][y] = instance;
			self.add_child(instance);
	for x in range(_width):
		for y in range(_height):
			nodes[x][y].neighbors = GetNeighbors(x,y);

func ShowArrowNodes(_nodes:Array[PathNode], _color:Color) -> void:
	for node in _nodes:
		node.ColorArrow(_color);
		node.PointArrow();

func ColorToGrayscale(_color:Color) -> Color:
	var average = (_color.r + _color.g + _color.b) / 3.0;
	return Color(average, average, average, _color.a)

func ColoringNodes(_color: Color, _nodes:Array[PathNode], _lerp:bool = false,
_value:float = 0.5) -> void:
	for node in _nodes:
		var new_color:Color = _color;
		if(_lerp):
			new_color = MapNodes.GetColorFromNodeType(node.type).lerp(new_color, _value);
		node.ColorTile(new_color);


