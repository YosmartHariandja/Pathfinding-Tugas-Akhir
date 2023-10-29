extends Node2D
class_name PathNode

@export var tile:Sprite2D;
@export var arrow:Sprite2D;

enum Type{
	OPEN = 0,
	BLOCK = 1,
	MILD = 2,
	HARSH = 3,
	JARRING = 4,
};

var index:Vector2i = Vector2i.ZERO;
var neighbors:Array[PathNode] = [];
var type:int = Type.OPEN;
var previous:PathNode = null;
var priority:int = 0;
var distance:int = 0;

func Reset() -> void:
	previous = null;

func CompareTo(_other:PathNode) -> int:
	if(priority < _other.priority):
		return -1;
	elif(priority > _other.priority):
		return 1;
	else:
		return 0;

static func PriorityEnqueueBinaryHeap(_node:PathNode, _queue:Array[PathNode]) -> void:
	_queue.push_back(_node);
	var index_queue:int = _queue.size() - 1;
	
	while(index_queue > 0):
		var parent_index:int = floor((index_queue - 1) / 2);
		
		if(_queue[index_queue].CompareTo(_queue[parent_index]) >= 0):
			break;
			
		var temp_node:PathNode = _queue[index_queue];
		_queue[index_queue] = _queue[parent_index];
		_queue[parent_index] = temp_node;
		
		index_queue = parent_index;

static func PriorityMergeSort(_queue:Array[PathNode]) -> Array[PathNode]:
	if(_queue.size() > 1):
		var mid:int = floor(_queue.size() / 2);
		var left:Array[PathNode] = _queue.slice(0, mid);
		var right:Array[PathNode] = _queue.slice(mid, _queue.size());
		
		PriorityMergeSort(left);
		PriorityMergeSort(right);
		
		var i:int = 0;
		var j:int = 0;
		var k:int = 0;
		
		while(i < left.size() && j < right.size()):
			if(left[i].priority <= right[j].priority):
				_queue[k] = left[i];
				i += 1;
			else:
				_queue[k] = right[j];
				j += 1;
			k += 1;
		
		while(i < left.size()):
			_queue[k] = left[i];
			i += 1;
			k += 1;
		
		while(j < right.size()):
			_queue[k] = right[j];
			j += 1;
			k += 1;

		return _queue
	return _queue;

static func PriorityDequeueLinear(_queue:Array[PathNode]) -> PathNode:
	var best_index:int = 0;
	var best_node:PathNode = _queue[best_index];
	
	for i in range(_queue.size()):
		if _queue[i].priority < best_node.priority:
			best_node = _queue[i];
			best_index = i;
	_queue.remove_at(best_index);
	
	return best_node;

static func PriorityDequeueBinaryHeap(_queue:Array[PathNode]) -> PathNode:
	var index_queue:int = _queue.size() - 1;
	var front:PathNode = _queue[0];
	
	_queue[0] = _queue[index_queue];
	_queue.remove_at(index_queue);
	index_queue = 0;
	
	while(true):
		var child_index = index_queue * 2 + 1;
		
		if(child_index > _queue.size() - 1):
			break;
			
		var right_index = index_queue * 2 + 2;
		
		if(right_index <= _queue.size() - 1 && _queue[right_index].CompareTo(_queue[child_index]) < 0):
			child_index = right_index;
		if(_queue[index_queue].CompareTo(_queue[child_index]) <= 0):
			break;
			
		var temp_node:PathNode = _queue[index_queue];
		_queue[index_queue] = _queue[child_index];
		_queue[child_index] = temp_node;
		
		index_queue = child_index;
	
	return front;

func PointArrow() -> void:
	if(previous == null):
		return;
	ToggleVisibility(arrow, true);
	arrow.look_at(previous.position);

func ColorArrow(_color:Color) -> void:
	arrow.modulate = _color;

func ColorTile(_color:Color) -> void:
	tile.modulate = _color;

func ToggleVisibility(_node:CanvasItem, _show:bool) -> void:
	_node.visible = _show;


func _on_button_pressed() -> void:
	self.get_parent().get_parent().emit_signal("grandchild_signal", self);
