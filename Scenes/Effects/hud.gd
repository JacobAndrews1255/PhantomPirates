extends Node2D

@onready var player = get_parent()
@onready var ammoType = "cannon"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	get_hearts()
	get_weapon()
	get_ammo()
	get_money()


func get_hearts():
	if player.health != player.maxHealth:
		$CanvasLayer/Heart5.hide()
		if player.health/player.maxHealth <= .75:
			$CanvasLayer/Heart4.hide()
			if player.health/player.maxHealth <= .50:
				$CanvasLayer/Heart3.hide()
				if player.health/player.maxHealth <= .25:
					$CanvasLayer/Heart2.hide()
					if player.health/player.maxHealth <= 0:
						$CanvasLayer/Heart1.hide()


func get_weapon():
	if player.attacks == 1:
		ammoType = "cannon"
		$CanvasLayer/Cannon1.show()
		if player.cannons == 2:
			$CanvasLayer/Cannon2.show()
		if player.cannons == 3:
			$CanvasLayer/Cannon3.show()
	else:
		$CanvasLayer/Cannon2.hide()
		$CanvasLayer/Cannon3.hide()
	
	if player.attacks == 2:
		ammoType = "cannon"
		$CanvasLayer/Cannon1.show()
		if player.cannons == 2:
			$CanvasLayer/Cannon4.show()
		if player.cannons == 3:
			$CanvasLayer/Cannon5.show()
	else:
		$CanvasLayer/Cannon4.hide()
		$CanvasLayer/Cannon5.hide()
	
	if player.attacks == 3:
		ammoType = "bolas"
		$CanvasLayer/Cannon1.hide()
		$CanvasLayer/Bolas.show()
	else:
		$CanvasLayer/Bolas.hide()
	
	if player.attacks == 4:
		ammoType = "magic"
		$CanvasLayer/Cannon1.hide()
		$CanvasLayer/Magic.show()
	else:
		$CanvasLayer/Magic.hide()
	
	if player.attacks == 5:
		ammoType = "bomb"
		$CanvasLayer/Cannon1.hide()
		$CanvasLayer/Bomb.show()
	else:
		$CanvasLayer/Bomb.hide()

func get_ammo():
	var temp = 0
	if ammoType == "cannon":
		if player.cannonBallsAmmo < 10:
			$CanvasLayer/H/A1.frame = 26
		elif player.cannonBallsAmmo < 20:
			temp = 10
			$CanvasLayer/H/A1.frame = 27
		elif player.cannonBallsAmmo < 30:
			temp = 20
			$CanvasLayer/H/A1.frame = 28
		elif player.cannonBallsAmmo < 40:
			temp = 30
			$CanvasLayer/H/A1.frame = 29
		elif player.cannonBallsAmmo < 50:
			temp = 40
			$CanvasLayer/H/A1.frame = 30
		$CanvasLayer/H/A2.frame = 26 + player.cannonBallsAmmo - temp
	elif ammoType == "bolas":
		if player.bolasAmmo < 10:
			$CanvasLayer/H/A1.frame = 26
		elif player.bolasAmmo < 20:
			temp = 10
			$CanvasLayer/H/A1.frame = 27
		elif player.bolasAmmo < 30:
			temp = 20
			$CanvasLayer/H/A1.frame = 28
		elif player.bolasAmmo < 40:
			temp = 30
			$CanvasLayer/H/A1.frame = 29
		elif player.bolasAmmo < 50:
			temp = 40
			$CanvasLayer/H/A1.frame = 30
		$CanvasLayer/H/A2.frame = 26 + player.bolasAmmo - temp
	elif ammoType == "magic":
		if player.magicAmmo < 10:
			$CanvasLayer/H/A1.frame = 26
		elif player.magicAmmo < 20:
			temp = 10
			$CanvasLayer/H/A1.frame = 27
		elif player.magicAmmo < 30:
			temp = 20
			$CanvasLayer/H/A1.frame = 28
		elif player.magicAmmo < 40:
			temp = 30
			$CanvasLayer/H/A1.frame = 29
		elif player.magicAmmo < 50:
			temp = 40
			$CanvasLayer/H/A1.frame = 30
		$CanvasLayer/H/A2.frame = 26 + player.magicAmmo - temp
	elif ammoType == "bomb":
		if player.bombAmmo < 10:
			$CanvasLayer/H/A1.frame = 26
		elif player.bombAmmo < 20:
			temp = 10
			$CanvasLayer/H/A1.frame = 27
		elif player.bombAmmo < 30:
			temp = 20
			$CanvasLayer/H/A1.frame = 28
		elif player.bombAmmo < 40:
			temp = 30
			$CanvasLayer/H/A1.frame = 29
		elif player.bombAmmo < 50:
			temp = 40
			$CanvasLayer/H/A1.frame = 30
		$CanvasLayer/H/A2.frame = 26 + player.bombAmmo - temp

func get_money():
	var temp = 0
	if player.money < 10:
		$CanvasLayer/H/M1.frame = 26
	elif player.money < 20:
		temp = 10
		$CanvasLayer/H/M1.frame = 27
	elif player.money < 30:
		temp = 20
		$CanvasLayer/H/M1.frame = 28
	elif player.money < 40:
		temp = 30
		$CanvasLayer/H/M1.frame = 29
	elif player.money < 50:
		temp = 40
		$CanvasLayer/H/M1.frame = 30
	$CanvasLayer/H/M2.frame = 26 + player.money - temp
