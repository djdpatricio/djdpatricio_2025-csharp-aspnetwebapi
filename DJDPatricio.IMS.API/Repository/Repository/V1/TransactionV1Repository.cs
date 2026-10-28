using DJDPatricio.IMS.API.Models;
using DJDPatricio.IMS.API.Models.Result.Custom;
using DJDPatricio.IMS.API.Models.Result.Transaction;
using DJDPatricio.IMS.API.Repository.Constants;
using DJDPatricio.IMS.API.Repository.Interface;
using DJDPatricio.IMS.API.Repository.Interface.V1;

namespace DJDPatricio.IMS.API.Repository.Repository.V1;

public class TransactionV1Repository(IDbFactoryWrapperRepository databaseContext) : ITransactionV1Repository
{
    public async Task<TransactionResult<IEnumerable<Attachments>>> GetAttachments(long? id, long? referenceId, long? attachmentTypeId, int pageNumber = 1, int pageSize = 10)
    {
        return await databaseContext.ExecuteMultipleResultStoredProcedureAsync<Attachments>
            (V1ProcedureReference.Transaction.Get.GetAttachments, new { id, referenceId, attachmentTypeId, pageNumber, pageSize });
    }
    public async Task<TransactionResult<IEnumerable<GroupPolicy>>> GetGroupPolicy(long? id, string? referenceNumber, string? cocNumber, long? partnersId, bool? issueStatus,
        string? policyBookingStatusId, string? cocStatusId, string? paymentStatusId, string? claimsStatusId, int pageNumber = 1, int pageSize = 10)
    {
        return await databaseContext.ExecuteMultipleResultStoredProcedureAsync<GroupPolicy>
            (V1ProcedureReference.Transaction.Get.GetGroupPolicy, new { id, referenceNumber, cocNumber, partnersId, issueStatus,
        policyBookingStatusId, cocStatusId, paymentStatusId, claimsStatusId, pageNumber, pageSize });
    }
    public async Task<TransactionResult<IEnumerable<IndividualPolicy>>> GetIndividualPolicy(long? id, string? referenceNumber, string? cocNumber, long? partnersId, long? clientsId,
        bool? issueStatus, string? policyBookingStatusId, string? cocStatusId, string? paymentStatusId, string? claimsStatusId, int pageNumber = 1, int pageSize = 10)
    {
        return await databaseContext.ExecuteMultipleResultStoredProcedureAsync<IndividualPolicy>
            (V1ProcedureReference.Transaction.Get.GetIndividualPolicy, new { id, referenceNumber, cocNumber, partnersId, clientsId, issueStatus,
        policyBookingStatusId, cocStatusId, paymentStatusId, claimsStatusId, pageNumber, pageSize });
    }
    public async Task<TransactionResult<IEnumerable<PartnerPolicy>>> GetPartnerPolicy(long? id, string? referenceNumber, string? cocNumber, long? partnersId, bool? issueStatus,
        string? policyBookingStatusId, string? cocStatusId, string? paymentStatusId, string? claimsStatusId, int pageNumber = 1, int pageSize = 10)
    {
        return await databaseContext.ExecuteMultipleResultStoredProcedureAsync<PartnerPolicy>
            (V1ProcedureReference.Transaction.Get.GetPartnerPolicy, new { id, referenceNumber, cocNumber, partnersId, issueStatus,
        policyBookingStatusId, cocStatusId, paymentStatusId, claimsStatusId, pageNumber, pageSize });
    }
    public async Task<TransactionResult<IEnumerable<PolicyBeneficiary>>> GetPolicyBeneficiary(long? id, long? policyId, long? policyTypeId, int pageNumber = 1, int pageSize = 10)
    {
        return await databaseContext.ExecuteMultipleResultStoredProcedureAsync<PolicyBeneficiary>
            (V1ProcedureReference.Transaction.Get.GetPolicyBeneficiary, new { id, policyId, policyTypeId, pageNumber, pageSize });
    }
    public async Task<TransactionResult<IEnumerable<PolicyBenefits>>> GetPolicyBenefits(long? id, long? policyId, long? policyTypeId, int pageNumber = 1, int pageSize = 10)
    {
        return await databaseContext.ExecuteMultipleResultStoredProcedureAsync<PolicyBenefits>
            (V1ProcedureReference.Transaction.Get.GetPolicyBenefits, new { id, policyId, policyTypeId, pageNumber, pageSize });
    }
    public async Task<TransactionResult<IEnumerable<PolicyDeductibles>>> GetPolicyDeductibles(long? id, long? policyId, long? policyTypeId, int pageNumber = 1, int pageSize = 10)
    {
        return await databaseContext.ExecuteMultipleResultStoredProcedureAsync<PolicyDeductibles>
            (V1ProcedureReference.Transaction.Get.GetPolicyDeductibles, new { id, policyId, policyTypeId, pageNumber, pageSize });
    }
    public async Task<TransactionResult<IEnumerable<PolicyPayments>>> GetPolicyPayments(long? id, long? policyId, long? policyTypeId, int pageNumber = 1, int pageSize = 10)
    {
        return await databaseContext.ExecuteMultipleResultStoredProcedureAsync<PolicyPayments>
            (V1ProcedureReference.Transaction.Get.GetPolicyPayments, new { id, policyId, policyTypeId, pageNumber, pageSize });
    }

    //Views
    public async Task<TransactionResult<IEnumerable<AttachmentsView>>> GetAttachmentsView(long? id, long? referenceId, long? attachmentTypeId, int pageNumber = 1, int pageSize = 10)
    {
        return await databaseContext.ExecuteMultipleResultStoredProcedureAsync<AttachmentsView>
            (V1ProcedureReference.Transaction.Get.View.GetAttachmentsView, new { id, referenceId, attachmentTypeId, pageNumber, pageSize });
    }
    public async Task<TransactionResult<IEnumerable<GroupPolicyView>>> GetGroupPolicyView(long? id, string? referenceNumber, string? cocNumber, long? partnersId, bool? issueStatus,
        string? policyBookingStatusId, string? cocStatusId, string? paymentStatusId, string? claimsStatusId, string? partnersCode, int pageNumber = 1, int pageSize = 10)
    {
        return await databaseContext.ExecuteMultipleResultStoredProcedureAsync<GroupPolicyView>
            (V1ProcedureReference.Transaction.Get.View.GetGroupPolicyView, new
            {
                id,
                referenceNumber,
                cocNumber,
                partnersId,
                issueStatus,
                policyBookingStatusId,
                cocStatusId,
                paymentStatusId,
                claimsStatusId,
                partnersCode,
                pageNumber,
                pageSize
            });
    }
    public async Task<TransactionResult<IEnumerable<IndividualPolicyView>>> GetIndividualPolicyView(long? id, string? referenceNumber, string? cocNumber, long? partnersId, long? clientsId,
        bool? issueStatus, string? policyBookingStatusId, string? cocStatusId, string? paymentStatusId, string? claimsStatusId, string? clientsInsuranceCustomerNo, int pageNumber = 1, int pageSize = 10)
    {
        return await databaseContext.ExecuteMultipleResultStoredProcedureAsync<IndividualPolicyView>
            (V1ProcedureReference.Transaction.Get.View.GetIndividualPolicyView, new
            {
                id,
                referenceNumber,
                cocNumber,
                partnersId,
                clientsId,
                issueStatus,
                policyBookingStatusId,
                cocStatusId,
                paymentStatusId,
                claimsStatusId,
                clientsInsuranceCustomerNo,
                pageNumber,
                pageSize
            });
    }
    public async Task<TransactionResult<IEnumerable<PartnerPolicyView>>> GetPartnerPolicyView(long? id, string? referenceNumber, string? cocNumber, long? partnersId, bool? issueStatus,
        string? policyBookingStatusId, string? cocStatusId, string? paymentStatusId, string? claimsStatusId, string? partnersCode, int pageNumber = 1, int pageSize = 10)
    {
        return await databaseContext.ExecuteMultipleResultStoredProcedureAsync<PartnerPolicyView>
            (V1ProcedureReference.Transaction.Get.View.GetPartnerPolicyView, new
            {
                id,
                referenceNumber,
                cocNumber,
                partnersId,
                issueStatus,
                policyBookingStatusId,
                cocStatusId,
                paymentStatusId,
                claimsStatusId,
                partnersCode,
                pageNumber,
                pageSize
            });
    }
    public async Task<TransactionResult<IEnumerable<PolicyBeneficiaryView>>> GetPolicyBeneficiaryView(long? id, long? policyId, long? policyTypeId, int pageNumber = 1, int pageSize = 10)
    {
        return await databaseContext.ExecuteMultipleResultStoredProcedureAsync<PolicyBeneficiaryView>
            (V1ProcedureReference.Transaction.Get.View.GetPolicyBeneficiaryView, new { id, policyId, policyTypeId, pageNumber, pageSize });
    }
    public async Task<TransactionResult<IEnumerable<PolicyBenefitsView>>> GetPolicyBenefitsView(long? id, long? policyId, long? policyTypeId, int pageNumber = 1, int pageSize = 10)
    {
        return await databaseContext.ExecuteMultipleResultStoredProcedureAsync<PolicyBenefitsView>
            (V1ProcedureReference.Transaction.Get.View.GetPolicyBenefitsView, new { id, policyId, policyTypeId, pageNumber, pageSize });
    }
    public async Task<TransactionResult<IEnumerable<PolicyDeductiblesView>>> GetPolicyDeductiblesView(long? id, long? policyId, long? policyTypeId, int pageNumber = 1, int pageSize = 10)
    {
        return await databaseContext.ExecuteMultipleResultStoredProcedureAsync<PolicyDeductiblesView>
            (V1ProcedureReference.Transaction.Get.View.GetPolicyDeductiblesView, new { id, policyId, policyTypeId, pageNumber, pageSize });
    }
    public async Task<TransactionResult<IEnumerable<PolicyPaymentsView>>> GetPolicyPaymentsView(long? id, long? policyId, long? policyTypeId, int pageNumber = 1, int pageSize = 10)
    {
        return await databaseContext.ExecuteMultipleResultStoredProcedureAsync<PolicyPaymentsView>
            (V1ProcedureReference.Transaction.Get.View.GetPolicyPaymentsView, new { id, policyId, policyTypeId, pageNumber, pageSize });
    }

    public async Task<TransactionResult<PostId>> PostAttachments(object parameters)
    {
        return await databaseContext.ExecuteSingleResultStoredProcedureAsync<PostId>
            (V1ProcedureReference.Transaction.Post .PostAttachments, parameters);
    }
    public async Task<TransactionResult<PostId>> PostGroupPolicy(object parameters)
    {
        return await databaseContext.ExecuteSingleResultStoredProcedureAsync<PostId>
            (V1ProcedureReference.Transaction.Post.PostGroupPolicy, parameters);
    }
    public async Task<TransactionResult<PostId>> PostIndividualPolicy(object parameters)
    {
        return await databaseContext.ExecuteSingleResultStoredProcedureAsync<PostId>
            (V1ProcedureReference.Transaction.Post.PostIndividualPolicy, parameters);
    }
    public async Task<TransactionResult<PostId>> PostPartnerPolicy(object parameters)
    {
        return await databaseContext.ExecuteSingleResultStoredProcedureAsync<PostId>
            (V1ProcedureReference.Transaction.Post.PostPartnerPolicy, parameters);
    }
    public async Task<TransactionResult<PostId>> PostPolicyBeneficiary(object parameters)
    {
        return await databaseContext.ExecuteSingleResultStoredProcedureAsync<PostId>
            (V1ProcedureReference.Transaction.Post.PostPolicyBeneficiary, parameters);
    }
    public async Task<TransactionResult<PostId>> PostPolicyBenefits(object parameters)
    {
        return await databaseContext.ExecuteSingleResultStoredProcedureAsync<PostId>
            (V1ProcedureReference.Transaction.Post.PostPolicyBenefits, parameters);
    }
    public async Task<TransactionResult<PostId>> PostPolicyDeductibles(object parameters)
    {
        return await databaseContext.ExecuteSingleResultStoredProcedureAsync<PostId>
            (V1ProcedureReference.Transaction.Post.PostPolicyDeductibles, parameters);
    }
    public async Task<TransactionResult<PostId>> PostPolicyPayments(object parameters)
    {
        return await databaseContext.ExecuteSingleResultStoredProcedureAsync<PostId>
            (V1ProcedureReference.Transaction.Post.PostPolicyPayments, parameters);
    }

    public async Task<TransactionResult> PutAttachments(object parameters)
    {
        return await databaseContext.ExecuteStoredProcedureAsync(V1ProcedureReference.Transaction.Put.PutAttachments, parameters);
    }
    public async Task<TransactionResult> PutGroupPolicy(object parameters)
    {
        return await databaseContext.ExecuteStoredProcedureAsync(V1ProcedureReference.Transaction.Put.PutGroupPolicy, parameters);
    }
    public async Task<TransactionResult> PutIndividualPolicy(object parameters)
    {
        return await databaseContext.ExecuteStoredProcedureAsync(V1ProcedureReference.Transaction.Put.PutIndividualPolicy, parameters);
    }
    public async Task<TransactionResult> PutPartnerPolicy(object parameters)
    {
        return await databaseContext.ExecuteStoredProcedureAsync(V1ProcedureReference.Transaction.Put.PutPartnerPolicy, parameters);
    }
    public async Task<TransactionResult> PutPolicyBeneficiary(object parameters)
    {
        return await databaseContext.ExecuteStoredProcedureAsync(V1ProcedureReference.Transaction.Put.PutPolicyBeneficiary, parameters);
    }
    public async Task<TransactionResult> PutPolicyPayments(object parameters)
    {
        return await databaseContext.ExecuteStoredProcedureAsync(V1ProcedureReference.Transaction.Put.PutPolicyPayments, parameters);
    }
}