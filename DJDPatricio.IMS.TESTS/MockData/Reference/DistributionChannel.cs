namespace DJDPatricio.IMS.TESTS.MockData.Reference;

public static class DistributionChannel
{
    public static IEnumerable<API.Models.Result.Reference.DistributionChannel> DistributionChannelList() =>
    [
        new()
        {
            Id = 1,
            Name = "Captive - MC Branch",
            Description = "Insurance Clients directly related to PJLI employees, Owners and sales via MC branches",
            Code = "CCLB",
            IsActive = true,
            CreatedBy = null,
            CreatedDateTime = new DateTime(2025, 06, 02, 0, 0, 0),
            ModifiedBy = null,
            ModifiedDateTime = new DateTime(2025, 06, 02, 0, 0, 0),
        },
        new()
        {
            Id = 2,
            Name = "Captive - MC Digital",
            Description = "Insurance Clients directly solicited through MasterConnoisseurs Digital Channels",
            Code = "CCLD",
            IsActive = true,
            CreatedBy = null,
            CreatedDateTime = new DateTime(2025, 06, 02, 0, 0, 0),
            ModifiedBy = null,
            ModifiedDateTime = new DateTime(2025, 06, 02, 0, 0, 0),
        },
        new()
        {
            Id = 3,
            Name = "Captive - MC Affiliates",
            Description = "Insurance Clients directly solicited by affiliated companies of PJLI",
            Code = "CCLA",
            IsActive = true,
            CreatedBy = null,
            CreatedDateTime = new DateTime(2025, 06, 02, 0, 0, 0),
            ModifiedBy = null,
            ModifiedDateTime = new DateTime(2025, 06, 02, 0, 0, 0),
        },
        new()
        {
            Id = 4,
            Name = "Semi-Captive",
            Description =
                "Insurance Clients directly solicited or referred by employees of PJLI and its affiliated companies",
            Code = "SCAP",
            IsActive = true,
            CreatedBy = null,
            CreatedDateTime = new DateTime(2025, 06, 02, 0, 0, 0),
            ModifiedBy = null,
            ModifiedDateTime = new DateTime(2025, 06, 02, 0, 0, 0),
        },
        new()
        {
            Id = 5,
            Name = "Non-Captive Agents",
            Description = "Insurance Clients directly solicited by registered agents of MC",
            Code = "NCPA",
            IsActive = true,
            CreatedBy = null,
            CreatedDateTime = new DateTime(2025, 06, 02, 0, 0, 0),
            ModifiedBy = null,
            ModifiedDateTime = new DateTime(2025, 06, 02, 0, 0, 0),
        },
        new()
        {
            Id = 6,
            Name = "Non-Captive Digital",
            Description = "Insurance Clients directly solicited through Digital partnership",
            Code = "NCPD",
            IsActive = true,
            CreatedBy = null,
            CreatedDateTime = new DateTime(2025, 06, 02, 0, 0, 0),
            ModifiedBy = null,
            ModifiedDateTime = new DateTime(2025, 06, 02, 0, 0, 0),
        },
        new()
        {
            Id = 7,
            Name = "ADC - Mall Branches",
            Description = null,
            Code = "CLIS",
            IsActive = true,
            CreatedBy = null,
            CreatedDateTime = new DateTime(2025, 06, 02, 0, 0, 0),
            ModifiedBy = null,
            ModifiedDateTime = new DateTime(2025, 06, 02, 0, 0, 0),
        },
        new()
        {
            Id = 8,
            Name = "ADC2 - Mall Branches",
            Description = null,
            Code = "MC",
            IsActive = true,
            CreatedBy = null,
            CreatedDateTime = new DateTime(2025, 06, 02, 0, 0, 0),
            ModifiedBy = null,
            ModifiedDateTime = new DateTime(2025, 06, 02, 0, 0, 0),
        },
        new()
        {
            Id = 10,
            Name = "BR Semi-Captive",
            Description = null,
            Code = "SCBR",
            IsActive = true,
            CreatedBy = null,
            CreatedDateTime = new DateTime(2025, 06, 02, 0, 0, 0),
            ModifiedBy = null,
            ModifiedDateTime = new DateTime(2025, 06, 02, 0, 0, 0),
        },
    ];
}