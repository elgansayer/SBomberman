using System.Collections.Generic;
using Godot;
using Nakama;
using Network;

namespace Network
{
    public partial class Client : Node2D
    {
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

        public NetworkMessenger networkMessenger { get; private set; }

        public void Setup()
        {
            this.networkMessenger = GetNode("/root/NetworkMessenger") as NetworkMessenger;

            this.eNet = new ENetMultiplayerPeer();

            this.eNet.ServerDisconnected += this.onServerDisconnected;
            this.eNet.ConnectionSucceeded += this.onConnectionSucceeded;
            this.eNet.ConnectionFailed += this.onConnectionFailed;

            // this.clientServerHandler.RegisterRpc("OnPeerConnected", this.OnPeerConnected);

            // Actually connect to the server
            this.CreateClient();
        }

        public void CreateClient()
        {
            this.eNet.CreateClient(this.host, this.port);
            GD.Print("Game Client created Client");
            Multiplayer.MultiplayerPeer = null;
            Multiplayer.MultiplayerPeer = this.eNet;
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

                // Rpc(nameof(this.RegisterPlayer), peerInfo.ToDictionary());

                // GD.Print("Game Server RegisterPlayer sent");
            }
            catch (System.Exception ex)
            {
                GD.Print("Failed to parse peer data");
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

            GD.Print("Account ", account);

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


        // void UnregisterPlayer(int id)
        // {
        //     PeerList.Remove(id);
        //     GD.Print("Removed peer with id: " + id);

        //     OnPeerLeftHandler handler = this.OnPeerLeft;
        //     handler?.Invoke();
        // }

        // [Authority]
        // [AnyPeer]
        // void RegisterPlayer(Godot.Collections.Dictionary<string, object> peerData)
        // {
        //     GD.Print(peerData);
        //     // Godot.AnyPeerAttribute
        //     GD.Print("Game Server RegisterPlayer");
        //     int id = Multiplayer.GetRemoteSenderId();

        //     try
        //     {
        //         PeerInfo peerInfo = PeerInfo.FromDictionary(peerData);
        //         peerInfo.State = PeerInfoState.Connecting;

        //         PeerList[id] = peerInfo;
        //         GD.Print(what: "Added peer with id: " + id);

        //         // OnPeerReadyHandler handler = this.OnPeerReady;
        //         // handler?.Invoke();
        //     }
        //     catch (System.Exception ex)
        //     {

        //         GD.Print("Failed to parse peer data");
        //         GD.Print("Error: " + ex.Message);
        //     }
        // }

    }
}