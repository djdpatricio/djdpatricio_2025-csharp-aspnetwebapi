using DJDPatricio.IMS.API.Models.Config;

namespace DJDPatricio.IMS.API.Helpers.Config;

public class SystemDefaultsConfig
{
    public static SystemDefaults Config { get; set; } = new();

    public static void Initialize(IConfiguration configuration)
    {
        Config = configuration.GetSection("SystemDefaults").Get<SystemDefaults>() ?? Config;
    }
}
