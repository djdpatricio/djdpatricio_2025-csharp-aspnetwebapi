namespace DJDPatricio.IMS.API.Models.Result.Transaction;

public class PolicyDeductibles : ResultBaseEntity
{
    public long PolicyId { get; set; }
    public long PolicyTypeId { get; set; }
    public long DeductiblesId { get; set; }
    public decimal Amount { get; set; }
}