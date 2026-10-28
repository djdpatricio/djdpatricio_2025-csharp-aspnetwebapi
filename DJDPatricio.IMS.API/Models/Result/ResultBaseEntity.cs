namespace DJDPatricio.IMS.API.Models.Result;

public abstract class ResultBaseEntity
{
    public long Id { get; set; }
    public long? CreatedBy { get; set; }
    public DateTime CreatedDateTime { get; set; }
    public long? ModifiedBy { get; set; }
    public DateTime ModifiedDateTime { get; set; }
}