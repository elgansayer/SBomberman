using System.Collections.Generic;
using Godot;
using Nakama;
using Network;
using Newtonsoft.Json;

namespace Network
{
    public partial class Server : Node2D
    {
        // [Export] private PackedScene MainMenuScene;
        [Export]
        public PackedScene TournementScene;

        public ENetMultiplayerPeer eNet { get; private set; }
        public Client client { get; private set; }

        protected int playerCount = 0;
        protected int port = 4333;
        protected int maxPlayers = 10;

        // public readonly Dictionary<int, PeerInfo> PeerList = new Dictionary<int, PeerInfo>();
        protected string host = "localhost";

        public delegate void OnPeerLeftHandler(int peerId);

        [Signal]
        public event OnPeerLeftHandler OnPeerLeft;
        public delegate void OnPeerEnteredHandler(PeerInfo peerInfo);
        public event OnPeerEnteredHandler OnPeerEntered;

        // private GameState gameState;

        public override void _Ready()
        {
            this.Name = "Server";
            // this.gameState = GetTree().Root.GetNode<GameState>("GameState");
        }

        private ServerOptions GetServerOptions()
        {
            //Todo: Get battle options from nakama
            ServerOptions serverOptions = new ServerOptions(
                battleName: "TestBattle",
                gameType: GameType.NormalMostWins,
                maxPlayers: 4,
                minPlayers: 2,
                numBattles: 1,
                time: 60,
                spawnShuffle: true,
                devil: true,
                madBomber: true,
                stages: new int[] { 0 }
            );

            return serverOptions;
        }

        public void Host()
        {
            this.eNet = new ENetMultiplayerPeer();

            GD.Print("Game Server Setup");

            this.client = GetNode("/root/Client") as Network.Client;

            // Create the server and start listening for connections
            // but don't start accepting connections yet
            Error error = this.CreateServer();

            if (error != Error.Ok)
            {
                GD.Print("Error creating server: " + error);
                GetTree().Quit();
                return;
            }

            // Build the tournament, battle and stage
            this.CreateTournement();

            // Handle incoming connections
            this.eNet.PeerConnected += this.OnPeerConnected;
            this.eNet.PeerDisconnected += this.onPeerDisconnected;

            // Finally, Allow server connections
            // Multiplayer.RefuseNewConnections = false;
        }

        private Error CreateServer()
        {
            GD.Print("Game Server Setup CreateServer");
            ServerOptions battleOptions = GetServerOptions();

            Error error = this.eNet.CreateServer(this.port, this.maxPlayers);

            GD.Print("Game Server created server");
            Multiplayer.MultiplayerPeer = this.eNet;
            Multiplayer.AllowObjectDecoding = true;
            // Multiplayer.RefuseNewConnections = true;

            GD.Print(what: "Multiplayer.GetUniqueId " + Multiplayer.GetUniqueId());
            return Error.Ok;
        }

        private void CreateTournement()
        {
            ServerOptions serverOptions = GetServerOptions();
            GD.Print("Game Server Setup AddTournement ", this.TournementScene);
            PackedScene tournementScene = this.TournementScene;
            Node tournementNode = tournementScene.Instantiate();
            Tournement tournement = tournementNode as Tournement;
            GetTree().Root.AddChild(tournement);
            tournement.ServerOptions = serverOptions;
            tournement.Init();
            // tournement.Battle.SpawnPeers();
        }

        public void onPeerDisconnected(int id)
        {
            GD.Print("Game Server OnPeerDisconnected");
            this.UnregisterPeer(id);
        }

        public void OnPeerConnected(int id)
        {
            if (id <= 1)
            {
                throw new System.Exception("Invalid peer id");
            }

            GD.Print("Game Server OnPeerConnected " + id);
        }

        public void UnregisterPeer(int id)
        {
            // gameState.RemovePeer(id);
            GD.Print("Removed peer with id: " + id);

            OnPeerLeftHandler handler = this.OnPeerLeft;
            handler?.Invoke(id);
        }

        [RPC(
            RPCMode.AnyPeer,
            CallLocal = false,
            TransferMode = TransferMode.Unreliable,
            TransferChannel = 0
        )]
        public void RegisterPeer(string peerData)
        {
            GD.Print("Game Server RegisterPlayer");
            int id = Multiplayer.GetRemoteSenderId();

            PeerInfo peerInfo = JsonConvert.DeserializeObject<PeerInfo>(peerData);
            peerInfo.State = PeerInfoState.Registered;
            peerInfo.Id = id;

            Tournement tournement = GetTree().Root.GetNode<Tournement>("Tournement") as Tournement;
            string tournementJson = tournement.SnapShot.ToJson();
            string snapShotJson = tournement.Battle.SnapShot.ToJson();
            Dictionary<Vector2i, List<Vector2i>> rocks =
                tournement.Battle.Stage.GetExplodableRockFlags();

            // Tell the player the battle options and ask if they are ready
            ServerOptions serverOptions = GetServerOptions();
            string serverOptionsJson = serverOptions.ToJson();

            // Dictionary<Vector2i, List<Vector2i>> rocks = this.Stage.GetExplodableRockFlags();
            var rocksJson = JsonConvert.SerializeObject(rocks);

            // Send the battle options and ask if the player is ready
            this.client.RpcId(
                id,
                nameof(this.client.RegisterPeerCompleted),
                serverOptionsJson,
                tournementJson,
                snapShotJson,
                rocksJson
            );
        }

        [RPC(
            RPCMode.AnyPeer,
            CallLocal = false,
            TransferMode = TransferMode.Unreliable,
            TransferChannel = 0
        )]
        public void RegisterPeerReady(string peerData)
        {
            // Godot.AnyPeerAttribute
            GD.Print("Game Server RegisterPeerReady");
            int id = Multiplayer.GetRemoteSenderId();

            PeerInfo peerInfo = JsonConvert.DeserializeObject<PeerInfo>(peerData);
            peerInfo.State = PeerInfoState.Ready;
            peerInfo.Id = id;

            // this.gameState.Peers[id].State = PeerInfoState.Ready;
            GD.Print(what: "Set peer ready: " + id);

            OnPeerEnteredHandler handler = this.OnPeerEntered;
            handler?.Invoke(peerInfo);
        }
    }
}
