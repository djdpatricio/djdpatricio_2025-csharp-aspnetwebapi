namespace DJDPatricio.IMS.API.Models.Result;

public class PagedResponse<T>
{
    public required T Data { get; set; }
    public long TotalRecords { get; set; }
    public long PageNumber { get; set; }
    public long PageSize { get; set; }
    public required object Filters { get; set; }
}