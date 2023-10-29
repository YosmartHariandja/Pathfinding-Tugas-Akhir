extends Node

signal result_log_signal(_log:String, _data:Array);

var tutorialScene:PackedScene = preload("res://Scenes/tutorial.tscn");
var resultPanel:PackedScene = preload("res://Scenes/result_log.tscn");

var viewport:SubViewport;
var dialog:AcceptDialog;
var mapOption:OptionButton;
var mainSceneInstance:Node2D;

var optionAlgo:int = 0;
var timeStep:float = 0;
var map:String;
var resultLog:Array;

func _ready() -> void:
	viewport = $GridContainer/SubViewportContainer/SubViewport;
	dialog = $AcceptDialog;
	mapOption = $GridContainer/HBoxContainer/VBoxContainer/OptionButton2;
	self.connect("result_log_signal", on_result_log_signal);
	self.add_child(tutorialScene.instantiate());

func Reset() -> void:
	viewport.get_child(0).queue_free();
	mainSceneInstance = preload("res://Scenes/main.tscn").instantiate()
	if(mainSceneInstance.pathfindNodes.algoMode != optionAlgo):
		mainSceneInstance.pathfindNodes.algoMode = optionAlgo;
	if(mainSceneInstance.pathfindNodes.timeStep != timeStep):
		mainSceneInstance.pathfindNodes.timeStep = timeStep;
	viewport.add_child(mainSceneInstance);

func _on_button_pressed() -> void:
	Reset();
	mapOption.select(-1);

func _on_option_button_item_selected(index) -> void:
	viewport.get_child(0).emit_signal("change_algo_signal", index);
	optionAlgo = index;

func _on_option_button_2_item_selected(index:int) -> void:
	if(index == -1):
		return;
	Reset();
	if(index < 9):
		map = "Map0" + str(index + 1);
	else:
		map = "Map" + str(index + 1);
	mainSceneInstance.emit_signal("change_map_signal", map);

func _on_option_button_3_item_selected(index:int) -> void:
	match index:
		0: timeStep = 0.0;
		1: timeStep = 0.05;
		2: timeStep = 0.5;
		3: timeStep = 1.0;
		4: timeStep = 3.0;
	viewport.get_child(0).emit_signal("change_delay_signal", timeStep);

func on_result_log_signal(_log:String, _data:Array) -> void:
	_data.push_back(map);
	dialog.dialog_text = _log;
	dialog.popup_centered();
	dialog.show();
	resultLog.push_back(_data);

func _on_button_2_pressed():
	var instance:Control = resultPanel.instantiate();
	instance.Establish(resultLog);
	self.add_child(instance);

func _on_tutorial_button_pressed():
	self.add_child(tutorialScene.instantiate());
