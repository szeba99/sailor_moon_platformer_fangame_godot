extends Area2D

var exit_scene : AnimationPlayer
@export_file("*.tscn") var next_level : String

var already_touched : bool = false
var it_timed_out : bool = false

# Called when the node enters the scene tree for the first time.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	
	
	if Input.is_anything_pressed() and already_touched and it_timed_out:
		get_tree().change_scene_to_file(next_level)


func _on_body_entered(body: Node2D) -> void:
	if (body.name == "Player"):
		already_touched = true
		$Timer.start()
		
		#register the time record
		var total_seconds = body.find_child("RecordTimer").wait_time - body.find_child("RecordTimer").time_left

		# calculating unitess
		var hours = int(total_seconds) / 3600
		var minutes = (int(total_seconds) / 60) % 60
		var seconds = int(total_seconds) % 60
		var msec = int((total_seconds - int(total_seconds)) * 1000)

		# format string
		var time_string = "%02d:%02d:%02d:%03d" % [hours, minutes, seconds, msec]
		body.find_child("CanvasLayer").find_child("RecordLabel").text = time_string

#########################
		get_tree().root.find_child("MusicPlayer", true, false).stop()
		exit_scene = body.find_child("ExitScene").find_child("AnimationPlayer")
		exit_scene.play("fade_out")
		if body.has_method("victory_pose2"):
			body.victory_pose2()
		
		$AudioStreamPlayer.play()
		


func _on_timer_timeout() -> void:
	it_timed_out = true
