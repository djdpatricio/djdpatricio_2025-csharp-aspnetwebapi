using DJDPatricio.IMS.API.Helpers;
using DJDPatricio.IMS.API.Models;
using DJDPatricio.IMS.API.Models.Result.Dbo;

namespace DJDPatricio.IMS.API.Repository.Interface.V1;

public interface IDboV1Repository
{
    Task<TransactionResult<IEnumerable<ProductSummary>>> GetProductSummary();
    Task<TransactionResult<IEnumerable<TotalBookingPerStatus>>> GetTotalBookingPerStatus(StaticDataHelper.TimePeriodOption? timePeriodOption);
    Task<TransactionResult<IEnumerable<SummaryYearToYear>>> GetSummaryYearToYear();
}