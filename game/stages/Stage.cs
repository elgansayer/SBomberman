using Godot;
using System;
using System.Collections.Generic;
using System.Linq;

public partial class Stage : Node2D
{
    [Export] public NodePath TileMapPath;

    public ExplodableRockList ExplodableRocks { get; private set; } = new ExplodableRockList();

    public List<SpawnPoint> SpawnPoints { get; private set; } = new List<SpawnPoint>();

    public TileMap TileMap { get; private set; }

    // Called when the node enters the scene tree for the first time.
    public override void _Ready()
    {
        this.TileMap = GetNode(this.TileMapPath) as TileMap;

        if (Multiplayer.IsServer())
        {
            GD.Print("Generate Explodable Rocks");
            this.SpawnPoints = this.TileMap.GetAllSpawnPoints();
            this.ExplodableRocks = this.TileMap.GenerateAndSpawnRocks();
            this.ExplodableRocks.RemoveRandomTiles();
        }

        GD.Print("Stage Ready");
    }

    public long GetExplodableRockFlags()
    {
        long explodableRockFlags = 0;
        for (int i = 0; i < this.ExplodableRocks.Count; i++)
        {
            ExplodableRock rock = this.ExplodableRocks[i];
            Vector2i gridPosition = this.TileMap.WorldToMap(rock.GlobalPosition);
            int cellPos = this.TileMap.GridToCell(gridPosition);
            long flag = this.TileMap.CellToBitFlag(cellPos);
            explodableRockFlags = explodableRockFlags | flag;
        }

        return explodableRockFlags;
    }

    public void SyncExplodableRocks(long explodableRockFlags)
    {
        if (explodableRockFlags < 0)
        {
            return;
        }

        // foreach (ExplodableRock item in this.ExplodableRocks.ToList())
        // {
        //     item.Remove();
        // }

        // this.ExplodableRocks.Clear();

        this.ExplodableRocks = TileMap.SpawnExplodableRocksFromFlags(explodableRockFlags);

        // this.ExplodableRocks = TileMap.SpawnExplodableRocks(explodableRocks);
    }
}
