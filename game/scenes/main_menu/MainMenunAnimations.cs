using Godot;
using System;

public partial class MainMenunAnimations : Node2D
{
    [Export] public NodePath[] ButtonNodes;
    [Export] public NodePath TirraSpriteNode;

    private Button lastButton;

    [Export] public NodePath FlashTimer;

    // Called when the node enters the scene tree for the first time.
    public override void _Ready()
    {
        GetNode<Timer>(FlashTimer).Timeout += OnFlashTimerTimeout;
        this.SwapPosition();
        this.AddClickHandlers();
    }

    private void SwapPosition()
    {
        GD.Print("SwapPosition");
        if (this.TirraSpriteNode == null)
        {
            return;
        }

        AnimatedSprite2D tirraSprite = GetNode<AnimatedSprite2D>(this.TirraSpriteNode);
        Vector2 newPosition = tirraSprite.GlobalPosition;

        Button selectedButton = this.getSelectedButton();
        if (selectedButton != null)
        {
            newPosition.y = selectedButton.GlobalPosition.y;
        }

        Tween tween = this.BuildTween(tirraSprite, newPosition);
        if (tween == null)
        {
            return;
        }

        GetNode<Timer>(FlashTimer).Stop();
        tween.Play();
        this.FlashButton(selectedButton);
    }

    private void FlashButton(Button button)
    {
        this.FlashButtonWhite(button);

        Timer timer = new Timer();
        timer.WaitTime = 0.5f;
        timer.OneShot = true;

        Callable callable = new Callable(this, "FlashButtonOff");

        Godot.Collections.Array binds =  new Godot.Collections.Array(){ button };
        timer.Connect("timeout", callable , binds );
        timer.Autostart = true;
        AddChild(timer);
        timer.Start();
    
        GetNode<Timer>(FlashTimer).Start();
    }

    private void FlashButtonOff(Button button)
    {
        GD.Print("FlashButtonOff");
        float flash_value = 0.0f;
        this.SetShaderFlash(button, flash_value);
    }

    private void FlashButtonWhite(Button button)
    {
        float flash_value = 0.5f;
        this.SetShaderFlash(button, flash_value);
    }

    private void SetShaderFlash(Button button, float flash_value)
    {
        ShaderMaterial btnSpriteMaterial = button.Material as ShaderMaterial;
        btnSpriteMaterial.SetShaderParam("white_value", flash_value);
    }

    private Tween BuildTween(AnimatedSprite2D tirraSprite, Vector2 newPosition)
    {
        Vector2 newVector = tirraSprite.GlobalPosition - newPosition;
        float speed = newVector.Length() / 100;

        if (speed <= 0)
        {
            return null;
        }

        float direction = tirraSprite.GlobalPosition.y - newPosition.y;
        if (direction > 0)
        {
            tirraSprite.Play("walk_up");
        }
        else
        {
            tirraSprite.Play("walk_down");
        }

        Tween tween = GetTree().CreateTween();
        tween.TweenProperty(
            tirraSprite,
            "position",
            newPosition,
            speed
        );

        Callable caller = new Callable(this, "OnTweenCompleted");
        tween.TweenCallback(caller);
        return tween;
    }

    private void OnTweenCompleted()
    {
        AnimatedSprite2D tirraSprite = GetNode<AnimatedSprite2D>(this.TirraSpriteNode);
        tirraSprite.Stop();
        tirraSprite.Play("default");
    }


    private void AddClickHandlers()
    {
        foreach (NodePath buttonNode in this.ButtonNodes)
        {
            Button button = GetNode<Button>(buttonNode);
            button.Pressed += SwapPosition;
        }

        Button firstButton = GetNode<Button>(this.ButtonNodes[0]);
        firstButton.GrabFocus();
        firstButton.GrabClickFocus();
    }

    private void OnFlashTimerTimeout()
    {
        Button button = this.getSelectedButton();
        // this.FlashButton(button);
    }

    private Button getSelectedButton()
    {
        foreach (NodePath buttonNode in this.ButtonNodes)
        {
            Button button = GetNode<Button>(buttonNode);
            bool hasFocus = button.HasFocus();

            if (hasFocus)
            {
                return button;
            }
        }

        return null;
    }
}
