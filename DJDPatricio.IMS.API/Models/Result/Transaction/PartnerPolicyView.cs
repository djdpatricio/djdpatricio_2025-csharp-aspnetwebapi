namespace DJDPatricio.IMS.API.Models.Result.Transaction;

public class PartnerPolicyView : PartnerPolicy
{
    public string Partners { get; set; } = string.Empty;
    public string PartnersCode { get; set; } = string.Empty;
    public string Platforms { get; set; } = string.Empty;
    public string IssueStatusTitle { get; set; } = string.Empty;
    public string PolicyBookingStatus { get; set; } = string.Empty;
    public string CocStatus { get; set; } = string.Empty;
    public string PaymentStatus { get; set; } = string.Empty;
    public string ClaimsStatus { get; set; } = string.Empty;
    public string Agents { get; set; } = string.Empty;
    public string? SubAgents { get; set; }
    public string Approvers { get; set; } = string.Empty;
    public string? PromoManagers { get; set; }
    public string? SalesManagers { get; set; }
    public string? PromoOfficers { get; set; }
    public string ProductCategory { get; set; } = string.Empty;
    public long ProductCategoryId { get; set; }
    public string Products { get; set; } = string.Empty;
    public string Providers { get; set; } = string.Empty;
    public string DistributionChannel { get; set; } = string.Empty;
    public string PaymentOption { get; set; } = string.Empty;
}