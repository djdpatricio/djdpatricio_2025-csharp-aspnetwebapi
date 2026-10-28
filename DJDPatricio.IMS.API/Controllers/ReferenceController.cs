using Asp.Versioning;
using DJDPatricio.IMS.API.Helpers;
using DJDPatricio.IMS.API.Helpers.Config;
using DJDPatricio.IMS.API.Models.Result.Reference;
using DJDPatricio.IMS.API.Service.Interface.V1;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace DJDPatricio.IMS.API.Controllers;

[ApiController]
[Route("api/v{version:apiVersion}/reference")]
[ApiVersion("1.0")]
[Authorize]

public class ReferenceController(IReferenceV1Service referenceV1Service) : ControllerBase
{
    [HttpGet("agents")]
    [ProducesResponseType(typeof(IEnumerable<Agents>), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status408RequestTimeout)]
    [ProducesResponseType(StatusCodes.Status500InternalServerError)]
    public async Task<IActionResult> GetAgents([FromQuery] long? id, bool? isActiveOnly, string? MCOrAgentId, long? mandatoryId)
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

            // Service call updated to match the new parameter order (CancellationToken is last)
            var result = await referenceV1Service.GetAgents(id, isActiveOnly, MCOrAgentId, mandatoryId, linkedToken);
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

    [HttpGet("approvers")]
    [ProducesResponseType(typeof(IEnumerable<Approvers>), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status408RequestTimeout)]
    [ProducesResponseType(StatusCodes.Status500InternalServerError)]
    public async Task<IActionResult> GetApprovers([FromQuery] long? id, bool? isActiveOnly, string? MCOrAgentId, long? mandatoryId)
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

            // Service call updated to match the new parameter order (CancellationToken is last)
            var result = await referenceV1Service.GetApprovers(id, isActiveOnly, MCOrAgentId, mandatoryId, linkedToken);
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

    [HttpGet("benefits")]
    [ProducesResponseType(typeof(IEnumerable<Benefits>), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status408RequestTimeout)]
    [ProducesResponseType(StatusCodes.Status500InternalServerError)]
    public async Task<IActionResult> GetBenefits([FromQuery] long? id, bool? isActiveOnly, long? mandatoryId)
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

            // Service call updated to match the new parameter order (CancellationToken is last)
            var result = await referenceV1Service.GetBenefits(id, isActiveOnly, mandatoryId, linkedToken);
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

    [HttpGet("clients")]
    [ProducesResponseType(typeof(IEnumerable<Clients>), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status408RequestTimeout)]
    [ProducesResponseType(StatusCodes.Status500InternalServerError)]
    public async Task<IActionResult> GetClients([FromQuery] long? id, bool? isActiveOnly, string? insuranceCustomerNo, long? mandatoryId)
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

            // Service call updated to match the new parameter order (CancellationToken is last)
            var result = await referenceV1Service.GetClients(id, isActiveOnly, insuranceCustomerNo, mandatoryId, linkedToken);
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

    [HttpGet("deductibles")]
    [ProducesResponseType(typeof(IEnumerable<Deductibles>), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status408RequestTimeout)]
    [ProducesResponseType(StatusCodes.Status500InternalServerError)]
    public async Task<IActionResult> GetDeductibles([FromQuery] long? id, bool? isActiveOnly, long? mandatoryId)
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

            // Service call updated to match the new parameter order (CancellationToken is last)
            var result = await referenceV1Service.GetDeductibles(id, isActiveOnly, mandatoryId, linkedToken);
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

    [HttpGet("distribution-channel")]
    [ProducesResponseType(typeof(IEnumerable<DistributionChannel>), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status408RequestTimeout)]
    [ProducesResponseType(StatusCodes.Status500InternalServerError)]
    public async Task<IActionResult> GetDistributionChannel([FromQuery] long? id, bool? isActiveOnly, long? mandatoryId)
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

            // Service call updated to match the new parameter order (CancellationToken is last)
            var result = await referenceV1Service.GetDistributionChannel(id, isActiveOnly, mandatoryId, linkedToken);
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

    [HttpGet("partners")]
    [ProducesResponseType(typeof(IEnumerable<Partners>), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status408RequestTimeout)]
    [ProducesResponseType(StatusCodes.Status500InternalServerError)]
    public async Task<IActionResult> GetPartners([FromQuery] long? id, bool? isActiveOnly, long? mandatoryId)
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

            // Service call updated to match the new parameter order (CancellationToken is last)
            var result = await referenceV1Service.GetPartners(id, isActiveOnly, mandatoryId, linkedToken);
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

    [HttpGet("product-benefits")]
    [ProducesResponseType(typeof(IEnumerable<ProductBenefits>), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status408RequestTimeout)]
    [ProducesResponseType(StatusCodes.Status500InternalServerError)]
    public async Task<IActionResult> GetProductBenefits([FromQuery] long? id, bool? isActiveOnly, long? productsId, long? mandatoryId)
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

            // Service call updated to match the new parameter order (CancellationToken is last)
            var result = await referenceV1Service.GetProductBenefits(id, isActiveOnly, productsId, mandatoryId, linkedToken);
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

    [HttpGet("product-category")]
    [ProducesResponseType(typeof(IEnumerable<ProductCategory>), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status408RequestTimeout)]
    [ProducesResponseType(StatusCodes.Status500InternalServerError)]
    public async Task<IActionResult> GetProductCategory([FromQuery] long? id, bool? isActiveOnly, long? mandatoryId)
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

            // Service call updated to match the new parameter order (CancellationToken is last)
            var result = await referenceV1Service.GetProductCategory(id, isActiveOnly, mandatoryId, linkedToken);
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

    [HttpGet("product-deductibles")]
    [ProducesResponseType(typeof(IEnumerable<ProductDeductibles>), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status408RequestTimeout)]
    [ProducesResponseType(StatusCodes.Status500InternalServerError)]
    public async Task<IActionResult> GetProductDeductibles([FromQuery] long? id, bool? isActiveOnly, long? productsId, long? mandatoryId)
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

            // Service call updated to match the new parameter order (CancellationToken is last)
            var result = await referenceV1Service.GetProductDeductibles(id, isActiveOnly, productsId, mandatoryId, linkedToken);
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

    [HttpGet("product-premium")]
    [ProducesResponseType(typeof(IEnumerable<ProductPremium>), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status408RequestTimeout)]
    [ProducesResponseType(StatusCodes.Status500InternalServerError)]
    public async Task<IActionResult> GetProductPremium([FromQuery] long? id, bool? isActiveOnly, long? productsId, long? mandatoryId)
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

            // Service call updated to match the new parameter order (CancellationToken is last)
            var result = await referenceV1Service.GetProductPremium(id, isActiveOnly, productsId, mandatoryId, linkedToken);
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

    [HttpGet("products")]
    [ProducesResponseType(typeof(IEnumerable<Products>), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status408RequestTimeout)]
    [ProducesResponseType(StatusCodes.Status500InternalServerError)]
    public async Task<IActionResult> GetProducts([FromQuery] long? id, bool? isActiveOnly, long? productCategoryId, long? mandatoryId)
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

            // Service call updated to match the new parameter order (CancellationToken is last)
            var result = await referenceV1Service.GetProducts(id, isActiveOnly, productCategoryId, mandatoryId, linkedToken);
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

    [HttpGet("promo-managers")]
    [ProducesResponseType(typeof(IEnumerable<PromoManagers>), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status408RequestTimeout)]
    [ProducesResponseType(StatusCodes.Status500InternalServerError)]
    public async Task<IActionResult> GetPromoManagers([FromQuery] long? id, bool? isActiveOnly, string? MCOrAgentId, long? agentsId, long? mandatoryId)
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

            // Service call updated to match the new parameter order (CancellationToken is last)
            var result = await referenceV1Service.GetPromoManagers(id, isActiveOnly, MCOrAgentId, agentsId, mandatoryId, linkedToken);
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

    [HttpGet("promo-officers")]
    [ProducesResponseType(typeof(IEnumerable<PromoOfficers>), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status408RequestTimeout)]
    [ProducesResponseType(StatusCodes.Status500InternalServerError)]
    public async Task<IActionResult> GetPromoOfficers([FromQuery] long? id, bool? isActiveOnly, string? MCOrAgentId, long? agentsId, long? mandatoryId)
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

            // Service call updated to match the new parameter order (CancellationToken is last)
            var result = await referenceV1Service.GetPromoOfficers(id, isActiveOnly, MCOrAgentId, agentsId, mandatoryId, linkedToken);
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

    [HttpGet("providers")]
    [ProducesResponseType(typeof(IEnumerable<Providers>), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status408RequestTimeout)]
    [ProducesResponseType(StatusCodes.Status500InternalServerError)]
    public async Task<IActionResult> GetProviders([FromQuery] long? id, bool? isActiveOnly, long? mandatoryId)
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

            // Service call updated to match the new parameter order (CancellationToken is last)
            var result = await referenceV1Service.GetProviders(id, isActiveOnly, mandatoryId, linkedToken);
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

    [HttpGet("sales-managers")]
    [ProducesResponseType(typeof(IEnumerable<SalesManagers>), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status408RequestTimeout)]
    [ProducesResponseType(StatusCodes.Status500InternalServerError)]
    public async Task<IActionResult> GetSalesManagers([FromQuery] long? id, bool? isActiveOnly, string? MCOrAgentId, long? agentsId, long? mandatoryId)
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

            // Service call updated to match the new parameter order (CancellationToken is last)
            var result = await referenceV1Service.GetSalesManagers(id, isActiveOnly, MCOrAgentId, agentsId, mandatoryId, linkedToken);
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

    [HttpGet("selection-list")]
    [ProducesResponseType(typeof(IEnumerable<SelectionList>), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status408RequestTimeout)]
    [ProducesResponseType(StatusCodes.Status500InternalServerError)]
    public async Task<IActionResult> GetSelectionList([FromQuery] long? id, bool? isActiveOnly, long? selectionTypeId, long? mandatoryId)
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

            // Service call updated to match the new parameter order (CancellationToken is last)
            var result = await referenceV1Service.GetSelectionList(id, isActiveOnly, selectionTypeId, mandatoryId, linkedToken);
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

    [HttpGet("sub-agents")]
    [ProducesResponseType(typeof(IEnumerable<SubAgents>), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status408RequestTimeout)]
    [ProducesResponseType(StatusCodes.Status500InternalServerError)]
    public async Task<IActionResult> GetSubAgents([FromQuery] long? id, bool? isActiveOnly, string? MCOrAgentId, long? mandatoryId)
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

            // Service call updated to match the new parameter order (CancellationToken is last)
            var result = await referenceV1Service.GetSubAgents(id, isActiveOnly, MCOrAgentId, mandatoryId, linkedToken);
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