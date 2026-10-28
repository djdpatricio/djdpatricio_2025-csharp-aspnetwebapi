namespace DJDPatricio.IMS.TESTS.MockData.Dbo;

public static class SummaryYearToYear
{
    public static IEnumerable<API.Models.Result.Dbo.SummaryYearToYear> SummaryYearToYearList() =>
    [
        new()
        {
            Id = 1,
            MetricName = "Revenue",
            ReportingYear = 2025,
            CurrentYearValue = 4516.19m,
            PreviousYearValue = 0m,
            PercentageIncrease = 451619.00m,
            Trend = "UP"
        },
        new()
        {
            Id = 2,
            MetricName = "Bookings",
            ReportingYear = 2025,
            CurrentYearValue = 7.00m,
            PreviousYearValue = 0.00m,
            PercentageIncrease = 700.00m,
            Trend = "UP"
        },
        new()
        {
            Id = 3,
            MetricName = "Customers",
            ReportingYear = 2025,
            CurrentYearValue = 24.00m,
            PreviousYearValue = 0.00m,
            PercentageIncrease = 2400.00m,
            Trend = "UP"
        },
        new()
        {
            Id = 4,
            MetricName = "Partners",
            ReportingYear = 2025,
            CurrentYearValue = 20.00m,
            PreviousYearValue = 0.00m,
            PercentageIncrease = 2000.00m,
            Trend = "UP"
        }
    ];
}