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
        [Export] public PackedScene[] StageScenes;
        [Export] public PackedScene[] ActorScenes;
        public Stage Stage;
        private int time = 0;
        private int stageIndex = 0;
        private int battleId;
        private BattleState state = BattleState.Initializing;

        private Network.Server server;
        private Network.Client client;
        // private GameState gameState;

        public override void _Ready()
        {
            // this.RpcConfig(nameof(this.SpawnPeer), RPCMode.AnyPeer, true, TransferMode.Reliable);

            GD.Print("Battle Ready");
            // this.gameState = GetTree().Root.GetNode<GameState>("GameState");

            if (Multiplayer.IsServer())
            {
                Random rnd = new Random();
                this.battleId = rnd.Next(minValue: 1, 9999999);

                GD.Print("Server Battle Ready " + this.battleId);

                this.server = GetNode("/root/Server") as Network.Server;
                // this.server.OnPeerEntered += this.OnPeerEntered;
                // this.server.OnPeerLeft += this.OnPeerLeft;
            }
            else
            {
                GD.Print("Client Battle Ready");

                this.client = GetNode("/root/Client") as Network.Client;
                // this.client.OnPeerEntered += this.OnPeerEntered;
                // this.client.OnPeerLeft += this.OnPeerLeft;
            }
        }

        public virtual void OnPeerEntered(PeerInfo peerInfo)
        {
            GD.Print(what: "Battle OnPeerEntered");

            peerInfo.State = PeerInfoState.InLobby;

            SpawnPoint spawnPoint = this.getNextSpawnPoint();
            spawnPoint.Used = true;
            this.Stage.ExplodableRocks.AddSpawnPointHole(spawnPoint.GridPosition);
            peerInfo.SpawnPoint = spawnPoint.Position;

            // this.SpawnPoints[peerInfo.Id] = spawnPoint;

            this.SpawnPeer(peerInfo);

            // this.gameState.Rpc(nameof(this.gameState.UpdatePeers));

            // this.Rpc(nameof(this.SpawnPeer),
            //         peerInfo.ToJson());

            // Update Rocks
            this.updatePeers();
        }

        void updatePeers()
        {
            // Send the snapshot to all clients
            this.Rpc(nameof(this.RecievedSnapshot), this.SnapShot.ToJson());
        }

        private SpawnPoint getNextSpawnPoint()
        {
            Tournement tournement = GetNode("/root/Tournement") as Tournement;
            bool spawnShuffle = tournement.ServerOptions.SpawnShuffle;

            if (spawnShuffle)
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
            // PeerInfo peerInfo = this.gameState.Peers[peerId];
            // peerInfo.State = PeerInfoState.Disconnected;
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
        public void RecievedSnapshot(string battleSnapShotJson)
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
            // this.battleId = battleSnapShot.BattleId;

            this.Stage.SyncExplodableRocks(battleSnapShot.ExplodableRocks);
        }

        internal void SpawnPeers(Dictionary<int, PeerInfo> peers)
        {
            GD.Print("Battle SpawnPeers");

            // Dictionary<int, PeerInfo> peers = this.gameState.Peers;
            foreach (KeyValuePair<int, PeerInfo> peer in peers)
            {
                this.SpawnPeer(peer.Value);
            }

            // if (Multiplayer.IsServer())
            // {
            //     // Update Rocks
            //     this.updatePeers();
            // }
        }

        [Authority]
        [AnyPeer]
        public void SpawnPeer(PeerInfo peerInfo)
        {
            // this.battleId = battleId;
            // PeerInfo peerInfo = JsonConvert.DeserializeObject<PeerInfo>(peerInfoJson);
            // int peerId = peerInfo.Id;
            if (peerInfo.SpawnedActor != null)
            {
                GD.Print("Battle SpawnPeer: peer is spawned InLobby");
                return;
            }

            // if (peerInfo.State == PeerInfoState.InLobby)
            // {
            //     GD.Print("Battle SpawnPeer: peer is spawned InLobby");
            //     return;
            // }

            // this.gameState.Peers[peerId] = peerInfo;

            GD.Print("Battle SpawnPeer: " + peerInfo.Id);

            peerInfo.State = PeerInfoState.InLobby;

            // We need to add a player to the battle
            // 1 Spawnpoint 

            // 2 Player
            int avatarId = peerInfo.AvatarId ?? 0;
            PackedScene actorScene = this.ActorScenes[avatarId];
            Node2D actor = (Node2D)actorScene.Instantiate();

            GD.Print("Spawning peerInfo ", peerInfo.ToJson());
            actor.Name = peerInfo.DisplayName;
            GD.Print("Spawning peer: " + peerInfo.DisplayName);

            this.Stage.AddChild(actor);

            // GD.Print("Spawning actor avatar: " + actor.GetPath());
            // BattlePeerInfo battleInfo = peerInfo.Battles[battleId];
            actor.Position = peerInfo.SpawnPoint;
            peerInfo.SpawnedActor = actor;

            // this.updatePeers();
        }

        internal void CreateStage(int stageIndex)
        {
            this.stageIndex = stageIndex;

            // Load the stage
            GD.Print("Loading stage: ");

            PackedScene packedScene = this.StageScenes[stageIndex];
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

