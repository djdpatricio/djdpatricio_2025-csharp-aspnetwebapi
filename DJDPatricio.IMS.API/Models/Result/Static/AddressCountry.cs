namespace DJDPatricio.IMS.API.Models.Result.Static;

public class AddressCountry
{
    public long Id { get; set; }
    public long AddressRegionDivisionId { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Code { get; set; } = string.Empty;
    public string PhoneCode { get; set; } = string.Empty;
    public string TopLevelDomain { get; set; } = string.Empty;
    public string Currency { get; set; } = string.Empty;
    public string CurrencyName { get; set; } = string.Empty;
    public string Nationality { get; set; } = string.Empty;
}