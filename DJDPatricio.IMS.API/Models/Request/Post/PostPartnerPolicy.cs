namespace DJDPatricio.IMS.API.Models.Request.Post;

public class PostPartnerPolicy
{
    public long PartnersId { get; set; }
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