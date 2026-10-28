namespace DJDPatricio.IMS.API.Helpers;

public static class StaticDataHelper
{
    public enum CrudOperation
    {
        Get,
        Post,
        Put,
        Delete
    }

    public enum TimePeriodOption
    {
        Year5 = 1,
        Year1,
        Month6,
        Day30
    }

    public static readonly Dictionary<string, long> DistributionChannelWithPromoSalesOption = new()
    {
        { "ADC - Mall Branches", 7 },
        { "ADC2 - Mall Branches", 8 }
    };
    public static readonly Dictionary<string, long> DistributionChannelWithBranchCodeAndReferrer = new()
    {
        { "Semi-Captive", 4 },
    };

    public static class AttachmentType
    {
        public static class Individual
        {
            public const long Id = 1;
            public const string Name = "Individual";
            public const string? Description = null;
        }

        public static class Partner
        {
            public const long Id = 2;
            public const string Name = "Partner";
            public const string? Description = null;
        }

        public static class GroupPolicyCopy
        {
            public const long Id = 3;
            public const string Name = "Group Policy Copy";
            public const string? Description = null;
        }

        public static class GroupDeclarationFile
        {
            public const long Id = 4;
            public const string Name = "Group Declaration File";
            public const string? Description = null;
        }

        public static class Payments
        {
            public const long Id = 5;
            public const string Name = "Payments";
            public const string? Description = null;
        }
    }

    public static class ClaimsStatus
    {
        public static class Reported
        {
            public const long Id = 1;
            public const string Name = "Reported";
            public const string? Description = "Notice of claim is made through DJDPatricio branch or direct to DJDPatricio Claims Team";
        }
        
        public static class PendingRequirements
        {
            public const long Id = 2;
            public const string Name = "Pending Requirements";
            public const string? Description = "Client to submit or has submitted partial document requirements for his/her claim";
        }

        public static class Processing
        {
            public const long Id = 3;
            public const string Name = "Processing";
            public const string? Description = "Client completes submission of claims requirements to DJDPatricio Claims";
        }

        public static class ForApprovalSectionHead
        {
            public const long Id = 4;
            public const string Name = "For Approval of Section Head";
            public const string? Description = "Claims Section Head reviews and approves the claim if amount is Within Settlement Authority (WSA is not more than Php60K)";
        }

        public static class ForApprovalClaimsDeptHead
        {
            public const long Id = 5;
            public const string Name = "For Approval of Claims Dept Head";
            public const string? Description = "Claims Department Head reviews and approves/disapproves all approvals made by Section Head, including claims payout processed via RAS (Remittance Agent System)";
        }

        public static class ForInsurerApproval
        {
            public const long Id = 6;
            public const string Name = "For Insurer's Approval";
            public const string? Description = "Claims under the following conditions are subject to review and approval of Insurance Company (Pioneer): a) Benefit is above Php60K; b) All Emergency Expense Benefit Claim; c) Other Claims deemed for approval of insurer";
        }

        public static class ApprovedByInsurer
        {
            public const long Id = 7;
            public const string Name = "Approved by Insurer";
            public const string? Description = "Claims submitted for insurer's review is already approved and sends Letter of Authorization (LOA) or check (if applicable)";
        }

        public static class ForPaymentProcessing
        {
            public const long Id = 8;
            public const string Name = "For Payment Processing";
            public const string? Description = "Claim is lined up for payment processing of DJDPatricio/Insurer";
        }

        public static class ReadyForRelease
        {
            public const long Id = 9;
            public const string Name = "Ready for Release";
            public const string? Description = "Claim is now ready for release to claimant (with reference number)";
        }

        public static class Settled
        {
            public const long Id = 10;
            public const string Name = "Settled";
            public const string? Description = "Claims proceeds is released to client/claimant";
        }

        public static class Denied
        {
            public const long Id = 11;
            public const string Name = "Denied";
            public const string? Description = "Claim is denied either by DJDPatricio or Insurer";
        }

        public static class PendingReimbursement
        {
            public const long Id = 12;
            public const string Name = "Pending Reimbursement";
            public const string? Description = "Claims forwarded to insurer for reimbursement";
        }

        public static class Reimbursed
        {
            public const long Id = 13;
            public const string Name = "Reimbursed";
            public const string? Description = "Claims is already replenished/paid by insurer";
        }

        public static class ForExGratiaProcessing
        {
            public const long Id = 14;
            public const string Name = "For Ex-Gratia Processing";
            public const string? Description = "Denied claims that are subject for reconsideration upon submission of recommendation by DJDPatricio branch personnel";
        }

        public static class ExGratiaForApprovalClaimsDeptHead
        {
            public const long Id = 15;
            public const string Name = "Ex-Gratia for Approval of Claims Department Head";
            public const string? Description = "Claims Lead submits the claim for ex-gratia for approval by Claims Department Head (rule: ex-gratia amount must not be more than Php500 per COC)";
        }

        public static class ExGratiaForApprovalInsurer
        {
            public const long Id = 16;
            public const string Name = "Ex-Gratia for Approval of Insurer";
            public const string? Description = "Claim is endorsed to Insurer for ex-gratia reconsideration";
        }

        public static class ExGratiaForApprovalAccountingDeptHead
        {
            public const long Id = 17;
            public const string Name = "Ex-Gratia for Approval of Accounting Department Head";
            public const string? Description = "Ex-gratia amount is submitted to Accounting Head for validation (copy of approval of Group Head must be attached if ex-gratia amount is more than Php500/COC or Php2500)";
        }

        public static class ForExGratiaPaymentProcessing
        {
            public const long Id = 18;
            public const string Name = "For Ex-Gratia Payment Processing";
            public const string? Description = "Ex-gratia is approved by Accounting Head and will be processed for payout";
        }

        public static class ReadyForReleaseExGratia
        {
            public const long Id = 19;
            public const string Name = "Ready for release (Ex-Gratia)";
            public const string? Description = "Claim is now ready for release to claimant (with reference number)";
        }

        public static class SettledExGratia
        {
            public const long Id = 20;
            public const string Name = "Settled (Ex-Gratia)";
            public const string? Description = "Claims proceeds is released to client/claimant";
        }

        public static class Cancelled
        {
            public const long Id = 21;
            public const string Name = "Cancelled";
            public const string? Description = "Claim benefit is processed for release (with reference number) but are unclaimed for more than 20 working days";
        }

        public static class ReactivatedForPayout
        {
            public const long Id = 22;
            public const string Name = "Reactivated for Payout";
            public const string? Description = "Claim benefit will be processed again for release to generate a new reference number for the payout upon receipt of claimant's request";
        }

        public static class Archived
        {
            public const long Id = 23;
            public const string Name = "Archived";
            public const string? Description = "Claim pending for 10 working days with lacking requirements from clients";
        }
    }

    public static class CocStatus
    {
        public static class Active
        {
            public const long Id = 1;
            public const string Name = "Active";
            public const string? Description = "COC in force; will be defined per benefit";
        }

        public static class Claimed
        {
            public const long Id = 2;
            public const string Name = "Claimed";
            public const string? Description = "Refers to status of benefit if already claimed or not; will be defined per benefit";
        }

        public static class Expired
        {
            public const long Id = 3;
            public const string Name = "Expired";
            public const string? Description = "COC is terminated on last day of effectivity date (ex: Sept 3, 2020 to Jan 3, 2021)";
        }

        public static class Cancelled
        {
            public const long Id = 4;
            public const string Name = "Cancelled";
            public const string? Description = "Successful sales but client requested for cancellation due to valid reasons";
        }

        public static class Void
        {
            public const long Id = 5;
            public const string Name = "Void";
            public const string? Description = "Sold COC’s but not yet encoded in the system and requested to tag as Void due to valid reasons";
        }

        public static class Inactive
        {
            public const long Id = 6;
            public const string Name = "Inactive";
            public const string? Description = "Inactive COC";
        }
    }

    public static class PaymentStatus
    {
        public static class FullyPaid
        {
            public const long Id = 1;
            public const string Name = "Fully Paid";
            public const string? Description = null;
        }

        public static class Unpaid
        {
            public const long Id = 2;
            public const string Name = "Unpaid";
            public const string? Description = null;
        }

        public static class PartiallyPaid
        {
            public const long Id = 3;
            public const string Name = "Partially Paid";
            public const string? Description = null;
        }

        public static class Cancelled
        {
            public const long Id = 4;
            public const string Name = "Cancelled";
            public const string? Description = null;
        }

        public static class Overpaid
        {
            public const long Id = 5;
            public const string Name = "Overpaid";
            public const string? Description = null;
        }
    }

    public static class Platforms
    {
        public static class SMS
        {
            public const long Id = 1;
            public const string Name = "SMS";
            public const string? Description = "for SMS based registration";
            public const string Code = "SMS1";
        }

        public static class FWCMobileApp
        {
            public const long Id = 2;
            public const string Name = "FWC Mobile App";
            public const string? Description = "FWC Mobile Application";
            public const string Code = "FWCA";
        }

        public static class IClick30
        {
            public const long Id = 3;
            public const string Name = "iClick 3.0";
            public const string? Description = null;
            public const string Code = "IC30";
        }

        public static class PeraLinkApp
        {
            public const long Id = 4;
            public const string Name = "PeraLink App";
            public const string? Description = null;
            public const string Code = "PRLK";
        }

        public static class J6WPlatform
        {
            public const long Id = 5;
            public const string Name = "J6W Platform";
            public const string? Description = "J6W Digital Platform";
            public const string Code = "J6WP";
        }

        public static class BizmotoPlatform
        {
            public const long Id = 6;
            public const string Name = "Bizmoto Platform";
            public const string? Description = null;
            public const string Code = "BIZP";
        }

        public static class TagcashPlatform
        {
            public const long Id = 7;
            public const string Name = "Tagcash Platform";
            public const string? Description = null;
            public const string Code = "TAGP";
        }

        public static class DJDPatricioFromHome
        {
            public const long Id = 8;
            public const string Name = "DJDPatricio From Home";
            public const string? Description = null;
            public const string Code = "CFHS";
        }

        public static class MCMicrosite
        {
            public const long Id = 9;
            public const string Name = "DJDPatricio Microsite";
            public const string? Description = null;
            public const string Code = "CLMS";
        }

        public static class Website24K
        {
            public const long Id = 10;
            public const string Name = "24K Website";
            public const string? Description = "DJDPatricio 24K members website";
            public const string Code = "24KW";
        }

        public static class EDJDPatricioApp
        {
            public const long Id = 11;
            public const string Name = "eDJDPatricio App";
            public const string? Description = "eDJDPatricio Application";
            public const string Code = "ECEB";
        }

        public static class ETapKiosk
        {
            public const long Id = 12;
            public const string Name = "eTap Kiosk";
            public const string? Description = "eTap Digital Platform";
            public const string Code = "ETAP";
        }

        public static class CMS2
        {
            public const long Id = 13;
            public const string Name = "CMS 2.0";
            public const string? Description = "Proud cloud platform";
            public const string Code = "CMS2";
        }

        public static class IMS2
        {
            public const long Id = 14;
            public const string Name = "IMS 2.0";
            public const string? Description = "Insurance Management System v2";
            public const string Code = "IMS2";
        }

        public static class MultiSysPlatform
        {
            public const long Id = 15;
            public const string Name = "MutiSys Platform";
            public const string? Description = "Multisys platform";
            public const string Code = "MSYS";
        }

        public static class ActionAble
        {
            public const long Id = 16;
            public const string Name = "Action Able";
            public const string? Description = "Posible dot Net";
            public const string Code = "ACAB";
        }

        public static class CMSRapido
        {
            public const long Id = 17;
            public const string Name = "CMS Rapido";
            public const string? Description = "Filing of Rapido claims";
            public const string Code = "CMSR";
        }

        public static class Togetech1
        {
            public const long Id = 18;
            public const string Name = "Togetech";
            public const string? Description = "Togetech new integration";
            public const string Code = "TOGE";
        }

        public static class FortunePay
        {
            public const long Id = 19;
            public const string Name = "FortunePay";
            public const string? Description = "Fortune pay integration";
            public const string Code = "FPAY";
        }

        public static class Togetech2
        {
            public const long Id = 20;
            public const string Name = "Togetech";
            public const string? Description = "Togetech integration";
            public const string Code = "TOGT";
        }

        public static class IVAPlatform
        {
            public const long Id = 21;
            public const string Name = "IVA Platform";
            public const string? Description = "DJDPatricio Facebook Messenger AI Chatbot";
            public const string Code = "IVAP";
        }

        public static class GCash
        {
            public const long Id = 22;
            public const string Name = "GCash";
            public const string? Description = "GCash App";
            public const string Code = "GCSH";
        }

        public static class ProtectNow
        {
            public const long Id = 23;
            public const string Name = "ProtectNow";
            public const string? Description = "DJDPatricio Insurance Platform";
            public const string Code = "PNOW";
        }

        public static class CebXInsurance
        {
            public const long Id = 24;
            public const string Name = "CebX Insurance";
            public const string? Description = "Nano Insurance";
            public const string Code = "CEBX";
        }

        public static class CebOnTheGo
        {
            public const long Id = 25;
            public const string Name = "Ceb-OnTheGo";
            public const string? Description = "DJDPatricio On The Go Agent App";
            public const string Code = "COTG";
        }

        public static class IClick3Qgen
        {
            public const long Id = 26;
            public const string Name = "iClick 3.0 Qgen";
            public const string? Description = "Quotation Generator for iClick 3.0";
            public const string Code = "IC3Q";
        }

        public static class IMS3
        {
            public const long Id = 27;
            public const string Name = "IMS 3.0";
            public const string? Description = "Insurance Management System v3";
            public const string Code = "IMS3";
        }
    }

    public static class PolicyBookingStatus
    {
        public static class Approved
        {
            public const long Id = 1;
            public const string Name = "Approved";
            public const string? Description = null;
        }

        public static class Disapproved
        {
            public const long Id = 2;
            public const string Name = "Disapproved";
            public const string? Description = null;
        }

        public static class Pending
        {
            public const long Id = 3;
            public const string Name = "Pending";
            public const string? Description = null;
        }

        public static class Declined
        {
            public const long Id = 4;
            public const string Name = "Declined";
            public const string? Description = null;
        }

        public static class Quoted
        {
            public const long Id = 5;
            public const string Name = "Quoted";
            public const string? Description = null;
        }

        public static class Draft
        {
            public const long Id = 6;
            public const string Name = "Draft";
            public const string? Description = null;
        }

        public static class AutoApproved
        {
            public const long Id = 7;
            public const string Name = "Auto-Approved";
            public const string? Description = null;
        }
    }

    public static class PolicyType
    {
        public static class Individual
        {
            public const long Id = 1;
            public const string Name = "Individual";
            public const string? Description = null;
        }

        public static class Partner
        {
            public const long Id = 2;
            public const string Name = "Partner";
            public const string? Description = null;
        }

        public static class Group
        {
            public const long Id = 3;
            public const string Name = "Group";
            public const string? Description = null;
        }
    }

    public static class SelectionType
    {
        public static class ValidIdType
        {
            public const long Id = 1;
            public const string Name = "Valid Id Type";
            public const string? Description = null;
        }

        public static class Relationship
        {
            public const long Id = 2;
            public const string Name = "Relationship";
            public const string? Description = null;
        }

        public static class AccountType
        {
            public const long Id = 3;
            public const string Name = "Account Type";
            public const string? Description = null;
        }

        public static class PaymentOption
        {
            public const long Id = 4;
            public const string Name = "Payment Option";
            public const string? Description = null;
        }
    }
}
