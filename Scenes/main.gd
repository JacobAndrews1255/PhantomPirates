extends Node2D

var fishingBoat = preload("res://Scenes/Ships/fishing_ship.tscn")

@onready var player = $playerShip
@onready var SPBR = $playerShip/SP_BottomRight
@onready var SPBL = $playerShip/SP_BottomLeft
@onready var SPTR = $playerShip/SP_TopRight
@onready var SPTL = $playerShip/SP_TopLeft

@onready var spawnPoint
@onready var spList = [false,false,false,false]

var spbrOpen = true
var spblOpen = true
var sptrOpen = true
var sptlOpen = true

var fishingBoatSpawnNumber = 3

@onready var rng

func _ready():
	$fishingBoatTimer.start()

#	rng = RandomNumberGenerator.new()
#	rng.randomize()
#	rng = randi_range(0,3)


func _physics_process(delta):
	#get_spawn_point()
	#spawnFishingBoat(rng)
	#if $fishingBoatTimer.wait_time < 1:
	#	$fishingBoatTimer.stop()
	#else:
	#	$fishingBoatTimer.wait_time -= delta
	#print("Time: ",$fishingBoatTimer.wait_time)
	pass


func get_spawn_point():
	if spbrOpen:
		spList[0] = true
	else:
		spList[0] = false
	if spblOpen:
		spList[1] = true
	else:
		spList[0] = false
	if sptrOpen:
		spList[2] = true
	else:
		spList[0] = false
	if sptlOpen:
		spList[3] = true
	else:
		spList[0] = false

func create_fishingBoat_instance(spawn):
	print("created_fishingBoat")
	var fishingBoatInst = fishingBoat.instantiate()
	get_tree().get_root().add_child.call_deferred(fishingBoatInst)
	fishingBoatInst.position.x = spawn.x
	fishingBoatInst.position.y = spawn.y
	fishingBoatSpawnNumber -= 1

func spawnFishingBoat(rng):
	if spList[rng] and fishingBoatSpawnNumber > 0 and $fishingBoatTimer.wait_time <= 1:
		spawnPoint = getSpawnPosition(rng)
		create_fishingBoat_instance(spawnPoint)
		$fishingBoatTimer.wait_time = 5
		$fishingBoatTimer.start()

func getSpawnPosition(num):
	if num == 0:
		return $playerShip/SP_BottomRight.position
	if num == 1:
		return $playerShip/SP_BottomLeft.position
	if num == 2:
		return $playerShip/SP_TopRight.position
	if num == 3:
		return $playerShip/SP_TopLeft.position

func _on_sp_bottom_left_area_shape_entered(_area_rid, _area, _area_shape_index, _local_shape_index):
	spblOpen = false
func _on_sp_bottom_left_area_shape_exited(_area_rid, _area, _area_shape_index, _local_shape_index):
	spblOpen = true


func _on_sp_top_left_area_shape_entered(_area_rid, _area, _area_shape_index, _local_shape_index):
	sptlOpen = false
func _on_sp_top_left_area_shape_exited(_area_rid, _area, _area_shape_index, _local_shape_index):
	sptlOpen = true


func _on_sp_top_right_area_shape_entered(_area_rid, _area, _area_shape_index, _local_shape_index):
	sptrOpen = false
func _on_sp_top_right_area_shape_exited(_area_rid, _area, _area_shape_index, _local_shape_index):
	sptrOpen = true


func _on_sp_bottom_right_area_shape_entered(_area_rid, _area, _area_shape_index, _local_shape_index):
	spbrOpen = false
func _on_sp_bottom_right_area_shape_exited(_area_rid, _area, _area_shape_index, _local_shape_index):
	spbrOpen = true
