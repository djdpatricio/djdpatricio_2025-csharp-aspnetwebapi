namespace DJDPatricio.IMS.API.Models.Result.Static;

public class AddressCountryDivision
{
    public long Id { get; set; }
    public long AddressCountryId { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Acronym { get; set; } = string.Empty;
    public string Code { get; set; } = string.Empty;
}