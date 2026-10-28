namespace DJDPatricio.IMS.API.Models.Request.Put;

public class PutPolicyBeneficiary
{
    public long Id { get; set; }
    public string FirstName { get; set; } = string.Empty;
    public string? MiddleName { get; set; }
    public string LastName { get; set; } = string.Empty;
    public string? Suffix { get; set; }
    public string EmailAddress { get; set; } = string.Empty;
    public string ContactNumber { get; set; } = string.Empty;
    public DateTime DateOfBirth { get; set; }
    public long Relationship { get; set; }
}