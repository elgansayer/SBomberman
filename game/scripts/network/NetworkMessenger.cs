using System.Collections.Generic;
using Godot;
using Nakama;
using Network;

namespace Network
{
    public delegate void RPCDelegate(Godot.Object[] args);

    public partial class NetworkMessenger : Node2D
    {
        protected Dictionary<string, RPCDelegate> rpcHandlers = new Dictionary<string, RPCDelegate>();

        // public ENetMultiplayerPeer eNet { get; private set; }
        // protected int playerCount = 0;
        // protected int port = 4333;
        // protected int maxPlayers = 10;
        // public readonly Dictionary<int, PeerInfo> PeerList = new Dictionary<int, PeerInfo>();
        // protected string host = "localhost";

        // protected BattleOptions battleOptions;

        // public delegate void OnPeerReadyHandler();

        // [Signal]
        // public event OnPeerReadyHandler OnPeerReady;

        // public delegate void OnPeerLeftHandler();

        // [Signal]
        // public event OnPeerLeftHandler OnPeerLeft;


        public override void _Ready()
        {
            this.Name = "NetworkMessenger";
            GD.Print("Game network Handler _Ready");
            this.setupENetMultiplayerPeer();
        }

        void setupENetMultiplayerPeer()
        {
            GD.Print("Game network Handler setupENetMultiplayerPeer");
            // this.eNet = new ENetMultiplayerPeer();

            // this.eNet.PeerConnected += this.OnPeerConnected;
            // this.eNet.PeerDisconnected += this.onPeerDisconnected;
            // this.eNet.ServerDisconnected += this.onServerDisconnected;
            // this.eNet.ConnectionSucceeded += this.onConnectionSucceeded;
            // this.eNet.ConnectionFailed += this.onConnectionFailed;

            GD.Print("Game network Handler setupENetMultiplayerPeer");
        }

        // public void CreateServer()
        // {
        //     this.eNet.CreateServer(this.port, this.maxPlayers);
        //     GD.Print("Game Server created server");
        //     Multiplayer.MultiplayerPeer = this.eNet;
        // }

        // public void CreateClient()
        // {
        //     this.eNet.CreateClient(this.host, this.port);
        //     GD.Print("Game Client created Client");
        //     Multiplayer.MultiplayerPeer = this.eNet;
        // }

        //
        // Summary:
        //     Emitted by the server when a client connects.
        // Only called on clients, not server. Send my ID and info to all the other peers
        // public void OnPeerConnected(int id)
        // {
        //     if (id <= 1)
        //     {
        //         return;
        //     }

        //     GD.Print("Game Server OnPeerConnected");

        //     // Sent the game info to the player
        //     // RpcId(id, nameof(this.clientGotBattleOptions), this.battleOptions);
        //     // var options = new Object[] {this.battleOptions};
        //     RpcId(id, nameof(this.RecievedRpc), this.battleOptions);
        // }
        public void SendRpc(string methodName, params Godot.Object[] args)
        {
            GD.Print("Game Server SendRpc " + methodName);
            this.Rpc(nameof(this.RecievedRpc));
        }

        public void SendRpcId(int id, string methodName, params Godot.Object[] args)
        {
            // var ss = [...args];
            RpcId(id, nameof(this.RecievedRpc), methodName, args);
        }

        public void RegisterRpc(string methodName, RPCDelegate rpc)
        {
            this.rpcHandlers.Add(methodName, rpc);
        }

        [RPC(RPCMode.AnyPeer | RPCMode.Authority, CallLocal = false, TransferMode = TransferMode.Unreliable, TransferChannel = 0)]
        public void RecievedRpc()
        {
            GD.Print("Game Client RecievedRpc");
            // GD.Print(args);
            // string methodName = args[0].ToString();
            // if (this.rpcHandlers.ContainsKey(methodName))
            // {
            //     RPCDelegate handler = this.rpcHandlers[methodName];
            //     handler.Invoke(args);
            //     // this.rpcHadnlers[methodName](args);
            // }
        }

        [RPC(RPCMode.AnyPeer, CallLocal = false, TransferMode = TransferMode.Unreliable, TransferChannel = 0)]
        public void clientGotBattleOptions(ServerOptions battleOptions)
        {
            GD.Print("Game Client clientGotBattleOptions");
            GD.Print("battleOptions ", battleOptions);

            // this.battleOptions = battleOptions;
            // this.OnPeerReady?.Invoke();
        }

        //
        // Summary:
        //     Emitted by the server when a client disconnects.
        // public void onPeerDisconnected(int id)
        // {
        //     GD.Print("Game Server OnPeerDisconnected");
        //     // this.UnregisterPlayer(id);
        // }

        //
        // Summary:
        //     Emitted by clients when the server disconnects.
        public void onServerDisconnected()
        {
            GD.Print("Game Server OnServerDisconnected");
        }

        // public void ClientGameInfo()
        // {
        //     GD.Print("Game Server OnServerDisconnected");
        // }

        //
        // Summary:
        //     Emitted when a connection attempt succeeds.
        // Only called on clients, not server. Send my ID and info to all the other peers
        // public void onConnectionSucceeded()
        // {
        //     GD.Print("Game Server OnConnectionSucceeded");

        //     try
        //     {
        //         PeerInfo peerInfo = this.GetPlayerInfo();

        //         Rpc(nameof(this.RegisterPlayer), peerInfo.ToDictionary());

        //         GD.Print("Game Server RegisterPlayer sent");
        //     }
        //     catch (System.Exception ex)
        //     {
        //         GD.Print("Failed to parse peer data");
        //         GD.Print("Error: " + ex.Message);
        //     }
        // }

        //
        // Summary:
        //     Emitted when a connection attempt fails.
        // public void onConnectionFailed()
        // {
        //     GD.Print("Game Server OnConnectionFailed");
        // }

    }
}