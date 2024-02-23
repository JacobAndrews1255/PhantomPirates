extends CharacterBody2D

@onready var maxHealth = 20.0
@onready var maxCannonBallsAmmo = 20
@onready var maxBolasAmmo = 10
@onready var maxMagicAmmo = 6

@export var normalSpeed = 35
@export var health = 20
@export var cannons = 2
@export var rotate = rotation

@onready var fastSpeed = normalSpeed / .5
@onready var speed = normalSpeed
@onready var slowSpeed = normalSpeed * .7

var attacks = 1
var maxAttacks = 5
var cannonBallsAmmo = 49
var bolasAmmo= 10
var magicAmmo = 6
var bombAmmo = 5

var money = 1

var backSplashEffect = preload("res://Scenes/Effects/back_splash_effect.tscn")
var cannon = preload("res://Scenes/Effects/cannon_balls.tscn")
var bomb = preload("res://Scenes/Effects/bomb.tscn")
var bolas = preload("res://Scenes/Effects/bolas.tscn")
var magic = preload("res://Scenes/Effects/magic.tscn")

@onready var backSplashPosition = $backSplashMarker
@onready var RightPosition = $RightShootMarker
@onready var RightTopPosition = $RightTopShootMarker
@onready var RightBottomPosition = $RightBottomShootMarker
@onready var LeftPosition = $LeftShootMarker
@onready var LeftTopPosition = $LeftTopShootMarker
@onready var LeftBottomPosition = $LeftBottomShootMarker

var rotation_speed = 1.9
var rotation_direction = 0
var canBackSplash = true
var canShootLeft = true
var canShootRight = true
var canShootBehind = true
var canRam = true
var boatFrame = 0
var shallowsEntered = false
var dying = false
var confused = false

var hitFrame = 14

func get_input(delta):
	rotation_direction = Input.get_axis("ui_left", "ui_right")
	if Input.is_action_pressed("ui_up"):
		$Boat.frame = 8
		await get_tree().create_timer(.1).timeout
		$Boat.frame = boatFrame + 1
		velocity = transform.x * speed
	else:
		velocity.x = move_toward(velocity.x, 0, .8)
		velocity.y = move_toward(velocity.y, 0, .8)
		$Boat.frame = boatFrame
	rotation += rotation_direction * rotation_speed * delta

func movingAnimations():
	if velocity != Vector2.ZERO and !shallowsEntered:
		$frontSplashAnimation.play()
		$frontSplashAnimation.show()
	else:
		$frontSplashAnimation.hide()
	if velocity != Vector2.ZERO and canBackSplash:
		create_backSplash_instance()
		canBackSplash = false
		await get_tree().create_timer(.5).timeout
		canBackSplash = true
	if speed <= 4:
		canBackSplash = false



func shooting():
	
#	if Input.is_action_just_pressed("ui_accept") and canRam:
#		$RamPlayer.monitoring = true
#		$RamPlayer.monitorable = true
#		speed = fastSpeed
#		canRam = false
#		await get_tree().create_timer(.3).timeout
#		speed = normalSpeed
#		$RamPlayer.monitoring = false
#		$RamPlayer.monitorable = false
#		await get_tree().create_timer(3).timeout
#		canRam = true
	
	
	if Input.is_action_pressed("shoot_left") and canShootLeft:
		$LeftAim.show()
	else:
		$LeftAim.hide()
	if Input.is_action_pressed("shoot_right") and canShootRight:
		$RightAim.show()
	else:
		$RightAim.hide()
	
	if Input.is_action_just_pressed("ui_focus_next"):
		if attacks == maxAttacks:
			attacks = 1
		else:
			attacks += 1
	
	if attacks == 1:
		$LeftTopShootMarker.rotation_degrees = -450
		$LeftBottomShootMarker.rotation_degrees = -450
		$RightTopShootMarker.rotation_degrees = -270
		$RightBottomShootMarker.rotation_degrees = -270
	elif attacks == 2:
		$LeftTopShootMarker.rotation_degrees = -435
		$LeftBottomShootMarker.rotation_degrees = -465
		$RightTopShootMarker.rotation_degrees = -285
		$RightBottomShootMarker.rotation_degrees = -255
	
	if (attacks == 1 or attacks == 2) and cannonBallsAmmo>= cannons:
		for i in range(0 , cannons):
			if Input.is_action_just_released("shoot_left") and canShootLeft:
				cannonBallsAmmo -= cannons
				create_cannonBall_instance("LeftPosition", cannons)
				canShootLeft = false
				await get_tree().create_timer(.75).timeout
				canShootLeft = true
			if Input.is_action_just_released("shoot_right") and canShootRight:
				cannonBallsAmmo -= cannons
				create_cannonBall_instance("RightPosition", cannons)
				canShootRight = false
				await get_tree().create_timer(.75).timeout
				canShootRight = true
	if attacks == 3 and bolasAmmo >= 1:
		if Input.is_action_just_released("shoot_left") and canShootLeft:
			bolasAmmo -= 1
			create_bolas_instance("LeftPosition")
			canShootLeft = false
			await get_tree().create_timer(.75).timeout
			canShootLeft = true
		if Input.is_action_just_released("shoot_right") and canShootRight:
			bolasAmmo -= 1
			create_bolas_instance("RightPosition")
			canShootRight = false
			await get_tree().create_timer(.75).timeout
			canShootRight = true
	if attacks == 4 and magicAmmo >= 1:
		if Input.is_action_just_released("shoot_left") and canShootLeft:
			magicAmmo -= 1
			create_magic_instance("LeftPosition")
			canShootLeft = false
			await get_tree().create_timer(5).timeout
			canShootLeft = true
		if Input.is_action_just_released("shoot_right") and canShootRight:
			magicAmmo -= 1
			create_magic_instance("RightPosition")
			canShootRight = false
			await get_tree().create_timer(5).timeout
			canShootRight = true
	if attacks == 5 and bombAmmo >= 1:
		if (Input.is_action_pressed("shoot_left") or Input.is_action_pressed("shoot_right")) and canShootBehind:
			bombAmmo -= 1
			create_bomb_instance()
			canShootBehind = false
			await get_tree().create_timer(1.5).timeout
			canShootBehind = true

func get_damage(area):
	
	var damage = 1
	if area.to_string().substr(0,10) == "HitboxBomb":
		damage = 3
	if area.to_string().substr(0,9) == "RamPlayer":
		damage = 0
	if area.to_string().substr(0,11) == "HitboxBolas":
		damage = 0
		speed = speed/1.5
	if area.to_string().substr(0,11) == "HitboxMagic":
		damage = 0
		confused = true
		await get_tree().create_timer(5).timeout
		confused = false
		get_parent().get_node("playerShip/MapCamera").ignore_rotation = true
		#rotation_speed = regularRotationSpeed
	
	if damage != 0:
		$BoatHit.show()
		await get_tree().create_timer(.3).timeout
		$BoatHit.hide()
	
	if damage >= health and !dying:
		dying = true
		death()
	else:
		if damage != 0:
			if health/maxHealth >= .75:
				boatFrame = 0
			elif health/maxHealth >= .50:
				boatFrame = 2
			elif health/maxHealth >= .25:
				boatFrame = 4
			elif health/maxHealth >= 0:
				boatFrame = 6
		health = health - damage

func death():
	$Boat.hide()
	$DeathSprite.show()
	$DeathSprite.play()
	await get_tree().create_timer(2).timeout
	if !$DeathSprite.is_playing():
		self.hide()
		canBackSplash = false

func reverseRotation(temp,delta):
	if temp:
		get_parent().get_node("playerShip/MapCamera").ignore_rotation = false
		rotation -= rotation_direction * (rotation_speed * 2) * delta * 2

func _physics_process(delta):

	movingAnimations()
	
	shooting()
	
	reverseRotation(confused,delta)
	
	get_input(delta)
	move_and_collide(velocity * delta)


func create_backSplash_instance():
	var bse = backSplashEffect.instantiate()
	var bse2 = backSplashEffect.instantiate()
	bse.position = backSplashPosition.get_global_position()
	bse2.position = backSplashPosition.get_global_position()
	bse.get_child(0).play()
	bse2.get_child(0).play()
	bse.rotation_degrees = rotation_degrees
	bse2.rotation_degrees = rotation_degrees
	get_tree().get_root().add_child(bse)
	await get_tree().create_timer(.3).timeout
	get_tree().get_root().add_child(bse2)
	await get_tree().create_timer(.3).timeout
	bse.queue_free()
	await get_tree().create_timer(.3).timeout
	bse2.queue_free()

func create_bomb_instance():
	var bombInst = bomb.instantiate()
	get_tree().get_root().add_child(bombInst)
	bombInst.transform = $backSplashMarker.global_transform

func create_cannonBall_instance(direction, cannons):
	var cannon_firing = check_direction_for_cannons(direction, cannons)
	var cannonInst = cannon.instantiate()
	cannonInst.rotation_degrees = rotation_direction
	get_tree().get_root().add_child(cannonInst)
	cannonInst.transform = cannon_firing.global_transform
	if cannons != 1:
		create_cannonBall_instance(direction, cannons-1)

func create_bolas_instance(direction):
	var bolas_firing = check_direction_for_cannons(direction, 1)
	var bolasInst = bolas.instantiate()
	bolasInst.rotation_degrees = rotation_direction
	get_tree().get_root().add_child(bolasInst)
	bolasInst.transform = bolas_firing.global_transform

func create_magic_instance(direction):
	var magic_firing = check_direction_for_cannons(direction, 1)
	var magicInst = magic.instantiate()
	magicInst.rotation_degrees = rotation_direction
	get_tree().get_root().add_child(magicInst)
	magicInst.transform = magic_firing.global_transform

func check_direction_for_cannons(direction, cannons):
	if direction == "LeftPosition":
		if cannons == 1:
			return LeftPosition
		elif cannons == 2:
			return LeftTopPosition
		elif cannons == 3:
			return LeftBottomPosition
		else:
			return LeftPosition
	if direction == "RightPosition":
		if cannons == 1:
			return RightPosition
		elif cannons == 2:
			return RightTopPosition
		if cannons == 3:
			return RightBottomPosition
		else:
			return RightPosition


func _on_shallows_body_exited(_area):
	shallowsEntered = false
	speed = normalSpeed


func _on_shallows_body_entered(_area):
	shallowsEntered = true
	speed = slowSpeed

func _on_hurtbox_area_shape_entered(_area_rid, area, _area_shape_index, _local_shape_index):
	get_damage(area)


func _on_ram_player_area_shape_entered(area_rid, area, area_shape_index, local_shape_index):
	$RamPlayer.monitoring = false
	$RamPlayer.monitorable = false
	await get_tree().create_timer(3).timeout
	canRam = true
