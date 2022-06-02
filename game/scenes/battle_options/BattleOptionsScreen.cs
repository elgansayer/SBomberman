using Godot;
using System;
using System.Threading.Tasks;

public partial class BattleOptionsScreen : Node2D
{
	[Export] private NodePath TxtBattleNameNode;

    // Called when the node enters the scene tree for the first time.
    public override void _Ready()
    {
        GD.Print(what: "Battle Options Screen Ready");
		
		LineEdit txtBattleName = GetNode<LineEdit>(this.TxtBattleNameNode);
		string battleName = txtBattleName.Text;		
        Network network = GetNode("/root/Network") as Network;

        Task match = network.CreateMatch(battleName);
    }

}
