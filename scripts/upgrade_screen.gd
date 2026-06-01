extends Control

var upgrade_points = 4
var stat_points = {"AttackSpeed": 0, "AttackDamage": 0, "HP": 0, "ShipSpeed": 0}
var total_spent = {"AttackSpeed": 0, "AttackDamage": 0, "HP": 0, "ShipSpeed": 0}

var current_perk = ""
var reroll_cost = 0 

func _ready():
	$Ready.disabled = true
	check_ready()
	
var upgrades = {
	"AttackSpeed": 0.035,
	"AttackDamage": 15,
	"HP": 50,
	"ShipSpeed": 15,
}
	
func showw():
	upgrade_points = 3
	if Global.bait_them:
		upgrade_points += 2
	var player = get_tree().get_first_node_in_group("player")
	update_all_labels()
	update_buttons()
	update_points_label()
	visible = true
	Global.music_player.stream_paused = Global.muted
	check_ready()
	reroll_cost = 0
	var world = get_tree().get_first_node_in_group("world")
	var show_perk = world.current_wave % 2 != 0
	
	var perk_card = $VBoxContainer/HBoxContainer3big/Control
	if perk_card:
		perk_card.visible = show_perk
	
	if show_perk:
		current_perk = Global.get_random_perk()
		update_perk_card()

func update_all_labels():
	var player = get_tree().get_first_node_in_group("player")
	$VBoxContainer/HBoxContainer6stat/StatCard1/Control/ASValue.text = str(player.attack_speed)
	$VBoxContainer/HBoxContainer6stat/StatCard2/Control/ADValue.text = str(player.attack_damage)
	$VBoxContainer/HBoxContainer6stat/StatCard4/Control/HPValue.text = str(player.hp)
	$VBoxContainer/HBoxContainer6stat/StatCard5/Control/SSValue.text = str(player.speed)
	$VBoxContainer/HBoxContainer6stat/StatCard1/Control/PointsSpentAS.text = str(stat_points["AttackSpeed"])
	$VBoxContainer/HBoxContainer6stat/StatCard2/Control/PointsSpentAD.text = str(stat_points["AttackDamage"])
	$VBoxContainer/HBoxContainer6stat/StatCard4/Control/PointsSpentHP.text = str(stat_points["HP"])
	$VBoxContainer/HBoxContainer6stat/StatCard5/Control/PointsSpentSS.text = str(stat_points["ShipSpeed"])
	for stat in stat_points:
		pass

func on_plus_pressed(stat_name):
	if upgrade_points <= 0:
		return
	if stat_points[stat_name] >= 2:
		return
	
	var player = get_tree().get_first_node_in_group("player")
	var caps = get_caps()
	
	if stat_name == "AttackSpeed" and player.attack_speed - (stat_points["AttackSpeed"] + 1) * upgrades["AttackSpeed"] <= caps["AttackSpeed"]:
		return
	if stat_name == "AttackDamage" and player.attack_damage + (stat_points["AttackDamage"] + 1) * upgrades["AttackDamage"] > caps["AttackDamage"]:
		return
	if stat_name == "HP" and player.max_hp + (stat_points["HP"] + 1) * upgrades["HP"] > caps["HP"]:
		return
	if stat_name == "ShipSpeed" and player.speed + (stat_points["ShipSpeed"] + 1) * upgrades["ShipSpeed"] > caps["ShipSpeed"]:
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
	var caps = get_caps()
	
	$VBoxContainer/HBoxContainer6stat/StatCard1/Control/ASValue.text = str(snappedf(player.attack_speed - stat_points["AttackSpeed"] * upgrades["AttackSpeed"], 0.01))
	$VBoxContainer/HBoxContainer6stat/StatCard2/Control/ADValue.text = str(player.attack_damage + stat_points["AttackDamage"] * upgrades["AttackDamage"])
	$VBoxContainer/HBoxContainer6stat/StatCard4/Control/HPValue.text = str(player.hp + stat_points["HP"] * upgrades["HP"])
	$VBoxContainer/HBoxContainer6stat/StatCard5/Control/SSValue.text = str(player.speed + stat_points["ShipSpeed"] * upgrades["ShipSpeed"])
	$VBoxContainer/HBoxContainer6stat/StatCard1/Control/PointsSpentAS.text = str(total_spent["AttackSpeed"] + stat_points["AttackSpeed"])
	$VBoxContainer/HBoxContainer6stat/StatCard2/Control/PointsSpentAD.text = str(total_spent["AttackDamage"] + stat_points["AttackDamage"])
	$VBoxContainer/HBoxContainer6stat/StatCard4/Control/PointsSpentHP.text = str(total_spent["HP"] + stat_points["HP"])
	$VBoxContainer/HBoxContainer6stat/StatCard5/Control/PointsSpentSS.text = str(total_spent["ShipSpeed"] + stat_points["ShipSpeed"])
	
	var cards = ["StatCard1", "StatCard2", "StatCard4", "StatCard5"]
	var stats = ["AttackSpeed", "AttackDamage", "HP", "ShipSpeed"]
	
	for i in cards.size():
		var card = $VBoxContainer/HBoxContainer6stat.get_node(cards[i])
		var plus = card.get_node("Control/+")
		var minus = card.get_node("Control/-")
		
		minus.modulate = Color(1, 1, 1, 0.3) if stat_points[stats[i]] <= 0 else Color(1, 1, 1, 1)
		minus.disabled = stat_points[stats[i]] <= 0
		
		var can_plus = upgrade_points > 0 and stat_points[stats[i]] < 2
		
		if stats[i] == "AttackSpeed" and player.attack_speed - (stat_points[stats[i]] + 1) * upgrades[stats[i]] <= caps["AttackSpeed"]:
			can_plus = false
		if stats[i] == "AttackDamage" and caps["AttackDamage"] != INF and player.attack_damage + (stat_points[stats[i]] + 1) * upgrades[stats[i]] > caps["AttackDamage"]:
			can_plus = false
		if stats[i] == "HP" and caps["HP"] != INF and player.max_hp + (stat_points[stats[i]] + 1) * upgrades[stats[i]] > caps["HP"]:
			can_plus = false
		if stats[i] == "ShipSpeed" and player.speed + (stat_points[stats[i]] + 1) * upgrades[stats[i]] > caps["ShipSpeed"]:
			can_plus = false
		
		plus.modulate = Color(1, 1, 1, 1) if can_plus else Color(1, 1, 1, 0.3)
		plus.disabled = not can_plus
		
func check_ready():
	var can_spend = false
	if upgrade_points > 0:
		var player = get_tree().get_first_node_in_group("player")
		var caps = get_caps()
		var stats = ["AttackSpeed", "AttackDamage", "HP", "ShipSpeed"]
		for stat in stats:
			if stat_points[stat] >= 2:
				continue
			if stat == "AttackSpeed" and player.attack_speed - (stat_points[stat] + 1) * upgrades[stat] <= caps["AttackSpeed"]:
				continue
			if stat == "AttackDamage" and caps["AttackDamage"] != INF and player.attack_damage + (stat_points[stat] + 1) * upgrades[stat] > caps["AttackDamage"]:
				continue
			if stat == "HP" and caps["HP"] != INF and player.max_hp + (stat_points[stat] + 1) * upgrades[stat] > caps["HP"]:
				continue
			if stat == "ShipSpeed" and player.speed + (stat_points[stat] + 1) * upgrades[stat] > caps["ShipSpeed"]:
				continue
			can_spend = true
			break
	
	$Ready.disabled = upgrade_points > 0 and can_spend
	update_points_label()

func on_ready_pressed():
	Global.click_player.play()
	apply_upgrades()
	
	if current_perk != "":
		Global.apply_perk(current_perk)
		apply_perk_effect(current_perk)
		current_perk = ""
	var player = get_tree().get_first_node_in_group("player")
	player.hp = player.max_hp
	
	var label = get_tree().get_first_node_in_group("lives_label")
	if label:
		label.text = "HP: " + str(player.hp) + "/" + str(player.max_hp)
	visible = false
	Global.set_music_volume(1.0)
	Global.music_player.stream_paused = Global.muted
	get_tree().get_first_node_in_group("world").end_upgrade_sequence()

func apply_upgrades():
	var player = get_tree().get_first_node_in_group("player")
	var caps = get_caps()
	
	player.hp += stat_points["HP"] * upgrades["HP"]
	player.max_hp += stat_points["HP"] * upgrades["HP"]
	player.hp = min(player.hp, caps["HP"])
	player.max_hp = min(player.max_hp, caps["HP"])
	
	player.attack_speed -= stat_points["AttackSpeed"] * upgrades["AttackSpeed"]
	player.attack_speed = max(player.attack_speed, caps["AttackSpeed"])
	
	player.attack_damage += stat_points["AttackDamage"] * upgrades["AttackDamage"]
	player.attack_damage = min(player.attack_damage, caps["AttackDamage"])
	
	player.speed += stat_points["ShipSpeed"] * upgrades["ShipSpeed"]
	player.speed = min(player.speed, caps["ShipSpeed"])
	
	Global.player_hp = player.hp
	Global.player_max_hp = player.max_hp
	Global.player_speed = player.speed
	Global.player_attack_speed = player.attack_speed
	Global.player_attack_damage = player.attack_damage
	
	for stat in stat_points:
		total_spent[stat] += stat_points[stat]
	stat_points = {"AttackSpeed": 0, "AttackDamage": 0, "HP": 0, "ShipSpeed": 0}
	upgrade_points = 4
	update_buttons()
	
func _on_StatCard1_plus_pressed():
	Global.click_player.play()
	on_plus_pressed("AttackSpeed")

func _on_StatCard1_minus_pressed():
	Global.click_player.play()
	on_minus_pressed("AttackSpeed")
	
func _on_StatCard2_plus_pressed():
	Global.click_player.play()
	on_plus_pressed("AttackDamage")

func _on_StatCard2_minus_pressed():
	Global.click_player.play()
	on_minus_pressed("AttackDamage")
	
func _on_StatCard4_plus_pressed():
	Global.click_player.play()
	on_plus_pressed("HP")

func _on_StatCard4_minus_pressed():
	Global.click_player.play()
	on_minus_pressed("HP")
	
func _on_StatCard5_plus_pressed():
	Global.click_player.play()
	on_plus_pressed("ShipSpeed")

func _on_StatCard5_minus_pressed():
	Global.click_player.play()
	on_minus_pressed("ShipSpeed")
	
func get_caps():
	if Global.endless_mode:
		return {
			"AttackSpeed": 0.25,
			"AttackDamage": INF,
			"HP": INF,
			"ShipSpeed": 750,
		}
	else:
		return {
			"AttackSpeed": 0.5,
			"AttackDamage": 250,
			"HP": 900,
			"ShipSpeed": 500,
		}
		
var perk_descriptions = {
	"Pierce": "Bullets pierce enemies\n(40% dmg after first hit)",
	"Shrinker": "Reduces ship size\nand hitbox by 25%",
	"BiggerGuns": "Increases bullet\nsize by 50%",
	"GlassCannon": "Bullet damage +50%\nDamage taken +100%",
	"SecondaryTurrets": "2 extra bullets at\n30° angle (25% dmg)",
	"ActiveCamo": "15% chance to\nevade damage",
	"BetterMaterials": "Reduces all\ndamage by 25",
	"BulletShield": "Destroys bullets around\nship every 15 sec",
	"BaitThem": "Damage taken +100%\n+2 upgrade points/wave",
	"RepairDrones": "+10 HP on kill\n(not from boss drones)",
	"ExplosiveRounds": "Enemies explode on\ndeath (100 dmg)",
	"HydraMK1": "25% chance to shoot\n2 bullets (50% dmg)",
	"LastStand": "At 10% HP: clear bullets,\n2sec invincibility+speed",
	"Ricochet": "25% chance bullets\nricochet (100 fixed dmg)",
	"Focus": "Standing still 2sec\ngives +25% damage"
}

func update_perk_card():
	var name_label = get_tree().get_first_node_in_group("perk_name_label")
	var desc_label = get_tree().get_first_node_in_group("perk_desc_label")
	var cost_label = get_tree().get_first_node_in_group("perk_cost_label")
	print("desc_label: ", desc_label)
	print("current_perk: ", current_perk)
	print("description: ", perk_descriptions.get(current_perk, "NOT FOUND"))
	
	if current_perk == "":
		if name_label: name_label.text = "No perks available"
		if desc_label: desc_label.text = ""
		return
	
	if name_label: name_label.text = current_perk
	if desc_label: desc_label.text = perk_descriptions.get(current_perk, "")
	if cost_label: cost_label.text = "Free" if reroll_cost == 0 else str(reroll_cost) + " pt"

func _on_reroll_pressed():
	if reroll_cost > 0 and upgrade_points < reroll_cost:
		return
	upgrade_points -= reroll_cost
	reroll_cost = 1
	current_perk = Global.get_random_perk(reroll_cost > 1)
	update_perk_card()
	update_buttons()
	check_ready()

func _on_take_perk_pressed():
	if current_perk == "":
		return
	Global.apply_perk(current_perk)
	apply_perk_effect(current_perk)
	current_perk = ""
	update_perk_card()
	
func apply_perk_effect(perk):
	var player = get_tree().get_first_node_in_group("player")
	match perk:
		"Shrinker":
			player.scale = Vector2(0.75, 0.75)
		"BiggerGuns":
			Global.bullet_scale = 1.5
		"GlassCannon":
			player.attack_damage *= 1.5
			Global.glass_cannon = true
		"BetterMaterials":
			Global.damage_reduction = 25
		"BaitThem":
			Global.bait_them = true
			Global.extra_upgrade_points += 2
		"ActiveCamo":
			Global.active_camo = true
		"SecondaryTurrets":
			Global.secondary_turrets = true
		"Pierce":
			Global.pierce = true
		"Ricochet":
			Global.ricochet = true
		"ExplosiveRounds":
			Global.explosive_rounds = true
		"HydraMK1":
			Global.hydra = true
		"RepairDrones":
			Global.repair_drones = true
		"LastStand":
			Global.last_stand = true
		"Focus":
			Global.focus = true
		"BulletShield":
			Global.bullet_shield = true
