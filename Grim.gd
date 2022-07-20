extends Node
class_name Grim

"""
Welcome to Grim.gd!
This is a utility to dynamically register events and callbacks to be used
procedurally in a game according to an intensity curve!
"""

var timer := Timer.new()

var event_pool := {}
var flasks := {}

export var curve: Curve
export var step: float
export var interval: float setget set_interval
export var intensity_range: float


func _ready():
	add_child(timer)
	print("test")


# class constructor
func _init(properties: Dictionary = {}):
	if properties.empty():
		return
	self.curve = properties.curve
	self.step = properties.step
	self.interval = properties.interval
	self.intensity_range = properties.intensity_range


# function to register an event into the grim hashmap
# and to group it into the closest flask using group()
func register_event(event: Event, deps: Dictionary) -> void:
	event.inject(deps)
	event_pool[event.id] = event
	group(event)


# function to run the callback of an event given it's key
func run(event: String) -> Dictionary:
	return event_pool[event].action()


# setter function to set the interval of the timer
func set_interval(new_interval: float) -> void:
	timer.wait_time = new_interval


# function to initialize the grim system
func grim_init() -> void:
	timer.wait_time = interval
	grim_loop()


# the main grim logic loop, called every interval
func grim_loop(acc: float = 0) -> void:
	# check if end of curve is reached
	if acc >= 1:
		return

	# wait for the next interval
	timer.start()
	yield(timer, "timeout")

	# calculate current intensity
	acc = acc + step
	var value = curve.interpolate(acc)

	# run the callback of a random event in the closest flask
	var flask = closest_flask(value)
	run_flask(flask)

	# recurse
	grim_loop(acc)


#
func run_flask(flask: Dictionary) -> void:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var event = flask.events[rng.randi_range(0, flask.events.size() - 1)]
	event.run()


# function that returns true if an event is in the range of a given point, according with the intensity range
func in_range(event: Event, point: float) -> bool:
	var low: float = point - intensity_range
	var high: float = point + intensity_range
	return event.intensity >= low and event.intensity <= high


# reset the flasks and regroup them
func group_all() -> void:
	# reset the flasks
	flasks = {}
	for event in event_pool.values():
		group(event)


# add the event to the appropriate flask
func group(event: Event) -> void:
	for group in flasks.keys():
		if in_range(event, group):
			flasks[group].append(event)
			return
	flasks[event.intensity] = [event]


# function to get the closest flask to an intensity
func closest_flask(value: float) -> float:
	var closest: float = 0
	var closest_diff: float = value
	for flask in flasks.keys():
		var diff: float = abs(flask - value)
		if diff > intensity_range:
			continue
		if diff < closest_diff:
			closest = flask
			closest_diff = diff
	return closest
