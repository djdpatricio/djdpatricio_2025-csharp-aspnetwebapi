using System.Security.Claims;
using DJDPatricio.IMS.API.Models.Result;
using DJDPatricio.IMS.API.Models.Result.Custom;

namespace DJDPatricio.IMS.API.Helpers;

public static class GlobalFunctionsHelper
{
    public static User GetUser(HttpContext httpContext)
    {
        return new User
        {
            Id = long.Parse(httpContext.User.Claims.FirstOrDefault(c => c.Type == ClaimTypes.NameIdentifier)!.Value),
            Name = httpContext.User.Claims.FirstOrDefault(c => c.Type == ClaimTypes.Name)!.Value,
            Role = httpContext.User.Claims.FirstOrDefault(c => c.Type == ClaimTypes.Role)!.Value
        };
    }

    public static PagedResponse<TData> CreatePagedResponse<TData>(TData data, string totalRecordsMessage, object filters, int pageNumber, int pageSize)
    {
        long totalRecords = 0;
        if (totalRecordsMessage != MessageHelper.Success.Generic)
        {
            if (!long.TryParse(totalRecordsMessage, out totalRecords))
            {
                totalRecords = 0;
            }
        }

        long finalPageNumber = pageNumber;
        long finalPageSize = pageSize;

        if (finalPageSize == 0)
        {
            finalPageNumber = 1;
            finalPageSize = totalRecords;
            if (finalPageSize == 0)
            {
                finalPageSize = 1;
            }
        }
        else
        {
            switch (finalPageNumber)
            {
                case 0: 
                    var totalPages = (long)Math.Ceiling((decimal)totalRecords / finalPageSize);
                    finalPageNumber = (totalPages == 0) ? 1 : totalPages;
                    break;
                case < 1:
                    finalPageNumber = 1;
                    break;
            }

            if (totalRecords > 0 && finalPageSize > 0)
            {
                var maxValidPageNumber = (long)Math.Ceiling((decimal)totalRecords / finalPageSize);
                if (finalPageNumber > maxValidPageNumber)
                {
                    finalPageNumber = maxValidPageNumber == 0 ? 1 : maxValidPageNumber; // If no records, still page 1
                }
            }
        }

        var response = new PagedResponse<TData>
        {
            Data = data,
            TotalRecords = totalRecords,
            PageNumber = finalPageNumber,
            PageSize = finalPageSize,
            Filters = filters
        };

        return response;
    }
    public static string? ToCommaSeparatedString<T>(List<T>? list)
    {
        return list is not { Count: 0 } ? null : string.Join(",", list);
    }
}