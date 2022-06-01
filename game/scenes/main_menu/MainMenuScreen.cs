using Godot;
using System.Threading.Tasks;

public partial class MainMenuScreen : Node2D
{
    [Export] public PackedScene LoginScene;
    [Export] public PackedScene BattleOptionsScreen;


    // Called when the node enters the scene tree for the first time.
    public override void _Ready()
    {
        GD.Print(("MainMenuScreen Ready"));
        CallDeferred("MainCheckLoggedIn");
    }

    // private async Task<bool> MainCheckLoggedIn()
    // {
    //     GD.Print(("Checking logged in"));
    //     Game game = GetNode("/root/Game") as Game;
    //     game.CheckLoggedIn();
    // }

    private async Task<bool> MainCheckLoggedIn()
    {
        GD.Print(("Checking logged in"));

        Game game = GetNode("/root/Game") as Game;
        Preferences preferences = GetNode("/root/Preferences") as Preferences;
        Network network = GetNode("/root/Network") as Network;

        game.ShowLoadingScreen();

        if (network == null)
        {
            GD.Print("Failed to get network object");
            return false;
        }

        AccountInfo accountInfo = preferences.LoadAccount();

        bool loggedIn = await network.Login(accountInfo.Email, accountInfo.Password);

        if (!loggedIn)
        {
            // Set the scene to loading
            PackedScene loginScene = this.LoginScene;
            game.LoadStage(stagePath: loginScene.ResourcePath);
        }

        game.HideLoadingScreen();
        return loggedIn;
    }

    void _on_btn_battle_pressed()
    {
        GetNode<Control>("UILayer/MainMenu").Visible = false;
        GetNode<Control>("UILayer/BattleMenu").Visible = true;
    }

    void _on_btn_options_pressed()
    {
        Game _game = GetNode("/root/Game") as Game;
        _game.ShowLoadingScreen();

        this.GetParent().RemoveChild(this);
    }

    void _on_btn_account_pressed()
    {
        Game _game = GetNode("/root/Game") as Game;
        _game.ShowLoadingScreen();

        this.GetParent().RemoveChild(this);
    }

    void _on_btn_host_game_pressed()
    {
        Game _game = GetNode("/root/Game") as Game;
        // _game.ShowLoadingScreen();

        _game.LoadStage(this.BattleOptionsScreen.ResourcePath);
    }

    void _on_btn_join_pressed()
    {
        Game _game = GetNode("/root/Game") as Game;
        _game.ShowLoadingScreen();

        this.GetParent().RemoveChild(this);
    }    

    void _on_btn_quick_match_pressed()
    {
        Game _game = GetNode("/root/Game") as Game;
        _game.ShowLoadingScreen();

        this.GetParent().RemoveChild(this);
    }     

    void _on_btn_back_pressed()
    {
        GetNode<Control>("UILayer/MainMenu").Visible = true;
        GetNode<Control>("UILayer/BattleMenu").Visible = false;
    }       
}

