using System;
using System.Collections.Generic;
using Godot;
using Nakama;
using Network;
using Newtonsoft.Json;

namespace Network
{
    public partial class Client : Node2D
    {
#pragma warning disable CS0649
        [Export] private PackedScene TournementScene;
#pragma warning restore CS0649

        public Server server { get; private set; }
        public ENetMultiplayerPeer eNet { get; private set; }
        protected int playerCount = 0;
        protected int port = 4333;
        protected int maxPlayers = 10;
        public readonly Dictionary<int, PeerInfo> PeerList = new Dictionary<int, PeerInfo>();
        protected string host = "localhost";

#pragma warning disable CS0067
        public delegate void OnPeerLeftHandler(int peerId);
        [Signal] public event OnPeerLeftHandler OnPeerLeft;

        public delegate void OnPeerEnteredHandler(PeerInfo peerInfo);
        public event OnPeerEnteredHandler OnPeerEntered;
#pragma warning restore CS0067

        // private GameState gameState;

        public override void _Ready()
        {
            this.Name = "Client";
            // this.gameState = GetTree().Root.GetNode<GameState>("GameState");
        }

        private PeerInfo clientPlayerInfo;

        // public NetworkMessenger networkMessenger { get; private set; }

        public void Connect()
        {
            // this.networkMessenger = GetNode("/root/NetworkMessenger") as NetworkMessenger;
            this.server = GetNode("/root/Server") as Network.Server;

            this.eNet = new ENetMultiplayerPeer();

            this.eNet.ServerDisconnected += this.onServerDisconnected;
            this.eNet.ConnectionSucceeded += this.onConnectionSucceeded;
            this.eNet.ConnectionFailed += this.onConnectionFailed;

            this.eNet.PeerConnected += this.OnPeerConnected;
            this.eNet.PeerDisconnected += this.onPeerDisconnected;

            // this.clientServerHandler.RegisterRpc("OnPeerConnected", this.OnPeerConnected);

            // Actually connect to the server
            this.CreateClient();
        }

        public void CreateClient()
        {
            Game game = GetTree().Root.GetNode("Game") as Game;
            game.ShowLoadingScreen();

            this.eNet.CreateClient(this.host, this.port);
            GD.Print("Game Client created Client");
            Multiplayer.MultiplayerPeer = this.eNet;
            GD.Print(what: "Multiplayer.GetUniqueId " + Multiplayer.GetUniqueId());
        }

        public void onPeerDisconnected(int id)
        {
            GD.Print("Game CLIENT onPeerDisconnected");
            // this.UnregisterPlayer(id);
        }

        public void OnPeerConnected(int id)
        {
            GD.Print("Game CLIENT OnPeerConnected ", id);
        }

        public void OnPeerConnected(Godot.Object[] args)
        {
            GD.Print("Game Server OnPeerConnected ", args);
        }

        //
        // Summary:
        //     Emitted by clients when the server disconnects.
        public void onServerDisconnected()
        {
            GD.Print("Game Client OnServerDisconnected");
        }

        //
        // Summary:
        //     Emitted when a connection attempt succeeds.
        // Only called on clients, not server. Send my ID and info to all the other peers
        public void onConnectionSucceeded()
        {
            GD.Print("Game Client OnConnectionSucceeded");

            // try
            // {
            PeerInfo peerInfo = this.GetPlayerInfo();
            String peerInfoJson = peerInfo.ToJson();

            // RPCMode rpcMode, bool callLocal = false, TransferMode transferMode = TransferMode.Reliable, int channel = 0);

            // this.gameState.AddPeer(peerInfo);
            // this.gameState.RegisterPeer(peerInfoJson);
            // this.gameState.Rpc(nameof(this.gameState.RegisterPeer), peerInfoJson);
            this.server.RpcId(1, nameof(this.server.RegisterPeer), peerInfoJson);
            // }
            // catch (System.Exception ex)
            // {
            // GD.Print("Failed to send peer data");
            // GD.Print("Error: " + ex.Message);
            // }
        }

        //
        // Summary:
        //     Emitted when a connection attempt fails.
        public void onConnectionFailed()
        {
            GD.Print("Game Server OnConnectionFailed");
        }

        protected PeerInfo GetPlayerInfo()
        {
            Network.NakamaNetwork nakamaNetwork = GetNode("/root/NakamaNetwork") as Network.NakamaNetwork;
            IApiAccount account = nakamaNetwork.Account;

            this.clientPlayerInfo = new PeerInfo()
            {
                Id = Multiplayer.GetUniqueId(),
                NakamaId = account.User.Id ?? "",
                DisplayName = account.User.DisplayName ?? account.User.Username,
                UserName = account.User.Username,
                AvatarId = 0,
            };

            return this.clientPlayerInfo;
        }

        [Authority]
        [AnyPeer]
        public void RegisterPeerCompleted(string serverOptionsJson, string tournementSnapshotJson, string battleSnapshotJson)
        {
            GD.Print("Game Client serverOptionsJson0: " + serverOptionsJson);

            ServerOptions serverOptions = JsonConvert.DeserializeObject<ServerOptions>(serverOptionsJson);
            // GD.Print("serverOptions ", serverOptions);

            TournementSnapshot tournementSnapshot = JsonConvert.DeserializeObject<TournementSnapshot>(tournementSnapshotJson);
            // GD.Print("serverOptions ", serverOptions);

            BattleSnapShot battleSnapShot = JsonConvert.DeserializeObject<BattleSnapShot>(battleSnapshotJson);
            // GD.Print("battleSnapShot ", battleSnapShot);

            this.CreateTournement(serverOptions, tournementSnapshot, battleSnapShot);

            // Send the peer data to be registered on the server
            PeerInfo peerInfo = this.GetPlayerInfo();
            String peerInfoJson = peerInfo.ToJson();

            // Notifcy the server we are ready to start the game
            this.server.RpcId(1, nameof(this.server.RegisterPeerReady), peerInfoJson);
        }

        private void CreateTournement(ServerOptions serverOptions, TournementSnapshot tournementSnapshot, BattleSnapShot battleSnapShot)
        {
            // GD.Print("CLIENT AddTournement");
            // GD.Print("serverOptions ", serverOptions);
            // GD.Print("battleSnapShot ", battleSnapShot.ToJson());

            // Add a game type
            PackedScene tournementScene = this.TournementScene;
            Tournement tournementNode = tournementScene.Instantiate() as Tournement;
            GetTree().Root.AddChild(tournementNode);
            tournementNode.ServerOptions = serverOptions;
            tournementNode.BattleIndex = battleSnapShot.StageIndex;
            tournementNode.Init();

            tournementNode.SnapShot = tournementSnapshot;
            tournementNode.Battle.SnapShot = battleSnapShot;
            // tournementNode.Battle.SpawnPeers();
        }
    }
}