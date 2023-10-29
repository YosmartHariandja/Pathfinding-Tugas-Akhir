extends Node2D
class_name MapNodes

@export var width:int;
@export var height:int;
var data:Array[PackedInt32Array];

@export_file("*.txt") var textPath:String;

@export var openColor:Color = Color.WHITE;
@export var blockedColor:Color = Color.BLACK;
@export var mildColor:Color = Color.YELLOW_GREEN;
@export var harshColor:Color = Color.ORANGE;
@export var jarringColor:Color = Color.BROWN;

static var terrainLookupTable:Dictionary = {};

func _ready() -> void:
	self.SetupLookupTable();

func SetupLookupTable() -> void:
	self.terrainLookupTable[self.openColor] = PathNode.Type.OPEN;
	self.terrainLookupTable[self.blockedColor] = PathNode.Type.BLOCK;
	self.terrainLookupTable[self.mildColor] = PathNode.Type.MILD;
	self.terrainLookupTable[self.harshColor] = PathNode.Type.HARSH;
	self.terrainLookupTable[self.jarringColor] = PathNode.Type.JARRING;

static func GetColorFromNodeType(_nodeType:PathNode.Type) -> Color:
	if(terrainLookupTable.values().has(_nodeType)):
		var color_key:Color = terrainLookupTable.find_key(_nodeType);
		return color_key;
	return Color.WHITE;

func GetTextFromFile() -> PackedStringArray:
	var lines:PackedStringArray = [];
	var file:Object = FileAccess.open(textPath, FileAccess.READ);
	
	if(file != null):
		var text_asset:String = file.get_as_text();
		var delimiter:String = "\n";
		lines = text_asset.split(delimiter, false)
	else:
		print_debug("MAPDATA - GetTextFromFile Error: invalid file");
	
	return lines;

func SetDimension(_textLines:PackedStringArray) -> void:
	height = _textLines.size();
	width = _textLines[0].length();
	
	for line in _textLines:
		if(line.length() > self.width):
			width = line.length();

func TranslateMap() -> void:
	width = 0;
	height = 0;
	var lines:PackedStringArray = GetTextFromFile();
	SetDimension(lines);
	
	data.resize(width);
	for column in range(self.width):
		data[column].resize(self.height);
	
	for x in range(self.width):
		for y in range(self.height):
			if(lines[y].length() > x):
				data[x][y] = lines[y][x].to_int();
			else:
				data[x][y] = 0;
