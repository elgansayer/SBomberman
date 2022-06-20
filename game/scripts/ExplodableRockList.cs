using Godot;
using System;
using System.Collections.Generic;

using System.Linq;

public class ExplodableRockList : List<ExplodableRock>
{
    public ExplodableRockList() : base()
    {
    }
    public ExplodableRockList(IEnumerable<ExplodableRock> collection) : base(collection)
    {
    }

    public void AddSpawnPointHole(Vector2i position)
    {
        Vector2i[] spawnPointHolePositions = new Vector2i[]
        {
            position,
            new Vector2i(position.x - 1, position.y),
            new Vector2i(position.x + 1, position.y),
            new Vector2i(position.x, position.y - 1),
            new Vector2i(position.x, position.y + 1)
        };

        this.AddPatternHole(spawnPointHolePositions);
    }

    public void RemoveRandomTiles(int maxRemove = 40)
    {
        for (int i = 0; i < maxRemove; i++)
        {
            Random rand = new Random();
            int randomInt = (int)rand.Next(0, this.Count);
            ExplodableRock node = this.ElementAt(randomInt);
            node.Remove();
            this.RemoveAt(randomInt);
        }
    }

    public List<Vector2i> Positions()
    {
        Node2D node = this.ElementAt(0);
        Network.Battle battle = node.GetTree().Root.GetNode<Network.Battle>("Tournement/Battle") as Network.Battle;

        return this.ConvertAll<Vector2i>((rock) => battle.Stage.TileMap.WorldToMap(rock.GlobalPosition));
    }

    public void AddPatternHole(Vector2i[] positions)
    {
        Node2D node = this.ElementAt(0);
        Network.Battle battle = node.GetTree().Root.GetNode<Network.Battle>("Tournement/Battle") as Network.Battle;
        TileMap tileMap = battle?.Stage.TileMap;

        if (tileMap == null)
        {
            return;
        }

        foreach (var position in positions)
        {
            IEnumerable<ExplodableRock> nodes = this.Where((rock) => tileMap.WorldToMap(rock.GlobalPosition) == position);
            foreach (ExplodableRock rock in nodes.ToList())
            {
                rock.Remove();
                this.Remove(rock);
            }
        }
    }
}