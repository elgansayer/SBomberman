using Godot;
using System;
using Nakama;
using System.Threading.Tasks;
using System.Collections.Generic;
using System.Linq;
using Nakama.TinyJson;

public class PlayerAccount
{
    public string Username;
    public string DisplayName;
    public string AvatarUrl;
    public string LangTag;
    public string Location;
    public string Timezone;
}

public partial class Network : Node
{
    protected IClient client;
    protected ISocketAdapter adapter;
    protected ISocket socket;
    protected IApiAccount account;
    protected ISession session;
    public string LastError { get; private set; }

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

        // this.Login();

        // or
        // #if UNITY_WEBGL && !UNITY_EDITOR
        //     ISocketAdapter adapter = new JsWebSocketAdapter();
        // #else
        //         ISocketAdapter adapter = new WebSocketAdapter();
        // #endif
    }
    public async Task ConnectSocketAsync()
    {
        GD.Print("Connecting to a socket");

        try
        {
            ISocketAdapter adapter = new WebSocketAdapter();
            this.socket = Socket.From(this.client, adapter);

            bool appearOnline = true;
            int connectionTimeout = 30;
            await socket.ConnectAsync(this.session, appearOnline, connectionTimeout);
        }
        catch (ApiResponseException ex)
        {
            this.LastError = ex.Message;
            GD.Print("Socket Error: {0}:{1} ", ex.StatusCode, ex.Message);
        }
        catch (Exception ex)
        {
            this.LastError = ex.Message;
            GD.Print("Error Socket: ", ex.Message);
        }
    }

    public async Task<bool> Login(string email, string password, string username = null, bool create = false)
    {
        RetryConfiguration retryConfiguration = new RetryConfiguration(100, 5);

        // Configure the retry configuration globally.
        client.GlobalRetryConfiguration = retryConfiguration;

        Dictionary<string, string> clientVars = new Dictionary<string, string>();
        clientVars.Add("displayName", username);

        try
        {
            GD.Print("Attempting to login to the server");
            this.session = await client.AuthenticateEmailAsync(email, password, username, create, clientVars);
            this.account = await client.GetAccountAsync(this.session);

            await this.ConnectSocketAsync();

            GD.Print("Logged in to server ", this.account.User.Id);
        }
        catch (ApiResponseException ex)
        {
            this.LastError = ex.Message;
            GD.Print("Authenticating Error: {0}:{1} ", ex.StatusCode, ex.Message);
            return false;
        }
        catch (Exception ex)
        {
            this.LastError = ex.Message;
            GD.Print("Login failed");
            GD.Print("Error authenticating: ", ex.Message);
            return false;
        }

        return true;
    }
    // https://heroiclabs.com/docs/nakama/client-libraries/unity/
    public async Task UpdateAccount(PlayerAccount playerAccount)
    {
        // string newUsername = "NotTheImp0ster";
        // string newDisplayName = "Innocent Dave";
        // string newAvatarUrl = "https://example.com/imposter.png";
        // string newLangTag = "en";
        // string newLocation = "Edinburgh";
        // string newTimezone = "BST";

        await this.client.UpdateAccountAsync(this.session, playerAccount.Username, displayName: playerAccount.DisplayName, playerAccount.AvatarUrl, playerAccount.LangTag, playerAccount.Location, playerAccount.Timezone);
    }

    public async Task<IMatch> JoinMatchName(string matchName)
    {
        Dictionary<string, string> status = new Dictionary<string, string>
        {
            { "Status", "Playing a match" },
            { "MatchId", "<MatchId>" }
        };

        await socket.UpdateStatusAsync(JsonWriter.ToJson(status));

        // When joining by match name, you use the CreateMatchAsync function instead of the JoinMatchAsync function
        return await socket.CreateMatchAsync(matchName);
    }

    public async Task<IMatch> JoinMatchId(string matchId)
    {
        Dictionary<string, string> status = new Dictionary<string, string>
        {
            { "Status", "Playing a match" },
            { "MatchId", "<MatchId>" }
        };

        await socket.UpdateStatusAsync(JsonWriter.ToJson(status));
        return await socket.JoinMatchAsync(matchId);
    }

    public async Task<IMatchmakerTicket> RealTimeMatchMaker(string matchId)
    {
        socket.ReceivedMatchmakerMatched += async matchmakerMatched =>
        {
            IMatch match = await socket.JoinMatchAsync(matchmakerMatched);
        };

        int minPlayers = 2;
        int maxPlayers = 10;
        string query = "";

        IMatchmakerTicket matchmakingTicket = await socket.AddMatchmakerAsync(query, minPlayers, maxPlayers);
        return matchmakingTicket;
    }

    public async Task CreateMatch(string matchName = null)
    {
        if (matchName == null)
        {
            matchName = "Match " + DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss");
        }

        GD.Print(what: "Creating battle with name: " + matchName);

        try
        {
            IMatch match = await this.socket.CreateMatchAsync();
            GD.Print(match);
        }
        catch (ApiResponseException ex)
        {
            this.LastError = ex.Message;
            GD.Print("Authenticating Error: {0}:{1} ", ex.StatusCode, ex.Message);
        }
        catch (Exception ex)
        {
            this.LastError = ex.Message;
            GD.Print("Login failed");
            GD.Print("Error authenticating: ", ex.Message);
        }

        // List 
        IApiFriendList friendsList = await client.ListFriendsAsync(session, 0, 100);
        IEnumerable<IApiUser> onlineFriends = friendsList.Friends.Where(f => f.User.Online).Select(f => f.User);

        // foreach (var friend in onlineFriends)
        // {
        //     var content = new
        //     {
        //         message = string.Format("Hey {0}, join me for a match!", friend.Username),
        //         matchId = match.Id
        //     };

        //     var channel = await socket.JoinChatAsync(friend.Id, ChannelType.DirectMessage);
        //     var messageAck = await socket.WriteChatMessageAsync(channel, JsonWriter.ToJson(content));
        // }
    }
}
