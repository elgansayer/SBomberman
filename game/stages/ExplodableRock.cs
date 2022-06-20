using Godot;
using System;

public partial class ExplodableRock : StaticBody2D
{
    internal void Remove()
    {
        this.GetParent().RemoveChild(this);
        this.QueueFree();
    }
}
