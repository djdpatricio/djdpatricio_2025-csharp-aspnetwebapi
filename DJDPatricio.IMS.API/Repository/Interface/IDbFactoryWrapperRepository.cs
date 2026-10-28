using DJDPatricio.IMS.API.Models;

namespace DJDPatricio.IMS.API.Repository.Interface;

public interface IDbFactoryWrapperRepository
{
    Task<TransactionResult<IEnumerable<T>>> ExecuteMultipleResultStoredProcedureAsync<T>(string storedProcedureName,object? parameters);
    Task<TransactionResult<T>> ExecuteSingleResultStoredProcedureAsync<T>(string storedProcedureName, object? parameters);
    Task<TransactionResult> ExecuteStoredProcedureAsync(string storedProcedureName, object? parameters);
    Task<TransactionResult<IEnumerable<T>>> ExecuteMultipleResultQueryAsync<T>(string query);
    Task<TransactionResult<T>> ExecuteSingleResultQueryAsync<T>(string query);
    Task<TransactionResult> ExecuteQueryAsync(string query);
}