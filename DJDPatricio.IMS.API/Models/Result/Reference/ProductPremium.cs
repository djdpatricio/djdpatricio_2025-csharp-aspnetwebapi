namespace DJDPatricio.IMS.API.Models.Result.Reference;

public class ProductPremium : ResultBaseEntity
{
    public long ProductsId { get; set; }
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
    public bool IsActive { get; set; }
}