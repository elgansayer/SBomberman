using Godot;
using Network;
using System;

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

    public partial class Tournement : Node2D
    {
        [Export] private PackedScene[] StageScenes;

        protected TournementState State = TournementState.NotStarted;
        protected GameType GameType = GameType.Unknown;
        public ServerOptions ServerOptions;
        public TournementState state;
        private Network.Server server;

        private int[] stages;
        private int currentStageIndex;

        public virtual void LoadBattlesOnClients()
        {
            GD.Print(what: "Tournement LoadBattlesOnClients");
            // int nextBatttle = this.GetNextBattleStage();
            // if (nextBatttle == -1)
            // {
            //     this.Finish();
            //     return;
            // }

            int nextBatttle = this.currentStageIndex;
            this.State = TournementState.Initializing;

            this.Rpc(nameof(this.LoadBattle), nextBatttle);
            this.LoadBattle(nextBatttle);
        }

        public virtual int GetNextBattleStage()
        {

            int nextStageIndex = this.currentStageIndex + 1;

            if (this.stages.Length <= nextStageIndex)
            {
                // We are done
                return -1;
            }

            return nextStageIndex;
        }

        [Authority]
        [AnyPeer]
        public virtual void LoadBattle(int stageId)
        {
            // Upset the current stage
            this.currentStageIndex = stageId;

            GD.Print(what: "Tournement LoadBattle " + stageId.ToString());

            // Load the stage
            GD.Print("Loading stage: " + stageId);
            PackedScene stage1 = this.StageScenes[0];

            Game game = GetNode("/root/Game") as Game;        
            game.ChangeScene(node: stage1.Instantiate());

            this.State = TournementState.InLobby;

            // Hide the loading scrfeens
            game.HideLoadingScreen();
        }

        public override void _Ready()
        {
            this.State = TournementState.NotStarted;
        }

        public virtual void initClient()
        {
            this.State = TournementState.Initializing;
        }

        public virtual void initServer()
        {
            GD.Print(what: "Tournement initServer");
            this.State = TournementState.Initializing;

            this.server = GetNode("/root/Server") as Network.Server;
            this.server.OnPeerEntered += this.OnPeerEntered;
            this.server.OnPeerLeft += this.OnPeerLeft;

            this.LoadBattlesOnClients();
        }

        public virtual void Finish()
        {

            this.State = TournementState.Finished;
        }

        public virtual void OnPeerEntered(int peerId)
        {
            GD.Print(what: "Tournement OnPeerEntered");
            // Peer has entered the server
            // Tell them to load the map
            int stageIndex = this.ServerOptions.CurrentStageIndex;
            this.RpcId(peerId, nameof(this.LoadBattle), stageIndex);
        }

        public virtual void OnPeerLeft(int peerId)
        {
            this.State = TournementState.NotStarted;
        }

        // public override void _Process(float delta)
        // {
        //     this.State = TournementState.NotStarted;
        // }

        public virtual bool CanTournementStart()
        {
            int numPlayers = this.server.PeerList.Count;
            if (numPlayers >= this.ServerOptions.MinPlayers)
            {
                return true;
            }

            return false;
            // {
            //     this.State = TournementState.InLobby;
            //     return true;
            // }
        }

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