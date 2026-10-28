namespace DJDPatricio.IMS.API.Models.Result.Transaction;

public class PolicyPaymentsView : PolicyPayments
{
    public string ReferenceNumber { get; set; } = string.Empty;
    public string CocNumber { get; set; } = string.Empty;
    public string PolicyType { get; set; } = string.Empty;
    public string PaymentMethodTitle { get; set; } = string.Empty;
}