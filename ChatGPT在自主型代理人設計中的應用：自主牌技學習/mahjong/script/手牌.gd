extends Container
var mahjong = load("res://mahjong/scene/mahjong.tscn")
var 手牌:Array[String]
var Abandon_card:Array[String]
var Other_card:Array[String]
@onready var Abandon_card_container_f := $"../棄牌"
@onready var other_card := $"../吃碰"

var select_card
var select_obj
var select_animation : bool = false
var dir = 0
var action:bool = false
var user
var memory
var Round_passed:int
var sequence:Array # 吃判定
var triplet:Array # 碰判定
var kong:Array #槓判定
var ready_hand:Array # 聽牌
var sequence_triplet_number :int = 0
var pair_number :int = 0
var lock = true
signal finished
signal gpt_Abandon_card_finished
signal event_complete
var Discard_card:mahjong

# Called when the node enters the scene tree for the first time.


func _ready() -> void:
	#手牌 = ["二萬", "二萬", "三萬", "二筒", "五筒", "五筒", "二條", "三條", "六條", "七條", "七條", "八條", "九條", "南", "北", "白"]
	#手牌 = ["八筒", "八筒", "八筒", "南", "南", "南", "一萬", "一萬", "四萬", "五萬", "六萬", "七萬", "八萬"]  # 3面聽
	#手牌 = ["一萬", "二萬", "三萬", "南", "南", "南", "五萬", "六萬", "七萬", "七萬", "八萬", "八萬", "八萬"] # 4面聽
	#gpt_env_info()
	#check_all_combination()
	pass
func gpt_inti(apiKey:String,model:String,name:String,main_mem:String,goal:Array[String]):
	memory = get_child(0)
	#var goal:Array[String] = ["最佳的出牌"]
	memory.set_info(name,main_mem,goal)
	memory.set_gpt(apiKey,model)

func start(dir:int = 0):
	Abandon_card.clear()
	Other_card.clear()
	user = get_child(0).user
		
	self.dir = dir
	for i in range(16):
		Draw_a_tile("deselect",dir)
	sort_card()
	if user == "gpt":

		memory.set_envMem(gpt_env_info())
		#make_plan()
		
	check_all_combination()
	
	#print(手牌)
	return	
	
func make_plan():
	await  memory.send_message(Global.question["Generate_plan"],"Generate_plan")
	lock = false
	pass


func array2string(user_name:String,user) -> String:
	var res:String = ""
	if user.Abandon_card.size() != 0:
		res += user_name + "打出去的牌 : "
		for i in user.Abandon_card :
			res += i  + ","
		res = res.erase(res.length() - 1)
		res += "\n"
		
	if user.Other_card.size() != 0:
		res += user_name + "吃碰槓的牌堆 : "
		for i in user.Other_card :
			res += i  + ","
		res = res.erase(res.length() - 1)
		res += "\n"
		
	return res 
		
func get_all_player_abandon_card() -> String:
	
	var parent = get_parent().get_parent().get_parent()
	var round : int = parent.round - 1
	var players : Array = parent.players
	var players_count = players.size() 
	var tem = ["上家","對家","下家"]
	var result = ""
	
	for i in tem :
		result += array2string(i,players[(players_count + round) % players_count])
		round -= 1
		print(round)
		
	print(result)	
	return result
	
func gpt_env_info():	
	var tt = "你的手牌 : "
	for i in 手牌 :
		tt += i  + ","
		
	tt = tt.erase(tt.length() - 1)
	tt = tt + "\n" + get_all_player_abandon_card()	
	print(tt)
	#memory.set_envMem(tt)
	return tt

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	


func test():
	sort_card()
	await get_tree().create_timer(1.0).timeout
		
	Draw_a_tile("deselect",dir)
	
	if user == "gpt":
		var tt = ""
		for i in 手牌 :
			tt += i  + ","
		$memoryModule.set_envMem(tt)
		
func turn(Draw = true):
	
	if Draw : 
		Draw_a_tile("deselect",dir)
		if self_drawn_win_check() : 
			emit_signal("finished")
			return
			
	
	if user == "computer" : 
		var random_int = randi()
		
		sort_card()
		var child = get_child($computer_player.Discard() + 1)
		
		Abandon_card.append(child.排型)
		
		remove_child(child)
		Abandon_card_container_f.add_child(child)
		
		#child.queue_free()
		手牌.clear()
		#await  child.tree_exited
		
		sort_card()
		
		#gpt_env_info()
		Discard_card = child
		
	if user == "gpt":
		
		memory.set_envMem(gpt_env_info())
		
		await memory.send_message(Global.question["Check_plan"],"Check_plan")
		await get_tree().create_timer(1).timeout
		await memory.send_message(Global.question["Discard_a_tile"],"Discard_a_tile")
		
		
		
	Round_passed += 1
	await get_tree().create_timer(0.1).timeout
	
	check_all_combination()
	
	get_parent().get_parent().get_parent().Discard_card = Discard_card
	
	lock = false
	emit_signal("finished")
	

	 #回傳打出去的牌 ， 用於檢查吃、碰、槓、胡
	
func sort_card():
	var children_array = []
	for child in get_children():
		if child is Container:
			children_array.append(child)
		
		
	children_array.sort_custom(func(a: mahjong, b: mahjong): 
		return Global.sort_mahjong_tiles[a.排型] < Global.sort_mahjong_tiles[b.排型])
	
	手牌.clear()
	
	for child in children_array:
		remove_child(child)
		add_child(child)
		手牌.append(child.排型)
	print("tem")
	
func Discard_a_tile(card:String = ""):

	
	for child in get_children():
		if child != null and child is Container : 
			if  child.排型 == card : 
				#$memoryModule.set_shortMem(card)
				Abandon_card.append(child.排型)
				remove_child(child)
				Abandon_card_container_f.add_child(child)
				手牌.clear()
				
				sort_card()
				
				Discard_card = child
				
				emit_signal("gpt_Abandon_card_finished")
				print(child.排型)
				
				return true
				#await get_tree().create_timer(3.0).timeout
				
				#Draw_a_tile("deselect",dir)
	return false			
				
	
	
func Draw_a_tile(ani:String = "deselect",dir:int = 0):
	var tem = mahjong.instantiate()
	var card = get_parent().get_parent().get_parent().draw_card()
	手牌.append(card)
	tem.set_info(card,dir)
	add_child(tem)
	if dir == 0 : tem.play_animation(ani)
	
	if ani == "select" : 
		select_obj = tem
	
func get_info():
	print(手牌)
	
func check_all_combination():
	sequence.clear()
	triplet.clear()
	kong.clear()
	ready_hand.clear()
	
	complete_a_sequence()
	complete_a_triplet()
	complete_ready_hand()
	print(ready_hand)
	
func complete_a_sequence():

	for i in 手牌.size() - 1:
		var tileA = Global.sort_mahjong_tiles[手牌[i+1]]
		var tileB = Global.sort_mahjong_tiles[手牌[i]]
		if (tileA - tileB == 1) and tileA != 9 and tileA != 18 and tileA <= 26:
			if tileA != 8 and tileA != 17 and tileA != 26 :
				if sequence.find(Global.mahjong_tiles[tileA + 1]) == -1:
					sequence.append(Global.mahjong_tiles[tileA + 1])
			if tileB != 0 and tileB != 9 and tileB != 18:
				if sequence.find(Global.mahjong_tiles[tileB - 1]) == -1:
					sequence.append(Global.mahjong_tiles[tileB - 1])

		if (tileA - tileB == 2) and tileA != 9 and tileA != 10 and tileA != 18 and tileA != 19 and tileA <= 26 and tileA != 27 :
			if sequence.find(Global.mahjong_tiles[tileA - 1]) == -1:
				sequence.append(Global.mahjong_tiles[tileA - 1])
	#print(sequence)

func complete_a_triplet():

	for i in 手牌.size() - 1:
		var tileA = Global.sort_mahjong_tiles[手牌[i+1]]
		var tileB = Global.sort_mahjong_tiles[手牌[i]]
		if tileA == tileB:
			if triplet.find(Global.mahjong_tiles[tileA]) == -1:
				triplet.append(Global.mahjong_tiles[tileA])
			else : kong.append(Global.mahjong_tiles[tileA])
	#print(triplet)
	#print(kong)
	
func complete_ready_hand( point = 0,have_pari = false,remaining_cards:Array = []): #聽牌
	remaining_cards = remaining_cards.duplicate()
	#print(remaining_cards)
	if point >= 手牌.size() : 
		print(remaining_cards)
		draw_check(remaining_cards) #聽牌處理
		return 
	
	if remaining_cards.size() > 2:
		remaining_cards.clear()
		return
		
	var tileC = -1
	var tileB = -1
	if point +2 < 手牌.size() :	tileC = Global.sort_mahjong_tiles[手牌[point+2]]
	if point +1 < 手牌.size() :	tileB = Global.sort_mahjong_tiles[手牌[point+1]]
	var tileA = Global.sort_mahjong_tiles[手牌[point]]
	
	if tileA == tileB and (not have_pari): 
		complete_ready_hand(point+2,true,remaining_cards)
	
	if tileA == tileC : 
		complete_ready_hand(point + 3,have_pari,remaining_cards)
		
	if sequence_check(tileA,tileB,tileC):
		complete_ready_hand(point + 3,have_pari,remaining_cards)
	
	remaining_cards.append(手牌[point])
	complete_ready_hand(point+1,have_pari,remaining_cards)
	
	
func sequence_check(tileA:int,tileB:int,tileC:int):
	if ((tileA >= 0 and tileA <= 8) and (tileC <= 8)) or ((tileA >= 9 and tileA <= 17) and (tileC <= 17)) or ((tileA >= 18 and tileA <= 26) and (tileC <= 26)):
		return (tileA + 1 == tileB) and (tileB + 1 == tileC)
	return false
	
func color_check(tileA,tileB,tileC = -1):
	if tileC == -1 :
		return extend_color_check(tileA) == extend_color_check(tileB)
	return extend_color_check(tileA) == extend_color_check(tileB) and extend_color_check(tileB) == extend_color_check(tileC)
	
func extend_color_check(tile):
	var res = -1
	if tile >= 0 and tile <= 8 : res = 1 # 萬
	elif tile >= 9 and tile <= 17 : res = 2 # 筒
	elif tile >= 18 and tile <= 26 : res = 3 #  條
	return res

func draw_check(input:Array): 
	#["1 2"] -> 3 ,  [2 4] -> 3   [2 3] -> 1,4 聽單或雙
	#["2 2"] -> 2聽單張 發生牌型為 [111 22 33 ] -> [22] [33]
	#[" 1 "] -> 1單掛 [111 2] [2]
	#["3 5"] 錯誤 [111 2 5]   [2 5] 單掉 *2 (離聽牌差1張) 可能還有其他發生可能性但我沒想到 ouob
	# ==== complete_ready_hand () 獲取到的陣列做處理 以上為目前觀測有的可能性 ====  為什麼這註解那麼詳細呢?我想很久這段code
	if input.size() == 1 :
		ready_hand.append(input[0])
		return
	
	if input[0] == input[1]:
		ready_hand.append(input[0])
		return
	
	var tileB = Global.sort_mahjong_tiles[input[0]]
	var tileA = Global.sort_mahjong_tiles[input[1]]
	if	(tileA - tileB == 1) and color_check(tileA,tileB):
		if tileA != 8 and tileA != 17 and tileA != 26 :
			if ready_hand.find(Global.mahjong_tiles[tileA + 1]) == -1:
				ready_hand.append(Global.mahjong_tiles[tileA + 1])
		if tileB != 0 and tileB != 9 and tileB != 18:
			if ready_hand.find(Global.mahjong_tiles[tileB - 1]) == -1:
				ready_hand.append(Global.mahjong_tiles[tileB - 1])
				
	if (tileA - tileB == 2) and color_check(tileA,tileB):
		if ready_hand.find(Global.mahjong_tiles[tileA - 1]) == -1:
			ready_hand.append(Global.mahjong_tiles[tileA - 1])
		
			
func _eat(Discard_card,Eat_combo:Array):

	var card_value = Discard_card.排型
	var idx = Global.sort_mahjong_tiles[card_value]
	#mahjong_tiles

	var len = 手牌.size()

		
	if user == "gpt" :
		var temp = ["A","B","C"]
		var temp_dic = {
			"A" : -1,
			"B" : -1,
			"C" : -1
		}
		var i = 0
		var question = "以下是你可以吃的選擇"
		var que :Array= Global.question["eat_choice"]
		
		if Eat_combo[0] : 
			question += temp[i] + Global.mahjong_tiles[idx - 2] + Global.mahjong_tiles[idx - 1] + "吃" +Global.mahjong_tiles[idx]  + ","
			temp_dic[temp[i]] = 0
			i += 1
		if Eat_combo[1] : 
			question += temp[i] + Global.mahjong_tiles[idx - 1] + Global.mahjong_tiles[idx + 1] + "吃" +Global.mahjong_tiles[idx]  + ","
			temp_dic[temp[i]] = 1
			i += 1
		if Eat_combo[2] : 
			question += temp[i] + Global.mahjong_tiles[idx - 1] + Global.mahjong_tiles[idx - 2] + "吃" +Global.mahjong_tiles[idx]  + ","
			temp_dic[temp[i]] = 2
			i += 1
		if i > 1 :
			que[0] += question
			await memory.send_message(que,"eat_choice")
			var val:String = memory.val
			if val.find("A") != -1 : 
				Eat_combo = [false,false,false]
				Eat_combo[temp_dic["A"]] = true
			elif val.find("B") != -1 : 
				Eat_combo = [false,false,false]
				Eat_combo[temp_dic["A"]] = true
			elif val.find("C") != -1 and i == 3: 
				Eat_combo = [false,false,false]
				Eat_combo[temp_dic["A"]] = true
	
	if Eat_combo[0]: 
		var fidx = 手牌.find(Global.mahjong_tiles[idx - 2])
		var sidx = 手牌.find(Global.mahjong_tiles[idx - 1])
		transfer_eat_cards(fidx,sidx)
		Other_card.append(card_value)
		print("吃" , Discard_card.排型)		
		return
		
	if Eat_combo[1]: 
		var fidx = 手牌.find(Global.mahjong_tiles[idx - 1])
		var sidx = 手牌.find(Global.mahjong_tiles[idx + 1])
		transfer_eat_cards(fidx,sidx)
		Other_card.append(card_value)
		print("吃" , Discard_card.排型)
		return
		
	if Eat_combo[2]: 
		var fidx = 手牌.find(Global.mahjong_tiles[idx + 1])
		var sidx = 手牌.find(Global.mahjong_tiles[idx + 2])
		transfer_eat_cards(fidx,sidx)
		Other_card.append(card_value)
		print("吃" , Discard_card.排型)
		return

	

func Eat_combo(Discard_card):
	var card_value = Discard_card.排型
	var idx = Global.sort_mahjong_tiles[card_value]
	#mahjong_tiles

	var len = 手牌.size()
	var res = [false,false,false]
	if sequence_check(idx - 2,idx - 1,idx): 
		if 手牌.find(Global.mahjong_tiles[idx - 2]) != -1 and 手牌.find(Global.mahjong_tiles[idx - 1]) != -1 :
			res[0] = true
				
	if sequence_check(idx - 1, idx ,idx + 1): 
		if 手牌.find(Global.mahjong_tiles[idx - 1]) != -1 and 手牌.find(Global.mahjong_tiles[idx + 1]) != -1 :
			res[1] = true
			
	if sequence_check(idx , idx + 1 ,idx + 2): 
		if 手牌.find(Global.mahjong_tiles[idx + 1]) != -1 and 手牌.find(Global.mahjong_tiles[idx +2]) != -1 :
			res[2] = true
	
	return res
	
func transfer_eat_cards(fidx,sidx):
	var childA = get_child(fidx + 1)
	var childB = get_child(sidx + 1)
	remove_child(childA)
	remove_child(childB)
	other_card.add_child(childA)
	other_card.add_child(childB)
	Other_card.append(childA.排型)
	Other_card.append(childB.排型)
	sort_card()


func _bump(Discard_card):
	
	lock = true
	
	var card_value = Discard_card.排型
	for i in range(2):
		var idx = 手牌.find(card_value) + 1
		var child = get_child(idx)
		
		remove_child(child)
		other_card.add_child(child)
		Other_card.append(Discard_card.排型)
	Other_card.append(Discard_card.排型)
	sort_card()
	print("碰" , Discard_card.排型)
	return true

func _kong(Discard_card):
	
	
	var card_value = Discard_card.排型
	for i in range(3):
		var idx = 手牌.find(card_value) + 1
		var child = get_child(idx)
		
		remove_child(child)
		other_card.add_child(child)
		Other_card.append(Discard_card.排型)
	Other_card.append(Discard_card.排型)
	sort_card()
	
	
	print("槓" , Discard_card.排型)
	
	return true

func _hear(Discard_card):
	return true
	
func self_drawn_win_check():
	var tile = get_child(-1)
	if ready_hand.find(tile.排型) != -1 :
		var parent = get_parent().get_parent().get_parent()
		var player_name = ["H1","H2","H3","H4"]
		parent.gameover = true
		print("自摸的是" + player_name[parent.round % parent.players_count] + "自摸的牌是" + tile.排型)
		
		return true
	return false

func  send_special_events(players_event,Discard_card):
	var events = ["槓","碰","吃"]
	if user == "computer" : 
		
		return players_event
	if user == "gpt" : 
		var question = "有人打出" + Discard_card.排型
		var num = 0
		for i in players_event:
			if i : question += ",你可以" + events[num]
			num += 1
		var que :Array= Global.question["event_choice"]
		que[0] += question
		await memory.send_message(que,"event_choice")
		var val:String = memory.val
		
		var temp_event
		if val.find("吃") != -1 : 
			temp_event = [false,false,true]
		if val.find("碰") != -1 : 
			temp_event = [false,true,true]
		if val.find("槓") != -1 : 
			temp_event = [true,false,true]
		if val.find("放棄") != -1 : 
			return [false,false,false]	
			
		for i in range(3): #檢查是否發生 不能碰 卻碰 ( ... 發生過
			players_event[i] = players_event[i] and temp_event[i]
		return players_event

func  gameover_from_gpt():
	memory.send_message(Global.question["Generate_reflection"],"Generate_reflection")
	
