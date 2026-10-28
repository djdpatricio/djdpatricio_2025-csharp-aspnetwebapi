namespace DJDPatricio.IMS.API.Models.Request.Put;

public class PutPolicyPayments
{
    public long Id { get; set; }
    public decimal Amount { get; set; }
    public DateTime TransactionDateTime { get; set; }
    public string TransactionCheckNo { get; set; } = string.Empty;
    public string TransactionOrigin { get; set; } = string.Empty;
    public DateTime NotificationDateTime { get; set; }
    public long PaymentMethod { get; set; }
    public string? Notes { get; set; }
}