using Godot;
using System;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System.Threading.Tasks;
using System.Text;
using System.Net.Http;
using HttpClient = System.Net.Http.HttpClient;

public partial class GPTAPI : Node
{
	// Called when the node enters the scene tree for the first time.
	public string massage;

	public async Task SendRequest(string inputMassage) {
		string url = "https://api.openai.com/v1/chat/completions";
		string key = "";
		var messages = new[]
		{
			new { role = "user",content = inputMassage }
		};

		var data = new
		{
			model = "gpt-3.5-turbo",
			messages = messages,
			temperature = 0.7
		};
		
		string jasonString = JsonConvert.SerializeObject(data);
		var content = new System.Net.Http.StringContent(jasonString,Encoding.UTF8,"application/json");
		HttpClient client = new System.Net.Http.HttpClient();
		client.DefaultRequestHeaders.Add("Authorization", "Bearer " + key);
		var response = await client.PostAsync(url, content);
		string responseContent = await response.Content.ReadAsStringAsync();
		var JsonRespones = JObject.Parse(responseContent);
		var assistantMessageContent = JsonRespones["choices"][0]["message"]["content"].Value<string>();
		//GD.Print(jasonString);
		GD.Print(JsonRespones);
		//GD.Print(assistantMessageContent);
		massage = assistantMessageContent;
	}
}
