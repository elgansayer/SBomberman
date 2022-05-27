using System;
using System.Linq;
using Godot;
using Array = Godot.Collections.Array;

public partial class rocks : Node2D
{
    private Node2D _world;
    private Node _hardBlocks;

    [Export] private PackedScene Rock;

    [Export] private NodePath world;

    [Export] private NodePath hardBlocks;

    // Called when the node enters the scene tree for the first time.
    public override void _Ready()
    {
        return;
        GD.Print("Rocks Ready");

        _world = GetNode<Node2D>(world);
        _hardBlocks = GetNode<Node>(hardBlocks);

        // Call spawn rocks on ready frame done
        CallDeferred("SpawnRocks");
    }

    public void SpawnRocks()
    {
        // GD.Print("Rocks SpawnRocks");
        Node spawnPointsNodes = _world.GetNode("SpawnPoints");
        // GD.Print("SpawnPointsNodes", spawnPointsNodes);
        SpawnPoint[] spawnPoints = spawnPointsNodes.GetChildren().Cast<SpawnPoint>().ToArray();
        // GD.Print("spawnPoints", spawnPoints);
        Vector2 mapSize = (Vector2)_world.Get("level_grid_size");
        Vector2 mapOffset = (Vector2)_world.Get("level_offset");
        // GD.Print("Rocks mapSize", mapSize);

        long gridSize = (long)_world.Get("grid_size");
        float gridSquare = gridSize / 2;

        // GD.Print("Rocks gridSize", gridSize);
        Array softBlockInfo = (Array)_world.Get("soft_block_info");

        // GD.Print("Rocks softBlockInfo ", softBlockInfo.GetType());
        // GD.Print("Rocks softBlockInfo ", softBlockInfo);
        // GD.Print("Rocks mapSize ", mapSize);
        // GD.Print("Rocks gridSize ", gridSize);

        softBlockInfo = CLearSoftRocks(mapSize, softBlockInfo);

        int index = 0;
        for (var iy = 0; iy < mapSize.y; iy++)
        {
            for (var ix = 0; ix < mapSize.x; ix++)
            {
                Vector2 gridPos = new Vector2(ix, iy);
                bool hasHardBlock = this.hasHardBlock(gridPos);
                bool hasSpawnBlock = this.hasSpawnPoint(spawnPoints, gridPos);

                if (hasHardBlock || hasSpawnBlock)
                {
                    continue;
                }

                SpawnRock(gridPos);
                index++;
            }
        }
    }

    private bool hasHardBlock(Vector2 gridPos)
    {
        StaticBody2D[] hardBlocks = _hardBlocks.GetChildren().Cast<StaticBody2D>().ToArray();
        StaticBody2D hardBlock = hardBlocks.FirstOrDefault(item =>
        {
            Vector2 itemPos = (Vector2)item.Get("position");
            Vector2 itemGridPos = World.ToGridPosition(itemPos);                     
            return itemGridPos == gridPos;
        });

        return hardBlock != null;
    }

    private bool hasSpawnPoint(SpawnPoint[] spawnPoints, Vector2 gridPos)
    {
        SpawnPoint spawnPoint = spawnPoints.FirstOrDefault(item =>
        {
            Vector2 itemPos = (Vector2)item.Get("position");               
            Vector2 itemGridPos = World.ToGridPosition(itemPos);         
            return itemGridPos == gridPos;
        });

        // GD.Print("spawnPoint ", spawnPoint);
        return spawnPoint != null && !spawnPoint.used;
    }

    // private CreateRock(spawnPoints, int index, int ix, int iy)
    // {
    //     Random rand = new Random();
    //     float randomFloat = (float)rand.NextDouble();

    //     // float chance = (float)softBlockInfo[index];
    //     // // GD.Print("Ro5frv55iu';lo65t6cks chance ", index, " ", chance);
    //     // if (chance < randomFloat)
    //     // {
    //     //     index++;
    //     //     return;
    //     // }

    //     SpawnRock(gridPos);
    //     index++;
    // }

    public Array CLearSoftRocks(Vector2 mapSize, Array softBlockInfo, int maxBlockToClear = 40)
    {
        int length = softBlockInfo.Count - 1;
        int count = 0;

        while (count < maxBlockToClear)
        {
            Random rand = new Random();
            int index = rand.Next(0, length);

            float chance = (float)softBlockInfo[index];
            if (chance > 0.0f)
            {
                softBlockInfo[index] = 0.0f;
                count++;
            }
        }

        return softBlockInfo;
    }

    public void SpawnRock(Vector2 gridPos)
    {
        Node2D rock = (Node2D)Rock.Instantiate();
        Vector2 rockPos = World.ToGlobalPosition(gridPos);
        _world.AddChild(rock);
        rock.Position = rockPos;
    }
}