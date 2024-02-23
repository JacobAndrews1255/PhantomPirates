extends CharacterBody2D

@export var normalSpeed = 35
@export var health = 10
@export var cannonBalls = 6
@export var cannons = 1
@export var rotate = rotation

@onready var fastSpeed = normalSpeed / .5
@onready var speed = normalSpeed
@onready var slowSpeed = normalSpeed * .7
const maxHealth = 10.0
const maxCannonBalls = 6

var attacks = 1
var maxAttacks = 4

var backSplashEffect = preload("res://Scenes/Effects/back_splash_effect.tscn")
var cannon = preload("res://Scenes/Effects/cannon_balls.tscn")
var bolas = preload("res://Scenes/Effects/bolas.tscn")
var lootScene = preload("res://Scenes/Effects/loot.tscn")

@onready var player: CharacterBody2D = get_tree().get_root().get_child(0).get_node("playerShip")

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
var canShoot = false
var canRam = true
var boatFrame = 0
var shallowsEntered = false
var dying = false
var confused = false

var hitFrame = 14

var randomDirection
var randomTime
var fleeing = false

enum{
	WANDER,
	ROTATE,
	ATTACK,
	FLEE,
	FLEED,
	FLOAT
}

var state = WANDER


func _ready():
	#player = get_parent().get_child(0).get_node("playerShip")
	
	randomDirection = RandomNumberGenerator.new()
	randomDirection.randomize()
	randomDirection = randi_range(-90,90)
	
	randomTime = RandomNumberGenerator.new()
	randomTime.randomize()
	randomTime = randi_range(1,4)
	
	$Timer.wait_time = randomTime
	
	if randomTime == 2:
		state = FLOAT
	
	
	if not player:
		print(player)
		print(get_tree().get_root().get_child(0).get_node("playerShip"))
		print("Warning: The 'playerShip' node was not found in the scene tree.")
		player = self

func _physics_process(delta):
	movingAnimations()
	match state:
		WANDER:
			wander(delta)
		ROTATE:
			changeDirection(delta)
		FLOAT:
			floating()
		FLEE:
			flee(delta)
		FLEED:
			fleed()
		ATTACK:
			attacking(delta)
	
	reverseRotation(confused,delta)



func wander(delta):
	velocity = transform.x * (speed/2)
	$Boat.frame = boatFrame + 1
	$Timer.wait_time -= delta
	if $Timer.wait_time <= 1:
		state = ROTATE
	move_and_collide(velocity * delta)

func changeDirection(delta):
	velocity = transform.x * (speed/2)
	rotation_direction = -1
	if randomDirection > 0:
		rotation_direction = 1
	rotation += rotation_direction * (rotation_speed * .5) * delta
	if round(rotation_degrees) + 1 == randomDirection or round(rotation_degrees) == randomDirection or rotation_degrees > 400:
		rotation_degrees = wrapRotationDegrese(rotation_degrees)
		randomDirection = randi_range(-90,90)
		$Timer.wait_time = randi_range(1,4)
		$Timer.start()
		state = WANDER
	move_and_collide(velocity * delta)

func wrapRotationDegrese(degrees):
	while degrees >= 360.0:
		degrees -= 360.0
	while degrees < 0.0:
		degrees += 360.0
	return degrees

func floating():
	$Boat.frame = boatFrame

func flee(delta):
	velocity = transform.x * speed
	$Boat.frame = boatFrame + 1
	if rotation != player.rotation and !fleeing:
		rotation = move_toward(rotation, player.rotation, .05)
	elif rotation == player.rotation:
		rotation += rotation_direction * rotation_speed * delta
		fleeing = true
	if move_and_collide(velocity * delta):
		state = FLEED

func fleed():
	canBackSplash = false
	velocity = Vector2.ZERO
	$Boat.frame = boatFrame + 2


func attacking(delta):
	var playerSide
	velocity = transform.x * (speed/1.5)
	$Boat.frame = boatFrame + 1
	move_and_collide(velocity * delta)

	var dir = player.position - position - (position/2)
	rotation = move_toward(rotation, dir.angle(), .05)
	if dir.angle() >= 0:
		playerSide = "right"
	else:
		playerSide = "left"
		
	shooting(canShoot, playerSide)
		

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



func shooting(shoot, playerSide):
	
	if randomTime == 2:
		if attacks == maxAttacks:
			attacks = 1
		else:
			attacks += 1
	
	#print(attacks)
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
	
	if attacks == 1 or attacks == 2:
		for i in range(0 , cannons):
			if shoot and playerSide == "left" and canShootLeft:
				create_cannonBall_instance("LeftPosition", cannons)
				canShootLeft = false
				await get_tree().create_timer(1.5).timeout
				canShootLeft = true
			if shoot and playerSide == "right" and canShootRight:
				create_cannonBall_instance("RightPosition", cannons)
				canShootRight = false
				await get_tree().create_timer(1.5).timeout
				canShootRight = true
	if attacks == 3:
		if shoot and playerSide == "left" and canShootLeft:
			create_bolas_instance("LeftPosition")
			canShootLeft = false
			await get_tree().create_timer(1.5).timeout
			canShootLeft = true
		if shoot and playerSide == "right" and canShootRight:
			create_bolas_instance("RightPosition")
			canShootRight = false
			await get_tree().create_timer(1.5).timeout
			canShootRight = true

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
				state = FLEE
				boatFrame = 6
		health = health - damage

func death():
	$Boat.hide()
	$DeathSprite.show()
	$DeathSprite.play()
	rotation_degrees = 0
	var loot = create_loot_instance()
	print(loot)
	await get_tree().create_timer(2).timeout
	if !$DeathSprite.is_playing():
		$backSplashMarker.queue_free()
		queue_free()

func reverseRotation(temp,delta):
	if temp:
		#get_parent().get_node("playerShip/MapCamera").ignore_rotation = false
		rotation -= rotation_direction * (rotation_speed * 2) * delta * 2

func create_loot_instance():
	var lootInst = lootScene.instantiate()
	get_tree().get_root().add_child(lootInst)
	lootInst.money_gained += 3
	lootInst.transform = self.global_transform

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


func _on_hurtbox_area_shape_entered(_area_rid, area, _area_shape_index, _local_shape_index):
	get_damage(area)


func _on_detection_body_shape_entered(body):
	state = ATTACK


func _on_left_shoot_area_entered(area):
	canShoot = true


func _on_left_shoot_area_exited(area):
	canShoot = false


func _on_right_shoot_area_shape_entered(area_rid, area, area_shape_index, local_shape_index):
	canShoot = true


func _on_right_shoot_area_shape_exited(area_rid, area, area_shape_index, local_shape_index):
	canShoot = false


func _on_detection_body_entered(body):
	state = ATTACK
