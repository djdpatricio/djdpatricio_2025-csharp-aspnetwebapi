namespace DJDPatricio.IMS.API.Models.Result.Transaction;

public class PolicyBeneficiaryView : PolicyBeneficiary
{
    public string ReferenceNumber { get; set; } = string.Empty;
    public string CocNumber { get; set; } = string.Empty;
    public string PolicyType { get; set; } = string.Empty;
    public string RelationshipTitle { get; set; } = string.Empty;
}