using Godot;
using System;
using Nakama;
using System.Threading.Tasks;
using System.Collections.Generic;
using System.Linq;
using Nakama.TinyJson;

namespace Network
{
    public class PlayerAccount
    {
        public string Username;
        public string DisplayName;
        public string Avatar;
        public string LangTag;
        public string Location;
        public string Timezone;
    }
}