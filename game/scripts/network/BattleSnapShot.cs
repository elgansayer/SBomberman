using Godot;
using Network;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;

namespace Network
{
    [Serializable]
    public class BattleSnapShot
    {
        public BattleState State { get; private set; }
        public int Time { get; private set; }
        public int StageIndex { get; private set; }

        [JsonProperty("ExplodableRocks")]
        public long ExplodableRockFlags { get; private set; }

        public Dictionary<int, ActorState> ActorStates { get; private set; }

        public BattleSnapShot()
        {        
            this.ActorStates = new Dictionary<int, ActorState>();
        }

        public BattleSnapShot(BattleState state, int time, int stageIndex,
            long explodableRockPositions, Dictionary<int, ActorState> actorStates)
        {
            this.State = state;
            this.Time = time;
            this.StageIndex = stageIndex;
            this.ExplodableRockFlags = explodableRockPositions;
            this.ActorStates = actorStates;
        }

        public string ToJson()
        {
            return JsonConvert.SerializeObject(this);
        }
    }
}

