extends Node
class_name TimeManager;

var decimalCollector : float = 0.0;
var latencyArray = [];
var latency : float = 0;
var deltaLatency : float = 0;

var clock : int = 0;

func _ready() -> void:
	fetchServerTime();
	var timer = Timer.new();
	timer.wait_time = .5;
	timer.autostart = true;
	timer.timeout.connect(determineLatency);
	self.add_child(timer);
	pass;
	
func _physics_process(delta: float) -> void:
	var deltaMsec = delta * 1000;
	var deltaMsecInt = int(deltaMsec);
	clock += deltaMsecInt + deltaLatency;
	deltaLatency = 0;
	decimalCollector += deltaMsec - deltaMsecInt;
	if(decimalCollector >= 1.00):
		clock += 1;
		decimalCollector -= 1.00;
	pass;	


func receiveServerTime(serverTicksMsec : int, clientTicksMsec : int):
	latency = (Time.get_ticks_msec() - clientTicksMsec) / 2;
	clock = serverTicksMsec + latency;
	
func receiveLatency(clientTicksMsec : int):
	latencyArray.append((Time.get_ticks_msec() - clientTicksMsec) / 2);
	if(latencyArray.size() == 9):
		var totalLatency = 0;
		latencyArray.sort();
		var midPoint = latencyArray[4];
		for i in range(latencyArray.size()-1, -1, -1):
			if(latencyArray[i] > (2 * midPoint) and latencyArray[i] > 20):
				latencyArray.remove_at(i);
			else:
				totalLatency += latencyArray[i];
		deltaLatency = (totalLatency / latencyArray.size()) - latency;
		latency = totalLatency / latencyArray.size();
		latencyArray.clear();
	pass;
	
func fetchServerTime():
	Network.rpc_id(1, "fetchServerTime", Time.get_ticks_msec());
	
func determineLatency():
	Network.rpc_id(1, "determineLatency", Time.get_ticks_msec());
	pass;
