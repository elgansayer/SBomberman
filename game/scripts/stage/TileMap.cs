using Godot;
using System;
using System.Collections.Generic;
using System.Linq;

public partial class TileMap : Godot.TileMap
{
    [Export] private PackedScene RockNode;
    [Export] private NodePath WorldNode;

    public enum TileMapLayers
    {
        OuterWalls,
        HardRocks,
        SpawnPoints,
        SoftBlocks
    }
    // Called when the node enters the scene tree for the first time.
    public override void _Ready()
    {
        Color hiddenColour = new Color(0, 0, 0, 0);
        this.SetLayerModulate((int)TileMapLayers.OuterWalls, hiddenColour);

        this.SetLayerEnabled((int)TileMapLayers.SpawnPoints, false);
        this.SetLayerEnabled((int)TileMapLayers.SoftBlocks, false);

        // Call spawn rocks on ready frame done
        CallDeferred("SpawnRocks");
    }

    public void SpawnRocks()
    {
        // List<Vector2i> allSpawnTiles = this.GetAllTiles(TileMapLayers.SpawnPoints);
        List<Vector2i> allHardTiles = this.GetAllTiles(TileMapLayers.HardRocks);
        List<Vector2i> allSoftTiles = this.GetAllTiles(TileMapLayers.SoftBlocks);

        List<SpawnPoint> usedSpawnTiles = this.GetAllSpawnPoints().Where((tile) => tile.Used).ToList();
        List<Vector2i> allSpawnTiles = usedSpawnTiles.ConvertAll((tile) => tile.Position).ToList();
        List<Vector2i> actualSoftBlocks = allSoftTiles.Where((tile) => !allHardTiles.Contains(tile) && !allSpawnTiles.Contains(tile)).ToList();
        int maxRemove = 40;

        for (int i = 0; i < maxRemove; i++)
        {
            Random rand = new Random();
            int randomInt = (int)rand.Next(0, actualSoftBlocks.Count);
            actualSoftBlocks.RemoveAt(randomInt);
        }

        foreach (Vector2i softBlock in actualSoftBlocks)
        {
            this.SpawnRock(softBlock);
        }
    }

    public void SpawnRock(Vector2i gridPos)
    {
        Node2D _world = GetNode<Node2D>(this.WorldNode);
        Node2D rock = (Node2D)this.RockNode.Instantiate();
        Vector2 rockGlobalPos = World.ToGlobalPosition(gridPos);
        Vector2 rockPos = World.ToTileCentrePosition(rockGlobalPos);
        _world.AddChild(rock);
        rock.Position = rockPos;
    }

    public List<Vector2i> GetAllTiles(TileMapLayers layerId)
    {
        Godot.Collections.Array usedCells = this.GetUsedCells((int)layerId);
        List<Vector2i> tiles = new List<Vector2i>();

        foreach (var usedCell in usedCells)
        {
            Vector2i spawnPoint = (Vector2i)usedCell;
            Vector2i newSpawnPoint = new Vector2i(spawnPoint.x, spawnPoint.y);
            tiles.Add(newSpawnPoint);
        }

        return tiles;
    }

    public List<SpawnPoint> GetAllSpawnPoints()
    {
        List<Vector2i> allTiles = this.GetAllTiles(TileMapLayers.SpawnPoints);

        return allTiles.ConvertAll((Vector2i tile) =>
        {
            SpawnPoint SpawnPoint = new SpawnPoint(tile);
            return SpawnPoint;
        });
    }
}
