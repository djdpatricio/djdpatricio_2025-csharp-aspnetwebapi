namespace DJDPatricio.IMS.TESTS.MockData.Static;

public static class AddressRegion
{
    public static IEnumerable<API.Models.Result.Static.AddressRegion> AddressRegionList() =>
    [
        new()
        {
            Name = "Asia",
            Code = "AS",
            Id = 1,
        }
    ];
}