using Godot;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Numerics;

public partial class TileMap : Godot.TileMap
{
    [Export] public PackedScene ExplodableRockNode;
    [Export] public NodePath WorldNode;
    [Export] public int Width;
    [Export] public int Height;

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

    public ExplodableRockList SpawnExplodableRocks(List<Vector2i> gridPositions)
    {
        this.ClearLayer((int)TileMapLayers.ExplodableBlocks);
        List<ExplodableRock> rocks = gridPositions.ConvertAll<ExplodableRock>((Vector2i gridPos) =>
        {
            return this.SpawnRock(gridPos);
        });

        return new ExplodableRockList(rocks);
    }

    internal ExplodableRockList SpawnExplodableRocksFromFlags(int explodableRockFlags)
    {
        // explodableRockFlags = 0;
        // explodableRockFlags |= this.CellToBitFlag(2);

        GD.Print("Spawning Explodable Rocks from flags: " + explodableRockFlags);
        if (explodableRockFlags < 0)
        {
            return new ExplodableRockList();
        }

        List<Vector2i> explodableRockList = new List<Vector2i>();
        for (int x = 0; x < 8; x++)
        {
            for (int y = 0; y < 4; y++)
            {
                Vector2i gridPos = new Vector2i(x, y);
                int cellPos = this.GridToCellId(gridPos);

                int flag = this.CellIdToBitFlag(cellPos);
                bool spawned = (explodableRockFlags & flag) != 0;
                GD.Print("gridPos " + gridPos.ToString() + " CellPos: " + cellPos + " flag: " + flag + " spawned: " + spawned);
                if (spawned)
                {
                    explodableRockList.Add(gridPos);
                }
            }
        }

        return this.SpawnExplodableRocks(explodableRockList);
    }

    public int GridToCellId(Vector2i gridPosition)
    {
        // int cellx = gridPosition.x / 16;
        // int celly = gridPosition.y / 16;
        // int cell = 16 * cellx + celly;

        // int newX = gridPosition.x - ( cellx * 16 );
        // int newY = gridPosition.y - ( celly * 16 );

        // int cellId = 16 * newX + newY;
        // return cellId;
        return this.Width * gridPosition.x + gridPosition.y;
    }

    public int CellIdToBitFlag(int x)
    {
        return (int)(1 << x);
    }

    public Vector2i CellIdToGrid(int cell)
    {
        
        int x = (cell - 1) % this.Width;
        int y = (cell - 1) / this.Width;
        return new Vector2i(x, y);
    }

    /**
    * Spawns a rock at the given tile position
    */
    public ExplodableRock SpawnRock(Godot.Vector2 gridPos)
    {
        Node2D stage = GetNode<Node2D>(this.WorldNode);
        Node node = this.ExplodableRockNode.Instantiate();
        ExplodableRock rock = (ExplodableRock)node as ExplodableRock;
        Godot.Vector2 rockPos = this.MapToWorld((Vector2i)gridPos);
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
