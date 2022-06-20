using Godot;
using System;
using System.Collections.Generic;
using System.Linq;

public partial class Stage : Node2D
{
    [Export] private NodePath TileMapPath;

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

    internal void SyncExplodableRocks(List<Vector2i> explodableRocks)
    {
        foreach (ExplodableRock item in this.ExplodableRocks.ToList())
        {
            item.Remove();
        }

        this.ExplodableRocks.Clear();
        this.ExplodableRocks = TileMap.SpawnExplodableRocks(explodableRocks);
    }
}
