using Asp.Versioning;
using DJDPatricio.IMS.API.Helpers;
using DJDPatricio.IMS.API.Helpers.Config;
using DJDPatricio.IMS.API.Models.Result.Static;
using DJDPatricio.IMS.API.Service.Interface.V1;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace DJDPatricio.IMS.API.Controllers;

[ApiController]
[Route("api/v{version:apiVersion}/static")]
[ApiVersion("1.0")]
[Authorize]

public class StaticController(IStaticV1Service staticV1Service) : ControllerBase
{
    #region Address

    [HttpGet("address-region")]
    [ProducesResponseType(typeof(IEnumerable<AddressRegion>), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status408RequestTimeout)]
    [ProducesResponseType(StatusCodes.Status500InternalServerError)]
    public async Task<IActionResult> GetAddressRegion([FromQuery] long? id)
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

            var result = await staticV1Service.GetAddressRegion(id, linkedToken);
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

    [HttpGet("address-region-division")]
    [ProducesResponseType(typeof(IEnumerable<AddressRegionDivision>), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status408RequestTimeout)]
    [ProducesResponseType(StatusCodes.Status500InternalServerError)]
    public async Task<IActionResult> GetAddressRegionDivision([FromQuery] long? id, [FromQuery] long? regionId)
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

            var result = await staticV1Service.GetAddressRegionDivision(id, regionId, linkedToken);
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

    [HttpGet("address-country")]
    [ProducesResponseType(typeof(IEnumerable<AddressCountry>), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status408RequestTimeout)]
    [ProducesResponseType(StatusCodes.Status500InternalServerError)]
    public async Task<IActionResult> GetAddressCountry([FromQuery] long? id, [FromQuery] long? regionDivisionId)
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

            var result = await staticV1Service.GetAddressCountry(id, regionDivisionId, linkedToken);
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

    [HttpGet("address-country-division")]
    [ProducesResponseType(typeof(IEnumerable<AddressCountryDivision>), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status408RequestTimeout)]
    [ProducesResponseType(StatusCodes.Status500InternalServerError)]
    public async Task<IActionResult> GetAddressCountryDivision([FromQuery] long? id, [FromQuery] long? countryId)
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

            var result = await staticV1Service.GetAddressCountryDivision(id, countryId, linkedToken);
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

    [HttpGet("address-state")]
    [ProducesResponseType(typeof(IEnumerable<AddressState>), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status408RequestTimeout)]
    [ProducesResponseType(StatusCodes.Status500InternalServerError)]
    public async Task<IActionResult> GetAddressState([FromQuery] long? id, [FromQuery] long? countryDivisionId)
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

            var result = await staticV1Service.GetAddressState(id, countryDivisionId, linkedToken);
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

    [HttpGet("address-city")]
    [ProducesResponseType(typeof(IEnumerable<AddressCity>), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status408RequestTimeout)]
    [ProducesResponseType(StatusCodes.Status500InternalServerError)]
    public async Task<IActionResult> GetAddressCity([FromQuery] long? id, [FromQuery] long? stateId)
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

            var result = await staticV1Service.GetAddressCity(id, stateId, linkedToken);
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

    [HttpGet("address-town")]
    [ProducesResponseType(typeof(IEnumerable<AddressTown>), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status408RequestTimeout)]
    [ProducesResponseType(StatusCodes.Status500InternalServerError)]
    public async Task<IActionResult> GetAddressTown([FromQuery] long? id, [FromQuery] long? cityId)
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

            var result = await staticV1Service.GetAddressTown(id, cityId, linkedToken);
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

    #endregion

    //Append Here
}