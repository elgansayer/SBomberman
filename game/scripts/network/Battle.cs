using Godot;
using Network;
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
    public class ClientBattleOptions
    {
        public GameType GameType;
        public int Time;
        public int StageIndex;
        public List<Vector2i> ExplodableRocks;
    }

    public partial class Battle : Node2D
    {
        [Export] private PackedScene[] stageScenes;
        private Stage stage;

        public GamePlayNormal GamePlay { get; private set; }

        internal void CreateStage(int stageIndex)
        {
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

