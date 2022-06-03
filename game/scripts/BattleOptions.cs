using Godot;
using System;
using System.Threading.Tasks;

[Serializable]
public enum GameType
{
    NormalMostWins,
    BestScoreKillsAndWins,
    GoldBomber,
    DeathMatchMostKills,
    Virus
}


[Serializable]
public class BattleOptions
{
    public string BattleName;
    public GameType GameType;
    public int MaxPlayers;
    public int NumBattles;
    public int Time;
    public bool SpawnShuffle;
    public bool Devil;
    public bool MadBomber;

    public int[] Stages;
}
