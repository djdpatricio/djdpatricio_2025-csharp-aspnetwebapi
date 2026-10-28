namespace DJDPatricio.IMS.TESTS.MockData.Transaction;

public static class PolicyBeneficiary
{
    public static IEnumerable<API.Models.Result.Transaction.PolicyBeneficiary> PolicyBeneficiaryList() =>
    [
        new()
        {
            Id = 10,
            PolicyId = 1,
            PolicyTypeId = 1,
            FirstName = "Maria",
            MiddleName = "C",
            LastName = "Santos",
            Suffix = null,
            FullName = "Maria C. Santos",
            EmailAddress = "maria.santos@email.com",
            ContactNumber = "+639171234567",
            DateOfBirth = new DateTime(1985, 05, 15),
            Relationship = 7,
            CreatedBy = 500329,
            CreatedDateTime = new DateTime(2025, 06, 02, 0, 0, 0),
            ModifiedBy = 500329,
            ModifiedDateTime = new DateTime(2025, 06, 02, 0, 0, 0)
        },
        new()
        {
            Id = 11,
            PolicyId = 2,
            PolicyTypeId = 1,
            FirstName = "John",
            MiddleName = null,
            LastName = "Lim",
            Suffix = "Jr.",
            FullName = "John Lim Jr.",
            EmailAddress = "john.lim@email.com",
            ContactNumber = "+639189876543",
            DateOfBirth = new DateTime(1990, 11, 22),
            Relationship = 10,
            CreatedBy = 500329,
            CreatedDateTime = new DateTime(2025, 06, 02, 0, 0, 0),
            ModifiedBy = 500329,
            ModifiedDateTime = new DateTime(2025, 06, 02, 0, 0, 0)
        },
        new()
        {
            Id = 12,
            PolicyId = 1,
            PolicyTypeId = 2,
            FirstName = "Sophia",
            MiddleName = "R",
            LastName = "Gonzales",
            Suffix = null,
            FullName = "Sophia R. Gonzales",
            EmailAddress = "sophia.g@email.com",
            ContactNumber = "+639201122334",
            DateOfBirth = new DateTime(1978, 01, 30),
            Relationship = 13,
            CreatedBy = 500329,
            CreatedDateTime = new DateTime(2025, 06, 02, 0, 0, 0),
            ModifiedBy = 500329,
            ModifiedDateTime = new DateTime(2025, 06, 02, 0, 0, 0)
        },
        new()
        {
            Id = 13,
            PolicyId = 2,
            PolicyTypeId = 2,
            FirstName = "David",
            MiddleName = "M",
            LastName = "Reyes",
            Suffix = "III",
            FullName = "David M. Reyes III",
            EmailAddress = "david.r@email.com",
            ContactNumber = "+639165566778",
            DateOfBirth = new DateTime(2005, 08, 01),
            Relationship = 16,
            CreatedBy = 500329,
            CreatedDateTime = new DateTime(2025, 06, 02, 0, 0, 0),
            ModifiedBy = 500329,
            ModifiedDateTime = new DateTime(2025, 06, 02, 0, 0, 0)
        },
        new()
        {
            Id = 14,
            PolicyId = 8,
            PolicyTypeId = 3,
            FirstName = "Anna",
            MiddleName = null,
            LastName = "Cruz",
            Suffix = null,
            FullName = "Anna Cruz",
            EmailAddress = "anna.c@email.com",
            ContactNumber = "+639223344556",
            DateOfBirth = new DateTime(1962, 03, 10),
            Relationship = 18,
            CreatedBy = 500329,
            CreatedDateTime = new DateTime(2025, 06, 02, 0, 0, 0),
            ModifiedBy = 500329,
            ModifiedDateTime = new DateTime(2025, 06, 02, 0, 0, 0)
        },
        new()
        {
            Id = 15,
            PolicyId = 10, // Assuming this refers to an existing policy in another list, if not, adjust as needed.
            PolicyTypeId = 3,
            FirstName = "Michael",
            MiddleName = "J",
            LastName = "Tan",
            Suffix = null,
            FullName = "Michael J. Tan",
            EmailAddress = "michael.t@email.com",
            ContactNumber = "+639190099887",
            DateOfBirth = new DateTime(1995, 09, 28),
            Relationship = 20,
            CreatedBy = 500329,
            CreatedDateTime = new DateTime(2025, 06, 02, 0, 0, 0),
            ModifiedBy = 500329,
            ModifiedDateTime = new DateTime(2025, 06, 02, 0, 0, 0)
        },
        new()
        {
            Id = 16,
            PolicyId = 9, // Assuming this refers to an existing policy in another list, if not, adjust as needed.
            PolicyTypeId = 3,
            FirstName = "Ella",
            MiddleName = "P",
            LastName = "Ramos",
            Suffix = null,
            FullName = "Ella P. Ramos",
            EmailAddress = "ella.ramos@email.com",
            ContactNumber = "+639151239876",
            DateOfBirth = new DateTime(2000, 07, 25),
            Relationship = 12,
            CreatedBy = 500329,
            CreatedDateTime = new DateTime(2025, 06, 02, 0, 0, 0),
            ModifiedBy = 500329,
            ModifiedDateTime = new DateTime(2025, 06, 02, 0, 0, 0)
        }
    ];
}