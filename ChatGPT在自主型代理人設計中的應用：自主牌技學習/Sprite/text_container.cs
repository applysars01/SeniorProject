using Godot;
using System;
using System.Threading.Tasks;

public enum State
{
	Start,
	Running,
	End
}


public partial class text_container : MarginContainer
{
	// Called when the node enters the scene tree for the first time.
	public MarginContainer textContainer;
	public Label start;
	public TextEdit textContent;
	public Label end;
	private GPTAPI getmassage;
	public override void _Ready()
	{
		GD.Print("test");
		textContainer = GetNode <MarginContainer> ("TextContainer");
		start = GetNode<Label>("MarginContainer/HBoxContainer/start");
		textContent = GetNode<TextEdit>("MarginContainer/HBoxContainer/content");
		end = GetNode<Label>("MarginContainer/HBoxContainer/end");
		getmassage = new GPTAPI();

		start.Text = "";
		textContent.Text = "";
		end.Text = "";
	}

	// Called every frame. 'delta' is the elapsed time since the previous frame.
	public override void _Process(double delta)
	{
		if (Input.IsActionJustPressed("back", true)) HideTextBox();
		if (Input.IsActionJustPressed("next", true))
		{
			_ = GetMassage(textContent.Text);
			
		}
	}


	public void HideTextBox()
	{
		start.Text = "";
		textContent.Text = "";
		end.Text = "";
		this.Hide();
	}
	
	public void ShowTextBox(string inputMassage)
	{
		start.Text = "*";
		textContent.Text = inputMassage;
		end.Text = "v";
	}
	private async Task GetMassage(string inputMassage)
	{
		string Massage = "";
		_ = getmassage.SendRequest(inputMassage);
		Massage = getmassage.massage;
		ShowTextBox(Massage);
	   
	}
}





