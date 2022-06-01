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
        GD.Print(("Shell Ready"));
        CallDeferred("Init");
    }

    private void Init()
    {
        // Ensure the background is black
        RenderingServer.SetDefaultClearColor(new Color(0f, 0f, 0f));
        
        // Create a game wide camera 
        this.CreateOffsetCamera();

        // Set the scene to loading
        this.LoadMainMenu();
    }

    private void CreateOffsetCamera()
    {
        // Set the scene to loading
        Camera2D camera = new Camera2D();
        camera.Position = new Vector2(-75, 0);  
        camera.AnchorMode = Camera2D.AnchorModeEnum.FixedTopLeft;
        camera.Name = "OffsetCamera";
        camera.Current = true;
        GetTree().Root.AddChild(camera);

        GD.Print(("CreateOffsetCamera"));
    }

    public void LoadMainMenu()
    {
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
