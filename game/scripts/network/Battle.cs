using Godot;
using Network;
using Newtonsoft.Json;
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

    public partial class Battle : Node2D
    {
        [Export] private PackedScene[] stageScenes;
        private Stage stage;
        private int time = 0;
        private int stageIndex = 0;
        private BattleState state = BattleState.Initializing;

        public GamePlayNormal GamePlay { get; private set; }

        public BattleSnapShot SnapShot
        {
            get => this.GetSnapshot();
            set => this.SetSnapshot(value);
        }

        private BattleSnapShot GetSnapshot()
        {
            if (this.stage == null)
            {
                GD.Print("Battle.GetSnapshot: stage is null");
                return null;
            }

            List<Vector2i> explodableRockPositions = this.stage.ExplodableRocks.ConvertAll<Vector2i>((rock)
            => this.stage.TileMap.WorldToMap(rock.GlobalPosition));

            BattleSnapShot snapShot = new BattleSnapShot(
            this.state,
            this.time,
            this.stageIndex,
            explodableRockPositions
            );

            return snapShot;
        }

        internal void SetSnapshot(BattleSnapShot battleSnapShot)
        {
            this.state = battleSnapShot.State;
            this.time = battleSnapShot.Time;
            this.stageIndex = battleSnapShot.StageIndex;

            this.stage.TileMap.SpawnRocks(battleSnapShot.ExplodableRocks);
        }

        internal void CreateStage(int stageIndex)
        {
            this.stageIndex = stageIndex;

            // Load the stage
            GD.Print("Loading stage: ");

            PackedScene packedScene = this.stageScenes[stageIndex];
            Node node = packedScene.Instantiate();
            this.stage = node as Stage;
            Game game = GetTree().Root.GetNode("Game") as Game;
            game.ChangeScene(node: this.stage);

            GD.Print("Loading node: ", node);
            GD.Print("Loading packedScene: ", packedScene);
            GD.Print("Loading stage: ", this.stage);

            // Hide the loading scrfeens
            game.HideLoadingScreen();

            state = BattleState.InLobby;
        }

        public void CreateGamePlay(GameType gameType)
        {
            switch (gameType)
            {
                case GameType.Unknown:
                    break;
                case GameType.NormalMostWins:
                    break;
                case GameType.BestScoreKillsAndWins:
                    break;
                case GameType.GoldBomber:
                    break;
                case GameType.DeathMatchMostKills:
                    break;
                case GameType.Virus:
                    break;
                default:
                    this.GamePlay = new GamePlayNormal(this);
                    break;
            }

            this.GamePlay = new GamePlayNormal(this);
        }
    }
}

