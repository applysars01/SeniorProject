extends Node2D

var user = "computer"

var _score:Dictionary = {
	"一萬": 0,
	"九萬": 0,
	"一筒": 0,
	"九筒": 0,
	"一條": 0,
	"九條": 0,
	"東": -1,
	"西": -1,
	"南": -1,
	"北": -1,
	"中": -1,
	"發": -1,
	"白": -1
};
var 手牌
var seq_score_bool : Array[bool]
var same_score_bool : Array[bool]
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#Discard()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func Discard() ->int :	
	手牌 = get_parent().手牌
	
	#手牌 = ["一萬","二萬","三萬","四萬","五萬","六萬","七萬","八萬","九萬","中","中"]
	#手牌 = ["二萬","二萬","五萬","五萬","七萬","一筒","一筒","一筒","八筒","四條","五條","五條","南","南","西","西"]
	var score : Array[int]
	var _new : Array
	
	for i in 手牌:
		_new.append(Global.sort_mahjong_tiles[i]) 
		seq_score_bool.append(false)
		same_score_bool.append(false)
		if _score.has(i):
			score.append(_score[i])
		else :
			score.append(1)
		
	add_score(_new,score) # main
	
	#print(score)
	
	var min_value = score.min() 
	var min_index = score.find(min_value) 
	
	#print(手牌)
	#print(score)
	#print(_new)
	#
	#print(min_index)
	
	seq_score_bool.clear()
	same_score_bool.clear()
	score.clear()
	_new.clear()
	return min_index
	
func add_score(_new:Array,score:Array[int]):
	for i in range(_new.size() - 1):
		if seq_score_bool[i] == false :
			_add_seq_score(_new,score,i,0,8)   #一萬 ~ 九萬 0 ~ 8
			_add_seq_score(_new,score,i,9,17)  	#一筒 ~ 九筒 9 ~ 17
			_add_seq_score(_new,score,i,18,26) 	#一條 ~ 九條 18 ~ 26 
		if same_score_bool[i] == false :
			if check_color(_new[i],27,33):
				_add_same_score(_new,score,i,3) # 刻子、對子
			else : _add_same_score(_new,score,i)
func check_color(card,left,right):
	return card <= right and card >= left
	
func _add_seq_score(_new:Array,score:Array[int],i,left,right):
	if  check_color(_new[i],left,right) and check_color(_new[i+1],left,right):
			if _new.size() - i > 2  and check_color(_new[i+2],left,right):
				if (_new[i+1] == _new[i] + 1) and (_new[i+1] == _new[i+2] - 1):
					#print(手牌[i] ," +2分  位置"  , i)
					#print(手牌[i+1] ," +2分  位置"  , i+1)
					#print(手牌[i+2] ," +2分  位置"  , i+2)
					score[i] += 2
					score[i+1] += 2
					score[i+2] += 2
					seq_score_bool[i] = true
					seq_score_bool[i+1] = true
					seq_score_bool[i+2] = true
					return
			if (_new[i+1] == _new[i] + 1):
				#print(手牌[i] ," +1分  位置"  , i)
				#print(手牌[i+1] ," +1分  位置"  , i+1)
				score[i] += 1
				score[i+1] += 1	
				seq_score_bool[i] = true
				seq_score_bool[i+1] = true


func _add_same_score(_new:Array,score:Array[int],i,bonus = 1):
	if  _new[i] == _new[i+1] :
		if _new.size() - i > 2  and _new[i+1] == _new[i+2]:
			#print(手牌[i] ," +3分  位置"  , i)
			#print(手牌[i+1] ," +3分  位置"  , i+1)
			#print(手牌[i+2] ," +3分  位置"  , i+2)
			score[i] += 3 * bonus
			score[i+1] += 3 * bonus
			score[i+2] += 3 * bonus
			same_score_bool[i] = true
			same_score_bool[i+1] = true
			same_score_bool[i+2] = true
			return

		#print(手牌[i] ," +2分  位置"  , i)
		#print(手牌[i+1] ," +2分  位置"  , i+1)
		score[i] += 2 * bonus
		score[i+1] += 2 * bonus
		same_score_bool[i] = true
		same_score_bool[i+1] = true
