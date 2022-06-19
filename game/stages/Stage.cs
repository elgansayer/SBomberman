using Godot;
using System;
using System.Collections.Generic;

public partial class Stage : Node2D
{
    [Export] private NodePath TileMapPath;

    public List<Node2D> ExplodableRocks { get; private set; } = new List<Node2D>();

    public TileMap TileMap { get; private set; }

    // Called when the node enters the scene tree for the first time.
    public override void _Ready()
    {
        this.TileMap = GetNode(this.TileMapPath) as TileMap;

        if (Multiplayer.IsServer())
        {
            GD.Print("Generate Explodable Rocks");
            this.ExplodableRocks = this.TileMap.GenerateAndSpawnRocks();
        }

        GD.Print("Stage Ready");
    }


    // Called every frame. 'delta' is the elapsed time since the previous frame.
    public override void _Process(float delta)
    {
    }
}
