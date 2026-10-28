namespace DJDPatricio.IMS.API.Models.Result.Dbo;

public class ProductSummary
{
    public string Category { get; set; } = string.Empty;
    public string ProductName { get; set; } = string.Empty;
    public string ProductCode { get; set; } = string.Empty;
    public int TotalBookings { get; set; }
    public decimal TotalPremiums { get; set; }
    public decimal TotalPayments { get; set; }
    public DateTime? LastTransaction { get; set; }
    public string Trend { get; set; } = "MIDDLE";
}