namespace DJDPatricio.IMS.API.Models.Result.Static;

public class AddressTown
{
    public long Id { get; set; }
    public long AddressCityId { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Code { get; set; } = string.Empty;
}