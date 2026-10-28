using DJDPatricio.IMS.API.Models;
using DJDPatricio.IMS.API.Models.Result.Reference;

namespace DJDPatricio.IMS.API.Repository.Interface.V1;

public interface IReferenceV1Repository
{
    Task<TransactionResult<IEnumerable<Agents>>> GetAgents(long? id, bool? isActiveOnly, string? DJDPatricioOrAgentId);
    Task<TransactionResult<IEnumerable<Approvers>>> GetApprovers(long? id, bool? isActiveOnly, string? DJDPatricioOrAgentId);
    Task<TransactionResult<IEnumerable<Benefits>>> GetBenefits(long? id, bool? isActiveOnly);
    Task<TransactionResult<IEnumerable<Clients>>> GetClients(long? id, bool? isActiveOnly, string? insuranceCustomerNo);
    Task<TransactionResult<IEnumerable<Deductibles>>> GetDeductibles(long? id, bool? isActiveOnly);
    Task<TransactionResult<IEnumerable<DistributionChannel>>> GetDistributionChannel(long? id, bool? isActiveOnly);
    Task<TransactionResult<IEnumerable<Partners>>> GetPartners(long? id, bool? isActiveOnly);
    Task<TransactionResult<IEnumerable<ProductBenefits>>> GetProductBenefits(long? id, bool? isActiveOnly, long? productsId);
    Task<TransactionResult<IEnumerable<ProductCategory>>> GetProductCategory(long? id, bool? isActiveOnly);
    Task<TransactionResult<IEnumerable<ProductDeductibles>>> GetProductDeductibles(long? id, bool? isActiveOnly, long? productsId);
    Task<TransactionResult<IEnumerable<ProductPremium>>> GetProductPremium(long? id, bool? isActiveOnly, long? productsId);
    Task<TransactionResult<IEnumerable<Products>>> GetProducts(long? id, bool? isActiveOnly, long? productCategoryId);
    Task<TransactionResult<IEnumerable<PromoManagers>>> GetPromoManagers(long? id, bool? isActiveOnly, string? DJDPatricioOrAgentId, long? agentsId);
    Task<TransactionResult<IEnumerable<PromoOfficers>>> GetPromoOfficers(long? id, bool? isActiveOnly, string? DJDPatricioOrAgentId, long? agentsId);
    Task<TransactionResult<IEnumerable<Providers>>> GetProviders(long? id, bool? isActiveOnly);
    Task<TransactionResult<IEnumerable<SalesManagers>>> GetSalesManagers(long? id, bool? isActiveOnly, string? DJDPatricioOrAgentId, long? agentsId);
    Task<TransactionResult<IEnumerable<SelectionList>>> GetSelectionList(long? id, bool? isActiveOnly, long? selectionTypeId);
    Task<TransactionResult<IEnumerable<SubAgents>>> GetSubAgents(long? id, bool? isActiveOnly, string? DJDPatricioOrAgentId);
}