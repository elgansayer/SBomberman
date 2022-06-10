using Godot;
using System;
using Nakama;
using System.Threading.Tasks;
using System.Linq;
using Nakama.TinyJson;
using Godot.Collections;

namespace Network
{
    public enum PeerInfoState
    {
        None,
        Connecting,
        Registered,
        Ready,
    }

    public class PeerInfo
    {
        public PeerInfoState State { get; set; } = PeerInfoState.None;
        public int Id { get; set; }
        public string NakamaId { get; set; }
        public string DisplayName { get; set; }
        public string UserName { get; set; }
        public string Avatar { get; set; }
        public int Score { get; set; }
        public int Kills { get; set; }
        public int Deaths { get; set; }
        public int Ping { get; set; }
        public int Team { get; set; }
        public int Spawned { get; set; }
        public int LastUpdate { get; set; }
        public int LastPing { get; set; }
        public int LastDeath { get; set; }
        public int LastKill { get; set; }
        public int LastScore { get; set; }
        public int LastTeam { get; set; }
        public int LastState { get; set; }
        public int LastSpawned { get; set; }

        public Dictionary<string, object> ToDictionary()
        {
            Dictionary<string, object> dict = new Dictionary<string, object>();
            dict["id"] = this.Id;
            dict["nakama_id"] = this.NakamaId;
            dict["display_name"] = this.DisplayName;
            dict["user_name"] = this.UserName;
            dict["avatar"] = this.Avatar;

            return dict;
        }

        static public PeerInfo FromDictionary(Dictionary<string, object> dict)
        {
            PeerInfo info = new PeerInfo();

            GD.Print("PeerInfo FromDictionary", dict["id"]);
            object dd = dict["id"];

            GD.Print(dd.GetType());

            info.Id = (int)(long)dict["id"];
            info.NakamaId = (string)dict["nakama_id"];

            return info;
        }
    }
}