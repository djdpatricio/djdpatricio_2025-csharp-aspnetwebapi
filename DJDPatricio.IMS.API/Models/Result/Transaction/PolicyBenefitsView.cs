namespace DJDPatricio.IMS.API.Models.Result.Transaction;

public class PolicyBenefitsView : PolicyBenefits
{
    public string ReferenceNumber { get; set; } = string.Empty;
    public string CocNumber { get; set; } = string.Empty;
    public string PolicyType { get; set; } = string.Empty;
    public string Benefits { get; set; } = string.Empty;
}