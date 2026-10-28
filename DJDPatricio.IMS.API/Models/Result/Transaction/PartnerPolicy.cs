namespace DJDPatricio.IMS.API.Models.Result.Transaction;

public class PartnerPolicy : ResultBaseEntity
{
    public string ReferenceNumber { get; set; } = string.Empty;
    public string CocNumber { get; set; } = string.Empty;
    public long PartnersId { get; set; }
    public long PlatformsId { get; set; }
    public bool IssueStatus { get; set; }
    public long PolicyBookingStatusId { get; set; }
    public long CocStatusId { get; set; }
    public long PaymentStatusId { get; set; }
    public long ClaimsStatusId { get; set; }
    public long AgentsId { get; set; }
    public long? SubAgentsId { get; set; }
    public long ApproversId { get; set; }
    public long? PromoManagersId { get; set; }
    public long? SalesManagersId { get; set; }
    public long? PromoOfficersId { get; set; }
    public long ProductsId { get; set; }
    public long ProvidersId { get; set; }
    public long DistributionChannelId { get; set; }
    public long PaymentOptionId { get; set; }
    public string ProviderPolicyNo { get; set; } = string.Empty;
    public string? EndorsementNo { get; set; }
    public DateTime TerminationDate { get; set; }
    public DateTime EffectiveDate { get; set; }
    public DateTime IssueDate { get; set; }
    public string? Remarks { get; set; }
    public decimal TotalPremium { get; set; }
    public decimal TotalCoverage { get; set; }
    public decimal TotalPaid { get; set; }

    //Premiums
    public decimal BasicPremium { get; set; }
    public decimal BasicPremiumCommission { get; set; }
    public decimal DJDPatricioMarkup { get; set; }
    public decimal PartnerMarkup { get; set; }
    public decimal Discount { get; set; }
    public decimal Taxes { get; set; }
    public decimal DST { get; set; }
    public decimal VAT { get; set; }
    public decimal LGT { get; set; }
    public decimal PT { get; set; }
    public decimal FST { get; set; }
    public decimal NotarialFee { get; set; }
    public decimal Others { get; set; }
    public string? PremiumsRemarks { get; set; }
}