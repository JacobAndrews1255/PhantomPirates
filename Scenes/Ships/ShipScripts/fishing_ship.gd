extends CharacterBody2D

const maxHealth = 2

@export var speed = 25
@export var health = maxHealth

var backSplashEffect = preload("res://Scenes/Effects/small_back_splash_effect.tscn")
var lootScene = preload("res://Scenes/Effects/loot.tscn")
#@onready var player: CharacterBody2D = get_tree().get_root().get_node("playerShip")
@onready var player: CharacterBody2D = get_tree().get_root().get_child(0).get_node("playerShip")
@onready var playerScene

@onready var backSplashPosition = $backSplashMarker

var rotation_speed = 2.2
var rotation_direction = 0
var canBackSplash = true
var boatFrame = 0
var shallowsEntered = false
var dying = false
var fleeing = false

var randomDirection
var randomTime

enum{
	WANDER,
	ROTATE,
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
	
	$Timer.stop()
	$Timer.wait_time = randomTime
	
	if randomTime == 2:
		state = FLOAT
	
	if not player:
		print(player)
		print(get_tree().get_root().get_child(0).get_node("playerShip"))
		print("Warning: The 'playerShip' node was not found in the scene tree.")

func _physics_process(delta):
	
	if not player:
		print(player)
		print(get_tree().get_root().get_child(0).get_node("playerShip"))
		print("Warning: The 'playerShip' node was not found in the scene tree.")
		player = self
		
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


func wander(delta):
	velocity = transform.x * (speed/2)
	$Boat.frame = boatFrame
	$Timer.wait_time -= delta
	#print("WANDER ", $Timer.wait_time)
	if $Timer.wait_time <= 1:
		state = ROTATE
		#print("STOPPED")
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
	$Boat.frame = boatFrame + 2

func flee(delta):
	velocity = transform.x * speed
	$Boat.frame = boatFrame
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

func movingAnimations():
	if velocity != Vector2.ZERO and canBackSplash:
		create_backSplash_instance()
		canBackSplash = false
		await get_tree().create_timer(.5).timeout
		canBackSplash = true
	if speed <= 4:
		canBackSplash = false


func get_damage(area):
	var damage = 1
	if area.to_string().substr(0,10) == "HitboxBomb":
		damage = 3
	elif area.to_string().substr(0,11) == "HitboxBolas":
		damage = 0
		speed = speed/1.5
#		await get_tree().create_timer(8).timeout
#		state = FLEE
	
	if damage >= health and !dying:
		dying = true
		death()
	else:
		if health == maxHealth and damage != 0:
			boatFrame = 1
		health = health - damage

func death():
	$Boat.hide()
	$DeathSprite.show()
	$DeathSprite.play()
	await get_tree().create_timer(1).timeout
	rotation_degrees = 0
	create_loot_instance()
	if !$DeathSprite.is_playing():
		#get_tree().get_root().fishingBoatSpawnNumber += 1
		self.queue_free()

func create_loot_instance():
	var lootInst = lootScene.instantiate()
	get_tree().get_root().add_child(lootInst)
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

func _on_hitbox_area_shape_entered(_area_rid, area, _area_shape_index, _local_shape_index):
	get_damage(area)

func _on_detection_body_entered(_body):
	print("fish flee   : ",self)
	state = FLEE
