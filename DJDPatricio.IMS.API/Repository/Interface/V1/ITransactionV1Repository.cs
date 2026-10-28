using DJDPatricio.IMS.API.Models;
using DJDPatricio.IMS.API.Models.Result.Custom;
using DJDPatricio.IMS.API.Models.Result.Transaction;

namespace DJDPatricio.IMS.API.Repository.Interface.V1;

public interface ITransactionV1Repository
{
    Task<TransactionResult<IEnumerable<Attachments>>> GetAttachments(long? id, long? referenceId, long? attachmentTypeId, int pageNumber = 1, int pageSize = 10);
    Task<TransactionResult<IEnumerable<GroupPolicy>>> GetGroupPolicy(long? id, string? referenceNumber, string? cocNumber, long? partnersId, bool? issueStatus, 
        string? policyBookingStatusId, string? cocStatusId, string? paymentStatusId, string? claimsStatusId, int pageNumber = 1, int pageSize = 10);
    Task<TransactionResult<IEnumerable<IndividualPolicy>>> GetIndividualPolicy(long? id, string? referenceNumber, string? cocNumber, long? partnersId, long? clientsId, 
        bool? issueStatus, string? policyBookingStatusId, string? cocStatusId, string? paymentStatusId, string? claimsStatusId, int pageNumber = 1, int pageSize = 10);
    Task<TransactionResult<IEnumerable<PartnerPolicy>>> GetPartnerPolicy(long? id, string? referenceNumber, string? cocNumber, long? partnersId, bool? issueStatus,
        string? policyBookingStatusId, string? cocStatusId, string? paymentStatusId, string? claimsStatusId, int pageNumber = 1, int pageSize = 10);
    Task<TransactionResult<IEnumerable<PolicyBeneficiary>>> GetPolicyBeneficiary(long? id, long? policyId, long? policyTypeId, int pageNumber = 1, int pageSize = 10);
    Task<TransactionResult<IEnumerable<PolicyBenefits>>> GetPolicyBenefits(long? id, long? policyId, long? policyTypeId, int pageNumber = 1, int pageSize = 10);
    Task<TransactionResult<IEnumerable<PolicyDeductibles>>> GetPolicyDeductibles(long? id, long? policyId, long? policyTypeId, int pageNumber = 1, int pageSize = 10);
    Task<TransactionResult<IEnumerable<PolicyPayments>>> GetPolicyPayments(long? id, long? policyId, long? policyTypeId, int pageNumber = 1, int pageSize = 10);

    //Views
    Task<TransactionResult<IEnumerable<AttachmentsView>>> GetAttachmentsView(long? id, long? referenceId, long? attachmentTypeId, int pageNumber = 1, int pageSize = 10);
    Task<TransactionResult<IEnumerable<GroupPolicyView>>> GetGroupPolicyView(long? id, string? referenceNumber, string? cocNumber, long? partnersId, bool? issueStatus,
        string? policyBookingStatusId, string? cocStatusId, string? paymentStatusId, string? claimsStatusId, string? partnersCode, int pageNumber = 1, int pageSize = 10);
    Task<TransactionResult<IEnumerable<IndividualPolicyView>>> GetIndividualPolicyView(long? id, string? referenceNumber, string? cocNumber, long? partnersId, long? clientsId,
        bool? issueStatus, string? policyBookingStatusId, string? cocStatusId, string? paymentStatusId, string? claimsStatusId, string? clientsInsuranceCustomerNo, int pageNumber = 1, int pageSize = 10);
    Task<TransactionResult<IEnumerable<PartnerPolicyView>>> GetPartnerPolicyView(long? id, string? referenceNumber, string? cocNumber, long? partnersId, bool? issueStatus,
        string? policyBookingStatusId, string? cocStatusId, string? paymentStatusId, string? claimsStatusId, string? partnersCode, int pageNumber = 1, int pageSize = 10);
    Task<TransactionResult<IEnumerable<PolicyBeneficiaryView>>> GetPolicyBeneficiaryView(long? id, long? policyId, long? policyTypeId, int pageNumber = 1, int pageSize = 10);
    Task<TransactionResult<IEnumerable<PolicyBenefitsView>>> GetPolicyBenefitsView(long? id, long? policyId, long? policyTypeId, int pageNumber = 1, int pageSize = 10);
    Task<TransactionResult<IEnumerable<PolicyDeductiblesView>>> GetPolicyDeductiblesView(long? id, long? policyId, long? policyTypeId, int pageNumber = 1, int pageSize = 10);
    Task<TransactionResult<IEnumerable<PolicyPaymentsView>>> GetPolicyPaymentsView(long? id, long? policyId, long? policyTypeId, int pageNumber = 1, int pageSize = 10);

    Task<TransactionResult<PostId>> PostAttachments(object parameters);
    Task<TransactionResult<PostId>> PostGroupPolicy(object parameters);
    Task<TransactionResult<PostId>> PostIndividualPolicy(object parameters);
    Task<TransactionResult<PostId>> PostPartnerPolicy(object parameters);
    Task<TransactionResult<PostId>> PostPolicyBeneficiary(object parameters);
    Task<TransactionResult<PostId>> PostPolicyBenefits(object parameters);
    Task<TransactionResult<PostId>> PostPolicyDeductibles(object parameters);
    Task<TransactionResult<PostId>> PostPolicyPayments(object parameters);

    Task<TransactionResult> PutAttachments(object parameters);
    Task<TransactionResult> PutGroupPolicy(object parameters);
    Task<TransactionResult> PutIndividualPolicy(object parameters);
    Task<TransactionResult> PutPartnerPolicy(object parameters);
    Task<TransactionResult> PutPolicyBeneficiary(object parameters);
    Task<TransactionResult> PutPolicyPayments(object parameters);
}