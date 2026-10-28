namespace DJDPatricio.IMS.API.Models.Config;

public class Authentication
{
    public string Issuer { get; set; } = string.Empty;
    public string Audience { get; set; } = string.Empty;
    public string JwtKey { get; set; } = string.Empty;
}