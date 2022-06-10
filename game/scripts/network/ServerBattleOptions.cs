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

    [Serializable]
    public class ServerOptions
    {
        public string BattleName;
        public GameType GameType;
        public int MaxPlayers;
        public int MinPlayers;
        public int NumBattles;
        public int Time;
        public bool SpawnShuffle;
        public bool Devil;
        public bool MadBomber;
        public int[] Stages;
        public int CurrentStageIndex;
    }

}