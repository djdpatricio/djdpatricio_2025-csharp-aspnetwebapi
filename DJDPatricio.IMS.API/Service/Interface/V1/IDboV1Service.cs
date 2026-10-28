using DJDPatricio.IMS.API.Helpers;
using DJDPatricio.IMS.API.Models;
using DJDPatricio.IMS.API.Models.Result.Dbo;

namespace DJDPatricio.IMS.API.Service.Interface.V1;

public interface IDboV1Service
{
    Task<TransactionResult<IEnumerable<ProductSummary>>> GetProductSummary(CancellationToken cancellationToken);
    Task<TransactionResult<IEnumerable<TotalBookingPerStatus>>> GetTotalBookingPerStatus(StaticDataHelper.TimePeriodOption? timePeriodOption, CancellationToken cancellationToken);
    Task<TransactionResult<IEnumerable<SummaryYearToYear>>> GetSummaryYearToYear(CancellationToken cancellationToken);
}