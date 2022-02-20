extends KinematicBody2D


# Sent to everyone else
remotesync func do_explosion():
	# #print("do explosion")
	$"AnimationPlayer".play("explode")


# Received by owner of the rock
master func exploded(by_who):
	rpc("do_explosion")  # Re-sent to puppet rocks
	$"../../Score".rpc("increase_score", by_who)
	do_explosion()


# Received by owner of the rock
master func explode():
	#print("explode rock ", str(is_network_master()))
	rpc("do_explosion")  # Re-sent to puppet rocks


func get_class():
	return "Rock"
