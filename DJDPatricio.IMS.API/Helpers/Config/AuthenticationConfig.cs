using DJDPatricio.IMS.API.Models.Config;

namespace DJDPatricio.IMS.API.Helpers.Config;

public class AuthenticationConfig
{
    public static Authentication Config { get; set; } = new();

    public static void Initialize(IConfiguration configuration)
    {
        Config = configuration.GetSection("Authentication").Get<Authentication>() ?? Config;
    }
}
