extends Control

onready var server_ip = $CenterContainer/VBoxContainer/serveredit

func _on_host_btn_pressed():
	Network.host_game()


func _on_join_btn_pressed():
	Network.join_game(server_ip.text)


func _on_start_btn_pressed():
	Network.start()
