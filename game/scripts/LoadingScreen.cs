using Godot;
using System;

public partial class LoadingScreen : Node
{
	private string loadingScreenPath = "res://game/scenes/LoadingScreen.tscn";
	// Called when the node enters the scene tree for the first time.
	public override void _Ready()
	{
		// uid://c2qc7r8ntghvb
		PackedScene scene = GD.Load<PackedScene>(this.loadingScreenPath);
		Node instance = scene.Instantiate();
		GetTree().Root.AddChild(instance);
	}
}
