using Godot;
using Network;
using Newtonsoft.Json;
using Newtonsoft.Json.Converters;
using System;
using System.Collections.Generic;
using System.Numerics;

namespace Network
{
    [Serializable]
    public class BattleSnapShot
    {
        public BattleState State { get; private set; }
        public int Time { get; private set; }
        public int StageIndex { get; private set; }

        // [JsonProperty("ExplodableRocks")]
        // public Dictionary<Vector2i, List<Vector2i>> ExplodableRockFlags { get; private set; }

        public Dictionary<int, ActorState> ActorStates { get; private set; }

        public BattleSnapShot()
        {
            this.ActorStates = new Dictionary<int, ActorState>();
            // this.ExplodableRockFlags = new Dictionary<Vector2i, List<Vector2i>>();
        }

        public BattleSnapShot(BattleState state, int time, int stageIndex, Dictionary<int, ActorState> actorStates)
        {
            this.State = state;
            this.Time = time;
            this.StageIndex = stageIndex;
            // this.ExplodableRockFlags = explodableRockPositions;
            this.ActorStates = actorStates;
        }

        public string ToJson()
        {
            return JsonConvert.SerializeObject(this);
        }

        public static BattleSnapShot Deserialize(string json)
        {
            // BattleSnapShot obj = JsonConvert.DeserializeObject<BattleSnapShot>(
            // json, new JsonConverter[] {new MyConverter()});

            return JsonConvert.DeserializeObject<BattleSnapShot>(json);
        }
    }
}

class MyConverter : CustomCreationConverter<BattleSnapShot>
{
    public override BattleSnapShot Create(Type objectType)
    {
        return new BattleSnapShot();
    }

    public override bool CanConvert(Type objectType)
    {
        return true;
        GD.Print("MyConverter.CanConvert");
        // in addition to handling IDictionary<string, object>
        // we want to handle the deserialization of dict value
        // which is of type object
        return objectType == typeof(object) || base.CanConvert(objectType);
    }

    public override object ReadJson(JsonReader reader, Type objectType, object existingValue, JsonSerializer serializer)
    {
        GD.Print("MyConverter.ReadJson ");
        GD.Print("MyConverter.ReadJson ", objectType.UnderlyingSystemType.ToString());
        GD.Print("MyConverter.ReadJson ", objectType.ToString());
        // GD.Print("MyConverter.ReadJson ", objectType.ReflectedType.ToString());
        GD.Print("MyConverter.ReadJson ", objectType.BaseType.ToString());
        GD.Print("MyConverter.ReadJson ", objectType.FullName);

        GD.Print("MyConverter.ReadJson ", reader);
        GD.Print("MyConverter.ReadJson ", reader.TokenType);



        if (reader.TokenType == JsonToken.StartObject
            || reader.TokenType == JsonToken.Null)
            return base.ReadJson(reader, objectType, existingValue, serializer);

        // if the next token is not an object
        // then fall back on standard deserializer (strings, numbers etc.)
        return serializer.Deserialize(reader);
    }
}

class VecConverter : CustomCreationConverter<BattleSnapShot>
{
    public override BattleSnapShot Create(Type objectType)
    {
        return new BattleSnapShot();
    }

    public override bool CanConvert(Type objectType)
    {
        return true;
        GD.Print("VecConverter.CanConvert");
        // in addition to handling IDictionary<string, object>
        // we want to handle the deserialization of dict value
        // which is of type object
        return objectType == typeof(object) || base.CanConvert(objectType);
    }

    public override object ReadJson(JsonReader reader, Type objectType, object existingValue, JsonSerializer serializer)
    {
        GD.Print("VecConverter.ReadJson ");
        GD.Print("VecConverter.ReadJson ", objectType.UnderlyingSystemType.ToString());
        GD.Print("VecConverter.ReadJson ", objectType.ToString());
        // GD.Print("VecConverter.ReadJson ", objectType.ReflectedType.ToString());
        GD.Print("VecConverter.ReadJson ", objectType.BaseType.ToString());
        GD.Print("VecConverter.ReadJson ", objectType.FullName);

        GD.Print("VecConverter.ReadJson ", reader);
        GD.Print("VecConverter.ReadJson ", reader.TokenType);



        if (reader.TokenType == JsonToken.StartObject
            || reader.TokenType == JsonToken.Null)
            return base.ReadJson(reader, objectType, existingValue, serializer);

        // if the next token is not an object
        // then fall back on standard deserializer (strings, numbers etc.)
        return serializer.Deserialize(reader);
    }
}