namespace DJDPatricio.IMS.API.Models.Config;

public class CorsOrigin
{
    public string[] Endpoints { get; set; } = [];
    public bool UseCors { get; set; }
}