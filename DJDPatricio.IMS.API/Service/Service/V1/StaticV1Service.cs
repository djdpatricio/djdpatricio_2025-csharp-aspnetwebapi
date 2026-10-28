using DJDPatricio.IMS.API.Helpers.Config;
using DJDPatricio.IMS.API.Models;
using DJDPatricio.IMS.API.Models.Result.Static;
using DJDPatricio.IMS.API.Repository.Interface.V1;
using DJDPatricio.IMS.API.Service.Interface.V1;

namespace DJDPatricio.IMS.API.Service.Service.V1;

public class StaticV1Service(IStaticV1Repository staticV1Repository) : IStaticV1Service
{
    public async Task<TransactionResult<IEnumerable<AddressRegion>>> GetAddressRegion(long? id, CancellationToken cancellationToken)
    {
        using var cts = CancellationTokenSource.CreateLinkedTokenSource(cancellationToken);
        cts.CancelAfter(TimeSpan.FromSeconds(SystemDefaultsConfig.Config.ApiTimeoutInSeconds));

        return await staticV1Repository.GetAddressRegion(id);
    }
    public async Task<TransactionResult<IEnumerable<AddressRegionDivision>>> GetAddressRegionDivision(long? id, long? regionId, CancellationToken cancellationToken)
    {
        using var cts = CancellationTokenSource.CreateLinkedTokenSource(cancellationToken);
        cts.CancelAfter(TimeSpan.FromSeconds(SystemDefaultsConfig.Config.ApiTimeoutInSeconds));

        return await staticV1Repository.GetAddressRegionDivision(id, regionId);
    }
    public async Task<TransactionResult<IEnumerable<AddressCountry>>> GetAddressCountry(long? id, long? regionDivisionId, CancellationToken cancellationToken)
    {
        using var cts = CancellationTokenSource.CreateLinkedTokenSource(cancellationToken);
        cts.CancelAfter(TimeSpan.FromSeconds(SystemDefaultsConfig.Config.ApiTimeoutInSeconds));

        return await staticV1Repository.GetAddressCountry(id, regionDivisionId);
    }
    public async Task<TransactionResult<IEnumerable<AddressCountryDivision>>> GetAddressCountryDivision(long? id, long? countryId, CancellationToken cancellationToken)
    {
        using var cts = CancellationTokenSource.CreateLinkedTokenSource(cancellationToken);
        cts.CancelAfter(TimeSpan.FromSeconds(SystemDefaultsConfig.Config.ApiTimeoutInSeconds));

        return await staticV1Repository.GetAddressCountryDivision(id, countryId);
    }
    public async Task<TransactionResult<IEnumerable<AddressState>>> GetAddressState(long? id, long? countryDivisionId, CancellationToken cancellationToken)
    {
        using var cts = CancellationTokenSource.CreateLinkedTokenSource(cancellationToken);
        cts.CancelAfter(TimeSpan.FromSeconds(SystemDefaultsConfig.Config.ApiTimeoutInSeconds));

        return await staticV1Repository.GetAddressState(id, countryDivisionId);
    }
    public async Task<TransactionResult<IEnumerable<AddressCity>>> GetAddressCity(long? id, long? stateId, CancellationToken cancellationToken)
    {
        using var cts = CancellationTokenSource.CreateLinkedTokenSource(cancellationToken);
        cts.CancelAfter(TimeSpan.FromSeconds(SystemDefaultsConfig.Config.ApiTimeoutInSeconds));

        return await staticV1Repository.GetAddressCity(id, stateId);
    }
    public async Task<TransactionResult<IEnumerable<AddressTown>>> GetAddressTown(long? id, long? cityId, CancellationToken cancellationToken)
    {
        using var cts = CancellationTokenSource.CreateLinkedTokenSource(cancellationToken);
        cts.CancelAfter(TimeSpan.FromSeconds(SystemDefaultsConfig.Config.ApiTimeoutInSeconds));

        return await staticV1Repository.GetAddressTown(id, cityId);
    }
}