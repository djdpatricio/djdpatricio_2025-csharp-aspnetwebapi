namespace DJDPatricio.IMS.API.Models.Result.Static;

public class AddressRegionDivision
{
    public long Id { get; set; }
    public long AddressRegionId { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Code { get; set; } = string.Empty;
}