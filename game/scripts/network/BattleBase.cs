using Godot;
using Network;
using System;
using System.Collections.Generic;

namespace Network
{

    public abstract partial class GamePlayBase : Node2D
    {
        protected BattleState State = BattleState.NotStarted;
        protected GameType GameType = GameType.Unknown;
        protected Battle Battle;
        public int Time { get; internal set; }

        public Stage Stage;

        public GamePlayBase(Battle battle)
        {
            this.Battle = battle;
        }

        public override void _Ready()
        {
            this.State = BattleState.NotStarted;
        }

        public virtual void init()
        {
            this.State = BattleState.NotStarted;
        }

        public virtual void OnPeerReady()
        {
            // this.CanBattleStart();
        }

        public virtual void OnPeerLeft()
        {
            this.State = BattleState.NotStarted;
        }

        // public override void _Process(float delta)
        // {
        //     this.State = BattleState.NotStarted;
        // }

        // public virtual bool CanBattleStart()
        // {
        //     int numPlayers = this.server.PeerList.Count;
        //     if (numPlayers >= this.BattleOptions.MinPlayers)
        //     {
        //         return true;
        //     }

        //     return false;
        //     // {
        //     //     this.State = BattleState.InLobby;
        //     //     return true;
        //     // }
        // }

        // public virtual bool CanBattleStart()
        // {
        // }

        // public virtual bool CanBattleEnd()
        // {
        // }

        public virtual void LobbyStarted()
        {
            this.State = BattleState.InLobby;
        }

        public virtual void LobbyEnded()
        {
            throw new NotImplementedException();
        }

        public virtual void BattleInitializing()
        {
            this.State = BattleState.Initializing;
            this.BattlePreStart();
            this.BattleStart();
            this.BattleStarted();
        }

        public virtual void BattlePreStart()
        {
            this.State = BattleState.PreStart;
        }

        public virtual void BattleStart()
        {
            this.State = BattleState.Start;
        }

        public virtual void BattleStarted()
        {
            this.State = BattleState.InProgress;
        }

        public virtual void BattleEnded()
        {
            this.State = BattleState.Finished;
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

        public virtual void CheckBattleEnd()
        {
            throw new NotImplementedException();
        }
    }

}

