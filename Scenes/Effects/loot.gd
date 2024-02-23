extends Area2D

@onready var player: CharacterBody2D = get_tree().get_root().get_child(0).get_node("playerShip")

var money_gained = randi_range(1,6)
var obtained = false

# Called when the node enters the scene tree for the first time.
func _ready():
	rotation_degrees = 0
	$Sprite2D.play()

func _physics_process(delta):
	show_money(obtained, delta)
	print($Path2D/PathFollow2D.progress_ratio)
	if $Path2D/PathFollow2D.progress_ratio >= .9:
		queue_free()

func show_money(obtained, delta):
	if obtained:
		$Path2D/PathFollow2D/c.show()
		$Path2D/PathFollow2D/Money.show()
		$Path2D/PathFollow2D.progress += 10 * delta
		$Path2D/PathFollow2D/Money.frame = 26 + money_gained

func _on_body_entered(body):
	player.money += money_gained
	obtained = true
	$Sprite2D.hide()
