namespace DJDPatricio.IMS.API.Models.Result.Dbo;

public class TotalBookingPerStatus
{
    public DateTime ActivityDate { get; set; }
    public int Approved { get; set; }
    public int Disapproved { get; set; }
    public int Pending { get; set; }
    public int Declined { get; set; }
    public int Quoted { get; set; }
    public int Draft { get; set; }
    public int AutoApproved { get; set; }
    public int TotalCount { get; set; }
}