using System.Collections.Generic;
using Godot;
using Nakama;
using Network;


public partial class ClientSetup : Node2D
{
    [Export] public PackedScene MainMenuScene;
    // [Export] private PackedScene NetworkClientScene;
    [Export] public PackedScene LoadingScene;

    public override void _Ready()
    {
        this.Name = "ClientSetup";

        // Ensure the background is black
        RenderingServer.SetDefaultClearColor(new Color(0f, 0f, 0f));

        // Create a game wide camera 
        this.CreateOffsetCamera();

        GD.Print("NakamaNetwork nakamaNetwork");

        // // Set the scene to loading
        // // this.LoadMainMenu();
        // // Temp just add and try to create a client
        PackedScene scene = this.MainMenuScene;
        Game game = GetNode("/root/Game") as Game;
        game.ChangeScene(scene.Instantiate());

        Network.NakamaNetwork nakamaNetwork = GetNode("/root/NakamaNetwork") as Network.NakamaNetwork;
        nakamaNetwork.OnPeerConnected += this.AddNetworkClient;
    }

    private void AddNetworkClient()
    {
        GD.Print("AddNetworkCLient actually ");

        Game game = GetNode("/root/Game") as Game;
        game.ShowLoadingScreen();
        
        GD.Print("Game InitServer");
        Network.Client Client = GetNode("/root/Client") as Network.Client;
        Client.Connect();
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
    }
}
