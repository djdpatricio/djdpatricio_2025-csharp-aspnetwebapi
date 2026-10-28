namespace DJDPatricio.IMS.API.Models.Result.Reference;

public class Partners : ResultBaseEntity
{
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }
    public string Code { get; set; } = string.Empty;
    public string ContactPerson { get; set; } = string.Empty;
    public string EmailAddress { get; set; } = string.Empty;
    public string ContactNumber { get; set; } = string.Empty;
    public string Address1 { get; set; } = string.Empty;
    public string? Address2 { get; set; }
    public long AddressTownId { get; set; }
    public string Address { get; set; } = string.Empty;
    public bool IsActive { get; set; }
}