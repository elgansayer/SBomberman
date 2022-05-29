using Godot;
using System;
using Nakama;
using System.Threading.Tasks;

public partial class Network : Node
{
    protected IClient client;
    protected ISocketAdapter adapter;
    protected ISocket socket;
    protected IApiAccount account;
    protected ISession session;
    
    // Called when the node enters the scene tree for the first time.
    public override void _Ready()
    {
        GD.Print("Connecting to server");
        
        const string scheme = "http";
        const string host = "127.0.0.1";
        const int port = 7350;
        const string serverKey = "defaultkey";
        this.client = new Client(scheme, host, port, serverKey);
        client.Timeout = 10;

        this.Login();

        // or
        // #if UNITY_WEBGL && !UNITY_EDITOR
        //     ISocketAdapter adapter = new JsWebSocketAdapter();
        // #else
        //         ISocketAdapter adapter = new WebSocketAdapter();
        // #endif

        ISocketAdapter adapter = new WebSocketAdapter();
        this.socket = Socket.From(client, adapter);
    }


    public async Task<bool> Login()
    {
        // Login to Nakama using "device authentication".
        string deviceId = OS.GetUniqueId();

        RetryConfiguration retryConfiguration = new RetryConfiguration(100, 5);

        // Configure the retry configuration globally.
        client.GlobalRetryConfiguration = retryConfiguration;

        try
        {
            GD.Print("Attempting to login to the server");
            this.session = await client.AuthenticateDeviceAsync(deviceId);
            this.account = await client.GetAccountAsync(this.session);
            GD.Print("Logged in to server ", this.account.User.Id);
        }
        catch (ApiResponseException ex)
        {
            GD.Print("Error authenticating device: {0}:{1} ", ex.StatusCode, ex.Message);
            return false;
        }
        catch (Exception ex)
        {
            GD.Print("Login failed");
            GD.Print("Error authenticating device: ", ex.Message);
            return false;
        }
        
        return true;
    }

    // Called every frame. 'delta' is the elapsed time since the previous frame.
    public override void _Process(float delta)
    {
    }
}
