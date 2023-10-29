extends Control

var row:PackedScene = preload("res://Scenes/result_row.tscn");
var logData:Array;
var fileDialog:FileDialog;
var acceptDialog:AcceptDialog;

func _ready() -> void:
	fileDialog = self.get_child(0);
	acceptDialog = self.get_child(1);

func Establish(_log_data:Array) -> void:
	for data in _log_data:
		var row_instance:HBoxContainer = row.instantiate();
		row_instance.get_child(0).text = str(data[0]);
		row_instance.get_child(1).text = str(data[1]);
		row_instance.get_child(2).text = str(data[2]);
		row_instance.get_child(3).text = str(data[3]);
		row_instance.get_child(4).text = str(data[4]);
		row_instance.get_child(5).text = str(data[5]);
		row_instance.get_child(6).text = str(data[6]);
		self.get_child(2).get_child(1).get_child(0).get_child(0).add_child(row_instance);
	logData = _log_data;

func _on_button_pressed() -> void:
	self.queue_free();

func _on_button_2_pressed() -> void:
	fileDialog.add_filter("*.txt", "Text");
	fileDialog.current_file = "Result Log";
	fileDialog.popup_centered();

func _on_file_dialog_file_selected(path:String) -> void:
	var file = FileAccess.open(path, FileAccess.WRITE)
	for item in logData:
		file.store_line(Join(item, ","));
	file.close();

func Join(array:Array, filler:String) -> String:
	var rs:String = "";
	for s in array:
		rs += str(s)+filler;
	return rs;

func _on_file_dialog_confirmed():
	acceptDialog.dialog_text = "Save has been succefull.";
	acceptDialog.popup_centered();
