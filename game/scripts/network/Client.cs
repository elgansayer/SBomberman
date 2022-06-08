using System.Collections.Generic;
using Godot;
using Nakama;
using Network;

namespace Network
{
    public partial class Client : Node2D
    {        
        public override void _Ready()
        {
            this.Name = "Client";
        }

        private PeerInfo clientPlayerInfo;

        public ClientServerHandler clientServerHandler { get; private set; }

        public void Setup(ClientServerHandler clientServerHandler)
        {
            this.clientServerHandler = clientServerHandler;

            this.clientServerHandler.eNet.ServerDisconnected += this.onServerDisconnected;
            this.clientServerHandler.eNet.ConnectionSucceeded += this.onConnectionSucceeded;
            this.clientServerHandler.eNet.ConnectionFailed += this.onConnectionFailed;

            // this.clientServerHandler.RegisterRpc("OnPeerConnected", this.OnPeerConnected);

            // Actually connect to the server
            this.clientServerHandler.CreateClient();
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