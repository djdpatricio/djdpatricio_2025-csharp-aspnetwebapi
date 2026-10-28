using DJDPatricio.IMS.API.Helpers;
using DJDPatricio.IMS.API.Helpers.Config;
using DJDPatricio.IMS.API.Models;
using DJDPatricio.IMS.API.Models.Result.Dbo;
using DJDPatricio.IMS.API.Repository.Interface.V1;
using DJDPatricio.IMS.API.Service.Interface.V1;

namespace DJDPatricio.IMS.API.Service.Service.V1;

public class DboV1Service(IDboV1Repository dboV1Repository) : IDboV1Service
{
    public async Task<TransactionResult<IEnumerable<ProductSummary>>> GetProductSummary(CancellationToken cancellationToken)
    {
        using var cts = CancellationTokenSource.CreateLinkedTokenSource(cancellationToken);
        cts.CancelAfter(TimeSpan.FromSeconds(SystemDefaultsConfig.Config.ApiTimeoutInSeconds));
        return await dboV1Repository.GetProductSummary();
    }

    public async Task<TransactionResult<IEnumerable<TotalBookingPerStatus>>> GetTotalBookingPerStatus(StaticDataHelper.TimePeriodOption? timePeriodOption, CancellationToken cancellationToken)
    {
        using var cts = CancellationTokenSource.CreateLinkedTokenSource(cancellationToken);
        cts.CancelAfter(TimeSpan.FromSeconds(SystemDefaultsConfig.Config.ApiTimeoutInSeconds));
        return await dboV1Repository.GetTotalBookingPerStatus(timePeriodOption);
    }

    public async Task<TransactionResult<IEnumerable<SummaryYearToYear>>> GetSummaryYearToYear(CancellationToken cancellationToken)
    {
        using var cts = CancellationTokenSource.CreateLinkedTokenSource(cancellationToken);
        cts.CancelAfter(TimeSpan.FromSeconds(SystemDefaultsConfig.Config.ApiTimeoutInSeconds));
        return await dboV1Repository.GetSummaryYearToYear();
    }
}