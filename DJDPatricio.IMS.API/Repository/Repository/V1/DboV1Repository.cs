using DJDPatricio.IMS.API.Helpers;
using DJDPatricio.IMS.API.Models;
using DJDPatricio.IMS.API.Models.Result.Dbo;
using DJDPatricio.IMS.API.Repository.Constants;
using DJDPatricio.IMS.API.Repository.Interface;
using DJDPatricio.IMS.API.Repository.Interface.V1;

namespace DJDPatricio.IMS.API.Repository.Repository.V1;

public class DboV1Repository(IDbFactoryWrapperRepository databaseContext) : IDboV1Repository
{
    public async Task<TransactionResult<IEnumerable<ProductSummary>>> GetProductSummary()
    {
        return await databaseContext.ExecuteMultipleResultStoredProcedureAsync<ProductSummary>
            (V1ProcedureReference.Dbo.Get.GetProductSummary, null);
    }
    public async Task<TransactionResult<IEnumerable<TotalBookingPerStatus>>> GetTotalBookingPerStatus(StaticDataHelper.TimePeriodOption? timePeriodOption)
    {
        return await databaseContext.ExecuteMultipleResultStoredProcedureAsync<TotalBookingPerStatus>
            (V1ProcedureReference.Dbo.Get.GetTotalBookingPerStatus, new { timePeriodOption });
    }
    public async Task<TransactionResult<IEnumerable<SummaryYearToYear>>> GetSummaryYearToYear()
    {
        return await databaseContext.ExecuteMultipleResultStoredProcedureAsync<SummaryYearToYear>
            (V1ProcedureReference.Dbo.Get.GetSummaryYearToYear, null);
    }
}