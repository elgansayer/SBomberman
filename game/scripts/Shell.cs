using Godot;
using System;

public partial class Shell : Node2D
{
    [Export] private PackedScene[] StageScenes;
    [Export] private PackedScene LoadingScene;
    [Export] private PackedScene MainMenuScene;

    // Called when the node enters the scene tree for the first time.
    public override void _Ready()
    {
        this.Init();
    }

    private void Init()
    {
        // Set the scene to loading
        PackedScene scene = this.MainMenuScene;
        Game _game = GetNode("/root/Game") as Game;
        _game.LoadStage(scene.ResourcePath);
    }

    public void LoadStage()
    {
        PackedScene stage1 = this.StageScenes[0];
        Game _game = GetNode("/root/Game") as Game;
        _game.LoadStage(stage1.ResourcePath);
    }
}
