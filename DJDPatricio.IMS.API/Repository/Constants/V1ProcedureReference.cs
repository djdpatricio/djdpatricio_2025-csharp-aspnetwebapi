namespace DJDPatricio.IMS.API.Repository.Constants;

public static class V1ProcedureReference
{
    public static class Static
	{
		public const string GetAddressCity = "[Static].[GetAddressCity]";
		public const string GetAddressCountry = "[Static].[GetAddressCountry]";
		public const string GetAddressCountryDivision = "[Static].[GetAddressCountryDivision]";
		public const string GetAddressRegion = "[Static].[GetAddressRegion]";
		public const string GetAddressRegionDivision = "[Static].[GetAddressRegionDivision]";
		public const string GetAddressState = "[Static].[GetAddressState]";
		public const string GetAddressTown = "[Static].[GetAddressTown]";
    }

    public static class Reference
    {
        public static class Get
        {
            public const string GetAgents = "[Reference].[GetAgents]";
            public const string GetApprovers = "[Reference].[GetApprovers]";
            public const string GetBenefits = "[Reference].[GetBenefits]";
            public const string GetClients = "[Reference].[GetClients]";
            public const string GetDeductibles = "[Reference].[GetDeductibles]";
            public const string GetDistributionChannel = "[Reference].[GetDistributionChannel]";
            public const string GetPartners = "[Reference].[GetPartners]";
            public const string GetProductBenefits = "[Reference].[GetProductBenefits]";
            public const string GetProductCategory = "[Reference].[GetProductCategory]";
            public const string GetProductDeductibles = "[Reference].[GetProductDeductibles]";
            public const string GetProductPremium = "[Reference].[GetProductPremium]";
            public const string GetProducts = "[Reference].[GetProducts]";
            public const string GetPromoManagers = "[Reference].[GetPromoManagers]";
            public const string GetPromoOfficers = "[Reference].[GetPromoOfficers]";
            public const string GetProviders = "[Reference].[GetProviders]";
            public const string GetSalesManagers = "[Reference].[GetSalesManagers]";
            public const string GetSelectionList = "[Reference].[GetSelectionList]";
            public const string GetSubAgents = "[Reference].[GetSubAgents]";
        }
    }

    public static class Transaction
    {
        public static class Get
        {
            public const string GetAttachments = "[Transaction].[GetAttachments]";
            public const string GetGroupPolicy = "[Transaction].[GetGroupPolicy]";
            public const string GetIndividualPolicy = "[Transaction].[GetIndividualPolicy]";
            public const string GetPartnerPolicy = "[Transaction].[GetPartnerPolicy]";
            public const string GetPolicyBeneficiary = "[Transaction].[GetPolicyBeneficiary]";
            public const string GetPolicyBenefits = "[Transaction].[GetPolicyBenefits]";
            public const string GetPolicyDeductibles = "[Transaction].[GetPolicyDeductibles]";
            public const string GetPolicyPayments = "[Transaction].[GetPolicyPayments]";

            public static class View
            {
                public const string GetAttachmentsView = "[Transaction].[GetAttachmentsView]";
                public const string GetGroupPolicyView = "[Transaction].[GetGroupPolicyView]";
                public const string GetIndividualPolicyView = "[Transaction].[GetIndividualPolicyView]";
                public const string GetPartnerPolicyView = "[Transaction].[GetPartnerPolicyView]";
                public const string GetPolicyBeneficiaryView = "[Transaction].[GetPolicyBeneficiaryView]";
                public const string GetPolicyBenefitsView = "[Transaction].[GetPolicyBenefitsView]";
                public const string GetPolicyDeductiblesView = "[Transaction].[GetPolicyDeductiblesView]";
                public const string GetPolicyPaymentsView = "[Transaction].[GetPolicyPaymentsView]";
            }
        }

        public static class Post
        {
            public const string PostAttachments = "[Transaction].[PostAttachments]";
            public const string PostGroupPolicy = "[Transaction].[PostGroupPolicy]";
            public const string PostIndividualPolicy = "[Transaction].[PostIndividualPolicy]";
            public const string PostPartnerPolicy = "[Transaction].[PostPartnerPolicy]";
            public const string PostPolicyBeneficiary = "[Transaction].[PostPolicyBeneficiary]";
            public const string PostPolicyBenefits = "[Transaction].[PostPolicyBenefits]";
            public const string PostPolicyDeductibles = "[Transaction].[PostPolicyDeductibles]";
            public const string PostPolicyPayments = "[Transaction].[PostPolicyPayments]";
        }

        public static class Put
        {
            public const string PutAttachments = "[Transaction].[PutAttachments]";
            public const string PutGroupPolicy = "[Transaction].[PutGroupPolicy]";
            public const string PutIndividualPolicy = "[Transaction].[PutIndividualPolicy]";
            public const string PutPartnerPolicy = "[Transaction].[PutPartnerPolicy]";
            public const string PutPolicyBeneficiary = "[Transaction].[PutPolicyBeneficiary]";
            public const string PutPolicyPayments = "[Transaction].[PutPolicyPayments]";
        }

    }

    public static class Dbo
    {
        public static class Get
        {
            public const string GetProductSummary = "[dbo].[GetProductSummary]";
            public const string GetTotalBookingPerStatus = "[dbo].[GetTotalBookingPerStatus]";
            public const string GetSummaryYearToYear = "[dbo].[GetSummaryYearToYear]";
        }

    }
}