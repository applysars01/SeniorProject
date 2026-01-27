extends Node2D

var System_mem : Dictionary
var Main_mem : Dictionary
var Env_mem : Dictionary
var Short_mem : Dictionary
var Plan_mem : Dictionary
var Goal_mem : Dictionary
var Reflection_mem : Dictionary
var Message : Dictionary
var temQuestion : Array
var _temQuestion : String
var val
var goal_array : Array
var goal_plan : Dictionary

var user = "gpt"
@onready var sendMessage = $send_message
# Called when the node enters the scene tree for the first time.
var pass_info : Array = ["反思:\n","短期記憶體:\n","計畫:\n"]
var erro_responce : Array
signal waitRoundcompelete
signal event_info

func _ready() -> void:
	
	#send_message(Main_mem,"請根據環境記憶體、目標記憶體、計畫記憶體,生成更加完善的目標，生成內容精簡，盡可能20字以內")
	pass

func set_gpt(apiKey:String,model:String = "gpt-4o") -> void:
	$send_message.model = model
	$send_message.apiKey = apiKey
func check_respone(res) -> bool: 
	for i in Global.mahjong_tiles:
		if res.find(i) != -1:
			res = i
			$send_message.set_value(res)
			if $"..".手牌.find(res) == -1 : 
				
				await send_message(temQuestion,_temQuestion,false)
				print("not found")
				return false
	return true



func set_envMem(envMem:String):
	Env_mem = {
		"role": "user",
		"content":  "環境記憶體:\n" + envMem
	}
	update()
	
func set_shortMem(shortMem:String):
	Short_mem.content += (shortMem + "、")
	update()

func update():
	Message["system"] = System_mem
	Message["main"] = Main_mem
	Message["env"] = Env_mem
	Message["short"] = Short_mem
	Message["goal"] = Goal_mem
	Message["plan"] = Plan_mem
	Message["reflect"] = Reflection_mem
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func set_info(name:String,mem:String,goal:Array[String]):
	
	
	var _goal:String = ""
	goal_array = goal
	for i in goal :
		_goal += i + '\n'
	
	var Main_mem_path = "user://mem/" + name + "/Main_mem.sav"
	var Env_mem_path = "user://mem/" + name + "/Env_mem.sav"
	var Short_mem_path = "user://mem/" + name + "/Short_mem.sav"
	#var Goal_mem_path = "user://mem/" + name + "/Goal_mem.sav"
	#var Reflection_mem_path = "user://mem/" + name + "/Reflection_mem.sav"
	
	
	create_folder("user://mem/" + name)
	read_json_file(Main_mem_path)
	
	
	System_mem = {
	  "role": "system",
	  "content": "麻將的基本目標是以最快的方式將手中的牌組成特定的組合達到「胡牌」（獲勝）的條件。通常每位玩家有16(3n + 1)張牌，而在某些情況下得到第17(3n + 2)張牌時，如果符合胡牌條件即可胡牌。以下是主要的組合概念：
		1. **順子**：由三張連續的同花色(條、萬、筒)數字牌組成。例如：
		   - 條子：3條、4條、5條
		   - 萬子：6萬、7萬、8萬
		   - 筒子：1筒、2筒、3筒

		2. **刻子**：由三張相同的牌組成。例如：
		   三個2筒 or 三個中

		3. **眼睛**：最後需要的一對牌，也就是兩張相同的牌，是組成胡牌的必要部分。例如：
		   兩個中 or 兩個8萬

		胡牌通常需要組成五個組合（由順子或刻子或槓組成）加上一對眼睛。當你手中的牌只差一張就能組成這樣的結構時，如果其他玩家打出你需要的那張牌，或者當你自己摸牌時摸到它，你就可以「胡牌」。

		在麻將中，除了基本的組牌和胡牌目標外，還有一些額外的規則和動作可以讓遊戲更具策略性，以下是主要的進階動作規則：

		1. 吃牌
		當其他玩家打出一張牌時，若這張牌能與自己手中的兩張牌組成順子，就可以選擇「吃」這張牌，並將這三張牌公開擺在桌面上，成為自己的牌組一部分。
		吃牌僅能對前一位玩家（即自己上家）打出的牌進行。
		2. 碰牌
		當其他玩家打出一張牌時，若這張牌與自己手中已有的兩張相同牌可以組成刻子，可以選擇「碰」這張牌，並將這三張牌公開放在桌面上。
		碰牌可以對任意玩家打出的牌進行，但碰牌後需要輪到自己出一張牌。
		3. 槓牌
		明槓：當有三張相同的牌在手中時，若其他玩家打出第四張相同牌，就可以選擇「槓」這張牌，將四張牌公開放在桌面上。
		槓牌後玩家可以從牌堆補一張牌，如果補的這張牌剛好使玩家胡牌，則這稱為「槓上開花胡」。
		
		下家，1個回合後的玩家
		對家，2個回合後的玩家
		上家，3個回合後的玩家
		
		下家，他可以吃碰槓你出的牌
		對家，他可以碰槓你出的牌
		上家，他可以碰槓你出的牌
		
		你會在4回合後輪到你
		'從你的手牌'選一張牌丟到棄牌區，請切記只能從'你的手牌'丟牌!!!" 
		
		
	}
	Main_mem = {
		"role": "user",
		"content": "主記憶體:\n" + mem
	}
	Goal_mem = {
		"role": "user",
		"content": "目標記憶體:\n" + _goal
	}
	Reflection_mem = {
		"role": "user",
		"content" : "反思記憶體: "
	}
	Plan_mem = {
		"role": "user",
		"content": "計畫記憶體:\n"
	}
	Env_mem = {
		"role": "user",
		"content":  "環境記憶體:\n"
	}
	
	Short_mem = {
	"role": "user",
	"content": "短期記憶體:\n "
	} 
	
	
	
	
	write_json_file(Main_mem,Main_mem_path)
	write_json_file(Env_mem,Env_mem_path)
	write_json_file(Short_mem,Short_mem_path)
	#write_json_file(Goal_mem,Goal_mem_path)
	#write_json_file(Reflection_mem,Reflection_mem_path)
	update()
	
func _process(delta: float) -> void:
	pass
	
func get_message():
	pass
	
func read_json_file(path:String):
	var file = FileAccess.open(path,FileAccess.READ)
	if not file :
		return
	
	var json := file.get_as_text()
	var data := JSON.parse_string(json) as Dictionary
	
	return data
	
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
	
func send_message(question:Array,_question:String,first_round:bool = true):
	
	update()
	temQuestion = question
	_temQuestion = _question
	
	var tem_message = [] 
	
	for i in question[1] :
		if Message[i].content.length() > 7 :
			
			tem_message.append(Message[i])
			
			
	
	if _temQuestion == "Generate_plan" : 	
		Plan_mem = {
			"role": "user",
			"content": "計畫:\n" 
		}
		Generate_plan(tem_message.duplicate(true),question[0])
		
			
		
	if _temQuestion == "Check_plan":
		Plan_mem = {
			"role": "user",
			"content": "計畫:\n" 
		}
		var plan_val = ""
		for i in goal_array:
			$send_message.set_Message(tem_message)
			#$send_message.append_Message("user",i + "計畫" +goal_plan[i])
			
			$send_message.append_Message("user",question[0])
			sendMessage.CallGPT(true)
			await sendMessage.send_message
			print(sendMessage.get_value())
			plan_val += sendMessage.get_value()
			
		Plan_mem = {
			"role": "user",
			"content": "計畫:\n" + plan_val
		}
	

		
	if _temQuestion == "Discard_a_tile" : 
		
		$send_message.set_Message(tem_message)	
		$send_message.append_Message("user",question[0])
		
		if not first_round :
			
			#for i in erro_responce :
				#$send_message.append_Message("assistant",i)
			
			$send_message.append_Message("user","你回答的內容有誤，請重新回答。")

		
		sendMessage.CallGPT(true)
		await sendMessage.send_message
		val = sendMessage.get_value()
		
		if not await check_respone(sendMessage.get_value()) : 
			erro_responce.append(val)
			return
		erro_responce.clear()
		
		$"..".Discard_a_tile(sendMessage.get_value())
		
		#print(sendMessage.get_value())
	
	if _temQuestion == "event_choice" :
		$send_message.set_Message(tem_message)	
		$send_message.append_Message("user",question[0])
		sendMessage.CallGPT(true)
		await sendMessage.send_message
		val = sendMessage.get_value()
		emit_signal("event_info")
	
	if _temQuestion == "eat_choice" :
		$send_message.set_Message(tem_message)	
		$send_message.append_Message("user",question[0])
		sendMessage.CallGPT(true)
		await sendMessage.send_message
		val = sendMessage.get_value()
		
	if _temQuestion == "Generate_reflection" :
		$send_message.set_Message(tem_message)	
		$send_message.append_Message("user",question[0])
		sendMessage.CallGPT(true)
		await sendMessage.send_message
		val = sendMessage.get_value()
		Reflection_mem = {
			"role": "user",
			"content" : "反思記憶體:\n"  + val
		}
		
	val = sendMessage.get_value()
		
	


func Generate_plan(tem_message,question):
	var plan_val = ""
	
	for i in goal_array:
		$send_message.set_Message(tem_message)
		$send_message.append_Message("user","目標:" + i)
		$send_message.append_Message("user",question)
		sendMessage.CallGPT(false)
		await sendMessage.send_message
		$send_message.clear_Message()
		
		goal_plan[i] = sendMessage.get_value()
		
		plan_val += sendMessage.get_value()
		print(sendMessage.get_value())
		
		Plan_mem = {
			"role": "user",
			"content": "計畫:\n" + plan_val
		}
			
		$send_message.append_Message_json(Plan_mem)
		
	#Plan_mem = {
			#"role": "user",
			#"content": "計畫:\n" + plan_val
		#}
	$send_message.clear_Message()	
	
func get_val():
	return val

func Setting_goal():
	pass

func _on_send_message_busy() -> void:
	#send_message(temQuestion)
	print("hello")


