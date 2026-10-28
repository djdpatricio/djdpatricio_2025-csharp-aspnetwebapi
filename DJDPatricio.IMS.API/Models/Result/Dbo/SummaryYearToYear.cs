namespace DJDPatricio.IMS.API.Models.Result.Dbo;

public class SummaryYearToYear
{
    public int Id { get; set; }
    public string MetricName { get; set; } = string.Empty;
    public int ReportingYear { get; set; }
    public decimal CurrentYearValue { get; set; }
    public decimal PreviousYearValue { get; set; }
    public decimal PercentageIncrease { get; set; }
    public string Trend { get; set; } = "MIDDLE";
    
}