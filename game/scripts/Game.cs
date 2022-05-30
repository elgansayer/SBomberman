using Godot;

public partial class Game : Node2D
{
    public void LoadStage(string stagePath)
    {
        GD.Print(("Game Ready"));
        GetTree().ChangeScene(stagePath);
    }    
    
    public void HideLoadingScreen()
    {
        GD.Print(("Hiding loading screen"));
        Node2D loadingNode = GetTree().Root.GetNode<Node2D>("LoadingScreen");
        loadingNode.Visible = false;
        loadingNode.ZIndex = 0;
    }  
    
    public void ShowLoadingScreen()
    {
        GD.Print("Displaying loading screen");
        Node2D loadingNode = GetTree().Root.GetNode<Node2D>("LoadingScreen");
        loadingNode.Visible = true;
        int index = GetTree().Root.GetChildren().Count + 1;
        loadingNode.ZIndex = index;
    }        
}