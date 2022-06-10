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
        [Export] private PackedScene TournementScene;

        public Server server { get; private set; }
        public ENetMultiplayerPeer eNet { get; private set; }
        protected int playerCount = 0;
        protected int port = 4333;
        protected int maxPlayers = 10;
        public readonly Dictionary<int, PeerInfo> PeerList = new Dictionary<int, PeerInfo>();
        protected string host = "localhost";


        public override void _Ready()
        {
            this.Name = "Client";
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
            GD.Print("Game CLIENT OnPeerConnected");
        }

        public void OnPeerConnected(Godot.Object[] args)
        {
            GD.Print("Game Server OnPeerConnected");
        }

        //
        // Summary:
        //     Emitted by clients when the server disconnects.
        public void onServerDisconnected()
        {
            GD.Print("Game Server OnServerDisconnected");
        }

        //
        // Summary:
        //     Emitted when a connection attempt succeeds.
        // Only called on clients, not server. Send my ID and info to all the other peers
        public void onConnectionSucceeded()
        {
            GD.Print("Game Server OnConnectionSucceeded");

            try
            {
                PeerInfo peerInfo = this.GetPlayerInfo();
                String peerInfoJson = JsonConvert.SerializeObject(peerInfo);

                this.server.Rpc(nameof(this.server.RegisterPeer), peerInfoJson);
            }
            catch (System.Exception ex)
            {
                GD.Print("Failed to send peer data");
                GD.Print("Error: " + ex.Message);
            }
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
                DisplayName = account.User.DisplayName ?? "",
                UserName = account.User.Username ?? "",
                Avatar = "" ?? "",
            };

            return this.clientPlayerInfo;
        }

        internal void RpcId(int id, object registerPlayerCompleted, ServerOptions battleOptions)
        {
            throw new NotImplementedException();
        }

        [Authority]
        [AnyPeer]
        public void RegisterPeerCompleted(String serverOptionsJson)
        {
            GD.Print("Game Server serverOptionsJson0: " + serverOptionsJson);
            ServerOptions serverOptions = JsonConvert.DeserializeObject<ServerOptions>(serverOptionsJson);

            GD.Print("CLIENT Register Player Completed");
            GD.Print("serverOptions ", serverOptions);
            this.AddTournement(serverOptions);
            this.server.RpcId(1, nameof(this.server.RegisterPeerReady));
        }

        private void AddTournement(ServerOptions serverOptions)
        {
            // Add a game type
            // Tournement tournement = new Tournement(serverOptions);
            // GetTree().Root.AddChild(tournement);
            // tournement.init();
            PackedScene tournementScene = this.TournementScene;
            Tournement tournementNode = tournementScene.Instantiate() as Tournement;
            GetTree().Root.AddChild(tournementNode);
            tournementNode.ServerOptions = serverOptions;
            tournementNode.initClient();
        }
    }
}