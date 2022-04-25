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

    public void SpawnRocks()
    {
        GD.Print("Rocks SpawnRocks");
        Vector2 mapSize = (Vector2)_world.Get("level_grid_size");
        Vector2 mapOffset = (Vector2)_world.Get("level_offset");
        GD.Print("Rocks mapSize", mapSize);

        long gridSize = (long)_world.Get("grid_size");
        float gridSquare = gridSize / 2;

        GD.Print("Rocks gridSize", gridSize);
        Godot.Collections.Array softBlockInfo = (Godot.Collections.Array)_world.Get("soft_block_info");

        GD.Print("Rocks softBlockInfo ", softBlockInfo.GetType());
        GD.Print("Rocks softBlockInfo ", softBlockInfo);
        GD.Print("Rocks mapSize ", mapSize);
        GD.Print("Rocks gridSize ", gridSize);

        GD.Print(mapSize);
        int index = 0;
        for (int iy = 0; iy < mapSize.y; iy++)
        {
            for (int ix = 0; ix < mapSize.x; ix++)
            {
                Random rand = new Random();
                float randomFloat = (float)rand.NextDouble();

                float chance = (float)softBlockInfo[index];
                // GD.Print("Ro5frv55iu';lo65t6cks chance ", index, " ", chance);

                if (chance < randomFloat)
                {
                    index++;
                    continue;
                }

                // GD.Print("Rocks chance ", index, " ", chance);

                // float x = mapOffset.x + (xi * gridSize - gridSquare);
                // float y = mapOffset.y + (yi * gridSize - gridSquare);
                // Vector2 pos = new Vector2(x, y);
                Vector2 gridPos = new Vector2(ix, iy);
                GD.Print("Rocks gridPos ", gridPos); 
                Vector2 pos = (Vector2)_world.Call("get_position_from_grid", gridPos);
                GD.Print("Rocks pos ", pos.GetType());
                this.SpawnRock(pos);
                index++;
            }
        }
    }

    public void SpawnRock(Vector2 pos)
    {
        var rock = (Node2D)Rock.Instantiate();
        _world.AddChild(rock);
        rock.Position = pos;
        GD.Print("Rocks SpawnRock ", pos);
    }
}
