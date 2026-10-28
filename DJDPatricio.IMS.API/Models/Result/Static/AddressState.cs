namespace DJDPatricio.IMS.API.Models.Result.Static;

public class AddressState
{
    public long Id { get; set; }
    public long AddressCountryDivisionId { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Code { get; set; } = string.Empty;
}