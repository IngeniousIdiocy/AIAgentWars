class_name FactionState
extends RefCounted

var id: String
var name: String
var color: Color
var is_neutral: bool
var is_player: bool = false

var credits: float = 0.0
var income_rate: float = 0.0
var hq: Node = null
var towers: Array = []
var hero: Node = null
var target_faction_id: String = ""
