using Godot;
using Network;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;

namespace Network
{
    public enum TournementState
    {
        NotStarted,
        InLobby,
        Initializing,
        PreStart,
        Start,
        InProgress,
        Finished
    }

    [Serializable]
    public class TournementSnapshot
    {
        public TournementSnapshot(int battleIndex, List<PeerInfo> peers)
        {
            BattleIndex = battleIndex;
            Peers = peers;
        }

        public int BattleIndex { get; }
        public List<PeerInfo> Peers { get; }

        public string ToJson()
        {
            return JsonConvert.SerializeObject(this);
        }
    }

    public partial class Tournement : Node2D
    {
        protected TournementState State = TournementState.NotStarted;
        public ServerOptions ServerOptions;
        public TournementState state;
        private Network.Server server;
        private Network.Client client;

        public readonly Dictionary<int, PeerInfo> Peers = new Dictionary<int, PeerInfo>();

        public Battle Battle { get; private set; }

        public int BattleIndex { get; set; } = 0;

        [Export] public PackedScene BattleScene;

        public TournementSnapshot SnapShot
        {
            get => this.GetSnapshot();
            set => this.SetSnapshot(value);
        }

        private TournementSnapshot GetSnapshot()
        {
            List<PeerInfo> peers = this.Peers.Select(x => x.Value).ToList();
            TournementSnapshot snapShot = new TournementSnapshot(
            this.BattleIndex,
            peers
            );

            return snapShot;
        }

        [Authority]
        [AnyPeer]
        public void RecievedSnapshot(string TournementSnapshotJson)
        {
            TournementSnapshot tournementSnapshot = JsonConvert.DeserializeObject<TournementSnapshot>(TournementSnapshotJson);
            this.SnapShot = tournementSnapshot;
        }


        internal void SetSnapshot(TournementSnapshot tournementSnapshot)
        {
            this.BattleIndex = tournementSnapshot.BattleIndex;

            foreach (PeerInfo peer in tournementSnapshot.Peers)
            {
                var peerInfo = this.RegisterPeer(peer);
                this.Battle.SpawnPeer(peerInfo);
            }
        }
 
        public override void _Ready()
        {
            this.Name = "Tournement";
            this.State = TournementState.NotStarted;
        }

        void CreateBattle()
        {
            GD.Print("Tournament, Create Battle");

            PackedScene battleScene = this.BattleScene;
            this.Battle = battleScene.Instantiate() as Battle;
            this.AddChild(this.Battle);

            this.Battle.CreateStage(this.BattleIndex);
        }

        public virtual void Init()
        {
            GD.Print(what: "Tournement initServer");
            this.State = TournementState.Initializing;

            // Load the battle for the server
            this.CreateBattle();

            if (Multiplayer.IsServer())
            {
                this.server = GetNode("/root/Server") as Network.Server;
                this.server.OnPeerEntered += this.OnPeerEntered;
                this.server.OnPeerLeft += this.OnPeerLeft;
            }
            else
            {
                this.client = GetNode("/root/Client") as Network.Client;
                this.client.OnPeerEntered += this.OnPeerEntered;
                this.client.OnPeerLeft += this.OnPeerLeft;
            }
        }

        public PeerInfo RegisterPeer(PeerInfo peerInfo)
        {
            int peerId = peerInfo.Id;
            if (this.Peers.ContainsKey(peerId))
            {
                this.Peers[peerId].UpdatePeer(peerInfo);
            }
            else
            {
                this.Peers[peerId] = peerInfo;
            }
            
            return this.Peers[peerId];
        }


        public virtual void OnPeerEntered(PeerInfo peerInfo)
        {
            GD.Print(what: "Tournement OnPeerEntered");
            peerInfo.State = PeerInfoState.Ready;
            this.RegisterPeer(peerInfo);
            this.Battle.OnPeerEntered(peerInfo);

            this.Rpc(nameof(this.RecievedSnapshot),
                    this.SnapShot.ToJson());
        }

        public virtual void OnPeerLeft(int peerId)
        {
            this.Peers.Remove(peerId);
        }

        public override void _Process(float delta)
        {
            switch (this.State)
            {
                case TournementState.NotStarted:
                    break;
                case TournementState.InLobby:
                    break;
                case TournementState.Initializing:
                    break;
                case TournementState.PreStart:
                    break;
                case TournementState.Start:
                    break;
                case TournementState.InProgress:
                    break;
                case TournementState.Finished:
                    break;
            }
            // GD.Print(what: "Tournement _Process");
            // this.Rpc(nameof(this.RecievedSnapshot),
            // this.SnapShot.ToJson());
        }
    }
}