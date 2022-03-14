extends Button
 
func _on_btn_create_account_focus_entered():
	get_node("FocusBorder").visible = true

func _on_btn_create_account_focus_exited():
	get_node("FocusBorder").visible = false


func _on_btn_login_focus_entered():
	get_node("FocusBorder").visible = true


func _on_btn_login_focus_exited():
	get_node("FocusBorder").visible = false


func _on_btn_go_focus_entered():
	if self.disabled:
		return
			
	var btn = get_node("FocusBorder")
	btn.visible = true


func _on_btn_go_focus_exited():
	get_node("FocusBorder").visible = false
