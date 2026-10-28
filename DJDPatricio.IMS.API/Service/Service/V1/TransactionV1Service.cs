using DJDPatricio.IMS.API.Helpers.Config;
using DJDPatricio.IMS.API.Models;
using DJDPatricio.IMS.API.Models.Result.Custom;
using DJDPatricio.IMS.API.Models.Result.Transaction;
using DJDPatricio.IMS.API.Repository.Interface.V1;
using DJDPatricio.IMS.API.Service.Interface.V1;

namespace DJDPatricio.IMS.API.Service.Service.V1;

public class TransactionV1Service(ITransactionV1Repository transactionV1Repository) : ITransactionV1Service
{
    public async Task<TransactionResult<IEnumerable<Attachments>>> GetAttachments(long? id, long? referenceId, long? attachmentTypeId, CancellationToken cancellationToken, int pageNumber = 1, int pageSize = 10)
    {
        using var cts = CancellationTokenSource.CreateLinkedTokenSource(cancellationToken);
        cts.CancelAfter(TimeSpan.FromSeconds(SystemDefaultsConfig.Config.ApiTimeoutInSeconds));

        return await transactionV1Repository.GetAttachments(id, referenceId, attachmentTypeId, pageNumber, pageSize);
    }
    public async Task<TransactionResult<IEnumerable<GroupPolicy>>> GetGroupPolicy(long? id, string? referenceNumber, string? cocNumber, long? partnersId, bool? issueStatus,
        string? policyBookingStatusId, string? cocStatusId, string? paymentStatusId, string? claimsStatusId, CancellationToken cancellationToken, int pageNumber = 1, int pageSize = 10)
    {
        using var cts = CancellationTokenSource.CreateLinkedTokenSource(cancellationToken);
        cts.CancelAfter(TimeSpan.FromSeconds(SystemDefaultsConfig.Config.ApiTimeoutInSeconds));

        return await transactionV1Repository.GetGroupPolicy(id, referenceNumber, cocNumber, partnersId, issueStatus,
            policyBookingStatusId, cocStatusId, paymentStatusId, claimsStatusId, pageNumber, pageSize);
    }
    public async Task<TransactionResult<IEnumerable<IndividualPolicy>>> GetIndividualPolicy(long? id, string? referenceNumber, string? cocNumber, long? partnersId, long? clientsId,
        bool? issueStatus, string? policyBookingStatusId, string? cocStatusId, string? paymentStatusId, string? claimsStatusId, CancellationToken cancellationToken, int pageNumber = 1, int pageSize = 10)
    {
        using var cts = CancellationTokenSource.CreateLinkedTokenSource(cancellationToken);
        cts.CancelAfter(TimeSpan.FromSeconds(SystemDefaultsConfig.Config.ApiTimeoutInSeconds));

        return await transactionV1Repository.GetIndividualPolicy(id, referenceNumber, cocNumber, partnersId, clientsId, issueStatus,
            policyBookingStatusId, cocStatusId, paymentStatusId, claimsStatusId, pageNumber, pageSize);
    }
    public async Task<TransactionResult<IEnumerable<PartnerPolicy>>> GetPartnerPolicy(long? id, string? referenceNumber, string? cocNumber, long? partnersId, bool? issueStatus,
        string? policyBookingStatusId, string? cocStatusId, string? paymentStatusId, string? claimsStatusId, CancellationToken cancellationToken, int pageNumber = 1, int pageSize = 10)
    {
        using var cts = CancellationTokenSource.CreateLinkedTokenSource(cancellationToken);
        cts.CancelAfter(TimeSpan.FromSeconds(SystemDefaultsConfig.Config.ApiTimeoutInSeconds));

        return await transactionV1Repository.GetPartnerPolicy(id, referenceNumber, cocNumber, partnersId, issueStatus,
            policyBookingStatusId, cocStatusId, paymentStatusId, claimsStatusId, pageNumber, pageSize);
    }
    public async Task<TransactionResult<IEnumerable<PolicyBeneficiary>>> GetPolicyBeneficiary(long? id, long? policyId, long? policyTypeId, CancellationToken cancellationToken, int pageNumber = 1, int pageSize = 10)
    {
        using var cts = CancellationTokenSource.CreateLinkedTokenSource(cancellationToken);
        cts.CancelAfter(TimeSpan.FromSeconds(SystemDefaultsConfig.Config.ApiTimeoutInSeconds));

        return await transactionV1Repository.GetPolicyBeneficiary(id, policyId, policyTypeId, pageNumber, pageSize);
    }
    public async Task<TransactionResult<IEnumerable<PolicyBenefits>>> GetPolicyBenefits(long? id, long? policyId, long? policyTypeId, CancellationToken cancellationToken, int pageNumber = 1, int pageSize = 10)
    {
        using var cts = CancellationTokenSource.CreateLinkedTokenSource(cancellationToken);
        cts.CancelAfter(TimeSpan.FromSeconds(SystemDefaultsConfig.Config.ApiTimeoutInSeconds));

        return await transactionV1Repository.GetPolicyBenefits(id, policyId, policyTypeId, pageNumber, pageSize);
    }
    public async Task<TransactionResult<IEnumerable<PolicyDeductibles>>> GetPolicyDeductibles(long? id, long? policyId, long? policyTypeId, CancellationToken cancellationToken, int pageNumber = 1, int pageSize = 10)
    {
        using var cts = CancellationTokenSource.CreateLinkedTokenSource(cancellationToken);
        cts.CancelAfter(TimeSpan.FromSeconds(SystemDefaultsConfig.Config.ApiTimeoutInSeconds));

        return await transactionV1Repository.GetPolicyDeductibles(id, policyId, policyTypeId, pageNumber, pageSize);
    }
    public async Task<TransactionResult<IEnumerable<PolicyPayments>>> GetPolicyPayments(long? id, long? policyId, long? policyTypeId, CancellationToken cancellationToken, int pageNumber = 1, int pageSize = 10)
    {
        using var cts = CancellationTokenSource.CreateLinkedTokenSource(cancellationToken);
        cts.CancelAfter(TimeSpan.FromSeconds(SystemDefaultsConfig.Config.ApiTimeoutInSeconds));

        return await transactionV1Repository.GetPolicyPayments(id, policyId, policyTypeId, pageNumber, pageSize);
    }

    //Views
    public async Task<TransactionResult<IEnumerable<AttachmentsView>>> GetAttachmentsView(long? id, long? referenceId, long? attachmentTypeId, CancellationToken cancellationToken, int pageNumber = 1, int pageSize = 10)
    {
        using var cts = CancellationTokenSource.CreateLinkedTokenSource(cancellationToken);
        cts.CancelAfter(TimeSpan.FromSeconds(SystemDefaultsConfig.Config.ApiTimeoutInSeconds));

        return await transactionV1Repository.GetAttachmentsView(id, referenceId, attachmentTypeId, pageNumber, pageSize);
    }
    public async Task<TransactionResult<IEnumerable<GroupPolicyView>>> GetGroupPolicyView(long? id, string? referenceNumber, string? cocNumber, long? partnersId, bool? issueStatus,
        string? policyBookingStatusId, string? cocStatusId, string? paymentStatusId, string? claimsStatusId, string? partnersCode, CancellationToken cancellationToken, int pageNumber = 1, int pageSize = 10)
    {
        using var cts = CancellationTokenSource.CreateLinkedTokenSource(cancellationToken);
        cts.CancelAfter(TimeSpan.FromSeconds(SystemDefaultsConfig.Config.ApiTimeoutInSeconds));

        return await transactionV1Repository.GetGroupPolicyView(id, referenceNumber, cocNumber, partnersId, issueStatus,
            policyBookingStatusId, cocStatusId, paymentStatusId, claimsStatusId, partnersCode, pageNumber, pageSize);
    }
    public async Task<TransactionResult<IEnumerable<IndividualPolicyView>>> GetIndividualPolicyView(long? id, string? referenceNumber, string? cocNumber, long? partnersId, long? clientsId,
        bool? issueStatus, string? policyBookingStatusId, string? cocStatusId, string? paymentStatusId, string? claimsStatusId, string? clientsInsuranceCustomerNo, CancellationToken cancellationToken, int pageNumber = 1, int pageSize = 10)
    {
        using var cts = CancellationTokenSource.CreateLinkedTokenSource(cancellationToken);
        cts.CancelAfter(TimeSpan.FromSeconds(SystemDefaultsConfig.Config.ApiTimeoutInSeconds));

        return await transactionV1Repository.GetIndividualPolicyView(id, referenceNumber, cocNumber, partnersId, clientsId, issueStatus,
            policyBookingStatusId, cocStatusId, paymentStatusId, claimsStatusId, clientsInsuranceCustomerNo, pageNumber, pageSize);
    }
    public async Task<TransactionResult<IEnumerable<PartnerPolicyView>>> GetPartnerPolicyView(long? id, string? referenceNumber, string? cocNumber, long? partnersId, bool? issueStatus,
        string? policyBookingStatusId, string? cocStatusId, string? paymentStatusId, string? claimsStatusId, string? partnersCode, CancellationToken cancellationToken, int pageNumber = 1, int pageSize = 10)
    {
        using var cts = CancellationTokenSource.CreateLinkedTokenSource(cancellationToken);
        cts.CancelAfter(TimeSpan.FromSeconds(SystemDefaultsConfig.Config.ApiTimeoutInSeconds));

        return await transactionV1Repository.GetPartnerPolicyView(id, referenceNumber, cocNumber, partnersId, issueStatus,
            policyBookingStatusId, cocStatusId, paymentStatusId, claimsStatusId, partnersCode, pageNumber, pageSize);
    }
    public async Task<TransactionResult<IEnumerable<PolicyBeneficiaryView>>> GetPolicyBeneficiaryView(long? id, long? policyId, long? policyTypeId, CancellationToken cancellationToken, int pageNumber = 1, int pageSize = 10)
    {
        using var cts = CancellationTokenSource.CreateLinkedTokenSource(cancellationToken);
        cts.CancelAfter(TimeSpan.FromSeconds(SystemDefaultsConfig.Config.ApiTimeoutInSeconds));

        return await transactionV1Repository.GetPolicyBeneficiaryView(id, policyId, policyTypeId, pageNumber, pageSize);
    }
    public async Task<TransactionResult<IEnumerable<PolicyBenefitsView>>> GetPolicyBenefitsView(long? id, long? policyId, long? policyTypeId, CancellationToken cancellationToken, int pageNumber = 1, int pageSize = 10)
    {
        using var cts = CancellationTokenSource.CreateLinkedTokenSource(cancellationToken);
        cts.CancelAfter(TimeSpan.FromSeconds(SystemDefaultsConfig.Config.ApiTimeoutInSeconds));

        return await transactionV1Repository.GetPolicyBenefitsView(id, policyId, policyTypeId, pageNumber, pageSize);
    }
    public async Task<TransactionResult<IEnumerable<PolicyDeductiblesView>>> GetPolicyDeductiblesView(long? id, long? policyId, long? policyTypeId, CancellationToken cancellationToken, int pageNumber = 1, int pageSize = 10)
    {
        using var cts = CancellationTokenSource.CreateLinkedTokenSource(cancellationToken);
        cts.CancelAfter(TimeSpan.FromSeconds(SystemDefaultsConfig.Config.ApiTimeoutInSeconds));

        return await transactionV1Repository.GetPolicyDeductiblesView(id, policyId, policyTypeId, pageNumber, pageSize);
    }
    public async Task<TransactionResult<IEnumerable<PolicyPaymentsView>>> GetPolicyPaymentsView(long? id, long? policyId, long? policyTypeId, CancellationToken cancellationToken, int pageNumber = 1, int pageSize = 10)
    {
        using var cts = CancellationTokenSource.CreateLinkedTokenSource(cancellationToken);
        cts.CancelAfter(TimeSpan.FromSeconds(SystemDefaultsConfig.Config.ApiTimeoutInSeconds));

        return await transactionV1Repository.GetPolicyPaymentsView(id, policyId, policyTypeId, pageNumber, pageSize);
    }

    public async Task<TransactionResult<PostId>> PostAttachments(object parameters, CancellationToken cancellationToken)
    {
        using var cts = CancellationTokenSource.CreateLinkedTokenSource(cancellationToken);
        cts.CancelAfter(TimeSpan.FromSeconds(SystemDefaultsConfig.Config.ApiTimeoutInSeconds));

        return await transactionV1Repository.PostAttachments(parameters);
    }
    public async Task<TransactionResult<PostId>> PostGroupPolicy(object parameters, CancellationToken cancellationToken)
    {
        using var cts = CancellationTokenSource.CreateLinkedTokenSource(cancellationToken);
        cts.CancelAfter(TimeSpan.FromSeconds(SystemDefaultsConfig.Config.ApiTimeoutInSeconds));

        return await transactionV1Repository.PostGroupPolicy(parameters);
    }
    public async Task<TransactionResult<PostId>> PostIndividualPolicy(object parameters, CancellationToken cancellationToken)
    {
        using var cts = CancellationTokenSource.CreateLinkedTokenSource(cancellationToken);
        cts.CancelAfter(TimeSpan.FromSeconds(SystemDefaultsConfig.Config.ApiTimeoutInSeconds));

        return await transactionV1Repository.PostIndividualPolicy(parameters);
    }
    public async Task<TransactionResult<PostId>> PostPartnerPolicy(object parameters, CancellationToken cancellationToken)
    {
        using var cts = CancellationTokenSource.CreateLinkedTokenSource(cancellationToken);
        cts.CancelAfter(TimeSpan.FromSeconds(SystemDefaultsConfig.Config.ApiTimeoutInSeconds));

        return await transactionV1Repository.PostPartnerPolicy(parameters);
    }
    public async Task<TransactionResult<PostId>> PostPolicyBeneficiary(object parameters, CancellationToken cancellationToken)
    {
        using var cts = CancellationTokenSource.CreateLinkedTokenSource(cancellationToken);
        cts.CancelAfter(TimeSpan.FromSeconds(SystemDefaultsConfig.Config.ApiTimeoutInSeconds));

        return await transactionV1Repository.PostPolicyBeneficiary(parameters);
    }
    public async Task<TransactionResult<PostId>> PostPolicyBenefits(object parameters, CancellationToken cancellationToken)
    {
        using var cts = CancellationTokenSource.CreateLinkedTokenSource(cancellationToken);
        cts.CancelAfter(TimeSpan.FromSeconds(SystemDefaultsConfig.Config.ApiTimeoutInSeconds));

        return await transactionV1Repository.PostPolicyBenefits(parameters);
    }
    public async Task<TransactionResult<PostId>> PostPolicyDeductibles(object parameters, CancellationToken cancellationToken)
    {
        using var cts = CancellationTokenSource.CreateLinkedTokenSource(cancellationToken);
        cts.CancelAfter(TimeSpan.FromSeconds(SystemDefaultsConfig.Config.ApiTimeoutInSeconds));

        return await transactionV1Repository.PostPolicyDeductibles(parameters);
    }
    public async Task<TransactionResult<PostId>> PostPolicyPayments(object parameters, CancellationToken cancellationToken)
    {
        using var cts = CancellationTokenSource.CreateLinkedTokenSource(cancellationToken);
        cts.CancelAfter(TimeSpan.FromSeconds(SystemDefaultsConfig.Config.ApiTimeoutInSeconds));

        return await transactionV1Repository.PostPolicyPayments(parameters);
    }

    public async Task<TransactionResult> PutAttachments(object parameters, CancellationToken cancellationToken)
    {
        using var cts = CancellationTokenSource.CreateLinkedTokenSource(cancellationToken);
        cts.CancelAfter(TimeSpan.FromSeconds(SystemDefaultsConfig.Config.ApiTimeoutInSeconds));

        return await transactionV1Repository.PutAttachments(parameters);
    }
    public async Task<TransactionResult> PutGroupPolicy(object parameters, CancellationToken cancellationToken)
    {
        using var cts = CancellationTokenSource.CreateLinkedTokenSource(cancellationToken);
        cts.CancelAfter(TimeSpan.FromSeconds(SystemDefaultsConfig.Config.ApiTimeoutInSeconds));

        return await transactionV1Repository.PutGroupPolicy(parameters);
    }
    public async Task<TransactionResult> PutIndividualPolicy(object parameters, CancellationToken cancellationToken)
    {
        using var cts = CancellationTokenSource.CreateLinkedTokenSource(cancellationToken);
        cts.CancelAfter(TimeSpan.FromSeconds(SystemDefaultsConfig.Config.ApiTimeoutInSeconds));

        return await transactionV1Repository.PutIndividualPolicy(parameters);
    }
    public async Task<TransactionResult> PutPartnerPolicy(object parameters, CancellationToken cancellationToken)
    {
        using var cts = CancellationTokenSource.CreateLinkedTokenSource(cancellationToken);
        cts.CancelAfter(TimeSpan.FromSeconds(SystemDefaultsConfig.Config.ApiTimeoutInSeconds));

        return await transactionV1Repository.PutPartnerPolicy(parameters);
    }
    public async Task<TransactionResult> PutPolicyBeneficiary(object parameters, CancellationToken cancellationToken)
    {
        using var cts = CancellationTokenSource.CreateLinkedTokenSource(cancellationToken);
        cts.CancelAfter(TimeSpan.FromSeconds(SystemDefaultsConfig.Config.ApiTimeoutInSeconds));

        return await transactionV1Repository.PutPolicyBeneficiary(parameters);
    }
    public async Task<TransactionResult> PutPolicyPayments(object parameters, CancellationToken cancellationToken)
    {
        using var cts = CancellationTokenSource.CreateLinkedTokenSource(cancellationToken);
        cts.CancelAfter(TimeSpan.FromSeconds(SystemDefaultsConfig.Config.ApiTimeoutInSeconds));

        return await transactionV1Repository.PutPolicyPayments(parameters);
    }
}