namespace DJDPatricio.IMS.API.Models.Result.Reference;

public class ProductBenefits : ResultBaseEntity
{
    public long ProductsId { get; set; }
    public long BenefitsId { get; set; }
    public decimal CoverageAmount { get; set; }
    public decimal PremiumAmount { get; set; }
    public decimal PremiumCommissionAmount { get; set; }
    public bool IsActive { get; set; }
}