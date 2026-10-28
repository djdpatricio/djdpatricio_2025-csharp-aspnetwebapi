namespace DJDPatricio.IMS.API.Models.Result.Transaction;

public class PolicyBeneficiary : ResultBaseEntity
{
    public long PolicyId { get; set; }
    public long PolicyTypeId { get; set; }
    public string FirstName { get; set; } = string.Empty;
    public string? MiddleName { get; set; }
    public string LastName { get; set; } = string.Empty;
    public string? Suffix { get; set; }
    public string FullName { get; set; } = string.Empty;
    public string EmailAddress { get; set; } = string.Empty;
    public string ContactNumber { get; set; } = string.Empty;
    public DateTime DateOfBirth { get; set; }
    public long Relationship { get; set; }
}