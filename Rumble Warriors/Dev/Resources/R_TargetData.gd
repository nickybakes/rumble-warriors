extends Resource
class_name R_TargetData

var inField := false;
var id := 0;
var distance := 0.0;
var angle := -1.0;

## This score is used to determine which of many targets should the
## player track onto. Larger number is better.
var trackingScore := 0.0;


func _to_string() -> String:
	return "inField: %s, distance: %s, angle: %s, id: %s" % [inField, distance, angle, id];
