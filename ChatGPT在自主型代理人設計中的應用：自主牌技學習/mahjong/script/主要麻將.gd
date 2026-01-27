extends Node
var all_mahjong_tiles:Array
var players_:Array
var players : Array
var round = 0
var players_count
var Discard_card:mahjong
@onready var gpt := load("res://mahjong/scene/memory_module.tscn")
@onready var computer := load("res://mahjong/scene/computer_player.tscn")
var gameover = false
var draw_one : bool
var stop = false
var round_cmplete = false
var player_name = ["H1","H2","H3","H4"]
var skip_event : bool 
var players_event : Array
var times = 0
var apiKey = "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"
var player_  # 當前玩家
var gptdrawcard:Array
var gptinfo = {
	"draw_card" : [],
	"win" : 0,
	"lose" : 0,
	"round" : 0,
}
var myseed = [["1"],["2"],["3"],["4"],["5"],["6"],["7"],["8"],["9"],["10"]]

func _ready() -> void:
	create_folder("user://mem/gpt")
	gameover = true
		
		
func inti():
	
	gameover = false
	var choice : Dictionary = {
		"gpt" : gpt,
		"computer" : computer
	}
	
	
	
	var ai : Array = ["gpt","computer","computer","computer"]
	gptdrawcard.clear()
	for i in range(34):
		gptdrawcard.append(0)
	players_ = get_child(0).get_children()
	
	for i in players_:
		var ch = i.get_children()
		for j in ch :
			var card = j.get_children()
			for k in card :
				j.remove_child(k)
				k.queue_free()   
	players.clear()
	for i in players_:
		players.append(i.get_child(0))
	players_count = players.size()
	
	var tem = 0
	round = 1
	
	
	if times == myseed.size() : return
	var my_seed = myseed[times].hash()
	seed(my_seed)
	times += 1
	
	#randomize()
	all_mahjong_tiles.clear()
	for i in range(4):
		for j in Global.mahjong_tiles:
			all_mahjong_tiles.append(j)
	all_mahjong_tiles.shuffle()
	
	for i in players.size():
		players[i].add_child(choice[ai[i]].instantiate())
		if ai[i] == "gpt": 
			var goal:Array[String] = ["最佳的出牌"]
			players[i].gpt_inti(apiKey,"gpt-4o-mini","p1","你正在玩麻將你是一名沉著冷靜的棋手",goal)
			
		players[i].start(tem)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func draw_card() -> String:
	return all_mahjong_tiles.pop_back()
	
func send_action():
	
	pass

func next_player():
	if gameover == true : inti()
	else : return
	var player_name = ["H1","H2","H3","H4"]
	var skip_event : bool 
	var players_event : Array
	draw_one = true
	while true:
		
		players_event = [[false,false,false],  # 槓 碰 吃
						[false,false,false],
						[false,false,false],
						[false,false,false]]
		skip_event = false
		var player_ = players[round % players_count]
		player_.turn(draw_one)
		if gameover : break
		draw_one = true
		await player_.finished
		if player_.user == "gpt" :
			gptdrawcard[Global.sort_mahjong_tiles[Discard_card.排型] ]+=1
			
		#Discard_card : player_.finished -> Discard_card會獲得值(打出的牌
		
		for i in range(3):
			if gameover : break
			var tem_turn = (round + players_count - 1 - i) % players_count
			var tem_player_ = players[tem_turn]
			var sequence:Array   =  tem_player_.sequence# 吃判定
			var triplet:Array    =  tem_player_.triplet# 碰判定
			var kong:Array       =  tem_player_.kong#槓判定
			var ready_hand:Array =  tem_player_.ready_hand # 聽牌
			
			if ready_hand.find(Discard_card.排型) != -1:
				print("遊戲結束，放槍的是" + player_name[round % players_count] + "放槍的牌是" + Discard_card.排型 + "獲勝的是" + player_name[tem_turn])
				if player_name[round % players_count] == "H1" : 
					gptinfo["lose"] += 1
				if player_name[tem_turn] == "H1" : 
					gptinfo["win"] += 1
				gameover = true
		
			if kong.find(Discard_card.排型) != -1 :
				players_event[tem_turn][0] = true

			if triplet.find(Discard_card.排型) != -1 :
				players_event[tem_turn][1] = true
	
			if i == 2 and sequence.find(Discard_card.排型) != -1 :
				players_event[tem_turn][2] = true

				
				
		for i in range(3):
			if gameover or skip_event: break
			
			var tem_turn = (round + players_count - 1 - i) % players_count
			var tem_player_ = players[tem_turn]
			
			var temp : bool = false
			for j in players_event[tem_turn]:
				temp = temp or j 
			if not temp : continue
			
			var players_choice = await tem_player_.send_special_events(players_event[tem_turn],Discard_card)  #給做選擇
			
			if players_choice[0] and  tem_player_._kong(Discard_card) :
				special_events(player_,tem_player_,tem_turn)
				skip_event = true
				break
				
			if players_choice[1] and   tem_player_._bump(Discard_card) :
				draw_one = false
				special_events(player_,tem_player_,tem_turn)
				skip_event = true
				break
				
			if i == 2 and players_choice[2]  :
				draw_one = false
				var eat_choice:Array = tem_player_.Eat_combo(Discard_card)
				tem_player_._eat(Discard_card,eat_choice)
				special_events(player_,tem_player_,tem_turn)
				skip_event = true
				break
		
		round += 1
		
		
		await  get_tree().create_timer(1).timeout
		if all_mahjong_tiles.size() == 0 :
			print("clear")
			break
		
		if gameover == true:
			for i in players :
				if i.user ==  "gpt" : 
					i.gameover_from_gpt()
					
			break
	gptinfo["draw_card"].append(gptdrawcard.duplicate(true))
	print(gptinfo)
	var model_name = "gpt-4o-無策略"
	var Main_mem_path = "user://mem/" + "gpt/" + model_name + ".json"
	gptinfo["round"] += 1
	write_json_file(gptinfo,Main_mem_path)
	pass
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("next")  :  next_player()
	
		
	
func special_events(player_,tem_player_,tem_turn):
	
	var ch = player_.Abandon_card_container_f.get_child(-1)
	player_.Abandon_card_container_f.remove_child(ch)
	player_.Abandon_card.erase(ch.排型)
	tem_player_.other_card.add_child(ch)
	
	round = tem_turn - 1

func write_json_file(data:Dictionary,path:String):
	
	var json := JSON.stringify(data)
	var file := FileAccess.open(path,FileAccess.WRITE)
	if not file:
		return
	file.store_string(json)
	
func create_folder(folder_path: String) -> void:
	var dir = DirAccess.open("user://")
	
	if not dir.dir_exists(folder_path):
		if dir.make_dir_recursive(folder_path) :
			print("Folder created at: ", folder_path)
