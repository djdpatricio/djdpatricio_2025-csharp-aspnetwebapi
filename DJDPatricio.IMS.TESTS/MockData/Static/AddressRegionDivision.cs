namespace DJDPatricio.IMS.TESTS.MockData.Static;

public static class AddressRegionDivision
{
    public static IEnumerable<API.Models.Result.Static.AddressRegionDivision> AddressRegionDivisionList() =>
    [
        new()
        {
            AddressRegionId = 1,
            Name = "Southeast",
            Code = "SE",
            Id = 1,
        }
    ];
}