using Asp.Versioning;
using DJDPatricio.IMS.API.Helpers;
using DJDPatricio.IMS.API.Helpers.Config;
using DJDPatricio.IMS.API.Models.Result.Dbo;
using DJDPatricio.IMS.API.Service.Interface.V1;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace DJDPatricio.IMS.API.Controllers;

[ApiController]
[Route("api/v{version:apiVersion}/dbo")]
[ApiVersion("1.0")]
[Authorize]

public class DboController(IDboV1Service dboV1Service) : ControllerBase
{
    [HttpGet("products-summary")]
    [ProducesResponseType(typeof(IEnumerable<ProductSummary>), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status408RequestTimeout)]
    [ProducesResponseType(StatusCodes.Status500InternalServerError)]
    public async Task<IActionResult> GetProductSummary()
    {
        if (!HttpContext.User.Identity!.IsAuthenticated)
        {
            return StatusCode(StatusCodes.Status401Unauthorized);
        }
        var endpointName = $"{HttpContext.Request.Method} {ControllerContext.ActionDescriptor.ActionName}";
        try
        {
            using var cts = new CancellationTokenSource();
            cts.CancelAfter(TimeSpan.FromSeconds(SystemDefaultsConfig.Config.ApiTimeoutInSeconds));
            var linkedToken = CancellationTokenSource.CreateLinkedTokenSource(HttpContext.RequestAborted, cts.Token).Token;

            var result = await dboV1Service.GetProductSummary(linkedToken);
            if (result.IsSuccess)
            {
                LogHelper.LoInformation(StatusCodes.Status200OK, endpointName, result.Message);
                return Ok(result.Data);
            }

            LogHelper.LogError(endpointName, result.Message, result.Exception);
            return StatusCode(StatusCodes.Status500InternalServerError);
        }
        catch (OperationCanceledException ex)
        {
            LogHelper.LogError(endpointName, ex);
            return StatusCode(StatusCodes.Status408RequestTimeout);
        }
    }

    [HttpGet("total-booking-per-status")]
    [ProducesResponseType(typeof(IEnumerable<TotalBookingPerStatus>), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status408RequestTimeout)]
    [ProducesResponseType(StatusCodes.Status500InternalServerError)]
    public async Task<IActionResult> GetTotalBookingPerStatus([FromQuery] StaticDataHelper.TimePeriodOption? timePeriodOption)
    {
        if (!HttpContext.User.Identity!.IsAuthenticated)
        {
            return StatusCode(StatusCodes.Status401Unauthorized);
        }
        var endpointName = $"{HttpContext.Request.Method} {ControllerContext.ActionDescriptor.ActionName}";
        try
        {
            using var cts = new CancellationTokenSource();
            cts.CancelAfter(TimeSpan.FromSeconds(SystemDefaultsConfig.Config.ApiTimeoutInSeconds));
            var linkedToken = CancellationTokenSource.CreateLinkedTokenSource(HttpContext.RequestAborted, cts.Token).Token;

            var result = await dboV1Service.GetTotalBookingPerStatus(timePeriodOption, linkedToken);
            if (result.IsSuccess)
            {
                LogHelper.LoInformation(StatusCodes.Status200OK, endpointName, result.Message);
                return Ok(result.Data);
            }

            LogHelper.LogError(endpointName, result.Message, result.Exception);
            return StatusCode(StatusCodes.Status500InternalServerError);
        }
        catch (OperationCanceledException ex)
        {
            LogHelper.LogError(endpointName, ex);
            return StatusCode(StatusCodes.Status408RequestTimeout);
        }
    }

    [HttpGet("summary-year-to-year")]
    [ProducesResponseType(typeof(IEnumerable<SummaryYearToYear>), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status408RequestTimeout)]
    [ProducesResponseType(StatusCodes.Status500InternalServerError)]
    public async Task<IActionResult> GetSummaryYearToYear()
    {
        if (!HttpContext.User.Identity!.IsAuthenticated)
        {
            return StatusCode(StatusCodes.Status401Unauthorized);
        }

        var endpointName = $"{HttpContext.Request.Method} {ControllerContext.ActionDescriptor.ActionName}";
        try
        {
            using var cts = new CancellationTokenSource();
            cts.CancelAfter(TimeSpan.FromSeconds(SystemDefaultsConfig.Config.ApiTimeoutInSeconds));
            var linkedToken = CancellationTokenSource.CreateLinkedTokenSource(HttpContext.RequestAborted, cts.Token)
                .Token;

            var result = await dboV1Service.GetSummaryYearToYear(linkedToken);
            if (result.IsSuccess)
            {
                LogHelper.LoInformation(StatusCodes.Status200OK, endpointName, result.Message);
                return Ok(result.Data);
            }

            LogHelper.LogError(endpointName, result.Message, result.Exception);
            return StatusCode(StatusCodes.Status500InternalServerError);
        }
        catch (OperationCanceledException ex)
        {
            LogHelper.LogError(endpointName, ex);
            return StatusCode(StatusCodes.Status408RequestTimeout);
        }
    }
    //Append Here
}