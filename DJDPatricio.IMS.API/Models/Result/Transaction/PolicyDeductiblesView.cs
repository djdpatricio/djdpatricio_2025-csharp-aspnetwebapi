namespace DJDPatricio.IMS.API.Models.Result.Transaction;

public class PolicyDeductiblesView : PolicyDeductibles
{
    public string ReferenceNumber { get; set; } = string.Empty;
    public string CocNumber { get; set; } = string.Empty;
    public string PolicyType { get; set; } = string.Empty;
    public string Deductibles { get; set; } = string.Empty;
}