extends Node
class_name Event

"""
Class to be used by Grim to represent an event.
This should be instanced on another parent class that can provide the
required dependencies.
"""

export var id: String = "Event"
export var intensity: float = 0.0
export var deps := {}


func _init(properties: Dictionary = { "id": "event", "intensity": 0}) -> void:
	id = properties.id
	intensity = properties.intensity


func action() -> Dictionary:
	return deps


func inject(_deps: Dictionary):
	self.deps = _deps
