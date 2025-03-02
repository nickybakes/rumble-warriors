extends Resource
class_name R_TargetList

var players = [] as Array[R_TargetData];
var breakables = [] as Array[R_TargetData];
var enemies = [] as Array[R_TargetData];

#func _to_string() -> String:
	#return "inField: %s, squaredDistance: %s, angle: %s" % [inField, squaredDistance, angle];
