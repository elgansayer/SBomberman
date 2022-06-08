using Godot;

public partial class Game : Node2D
{

    public void LoadStage(string stagePath)
    {
        GetTree().ChangeScene(stagePath);
    }

    public void HideLoadingScreen()
    {
        Node2D loadingNode = GetTree().Root.GetNode<Node2D>("LoadingScreen");
        loadingNode.Visible = false;
        loadingNode.ZIndex = 0;
    }

    public void ShowLoadingScreen()
    {
        Node2D loadingNode = GetTree().Root.GetNode<Node2D>("LoadingScreen");
        loadingNode.Visible = true;
        int index = GetTree().Root.GetChildren().Count + 1;
        loadingNode.ZIndex = index;
    }
}