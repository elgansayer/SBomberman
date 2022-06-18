using Godot;
using Network;
using System;
using System.Collections.Generic;

public partial class GamePlayNormal : GamePlayBase
{
    public override void _Ready()
    {
        this.Name = "BattleTypeNormal";
        GD.Print("BattleNormal _Ready");
    }

    public GamePlayNormal(Battle battle) : base(battle)
    {
        this.GameType = GameType.NormalMostWins;
    }

    public virtual void OnPeerRegistered()
    {

    }
}