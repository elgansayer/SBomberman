using Godot;
using Network;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;

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

    // [Serializable]
    // public class TournementData
    // {
    //     public int StageIndex { get; private set; }
    //     public GameType GameType { get; private set; }
    //     public int MaxPlayers { get; private set; }
    //     public int MinPlayers { get; private set; }
    //     public int NumBattles { get; private set; }
    //     public int Time { get; private set; }
    //     public bool SpawnShuffle { get; private set; }
    //     public bool Devil { get; private set; }
    //     public bool MadBomber { get; private set; }
    //     public int[] Stages { get; private set; }

    //     public TournementData(int stageIndex, GameType gameType, int maxPlayers, int minPlayers, int numBattles, int time, bool spawnShuffle, bool devil, bool madBomber, int[] stages)
    //     {
    //         this.StageIndex = stageIndex;

    //         this.GameType = gameType;
    //         this.MaxPlayers = maxPlayers;
    //         this.MinPlayers = minPlayers;
    //         this.NumBattles = numBattles;
    //         this.Time = time;
    //         this.SpawnShuffle = spawnShuffle;
    //         this.Devil = devil;
    //         this.MadBomber = madBomber;
    //         this.Stages = stages;
    //     }
    // }

    public partial class Tournement : Node2D
    {
        protected TournementState State = TournementState.NotStarted;
        public ServerOptions ServerOptions;
        public TournementState state;
        private Network.Server server;
        private Network.Client client;

        public readonly Dictionary<int, TournementPeerInfo> TournementPeers = new Dictionary<int, TournementPeerInfo>();

        public Battle Battle { get; private set; }

        public int StageIndex { get; set; } = 0;

        [Export] public PackedScene BattleScene;

        public override void _Ready()
        {
            this.Name = "Tournement";
            this.State = TournementState.NotStarted;
        }

        // public virtual int GetNextBattleStage()
        // {
        //     int nextStageIndex = this.stageIndex + 1;

        //     if (this.stages.Length <= nextStageIndex)
        //     {
        //         // We are done
        //         return -1;
        //     }

        //     return nextStageIndex;
        // }

        // [Authority]
        // [AnyPeer]
        // public virtual void ClientLoadBattle(string optionsJson)
        // {
        //     // Create a battle options
        //     BattleSnapShot options = JsonConvert.DeserializeObject<BattleSnapShot>(optionsJson);

        //     this.CreateBattle();

        //     // Upset the current stage            
        //     // this.stageIndex = options.StageIndex;
        //     // this.battle.Time = options.Time;

        //     // this.battle.Stage.ExplodableRocks = options.ExplodableRocks;

        //     this.State = TournementState.InLobby;
        // }

        void CreateBattle()
        {
            GD.Print("Tournament, Create Battle");
            PackedScene battleScene = this.BattleScene;
            this.Battle = battleScene.Instantiate() as Battle;
            this.AddChild(this.Battle);

            this.Battle.CreateStage(this.StageIndex);
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

        // void SendStageToClients()
        // {
        //     // Load a battle for each player
        //     string optionsJson = this.GetStageStateJson();
        //     this.Rpc(nameof(this.ClientLoadBattle), optionsJson);
        // }

        // string GetStageStateJson()
        // {
        //     // Only done on the server. Creates the rocks
        //     List<Vector2i> rocks = this.battle.Stage.ExplodableRocks;

        //     // Create a battle options
        //     ClientBattleOptions options = new ClientBattleOptions()
        //     {
        //         GameType = this.ServerOptions.GameType,
        //         Time = this.battle.Time,
        //         StageIndex = this.stageIndex,
        //         ExplodableRocks = rocks
        //     };

        //     GD.Print(what: "Tournement LoadBattlesOnClients");
        //     return JsonConvert.SerializeObject(options);
        // }

        public virtual void Finish()
        {
            this.State = TournementState.Finished;
        }

        public virtual void OnPeerEntered(int peerId)
        {
            GD.Print(what: "Tournement OnPeerEntered");

            TournementPeerInfo TournementPeerInfo = new TournementPeerInfo();
            TournementPeerInfo.State = PeerInfoState.Ready;
            this.TournementPeers[peerId] = TournementPeerInfo;
        }

        public virtual void OnPeerLeft(int peerId)
        {
            TournementPeers.Remove(peerId);
        }

        // public override void _Process(float delta)
        // {
        //     this.State = TournementState.NotStarted;
        // }

        // public virtual bool CanTournementStart()
        // {
        //     int numPlayers = this.server.PeerList.Count;
        //     if (numPlayers >= this.ServerOptions.MinPlayers)
        //     {
        //         return true;
        //     }

        //     return false;
        //     // {
        //     //     this.State = TournementState.InLobby;
        //     //     return true;
        //     // }
        // }

        // public virtual bool CanTournementStart()
        // {
        // }

        // public virtual bool CanTournementEnd()
        // {
        // }

        public virtual void LobbyStarted()
        {
            this.State = TournementState.InLobby;
        }

        public virtual void LobbyEnded()
        {
            throw new NotImplementedException();
        }

        public virtual void TournementInitializing()
        {
            this.State = TournementState.Initializing;
            this.TournementPreStart();
            this.TournementStart();
            this.TournementStarted();
        }

        public virtual void TournementPreStart()
        {
            this.State = TournementState.PreStart;

        }

        public virtual void TournementStart()
        {
            this.State = TournementState.Start;
        }

        public virtual void TournementStarted()
        {
            this.State = TournementState.InProgress;
        }

        public virtual void TournementEnded()
        {
            this.State = TournementState.Finished;
        }

        public virtual void ClockStarted()
        {
            throw new NotImplementedException();
        }

        public virtual void ClockEnded()
        {
            throw new NotImplementedException();
        }

        public virtual void ClockTick()
        {
            throw new NotImplementedException();
        }

        public virtual void CheckTournementEnd()
        {
            throw new NotImplementedException();
        }
    }
}