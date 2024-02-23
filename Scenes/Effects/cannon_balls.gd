extends Node2D

var cannonSpeed = 50
var hit = false

func _process(delta):
	$Path2D/PathFollow2D/CannonSprite.play()
	if hit:
		$Path2D/PathFollow2D.progress += 0
	else:
		$Path2D/PathFollow2D.progress += cannonSpeed * delta
	miss()

func miss():
	if $Path2D/PathFollow2D.progress_ratio == 1:
		$Path2D/PathFollow2D/CannonSprite.hide()
		$Path2D/PathFollow2D/SplashSprite.show()
		$Path2D/PathFollow2D/SplashSprite.play()
		$Path2D/PathFollow2D/HitboxCannon.monitoring = false
		await get_tree().create_timer(.8).timeout
		self.queue_free()

func play_hit():
	hit = true
	$Path2D/PathFollow2D.progress += 0
	$Path2D/PathFollow2D/HitSprite.show()
	$Path2D/PathFollow2D/CannonSprite.hide()
	$Path2D/PathFollow2D/HitSprite.play()
	$Path2D/PathFollow2D/HitboxCannon.monitoring = false
	await get_tree().create_timer(.8).timeout
	self.queue_free()


func _on_hitbox_body_entered(_body):
	play_hit()


func _on_hitbox_area_entered(_area):
	play_hit()
