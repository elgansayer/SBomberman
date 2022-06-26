using Godot;
using System;
using System.Collections.Generic;
using System.Linq;

public partial class TileMap : Godot.TileMap
{
    [Export] public PackedScene ExplodableRockNode;
    [Export] public NodePath WorldNode;

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
        // List<SpawnPoint> usedSpawnTiles = spawnTiles.Where((tile) => tile.Used).ToList();
        // List<Vector2i> allSpawnTiles = usedSpawnTiles.ConvertAll((tile) => tile.Position).ToList();

        List<Vector2i> actualSoftBlocks = allSoftTiles.Where((tile) =>
            !allHardTiles.Contains(tile)).ToList();

        return actualSoftBlocks;
    }

    public ExplodableRockList GenerateAndSpawnRocks()
    {
        return this.SpawnExplodableRocks(this.GenerateRockPositions());
    }

    public ExplodableRockList SpawnExplodableRocks(List<Vector2i> rockPositions)
    {
        this.ClearLayer((int)TileMapLayers.ExplodableBlocks);
        List<ExplodableRock> rocks = rockPositions.ConvertAll<ExplodableRock>((Vector2i gridPos) =>
        {
            return this.SpawnRock(gridPos);
        });

        return new ExplodableRockList(rocks);
    }

    /**
    * Spawns a rock at the given tile position
    */
    public ExplodableRock SpawnRock(Vector2 gridPos)
    {
        Node2D stage = GetNode<Node2D>(this.WorldNode);
        Node node = this.ExplodableRockNode.Instantiate();
        ExplodableRock rock = (ExplodableRock)node as ExplodableRock;
        Vector2 rockPos = this.MapToWorld((Vector2i)gridPos);
        stage.AddChild(node: rock);
        rock.Position = rockPos;
        rock.Name = "ExplodableRock" + gridPos.ToString();
        return rock;
    }

    /**
    * Returns a list of all tiles in the given layer
    */
    public List<Vector2i> GetAllTiles(TileMapLayers layerId)
    {
        var usedCells = this.GetUsedCells((int)layerId);
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
            SpawnPoint SpawnPoint = new SpawnPoint(gridPosition: tile, position: this.MapToWorld(tile));
            return SpawnPoint;
        });
    }
}
