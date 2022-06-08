using System.Collections.Generic;
using Godot;
using Nakama;
using Network;

namespace Network
{
    public partial class Server : Node2D
    {
        public ClientServerHandler clientServerHandler { get; private set; }

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

        public void Setup(ClientServerHandler clientServerHandler)
        {
            GD.Print("Game Server Setup");
            this.clientServerHandler = clientServerHandler;

            this.clientServerHandler.eNet.PeerConnected += this.OnPeerConnected;
            this.clientServerHandler.eNet.PeerDisconnected += this.onPeerDisconnected;

            this.CreateServer();
            this.AddGameType();
        }

        private void CreateServer()
        {
            GD.Print("Game Server Setup CreateServer");
            BattleOptions battleOptions = GetBattleOptions();
            this.clientServerHandler.CreateServer();
        }

        private void AddGameType()
        {
            // Add a game type
            BattleTypeNormal battleType = new BattleTypeNormal(this.clientServerHandler);
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
            this.clientServerHandler.SendRpc("OnPeerConnected");

            // Sent the game info to the player
            // RpcId(id, nameof(this.clientGotBattleOptions), this.battleOptions);
            // var options = new Object[] {this.battleOptions};
            // RpcId(id, nameof(this.RecievedRpc), this.battleOptions);
        }
    }
}