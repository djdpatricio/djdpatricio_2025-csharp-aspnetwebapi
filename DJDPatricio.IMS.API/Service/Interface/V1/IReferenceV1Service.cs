using DJDPatricio.IMS.API.Models;
using DJDPatricio.IMS.API.Models.Result.Reference;

namespace DJDPatricio.IMS.API.Service.Interface.V1;

public interface IReferenceV1Service
{
    Task<TransactionResult<IEnumerable<Agents>>> GetAgents(long? id, bool? isActiveOnly, string? DJDPatricioOrAgentId, long? mandatoryId, CancellationToken cancellationToken);
    Task<TransactionResult<IEnumerable<Approvers>>> GetApprovers(long? id, bool? isActiveOnly, string? DJDPatricioOrAgentId, long? mandatoryId, CancellationToken cancellationToken);
    Task<TransactionResult<IEnumerable<Benefits>>> GetBenefits(long? id, bool? isActiveOnly, long? mandatoryId, CancellationToken cancellationToken);
    Task<TransactionResult<IEnumerable<Clients>>> GetClients(long? id, bool? isActiveOnly, string? insuranceCustomerNo, long? mandatoryId, CancellationToken cancellationToken);
    Task<TransactionResult<IEnumerable<Deductibles>>> GetDeductibles(long? id, bool? isActiveOnly, long? mandatoryId, CancellationToken cancellationToken);
    Task<TransactionResult<IEnumerable<DistributionChannel>>> GetDistributionChannel(long? id, bool? isActiveOnly, long? mandatoryId, CancellationToken cancellationToken);
    Task<TransactionResult<IEnumerable<Partners>>> GetPartners(long? id, bool? isActiveOnly, long? mandatoryId, CancellationToken cancellationToken);
    Task<TransactionResult<IEnumerable<ProductBenefits>>> GetProductBenefits(long? id, bool? isActiveOnly, long? productsId, long? mandatoryId, CancellationToken cancellationToken);
    Task<TransactionResult<IEnumerable<ProductCategory>>> GetProductCategory(long? id, bool? isActiveOnly, long? mandatoryId, CancellationToken cancellationToken);
    Task<TransactionResult<IEnumerable<ProductDeductibles>>> GetProductDeductibles(long? id, bool? isActiveOnly, long? productsId, long? mandatoryId, CancellationToken cancellationToken);
    Task<TransactionResult<IEnumerable<ProductPremium>>> GetProductPremium(long? id, bool? isActiveOnly, long? productsId, long? mandatoryId, CancellationToken cancellationToken);
    Task<TransactionResult<IEnumerable<Products>>> GetProducts(long? id, bool? isActiveOnly, long? productCategoryId, long? mandatoryId, CancellationToken cancellationToken);
    Task<TransactionResult<IEnumerable<PromoManagers>>> GetPromoManagers(long? id, bool? isActiveOnly, string? DJDPatricioOrAgentId, long? agentsId, long? mandatoryId, CancellationToken cancellationToken);
    Task<TransactionResult<IEnumerable<PromoOfficers>>> GetPromoOfficers(long? id, bool? isActiveOnly, string? DJDPatricioOrAgentId, long? agentsId, long? mandatoryId, CancellationToken cancellationToken);
    Task<TransactionResult<IEnumerable<Providers>>> GetProviders(long? id, bool? isActiveOnly, long? mandatoryId, CancellationToken cancellationToken);
    Task<TransactionResult<IEnumerable<SalesManagers>>> GetSalesManagers(long? id, bool? isActiveOnly, string? DJDPatricioOrAgentId, long? agentsId, long? mandatoryId, CancellationToken cancellationToken);
    Task<TransactionResult<IEnumerable<SelectionList>>> GetSelectionList(long? id, bool? isActiveOnly, long? selectionTypeId, long? mandatoryId, CancellationToken cancellationToken);
    Task<TransactionResult<IEnumerable<SubAgents>>> GetSubAgents(long? id, bool? isActiveOnly, string? DJDPatricioOrAgentId, long? mandatoryId, CancellationToken cancellationToken);
}