namespace DJDPatricio.IMS.API.Models.Result.Reference;

public class SelectionList : ResultBaseEntity
{
    public long SelectionTypeId { get; set; }
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }
    public bool IsActive { get; set; }
}