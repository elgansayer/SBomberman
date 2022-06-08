using Godot;
using System;
using System.Threading.Tasks;

public partial class BattleOptionsScreen : Node2D
{
    [Export] private NodePath TxtBattleNameNode;

    // Called when the node enters the scene tree for the first time.
    public override void _Ready()
    {
        LineEdit txtBattleName = GetNode<LineEdit>(this.TxtBattleNameNode);
        string battleName = txtBattleName.Text;
        Network.NakamaNetwork network = GetNode("/root/NakamaNetwork") as Network.NakamaNetwork;

        Task match = network.CreateMatch(battleName);
    }
}
