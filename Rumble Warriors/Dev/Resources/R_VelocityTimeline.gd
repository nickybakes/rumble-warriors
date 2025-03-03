extends Resource
class_name R_VelocityTimeline

@export var forward : Curve;
@export var upward : Curve;
@export var sideways : Curve;

func _init() -> void:
	pass;
	
func sample(time: float) -> Vector3:
	var x = sideways.sample(time) if sideways != null else 0.0;
	var y = upward.sample(time) if upward != null else 0.0;
	var z = forward.sample(time) if forward != null else 0.0;
	return Vector3(x, y, z);
