using Godot;
using System;

public partial class MainMenu : Node2D
{
    [Export] private PackedScene LoadingScene;
    [Export] private PackedScene LoginScene;

    // Called when the node enters the scene tree for the first time.
    public override void _Ready()
    {
        // CallDeferred("CheckLoggedIn");
    }

    private async void CheckLoggedIn()
    {
        PackedScene scene = this.LoadingScene;
        Game _game = GetNode("/root/Game") as Game;
        _game.LoadStage(scene.ResourcePath);

        Network _network = GetNode("/root/Network") as Network;
        bool loggedIn = await _network?.Login();

        if (!loggedIn)
        {
            // Set the scene to loading
            PackedScene loginScene = this.LoginScene;
            _game.LoadStage(stagePath: loginScene.ResourcePath);
        }
    }
}

