extends Resource
class_name R_TargetInFieldData

var inField := false;
var squaredDistance := 99999999999.0;
var angle := -1.0;


func _to_string() -> String:
	return "inField: %s, squaredDistance: %s, angle: %s" % [inField, squaredDistance, angle];
