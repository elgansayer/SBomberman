using Godot;
using System;

public partial class Actor : CharacterBody2D
{
//     public const float Speed = 300.0f;
//     public const float JumpVelocity = -400.0f;

//     // Get the gravity from the project settings to be synced with RigidDynamicBody nodes.
//     public float gravity = (float)ProjectSettings.GetSetting("physics/2d/default_gravity");

//     public override void _Ready()
//     {
//         // Call the base class _Ready() method.
//         base._Ready();
// 		this.Position = new Vector2(100, 100);
//     }

//     public override void _PhysicsProcess(float delta)
//     {
//         Vector2 velocity = Velocity;

//         // Add the gravity.
//         if (!IsOnFloor())
//             velocity.y += gravity * delta;

//         // Handle Jump.
//         if (Input.IsActionJustPressed("ui_accept") && IsOnFloor())
//             velocity.y = JumpVelocity;

//         // Get the input direction and handle the movement/deceleration.
//         // As good practice, you should replace UI actions with custom gameplay actions.
//         Vector2 direction = Input.GetVector("ui_left", "ui_right", "ui_up", "ui_down");
//         if (direction != Vector2.Zero)
//         {
//             velocity.x = direction.x * Speed;
//         }
//         else
//         {
//             velocity.x = Mathf.MoveToward(Velocity.x, 0, Speed);
//         }

//         Velocity = velocity;
//         MoveAndSlide();
//     }
}
