using Godot;
using System;
using System.Collections.Generic;

public partial class Stage : Node2D
{
    [Export] private NodePath TileMapPath;
    public List<Vector2i> ExplodableRocks
    {
        get
        {
            return this.explodableRocks;
        }
        set
        {
            this.explodableRocks = value;
            TileMapaNode.SpawnRocks(this.explodableRocks);
        }
    }

    public TileMap TileMapaNode { get; private set; }

    private List<Vector2i> explodableRocks;

    // Called when the node enters the scene tree for the first time.
    public override void _Ready()
    {
        this.TileMapaNode = GetNode(this.TileMapPath) as TileMap;

        if (Multiplayer.IsServer())
        {
            this.GenerateRocks();
        }
    }

    private List<Vector2i> GenerateRocks()
    {
        GD.Print("GenerateRocks");
        // long id = ResourceLoader.GetResourceUid(Player.resource_path        
        this.ExplodableRocks = TileMapaNode.GenerateRockPositions();        
        return this.ExplodableRocks;
    }


    // Called every frame. 'delta' is the elapsed time since the previous frame.
    public override void _Process(float delta)
    {
    }
}
