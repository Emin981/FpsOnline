extends Node

var peer : NetworkedMultiplayerENet
var port : int = 5555
var max_player : int = 4
var my_info = {"username":"username"}
var players_info = {}

onready var world = preload("res://scene/World.tscn")
onready var player = preload("res://instance/player.tscn")

func _ready():
	get_tree().connect("network_peer_connected",self,"user_connected")
	get_tree().connect("network_peer_disconnected",self,"user_disconnected")

func user_connected(peer_id):
	rpc_id(peer_id,"register_player",my_info)

func user_disconnected(peer_id):
	players_info.erase(peer_id)

remote func register_player(info):
	players_info[sender_id()] = info

func sender_id():
	return get_tree().get_rpc_sender_id()

func host_game():
	peer = NetworkedMultiplayerENet.new()
	peer.create_server(port,max_player)
	get_tree().network_peer = peer

func join_game(ip_address):
	peer = NetworkedMultiplayerENet.new()
	peer.create_client(ip_address,port)
	get_tree().network_peer = peer

func start():
	start_game()
	for i in players_info:
		rpc_id(i,"start_game")

remote func start_game():
	get_node("/root/MainMenu").hide()
	var selfID = get_tree().get_network_unique_id()
	var world_instance = world.instance()
	get_tree().get_root().add_child(world_instance)
	
	var pl = player.instance()
	pl.set_name(str(selfID))
	pl.set_network_master(selfID)
	pl.transform.origin = Vector3(rand_range(0,100),3,rand_range(0,100))
	get_node("/root/World/players").add_child(pl)
	
	for p in players_info:
		var pl_ = player.instance()
		pl_.set_name(str(p))
		pl_.set_network_master(p)
		pl_.transform.origin = Vector3(rand_range(0,100),3,rand_range(0,100))
		get_node("/root/World/players").add_child(pl_)

