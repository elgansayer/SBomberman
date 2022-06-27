using Godot;
using System;
using Nakama;
using System.Threading.Tasks;
using System.Linq;
using Nakama.TinyJson;
using Newtonsoft.Json;
using System.Collections.Generic;

namespace Network
{
    public enum PeerInfoState
    {
        None,
        Connecting,
        Registered,
        Ready,
        InLobby,
        Disconnected,
    }

    public class PeerInfo
    {
        public PeerInfoState State { get; set; } = PeerInfoState.None;
        public int Id { get; set; }
        public string NakamaId { get; set; }
        public string DisplayName { get; set; }
        public string UserName { get; set; }
        public int? AvatarId { get; set; }
        public Vector2 SpawnPoint { get; set; }
        [JsonIgnore]
        public Node2D SpawnedActor { get; internal set; }

        // public readonly Dictionary<int, BattlePeerInfo> Battles = new Dictionary<int, BattlePeerInfo>();

        public void UpdatePeer(PeerInfo peerInfo)
        {
            this.NakamaId = peerInfo.NakamaId ?? this.NakamaId;
            this.DisplayName = peerInfo.DisplayName ?? this.DisplayName;
            this.UserName = peerInfo.UserName ?? this.UserName;
            this.AvatarId = peerInfo.AvatarId ?? this.AvatarId;
            this.SpawnPoint = peerInfo.SpawnPoint;

            // foreach (KeyValuePair<int, BattlePeerInfo> item in peerInfo.Battles)
            // {
            //     this.Battles[item.Key] = item.Value;
            // }
        }

        // public void AddBattle(BattlePeerInfo BattleInfo)
        // {
        //     this.Battles.Add(BattleInfo.Id, value: BattleInfo);
        // }

        // public BattlePeerInfo AddBattle(int BattleId)
        // {
        //     BattlePeerInfo battleInfo = new BattlePeerInfo();
        //     battleInfo.Id = BattleId;
        //     this.Battles.Add(BattleId, battleInfo);
        //     return battleInfo;
        // }

        // public bool RemoveBattle(int BattleId)
        // {
        //     return this.Battles.Remove(BattleId);
        // }

        // public bool RemoveBattle(BattlePeerInfo BattleInfo)
        // {
        //     return this.Battles.Remove(BattleInfo.Id);
        // }

        // internal void UpdateBattle(BattlePeerInfo BattleInfo)
        // {
        //     this.Battles[BattleInfo.Id].UpdateBattle(BattleInfo);
        // }

        internal string ToJson()
        {
            return JsonConvert.SerializeObject(this);
        }
    }

    // public class BattlePeerInfo
    // {
    //     public int Id { get; set; }
    //     public int? Kills { get; set; }
    //     public int? Deaths { get; set; }
    //     // [JsonIgnore]
    //     public SpawnPoint spawnPoint { get; set; }

    //     public void UpdateBattle(BattlePeerInfo battleInfo)
    //     {
    //         this.Kills = battleInfo.Kills ?? this.Kills;
    //         this.Deaths = battleInfo.Deaths ?? this.Deaths;
    //     }
    // }

    // public class TournementPeerInfo
    // {
    //     public PeerInfoState State { get; set; } = PeerInfoState.None;
    //     public BattlePeerInfo[] BattlePeerInfo { get; set; }
    // }

}