using Godot;
using System;

public partial class Main : Node2D
{
    [Export] private PackedScene[] WorldNodes;

    // Called when the node enters the scene tree for the first time.
    public override void _Ready()
    {
        this.LoadStage();
    }

    public void LoadStage()
    {
        PackedScene stage1 = this.WorldNodes[0];
        Game _game = GetNode("/root/Game") as Game;
        _game.LoadStage(stage1.ResourcePath);
    }
}
