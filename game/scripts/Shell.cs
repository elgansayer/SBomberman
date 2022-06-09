using Godot;
using Network;
using System;

public partial class Shell : Node2D
{
    // [Export] private PackedScene[] StageScenes;
    // [Export] private PackedScene LoadingScene;
    // [Export] private PackedScene MainMenuScene;
    // [Export] private PackedScene NetworkServerScene;

    protected bool IsServer = false;

    // public NetworkMessenger networkMessenger { get; private set; }

    [Export]
    public PackedScene ClientGameSetupScene { get; set; }
    [Export]
    public PackedScene ServerScene { get; set; }

    // Called when the node enters the scene tree for the first time.
    public override void _Ready()
    {
        GD.Print(("Shell Ready"));
        CallDeferred(nameof(this.InitNetwork));
    }

    private void InitNetwork()
    {
        GD.Print(what: ("InitNetwork"));
        this.IsServer = this.getServerCmdlineArgs();

        // var networkMessenger = as Network.NetworkMessenger();
        // GetTree().Root.AddChild(networkMessenger);

        if (this.IsServer)
        {
            GD.Print(what: ("Shell IsServer"));
            this.InitServer();
        }
        else
        {
            GD.Print(("Shell IsClient"));
            this.InitClient();
        }
    }

    public bool getServerCmdlineArgs()
    {
        GD.Print("Game ready GetCmdlineArgs");
        string[] args = OS.GetCmdlineArgs();
        GD.Print(what: args);

        bool exists = Array.Exists(array: args, element => element == "--server");
        if (exists)
        {
            foreach (string arg in args)
            {
                GD.Print("Arg is :\"" + arg + "\"");
            }
        }

        return exists;
    }

    private void InitServer()
    {
        GD.Print("Game InitServer");
        PackedScene scene = this.ServerScene;
        Network.Server isntance = scene.Instantiate() as Network.Server;
        GetTree().Root.AddChild(isntance);
        isntance.Setup();
    }

    private void InitClient()
    {
        // Set the scene to loading
        // this.LoadMainMenu();
        // Temp just add and try to create a client
        // PackedScene scene = this.MainMenuScene;
        // Game _game = GetNode("/root/Game") as Game;
        // GetTree().Root.AddChild(scene.Instantiate());
        // PackedScene scene = this.MainMenuScene;
        // Game _game = GetNode("/root/Game") as Game;
        // _game.LoadStage(stagePath: scene.ResourcePath);

        PackedScene scene = this.ClientGameSetupScene;
        // Game game = GetNode("/root/Game") as Game;
        GetTree().Root.AddChild(scene.Instantiate());
    }

    // public void LoadStage()
    // {
    //     PackedScene stage1 = this.StageScenes[0];
    //     Game _game = GetNode("/root/Game") as Game;
    //     _game.LoadStage(stage1.ResourcePath);
    // }
}
