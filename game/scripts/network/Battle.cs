using Godot;
using Network;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;

namespace Network
{
    public partial class Battle : Node2D
    {
        [Export] private PackedScene[] stageScenes;
        public Stage Stage;
        private int time = 0;
        private int stageIndex = 0;
        private BattleState state = BattleState.Initializing;

        private Network.Server server;
        private Network.Client client;

        public override void _Ready()
        {
            GD.Print("Battle Ready");

            if (Multiplayer.IsServer())
            {
                GD.Print("Server Battle Ready");

                this.server = GetNode("/root/Server") as Network.Server;
                this.server.OnPeerEntered += this.OnPeerEntered;
                this.server.OnPeerLeft += this.OnPeerLeft;
            }
            else
            {
                GD.Print("Client Battle Ready");

                this.client = GetNode("/root/Client") as Network.Client;
                this.client.OnPeerEntered += this.OnPeerEntered;
                this.client.OnPeerLeft += this.OnPeerLeft;
            }
        }

        public virtual void OnPeerEntered(int peerId)
        {
            GD.Print(what: "Battle OnPeerEntered");
            // Peer has entered the server
            // Tell them to load the map
            // string optionsJson = this.GetStageStateJson();
            // this.Rpc(nameof(this.ClientLoadBattle), optionsJson);

            // We need to add a player to the battle
            // 1 Spawnpoint 
            SpawnPoint spawnPoint = this.getNextSpawnPoint();
            spawnPoint.Used = true;
            this.Stage.ExplodableRocks.AddSpawnPointHole(spawnPoint.Position);

            GD.Print(this.SnapShot);
            GD.Print(this.SnapShot.ToJson());
            this.Rpc(nameof(this.RecievedSnapshot), this.SnapShot.ToJson());
        }

        private SpawnPoint getNextSpawnPoint()
        {

            Tournement tournement = GetNode("/root/Tournement") as Tournement;
            bool SpawnShuffle = tournement.ServerOptions.SpawnShuffle;

            if (SpawnShuffle)
            {
                // Shuffle the spawn points
                List<SpawnPoint> unusedSpawnPoints = this.Stage.SpawnPoints.Where((SpawnPoint spawnPoint) => spawnPoint.Used == false).ToList();
                unusedSpawnPoints.Shuffle();
                foreach (SpawnPoint spawnPoint in this.Stage.SpawnPoints)
                {
                    if (spawnPoint.Used == false)
                    {
                        return spawnPoint;
                    }
                }
            }
            else
            {
                foreach (SpawnPoint spawnPoint in this.Stage.SpawnPoints)
                {
                    if (spawnPoint.Used == false)
                    {
                        return spawnPoint;
                    }
                }
            }

            return null;
        }

        public virtual void OnPeerLeft(int peerId)
        {
            // this.State = TournementState.NotStarted;
        }


        public GamePlayNormal GamePlay { get; private set; }

        public BattleSnapShot SnapShot
        {
            get => this.GetSnapshot();
            set => this.SetSnapshot(value);
        }

        private BattleSnapShot GetSnapshot()
        {
            if (this.Stage == null)
            {
                GD.Print("Battle.GetSnapshot: stage is null");
                return null;
            }


            BattleSnapShot snapShot = new BattleSnapShot(
            this.state,
            this.time,
            this.stageIndex,
            this.Stage.ExplodableRocks.Positions()
            );

            return snapShot;
        }

        [Authority]
        [AnyPeer]
        private void RecievedSnapshot(string battleSnapShotJson)
        {

            BattleSnapShot battleSnapShot = JsonConvert.DeserializeObject<BattleSnapShot>(battleSnapShotJson);
            this.state = battleSnapShot.State;
            this.time = battleSnapShot.Time;
            this.stageIndex = battleSnapShot.StageIndex;

            this.Stage.SyncExplodableRocks(battleSnapShot.ExplodableRocks);
        }

        internal void SetSnapshot(BattleSnapShot battleSnapShot)
        {
            this.state = battleSnapShot.State;
            this.time = battleSnapShot.Time;
            this.stageIndex = battleSnapShot.StageIndex;

            this.Stage.SyncExplodableRocks(battleSnapShot.ExplodableRocks);
        }

        internal void CreateStage(int stageIndex)
        {
            this.stageIndex = stageIndex;

            // Load the stage
            GD.Print("Loading stage: ");

            PackedScene packedScene = this.stageScenes[stageIndex];
            Node node = packedScene.Instantiate();
            this.Stage = node as Stage;
            Game game = GetTree().Root.GetNode("Game") as Game;
            game.ChangeScene(node: this.Stage);

            GD.Print("Loading node: ", node);
            GD.Print("Loading packedScene: ", packedScene);
            GD.Print("Loading stage: ", this.Stage);

            // Hide the loading scrfeens
            game.HideLoadingScreen();

            state = BattleState.InLobby;
        }

        public void CreateGamePlay(GameType gameType)
        {
            switch (gameType)
            {
                case GameType.Unknown:
                    break;
                case GameType.NormalMostWins:
                    break;
                case GameType.BestScoreKillsAndWins:
                    break;
                case GameType.GoldBomber:
                    break;
                case GameType.DeathMatchMostKills:
                    break;
                case GameType.Virus:
                    break;
                default:
                    this.GamePlay = new GamePlayNormal(this);
                    break;
            }

            this.GamePlay = new GamePlayNormal(this);
        }
    }
}

