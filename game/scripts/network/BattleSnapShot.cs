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
        public int BattleId { get; private set; }

        // public List<BattlePeerInfo> PeerInfo { get; private set; }

        public BattleSnapShot()
        {
            this.ExplodableRocks = new List<Vector2i>();
            // this.PeerInfo = new List<BattlePeerInfo>();
        }

        public BattleSnapShot(BattleState state, int time, int stageIndex,
            List<Vector2i> explodableRockPositions, int battleId)
        {
            this.State = state;
            this.Time = time;
            this.StageIndex = stageIndex;
            this.ExplodableRocks = explodableRockPositions;
            this.BattleId = battleId;
        }

        public string ToJson()
        {
            return JsonConvert.SerializeObject(this);
        }
    }
}

