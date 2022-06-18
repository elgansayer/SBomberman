using Godot;
using System;
using System.Threading.Tasks;

namespace Network
{
    [Serializable]
    public class ServerOptions
    {
        public string BattleName { get; private set; }
        public GameType GameType { get; private set; }
        public int MaxPlayers { get; private set; }
        public int MinPlayers { get; private set; }
        public int NumBattles { get; private set; }
        public int Time { get; private set; }
        public bool SpawnShuffle { get; private set; }
        public bool Devil { get; private set; }
        public bool MadBomber { get; private set; }
        public int[] Stages { get; private set; }

        public ServerOptions(string battleName, GameType gameType, int maxPlayers, int minPlayers, int numBattles, int time, bool spawnShuffle, bool devil, bool madBomber, int[] stages)
        {
            this.BattleName = battleName;
            this.GameType = gameType;
            this.MaxPlayers = maxPlayers;
            this.MinPlayers = minPlayers;
            this.NumBattles = numBattles;
            this.Time = time;
            this.SpawnShuffle = spawnShuffle;
            this.Devil = devil;
            this.MadBomber = madBomber;
            this.Stages = stages;
        }
    }

}