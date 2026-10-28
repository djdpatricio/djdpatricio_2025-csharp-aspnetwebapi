using System.Data;
using System.Reflection;
using DJDPatricio.IMS.API.Helpers.Config;
using DJDPatricio.IMS.API.Models;
using DJDPatricio.IMS.API.Repository.Interface;
using Microsoft.Data.SqlClient;

namespace DJDPatricio.IMS.API.Repository.Repository;

public class DbFactoryWrapperRepository : IDbFactoryWrapperRepository
{
    public async Task<TransactionResult<IEnumerable<T>>> ExecuteMultipleResultStoredProcedureAsync<T>(string storedProcedureName, object? parameters)
    {
        try
        {
            await using var connection = new SqlConnection(ConnectionStringsConfig.Config.DefaultConnection);
            await connection.OpenAsync();

            await using var command = connection.CreateCommand();
            command.CommandType = CommandType.StoredProcedure;
            command.CommandText = storedProcedureName;

            var storedProcParams = GetStoredProcedureParameters(storedProcedureName);
            if (parameters != null)
            {
                if (parameters is Dictionary<string, object> dict)
                {
                    foreach (var param in storedProcParams.Where(param => param.ParameterName != "@RETURN_VALUE"))
                    {
                        var parameterFound = false;
                        foreach (var keyValue in dict.Where(keyValue => string.Equals(keyValue.Key, param.ParameterName.TrimStart('@'),
                                     StringComparison.CurrentCultureIgnoreCase)))
                        {
                            command.Parameters.AddWithValue(param.ParameterName, keyValue.Value ?? DBNull.Value);
                            parameterFound = true;
                            break;
                        }
                        if (!parameterFound)
                        {
                            command.Parameters.AddWithValue(param.ParameterName, DBNull.Value);
                        }
                    }
                }
                else
                {
                    foreach (var param in storedProcParams.Where(param => param.ParameterName != "@RETURN_VALUE"))
                    {
                        var parameterProperties = parameters.GetType().GetProperties();
                        var parameterFound = false;
                        foreach (var prop in parameterProperties)
                        {
                            if (!string.Equals(prop.Name, param.ParameterName.TrimStart('@'), StringComparison.CurrentCultureIgnoreCase))
                                continue;
                            var value = prop.GetValue(parameters);
                            command.Parameters.AddWithValue(param.ParameterName, value ?? DBNull.Value);
                            parameterFound = true;
                            break;
                        }
                        if (!parameterFound)
                        {
                            command.Parameters.AddWithValue(param.ParameterName, DBNull.Value);
                        }
                    }

                }
            }

            var objType = typeof(T);
            var properties = objType.GetProperties(BindingFlags.Public | BindingFlags.Instance);

            var result = new List<T>();
            await using var reader = await command.ExecuteReaderAsync();

            while (await reader.ReadAsync())
            {
                var obj = Activator.CreateInstance<T>();
                foreach (var prop in properties)
                {
                    
                    if (prop.PropertyType != typeof(sbyte) && prop.PropertyType != typeof(sbyte?) &&
                        prop.PropertyType != typeof(byte) && prop.PropertyType != typeof(byte?) &&
                        prop.PropertyType != typeof(short) && prop.PropertyType != typeof(short?) &&
                        prop.PropertyType != typeof(ushort) && prop.PropertyType != typeof(ushort?) &&
                        prop.PropertyType != typeof(int) && prop.PropertyType != typeof(int?) &&
                        prop.PropertyType != typeof(uint) && prop.PropertyType != typeof(uint?) &&
                        prop.PropertyType != typeof(long) && prop.PropertyType != typeof(long?) &&
                        prop.PropertyType != typeof(ulong) && prop.PropertyType != typeof(ulong?) &&
                        prop.PropertyType != typeof(char) && prop.PropertyType != typeof(char?) &&
                        prop.PropertyType != typeof(float) && prop.PropertyType != typeof(float?) &&
                        prop.PropertyType != typeof(double) && prop.PropertyType != typeof(double?) &&
                        prop.PropertyType != typeof(decimal) && prop.PropertyType != typeof(decimal?) &&
                        prop.PropertyType != typeof(bool) && prop.PropertyType != typeof(bool?) &&
                        !prop.PropertyType.IsEnum && (Nullable.GetUnderlyingType(prop.PropertyType)?.IsEnum != true) &&
                        prop.PropertyType != typeof(string) && prop.PropertyType != typeof(byte[]) &&
                        prop.PropertyType != typeof(DateTime) && prop.PropertyType != typeof(DateTime?) &&
                        prop.PropertyType != typeof(TimeSpan) && prop.PropertyType != typeof(TimeSpan?))
                    {
                        continue;
                    }

                    var ordinal = reader.GetOrdinal(prop.Name);

                    if (!reader.IsDBNull(ordinal))
                    {
                        if (prop.PropertyType == typeof(DateTime))
                        {
                            var dbValue = reader.GetDateTime(ordinal);
                            prop.SetValue(obj, DateTime.SpecifyKind(dbValue, DateTimeKind.Utc));
                        }
                        else if (prop.PropertyType == typeof(DateTime?))
                        {
                            var dbValue = reader.GetDateTime(ordinal);
                            prop.SetValue(obj, (DateTime?)DateTime.SpecifyKind(dbValue, DateTimeKind.Utc));
                        }
                        else
                        {
                            var value = reader.GetValue(ordinal);
                            prop.SetValue(obj, value);
                        }
                    }
                    else if (Nullable.GetUnderlyingType(prop.PropertyType) != null || !prop.PropertyType.IsValueType)
                    {
                        prop.SetValue(obj, null);
                    }
                }
                result.Add(obj);
            }

            var hasAnotherResultSet = await reader.NextResultAsync();
            if (!hasAnotherResultSet) return TransactionResult<IEnumerable<T>>.Success(result);
            var totalRecords = "";
            if (await reader.ReadAsync())
            {
                totalRecords = reader[0].ToString() ?? "";
            }
            return TransactionResult<IEnumerable<T>>.Success(totalRecords, result);

        }
        catch (Exception ex)
        {
            return TransactionResult<IEnumerable<T>>.Failure(ex);
        }
    }
    public async Task<TransactionResult<T>> ExecuteSingleResultStoredProcedureAsync<T>(string storedProcedureName, object? parameters)
    {
        try
        {
            await using var connection = new SqlConnection(ConnectionStringsConfig.Config.DefaultConnection);
            await connection.OpenAsync();

            await using var command = connection.CreateCommand();
            command.CommandType = CommandType.StoredProcedure;
            command.CommandText = storedProcedureName;

            var storedProcParams = GetStoredProcedureParameters(storedProcedureName);
            if (parameters != null)
            {
                if (parameters is Dictionary<string, object> dict)
                {
                    foreach (var param in storedProcParams.Where(param => param.ParameterName != "@RETURN_VALUE"))
                    {
                        var parameterFound = false;
                        foreach (var keyValue in dict.Where(keyValue => string.Equals(keyValue.Key, param.ParameterName.TrimStart('@'),
                                     StringComparison.CurrentCultureIgnoreCase)))
                        {
                            command.Parameters.AddWithValue(param.ParameterName, keyValue.Value ?? DBNull.Value);
                            parameterFound = true;
                            break;
                        }
                        if (!parameterFound)
                        {
                            command.Parameters.AddWithValue(param.ParameterName, DBNull.Value);
                        }
                    }
                }
                else
                {
                    foreach (var param in storedProcParams.Where(param => param.ParameterName != "@RETURN_VALUE"))
                    {
                        var parameterProperties = parameters.GetType().GetProperties();
                        var parameterFound = false;
                        foreach (var prop in parameterProperties)
                        {
                            if (!string.Equals(prop.Name, param.ParameterName.TrimStart('@'), StringComparison.CurrentCultureIgnoreCase))
                                continue;
                            var value = prop.GetValue(parameters);
                            command.Parameters.AddWithValue(param.ParameterName, value ?? DBNull.Value);
                            parameterFound = true;
                            break;
                        }
                        if (!parameterFound)
                        {
                            command.Parameters.AddWithValue(param.ParameterName, DBNull.Value);
                        }
                    }

                }
            }

            var objType = typeof(T);
            var properties = objType.GetProperties(BindingFlags.Public | BindingFlags.Instance);

            var result = Activator.CreateInstance<T>();
            await using var reader = await command.ExecuteReaderAsync();
            if (!await reader.ReadAsync()) return TransactionResult<T>.Success(result);
            {
                foreach (var prop in properties)
                {
                    if (prop.PropertyType != typeof(sbyte) && prop.PropertyType != typeof(sbyte?) &&
                        prop.PropertyType != typeof(byte) && prop.PropertyType != typeof(byte?) &&
                        prop.PropertyType != typeof(short) && prop.PropertyType != typeof(short?) &&
                        prop.PropertyType != typeof(ushort) && prop.PropertyType != typeof(ushort?) &&
                        prop.PropertyType != typeof(int) && prop.PropertyType != typeof(int?) &&
                        prop.PropertyType != typeof(uint) && prop.PropertyType != typeof(uint?) &&
                        prop.PropertyType != typeof(long) && prop.PropertyType != typeof(long?) &&
                        prop.PropertyType != typeof(ulong) && prop.PropertyType != typeof(ulong?) &&
                        prop.PropertyType != typeof(char) && prop.PropertyType != typeof(char?) &&
                        prop.PropertyType != typeof(float) && prop.PropertyType != typeof(float?) &&
                        prop.PropertyType != typeof(double) && prop.PropertyType != typeof(double?) &&
                        prop.PropertyType != typeof(decimal) && prop.PropertyType != typeof(decimal?) &&
                        prop.PropertyType != typeof(bool) && prop.PropertyType != typeof(bool?) &&
                        !prop.PropertyType.IsEnum && (Nullable.GetUnderlyingType(prop.PropertyType)?.IsEnum != true) &&
                        prop.PropertyType != typeof(string) && prop.PropertyType != typeof(byte[]) &&
                        prop.PropertyType != typeof(DateTime) && prop.PropertyType != typeof(DateTime?) &&
                        prop.PropertyType != typeof(TimeSpan) && prop.PropertyType != typeof(TimeSpan?))
                    {
                        continue;
                    }
                    var ordinal = reader.GetOrdinal(prop.Name);

                    if (!reader.IsDBNull(ordinal))
                    {
                        if (prop.PropertyType == typeof(DateTime))
                        {
                            var dbValue = reader.GetDateTime(ordinal);
                            prop.SetValue(result, DateTime.SpecifyKind(dbValue, DateTimeKind.Utc));
                        }
                        else if (prop.PropertyType == typeof(DateTime?))
                        {
                            var dbValue = reader.GetDateTime(ordinal);
                            prop.SetValue(result, (DateTime?)DateTime.SpecifyKind(dbValue, DateTimeKind.Utc));
                        }
                        else
                        {
                            var value = reader.GetValue(ordinal);
                            prop.SetValue(result, value);
                        }
                    }
                    else if (Nullable.GetUnderlyingType(prop.PropertyType) != null || !prop.PropertyType.IsValueType)
                    {
                        prop.SetValue(result, null);
                    }
                }
            }
            return TransactionResult<T>.Success(result);
        }
        catch (Exception ex)
        {
            return TransactionResult<T>.Failure(ex);
        }
    }
    public async Task<TransactionResult> ExecuteStoredProcedureAsync(string storedProcedureName, object? parameters)
    {
        try
        {
            await using var connection = new SqlConnection(ConnectionStringsConfig.Config.DefaultConnection);
            await connection.OpenAsync();

            await using var command = connection.CreateCommand();
            command.CommandType = CommandType.StoredProcedure;
            command.CommandText = storedProcedureName;

            var storedProcParams = GetStoredProcedureParameters(storedProcedureName);
            if (parameters != null)
            {
                if (parameters is Dictionary<string, object> dict)
                {
                    foreach (var param in storedProcParams.Where(param => param.ParameterName != "@RETURN_VALUE"))
                    {
                        var parameterFound = false;
                        foreach (var keyValue in dict.Where(keyValue => string.Equals(keyValue.Key, param.ParameterName.TrimStart('@'),
                                     StringComparison.CurrentCultureIgnoreCase)))
                        {
                            command.Parameters.AddWithValue(param.ParameterName, keyValue.Value ?? DBNull.Value);
                            parameterFound = true;
                            break;
                        }
                        if (!parameterFound)
                        {
                            command.Parameters.AddWithValue(param.ParameterName, DBNull.Value);
                        }
                    }
                }
                else
                {
                    foreach (var param in storedProcParams.Where(param => param.ParameterName != "@RETURN_VALUE"))
                    {
                        var parameterProperties = parameters.GetType().GetProperties();
                        var parameterFound = false;
                        foreach (var prop in parameterProperties)
                        {
                            if (!string.Equals(prop.Name, param.ParameterName.TrimStart('@'), StringComparison.CurrentCultureIgnoreCase))
                                continue;
                            var value = prop.GetValue(parameters);
                            command.Parameters.AddWithValue(param.ParameterName, value ?? DBNull.Value);
                            parameterFound = true;
                            break;
                        }
                        if (!parameterFound)
                        {
                            command.Parameters.AddWithValue(param.ParameterName, DBNull.Value);
                        }
                    }

                }
            }

            await command.ExecuteNonQueryAsync();
            return TransactionResult.Success();
        }
        catch (Exception ex)
        {
            return TransactionResult.Failure(ex);
        }
    }
    public async Task<TransactionResult<IEnumerable<T>>> ExecuteMultipleResultQueryAsync<T>(string query)
    {
        try
        {
            await using var connection = new SqlConnection(ConnectionStringsConfig.Config.DefaultConnection);
            await connection.OpenAsync();

            await using var command = connection.CreateCommand();
            command.CommandText = query;

            var objType = typeof(T);
            var properties = objType.GetProperties(BindingFlags.Public | BindingFlags.Instance);

            var result = new List<T>();
            await using var reader = await command.ExecuteReaderAsync();

            while (await reader.ReadAsync())
            {
                var obj = Activator.CreateInstance<T>();
                foreach (var prop in properties)
                {
                    if (prop.PropertyType != typeof(sbyte) && prop.PropertyType != typeof(sbyte?) &&
                        prop.PropertyType != typeof(byte) && prop.PropertyType != typeof(byte?) &&
                        prop.PropertyType != typeof(short) && prop.PropertyType != typeof(short?) &&
                        prop.PropertyType != typeof(ushort) && prop.PropertyType != typeof(ushort?) &&
                        prop.PropertyType != typeof(int) && prop.PropertyType != typeof(int?) &&
                        prop.PropertyType != typeof(uint) && prop.PropertyType != typeof(uint?) &&
                        prop.PropertyType != typeof(long) && prop.PropertyType != typeof(long?) &&
                        prop.PropertyType != typeof(ulong) && prop.PropertyType != typeof(ulong?) &&
                        prop.PropertyType != typeof(char) && prop.PropertyType != typeof(char?) &&
                        prop.PropertyType != typeof(float) && prop.PropertyType != typeof(float?) &&
                        prop.PropertyType != typeof(double) && prop.PropertyType != typeof(double?) &&
                        prop.PropertyType != typeof(decimal) && prop.PropertyType != typeof(decimal?) &&
                        prop.PropertyType != typeof(bool) && prop.PropertyType != typeof(bool?) &&
                        !prop.PropertyType.IsEnum && (Nullable.GetUnderlyingType(prop.PropertyType)?.IsEnum != true) &&
                        prop.PropertyType != typeof(string) && prop.PropertyType != typeof(byte[]) &&
                        prop.PropertyType != typeof(DateTime) && prop.PropertyType != typeof(DateTime?) &&
                        prop.PropertyType != typeof(TimeSpan) && prop.PropertyType != typeof(TimeSpan?))
                    {
                        continue;
                    }
                    var ordinal = reader.GetOrdinal(prop.Name);

                    if (!reader.IsDBNull(ordinal))
                    {
                        if (prop.PropertyType == typeof(DateTime))
                        {
                            var dbValue = reader.GetDateTime(ordinal);
                            prop.SetValue(obj, DateTime.SpecifyKind(dbValue, DateTimeKind.Utc));
                        }
                        else if (prop.PropertyType == typeof(DateTime?))
                        {
                            var dbValue = reader.GetDateTime(ordinal);
                            prop.SetValue(obj, (DateTime?)DateTime.SpecifyKind(dbValue, DateTimeKind.Utc));
                        }
                        else
                        {
                            var value = reader.GetValue(ordinal);
                            prop.SetValue(obj, value);
                        }
                    }
                    else if (Nullable.GetUnderlyingType(prop.PropertyType) != null || !prop.PropertyType.IsValueType)
                    {
                        prop.SetValue(obj, null);
                    }
                }
                result.Add(obj);
            }

            var hasAnotherResultSet = await reader.NextResultAsync();
            if (!hasAnotherResultSet) return TransactionResult<IEnumerable<T>>.Success(result);
            var totalRecords = "";
            if (await reader.ReadAsync())
            {
                totalRecords = reader[0].ToString() ?? "";
            }
            return TransactionResult<IEnumerable<T>>.Success(totalRecords, result);
        }
        catch (Exception ex)
        {
            return TransactionResult<IEnumerable<T>>.Failure(ex);
        }
    }
    public async Task<TransactionResult<T>> ExecuteSingleResultQueryAsync<T>(string query)
    {
        try
        {
            await using var connection = new SqlConnection(ConnectionStringsConfig.Config.DefaultConnection);
            await connection.OpenAsync();

            await using var command = connection.CreateCommand();
            command.CommandText = query;

            var objType = typeof(T);
            var properties = objType.GetProperties(BindingFlags.Public | BindingFlags.Instance);

            var result = Activator.CreateInstance<T>();
            await using var reader = await command.ExecuteReaderAsync();
            if (!await reader.ReadAsync()) return TransactionResult<T>.Success(result);
            {
                foreach (var prop in properties)
                {
                    if (prop.PropertyType != typeof(sbyte) && prop.PropertyType != typeof(sbyte?) &&
                        prop.PropertyType != typeof(byte) && prop.PropertyType != typeof(byte?) &&
                        prop.PropertyType != typeof(short) && prop.PropertyType != typeof(short?) &&
                        prop.PropertyType != typeof(ushort) && prop.PropertyType != typeof(ushort?) &&
                        prop.PropertyType != typeof(int) && prop.PropertyType != typeof(int?) &&
                        prop.PropertyType != typeof(uint) && prop.PropertyType != typeof(uint?) &&
                        prop.PropertyType != typeof(long) && prop.PropertyType != typeof(long?) &&
                        prop.PropertyType != typeof(ulong) && prop.PropertyType != typeof(ulong?) &&
                        prop.PropertyType != typeof(char) && prop.PropertyType != typeof(char?) &&
                        prop.PropertyType != typeof(float) && prop.PropertyType != typeof(float?) &&
                        prop.PropertyType != typeof(double) && prop.PropertyType != typeof(double?) &&
                        prop.PropertyType != typeof(decimal) && prop.PropertyType != typeof(decimal?) &&
                        prop.PropertyType != typeof(bool) && prop.PropertyType != typeof(bool?) &&
                        !prop.PropertyType.IsEnum && (Nullable.GetUnderlyingType(prop.PropertyType)?.IsEnum != true) &&
                        prop.PropertyType != typeof(string) && prop.PropertyType != typeof(byte[]) &&
                        prop.PropertyType != typeof(DateTime) && prop.PropertyType != typeof(DateTime?) &&
                        prop.PropertyType != typeof(TimeSpan) && prop.PropertyType != typeof(TimeSpan?))
                    {
                        continue;
                    }
                    var ordinal = reader.GetOrdinal(prop.Name);

                    if (!reader.IsDBNull(ordinal))
                    {
                        if (prop.PropertyType == typeof(DateTime))
                        {
                            var dbValue = reader.GetDateTime(ordinal);
                            prop.SetValue(result, DateTime.SpecifyKind(dbValue, DateTimeKind.Utc));
                        }
                        else if (prop.PropertyType == typeof(DateTime?))
                        {
                            var dbValue = reader.GetDateTime(ordinal);
                            prop.SetValue(result, (DateTime?)DateTime.SpecifyKind(dbValue, DateTimeKind.Utc));
                        }
                        else
                        {
                            var value = reader.GetValue(ordinal);
                            prop.SetValue(result, value);
                        }
                    }
                    else if (Nullable.GetUnderlyingType(prop.PropertyType) != null || !prop.PropertyType.IsValueType)
                    {
                        prop.SetValue(result, null);
                    }
                }
            }
            return TransactionResult<T>.Success(result);
        }
        catch (Exception ex)
        {
            return TransactionResult<T>.Failure(ex);
        }
    }
    public async Task<TransactionResult> ExecuteQueryAsync(string query)
    {
        try
        {
            await using var connection = new SqlConnection(ConnectionStringsConfig.Config.DefaultConnection);
            await connection.OpenAsync();

            await using var command = connection.CreateCommand();
            command.CommandText = query;

            await command.ExecuteNonQueryAsync();
            return TransactionResult.Success();
        }
        catch (Exception ex)
        {
            return TransactionResult.Failure(ex);
        }
    }
    public List<SqlParameter> GetStoredProcedureParameters(string storedProcedureName)
    {
        using var conn = new SqlConnection(ConnectionStringsConfig.Config.DefaultConnection);
        using var cmd = new SqlCommand(storedProcedureName, conn);
        cmd.CommandType = CommandType.StoredProcedure;
        conn.Open();
        SqlCommandBuilder.DeriveParameters(cmd);
        return cmd.Parameters.Cast<SqlParameter>().ToList();
    }
}