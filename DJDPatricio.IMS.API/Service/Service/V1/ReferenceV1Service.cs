using DJDPatricio.IMS.API.Helpers.Config;
using DJDPatricio.IMS.API.Models;
using DJDPatricio.IMS.API.Models.Result.Reference;
using DJDPatricio.IMS.API.Repository.Interface.V1;
using DJDPatricio.IMS.API.Service.Interface.V1;

namespace DJDPatricio.IMS.API.Service.Service.V1;

public class ReferenceV1Service(IReferenceV1Repository referenceV1Repository) : IReferenceV1Service
{
    public async Task<TransactionResult<IEnumerable<Agents>>> GetAgents(long? id, bool? isActiveOnly, string? DJDPatricioOrAgentId, long? mandatoryId, CancellationToken cancellationToken)
    {
        using var cts = CancellationTokenSource.CreateLinkedTokenSource(cancellationToken);
        cts.CancelAfter(TimeSpan.FromSeconds(SystemDefaultsConfig.Config.ApiTimeoutInSeconds));

        var result = await referenceV1Repository.GetAgents(id, isActiveOnly, DJDPatricioOrAgentId);
        if (!result.IsSuccess) return result;
        if (mandatoryId == null) return result;
        var mandatoryOption = await referenceV1Repository.GetAgents(mandatoryId, null, null);
        if (!mandatoryOption.IsSuccess) return mandatoryOption;
        if (mandatoryOption.Data?.Count() == 0) return result;
        var newList = result.Data!.ToList();
        newList.Add(mandatoryOption.Data!.ToList().First());
        return TransactionResult<IEnumerable<Agents>>.Success(newList);
    }

    public async Task<TransactionResult<IEnumerable<Approvers>>> GetApprovers(long? id, bool? isActiveOnly, string? DJDPatricioOrAgentId, long? mandatoryId, CancellationToken cancellationToken)
    {
        using var cts = CancellationTokenSource.CreateLinkedTokenSource(cancellationToken);
        cts.CancelAfter(TimeSpan.FromSeconds(SystemDefaultsConfig.Config.ApiTimeoutInSeconds));

        var result = await referenceV1Repository.GetApprovers(id, isActiveOnly, DJDPatricioOrAgentId);
        if (!result.IsSuccess) return result;
        if (mandatoryId == null) return result;
        var mandatoryOption = await referenceV1Repository.GetApprovers(mandatoryId, null, null);
        if (!mandatoryOption.IsSuccess) return mandatoryOption;
        if (mandatoryOption.Data?.Count() == 0) return result;
        var newList = result.Data!.ToList();
        newList.Add(mandatoryOption.Data!.ToList().First());
        return TransactionResult<IEnumerable<Approvers>>.Success(newList);
    }
    public async Task<TransactionResult<IEnumerable<Benefits>>> GetBenefits(long? id, bool? isActiveOnly, long? mandatoryId, CancellationToken cancellationToken)
    {
        using var cts = CancellationTokenSource.CreateLinkedTokenSource(cancellationToken);
        cts.CancelAfter(TimeSpan.FromSeconds(SystemDefaultsConfig.Config.ApiTimeoutInSeconds));

        var result = await referenceV1Repository.GetBenefits(id, isActiveOnly);
        if (!result.IsSuccess) return result;
        if (mandatoryId == null) return result;
        var mandatoryOption = await referenceV1Repository.GetBenefits(mandatoryId, null);
        if (!mandatoryOption.IsSuccess) return mandatoryOption;
        if (mandatoryOption.Data?.Count() == 0) return result;
        var newList = result.Data!.ToList();
        newList.Add(mandatoryOption.Data!.ToList().First());
        return TransactionResult<IEnumerable<Benefits>>.Success(newList);
    }
    public async Task<TransactionResult<IEnumerable<Clients>>> GetClients(long? id, bool? isActiveOnly, string? insuranceCustomerNo, long? mandatoryId, CancellationToken cancellationToken)
    {
        using var cts = CancellationTokenSource.CreateLinkedTokenSource(cancellationToken);
        cts.CancelAfter(TimeSpan.FromSeconds(SystemDefaultsConfig.Config.ApiTimeoutInSeconds));

        var result = await referenceV1Repository.GetClients(id, isActiveOnly, insuranceCustomerNo);
        if (!result.IsSuccess) return result;
        if (mandatoryId == null) return result;
        var mandatoryOption = await referenceV1Repository.GetClients(mandatoryId, null, null);
        if (!mandatoryOption.IsSuccess) return mandatoryOption;
        if (mandatoryOption.Data?.Count() == 0) return result;
        var newList = result.Data!.ToList();
        newList.Add(mandatoryOption.Data!.ToList().First());
        return TransactionResult<IEnumerable<Clients>>.Success(newList);
    }
    public async Task<TransactionResult<IEnumerable<Deductibles>>> GetDeductibles(long? id, bool? isActiveOnly, long? mandatoryId, CancellationToken cancellationToken)
    {
        using var cts = CancellationTokenSource.CreateLinkedTokenSource(cancellationToken);
        cts.CancelAfter(TimeSpan.FromSeconds(SystemDefaultsConfig.Config.ApiTimeoutInSeconds));

        var result = await referenceV1Repository.GetDeductibles(id, isActiveOnly);
        if (!result.IsSuccess) return result;
        if (mandatoryId == null) return result;
        var mandatoryOption = await referenceV1Repository.GetDeductibles(mandatoryId, null);
        if (!mandatoryOption.IsSuccess) return mandatoryOption;
        if (mandatoryOption.Data?.Count() == 0) return result;
        var newList = result.Data!.ToList();
        newList.Add(mandatoryOption.Data!.ToList().First());
        return TransactionResult<IEnumerable<Deductibles>>.Success(newList);
    }
    public async Task<TransactionResult<IEnumerable<DistributionChannel>>> GetDistributionChannel(long? id, bool? isActiveOnly, long? mandatoryId, CancellationToken cancellationToken)
    {
        using var cts = CancellationTokenSource.CreateLinkedTokenSource(cancellationToken);
        cts.CancelAfter(TimeSpan.FromSeconds(SystemDefaultsConfig.Config.ApiTimeoutInSeconds));

        var result = await referenceV1Repository.GetDistributionChannel(id, isActiveOnly);
        if (!result.IsSuccess) return result;
        if (mandatoryId == null) return result;
        var mandatoryOption = await referenceV1Repository.GetDistributionChannel(mandatoryId, null);
        if (!mandatoryOption.IsSuccess) return mandatoryOption;
        if (mandatoryOption.Data?.Count() == 0) return result;
        var newList = result.Data!.ToList();
        newList.Add(mandatoryOption.Data!.ToList().First());
        return TransactionResult<IEnumerable<DistributionChannel>>.Success(newList);
    }
    public async Task<TransactionResult<IEnumerable<Partners>>> GetPartners(long? id, bool? isActiveOnly, long? mandatoryId, CancellationToken cancellationToken)
    {
        using var cts = CancellationTokenSource.CreateLinkedTokenSource(cancellationToken);
        cts.CancelAfter(TimeSpan.FromSeconds(SystemDefaultsConfig.Config.ApiTimeoutInSeconds));

        var result = await referenceV1Repository.GetPartners(id, isActiveOnly);
        if (!result.IsSuccess) return result;
        if (mandatoryId == null) return result;
        var mandatoryOption = await referenceV1Repository.GetPartners(mandatoryId, null);
        if (!mandatoryOption.IsSuccess) return mandatoryOption;
        if (mandatoryOption.Data?.Count() == 0) return result;
        var newList = result.Data!.ToList();
        newList.Add(mandatoryOption.Data!.ToList().First());
        return TransactionResult<IEnumerable<Partners>>.Success(newList);
    }
    public async Task<TransactionResult<IEnumerable<ProductBenefits>>> GetProductBenefits(long? id, bool? isActiveOnly, long? productsId, long? mandatoryId, CancellationToken cancellationToken)
    {
        using var cts = CancellationTokenSource.CreateLinkedTokenSource(cancellationToken);
        cts.CancelAfter(TimeSpan.FromSeconds(SystemDefaultsConfig.Config.ApiTimeoutInSeconds));

        var result = await referenceV1Repository.GetProductBenefits(id, isActiveOnly, productsId);
        if (!result.IsSuccess) return result;
        if (mandatoryId == null) return result;
        var mandatoryOption = await referenceV1Repository.GetProductBenefits(mandatoryId, null, null);
        if (!mandatoryOption.IsSuccess) return mandatoryOption;
        if (mandatoryOption.Data?.Count() == 0) return result;
        var newList = result.Data!.ToList();
        newList.Add(mandatoryOption.Data!.ToList().First());
        return TransactionResult<IEnumerable<ProductBenefits>>.Success(newList);
    }
    public async Task<TransactionResult<IEnumerable<ProductCategory>>> GetProductCategory(long? id, bool? isActiveOnly, long? mandatoryId, CancellationToken cancellationToken)
    {
        using var cts = CancellationTokenSource.CreateLinkedTokenSource(cancellationToken);
        cts.CancelAfter(TimeSpan.FromSeconds(SystemDefaultsConfig.Config.ApiTimeoutInSeconds));

        var result = await referenceV1Repository.GetProductCategory(id, isActiveOnly);
        if (!result.IsSuccess) return result;
        if (mandatoryId == null) return result;
        var mandatoryOption = await referenceV1Repository.GetProductCategory(mandatoryId, null);
        if (!mandatoryOption.IsSuccess) return mandatoryOption;
        if (mandatoryOption.Data?.Count() == 0) return result;
        var newList = result.Data!.ToList();
        newList.Add(mandatoryOption.Data!.ToList().First());
        return TransactionResult<IEnumerable<ProductCategory>>.Success(newList);
    }
    public async Task<TransactionResult<IEnumerable<ProductDeductibles>>> GetProductDeductibles(long? id, bool? isActiveOnly, long? productsId, long? mandatoryId, CancellationToken cancellationToken)
    {
        using var cts = CancellationTokenSource.CreateLinkedTokenSource(cancellationToken);
        cts.CancelAfter(TimeSpan.FromSeconds(SystemDefaultsConfig.Config.ApiTimeoutInSeconds));

        var result = await referenceV1Repository.GetProductDeductibles(id, isActiveOnly, productsId);
        if (!result.IsSuccess) return result;
        if (mandatoryId == null) return result;
        var mandatoryOption = await referenceV1Repository.GetProductDeductibles(mandatoryId, null, null);
        if (!mandatoryOption.IsSuccess) return mandatoryOption;
        if (mandatoryOption.Data?.Count() == 0) return result;
        var newList = result.Data!.ToList();
        newList.Add(mandatoryOption.Data!.ToList().First());
        return TransactionResult<IEnumerable<ProductDeductibles>>.Success(newList);
    }
    public async Task<TransactionResult<IEnumerable<ProductPremium>>> GetProductPremium(long? id, bool? isActiveOnly, long? productsId, long? mandatoryId, CancellationToken cancellationToken)
    {
        using var cts = CancellationTokenSource.CreateLinkedTokenSource(cancellationToken);
        cts.CancelAfter(TimeSpan.FromSeconds(SystemDefaultsConfig.Config.ApiTimeoutInSeconds));

        var result = await referenceV1Repository.GetProductPremium(id, isActiveOnly, productsId);
        if (!result.IsSuccess) return result;
        if (mandatoryId == null) return result;
        var mandatoryOption = await referenceV1Repository.GetProductPremium(mandatoryId, null, null);
        if (!mandatoryOption.IsSuccess) return mandatoryOption;
        if (mandatoryOption.Data?.Count() == 0) return result;
        var newList = result.Data!.ToList();
        newList.Add(mandatoryOption.Data!.ToList().First());
        return TransactionResult<IEnumerable<ProductPremium>>.Success(newList);
    }
    public async Task<TransactionResult<IEnumerable<Products>>> GetProducts(long? id, bool? isActiveOnly, long? productCategoryId, long? mandatoryId, CancellationToken cancellationToken)
    {
        using var cts = CancellationTokenSource.CreateLinkedTokenSource(cancellationToken);
        cts.CancelAfter(TimeSpan.FromSeconds(SystemDefaultsConfig.Config.ApiTimeoutInSeconds));

        var result = await referenceV1Repository.GetProducts(id, isActiveOnly, productCategoryId);
        if (!result.IsSuccess) return result;
        if (mandatoryId == null) return result;
        var mandatoryOption = await referenceV1Repository.GetProducts(mandatoryId, null, null);
        if (!mandatoryOption.IsSuccess) return mandatoryOption;
        if (mandatoryOption.Data?.Count() == 0) return result;
        var newList = result.Data!.ToList();
        newList.Add(mandatoryOption.Data!.ToList().First());
        return TransactionResult<IEnumerable<Products>>.Success(newList);
    }
    public async Task<TransactionResult<IEnumerable<PromoManagers>>> GetPromoManagers(long? id, bool? isActiveOnly, string? DJDPatricioOrAgentId, long? agentsId, long? mandatoryId, CancellationToken cancellationToken)
    {
        using var cts = CancellationTokenSource.CreateLinkedTokenSource(cancellationToken);
        cts.CancelAfter(TimeSpan.FromSeconds(SystemDefaultsConfig.Config.ApiTimeoutInSeconds));

        var result = await referenceV1Repository.GetPromoManagers(id, isActiveOnly, DJDPatricioOrAgentId, agentsId);
        if (!result.IsSuccess) return result;
        if (mandatoryId == null) return result;
        var mandatoryOption = await referenceV1Repository.GetPromoManagers(mandatoryId, null, null, null);
        if (!mandatoryOption.IsSuccess) return mandatoryOption;
        if (mandatoryOption.Data?.Count() == 0) return result;
        var newList = result.Data!.ToList();
        newList.Add(mandatoryOption.Data!.ToList().First());
        return TransactionResult<IEnumerable<PromoManagers>>.Success(newList);
    }
    public async Task<TransactionResult<IEnumerable<PromoOfficers>>> GetPromoOfficers(long? id, bool? isActiveOnly, string? DJDPatricioOrAgentId, long? agentsId, long? mandatoryId, CancellationToken cancellationToken)
    {
        using var cts = CancellationTokenSource.CreateLinkedTokenSource(cancellationToken);
        cts.CancelAfter(TimeSpan.FromSeconds(SystemDefaultsConfig.Config.ApiTimeoutInSeconds));

        var result = await referenceV1Repository.GetPromoOfficers(id, isActiveOnly, DJDPatricioOrAgentId, agentsId);
        if (!result.IsSuccess) return result;
        if (mandatoryId == null) return result;
        var mandatoryOption = await referenceV1Repository.GetPromoOfficers(mandatoryId, null, null, null);
        if (!mandatoryOption.IsSuccess) return mandatoryOption;
        if (mandatoryOption.Data?.Count() == 0) return result;
        var newList = result.Data!.ToList();
        newList.Add(mandatoryOption.Data!.ToList().First());
        return TransactionResult<IEnumerable<PromoOfficers>>.Success(newList);
    }
    public async Task<TransactionResult<IEnumerable<Providers>>> GetProviders(long? id, bool? isActiveOnly, long? mandatoryId, CancellationToken cancellationToken)
    {
        using var cts = CancellationTokenSource.CreateLinkedTokenSource(cancellationToken);
        cts.CancelAfter(TimeSpan.FromSeconds(SystemDefaultsConfig.Config.ApiTimeoutInSeconds));

        var result = await referenceV1Repository.GetProviders(id, isActiveOnly);
        if (!result.IsSuccess) return result;
        if (mandatoryId == null) return result;
        var mandatoryOption = await referenceV1Repository.GetProviders(mandatoryId, null);
        if (!mandatoryOption.IsSuccess) return mandatoryOption;
        if (mandatoryOption.Data?.Count() == 0) return result;
        var newList = result.Data!.ToList();
        newList.Add(mandatoryOption.Data!.ToList().First());
        return TransactionResult<IEnumerable<Providers>>.Success(newList);
    }
    public async Task<TransactionResult<IEnumerable<SalesManagers>>> GetSalesManagers(long? id, bool? isActiveOnly, string? DJDPatricioOrAgentId, long? agentsId, long? mandatoryId, CancellationToken cancellationToken)
    {
        using var cts = CancellationTokenSource.CreateLinkedTokenSource(cancellationToken);
        cts.CancelAfter(TimeSpan.FromSeconds(SystemDefaultsConfig.Config.ApiTimeoutInSeconds));

        var result = await referenceV1Repository.GetSalesManagers(id, isActiveOnly, DJDPatricioOrAgentId, agentsId);
        if (!result.IsSuccess) return result;
        if (mandatoryId == null) return result;
        var mandatoryOption = await referenceV1Repository.GetSalesManagers(mandatoryId, null, null, null);
        if (!mandatoryOption.IsSuccess) return mandatoryOption;
        if (mandatoryOption.Data?.Count() == 0) return result;
        var newList = result.Data!.ToList();
        newList.Add(mandatoryOption.Data!.ToList().First());
        return TransactionResult<IEnumerable<SalesManagers>>.Success(newList);
    }
    public async Task<TransactionResult<IEnumerable<SelectionList>>> GetSelectionList(long? id, bool? isActiveOnly, long? selectionTypeId, long? mandatoryId, CancellationToken cancellationToken)
    {
        using var cts = CancellationTokenSource.CreateLinkedTokenSource(cancellationToken);
        cts.CancelAfter(TimeSpan.FromSeconds(SystemDefaultsConfig.Config.ApiTimeoutInSeconds));

        var result = await referenceV1Repository.GetSelectionList(id, isActiveOnly, selectionTypeId);
        if (!result.IsSuccess) return result;
        if (mandatoryId == null) return result;
        var mandatoryOption = await referenceV1Repository.GetSelectionList(mandatoryId, null, null);
        if (!mandatoryOption.IsSuccess) return mandatoryOption;
        if (mandatoryOption.Data?.Count() == 0) return result;
        var newList = result.Data!.ToList();
        newList.Add(mandatoryOption.Data!.ToList().First());
        return TransactionResult<IEnumerable<SelectionList>>.Success(newList);
    }
    public async Task<TransactionResult<IEnumerable<SubAgents>>> GetSubAgents(long? id, bool? isActiveOnly, string? DJDPatricioOrAgentId, long? mandatoryId, CancellationToken cancellationToken)
    {
        using var cts = CancellationTokenSource.CreateLinkedTokenSource(cancellationToken);
        cts.CancelAfter(TimeSpan.FromSeconds(SystemDefaultsConfig.Config.ApiTimeoutInSeconds));

        var result = await referenceV1Repository.GetSubAgents(id, isActiveOnly, DJDPatricioOrAgentId);
        if (!result.IsSuccess) return result;
        if (mandatoryId == null) return result;
        var mandatoryOption = await referenceV1Repository.GetSubAgents(mandatoryId, null, null);
        if (!mandatoryOption.IsSuccess) return mandatoryOption;
        if (mandatoryOption.Data?.Count() == 0) return result;
        var newList = result.Data!.ToList();
        newList.Add(mandatoryOption.Data!.ToList().First());
        return TransactionResult<IEnumerable<SubAgents>>.Success(newList);
    }
}