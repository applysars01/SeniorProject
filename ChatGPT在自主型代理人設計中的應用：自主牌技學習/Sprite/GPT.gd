extends Node

var url:String = "https://api.openai.com/v1/chat/completions"
var apiKey:String = "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"
var header = ["Content-Type: application/json", "Authorization: Bearer "+ apiKey]
var maxtoken = 128
var temperature = 0.8
var model = "gpt-3.5-turbo"
var httpRequest
var Message = []
var newStr:String
var context 
# Called when the node enters the scene tree for the first time.
func _ready():
	httpRequest = $"../HTTPRequest"
	#add_child(httpRequest)
	#httpRequest.request_completed.connect(self._http_request_completed)
	context = $".."
func insert_message(role:String,message:String):
	Message.append({
		"role":role,
		"content":message,
	})
	print(Message)
	
func CallGPT():
	
	
	var body = JSON.stringify({
		"messages": Message,
		"temperature": temperature,
		"max_tokens": maxtoken,
		"model": model,
		
	}) 
	print(body)
	var err =httpRequest.request(url,header,HTTPClient.METHOD_POST,body)
	if err != OK : push_error("Wrong!")
	
	
	
	
	

	
	
	
	
