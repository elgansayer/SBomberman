using Godot;
using Network;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

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

        private Dictionary<int, ActorState> actorStates = new Dictionary<int, ActorState>();

        private Network.Server server;
        private Network.Client client;
        private static readonly object _locker = new object();


        public override void _Ready()
        {
            // this.RpcConfig(nameof(this.SpawnPeer), RPCMode.AnyPeer, true, TransferMode.Reliable);
            // this.RpcConfig(nameof(this.PeerRecievedSnapshot), RPCMode.Authority, false, TransferMode.Reliable);

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

        public void SetActorState(int id, ActorState actorState)
        {
            // Create an initial snapshot for the peer.
            this.actorStates[id].updateState(actorState);
        }

        public override void _PhysicsProcess(float delta)
        {
            if (Multiplayer.IsServer())
            {
                // this.updatePeers();
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

        private static readonly SemaphoreSlim _semaphoreSlim = new SemaphoreSlim(1, 1);

        async void updatePeers()
        {
            await _semaphoreSlim.WaitAsync();

            // GD.Print(what: "sendPlayerState: " + snapShot.ToJson());
            await Task.Run(() =>
            {
                Dictionary<Vector2i, List<Vector2i>> rocks = this.Stage.GetExplodableRockFlags();
                var rocksJson = JsonConvert.SerializeObject(rocks);

                GD.Print(what: "updatePeers");
                // Send the snapshot to all clients
                this.Rpc(nameof(this.PeerRecievedSnapshot), this.SnapShot.ToJson());
                this.Rpc(nameof(this.PeerRecievedRocks), rocksJson);

            });

            _semaphoreSlim.Release();
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

            // this.Stage.GetExplodableRockFlags()

            BattleSnapShot snapShot = new BattleSnapShot(
            this.state,
            this.time,
            this.stageIndex,
            this.actorStates
            );

            return snapShot;
        }

        // makes the RPC callable by anyone, "call_local", use "unreliable" transfer, channel 1
        // [RPC(RPCMode.AnyPeer, CallLocal = true, TransferMode = TransferMode.Unreliable, TransferChannel = 1)]

        // Defaults are authority, no call_local, reliable, "default channel" (i.e. 0).
        [RPC(RPCMode.Authority, CallLocal = false, TransferMode = TransferMode.Reliable, TransferChannel = 0)]
        public void PeerRecievedSnapshot(string battleSnapShotJson)
        {
            GD.Print("PeerRecievedSnapshot");
            lock (_locker)
            {
                //   await Task.Run(() =>
                //    {
                GD.Print("PeerRecievedSnapshot: " + battleSnapShotJson);

                // BattleSnapShot battleSnapShot = JsonConvert.DeserializeObject<BattleSnapShot>(battleSnapShotJson);
                BattleSnapShot battleSnapShot = BattleSnapShot.Deserialize(battleSnapShotJson);
                // this.SnapShot = battleSnapShot;
                this.SetSnapshot(battleSnapShot);
                //   });
            }
        }

        [RPC(RPCMode.Authority, CallLocal = false, TransferMode = TransferMode.Reliable, TransferChannel = 0)]
        public void PeerRecievedRocks(string rocksJson)
        {
            GD.Print("PeerRecievedRocks: " + rocksJson);

            Dictionary<Vector2i, List<Vector2i>> rocks = JsonConvert.DeserializeObject<Dictionary<Vector2i, List<Vector2i>>>(rocksJson);
            this.Stage.SyncExplodableRocks(rocks);
        }


        public void SetSnapshot(BattleSnapShot battleSnapShot)
        {
            GD.Print("SetSnapshot: ");

            this.state = battleSnapShot.State;
            this.time = battleSnapShot.Time;
            this.stageIndex = battleSnapShot.StageIndex;
            // this.battleId = battleSnapShot.BattleId;

            // GD.Print("SetSnapshot: " + battleSnapShot.ToJson());

            foreach (KeyValuePair<int, ActorState> item in battleSnapShot.ActorStates)
            {
                if (this.actorStates.ContainsKey(item.Key))
                {
                    // GD.Print("actorStates.ContainsKey: " + item.Key);

                    this.actorStates[item.Key].updateState(item.Value);
                    Actor actorNode = this.Stage.GetNode<Actor>(item.Key.ToString());

                    // GD.Print("actorNode: " + actorNode);
                    if (actorNode != null)
                    {
                        actorNode.UpdateFromState(item.Value);
                    }
                }
            }
            // this.actorStates = battleSnapShot.ActorStates;

            //TODO 
            // this.Stage.SyncExplodableRocks(battleSnapShot.ExplodableRockFlags);
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

        // Defaults are authority, no call_local, reliable, "default channel" (i.e. 0).
        [RPC(RPCMode.AnyPeer, CallLocal = false, TransferMode = TransferMode.Unreliable, TransferChannel = 0)]
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
            Actor actor = (Actor)actorScene.Instantiate();

            GD.Print("Spawning peerInfo ", peerInfo.ToJson());
            actor.Name = peerInfo.Id.ToString();
            actor.AddToGroup("Players");
            GD.Print("Spawning peer: " + peerInfo.DisplayName);

            this.Stage.AddChild(actor);

            // GD.Print("Spawning actor avatar: " + actor.GetPath());
            // BattlePeerInfo battleInfo = peerInfo.Battles[battleId];
            // actor.Position = peerInfo.SpawnPoint;
            peerInfo.SpawnedActor = actor;

            actor.Position = peerInfo.SpawnPoint;
            var actorState = actor.GetActorState();
            // Create an initial snapshot for the peer.
            this.actorStates[peerInfo.Id] = actorState;

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

