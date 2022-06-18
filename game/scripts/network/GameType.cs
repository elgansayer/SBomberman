using Godot;
using System;
using System.Threading.Tasks;

namespace Network
{
    [Serializable]
    public enum GameType
    {
        Unknown,
        NormalMostWins,
        BestScoreKillsAndWins,
        GoldBomber,
        DeathMatchMostKills,
        Virus
    }
}