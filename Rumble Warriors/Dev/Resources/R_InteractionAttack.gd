extends R_Interaction
class_name R_InteractionAttack

var attack := Enums.ATTACK;
var targets : R_TargetList;

func _init(_targets : R_TargetList, playerId : int, interactNum : int) -> void:
	super(playerId, interactNum);
	type = Enums.INTERACTION.Attack;
	targets = _targets;

func _to_string() -> String:
	return "timeStamp: %s, type: %s" % [timeStamp, type];

func _to_dict() -> Dictionary:
	var dict = super._to_dict();
	dict["attack"] = attack;
	dict["targets"] = targets.get_property_list();
	return dict;
