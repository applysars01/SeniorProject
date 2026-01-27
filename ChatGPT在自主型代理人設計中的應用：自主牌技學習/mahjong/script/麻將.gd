extends Container
class_name mahjong


var 排型
var w = 116
var h = 160
var select : bool = false
@export var select_done : bool = false
var select_animation = false
var parent;
func _ready() -> void:
	parent = get_parent()
	
	pass
		
	#$"正面".region_rect = Global.map[排型]
	#$"正面".visible = false
	#$"反面".visible = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func set_info(排型:String,rotation:float = 0):
	self.排型 = 排型
	$"正面".region_rect = Global.map[排型]
	$"正面".rotation_degrees = rotation
	if rotation == 90 or rotation == 270:
		custom_minimum_size = Vector2(h / 2 , w / 2)
		

func _process(delta: float) -> void:
	
	pass

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("text_next"):
		if select :
			
			parent.test()
			
			queue_free()
	pass
			
	
			
		
	
func play_animation(ani):
	$AnimationPlayer.play(ani)	

func _on_mouse_entered() -> void:
	
	select = true
	$AnimationPlayer.play("select")
	


func _on_mouse_exited() -> void:
	select = false
	$AnimationPlayer.play("deselect")
	



