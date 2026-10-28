using DJDPatricio.IMS.API.Models;
using DJDPatricio.IMS.API.Models.Result.Reference;
using DJDPatricio.IMS.API.Repository.Constants;
using DJDPatricio.IMS.API.Repository.Interface;
using DJDPatricio.IMS.API.Repository.Interface.V1;

namespace DJDPatricio.IMS.API.Repository.Repository.V1;

public class ReferenceV1Repository(IDbFactoryWrapperRepository databaseContext) : IReferenceV1Repository
{
    public async Task<TransactionResult<IEnumerable<Agents>>> GetAgents(long? id, bool? isActiveOnly, string? DJDPatricioOrAgentId)
    {
        return await databaseContext.ExecuteMultipleResultStoredProcedureAsync<Agents>
            (V1ProcedureReference.Reference.Get.GetAgents, new { id, isActiveOnly, DJDPatricioOrAgentId });
    }
    public async Task<TransactionResult<IEnumerable<Approvers>>> GetApprovers(long? id, bool? isActiveOnly, string? DJDPatricioOrAgentId)
    {
        return await databaseContext.ExecuteMultipleResultStoredProcedureAsync<Approvers>
            (V1ProcedureReference.Reference.Get.GetApprovers, new { id, isActiveOnly, DJDPatricioOrAgentId });
    }
    public async Task<TransactionResult<IEnumerable<Benefits>>> GetBenefits(long? id, bool? isActiveOnly)
    {
        return await databaseContext.ExecuteMultipleResultStoredProcedureAsync<Benefits>
            (V1ProcedureReference.Reference.Get.GetBenefits, new { id, isActiveOnly });
    }
    public async Task<TransactionResult<IEnumerable<Clients>>> GetClients(long? id, bool? isActiveOnly, string? insuranceCustomerNo)
    {
        return await databaseContext.ExecuteMultipleResultStoredProcedureAsync<Clients>
            (V1ProcedureReference.Reference.Get.GetClients, new { id, isActiveOnly, insuranceCustomerNo });
    }
    public async Task<TransactionResult<IEnumerable<Deductibles>>> GetDeductibles(long? id, bool? isActiveOnly)
    {
        return await databaseContext.ExecuteMultipleResultStoredProcedureAsync<Deductibles>
            (V1ProcedureReference.Reference.Get.GetDeductibles, new { id, isActiveOnly });
    }
    public async Task<TransactionResult<IEnumerable<DistributionChannel>>> GetDistributionChannel(long? id, bool? isActiveOnly)
    {
        return await databaseContext.ExecuteMultipleResultStoredProcedureAsync<DistributionChannel>
            (V1ProcedureReference.Reference.Get.GetDistributionChannel, new { id, isActiveOnly });
    }
    public async Task<TransactionResult<IEnumerable<Partners>>> GetPartners(long? id, bool? isActiveOnly)
    {
        return await databaseContext.ExecuteMultipleResultStoredProcedureAsync<Partners>
            (V1ProcedureReference.Reference.Get.GetPartners, new { id, isActiveOnly });
    }
    public async Task<TransactionResult<IEnumerable<ProductBenefits>>> GetProductBenefits(long? id, bool? isActiveOnly, long? productsId)
    {
        return await databaseContext.ExecuteMultipleResultStoredProcedureAsync<ProductBenefits>
            (V1ProcedureReference.Reference.Get.GetProductBenefits, new { id, isActiveOnly, productsId });
    }
    public async Task<TransactionResult<IEnumerable<ProductCategory>>> GetProductCategory(long? id, bool? isActiveOnly)
    {
        return await databaseContext.ExecuteMultipleResultStoredProcedureAsync<ProductCategory>
            (V1ProcedureReference.Reference.Get.GetProductCategory, new { id, isActiveOnly });
    }
    public async Task<TransactionResult<IEnumerable<ProductDeductibles>>> GetProductDeductibles(long? id, bool? isActiveOnly, long? productsId)
    {
        return await databaseContext.ExecuteMultipleResultStoredProcedureAsync<ProductDeductibles>
            (V1ProcedureReference.Reference.Get.GetProductDeductibles, new { id, isActiveOnly, productsId });
    }
    public async Task<TransactionResult<IEnumerable<ProductPremium>>> GetProductPremium(long? id, bool? isActiveOnly, long? productsId)
    {
        return await databaseContext.ExecuteMultipleResultStoredProcedureAsync<ProductPremium>
            (V1ProcedureReference.Reference.Get.GetProductPremium, new { id, isActiveOnly, productsId });
    }
    public async Task<TransactionResult<IEnumerable<Products>>> GetProducts(long? id, bool? isActiveOnly, long? productCategoryId)
    {
        return await databaseContext.ExecuteMultipleResultStoredProcedureAsync<Products>
            (V1ProcedureReference.Reference.Get.GetProducts, new { id, isActiveOnly, productCategoryId });
    }
    public async Task<TransactionResult<IEnumerable<PromoManagers>>> GetPromoManagers(long? id, bool? isActiveOnly, string? DJDPatricioOrAgentId, long? agentsId)
    {
        return await databaseContext.ExecuteMultipleResultStoredProcedureAsync<PromoManagers>
            (V1ProcedureReference.Reference.Get.GetPromoManagers, new { id, isActiveOnly, DJDPatricioOrAgentId, agentsId });
    }
    public async Task<TransactionResult<IEnumerable<PromoOfficers>>> GetPromoOfficers(long? id, bool? isActiveOnly, string? DJDPatricioOrAgentId, long? agentsId)
    {
        return await databaseContext.ExecuteMultipleResultStoredProcedureAsync<PromoOfficers>
            (V1ProcedureReference.Reference.Get.GetPromoOfficers, new { id, isActiveOnly, DJDPatricioOrAgentId, agentsId });
    }
    public async Task<TransactionResult<IEnumerable<Providers>>> GetProviders(long? id, bool? isActiveOnly)
    {
        return await databaseContext.ExecuteMultipleResultStoredProcedureAsync<Providers>
            (V1ProcedureReference.Reference.Get.GetProviders, new { id, isActiveOnly });
    }
    public async Task<TransactionResult<IEnumerable<SalesManagers>>> GetSalesManagers(long? id, bool? isActiveOnly, string? DJDPatricioOrAgentId, long? agentsId)
    {
        return await databaseContext.ExecuteMultipleResultStoredProcedureAsync<SalesManagers>
            (V1ProcedureReference.Reference.Get.GetSalesManagers, new { id, isActiveOnly, DJDPatricioOrAgentId, agentsId });
    }
    public async Task<TransactionResult<IEnumerable<SelectionList>>> GetSelectionList(long? id, bool? isActiveOnly, long? selectionTypeId)
    {
        return await databaseContext.ExecuteMultipleResultStoredProcedureAsync<SelectionList>
            (V1ProcedureReference.Reference.Get.GetSelectionList, new { id, isActiveOnly, selectionTypeId });
    }
    public async Task<TransactionResult<IEnumerable<SubAgents>>> GetSubAgents(long? id, bool? isActiveOnly, string? DJDPatricioOrAgentId)
    {
        return await databaseContext.ExecuteMultipleResultStoredProcedureAsync<SubAgents>
            (V1ProcedureReference.Reference.Get.GetSubAgents, new { id, isActiveOnly, DJDPatricioOrAgentId });
    }
}