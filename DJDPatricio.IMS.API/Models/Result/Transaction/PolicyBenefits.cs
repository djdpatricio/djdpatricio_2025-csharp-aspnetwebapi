namespace DJDPatricio.IMS.API.Models.Result.Transaction;

public class PolicyBenefits : ResultBaseEntity
{
    public long PolicyId { get; set; }
    public long PolicyTypeId { get; set; }
    public long BenefitsId { get; set; }
    public decimal CoverageAmount { get; set; }
    public decimal PremiumAmount { get; set; }
    public decimal PremiumCommissionAmount { get; set; }
}