using System.Collections.Generic;
using Godot;
using Nakama;
using Network;

namespace Network
{
    public partial class Server : Node2D
    {
        public NetworkMessenger networkMessenger { get; private set; }

        public ENetMultiplayerPeer eNet { get; private set; }
        protected int playerCount = 0;
        protected int port = 4333;
        protected int maxPlayers = 10;
        public readonly Dictionary<int, PeerInfo> PeerList = new Dictionary<int, PeerInfo>();
        protected string host = "localhost";


        public override void _Ready()
        {
            this.Name = "Server";
        }

        private BattleOptions GetBattleOptions()
        {
            //Todo: Get battle options from nakama        
            BattleOptions battleOptions = new BattleOptions()
            {
                BattleName = "TestBattle",
                GameType = GameType.NormalMostWins,
                MaxPlayers = 4,
                MinPlayers = 2,
                NumBattles = 1,
                Time = 60,
                SpawnShuffle = true,
                Devil = true,
                MadBomber = true,
                Stages = new int[] { 1, 2, 3, 4 }
            };

            return battleOptions;
        }

        public void Setup()
        {
            this.eNet = new ENetMultiplayerPeer();

            GD.Print("Game Server Setup");
            this.networkMessenger = GetNode("/root/NetworkMessenger") as NetworkMessenger;

            this.eNet.PeerConnected += this.OnPeerConnected;
            this.eNet.PeerDisconnected += this.onPeerDisconnected;

            this.CreateServer();
            // this.AddGameType();
        }

        private void CreateServer()
        {
            GD.Print("Game Server Setup CreateServer");
            BattleOptions battleOptions = GetBattleOptions();

            this.eNet.CreateServer(this.port, this.maxPlayers);
            GD.Print("Game Server created server");
            Multiplayer.MultiplayerPeer = this.eNet;
        }

        private void AddGameType()
        {
            // Add a game type
            BattleTypeNormal battleType = new BattleTypeNormal(this);
            GetTree().Root.AddChild(battleType);
            battleType.init();
        }

        public void onPeerDisconnected(int id)
        {
            GD.Print("Game Server OnPeerDisconnected");
            // this.UnregisterPlayer(id);
        }

        public void OnPeerConnected(int id)
        {
            if (id <= 1)
            {
                return;
            }

            GD.Print("Game Server OnPeerConnected");
            this.networkMessenger.SendRpc("OnPeerConnected");

            // Sent the game info to the player
            // RpcId(id, nameof(this.clientGotBattleOptions), this.battleOptions);
            // var options = new Object[] {this.battleOptions};
            // RpcId(id, nameof(this.RecievedRpc), this.battleOptions);
        }
    }
}