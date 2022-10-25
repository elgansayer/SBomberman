using Godot;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Numerics;

class Sectiondddd
{
    Vector2i Position;
    int cell;
    Vector2i dPosition;
}

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

    public Dictionary<Vector2i, List<Vector2i>> GetExplodableRockFlags()
    {
        List<ExplodableRock> rocks = new List<ExplodableRock>(this.ExplodableRocks);
        rocks.Sort(delegate (ExplodableRock rockA, ExplodableRock rockB)
        {
            Vector2i gridPositionA = this.TileMap.WorldToMap(rockA.GlobalPosition);
            int cellPosA = this.TileMap.GridToCellId(gridPositionA);

            Vector2i gridPositionB = this.TileMap.WorldToMap(rockB.GlobalPosition);
            int cellPosB = this.TileMap.GridToCellId(gridPositionB);

            return cellPosA.CompareTo(cellPosB);
        });

        Dictionary<Vector2i, List<Vector2i>> sections = new Dictionary<Vector2i, List<Vector2i>>();

        int sectionSize = 16;
        int times = rocks.Count / sectionSize;
        // for (int p = 0; p < times; p++)
        // {
        //     int explodableRockFlags = 0;
        //     for (int i = 0; i < sectionSize; i++)
        //     {
        for (int i = 0; i < rocks.Count; i++)
        {
            ExplodableRock rock = rocks[i];
            Vector2i gridPosition = this.TileMap.WorldToMap(rock.GlobalPosition);
            GD.Print("rock         " + gridPosition.ToString());

            int sectorX = gridPosition.x / sectionSize;
            int sectorY = gridPosition.y / sectionSize;

            Vector2i section = new Vector2i(sectorX, sectorY);

            int newX = sectionSize - (gridPosition.x % sectionSize);
            int newY = sectionSize - (gridPosition.y % sectionSize);

            Vector2i sectionGridPos = new Vector2i(newX, newY);

            if (!sections.ContainsKey(section))
            {
                sections.Add(section, new List<Vector2i>());
            }

            sections[section].Add(sectionGridPos);
            // sections[section].Add(gridPosition);

            int cellPos = this.TileMap.GridToCellId(gridPosition);
            int flag = this.TileMap.CellIdToBitFlag(cellPos);
            // explodableRockFlags |= flag;

            // GD.Print("gridPosition " + gridPosition.ToString() + " cellPos " + cellPos + " new cellPos " + cellPos + " flag " + flag);
        }

        // GD.Print("Flags " + p + " " + explodableRockFlags);
        // flagsFound.Add(explodableRockFlags);
        // }

        foreach (KeyValuePair<Vector2i, List<Vector2i>> item in sections)
        {
            GD.Print("Section " + item.Key.ToString() + " " + item.Value.Count);
            foreach (Vector2i pos in item.Value)
            {
                GD.Print("         " + pos.ToString());
            }
        }

        return sections;
    }

    public void SyncExplodableRocks(Dictionary<Vector2i, List<Vector2i>> explodableRockFlags)
    {
        // if (explodableRockFlags < 0)
        // {
        //     return;
        // }

        // foreach (ExplodableRock item in this.ExplodableRocks.ToList())
        // {
        //     item.Remove();
        // }

        // this.ExplodableRocks.Clear();

        // this.ExplodableRocks = TileMap.SpawnExplodableRocksFromFlags(explodableRockFlags);
        List<Vector2i> explodableRocks = new List<Vector2i>();

        int sectionSize = 16;
        foreach (KeyValuePair<Vector2i, List<Vector2i>> item in explodableRockFlags)
        {
            int sectorX = item.Key.x / sectionSize;
            int sectorY = item.Key.y / sectionSize;
            Vector2i section = new Vector2i(sectorX, sectorY);

            foreach (var gridPos in item.Value)
            {
                Vector2i pos = new Vector2i(section.x * sectionSize + gridPos.x, section.y * sectionSize + gridPos.y);
                explodableRocks.Add(pos);
            }
        }

        this.ExplodableRocks = TileMap.SpawnExplodableRocks(explodableRocks);
    }
}
