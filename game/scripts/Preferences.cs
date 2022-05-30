using Godot;
using System;
using System.Threading.Tasks;

public class AccountInfo
{
    public string Email { get; set; }
    public string Password { get; set; }
}

public partial class Preferences : Node2D
{
    private ConfigFile dataConfig = new ConfigFile();
    private ConfigFile accountConfig = new ConfigFile();
    private string dataConfigName = "user://config.ini";
    private string accountConfigName = "user://account.ini";
    private string accountConfigPassword = "3984340khYGUYG679JHB!fdf";

    // Called when the node enters the scene tree for the first time.
    public Preferences()
    {
        // Load the config file
        string configPath = OS.GetUserDataDir() + "/" + this.dataConfigName;
        GD.Print("Loading config from \"", configPath + "\"");
        string accountConfigPath = OS.GetUserDataDir() + "/" + this.accountConfigName;
        GD.Print("Loading config from \"", accountConfigPath + "\"");

        Error configData = dataConfig.Load(dataConfigName);
        if (configData != Error.Ok)
        {
            GD.Print("Error loading config: ", this.dataConfigName);
        }
        else
        {
            GD.Print("Data Config loaded");
        }

        Error accountConfigData = accountConfig.LoadEncryptedPass(this.accountConfigName, this.accountConfigPassword);
        if (configData != Error.Ok)
        {
            GD.Print("Error loading config: ", this.accountConfigName);
        }
        else
        {
            GD.Print("Account Config loaded");
        }
    }

    public void SaveAccount(string email , string password)
    {
        GD.Print("Saving account details");
        this.accountConfig.SetValue("account", "email", value: email);
        this.accountConfig.SetValue("account", "password", password);

        this.accountConfig.SaveEncryptedPass(this.accountConfigName, this.accountConfigPassword);
    }

    public AccountInfo LoadAccount()
    {
        GD.Print("Loading account details");
        string email = this.accountConfig.GetValue("account", "email") as string;
        string password = this.accountConfig.GetValue("account", "password") as string;

        return new AccountInfo()
        {
            Email = email,
            Password = password
        };
    }
}
