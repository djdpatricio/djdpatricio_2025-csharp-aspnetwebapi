using DJDPatricio.IMS.API.Models.Config;

namespace DJDPatricio.IMS.API.Helpers.Config;

public class ConnectionStringsConfig
{
    public static ConnectionStrings Config { get; set; } = new();

    public static void Initialize(IConfiguration configuration)
    {
        Config = configuration.GetSection("ConnectionStrings").Get<ConnectionStrings>() ?? Config;
    }
}
