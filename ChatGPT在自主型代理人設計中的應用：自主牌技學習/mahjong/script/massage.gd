extends Node
class_name send_message

var url:String = "https://api.openai.com/v1/chat/completions"
var apiKey:String
var header
var maxtoken = 512
var temperature = 0.8
var model="gpt-4o"
@onready var httpRequest = $"../HTTPRequest"
var Message = []
var newStr = []
var val
var clearmessage:bool
var complete :bool = true
signal send_message
signal BUSY

func append_Message(role:String,content:String):
	Message.append({
		"role": role,
	  	"content": content })
			
func append_Message_json(json_content):
	Message.append(json_content)

func set_Message(Message):
	self.Message += Message
	
func clear_Message():
	Message.clear()


func CallGPT(mc = true):
	header = ["Content-Type: application/json", "Authorization: Bearer "+ apiKey]
	complete = false
	
	
	var body = JSON.new().stringify({
		"messages": Message,
		"temperature": temperature,
		"max_tokens": maxtoken,
		"model": model,
	}) 
	#print(body)
	var err =httpRequest.request(url,header,HTTPClient.METHOD_POST,body)
	if err != OK : emit_signal("BUSY")
	clearmessage = mc

func get_value():
	return val

func set_value(val):
	self.val = val

func _on_http_request_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	var response = json.get_data()
	#print(response)
	
	#print(response["choices"][0]["message"]["content"])
	val = response["choices"][0]["message"]["content"]
	if  clearmessage : Message.clear()
	emit_signal("send_message")
