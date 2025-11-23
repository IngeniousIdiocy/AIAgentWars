class_name FactionsConfig
extends Node

const FACTION_KPMG := "KPMG"
const FACTION_PWC := "PWC"
const FACTION_EY := "EY"
const FACTION_DELOITTE := "DELOITTE"
const FACTION_ACCENTURE := "ACCENTURE"

const BIG4_IDS := [FACTION_KPMG, FACTION_PWC, FACTION_EY, FACTION_DELOITTE]
const NEUTRAL_IDS := [FACTION_ACCENTURE]

const FACTION_DATA := {
	FACTION_KPMG: {
		"name": "KPMG",
		"color": Color(0.0, 0.3, 0.7), # KPMG blue
		"is_neutral": false,
	},
	FACTION_PWC: {
		"name": "PwC",
		"color": Color(1.0, 0.55, 0.1), # PwC orange
		"is_neutral": false,
	},
	FACTION_EY: {
		"name": "EY",
		"color": Color(0.95, 0.85, 0.1), # EY yellow
		"is_neutral": false,
	},
	FACTION_DELOITTE: {
		"name": "Deloitte",
		"color": Color(0.95, 0.95, 0.95), # Deloitte white
		"is_neutral": false,
	},
	FACTION_ACCENTURE: {
		"name": "Accenture",
		"color": Color(0.7, 0.2, 0.7),
		"is_neutral": true,
	},
}
