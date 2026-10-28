using DJDPatricio.IMS.API.Models;
using DJDPatricio.IMS.API.Models.Result.Reference;
using DJDPatricio.IMS.API.Models.Result.Transaction;
using DJDPatricio.IMS.API.Repository.Interface.V1;
using Moq;

namespace DJDPatricio.IMS.TESTS.Controllers;

public static class SetupHelper
{
    public static Mock<IReferenceV1Repository> GenerateReferenceRepositoryMock()
    {
        var result = new Mock<IReferenceV1Repository>();

        // Setup for GetAgents
        result.Setup(s => s.GetAgents(It.IsAny<long?>(), It.IsAny<bool?>(), It.IsAny<string?>()))
            .ReturnsAsync((long? id, bool? isActiveOnly, string? MCOrAgentId) =>
            {
                var filteredList = MockData.Reference.Agents.AgentsList()
                    .Where(x => (id == null || x.Id == id) &&
                                (isActiveOnly == null || x.IsActive == isActiveOnly) &&
                                (MCOrAgentId == null || x.MCOrAgentId == MCOrAgentId))
                    .ToList();
                return TransactionResult<IEnumerable<Agents>>.Success(filteredList);
            });

        // Setup for GetApprovers
        result.Setup(s => s.GetApprovers(It.IsAny<long?>(), It.IsAny<bool?>(), It.IsAny<string?>()))
            .ReturnsAsync((long? id, bool? isActiveOnly, string? MCOrAgentId) =>
            {
                var filteredList = MockData.Reference.Approvers.ApproversList()
                    .Where(x => (id == null || x.Id == id) &&
                                (isActiveOnly == null || x.IsActive == isActiveOnly) &&
                                (MCOrAgentId == null || x.MCOrAgentId == MCOrAgentId))
                    .ToList();
                return TransactionResult<IEnumerable<Approvers>>.Success(filteredList);
            });

        // Setup for GetBenefits
        result.Setup(s => s.GetBenefits(It.IsAny<long?>(), It.IsAny<bool?>()))
            .ReturnsAsync((long? id, bool? isActiveOnly) =>
            {
                var filteredList = MockData.Reference.Benefits.BenefitsList()
                    .Where(x => (id == null || x.Id == id) &&
                                (isActiveOnly == null || x.IsActive == isActiveOnly))
                    .ToList();
                return TransactionResult<IEnumerable<Benefits>>.Success(filteredList);
            });

        // Setup for GetClients
        result.Setup(s => s.GetClients(It.IsAny<long?>(), It.IsAny<bool?>(), It.IsAny<string?>()))
            .ReturnsAsync((long? id, bool? isActiveOnly, string? insuranceCustomerNo) =>
            {
                var filteredList = MockData.Reference.Clients.ClientsList()
                    .Where(x => (id == null || x.Id == id) &&
                                (isActiveOnly == null || x.IsActive == isActiveOnly) &&
                                (insuranceCustomerNo == null || x.InsuranceCustomerNo == insuranceCustomerNo))
                    .ToList();
                return TransactionResult<IEnumerable<Clients>>.Success(filteredList);
            });

        // Setup for GetDeductibles
        result.Setup(s => s.GetDeductibles(It.IsAny<long?>(), It.IsAny<bool?>()))
            .ReturnsAsync((long? id, bool? isActiveOnly) =>
            {
                var filteredList = MockData.Reference.Deductibles.DeductiblesList()
                    .Where(x => (id == null || x.Id == id) &&
                                (isActiveOnly == null || x.IsActive == isActiveOnly))
                    .ToList();
                return TransactionResult<IEnumerable<Deductibles>>.Success(filteredList);
            });

        // Setup for GetDistributionChannel
        result.Setup(s => s.GetDistributionChannel(It.IsAny<long?>(), It.IsAny<bool?>()))
            .ReturnsAsync((long? id, bool? isActiveOnly) =>
            {
                var filteredList = MockData.Reference.DistributionChannel.DistributionChannelList()
                    .Where(x => (id == null || x.Id == id) &&
                                (isActiveOnly == null || x.IsActive == isActiveOnly))
                    .ToList();
                return TransactionResult<IEnumerable<DistributionChannel>>.Success(filteredList);
            });

        // Setup for GetPartners
        result.Setup(s => s.GetPartners(It.IsAny<long?>(), It.IsAny<bool?>()))
            .ReturnsAsync((long? id, bool? isActiveOnly) =>
            {
                var filteredList = MockData.Reference.Partners.PartnersList()
                    .Where(x => (id == null || x.Id == id) &&
                                (isActiveOnly == null || x.IsActive == isActiveOnly))
                    .ToList();
                return TransactionResult<IEnumerable<Partners>>.Success(filteredList);
            });

        // Setup for GetProductBenefits
        result.Setup(s => s.GetProductBenefits(It.IsAny<long?>(), It.IsAny<bool?>(), It.IsAny<long?>()))
            .ReturnsAsync((long? id, bool? isActiveOnly, long? productsId) =>
            {
                var filteredList = MockData.Reference.ProductBenefits.ProductBenefitsList()
                    .Where(x => (id == null || x.Id == id) &&
                                (isActiveOnly == null || x.IsActive == isActiveOnly) &&
                                (productsId == null || x.ProductsId == productsId))
                    .ToList();
                return TransactionResult<IEnumerable<ProductBenefits>>.Success(filteredList);
            });

        // Setup for GetProductCategory
        result.Setup(s => s.GetProductCategory(It.IsAny<long?>(), It.IsAny<bool?>()))
            .ReturnsAsync((long? id, bool? isActiveOnly) =>
            {
                var filteredList = MockData.Reference.ProductCategory.ProductCategoryList()
                    .Where(x => (id == null || x.Id == id) &&
                                (isActiveOnly == null || x.IsActive == isActiveOnly))
                    .ToList();
                return TransactionResult<IEnumerable<ProductCategory>>.Success(filteredList);
            });

        // Setup for GetProductDeductibles
        result.Setup(s => s.GetProductDeductibles(It.IsAny<long?>(), It.IsAny<bool?>(), It.IsAny<long?>()))
            .ReturnsAsync((long? id, bool? isActiveOnly, long? productsId) =>
            {
                var filteredList = MockData.Reference.ProductDeductibles.ProductDeductiblesList()
                    .Where(x => (id == null || x.Id == id) &&
                                (isActiveOnly == null || x.IsActive == isActiveOnly) &&
                                (productsId == null || x.ProductsId == productsId))
                    .ToList();
                return TransactionResult<IEnumerable<ProductDeductibles>>.Success(filteredList);
            });

        // Setup for GetProductPremium
        result.Setup(s => s.GetProductPremium(It.IsAny<long?>(), It.IsAny<bool?>(), It.IsAny<long?>()))
            .ReturnsAsync((long? id, bool? isActiveOnly, long? productsId) =>
            {
                var filteredList = MockData.Reference.ProductPremium.ProductPremiumList()
                    .Where(x => (id == null || x.Id == id) &&
                                (isActiveOnly == null || x.IsActive == isActiveOnly) &&
                                (productsId == null || x.ProductsId == productsId))
                    .ToList();
                return TransactionResult<IEnumerable<ProductPremium>>.Success(filteredList);
            });

        // Setup for GetProducts
        result.Setup(s => s.GetProducts(It.IsAny<long?>(), It.IsAny<bool?>(), It.IsAny<long?>()))
            .ReturnsAsync((long? id, bool? isActiveOnly, long? productCategoryId) =>
            {
                var filteredList = MockData.Reference.Products.ProductsList()
                    .Where(x => (id == null || x.Id == id) &&
                                (isActiveOnly == null || x.IsActive == isActiveOnly) &&
                                (productCategoryId == null || x.ProductCategoryId == productCategoryId))
                    .ToList();
                return TransactionResult<IEnumerable<Products>>.Success(filteredList);
            });

        // Setup for GetPromoManagers
        result.Setup(s => s.GetPromoManagers(It.IsAny<long?>(), It.IsAny<bool?>(), It.IsAny<string?>(), It.IsAny<long?>()))
            .ReturnsAsync((long? id, bool? isActiveOnly, string? MCOrAgentId, long? agentsId) =>
            {
                var filteredList = MockData.Reference.PromoManagers.PromoManagersList()
                    .Where(x => (id == null || x.Id == id) &&
                                (isActiveOnly == null || x.IsActive == isActiveOnly) &&
                                (MCOrAgentId == null || x.MCOrAgentId == MCOrAgentId) &&
                                (agentsId == null || x.AgentsId == agentsId))
                    .ToList();
                return TransactionResult<IEnumerable<PromoManagers>>.Success(filteredList);
            });

        // Setup for GetPromoOfficers
        result.Setup(s => s.GetPromoOfficers(It.IsAny<long?>(), It.IsAny<bool?>(), It.IsAny<string?>(), It.IsAny<long?>()))
            .ReturnsAsync((long? id, bool? isActiveOnly, string? MCOrAgentId, long? agentsId) =>
            {
                var filteredList = MockData.Reference.PromoOfficers.PromoOfficersList()
                    .Where(x => (id == null || x.Id == id) &&
                                (isActiveOnly == null || x.IsActive == isActiveOnly) &&
                                (MCOrAgentId == null || x.MCOrAgentId == MCOrAgentId) &&
                                (agentsId == null || x.AgentsId == agentsId))
                    .ToList();
                return TransactionResult<IEnumerable<PromoOfficers>>.Success(filteredList);
            });

        // Setup for GetProviders
        result.Setup(s => s.GetProviders(It.IsAny<long?>(), It.IsAny<bool?>()))
            .ReturnsAsync((long? id, bool? isActiveOnly) =>
            {
                var filteredList = MockData.Reference.Providers.ProvidersList()
                    .Where(x => (id == null || x.Id == id) &&
                                (isActiveOnly == null || x.IsActive == isActiveOnly))
                    .ToList();
                return TransactionResult<IEnumerable<Providers>>.Success(filteredList);
            });

        // Setup for GetSalesManagers
        result.Setup(s => s.GetSalesManagers(It.IsAny<long?>(), It.IsAny<bool?>(), It.IsAny<string?>(), It.IsAny<long?>()))
            .ReturnsAsync((long? id, bool? isActiveOnly, string? MCOrAgentId, long? agentsId) =>
            {
                var filteredList = MockData.Reference.SalesManagers.SalesManagersList()
                    .Where(x => (id == null || x.Id == id) &&
                                (isActiveOnly == null || x.IsActive == isActiveOnly) &&
                                (MCOrAgentId == null || x.MCOrAgentId == MCOrAgentId) &&
                                (agentsId == null || x.AgentsId == agentsId))
                    .ToList();
                return TransactionResult<IEnumerable<SalesManagers>>.Success(filteredList);
            });

        // Setup for GetSelectionList
        result.Setup(s => s.GetSelectionList(It.IsAny<long?>(), It.IsAny<bool?>(), It.IsAny<long?>()))
            .ReturnsAsync((long? id, bool? isActiveOnly, long? selectionTypeId) =>
            {
                var filteredList = MockData.Reference.SelectionList.SelectionListItems()
                    .Where(x => (id == null || x.Id == id) &&
                                (isActiveOnly == null || x.IsActive == isActiveOnly) &&
                                (selectionTypeId == null || x.SelectionTypeId == selectionTypeId))
                    .ToList();
                return TransactionResult<IEnumerable<SelectionList>>.Success(filteredList);
            });

        // Setup for GetSubAgents
        result.Setup(s => s.GetSubAgents(It.IsAny<long?>(), It.IsAny<bool?>(), It.IsAny<string?>()))
            .ReturnsAsync((long? id, bool? isActiveOnly, string? MCOrAgentId) =>
            {
                var filteredList = MockData.Reference.SubAgents.SubAgentsList()
                    .Where(x => (id == null || x.Id == id) &&
                                (isActiveOnly == null || x.IsActive == isActiveOnly) &&
                                (MCOrAgentId == null || x.MCOrAgentId == MCOrAgentId))
                    .ToList();
                return TransactionResult<IEnumerable<SubAgents>>.Success(filteredList);
            });

        return result;
    }
    public static Mock<ITransactionV1Repository> GenerateTransactionRepositoryMock()
    {
        var result = new Mock<ITransactionV1Repository>();

        // Setup for GetGroupPolicy
        result.Setup(s => s.GetGroupPolicy(
            It.IsAny<long?>(),
            It.IsAny<string?>(),
            It.IsAny<string?>(),
            It.IsAny<long?>(),
            It.IsAny<bool?>(),
            It.IsAny<string?>(),
            It.IsAny<string?>(),
            It.IsAny<string?>(),
            It.IsAny<string?>(),
            It.IsAny<int>(),
            It.IsAny<int>()))
            .ReturnsAsync((long? id, string? referenceNumber, string? cocNumber, long? partnersId, bool? issueStatus,
                string? policyBookingStatusId, string? cocStatusId, string? paymentStatusId, string? claimsStatusId, int _, int _) =>
            {
                var filteredList = MockData.Transaction.GroupPolicy.GroupPolicyList()
                    .Where(x => (id == null || x.Id == id) &&
                                (referenceNumber == null || x.ReferenceNumber == referenceNumber) &&
                                (cocNumber == null || x.CocNumber == cocNumber) &&
                                (partnersId == null || x.PartnersId == partnersId) &&
                                (issueStatus == null || x.IssueStatus == issueStatus) &&
                                // Filter by PolicyBookingStatusId
                                (policyBookingStatusId == null ||
                                 policyBookingStatusId.Split(',', StringSplitOptions.RemoveEmptyEntries)
                                     .Select(s => long.TryParse(s.Trim(), out var parsedId) ? (long?)parsedId : null)
                                     .Where(pId => pId.HasValue)
                                     .Select(pId => pId.GetValueOrDefault())
                                     .Contains(x.PolicyBookingStatusId)
                                ) &&

                                // Filter by CocStatusId
                                (cocStatusId == null ||
                                 cocStatusId.Split(',', StringSplitOptions.RemoveEmptyEntries)
                                     .Select(s => long.TryParse(s.Trim(), out var parsedId) ? (long?)parsedId : null)
                                     .Where(pId => pId.HasValue)
                                     .Select(pId => pId.GetValueOrDefault())
                                     .Contains(x.CocStatusId)
                                ) &&

                                // Filter by PaymentStatusId
                                (paymentStatusId == null ||
                                 paymentStatusId.Split(',', StringSplitOptions.RemoveEmptyEntries)
                                     .Select(s => long.TryParse(s.Trim(), out var parsedId) ? (long?)parsedId : null)
                                     .Where(pId => pId.HasValue)
                                     .Select(pId => pId.GetValueOrDefault())
                                     .Contains(x.PaymentStatusId)
                                ) &&

                                // Filter by ClaimsStatusId
                                (claimsStatusId == null ||
                                 claimsStatusId.Split(',', StringSplitOptions.RemoveEmptyEntries)
                                     .Select(s => long.TryParse(s.Trim(), out var parsedId) ? (long?)parsedId : null)
                                     .Where(pId => pId.HasValue)
                                     .Select(pId => pId.GetValueOrDefault())
                                     .Contains(x.ClaimsStatusId)
                                ))
                    .ToList();
                return TransactionResult<IEnumerable<GroupPolicy>>.Success(filteredList);
            });

        // Setup for GetIndividualPolicy
        result.Setup(s => s.GetIndividualPolicy(
            It.IsAny<long?>(),
            It.IsAny<string?>(),
            It.IsAny<string?>(),
            It.IsAny<long?>(),
            It.IsAny<long?>(),
            It.IsAny<bool?>(),
            It.IsAny<string?>(),
            It.IsAny<string?>(),
            It.IsAny<string?>(),
            It.IsAny<string?>(),
            It.IsAny<int>(),
            It.IsAny<int>()))
            .ReturnsAsync((long? id, string? referenceNumber, string? cocNumber, long? partnersId, long? clientsId,
                           bool? issueStatus, string? policyBookingStatusId, string? cocStatusId, string? paymentStatusId, string? claimsStatusId, int _, int _) =>
            {
                var filteredList = MockData.Transaction.IndividualPolicy.IndividualPolicyList()
                    .Where(x => (id == null || x.Id == id) &&
                                (referenceNumber == null || x.ReferenceNumber == referenceNumber) &&
                                (cocNumber == null || x.CocNumber == cocNumber) &&
                                (partnersId == null || x.PartnersId == partnersId) &&
                                (clientsId == null || x.ClientsId == clientsId) &&
                                (issueStatus == null || x.IssueStatus == issueStatus) &&
                                // Filter by PolicyBookingStatusId
                                (policyBookingStatusId == null ||
                                 policyBookingStatusId.Split(',', StringSplitOptions.RemoveEmptyEntries)
                                     .Select(s => long.TryParse(s.Trim(), out var parsedId) ? (long?)parsedId : null)
                                     .Where(pId => pId.HasValue)
                                     .Select(pId => pId.GetValueOrDefault())
                                     .Contains(x.PolicyBookingStatusId)
                                ) &&

                                // Filter by CocStatusId
                                (cocStatusId == null ||
                                 cocStatusId.Split(',', StringSplitOptions.RemoveEmptyEntries)
                                     .Select(s => long.TryParse(s.Trim(), out var parsedId) ? (long?)parsedId : null)
                                     .Where(pId => pId.HasValue)
                                     .Select(pId => pId.GetValueOrDefault())
                                     .Contains(x.CocStatusId)
                                ) &&

                                // Filter by PaymentStatusId
                                (paymentStatusId == null ||
                                 paymentStatusId.Split(',', StringSplitOptions.RemoveEmptyEntries)
                                     .Select(s => long.TryParse(s.Trim(), out var parsedId) ? (long?)parsedId : null)
                                     .Where(pId => pId.HasValue)
                                     .Select(pId => pId.GetValueOrDefault())
                                     .Contains(x.PaymentStatusId)
                                ) &&

                                // Filter by ClaimsStatusId
                                (claimsStatusId == null ||
                                 claimsStatusId.Split(',', StringSplitOptions.RemoveEmptyEntries)
                                     .Select(s => long.TryParse(s.Trim(), out var parsedId) ? (long?)parsedId : null)
                                     .Where(pId => pId.HasValue)
                                     .Select(pId => pId.GetValueOrDefault())
                                     .Contains(x.ClaimsStatusId)
                                ))
                    .ToList();
                return TransactionResult<IEnumerable<IndividualPolicy>>.Success(filteredList);
            });

        // Setup for GetPartnerPolicy
        result.Setup(s => s.GetPartnerPolicy(
            It.IsAny<long?>(),
            It.IsAny<string?>(),
            It.IsAny<string?>(),
            It.IsAny<long?>(),
            It.IsAny<bool?>(),
            It.IsAny<string?>(),
            It.IsAny<string?>(),
            It.IsAny<string?>(),
            It.IsAny<string?>(),
            It.IsAny<int>(),
            It.IsAny<int>()))
            .ReturnsAsync((long? id, string? referenceNumber, string? cocNumber, long? partnersId, bool? issueStatus,
                string? policyBookingStatusId, string? cocStatusId, string? paymentStatusId, string? claimsStatusId, int _, int _) =>
            {
                var filteredList = MockData.Transaction.PartnerPolicy.PartnerPolicyList()
                    .Where(x => (id == null || x.Id == id) &&
                                (referenceNumber == null || x.ReferenceNumber == referenceNumber) &&
                                (cocNumber == null || x.CocNumber == cocNumber) &&
                                (partnersId == null || x.PartnersId == partnersId) &&
                                (issueStatus == null || x.IssueStatus == issueStatus) &&
                                // Filter by PolicyBookingStatusId
                                (policyBookingStatusId == null ||
                                 policyBookingStatusId.Split(',', StringSplitOptions.RemoveEmptyEntries)
                                     .Select(s => long.TryParse(s.Trim(), out var parsedId) ? (long?)parsedId : null)
                                     .Where(pId => pId.HasValue)
                                     .Select(pId => pId.GetValueOrDefault())
                                     .Contains(x.PolicyBookingStatusId)
                                ) &&

                                // Filter by CocStatusId
                                (cocStatusId == null ||
                                 cocStatusId.Split(',', StringSplitOptions.RemoveEmptyEntries)
                                     .Select(s => long.TryParse(s.Trim(), out var parsedId) ? (long?)parsedId : null)
                                     .Where(pId => pId.HasValue)
                                     .Select(pId => pId.GetValueOrDefault())
                                     .Contains(x.CocStatusId)
                                ) &&

                                // Filter by PaymentStatusId
                                (paymentStatusId == null ||
                                 paymentStatusId.Split(',', StringSplitOptions.RemoveEmptyEntries)
                                     .Select(s => long.TryParse(s.Trim(), out var parsedId) ? (long?)parsedId : null)
                                     .Where(pId => pId.HasValue)
                                     .Select(pId => pId.GetValueOrDefault())
                                     .Contains(x.PaymentStatusId)
                                ) &&

                                // Filter by ClaimsStatusId
                                (claimsStatusId == null ||
                                 claimsStatusId.Split(',', StringSplitOptions.RemoveEmptyEntries)
                                     .Select(s => long.TryParse(s.Trim(), out var parsedId) ? (long?)parsedId : null)
                                     .Where(pId => pId.HasValue)
                                     .Select(pId => pId.GetValueOrDefault())
                                     .Contains(x.ClaimsStatusId)
                                ))
                    .ToList();
                return TransactionResult<IEnumerable<PartnerPolicy>>.Success(filteredList);
            });

        return result;
    }
}