using Godot;
using System;

public static class World
{
    public static int gridSquare = 32;

    // Turn a vector node position into a grid position
    public static Vector2 ToGridPosition(Vector2 position)
    {
        int gridX = (int)(position.x / gridSquare);
        int gridY = (int)(position.y / gridSquare);
        return new Vector2(gridX, gridY);
    }

    // Turn a grid position to a world position
    public static Vector2 ToGlobalPosition(Vector2 gridPosition)
    {
        return new Vector2(gridPosition.x * gridSquare, gridPosition.y * gridSquare);
    }
    
    // Turn a grid position to a world position
    public static Vector2 ToTileCentrePosition(Vector2 globalPosition)
    {
        int half = gridSquare / 2;
        return globalPosition + new Vector2(half,half);
    }

    
}
