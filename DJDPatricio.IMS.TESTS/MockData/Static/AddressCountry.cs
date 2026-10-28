namespace DJDPatricio.IMS.TESTS.MockData.Static;

public static class AddressCountry
{
    public static IEnumerable<API.Models.Result.Static.AddressCountry> AddressCountryList() =>
    [
        new()
        {
            AddressRegionDivisionId = 1,
            Name = "Philippines",
            Code = "PH",
            PhoneCode = "+63",
            TopLevelDomain = ".ph",
            Currency = "PHP",
            CurrencyName = "Philippine peso",
            Nationality = "Filipino",
            Id = 1,
        }
    ];
}