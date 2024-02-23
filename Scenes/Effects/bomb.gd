extends Node2D

func _ready():
	$Timer.start()
	$BombSprite.play()

func _process(delta):
	miss()

func miss():
	if $Timer.is_stopped():
		$BombSprite.hide()
		$SplashSprite.show()
		$SplashSprite.play()
		$HitboxBomb.monitoring = false
		await get_tree().create_timer(.8).timeout
		self.queue_free()

func play_hit():
	$SplashSprite.show()
	$BombSprite.hide()
	$SplashSprite.play()
	$HitboxBomb.monitoring = false
	await get_tree().create_timer(.8).timeout
	self.queue_free()


func _on_hitbox_body_entered(_body):
	play_hit()


func _on_hitbox_area_entered(_area):
	play_hit()
