using DJDPatricio.IMS.API.Models;
using DJDPatricio.IMS.API.Models.Result.Static;

namespace DJDPatricio.IMS.API.Repository.Interface.V1;

public interface IStaticV1Repository
{
    Task<TransactionResult<IEnumerable<AddressRegion>>> GetAddressRegion(long? id);
    Task<TransactionResult<IEnumerable<AddressRegionDivision>>> GetAddressRegionDivision(long? id, long? regionId);
    Task<TransactionResult<IEnumerable<AddressCountry>>> GetAddressCountry(long? id, long? regionDivisionId);
    Task<TransactionResult<IEnumerable<AddressCountryDivision>>> GetAddressCountryDivision(long? id, long? countryId);
    Task<TransactionResult<IEnumerable<AddressState>>> GetAddressState(long? id, long? countryDivisionId);
    Task<TransactionResult<IEnumerable<AddressCity>>> GetAddressCity(long? id, long? stateId);
    Task<TransactionResult<IEnumerable<AddressTown>>> GetAddressTown(long? id, long? cityId);
}