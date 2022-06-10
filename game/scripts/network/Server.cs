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
        [Export] public PackedScene TournementScene;

        public ENetMultiplayerPeer eNet { get; private set; }
        public Client client { get; private set; }

        protected int playerCount = 0;
        protected int port = 4333;
        protected int maxPlayers = 10;
        public readonly Dictionary<int, PeerInfo> PeerList = new Dictionary<int, PeerInfo>();
        protected string host = "localhost";

        public delegate void OnPeerLeftHandler(int peerId);
        [Signal] public event OnPeerLeftHandler OnPeerLeft;
        public delegate void OnPeerEnteredHandler(int peerId);
        [Signal] public event OnPeerEnteredHandler OnPeerEntered;

        public override void _Ready()
        {
            this.Name = "Server";
        }

        private ServerOptions GetServerOptions()
        {
            //Todo: Get battle options from nakama        
            ServerOptions serverOptions = new ServerOptions()
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
                Stages = new int[] { 0 },
                CurrentStageIndex = 0
            };

            return serverOptions;
        }

        public void Host()
        {
            this.eNet = new ENetMultiplayerPeer();

            GD.Print("Game Server Setup");

            this.client = GetNode("/root/Client") as Network.Client;

            this.AddTournement();

            this.CreateServer();

            this.eNet.PeerConnected += this.OnPeerConnected;
            this.eNet.PeerDisconnected += this.onPeerDisconnected;
        }

        private void CreateServer()
        {
            GD.Print("Game Server Setup CreateServer");
            ServerOptions battleOptions = GetServerOptions();

            this.eNet.CreateServer(this.port, this.maxPlayers);
            GD.Print("Game Server created server");
            Multiplayer.MultiplayerPeer = this.eNet;

            GD.Print(what: "Multiplayer.GetUniqueId " + Multiplayer.GetUniqueId());
        }

        private void AddTournement()
        {
            ServerOptions serverOptions = GetServerOptions();
            GD.Print("Game Server Setup AddTournement ", this.TournementScene);
            PackedScene tournementScene = this.TournementScene;
            Node tournementNode = tournementScene.Instantiate();
            Tournement tournemen = tournementNode as Tournement;
            GetTree().Root.AddChild(tournemen);
            tournemen.ServerOptions = serverOptions;
            tournemen.initServer();
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

            GD.Print("Game Server OnPeerConnected");

            PeerInfo peerInfo = new PeerInfo();
            peerInfo.State = PeerInfoState.Connecting;
            PeerList[id] = peerInfo;
        }

        public void UnregisterPeer(int id)
        {
            PeerList.Remove(id);
            GD.Print("Removed peer with id: " + id);

            OnPeerLeftHandler handler = this.OnPeerLeft;
            handler?.Invoke(id);
        }

        [Authority]
        [AnyPeer]
        public void RegisterPeer(string peerData)
        {
            GD.Print(peerData);
            // Godot.AnyPeerAttribute
            GD.Print("Game Server RegisterPlayer");
            int id = Multiplayer.GetRemoteSenderId();

            try
            {
                // PeerInfo peerInfo = PeerInfo.FromDictionary(peerData);
                PeerInfo peerInfo = JsonConvert.DeserializeObject<PeerInfo>(peerData);

                peerInfo.State = PeerInfoState.Registered;

                PeerList[id] = peerInfo;
                GD.Print(what: "Added peer with id: " + id);

                // Tell the player the battle options and ask if they are ready
                ServerOptions serverOptions = GetServerOptions();
                string json = JsonConvert.SerializeObject(serverOptions);
                GD.Print(json);

                this.client.RpcId(id, nameof(this.client.RegisterPeerCompleted), json);
            }
            catch (System.Exception ex)
            {
                GD.Print("Failed to parse peer data");
                GD.Print("Error: " + ex.Message);
            }
        }

        [Authority]
        [AnyPeer]
        public void RegisterPeerReady()
        {
            // Godot.AnyPeerAttribute
            GD.Print("Game Server RegisterPeerReady");
            int id = Multiplayer.GetRemoteSenderId();

            PeerList[id].State = PeerInfoState.Ready;
            GD.Print(what: "Set peer ready: " + id);

            OnPeerEnteredHandler handler = this.OnPeerEntered;
            handler?.Invoke(id);
        }
    }
}