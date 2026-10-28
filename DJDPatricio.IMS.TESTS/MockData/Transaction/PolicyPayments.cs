namespace DJDPatricio.IMS.TESTS.MockData.Transaction;

public static class PolicyPayments
{
    public static IEnumerable<API.Models.Result.Transaction.PolicyPayments> PolicyPaymentsList() =>
    [
        new()
        {
            Id = 1,
            PolicyId = 1,
            PolicyTypeId = 1,
            Amount = 645.17m,
            TransactionDateTime = new DateTime(2025, 06, 07, 08, 04, 12, 176),
            TransactionCheckNo = "CHK12345",
            TransactionOrigin = "Online",
            NotificationDateTime = new DateTime(2025, 06, 01, 08, 04, 12, 176),
            PaymentMethod = 27,
            Notes = null,
            CreatedBy = 500329,
            CreatedDateTime = new DateTime(2025, 06, 02, 0, 0, 0),
            ModifiedBy = 500329,
            ModifiedDateTime = new DateTime(2025, 06, 02, 0, 0, 0)
        },
        new()
        {
            Id = 2,
            PolicyId = 2,
            PolicyTypeId = 1,
            Amount = 645.17m,
            TransactionDateTime = new DateTime(2025, 06, 07, 08, 04, 12, 176),
            TransactionCheckNo = "CHK12346",
            TransactionOrigin = "Branch",
            NotificationDateTime = new DateTime(2025, 06, 12, 08, 04, 12, 176),
            PaymentMethod = 28,
            Notes = "Cash payment received",
            CreatedBy = 500329,
            CreatedDateTime = new DateTime(2025, 06, 02, 0, 0, 0),
            ModifiedBy = 500329,
            ModifiedDateTime = new DateTime(2025, 06, 02, 0, 0, 0)
        },
        new()
        {
            Id = 3,
            PolicyId = 1,
            PolicyTypeId = 2,
            Amount = 645.17m,
            TransactionDateTime = new DateTime(2025, 06, 07, 08, 04, 12, 176),
            TransactionCheckNo = "CHK12347",
            TransactionOrigin = "Agent",
            NotificationDateTime = new DateTime(2025, 05, 26, 08, 04, 12, 176),
            PaymentMethod = 29,
            Notes = null,
            CreatedBy = 500329,
            CreatedDateTime = new DateTime(2025, 06, 02, 0, 0, 0),
            ModifiedBy = 500329,
            ModifiedDateTime = new DateTime(2025, 06, 02, 0, 0, 0)
        },
        new()
        {
            Id = 4,
            PolicyId = 2,
            PolicyTypeId = 2,
            Amount = 645.17m,
            TransactionDateTime = new DateTime(2025, 06, 07, 08, 04, 12, 176),
            TransactionCheckNo = "CHK12348",
            TransactionOrigin = "Online",
            NotificationDateTime = new DateTime(2025, 06, 20, 08, 04, 12, 176),
            PaymentMethod = 30,
            Notes = "Via mobile app",
            CreatedBy = 500329,
            CreatedDateTime = new DateTime(2025, 06, 02, 0, 0, 0),
            ModifiedBy = 500329,
            ModifiedDateTime = new DateTime(2025, 06, 02, 0, 0, 0)
        },
        new()
        {
            Id = 5,
            PolicyId = 8,
            PolicyTypeId = 3,
            Amount = 645.17m,
            TransactionDateTime = new DateTime(2025, 06, 07, 08, 04, 12, 176),
            TransactionCheckNo = "CHK12349",
            TransactionOrigin = "Branch",
            NotificationDateTime = new DateTime(2025, 06, 11, 08, 04, 12, 176),
            PaymentMethod = 31,
            Notes = null,
            CreatedBy = 500329,
            CreatedDateTime = new DateTime(2025, 06, 02, 0, 0, 0),
            ModifiedBy = 500329,
            ModifiedDateTime = new DateTime(2025, 06, 02, 0, 0, 0)
        },
        new()
        {
            Id = 6,
            PolicyId = 9,
            PolicyTypeId = 3,
            Amount = 645.17m,
            TransactionDateTime = new DateTime(2025, 06, 07, 08, 04, 12, 176),
            TransactionCheckNo = "CHK12350",
            TransactionOrigin = "CallCenter",
            NotificationDateTime = new DateTime(2025, 06, 01, 08, 04, 12, 176),
            PaymentMethod = 32,
            Notes = "Phone payment",
            CreatedBy = 500329,
            CreatedDateTime = new DateTime(2025, 06, 02, 0, 0, 0),
            ModifiedBy = 500329,
            ModifiedDateTime = new DateTime(2025, 06, 02, 0, 0, 0)
        },
        new()
        {
            Id = 7,
            PolicyId = 10,
            PolicyTypeId = 3,
            Amount = 645.17m,
            TransactionDateTime = new DateTime(2025, 06, 07, 08, 04, 12, 176),
            TransactionCheckNo = "CHK12351",
            TransactionOrigin = "Online",
            NotificationDateTime = new DateTime(2025, 06, 20, 08, 04, 12, 176),
            PaymentMethod = 33,
            Notes = "Autopay successful",
            CreatedBy = 500329,
            CreatedDateTime = new DateTime(2025, 06, 02, 0, 0, 0),
            ModifiedBy = 500329,
            ModifiedDateTime = new DateTime(2025, 06, 02, 0, 0, 0)
        }
    ];
}