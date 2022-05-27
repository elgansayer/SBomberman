using Godot;

public partial class Game : Node2D
{
    public void LoadStage(string stagePath)
    {
        GetTree().Paused = true;
        GetTree().ChangeScene(stagePath);
    }    
}