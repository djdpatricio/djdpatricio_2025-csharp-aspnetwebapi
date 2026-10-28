namespace DJDPatricio.IMS.API.Models.Result.Reference;

public class Products : ResultBaseEntity
{
    public long ProductCategoryId { get; set; }
    public string Name { get; set; } = null!;
    public string? Description { get; set; }
    public string Code { get; set; } = null!;
    public int? MinimumAge { get; set; }
    public int? MaximumAge { get; set; }
    public int? MaximumBookingPerYear { get; set; }
    public int? MaximumBookingPerDuration { get; set; }
    public bool IsActive { get; set; }
}