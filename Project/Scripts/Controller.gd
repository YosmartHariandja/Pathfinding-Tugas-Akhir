extends Node2D

@export var graphNodes:Node2D;
@export var camera:Camera2D;
@export var mapNodes:Node2D;
@export var pathfindNodes:Node2D;

signal grandchild_signal(_node:PathNode);
signal change_algo_signal(_algo_mode:int);
signal change_map_signal(_map_mode:String);
signal change_delay_signal(_time_step:float);

var once:bool = false;
var counter:int = 0;
var reset:bool = false;

func _ready() -> void:
	self.connect("grandchild_signal", on_grandchild_signal);
	self.connect("change_algo_signal", on_change_algo_signal);
	self.connect("change_map_signal", on_change_map_signal);
	self.connect("change_delay_signal", on_change_delay_signal);

func _process(_delta:float) -> void:
	var zoom_min:float = min(self.get_viewport().size.x / (mapNodes.width * 128.0 + 128),
	self.get_viewport().size.y / (mapNodes.height * 128.0));
	camera.zoom.x = zoom_min;
	camera.zoom.y = zoom_min;
	camera.position.x = (mapNodes.width * 128.0) / 2;
	camera.position.y = (mapNodes.height * 128.0) / 2;
	
	if(Input.is_action_just_pressed("ui_accept") && !once && counter > 1):
		pathfindNodes = pathfindNodes as PathfindNodes;
		graphNodes = graphNodes as GraphNodes;
		pathfindNodes.EstablishPathing(graphNodes);
		pathfindNodes.SearchRoutine()
		once = true;

func Initialize() -> void:
	mapNodes = mapNodes as MapNodes;
	graphNodes = graphNodes as GraphNodes;
	mapNodes.TranslateMap();
	graphNodes.EstablishGraph(mapNodes.width, mapNodes.height, mapNodes.data);

func on_change_delay_signal(_time_step:float) -> void:
	if(!once):
		pathfindNodes = pathfindNodes as PathfindNodes;
		pathfindNodes.timeStep = _time_step;

func on_change_map_signal(_map_mode:String) -> void:
	if(!once):
		mapNodes = mapNodes as MapNodes;
		mapNodes.textPath = "res://Resources/Map/" + _map_mode +".txt";
		Initialize();

func on_change_algo_signal(_algo_mode:int) -> void:
	if(!once):
		pathfindNodes = pathfindNodes as PathfindNodes;
		pathfindNodes.algoMode = _algo_mode;

func on_grandchild_signal(_node:PathNode) -> void:
	pathfindNodes = pathfindNodes as PathfindNodes;
	if(counter == 0 && _node.type != PathNode.Type.BLOCK):
		pathfindNodes.startNode = _node;
		pathfindNodes.startNode.ColorTile(pathfindNodes.startColor);
		pathfindNodes.startNode.type = PathNode.Type.OPEN;
		counter += 1;
	elif(counter == 1 && _node != pathfindNodes.startNode && _node.type != PathNode.Type.BLOCK):
		pathfindNodes.endNode = _node;
		pathfindNodes.endNode.ColorTile(pathfindNodes.endColor);
		pathfindNodes.endNode.type = PathNode.Type.OPEN;
		counter += 1;
		
