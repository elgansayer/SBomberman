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
        public List<Vector2i> ExplodableRocks { get; private set; }

        public BattleSnapShot()
        {
            this.ExplodableRocks = new List<Vector2i>();
        }

        public BattleSnapShot(BattleState state, int time, int stageIndex, List<Vector2i> explodableRockPositions)
        {
            this.State = state;
            this.Time = time;
            this.StageIndex = stageIndex;
            this.ExplodableRocks = explodableRockPositions;
        }

        public string ToJson()
        {
            return JsonConvert.SerializeObject(this);
        }
    }
}

