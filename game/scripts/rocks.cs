using Godot;
using System;

public partial class rocks : Node
{
    [Export]
    private PackedScene Rock;

    [Export]
    private NodePath world;
    private Node2D _world;

    // Called when the node enters the scene tree for the first time.
    public override void _Ready()
    {
        _world = GetNode<Node2D>(world);
        GD.Print("Rocks Ready");
        // SpawnRocks();
        CallDeferred("SpawnRocks");
    }

    // Called every frame. 'delta' is the elapsed time since the previous frame.
    public override void _Process(float delta)
    {
    }

    public void SpawnRocks()
    {
        GD.Print("Rocks SpawnRocks");
        Vector2 mapSize = (Vector2)_world.Get("level_size");
        Vector2 mapOffset = (Vector2)_world.Get("level_offset");
        GD.Print("Rocks mapSize", mapSize);

        long gridSize = (long)_world.Get("grid_size");
        float gridSquare = gridSize / 2;

        GD.Print("Rocks mapSize", mapSize);
        GD.Print("Rocks gridSize", gridSize);

        GD.Print(mapSize);
        for (int i = 0; i < mapSize.x; i++)
        {
            for (int p = 0; p < 2; p++)
            {
                float x = mapOffset.x + (i * gridSize - gridSquare);
                float y = mapOffset.y + (p * gridSize - gridSquare);
                Vector2 pos = new Vector2(x, y);
                GD.Print("Rocks pos", pos);
                this.SpawnRock(pos);
            }
        }
    }

    public void SpawnRock(Vector2 pos)
    {
        var rock = (Node2D)Rock.Instantiate();
        _world.AddChild(rock);
        rock.Position = pos;
    }
}
