using Godot;
using System;
using Nakama;
using System.Threading.Tasks;

public partial class Network : Node
{
    protected IClient _client;
    // Called when the node enters the scene tree for the first time.
    public override void _Ready()
    {
        const string scheme = "http";
        const string host = "127.0.0.1";
        const int port = 7350;
        const string serverKey = "defaultkey";
        Client client = new Client(scheme, host, port, serverKey);
        _client = client;
        
        this.Login();
    }


    public async void Login()
    {
        // Login to Nakama using "device authentication".
        var deviceId = OS.GetUniqueId();

        Task<ISession> auth = _client.AuthenticateDeviceAsync(deviceId);

        auth.Start();
        ISession session = await auth;

    }

    // Called every frame. 'delta' is the elapsed time since the previous frame.
    public override void _Process(float delta)
    {
    }

    public void LocalDataStoreSlot()
    {
        // using Nakama;

    }
}
