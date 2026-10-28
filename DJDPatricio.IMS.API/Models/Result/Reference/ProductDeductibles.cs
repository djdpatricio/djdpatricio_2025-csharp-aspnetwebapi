namespace DJDPatricio.IMS.API.Models.Result.Reference;

public class ProductDeductibles : ResultBaseEntity
{
    public long ProductsId { get; set; }
    public long DeductiblesId { get; set; }
    public decimal Amount { get; set; }
    public bool IsActive { get; set; }
}