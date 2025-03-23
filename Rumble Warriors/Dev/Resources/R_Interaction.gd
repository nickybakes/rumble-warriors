extends Resource
class_name R_Interaction

var timeStamp := 0;
var type := Enums.INTERACTION.Attack;
var interactionId := "0";
var latency := 0;

func _init(playerId : int, interactNum : int) -> void:
	interactionId = str(playerId) + "-" + str(interactNum);

func _to_string() -> String:
	return "timeStamp: %s, type: %s" % [timeStamp, type];

func _to_dict() -> Dictionary:
	return {
		"timeStamp": timeStamp,
		"interactionId": interactionId,
		"type": type,
	};
