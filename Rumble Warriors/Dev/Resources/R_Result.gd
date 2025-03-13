extends Resource
class_name R_Result

var timeStamp := 0;
var type := Enums.RESULT.AttackSuccess;
var interactionId := "0";
var interactionIdToCorrect := "0";

func _init(playerId : int, interactNum : int) -> void:
	interactionId = str(playerId) + "-" + str(interactNum);
	inst_to_dict(self);
	

func _to_string() -> String:
	return "timeStamp: %s, type: %s" % [timeStamp, type];
