using Godot;
using System;
using System.Collections.Generic;
using System.Linq;

public partial class SpawnPoint 
{
	public bool Used;
	public Vector2i Position;

	public SpawnPoint(Vector2i position)
	{
		this.Position = position;
	}
}
