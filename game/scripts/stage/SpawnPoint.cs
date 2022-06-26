using Godot;
using Network;
using System;
using System.Collections.Generic;
using System.Linq;

public partial class SpawnPoint 
{
	public bool Used;
	public Vector2i GridPosition;
	public Vector2 Position;

	public SpawnPoint(Vector2i gridPosition, Vector2 position)
	{
		this.GridPosition = gridPosition;
		this.Position = position;
	}
}
