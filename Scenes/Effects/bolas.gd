extends Node2D

var bolasSpeed = 35
var hit = false

func _process(delta):
	$Path2D/PathFollow2D/BolasSprite.rotation_degrees += 5
	if hit:
		$Path2D/PathFollow2D.progress += 0
	else:
		$Path2D/PathFollow2D.progress += bolasSpeed * delta
	miss()

func miss():
	if $Path2D/PathFollow2D.progress_ratio == 1:
		$Path2D/PathFollow2D/BolasSprite.hide()
		$Path2D/PathFollow2D/SplashSprite.show()
		$Path2D/PathFollow2D/SplashSprite.play()
		$Path2D/PathFollow2D/HitboxBolas.monitoring = false
		await get_tree().create_timer(.8).timeout
		self.queue_free()

func play_hit():
	hit = true
	$Path2D/PathFollow2D.progress += 0
	$Path2D/PathFollow2D/BolasSprite.hide()
	$Path2D/PathFollow2D/HitboxBolas.monitoring = false
	await get_tree().create_timer(.8).timeout
	self.queue_free()


func _on_hitbox_body_entered(_body):
	play_hit()


func _on_hitbox_area_entered(_area):
	play_hit()
