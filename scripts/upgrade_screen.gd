extends Control

var upgrade_points = 3
var stat_points = {"AttackSpeed": 0, "AttackDamage": 0, "BulletSpeed": 0, "HP": 0, "ShipSpeed": 0, "StatusResist": 0}
var total_spent = {"AttackSpeed": 0, "AttackDamage": 0, "BulletSpeed": 0, "HP": 0, "ShipSpeed": 0, "StatusResist": 0}

func _ready():
	$Ready.disabled = true
	
var upgrades = {
	"AttackSpeed": 0.015,
	"AttackDamage": 10,
	"BulletSpeed": 40,
	"HP": 25,
	"ShipSpeed": 25,
	"StatusResist": 5
}
	
func showw():
	update_all_labels()
	visible = true

func update_all_labels():
	var player = get_tree().get_first_node_in_group("player")
	$VBoxContainer/HBoxContainer6stat/StatCard1/ASValue.text = str(player.attack_speed)
	$VBoxContainer/HBoxContainer6stat/StatCard2/ADValue.text = str(player.attack_damage)
	$VBoxContainer/HBoxContainer6stat/StatCard3/BSValue.text = str(player.bullet_speed)
	$VBoxContainer/HBoxContainer6stat/StatCard4/HPValue.text = str(player.hp)
	$VBoxContainer/HBoxContainer6stat/StatCard5/SSValue.text = str(player.speed)
	$VBoxContainer/HBoxContainer6stat/StatCard6/SRValue.text = "0"
	$VBoxContainer/HBoxContainer6stat/StatCard1/PointsSpentAS.text = str(stat_points["AttackSpeed"])
	$VBoxContainer/HBoxContainer6stat/StatCard2/PointsSpentAD.text = str(stat_points["AttackDamage"])
	$VBoxContainer/HBoxContainer6stat/StatCard3/PointsSpentBS.text = str(stat_points["BulletSpeed"])
	$VBoxContainer/HBoxContainer6stat/StatCard4/PointsSpentHP.text = str(stat_points["HP"])
	$VBoxContainer/HBoxContainer6stat/StatCard5/PointsSpentSS.text = str(stat_points["ShipSpeed"])
	$VBoxContainer/HBoxContainer6stat/StatCard6/PointsSpentSR.text = str(stat_points["StatusResist"])
	for stat in stat_points:
		pass

func on_plus_pressed(stat_name):
	if upgrade_points <= 0:
		return
	stat_points[stat_name] += 1
	upgrade_points -= 1
	update_buttons()
	check_ready()

func on_minus_pressed(stat_name):
	if stat_points[stat_name] <= 0:
		return
	stat_points[stat_name] -= 1
	upgrade_points += 1
	update_buttons()
	check_ready()

func update_buttons():
	var player = get_tree().get_first_node_in_group("player")
	$VBoxContainer/HBoxContainer6stat/StatCard1/ASValue.text = str(snappedf(player.attack_speed - stat_points["AttackSpeed"] * upgrades["AttackSpeed"], 0.01))
	$VBoxContainer/HBoxContainer6stat/StatCard2/ADValue.text = str(player.attack_damage + stat_points["AttackDamage"] * upgrades["AttackDamage"])
	$VBoxContainer/HBoxContainer6stat/StatCard3/BSValue.text = str(player.bullet_speed + stat_points["BulletSpeed"] * upgrades["BulletSpeed"])
	$VBoxContainer/HBoxContainer6stat/StatCard4/HPValue.text = str(player.hp + stat_points["HP"] * upgrades["HP"])
	$VBoxContainer/HBoxContainer6stat/StatCard5/SSValue.text = str(player.speed + stat_points["ShipSpeed"] * upgrades["ShipSpeed"])
	$VBoxContainer/HBoxContainer6stat/StatCard1/PointsSpentAS.text = str(total_spent["AttackSpeed"] + stat_points["AttackSpeed"])
	$VBoxContainer/HBoxContainer6stat/StatCard2/PointsSpentAD.text = str(total_spent["AttackDamage"] + stat_points["AttackDamage"])
	$VBoxContainer/HBoxContainer6stat/StatCard3/PointsSpentBS.text = str(total_spent["BulletSpeed"] + stat_points["BulletSpeed"])
	$VBoxContainer/HBoxContainer6stat/StatCard4/PointsSpentHP.text = str(total_spent["HP"] + stat_points["HP"])
	$VBoxContainer/HBoxContainer6stat/StatCard5/PointsSpentSS.text = str(total_spent["ShipSpeed"] + stat_points["ShipSpeed"])
	$VBoxContainer/HBoxContainer6stat/StatCard6/PointsSpentSR.text = str(total_spent["StatusResist"] + stat_points["StatusResist"])

func check_ready():
	$Ready.disabled = upgrade_points > 0

func on_ready_pressed():
	apply_upgrades()
	var player = get_tree().get_first_node_in_group("player")
	var label = get_tree().get_first_node_in_group("lives_label")
	if label:
		label.text = "HP: " + str(player.hp) + "/" + str(player.max_hp)
	visible = false
	get_tree().paused = false
	get_tree().get_first_node_in_group("world").start_next_wave()

func apply_upgrades():
	var player = get_tree().get_first_node_in_group("player")
	player.hp += stat_points["HP"] * upgrades["HP"]
	player.max_hp += stat_points["HP"] * upgrades["HP"]
	player.speed += stat_points["ShipSpeed"] * upgrades["ShipSpeed"]
	player.attack_speed -= stat_points["AttackSpeed"] * upgrades["AttackSpeed"]
	player.attack_damage += stat_points["AttackDamage"] * upgrades["AttackDamage"]
	player.bullet_speed += stat_points["BulletSpeed"] * upgrades["BulletSpeed"]
	player.armor += stat_points["StatusResist"] * upgrades["StatusResist"]
	for stat in stat_points:
		total_spent[stat] += stat_points[stat]
	stat_points = {"AttackSpeed": 0, "AttackDamage": 0, "BulletSpeed": 0, "HP": 0, "ShipSpeed": 0, "StatusResist": 0}
	upgrade_points = 3
	update_buttons()
	
func _on_StatCard1_plus_pressed():
	on_plus_pressed("AttackSpeed")

func _on_StatCard1_minus_pressed():
	on_minus_pressed("AttackSpeed")
	
func _on_StatCard2_plus_pressed():
	on_plus_pressed("AttackDamage")

func _on_StatCard2_minus_pressed():
	on_minus_pressed("AttackDamage")
	
func _on_StatCard3_plus_pressed():
	on_plus_pressed("BulletSpeed")

func _on_StatCard3_minus_pressed():
	on_minus_pressed("BulletSpeed")
	
func _on_StatCard4_plus_pressed():
	on_plus_pressed("HP")

func _on_StatCard4_minus_pressed():
	on_minus_pressed("HP")
	
func _on_StatCard5_plus_pressed():
	on_plus_pressed("ShipSpeed")

func _on_StatCard5_minus_pressed():
	on_minus_pressed("ShipSpeed")
	
func _on_StatCard6_plus_pressed():
	on_plus_pressed("StatusResist")

func _on_StatCard6_minus_pressed():
	on_minus_pressed("StatusResist")
