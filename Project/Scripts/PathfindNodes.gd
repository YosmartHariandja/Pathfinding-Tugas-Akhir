extends Node2D
class_name PathfindNodes

var startNode:PathNode;
var endNode:PathNode;
var graphNodes:GraphNodes;

var frontierNodes:Array[PathNode];
var reachedNodes:Array[PathNode];
var finishNodes:Array[PathNode];

@export var startColor = Color.GREEN;
@export var endColor = Color.RED;
@export var frontierColor = Color.MAGENTA;
@export var reachedColor = Color.GRAY;
@export var finishColor = Color.CYAN;
@export var arrowColor = Color.DIM_GRAY;
@export var highlightColor = Color.YELLOW;

@export var showColors:bool = true;
@export var showArrows:bool = true;
@export var exitOnGoal:bool = true;

var complete:bool = false;
@export var timeStep:float = 0.15

enum Algo{BFS, DFS, GreedyBFS, Dijkstra, AStar}
@export_enum("BFS", "DFS", "GreedyBFS", "Dijkstra", "AStar") var algoMode:int = self.Algo.BFS;

func EstablishPathing(_graph:GraphNodes) -> void:
	graphNodes = _graph;
	
	frontierNodes.push_back(startNode);
	for x in range(graphNodes.width):
		for y in range(graphNodes.height):
			graphNodes.nodes[x][y].Reset();
	complete = false;
	startNode.priority = 0;
	startNode.distance = 0;

func SearchRoutine() -> void:
	var time_start:float = Engine.get_physics_frames();
	var time_end:float = 0.0;
	var fps:float = ProjectSettings.get_setting("physics/common/physics_ticks_per_second");
	var expanded_nodes:int = 0;
	await(get_tree().process_frame);
	while(!complete):
		if(frontierNodes.size() > 0):
			var current_node:PathNode;
			if(algoMode == Algo.BFS || algoMode == Algo.DFS):
				current_node = frontierNodes.pop_front();
			elif(algoMode == Algo.Dijkstra):
				# If the priorty deueue binary tree, some of the path is not the best.
				current_node = PathNode.PriorityDequeueLinear(frontierNodes);
			else:
				current_node = PathNode.PriorityDequeueBinaryHeap(frontierNodes);
			if(!reachedNodes.has(current_node)):
				reachedNodes.push_back(current_node);
			var previous_expanded:int = frontierNodes.size();
			if(algoMode == Algo.BFS):
				ExpandFrontierBFS(current_node);
			elif(algoMode == Algo.DFS):
				ExpandFrontierDFS(current_node);
			elif(algoMode == Algo.GreedyBFS):
				ExpandFrontierGreedyBFS(current_node);
			elif(algoMode == Algo.Dijkstra):
				ExpandFrontierDijkstra(current_node);
			elif(algoMode == Algo.AStar):
				ExpandFrontierAStar(current_node);
			expanded_nodes += frontierNodes.size() - previous_expanded;
			if(frontierNodes.has(endNode)):
				if(time_end == 0.0):
					time_end = (Engine.get_physics_frames() - time_start) / fps;
				ProduceFinishedPath();
				if(exitOnGoal):
					complete = true;
			ShowDiagnostics();
			await(get_tree().create_timer(timeStep).timeout);
		else:
			complete = true;
	var log:String = "PATHFINDER SearchIterations: Elapse Time = " + str(time_end) + " seconds. \n";
	log += "Mode: " + str(Algo.keys()[algoMode]);
	log += " |	 Path Length = " + str(endNode.distance);
	log += " |	 Node Traveled = " + str(finishNodes.size()) ;
	log += " |	 Node Expanded = " + str(expanded_nodes);
	var data:Array = [Algo.keys()[algoMode], time_end, timeStep, endNode.distance, finishNodes.size(), expanded_nodes]
	self.get_tree().root.get_node("Game").emit_signal("result_log_signal", log, data);

# Uninformed
func ExpandFrontierBFS(_node:PathNode) -> void:
	for i in range(_node.neighbors.size()):
		if(!reachedNodes.has(_node.neighbors[i]) && !frontierNodes.has(_node.neighbors[i])):
			var distance:int = graphNodes.GetDistance(_node, _node.neighbors[i]);
			var sum_distance:int = distance + _node.distance + _node.neighbors[i].type;
			_node.neighbors[i].distance = sum_distance;
			_node.neighbors[i].priority = reachedNodes.size() ;
			_node.neighbors[i].previous = _node;
			frontierNodes.push_back(_node.neighbors[i]);
# Uninformed
func ExpandFrontierDFS(_node:PathNode) -> void:
	for i in range(_node.neighbors.size()):
		if(!reachedNodes.has(_node.neighbors[i]) && !frontierNodes.has(_node.neighbors[i])):
			var distance:int = graphNodes.GetDistance(_node, _node.neighbors[i]);
			var sum_distance:int = distance + _node.distance + _node.neighbors[i].type;
			_node.neighbors[i].distance = sum_distance;
			_node.neighbors[i].priority = reachedNodes.size();
			_node.neighbors[i].previous = _node;
			frontierNodes.push_front(_node.neighbors[i]);
# Uninformed
func ExpandFrontierGreedyBFS(_node:PathNode) -> void:
	for i in range(_node.neighbors.size()):
		if(!reachedNodes.has(_node.neighbors[i]) && !frontierNodes.has(_node.neighbors[i])):
			var distance:int = graphNodes.GetDistance(_node, _node.neighbors[i]);
			var sum_distance:int = distance + _node.distance  + _node.neighbors[i].type;
			_node.neighbors[i].distance = sum_distance;

			var distance_end:int = graphNodes.GetDistance(_node.neighbors[i], endNode);
			# Improvement
#			_node.neighbors[i].priority = distance_end + _node.neighbors[i].type;
			_node.neighbors[i].priority = distance_end;
			_node.neighbors[i].previous = _node;
			PathNode.PriorityEnqueueBinaryHeap(_node.neighbors[i], frontierNodes);
# Informed
func ExpandFrontierDijkstra(_node:PathNode) -> void:
	for i in range(_node.neighbors.size()):
		if(!reachedNodes.has(_node.neighbors[i])):
			var distance:int = graphNodes.GetDistance(_node, _node.neighbors[i]);
			var sum_distance:int = distance + _node.distance  + _node.neighbors[i].type;
			if(_node.neighbors[i].distance == 0 || sum_distance < _node.neighbors[i].distance):
				_node.neighbors[i].previous = _node;
				_node.neighbors[i].distance = sum_distance;
			if(!frontierNodes.has(_node.neighbors[i])):
				_node.neighbors[i].priority = _node.neighbors[i].distance;
				PathNode.PriorityEnqueueBinaryHeap(_node.neighbors[i], frontierNodes);
# Informed
func ExpandFrontierAStar(_node:PathNode) -> void:
	for i in range(_node.neighbors.size()):
		if(!reachedNodes.has(_node.neighbors[i])):
			var distance:int = graphNodes.GetDistance(_node, _node.neighbors[i]);
			var sum_distance:int = distance + _node.distance  + _node.neighbors[i].type;
			var distance_end:int = graphNodes.GetDistance(_node.neighbors[i], endNode);
			if(_node.neighbors[i].distance == 0 || sum_distance < _node.neighbors[i].distance):
				_node.neighbors[i].previous = _node;
				_node.neighbors[i].distance = sum_distance;
			if(!frontierNodes.has(_node.neighbors[i])):
				_node.neighbors[i].priority = _node.neighbors[i].distance + distance_end;
				PathNode.PriorityEnqueueBinaryHeap(_node.neighbors[i], frontierNodes);

func ProduceFinishedPath() -> void:
	finishNodes.push_back(endNode);
	var currentNode:PathNode = endNode.previous;
	
	while(currentNode != null):
		finishNodes.push_front(currentNode);
		currentNode = currentNode.previous;

func ShowColors() -> void:
	graphNodes.ColoringNodes(frontierColor, frontierNodes);
	graphNodes.ColoringNodes(reachedColor, reachedNodes, true);
	if(finishNodes.size() > 0):
		graphNodes.ColoringNodes(finishColor, finishNodes);
	startNode.ColorTile(startColor);
	endNode.ColorTile(endColor);

func ShowDiagnostics() -> void:
	if(showColors):
		ShowColors();
	if(showArrows):
		graphNodes.ShowArrowNodes(frontierNodes, arrowColor);
		if(frontierNodes.has(endNode)):
			graphNodes.ShowArrowNodes(finishNodes, highlightColor);
			if(exitOnGoal):
				complete = true;






