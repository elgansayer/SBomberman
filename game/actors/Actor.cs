using Godot;
using System;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;

[Flags]
public enum InputActions
{
    None = 0,
    Left = 1,
    Right = 2,
    Up = 4,
    Down = 8,
    PlantBomb = 16,
    BarBeverage = 32
}

public class ActorInputSnapshot
{
    public InputActions InputActions { get; private set; }

    public ActorInputSnapshot(InputActions inputActions)
    {
        InputActions = inputActions;
    }

    public string ToJson()
    {
        return Newtonsoft.Json.JsonConvert.SerializeObject(this);
    }
}


public class ActorState
{
    public Vector2 Position { get; private set; }
    public long Time { get; private set; }

    public ActorState(Vector2 position, long time)
    {
        Position = position;
        Time = time;
    }

    public string ToJson()
    {
        return Newtonsoft.Json.JsonConvert.SerializeObject(this);
    }

    public void updateState(ActorState actorState)
    {
        if (this.Time > actorState.Time)
        {
            return;
        }

        this.Position = actorState.Position;
        this.Time = actorState.Time;
    }
}


public partial class Actor : CharacterBody2D
{
    public const float Speed = 300.0f;

    private ActorState actorState { get; set; }

    public override void _Ready()
    {
        // this.SetPhysicsProcess(true);

        // var isPro = this.IsPhysicsProcessing();
        // GD.Print("IsPhysicsProcessing: " + isPro);
        this.RpcConfig(nameof(this.recievedActorState), RPCMode.AnyPeer, false, TransferMode.UnreliableOrdered);

        // Call the base class _Ready() method.
        base._Ready();
    }

    public override void _PhysicsProcess(float delta)
    {
        // GD.Print(what: "_PhysicsProcess");

        if (!this.Multiplayer.IsServer())
        {
            if (this.actorState != null)
            {
                // GD.Print(what: "_PhysicsProcess ActorState: " + this.actorState.ToJson());
                // Update the actor's position.
                // var newVel = this.Position = this.actorState.Position;
                this.Position = this.actorState.Position;
            }

            // Get the input flags from the players input.    
            InputActions inputFlagsValue = this.getInputFlags();

            // GD.Print(what: "inputFlagsValue: " + inputFlagsValue);

            ActorInputSnapshot snapShot = new ActorInputSnapshot(
                inputActions: inputFlagsValue
            );

            sendPlayerState(snapShot);
        }
    }
    private static readonly SemaphoreSlim _semaphoreSlim = new SemaphoreSlim(1, 1);

    private void ProcessActorInput(InputActions inputFlagsValue)
    {
        // Get the current velocity of the character.
        Velocity = this.getVelocity(inputFlagsValue);

        MoveAndSlide();
    }

    /**
    * Get the input flags from the players input.    
    */
    private InputActions getInputFlags()
    {
        Dictionary<string, InputActions> data = new Dictionary<string, InputActions>();
        data["move_left"] = InputActions.Left;
        data["move_right"] = InputActions.Right;
        data["move_up"] = InputActions.Up;
        data["move_down"] = InputActions.Down;

        InputActions inputFlagsValue = InputActions.None;
        foreach (KeyValuePair<string, InputActions> item in data)
        {
            if (Input.IsActionPressed(item.Key))
            {
                inputFlagsValue = inputFlagsValue | item.Value;
            }
        }

        return inputFlagsValue;
    }

    private void sendPlayerState(ActorInputSnapshot snapShot)
    {
        // await _semaphoreSlim.WaitAsync();

        // GD.Print(what: "sendPlayerState: " + snapShot.ToJson());
        // await Task.Run(() =>
        // {
        this.RpcId(1, nameof(this.recievedActorState), snapShot.ToJson());
        // });

        // _semaphoreSlim.Release();
    }

    private static readonly object _locker = new object();

    private void recievedActorState(string actorInputSnapshot)
    {
        lock (_locker)
        {
            int id = Multiplayer.GetRemoteSenderId();

            ActorInputSnapshot snapShot = Newtonsoft.Json.JsonConvert.DeserializeObject<ActorInputSnapshot>(actorInputSnapshot);
            GD.Print(what: "recievedActorState: " + snapShot.ToJson());

            if (snapShot.InputActions != InputActions.None)
            {
                this.ProcessActorInput(snapShot.InputActions);
            }

            this.actorState = this.GetActorState();

            // GD.Print("ActorState: " + this.actorState.ToJson());

            // Update the actor state.
            Network.Battle battle = GetTree().Root.GetNode<Network.Battle>("Tournement/Battle");
            if (battle == null)
            {
                GD.PushError("Could not find Battle node in the scene.");
                GD.Print("Battle is null");
                return;
            }

            // GD.Print("battle ", battle);
            battle.SetActorState(id, this.actorState);
        }
    }

    public ActorState GetActorState()
    {
        long unixTimestamp = DateTimeOffset.Now.ToUnixTimeSeconds();
        return new ActorState(position: this.Position, time: unixTimestamp);
    }

    /**
    * Get the velocity of the actor based on the input flags.
    */
    private Vector2 getVelocity(InputActions inputFlagsValue)
    {
        Dictionary<InputActions, Vector2> data = new Dictionary<InputActions, Vector2>();
        data[InputActions.Left] = new Vector2(-1, 0);
        data[InputActions.Right] = new Vector2(1, 0);
        data[InputActions.Up] = new Vector2(0, -1);
        data[InputActions.Down] = new Vector2(0, 1);

        foreach (KeyValuePair<InputActions, Vector2> item in data)
        {
            if (inputFlagsValue.HasFlag(item.Key))
            {
                return item.Value * Speed;
            }
        }

        return Vector2.Zero;
    }

    public void UpdateFromState(ActorState value)
    {
        GD.Print(what: "UpdateFromState: " + value.ToJson());
        this.actorState = value;
    }
}
