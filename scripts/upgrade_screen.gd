extends Control

var upgrade_points = 4
var stat_points = {"AttackSpeed": 0, "AttackDamage": 0, "BulletSpeed": 0, "HP": 0, "ShipSpeed": 0, "StatusResist": 0}
var total_spent = {"AttackSpeed": 0, "AttackDamage": 0, "BulletSpeed": 0, "HP": 0, "ShipSpeed": 0, "StatusResist": 0}

func _ready():
	$Ready.disabled = true
	check_ready()
	
var upgrades = {
	"AttackSpeed": 0.02,
	"AttackDamage": 10,
	"BulletSpeed": 50,
	"HP": 25,
	"ShipSpeed": 10,
	"StatusResist": 4
}
	
func showw():
	var player = get_tree().get_first_node_in_group("player")
	update_all_labels()
	update_buttons()
	update_points_label()
	visible = true
	Global.music_player.stream_paused = Global.muted
	check_ready()

func update_all_labels():
	var player = get_tree().get_first_node_in_group("player")
	$VBoxContainer/HBoxContainer6stat/StatCard1/ASValue.text = str(player.attack_speed)
	$VBoxContainer/HBoxContainer6stat/StatCard2/ADValue.text = str(player.attack_damage)
	$VBoxContainer/HBoxContainer6stat/StatCard3/BSValue.text = str(player.bullet_speed)
	$VBoxContainer/HBoxContainer6stat/StatCard4/HPValue.text = str(player.hp)
	$VBoxContainer/HBoxContainer6stat/StatCard5/SSValue.text = str(player.speed)
	$VBoxContainer/HBoxContainer6stat/StatCard6/SRValue.text = str(player.armor)
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
	if stat_points[stat_name] >= 2:
		return
	
	var player = get_tree().get_first_node_in_group("player")
	if stat_name == "AttackSpeed" and player.attack_speed - (stat_points["AttackSpeed"] + 1) * upgrades["AttackSpeed"] <= 0.3:
		return
	if stat_name == "AttackDamage" and player.attack_damage + (stat_points["AttackDamage"] + 1) * upgrades["AttackDamage"] > 250:
		return
	if stat_name == "BulletSpeed" and player.bullet_speed + (stat_points["BulletSpeed"] + 1) * upgrades["BulletSpeed"] > 1000:
		return
	if stat_name == "HP" and player.max_hp + (stat_points["HP"] + 1) * upgrades["HP"] > 1000:
		return
	if stat_name == "ShipSpeed" and player.speed + (stat_points["ShipSpeed"] + 1) * upgrades["ShipSpeed"] > 500:
		return
	if stat_name == "StatusResist" and player.armor + (stat_points["StatusResist"] + 1) * upgrades["StatusResist"] > 25:
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
	
func update_points_label():
	var label = get_tree().get_first_node_in_group("points_left_label")
	if label:
		label.text = "Points left: " + str(upgrade_points)

func update_buttons():
	var player = get_tree().get_first_node_in_group("player")
	
	$VBoxContainer/HBoxContainer6stat/StatCard1/ASValue.text = str(snappedf(player.attack_speed - stat_points["AttackSpeed"] * upgrades["AttackSpeed"], 0.01))
	$VBoxContainer/HBoxContainer6stat/StatCard2/ADValue.text = str(player.attack_damage + stat_points["AttackDamage"] * upgrades["AttackDamage"])
	$VBoxContainer/HBoxContainer6stat/StatCard3/BSValue.text = str(player.bullet_speed + stat_points["BulletSpeed"] * upgrades["BulletSpeed"])
	$VBoxContainer/HBoxContainer6stat/StatCard4/HPValue.text = str(player.hp + stat_points["HP"] * upgrades["HP"])
	$VBoxContainer/HBoxContainer6stat/StatCard5/SSValue.text = str(player.speed + stat_points["ShipSpeed"] * upgrades["ShipSpeed"])
	$VBoxContainer/HBoxContainer6stat/StatCard6/SRValue.text = str(player.armor + stat_points["StatusResist"] * upgrades["StatusResist"])
	$VBoxContainer/HBoxContainer6stat/StatCard1/PointsSpentAS.text = str(total_spent["AttackSpeed"] + stat_points["AttackSpeed"])
	$VBoxContainer/HBoxContainer6stat/StatCard2/PointsSpentAD.text = str(total_spent["AttackDamage"] + stat_points["AttackDamage"])
	$VBoxContainer/HBoxContainer6stat/StatCard3/PointsSpentBS.text = str(total_spent["BulletSpeed"] + stat_points["BulletSpeed"])
	$VBoxContainer/HBoxContainer6stat/StatCard4/PointsSpentHP.text = str(total_spent["HP"] + stat_points["HP"])
	$VBoxContainer/HBoxContainer6stat/StatCard5/PointsSpentSS.text = str(total_spent["ShipSpeed"] + stat_points["ShipSpeed"])
	$VBoxContainer/HBoxContainer6stat/StatCard6/PointsSpentSR.text = str(total_spent["StatusResist"] + stat_points["StatusResist"])
	
	var cards = ["StatCard1", "StatCard2", "StatCard3", "StatCard4", "StatCard5", "StatCard6"]
	var stats = ["AttackSpeed", "AttackDamage", "BulletSpeed", "HP", "ShipSpeed", "StatusResist"]
	
	for i in cards.size():
		var card = $VBoxContainer/HBoxContainer6stat.get_node(cards[i])
		var plus = card.get_node("+")
		var minus = card.get_node("-")
		
		minus.modulate = Color(1, 1, 1, 0.3) if stat_points[stats[i]] <= 0 else Color(1, 1, 1, 1)
		
		var can_plus = upgrade_points > 0 and stat_points[stats[i]] < 2
		
		if stats[i] == "AttackSpeed" and player.attack_speed - (stat_points[stats[i]] + 1) * upgrades[stats[i]] <= 0.4:
			can_plus = false
		if stats[i] == "AttackDamage" and player.attack_damage + (stat_points[stats[i]] + 1) * upgrades[stats[i]] > 250:
			can_plus = false
		if stats[i] == "BulletSpeed" and player.bullet_speed + (stat_points[stats[i]] + 1) * upgrades[stats[i]] > 1000:
			can_plus = false
		if stats[i] == "HP" and player.max_hp + (stat_points[stats[i]] + 1) * upgrades[stats[i]] > 1000:
			can_plus = false
		if stats[i] == "ShipSpeed" and player.speed + (stat_points[stats[i]] + 1) * upgrades[stats[i]] > 500:
			can_plus = false
		if stats[i] == "StatusResist" and player.armor + (stat_points[stats[i]] + 1) * upgrades[stats[i]] > 25:
			can_plus = false
	
		plus.modulate = Color(1, 1, 1, 1) if can_plus else Color(1, 1, 1, 0.3)

func check_ready():
	$Ready.disabled = upgrade_points > 0
	update_points_label()
	

func on_ready_pressed():
	apply_upgrades()
	var player = get_tree().get_first_node_in_group("player")
	var label = get_tree().get_first_node_in_group("lives_label")
	if label:
		label.text = "HP: " + str(player.hp) + "/" + str(player.max_hp)
	visible = false
	get_tree().paused = false
	get_tree().get_first_node_in_group("world").start_next_wave()
	Global.music_player.stream_paused = Global.muted

func apply_upgrades():
	var player = get_tree().get_first_node_in_group("player")
	player.hp += stat_points["HP"] * upgrades["HP"]
	player.max_hp += stat_points["HP"] * upgrades["HP"]
	player.hp = min(player.hp, 1000)
	player.max_hp = min(player.max_hp, 1000)
	player.attack_speed -= stat_points["AttackSpeed"] * upgrades["AttackSpeed"]
	player.attack_speed = max(player.attack_speed, 0.3)  
	player.attack_damage += stat_points["AttackDamage"] * upgrades["AttackDamage"]
	player.attack_damage = min(player.attack_damage, 250) 
	player.speed += stat_points["ShipSpeed"] * upgrades["ShipSpeed"]
	player.speed = min(player.speed, 500) 
	player.armor += stat_points["StatusResist"] * upgrades["StatusResist"]
	player.armor = min(player.armor, 32) 
	player.bullet_speed += stat_points["BulletSpeed"] * upgrades["BulletSpeed"]
	Global.player_hp = player.hp
	Global.player_max_hp = player.max_hp
	Global.player_speed = player.speed
	Global.player_attack_speed = player.attack_speed
	Global.player_attack_damage = player.attack_damage
	Global.player_bullet_speed = player.bullet_speed
	Global.player_armor = player.armor
	for stat in stat_points:
		total_spent[stat] += stat_points[stat]
	stat_points = {"AttackSpeed": 0, "AttackDamage": 0, "BulletSpeed": 0, "HP": 0, "ShipSpeed": 0, "StatusResist": 0}
	upgrade_points = 4
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
