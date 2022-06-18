using Godot;
using System;
using System.Collections.Generic;
using System.Linq;

public partial class TileMap : Godot.TileMap
{
    [Export] private PackedScene ExplodableRockNode;
    [Export] private NodePath WorldNode;

    public enum TileMapLayers
    {
        OuterWalls,
        HardRocks,
        SpawnPoints,
        ExplodableBlocks
    }

    // Called when the node enters the scene tree for the first time.
    public override void _Ready()
    {
        // Hide our layer but leave it active
        Color hiddenColour = new Color(0, 0, 0, 0);
        this.SetLayerModulate((int)TileMapLayers.OuterWalls, hiddenColour);

        // Disable layers we don't want to see
        this.SetLayerEnabled((int)TileMapLayers.SpawnPoints, false);
        this.SetLayerEnabled((int)TileMapLayers.ExplodableBlocks, false);
    }

    /**
    * Spawns explodable soft rock tiles in the map
    */
    public List<Vector2i> GenerateRockPositions()
    {
        List<Vector2i> allHardTiles = this.GetAllTiles(TileMapLayers.HardRocks);
        List<Vector2i> allSoftTiles = this.GetAllTiles(TileMapLayers.ExplodableBlocks);

        // If an actor is spawning on this tile, don't spawn a rock
        List<SpawnPoint> usedSpawnTiles = this.GetAllSpawnPoints().Where((tile) => tile.Used).ToList();
        List<Vector2i> allSpawnTiles = usedSpawnTiles.ConvertAll((tile) => tile.Position).ToList();

        List<Vector2i> actualSoftBlocks = allSoftTiles.Where((tile) =>
            !allHardTiles.Contains(tile) &&
            !allSpawnTiles.Contains(tile)).ToList();

        int maxRemove = 40;
        for (int i = 0; i < maxRemove; i++)
        {
            Random rand = new Random();
            int randomInt = (int)rand.Next(0, actualSoftBlocks.Count);
            actualSoftBlocks.RemoveAt(randomInt);
        }

        return actualSoftBlocks;
    }

    public void SpawnRocks(List<Vector2i> actualSoftBlocks)
    {
        this.ClearLayer((int)TileMapLayers.ExplodableBlocks);
        foreach (Vector2i softBlock in actualSoftBlocks)
        {
            this.SpawnRock(softBlock);
        }
    }

    /**
    * Spawns a rock at the given tile position
    */
    public void SpawnRock(Vector2i gridPos)
    {
        Node2D world = GetNode<Node2D>(this.WorldNode);
        Node2D rock = (Node2D)this.ExplodableRockNode.Instantiate();
        Vector2 rockPos = this.MapToWorld(gridPos);
        world.AddChild(node: rock);
        rock.Position = rockPos;
    }

    /**
    * Returns a list of all tiles in the given layer
    */
    public List<Vector2i> GetAllTiles(TileMapLayers layerId)
    {
        Godot.Collections.Array usedCells = this.GetUsedCells((int)layerId);
        return usedCells.OfType<Vector2i>().ToList();
    }

    /** 
    * Returns a list of all spawn points in the map
    */
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
