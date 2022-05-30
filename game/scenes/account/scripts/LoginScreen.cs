using Godot;
using System;
using System.Threading.Tasks;

public partial class LoginScreen : Node2D
{
    [Export] public NodePath TxtEmailNode;
    [Export] public NodePath TxtPasswordNode;

    [Export] public NodePath LoginButtonNode;
    [Export] public NodePath CreateAccountButtonNode;
    [Export] public NodePath SubmitButtonNode;

    [Export] public NodePath LblErrorNode;

    [Export] public NodePath LblUsernameNode;
    [Export] public NodePath TxtUsernameNode;


    [Signal]
    delegate void MySignal();

    public override void _Ready()
    {
        // Hide the username fields
        this.onLoginButtonPressed();

        // Handle button pressed
        Button loginButton = GetNode<Button>(this.LoginButtonNode);
        loginButton.ButtonDown += onLoginButtonPressed;

        Button createButton = GetNode<Button>(this.CreateAccountButtonNode);
        createButton.ButtonDown += onCreateAccountButtonPressed;

        Button submitButton = GetNode<Button>(this.SubmitButtonNode);
        submitButton.ButtonDown += onSubmitPressedAsync;

        this.loadLoginDetails();

        GD.Print(("LoginScreen Ready"));

    }

    private void loadLoginDetails()
    {
        Preferences preferences = GetNode("/root/Preferences") as Preferences;
        AccountInfo account = preferences.LoadAccount();

        LineEdit emailNode = GetNode<LineEdit>(this.TxtEmailNode);
        LineEdit passwordNode = GetNode<LineEdit>(this.TxtPasswordNode);

        emailNode.Text = account.Email;
        passwordNode.Text = account.Password;
    }

    public void SetError(string error)
    {
        Label LblError = GetNode<Label>(this.LblErrorNode);
        LblError.Text = error;
    }



    public void onCreateAccountButtonPressed()
    {
        GetNode<Label>(this.LblUsernameNode).Visible = true;
        GetNode<LineEdit>(this.TxtUsernameNode).Visible = true;
    }

    public void onLoginButtonPressed()
    {
        GetNode<Label>(this.LblUsernameNode).Visible = false;
        GetNode<LineEdit>(this.TxtUsernameNode).Visible = false;
    }

    // Called every frame. 'delta' is the elapsed time since the previous frame.
    public async void onSubmitPressedAsync()
    {
        GD.Print("onSubmitPressed");

        LineEdit emailNode = GetNode<LineEdit>(this.TxtEmailNode);
        LineEdit passwordNode = GetNode<LineEdit>(this.TxtPasswordNode);
        LineEdit usernameNode = GetNode<LineEdit>(this.TxtUsernameNode);

        string email = emailNode.Text;
        string password = passwordNode.Text;
        string username = usernameNode.Text;

        if (email == "")
        {
            emailNode.GrabFocus();
            return;
        }

        if (password == "")
        {
            passwordNode.GrabFocus();
            return;
        }

        // If the username field is visible, then we are creating an account
        bool createNew = GetNode<Label>(this.LblUsernameNode).Visible;
        if (createNew)
        {
            if (username == "")
            {
                usernameNode.GrabFocus();
                return;
            }
        }
        else
        {
            username = null;
        }

        // We have login details. So attempt!
        GD.Print(("Attempting login"));
        bool loggedIn = await this.CheckLoggedIn(email, password, username, createNew);

        GD.Print(("Logged in: ", loggedIn));
        if (!loggedIn)
        {
            Network network = GetNode("/root/Network") as Network;
            this.SetError(network.LastError);
            return;
        }

        Preferences preferences = GetNode("/root/Preferences") as Preferences;
        preferences.SaveAccount(email, password);

        this.GetParent().RemoveChild(this);
        GD.Print("float delta " + email + " " + password);
    }

    private async Task<bool> CheckLoggedIn(string email, string password, string username, bool createNew)
    {
        GD.Print(("Checking logged in"));
        Game game = GetNode("/root/Game") as Game;
        game.ShowLoadingScreen();

        Network network = GetNode("/root/Network") as Network;

        if (network == null)
        {
            GD.Print("Failed to get network object");
            return false;
        }

        bool loggedIn = await network.Login(email, password, username, createNew);
        game.HideLoadingScreen();
        return loggedIn;
    }
}

