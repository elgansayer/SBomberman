extends Control

@export var ControlStagePath: NodePath
var ControlStage: Control

@export var ControlRulesPath: NodePath
var ControlRules: Control

func _ready():
	ControlStage = get_node(ControlStagePath)
	ControlRules = get_node(ControlRulesPath)
	
func _on_btn_battle_pressed():	
	ControlRules.visible = false
	ControlStage.visible = true


func _on_btn_rules_pressed():
	ControlRules.visible = true
	ControlStage.visible = false
