
using Godot;
using System;
using System.Collections.Generic;

namespace Network
{
    public enum BattleState
    {
        NotStarted,
        InLobby,
        Initializing,
        PreStart,
        Start,
        InProgress,
        Finished
    }
}