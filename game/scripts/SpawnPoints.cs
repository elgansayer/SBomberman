using Godot;
using System;

[Tool]
public partial class SpanPoints : EditorScript
{
	[Export]
	private Vector2[] Rock;

    // Called when the node enters the scene tree for the first time.
    public override void _Run()
    {
        GD.Print("Hello from the Godot Editor!")
    }
}
