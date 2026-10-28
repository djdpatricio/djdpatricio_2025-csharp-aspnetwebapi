using Asp.Versioning;
using DJDPatricio.IMS.API.Helpers;
using DJDPatricio.IMS.API.Helpers.Config;
using DJDPatricio.IMS.API.Models.Request.Post;
using DJDPatricio.IMS.API.Models.Request.Put;
using DJDPatricio.IMS.API.Models.Result.Custom;
using DJDPatricio.IMS.API.Models.Result.Transaction;
using DJDPatricio.IMS.API.Repository.Interface.V1;
using DJDPatricio.IMS.API.Service.Interface.V1;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace DJDPatricio.IMS.API.Controllers;

[ApiController]
[Route("api/v{version:apiVersion}/transaction")]
[ApiVersion("1.0")]
[Authorize]

public class TransactionController(ITransactionV1Service transactionV1Service, ITransactionV1Repository transactionV1Repository, IReferenceV1Repository referenceV1Repository) : ControllerBase
{
    #region Attachments

    [HttpGet("attachments")]
    [ProducesResponseType(typeof(IEnumerable<Attachments>), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status408RequestTimeout)]
    [ProducesResponseType(StatusCodes.Status500InternalServerError)]
    public async Task<IActionResult> GetAttachments([FromQuery] long? id, long? referenceId, long? attachmentTypeId, int pageNumber = 1, int pageSize = 10)
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

            var result = await transactionV1Service.GetAttachments(id, referenceId, attachmentTypeId, linkedToken, pageNumber, pageSize);
            if (result.IsSuccess)
            {
                var filters = new
                {
                    Id = id,
                    ReferenceId = referenceId,
                    AttachmentTypeId = attachmentTypeId
                };
                var response = GlobalFunctionsHelper.CreatePagedResponse(result.Data!, result.Message, filters, pageNumber, pageSize);
                LogHelper.LoInformation(StatusCodes.Status200OK, endpointName, MessageHelper.Success.Generic);
                return Ok(response);
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

    [HttpGet("attachments-view")]
    [ProducesResponseType(typeof(IEnumerable<AttachmentsView>), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status408RequestTimeout)]
    [ProducesResponseType(StatusCodes.Status500InternalServerError)]
    public async Task<IActionResult> GetAttachmentsView([FromQuery] long? id, long? referenceId, long? attachmentTypeId, int pageNumber = 1, int pageSize = 10)
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

            var result = await transactionV1Service.GetAttachmentsView(id, referenceId, attachmentTypeId, linkedToken, pageNumber, pageSize);
            if (result.IsSuccess)
            {
                var filters = new
                {
                    Id = id,
                    ReferenceId = referenceId,
                    AttachmentTypeId = attachmentTypeId
                };
                var response = GlobalFunctionsHelper.CreatePagedResponse(result.Data!, result.Message, filters, pageNumber, pageSize);
                LogHelper.LoInformation(StatusCodes.Status200OK, endpointName, MessageHelper.Success.Generic);
                return Ok(response);
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

    [HttpPost("attachments")]
    [ProducesResponseType(typeof(PostId), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status408RequestTimeout)]
    [ProducesResponseType(StatusCodes.Status500InternalServerError)]
    public async Task<IActionResult> PostAttachments([FromBody] PostAttachments request)
    {
        if (!HttpContext.User.Identity!.IsAuthenticated)
        {
            return StatusCode(StatusCodes.Status401Unauthorized);
        }

        var endpointName = $"{HttpContext.Request.Method} {ControllerContext.ActionDescriptor.ActionName}";

        #region Validation
        var inputValidationCollection = new List<ValidationCollection>
    {
        new() { Field = () => request.ReferenceId, Action = ValidationHelper.Action.CheckLong },
        new() { Field = () => request.AttachmentTypeId, Action = ValidationHelper.Action.StaticData.AttachmentType },
        new() { Field = () => request.ContentType!, Action = ValidationHelper.Action.CheckString, IsNullable = true },
        new() { Field = () => request.FileName, Action = ValidationHelper.Action.CheckString },
        //new() { Field = () => request.Attachment, Action = ValidationHelper.Action.CheckFile }
    };
        var inputValidationResultSet = ValidationHelper.ValidateInputs(inputValidationCollection, referenceV1Repository);
        if (!inputValidationResultSet.IsValid)
        {
            LogHelper.LogWarning(StatusCodes.Status400BadRequest, endpointName, inputValidationResultSet.Message);
            return StatusCode(StatusCodes.Status400BadRequest, inputValidationResultSet.Message);
        }
        #endregion

        try
        {
            var user = GlobalFunctionsHelper.GetUser(HttpContext);
            var dynamicRequest = new DynamicObjectWithTypes();
            dynamicRequest.AddClassPropertiesToDynamicObject(request, dynamicRequest);
            dynamicRequest.AddProperty("UserId", user.Id);

            using var cts = new CancellationTokenSource();
            cts.CancelAfter(TimeSpan.FromSeconds(SystemDefaultsConfig.Config.ApiTimeoutInSeconds));
            var linkedToken = CancellationTokenSource.CreateLinkedTokenSource(HttpContext.RequestAborted, cts.Token).Token;

            var result = await transactionV1Service.PostAttachments(dynamicRequest.Properties, linkedToken);
            if (result.IsSuccess)
            {
                LogHelper.LoInformation(StatusCodes.Status200OK, endpointName, result.Message);
                return Ok(result.Data);
            }

            if (result.Exception != null)
            {
                if (result.Exception.Message.Contains(MessageHelper.CustomSqlException))
                {
                    var message = result.Exception.Message.Replace(MessageHelper.CustomSqlException, "");
                    LogHelper.LogWarning(StatusCodes.Status400BadRequest, endpointName, message);
                    return StatusCode(StatusCodes.Status400BadRequest, message);
                }
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

    [HttpPut("attachments")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status408RequestTimeout)]
    [ProducesResponseType(StatusCodes.Status500InternalServerError)]
    public async Task<IActionResult> PutAttachments([FromBody] PutAttachments request)
    {
        if (!HttpContext.User.Identity!.IsAuthenticated)
        {
            return StatusCode(StatusCodes.Status401Unauthorized);
        }

        var endpointName = $"{HttpContext.Request.Method} {ControllerContext.ActionDescriptor.ActionName}";

        #region Validation
        var inputValidationCollection = new List<ValidationCollection>
    {
        new() { Field = () => request.Id, Action = ValidationHelper.Action.CheckLong },
        new() { Field = () => request.ContentType!, Action = ValidationHelper.Action.CheckString, IsNullable = true },
        new() { Field = () => request.FileName, Action = ValidationHelper.Action.CheckString },
    };
        var inputValidationResultSet = ValidationHelper.ValidateInputs(inputValidationCollection, referenceV1Repository);
        if (!inputValidationResultSet.IsValid)
        {
            LogHelper.LogWarning(StatusCodes.Status400BadRequest, endpointName, inputValidationResultSet.Message);
            return StatusCode(StatusCodes.Status400BadRequest, inputValidationResultSet.Message);
        }
        #endregion

        try
        {
            var user = GlobalFunctionsHelper.GetUser(HttpContext);
            var dynamicRequest = new DynamicObjectWithTypes();
            dynamicRequest.AddClassPropertiesToDynamicObject(request, dynamicRequest);
            dynamicRequest.AddProperty("UserId", user.Id);

            using var cts = new CancellationTokenSource();
            cts.CancelAfter(TimeSpan.FromSeconds(SystemDefaultsConfig.Config.ApiTimeoutInSeconds));
            var linkedToken = CancellationTokenSource.CreateLinkedTokenSource(HttpContext.RequestAborted, cts.Token).Token;

            var result = await transactionV1Service.PutAttachments(dynamicRequest.Properties, linkedToken);
            if (result.IsSuccess)
            {
                LogHelper.LoInformation(StatusCodes.Status200OK, endpointName, result.Message);
                return Ok();
            }

            if (result.Exception != null)
            {
                if (result.Exception.Message.Contains(MessageHelper.CustomSqlException))
                {
                    var message = result.Exception.Message.Replace(MessageHelper.CustomSqlException, "");
                    LogHelper.LogWarning(StatusCodes.Status400BadRequest, endpointName, message);
                    return StatusCode(StatusCodes.Status400BadRequest, message);
                }
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

    [HttpDelete("attachments")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status408RequestTimeout)]
    [ProducesResponseType(StatusCodes.Status500InternalServerError)]
    public async Task<IActionResult> DeleteAttachments([FromQuery] long id)
    {
        if (!HttpContext.User.Identity!.IsAuthenticated)
        {
            return StatusCode(StatusCodes.Status401Unauthorized);
        }

        var endpointName = $"{HttpContext.Request.Method} {ControllerContext.ActionDescriptor.ActionName}";

        #region Validation
        var request = new PutAttachments
        {
            Id = id
        };
        var inputValidationCollection = new List<ValidationCollection>
    {
        new() { Field = () => request.Id, Action = ValidationHelper.Action.CheckLong }
    };
        var inputValidationResultSet = ValidationHelper.ValidateInputs(inputValidationCollection, referenceV1Repository);
        if (!inputValidationResultSet.IsValid)
        {
            LogHelper.LogWarning(StatusCodes.Status400BadRequest, endpointName, inputValidationResultSet.Message);
            return StatusCode(StatusCodes.Status400BadRequest, inputValidationResultSet.Message);
        }
        #endregion

        try
        {
            var user = GlobalFunctionsHelper.GetUser(HttpContext);
            var dynamicRequest = new DynamicObjectWithTypes();
            dynamicRequest.AddClassPropertiesToDynamicObject(request, dynamicRequest);
            dynamicRequest.AddProperty("UserId", user.Id);
            dynamicRequest.AddProperty("IsDeleted", true);

            using var cts = new CancellationTokenSource();
            cts.CancelAfter(TimeSpan.FromSeconds(SystemDefaultsConfig.Config.ApiTimeoutInSeconds));
            var linkedToken = CancellationTokenSource.CreateLinkedTokenSource(HttpContext.RequestAborted, cts.Token).Token;

            var result = await transactionV1Service.PutAttachments(dynamicRequest.Properties, linkedToken);
            if (result.IsSuccess)
            {
                LogHelper.LoInformation(StatusCodes.Status200OK, endpointName, result.Message);
                return Ok();
            }

            if (result.Exception != null)
            {
                if (result.Exception.Message.Contains(MessageHelper.CustomSqlException))
                {
                    var message = result.Exception.Message.Replace(MessageHelper.CustomSqlException, "");
                    LogHelper.LogWarning(StatusCodes.Status400BadRequest, endpointName, message);
                    return StatusCode(StatusCodes.Status400BadRequest, message);
                }
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

    #region Group Policy

    [HttpGet("group-policy")]
    [ProducesResponseType(typeof(IEnumerable<GroupPolicy>), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status408RequestTimeout)]
    [ProducesResponseType(StatusCodes.Status500InternalServerError)]
    public async Task<IActionResult> GetGroupPolicy([FromQuery] long? id, string? referenceNumber, string? cocNumber, long? partnersId, bool? issueStatus,
        [FromQuery] List<long>? policyBookingStatusId, [FromQuery] List<long>? cocStatusId, [FromQuery] List<long>? paymentStatusId, [FromQuery] List<long>? claimsStatusId, int pageNumber = 1, int pageSize = 10)
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

            var result = await transactionV1Service.GetGroupPolicy(id, referenceNumber, cocNumber, partnersId, issueStatus,
                GlobalFunctionsHelper.ToCommaSeparatedString(policyBookingStatusId),
                GlobalFunctionsHelper.ToCommaSeparatedString(cocStatusId),
                GlobalFunctionsHelper.ToCommaSeparatedString(paymentStatusId),
                GlobalFunctionsHelper.ToCommaSeparatedString(claimsStatusId),
                linkedToken, // Moved linkedToken here
                pageNumber, pageSize);
            if (result.IsSuccess)
            {
                var filters = new
                {
                    Id = id,
                    ReferenceNumber = referenceNumber,
                    CocNumber = cocNumber,
                    PartnersId = partnersId,
                    IssueStatus = issueStatus,
                    PolicyBookingStatusId = policyBookingStatusId,
                    CocStatusId = cocStatusId,
                    PaymentStatusId = paymentStatusId,
                    ClaimsStatusId = claimsStatusId
                };
                var response = GlobalFunctionsHelper.CreatePagedResponse(result.Data!, result.Message, filters, pageNumber, pageSize);
                LogHelper.LoInformation(StatusCodes.Status200OK, endpointName, MessageHelper.Success.Generic);
                return Ok(response);
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

    [HttpGet("group-policy-view")]
    [ProducesResponseType(typeof(IEnumerable<GroupPolicyView>), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status408RequestTimeout)]
    [ProducesResponseType(StatusCodes.Status500InternalServerError)]
    public async Task<IActionResult> GetGroupPolicyView([FromQuery] long? id, string? referenceNumber, string? cocNumber, long? partnersId, bool? issueStatus,
        [FromQuery] List<long>? policyBookingStatusId, [FromQuery] List<long>? cocStatusId, [FromQuery] List<long>? paymentStatusId, [FromQuery] List<long>? claimsStatusId, string? partnersCode, int pageNumber = 1, int pageSize = 10)
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

            var result = await transactionV1Service.GetGroupPolicyView(id, referenceNumber, cocNumber, partnersId, issueStatus,
                GlobalFunctionsHelper.ToCommaSeparatedString(policyBookingStatusId),
                GlobalFunctionsHelper.ToCommaSeparatedString(cocStatusId),
                GlobalFunctionsHelper.ToCommaSeparatedString(paymentStatusId),
                GlobalFunctionsHelper.ToCommaSeparatedString(claimsStatusId),
                partnersCode, linkedToken, // Moved linkedToken here
                pageNumber, pageSize);
            if (result.IsSuccess)
            {
                var filters = new
                {
                    Id = id,
                    ReferenceNumber = referenceNumber,
                    CocNumber = cocNumber,
                    PartnersId = partnersId,
                    IssueStatus = issueStatus,
                    PolicyBookingStatusId = policyBookingStatusId,
                    CocStatusId = cocStatusId,
                    PaymentStatusId = paymentStatusId,
                    ClaimsStatusId = claimsStatusId,
                    PartnersCode = partnersCode
                };
                var response = GlobalFunctionsHelper.CreatePagedResponse(result.Data!, result.Message, filters, pageNumber, pageSize);
                LogHelper.LoInformation(StatusCodes.Status200OK, endpointName, MessageHelper.Success.Generic);
                return Ok(response);
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

    [HttpPost("group-policy")]
    [ProducesResponseType(typeof(PostId), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status408RequestTimeout)]
    [ProducesResponseType(StatusCodes.Status500InternalServerError)]
    public async Task<IActionResult> PostGroupPolicy([FromBody] PostGroupPolicy request)
    {
        if (!HttpContext.User.Identity!.IsAuthenticated)
        {
            return StatusCode(StatusCodes.Status401Unauthorized);
        }

        var endpointName = $"{HttpContext.Request.Method} {ControllerContext.ActionDescriptor.ActionName}";

        #region Validation Batch 1

        var inputValidationCollection1 = new List<ValidationCollection>
    {
        new() { Field = () => request.PartnersId, Action = ValidationHelper.Action.ReferenceData.Partners },
        new() { Field = () => request.AgentsId, Action = ValidationHelper.Action.ReferenceData.Agents },
        new() { Field = () => request.ApproversId, Action = ValidationHelper.Action.ReferenceData.Approvers },
        new() { Field = () => request.ProductsId, Action = ValidationHelper.Action.ReferenceData.Products },
        new() { Field = () => request.ProvidersId, Action = ValidationHelper.Action.ReferenceData.Providers },
        new() { Field = () => request.DistributionChannelId, Action = ValidationHelper.Action.ReferenceData.DistributionChannel },
        new() { Field = () => request.PaymentOptionId, Action = ValidationHelper.Action.ReferenceData.SelectionList, SelectionTypeId = StaticDataHelper.SelectionType.PaymentOption.Id },
        new() { Field = () => request.AccountTypeId, Action = ValidationHelper.Action.ReferenceData.SelectionList, SelectionTypeId = StaticDataHelper.SelectionType.AccountType.Id },
        new() { Field = () => request.ProviderPolicyNo, Action = ValidationHelper.Action.CheckString, Pattern = ValidationHelper.RegexPatterns.AlphaNumericDash, MaxLength = 50 },
        new() { Field = () => request.EndorsementNo!, Action = ValidationHelper.Action.CheckString, Pattern = ValidationHelper.RegexPatterns.AlphaNumericDash, MaxLength = 50, IsNullable = true },
        new() { Field = () => request.TerminationDate, Action = ValidationHelper.Action.CheckDate },
        new() { Field = () => request.EffectiveDate, Action = ValidationHelper.Action.CheckDate },
        new() { Field = () => request.IssueDate, Action = ValidationHelper.Action.CheckDate },
        new() { Field = () => request.Remarks!, Action = ValidationHelper.Action.CheckString, MaxLength = 500, IsNullable = true},

        //Premiums
        new() { Field = () => request.BasicPremium, Action = ValidationHelper.Action.CheckDecimal },
        new() { Field = () => request.BasicPremiumCommission, Action = ValidationHelper.Action.CheckDecimal },
        new() { Field = () => request.DJDPatricioMarkup, Action = ValidationHelper.Action.CheckDecimal },
        new() { Field = () => request.PartnerMarkup, Action = ValidationHelper.Action.CheckDecimal },
        new() { Field = () => request.Discount, Action = ValidationHelper.Action.CheckDecimal },
        new() { Field = () => request.Taxes, Action = ValidationHelper.Action.CheckDecimal },
        new() { Field = () => request.DST, Action = ValidationHelper.Action.CheckDecimal },
        new() { Field = () => request.VAT, Action = ValidationHelper.Action.CheckDecimal },
        new() { Field = () => request.LGT, Action = ValidationHelper.Action.CheckDecimal },
        new() { Field = () => request.PT, Action = ValidationHelper.Action.CheckDecimal },
        new() { Field = () => request.FST, Action = ValidationHelper.Action.CheckDecimal },
        new() { Field = () => request.NotarialFee, Action = ValidationHelper.Action.CheckDecimal },
        new() { Field = () => request.Others, Action = ValidationHelper.Action.CheckDecimal },
        new() { Field = () => request.PremiumsRemarks!, Action = ValidationHelper.Action.CheckString, MaxLength = 500, IsNullable = true}
    };
        var inputValidationResultSet1 = ValidationHelper.ValidateInputs(inputValidationCollection1, referenceV1Repository);
        if (!inputValidationResultSet1.IsValid)
        {
            LogHelper.LogWarning(StatusCodes.Status400BadRequest, endpointName, inputValidationResultSet1.Message);
            return StatusCode(StatusCodes.Status400BadRequest, inputValidationResultSet1.Message);
        }

        #endregion

        #region Validation Batch 2

        var inputValidationCollection2 = new List<ValidationCollection>();

        //DistributionChannelWithPromoSalesOption
        if (StaticDataHelper.DistributionChannelWithPromoSalesOption.ContainsValue(request.DistributionChannelId))
        {
            inputValidationCollection2.Add(new ValidationCollection { Field = () => request.PromoManagersId!, Action = ValidationHelper.Action.ReferenceData.PromoManagers });
            inputValidationCollection2.Add(new ValidationCollection { Field = () => request.PromoOfficersId!, Action = ValidationHelper.Action.ReferenceData.PromoOfficers, IsNullable = true });
            inputValidationCollection2.Add(new ValidationCollection { Field = () => request.SalesManagersId!, Action = ValidationHelper.Action.ReferenceData.SalesManagers });
            request.SubAgentsId = null;
        }
        else
        {
            request.PromoManagersId = null;
            request.PromoOfficersId = null;
            request.SalesManagersId = null;
            inputValidationCollection2.Add(new ValidationCollection { Field = () => request.SubAgentsId!, Action = ValidationHelper.Action.ReferenceData.SubAgents, IsNullable = true });
        }

        //DistributionChannelWithBranchCodeAndReferrer
        if (StaticDataHelper.DistributionChannelWithBranchCodeAndReferrer.ContainsValue(request.DistributionChannelId))
        {
            inputValidationCollection2.Add(new ValidationCollection { Field = () => request.BranchCode!, Action = ValidationHelper.Action.CheckString, Pattern = ValidationHelper.RegexPatterns.Numeric, MaxLength = 5, MinLength = 5 });
            inputValidationCollection2.Add(new ValidationCollection { Field = () => request.BranchName!, Action = ValidationHelper.Action.CheckString, Pattern = ValidationHelper.RegexPatterns.Numeric, MaxLength = 6, MinLength = 6 });
        }
        else
        {
            request.BranchCode = null;
            request.BranchName = null;
        }

        var inputValidationResultSet2 = ValidationHelper.ValidateInputs(inputValidationCollection2, referenceV1Repository);
        if (!inputValidationResultSet2.IsValid)
        {
            LogHelper.LogWarning(StatusCodes.Status400BadRequest, endpointName, inputValidationResultSet2.Message);
            return StatusCode(StatusCodes.Status400BadRequest, inputValidationResultSet2.Message);
        }

        #endregion

        try
        {
            var user = GlobalFunctionsHelper.GetUser(HttpContext);
            var dynamicRequest = new DynamicObjectWithTypes();
            dynamicRequest.AddClassPropertiesToDynamicObject(request, dynamicRequest);
            dynamicRequest.AddProperty("UserId", user.Id);
            dynamicRequest.AddProperty("PlatformsId", StaticDataHelper.Platforms.IMS3.Id);
            dynamicRequest.AddProperty("PolicyBookingStatusId", StaticDataHelper.PolicyBookingStatus.Pending.Id);
            dynamicRequest.AddProperty("CocStatusId", StaticDataHelper.CocStatus.Active.Id);
            dynamicRequest.AddProperty("ClaimsStatusId", StaticDataHelper.ClaimsStatus.Processing.Id);

            using var cts = new CancellationTokenSource();
            cts.CancelAfter(TimeSpan.FromSeconds(SystemDefaultsConfig.Config.ApiTimeoutInSeconds));
            var linkedToken = CancellationTokenSource.CreateLinkedTokenSource(HttpContext.RequestAborted, cts.Token).Token;

            var result = await transactionV1Service.PostGroupPolicy(dynamicRequest.Properties, linkedToken);
            if (result.IsSuccess)
            {
                LogHelper.LoInformation(StatusCodes.Status200OK, endpointName, result.Message);
                return Ok(result.Data);
            }

            if (result.Exception != null)
            {
                if (result.Exception.Message.Contains(MessageHelper.CustomSqlException))
                {
                    var message = result.Exception.Message.Replace(MessageHelper.CustomSqlException, "");
                    LogHelper.LogWarning(StatusCodes.Status400BadRequest, endpointName, message);
                    return StatusCode(StatusCodes.Status400BadRequest, message);
                }
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

    [HttpPut("group-policy")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status408RequestTimeout)]
    [ProducesResponseType(StatusCodes.Status500InternalServerError)]
    public async Task<IActionResult> PutGroupPolicy([FromBody] PutGroupPolicy request)
    {
        if (!HttpContext.User.Identity!.IsAuthenticated)
        {
            return StatusCode(StatusCodes.Status401Unauthorized);
        }

        var endpointName = $"{HttpContext.Request.Method} {ControllerContext.ActionDescriptor.ActionName}";

        #region Validation Batch 1

        var inputValidationCollection1 = new List<ValidationCollection>
    {
        new() { Field = () => request.Id, Action = ValidationHelper.Action.CheckLong },
        new() { Field = () => request.AgentsId, Action = ValidationHelper.Action.ReferenceData.Agents },
        new() { Field = () => request.ApproversId, Action = ValidationHelper.Action.ReferenceData.Approvers },
        new() { Field = () => request.Remarks!, Action = ValidationHelper.Action.CheckString, MaxLength = 500, IsNullable = true},

        //Premiums
        new() { Field = () => request.BasicPremium, Action = ValidationHelper.Action.CheckDecimal },
        new() { Field = () => request.BasicPremiumCommission, Action = ValidationHelper.Action.CheckDecimal },
        new() { Field = () => request.DJDPatricioMarkup, Action = ValidationHelper.Action.CheckDecimal },
        new() { Field = () => request.PartnerMarkup, Action = ValidationHelper.Action.CheckDecimal },
        new() { Field = () => request.Discount, Action = ValidationHelper.Action.CheckDecimal },
        new() { Field = () => request.Taxes, Action = ValidationHelper.Action.CheckDecimal },
        new() { Field = () => request.DST, Action = ValidationHelper.Action.CheckDecimal },
        new() { Field = () => request.VAT, Action = ValidationHelper.Action.CheckDecimal },
        new() { Field = () => request.LGT, Action = ValidationHelper.Action.CheckDecimal },
        new() { Field = () => request.PT, Action = ValidationHelper.Action.CheckDecimal },
        new() { Field = () => request.FST, Action = ValidationHelper.Action.CheckDecimal },
        new() { Field = () => request.NotarialFee, Action = ValidationHelper.Action.CheckDecimal },
        new() { Field = () => request.Others, Action = ValidationHelper.Action.CheckDecimal },
        new() { Field = () => request.PremiumsRemarks!, Action = ValidationHelper.Action.CheckString, MaxLength = 500, IsNullable = true}
    };
        var inputValidationResultSet1 = ValidationHelper.ValidateInputs(inputValidationCollection1, referenceV1Repository);
        if (!inputValidationResultSet1.IsValid)
        {
            LogHelper.LogWarning(StatusCodes.Status400BadRequest, endpointName, inputValidationResultSet1.Message);
            return StatusCode(StatusCodes.Status400BadRequest, inputValidationResultSet1.Message);
        }

        #endregion

        #region Validation Batch 2

        var currentPolicyResult = await transactionV1Repository.GetGroupPolicy(request.Id, null, null, null, null, null, null, null, null);
        GroupPolicy currentPolicy;
        if (currentPolicyResult.IsSuccess)
        {
            if (currentPolicyResult.Data != null)
            {
                if (currentPolicyResult.Data.ToList().Count != 0)
                {
                    currentPolicy = currentPolicyResult.Data.First();
                }
                else
                {
                    LogHelper.LogWarning(StatusCodes.Status400BadRequest, endpointName, MessageHelper.Error.Policy.PolicyNotFound);
                    return StatusCode(StatusCodes.Status400BadRequest, MessageHelper.Error.Policy.PolicyNotFound);
                }
            }
            else
            {
                LogHelper.LogWarning(StatusCodes.Status400BadRequest, endpointName, MessageHelper.Error.Policy.PolicyNotFound);
                return StatusCode(StatusCodes.Status400BadRequest, MessageHelper.Error.Policy.PolicyNotFound);
            }
        }
        else
        {
            if (currentPolicyResult.Exception != null)
            {
                if (currentPolicyResult.Exception.Message.Contains(MessageHelper.CustomSqlException))
                {
                    var message = currentPolicyResult.Exception.Message.Replace(MessageHelper.CustomSqlException, "");
                    LogHelper.LogWarning(StatusCodes.Status400BadRequest, endpointName, message);
                    return StatusCode(StatusCodes.Status400BadRequest, message);
                }
            }

            LogHelper.LogError(endpointName, currentPolicyResult.Message, currentPolicyResult.Exception);
            return StatusCode(StatusCodes.Status500InternalServerError);
        }

        var inputValidationCollection2 = new List<ValidationCollection>();

        //DistributionChannelWithPromoSalesOption
        if (StaticDataHelper.DistributionChannelWithPromoSalesOption.ContainsValue(currentPolicy.DistributionChannelId))
        {
            inputValidationCollection2.Add(new ValidationCollection { Field = () => request.PromoManagersId!, Action = ValidationHelper.Action.ReferenceData.PromoManagers });
            inputValidationCollection2.Add(new ValidationCollection { Field = () => request.PromoOfficersId!, Action = ValidationHelper.Action.ReferenceData.PromoOfficers, IsNullable = true });
            inputValidationCollection2.Add(new ValidationCollection { Field = () => request.SalesManagersId!, Action = ValidationHelper.Action.ReferenceData.SalesManagers });
            request.SubAgentsId = null;
        }
        else
        {
            request.PromoManagersId = null;
            request.PromoOfficersId = null;
            request.SalesManagersId = null;
            inputValidationCollection2.Add(new ValidationCollection { Field = () => request.SubAgentsId!, Action = ValidationHelper.Action.ReferenceData.SubAgents, IsNullable = true });
        }

        var inputValidationResultSet2 = ValidationHelper.ValidateInputs(inputValidationCollection2, referenceV1Repository);
        if (!inputValidationResultSet2.IsValid)
        {
            LogHelper.LogWarning(StatusCodes.Status400BadRequest, endpointName, inputValidationResultSet2.Message);
            return StatusCode(StatusCodes.Status400BadRequest, inputValidationResultSet2.Message);
        }

        #endregion

        try
        {
            var user = GlobalFunctionsHelper.GetUser(HttpContext);
            var dynamicRequest = new DynamicObjectWithTypes();
            dynamicRequest.AddClassPropertiesToDynamicObject(request, dynamicRequest);
            dynamicRequest.AddProperty("UserId", user.Id);
            dynamicRequest.AddProperty("IssueStatus", currentPolicy.IssueStatus);
            dynamicRequest.AddProperty("PolicyBookingStatusId", currentPolicy.PolicyBookingStatusId);
            dynamicRequest.AddProperty("CocStatusId", currentPolicy.CocStatusId);
            dynamicRequest.AddProperty("ClaimsStatusId", currentPolicy.ClaimsStatusId);

            using var cts = new CancellationTokenSource();
            cts.CancelAfter(TimeSpan.FromSeconds(SystemDefaultsConfig.Config.ApiTimeoutInSeconds));
            var linkedToken = CancellationTokenSource.CreateLinkedTokenSource(HttpContext.RequestAborted, cts.Token).Token;

            var result = await transactionV1Service.PutGroupPolicy(dynamicRequest.Properties, linkedToken);
            if (result.IsSuccess)
            {
                LogHelper.LoInformation(StatusCodes.Status200OK, endpointName, result.Message);
                return Ok();
            }

            if (result.Exception != null)
            {
                if (result.Exception.Message.Contains(MessageHelper.CustomSqlException))
                {
                    var message = result.Exception.Message.Replace(MessageHelper.CustomSqlException, "");
                    LogHelper.LogWarning(StatusCodes.Status400BadRequest, endpointName, message);
                    return StatusCode(StatusCodes.Status400BadRequest, message);
                }
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

    [HttpDelete("group-policy")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status408RequestTimeout)]
    [ProducesResponseType(StatusCodes.Status500InternalServerError)]
    public async Task<IActionResult> DeleteGroupPolicy([FromQuery] long id)
    {
        if (!HttpContext.User.Identity!.IsAuthenticated)
        {
            return StatusCode(StatusCodes.Status401Unauthorized);
        }

        var endpointName = $"{HttpContext.Request.Method} {ControllerContext.ActionDescriptor.ActionName}";

        #region Validation
        var request = new PutGroupPolicy
        {
            Id = id
        };
        var inputValidationCollection = new List<ValidationCollection>
    {
        new() { Field = () => request.Id, Action = ValidationHelper.Action.CheckLong }
    };
        var inputValidationResultSet = ValidationHelper.ValidateInputs(inputValidationCollection, referenceV1Repository);
        if (!inputValidationResultSet.IsValid)
        {
            LogHelper.LogWarning(StatusCodes.Status400BadRequest, endpointName, inputValidationResultSet.Message);
            return StatusCode(StatusCodes.Status400BadRequest, inputValidationResultSet.Message);
        }
        #endregion

        try
        {
            var user = GlobalFunctionsHelper.GetUser(HttpContext);
            var dynamicRequest = new DynamicObjectWithTypes();
            dynamicRequest.AddClassPropertiesToDynamicObject(request, dynamicRequest);
            dynamicRequest.AddProperty("UserId", user.Id);
            dynamicRequest.AddProperty("IsDeleted", true);

            using var cts = new CancellationTokenSource();
            cts.CancelAfter(TimeSpan.FromSeconds(SystemDefaultsConfig.Config.ApiTimeoutInSeconds));
            var linkedToken = CancellationTokenSource.CreateLinkedTokenSource(HttpContext.RequestAborted, cts.Token).Token;

            var result = await transactionV1Service.PutGroupPolicy(dynamicRequest.Properties, linkedToken);
            if (result.IsSuccess)
            {
                LogHelper.LoInformation(StatusCodes.Status200OK, endpointName, result.Message);
                return Ok();
            }

            if (result.Exception != null)
            {
                if (result.Exception.Message.Contains(MessageHelper.CustomSqlException))
                {
                    var message = result.Exception.Message.Replace(MessageHelper.CustomSqlException, "");
                    LogHelper.LogWarning(StatusCodes.Status400BadRequest, endpointName, message);
                    return StatusCode(StatusCodes.Status400BadRequest, message);
                }
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

    #region Individual Policy

    [HttpGet("individual-policy")]
    [ProducesResponseType(typeof(IEnumerable<IndividualPolicy>), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status408RequestTimeout)]
    [ProducesResponseType(StatusCodes.Status500InternalServerError)]
    public async Task<IActionResult> GetIndividualPolicy([FromQuery] long? id, string? referenceNumber, string? cocNumber, long? partnersId, long? clientsId,
        bool? issueStatus, [FromQuery] List<long>? policyBookingStatusId, [FromQuery] List<long>? cocStatusId, [FromQuery] List<long>? paymentStatusId, [FromQuery] List<long>? claimsStatusId, int pageNumber = 1, int pageSize = 10)
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

            var result = await transactionV1Service.GetIndividualPolicy(id, referenceNumber, cocNumber, partnersId, clientsId, issueStatus,
                GlobalFunctionsHelper.ToCommaSeparatedString(policyBookingStatusId),
                GlobalFunctionsHelper.ToCommaSeparatedString(cocStatusId),
                GlobalFunctionsHelper.ToCommaSeparatedString(paymentStatusId),
                GlobalFunctionsHelper.ToCommaSeparatedString(claimsStatusId),
                linkedToken, // Moved linkedToken here
                pageNumber, pageSize);
            if (result.IsSuccess)
            {
                var filters = new
                {
                    Id = id,
                    ReferenceNumber = referenceNumber,
                    CocNumber = cocNumber,
                    PartnersId = partnersId,
                    ClientsId = clientsId, // Added ClientsId
                    IssueStatus = issueStatus,
                    PolicyBookingStatusId = policyBookingStatusId,
                    CocStatusId = cocStatusId,
                    PaymentStatusId = paymentStatusId,
                    ClaimsStatusId = claimsStatusId
                };
                var response = GlobalFunctionsHelper.CreatePagedResponse(result.Data!, result.Message, filters, pageNumber, pageSize);
                LogHelper.LoInformation(StatusCodes.Status200OK, endpointName, MessageHelper.Success.Generic);
                return Ok(response);
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

    [HttpGet("individual-policy-view")]
    [ProducesResponseType(typeof(IEnumerable<IndividualPolicyView>), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status408RequestTimeout)]
    [ProducesResponseType(StatusCodes.Status500InternalServerError)]
    public async Task<IActionResult> GetIndividualPolicyView([FromQuery] long? id, string? referenceNumber, string? cocNumber, long? partnersId, long? clientsId,
        bool? issueStatus, [FromQuery] List<long>? policyBookingStatusId, [FromQuery] List<long>? cocStatusId, [FromQuery] List<long>? paymentStatusId, [FromQuery] List<long>? claimsStatusId, string? clientsInsuranceCustomerNo, int pageNumber = 1, int pageSize = 10)
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

            var result = await transactionV1Service.GetIndividualPolicyView(id, referenceNumber, cocNumber, partnersId, clientsId, issueStatus,
                GlobalFunctionsHelper.ToCommaSeparatedString(policyBookingStatusId),
                GlobalFunctionsHelper.ToCommaSeparatedString(cocStatusId),
                GlobalFunctionsHelper.ToCommaSeparatedString(paymentStatusId),
                GlobalFunctionsHelper.ToCommaSeparatedString(claimsStatusId),
                clientsInsuranceCustomerNo, linkedToken, // Moved linkedToken here
                pageNumber, pageSize);
            if (result.IsSuccess)
            {
                var filters = new
                {
                    Id = id,
                    ReferenceNumber = referenceNumber,
                    CocNumber = cocNumber,
                    PartnersId = partnersId,
                    ClientsId = clientsId,
                    IssueStatus = issueStatus,
                    PolicyBookingStatusId = policyBookingStatusId,
                    CocStatusId = cocStatusId,
                    PaymentStatusId = paymentStatusId,
                    ClaimsStatusId = claimsStatusId,
                    ClientsInsuranceCustomerNo = clientsInsuranceCustomerNo // Added ClientsInsuranceCustomerNo
                };
                var response = GlobalFunctionsHelper.CreatePagedResponse(result.Data!, result.Message, filters, pageNumber, pageSize);
                LogHelper.LoInformation(StatusCodes.Status200OK, endpointName, MessageHelper.Success.Generic);
                return Ok(response);
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

    [HttpPost("individual-policy")]
    [ProducesResponseType(typeof(PostId), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status408RequestTimeout)]
    [ProducesResponseType(StatusCodes.Status500InternalServerError)]
    public async Task<IActionResult> PostIndividualPolicy([FromBody] PostIndividualPolicy request)
    {
        if (!HttpContext.User.Identity!.IsAuthenticated)
        {
            return StatusCode(StatusCodes.Status401Unauthorized);
        }

        var endpointName = $"{HttpContext.Request.Method} {ControllerContext.ActionDescriptor.ActionName}";

        #region Validation Batch 1

        var inputValidationCollection1 = new List<ValidationCollection>
    {
        new() { Field = () => request.ClientsId, Action = ValidationHelper.Action.ReferenceData.Clients },
        new() { Field = () => request.PartnersId, Action = ValidationHelper.Action.ReferenceData.Partners },
        new() { Field = () => request.AgentsId, Action = ValidationHelper.Action.ReferenceData.Agents },
        new() { Field = () => request.ApproversId, Action = ValidationHelper.Action.ReferenceData.Approvers },
        new() { Field = () => request.ProductsId, Action = ValidationHelper.Action.ReferenceData.Products },
        new() { Field = () => request.ProvidersId, Action = ValidationHelper.Action.ReferenceData.Providers },
        new() { Field = () => request.DistributionChannelId, Action = ValidationHelper.Action.ReferenceData.DistributionChannel },
        new() { Field = () => request.PaymentOptionId, Action = ValidationHelper.Action.ReferenceData.SelectionList, SelectionTypeId = StaticDataHelper.SelectionType.PaymentOption.Id },
        new() { Field = () => request.ProviderPolicyNo, Action = ValidationHelper.Action.CheckString, Pattern = ValidationHelper.RegexPatterns.AlphaNumericDash, MaxLength = 50 },
        new() { Field = () => request.EndorsementNo!, Action = ValidationHelper.Action.CheckString, Pattern = ValidationHelper.RegexPatterns.AlphaNumericDash, MaxLength = 50, IsNullable = true },
        new() { Field = () => request.TerminationDate, Action = ValidationHelper.Action.CheckDate },
        new() { Field = () => request.EffectiveDate, Action = ValidationHelper.Action.CheckDate },
        new() { Field = () => request.IssueDate, Action = ValidationHelper.Action.CheckDate },
        new() { Field = () => request.Remarks!, Action = ValidationHelper.Action.CheckString, MaxLength = 500, IsNullable = true},

        //Premiums
        new() { Field = () => request.BasicPremium, Action = ValidationHelper.Action.CheckDecimal },
        new() { Field = () => request.BasicPremiumCommission, Action = ValidationHelper.Action.CheckDecimal },
        new() { Field = () => request.DJDPatricioMarkup, Action = ValidationHelper.Action.CheckDecimal },
        new() { Field = () => request.PartnerMarkup, Action = ValidationHelper.Action.CheckDecimal },
        new() { Field = () => request.Discount, Action = ValidationHelper.Action.CheckDecimal },
        new() { Field = () => request.Taxes, Action = ValidationHelper.Action.CheckDecimal },
        new() { Field = () => request.DST, Action = ValidationHelper.Action.CheckDecimal },
        new() { Field = () => request.VAT, Action = ValidationHelper.Action.CheckDecimal },
        new() { Field = () => request.LGT, Action = ValidationHelper.Action.CheckDecimal },
        new() { Field = () => request.PT, Action = ValidationHelper.Action.CheckDecimal },
        new() { Field = () => request.FST, Action = ValidationHelper.Action.CheckDecimal },
        new() { Field = () => request.NotarialFee, Action = ValidationHelper.Action.CheckDecimal },
        new() { Field = () => request.Others, Action = ValidationHelper.Action.CheckDecimal },
        new() { Field = () => request.PremiumsRemarks!, Action = ValidationHelper.Action.CheckString, MaxLength = 500, IsNullable = true}
    };
        var inputValidationResultSet1 = ValidationHelper.ValidateInputs(inputValidationCollection1, referenceV1Repository);
        if (!inputValidationResultSet1.IsValid)
        {
            LogHelper.LogWarning(StatusCodes.Status400BadRequest, endpointName, inputValidationResultSet1.Message);
            return StatusCode(StatusCodes.Status400BadRequest, inputValidationResultSet1.Message);
        }

        #endregion

        #region Validation Batch 2

        var inputValidationCollection2 = new List<ValidationCollection>();

        //DistributionChannelWithPromoSalesOption
        if (StaticDataHelper.DistributionChannelWithPromoSalesOption.ContainsValue(request.DistributionChannelId))
        {
            inputValidationCollection2.Add(new ValidationCollection { Field = () => request.PromoManagersId!, Action = ValidationHelper.Action.ReferenceData.PromoManagers });
            inputValidationCollection2.Add(new ValidationCollection { Field = () => request.PromoOfficersId!, Action = ValidationHelper.Action.ReferenceData.PromoOfficers, IsNullable = true });
            inputValidationCollection2.Add(new ValidationCollection { Field = () => request.SalesManagersId!, Action = ValidationHelper.Action.ReferenceData.SalesManagers });
            request.SubAgentsId = null;
        }
        else
        {
            request.PromoManagersId = null;
            request.PromoOfficersId = null;
            request.SalesManagersId = null;
            inputValidationCollection2.Add(new ValidationCollection { Field = () => request.SubAgentsId!, Action = ValidationHelper.Action.ReferenceData.SubAgents, IsNullable = true });
        }

        var inputValidationResultSet2 = ValidationHelper.ValidateInputs(inputValidationCollection2, referenceV1Repository);
        if (!inputValidationResultSet2.IsValid)
        {
            LogHelper.LogWarning(StatusCodes.Status400BadRequest, endpointName, inputValidationResultSet2.Message);
            return StatusCode(StatusCodes.Status400BadRequest, inputValidationResultSet2.Message);
        }

        #endregion

        try
        {
            var user = GlobalFunctionsHelper.GetUser(HttpContext);
            var dynamicRequest = new DynamicObjectWithTypes();
            dynamicRequest.AddClassPropertiesToDynamicObject(request, dynamicRequest);
            dynamicRequest.AddProperty("UserId", user.Id);
            dynamicRequest.AddProperty("PlatformsId", StaticDataHelper.Platforms.IMS3.Id);
            dynamicRequest.AddProperty("PolicyBookingStatusId", StaticDataHelper.PolicyBookingStatus.Pending.Id);
            dynamicRequest.AddProperty("CocStatusId", StaticDataHelper.CocStatus.Active.Id);
            dynamicRequest.AddProperty("ClaimsStatusId", StaticDataHelper.ClaimsStatus.Processing.Id);

            using var cts = new CancellationTokenSource();
            cts.CancelAfter(TimeSpan.FromSeconds(SystemDefaultsConfig.Config.ApiTimeoutInSeconds));
            var linkedToken = CancellationTokenSource.CreateLinkedTokenSource(HttpContext.RequestAborted, cts.Token).Token;

            var result = await transactionV1Service.PostIndividualPolicy(dynamicRequest.Properties, linkedToken);
            if (result.IsSuccess)
            {
                LogHelper.LoInformation(StatusCodes.Status200OK, endpointName, result.Message);
                return Ok(result.Data);
            }

            if (result.Exception != null)
            {
                if (result.Exception.Message.Contains(MessageHelper.CustomSqlException))
                {
                    var message = result.Exception.Message.Replace(MessageHelper.CustomSqlException, "");
                    LogHelper.LogWarning(StatusCodes.Status400BadRequest, endpointName, message);
                    return StatusCode(StatusCodes.Status400BadRequest, message);
                }
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

    [HttpPut("individual-policy")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status408RequestTimeout)]
    [ProducesResponseType(StatusCodes.Status500InternalServerError)]
    public async Task<IActionResult> PutIndividualPolicy([FromBody] PutIndividualPolicy request)
    {
        if (!HttpContext.User.Identity!.IsAuthenticated)
        {
            return StatusCode(StatusCodes.Status401Unauthorized);
        }

        var endpointName = $"{HttpContext.Request.Method} {ControllerContext.ActionDescriptor.ActionName}";

        #region Validation Batch 1

        var inputValidationCollection1 = new List<ValidationCollection>
    {
        new() { Field = () => request.Id, Action = ValidationHelper.Action.CheckLong },
        new() { Field = () => request.AgentsId, Action = ValidationHelper.Action.ReferenceData.Agents },
        new() { Field = () => request.ApproversId, Action = ValidationHelper.Action.ReferenceData.Approvers },
        new() { Field = () => request.Remarks!, Action = ValidationHelper.Action.CheckString, MaxLength = 500, IsNullable = true},

        //Premiums
        new() { Field = () => request.BasicPremium, Action = ValidationHelper.Action.CheckDecimal },
        new() { Field = () => request.BasicPremiumCommission, Action = ValidationHelper.Action.CheckDecimal },
        new() { Field = () => request.DJDPatricioMarkup, Action = ValidationHelper.Action.CheckDecimal },
        new() { Field = () => request.PartnerMarkup, Action = ValidationHelper.Action.CheckDecimal },
        new() { Field = () => request.Discount, Action = ValidationHelper.Action.CheckDecimal },
        new() { Field = () => request.Taxes, Action = ValidationHelper.Action.CheckDecimal },
        new() { Field = () => request.DST, Action = ValidationHelper.Action.CheckDecimal },
        new() { Field = () => request.VAT, Action = ValidationHelper.Action.CheckDecimal },
        new() { Field = () => request.LGT, Action = ValidationHelper.Action.CheckDecimal },
        new() { Field = () => request.PT, Action = ValidationHelper.Action.CheckDecimal },
        new() { Field = () => request.FST, Action = ValidationHelper.Action.CheckDecimal },
        new() { Field = () => request.NotarialFee, Action = ValidationHelper.Action.CheckDecimal },
        new() { Field = () => request.Others, Action = ValidationHelper.Action.CheckDecimal },
        new() { Field = () => request.PremiumsRemarks!, Action = ValidationHelper.Action.CheckString, MaxLength = 500, IsNullable = true}
    };
        var inputValidationResultSet1 = ValidationHelper.ValidateInputs(inputValidationCollection1, referenceV1Repository);
        if (!inputValidationResultSet1.IsValid)
        {
            LogHelper.LogWarning(StatusCodes.Status400BadRequest, endpointName, inputValidationResultSet1.Message);
            return StatusCode(StatusCodes.Status400BadRequest, inputValidationResultSet1.Message);
        }

        #endregion

        #region Validation Batch 2

        var currentPolicyResult = await transactionV1Repository.GetIndividualPolicy(request.Id, null, null, null, null, null, null, null, null, null);
        IndividualPolicy currentPolicy;
        if (currentPolicyResult.IsSuccess)
        {
            if (currentPolicyResult.Data != null)
            {
                if (currentPolicyResult.Data.ToList().Count != 0)
                {
                    currentPolicy = currentPolicyResult.Data.First();
                }
                else
                {
                    LogHelper.LogWarning(StatusCodes.Status400BadRequest, endpointName, MessageHelper.Error.Policy.PolicyNotFound);
                    return StatusCode(StatusCodes.Status400BadRequest, MessageHelper.Error.Policy.PolicyNotFound);
                }
            }
            else
            {
                LogHelper.LogWarning(StatusCodes.Status400BadRequest, endpointName, MessageHelper.Error.Policy.PolicyNotFound);
                return StatusCode(StatusCodes.Status400BadRequest, MessageHelper.Error.Policy.PolicyNotFound);
            }
        }
        else
        {
            if (currentPolicyResult.Exception != null)
            {
                if (currentPolicyResult.Exception.Message.Contains(MessageHelper.CustomSqlException))
                {
                    var message = currentPolicyResult.Exception.Message.Replace(MessageHelper.CustomSqlException, "");
                    LogHelper.LogWarning(StatusCodes.Status400BadRequest, endpointName, message);
                    return StatusCode(StatusCodes.Status400BadRequest, message);
                }
            }

            LogHelper.LogError(endpointName, currentPolicyResult.Message, currentPolicyResult.Exception);
            return StatusCode(StatusCodes.Status500InternalServerError);
        }

        var inputValidationCollection2 = new List<ValidationCollection>();

        //DistributionChannelWithPromoSalesOption
        if (StaticDataHelper.DistributionChannelWithPromoSalesOption.ContainsValue(currentPolicy.DistributionChannelId))
        {
            inputValidationCollection2.Add(new ValidationCollection { Field = () => request.PromoManagersId!, Action = ValidationHelper.Action.ReferenceData.PromoManagers });
            inputValidationCollection2.Add(new ValidationCollection { Field = () => request.PromoOfficersId!, Action = ValidationHelper.Action.ReferenceData.PromoOfficers, IsNullable = true });
            inputValidationCollection2.Add(new ValidationCollection { Field = () => request.SalesManagersId!, Action = ValidationHelper.Action.ReferenceData.SalesManagers });
            request.SubAgentsId = null;
        }
        else
        {
            request.PromoManagersId = null;
            request.PromoOfficersId = null;
            request.SalesManagersId = null;
            inputValidationCollection2.Add(new ValidationCollection { Field = () => request.SubAgentsId!, Action = ValidationHelper.Action.ReferenceData.SubAgents, IsNullable = true });
        }

        var inputValidationResultSet2 = ValidationHelper.ValidateInputs(inputValidationCollection2, referenceV1Repository);
        if (!inputValidationResultSet2.IsValid)
        {
            LogHelper.LogWarning(StatusCodes.Status400BadRequest, endpointName, inputValidationResultSet2.Message);
            return StatusCode(StatusCodes.Status400BadRequest, inputValidationResultSet2.Message);
        }

        #endregion

        try
        {
            var user = GlobalFunctionsHelper.GetUser(HttpContext);
            var dynamicRequest = new DynamicObjectWithTypes();
            dynamicRequest.AddClassPropertiesToDynamicObject(request, dynamicRequest);
            dynamicRequest.AddProperty("UserId", user.Id);
            dynamicRequest.AddProperty("IssueStatus", currentPolicy.IssueStatus);
            dynamicRequest.AddProperty("PolicyBookingStatusId", currentPolicy.PolicyBookingStatusId);
            dynamicRequest.AddProperty("CocStatusId", currentPolicy.CocStatusId);
            dynamicRequest.AddProperty("ClaimsStatusId", currentPolicy.ClaimsStatusId);

            using var cts = new CancellationTokenSource();
            cts.CancelAfter(TimeSpan.FromSeconds(SystemDefaultsConfig.Config.ApiTimeoutInSeconds));
            var linkedToken = CancellationTokenSource.CreateLinkedTokenSource(HttpContext.RequestAborted, cts.Token).Token;

            var result = await transactionV1Service.PutIndividualPolicy(dynamicRequest.Properties, linkedToken);
            if (result.IsSuccess)
            {
                LogHelper.LoInformation(StatusCodes.Status200OK, endpointName, result.Message);
                return Ok();
            }

            if (result.Exception != null)
            {
                if (result.Exception.Message.Contains(MessageHelper.CustomSqlException))
                {
                    var message = result.Exception.Message.Replace(MessageHelper.CustomSqlException, "");
                    LogHelper.LogWarning(StatusCodes.Status400BadRequest, endpointName, message);
                    return StatusCode(StatusCodes.Status400BadRequest, message);
                }
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

    [HttpDelete("individual-policy")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status408RequestTimeout)]
    [ProducesResponseType(StatusCodes.Status500InternalServerError)]
    public async Task<IActionResult> DeleteIndividualPolicy([FromQuery] long id)
    {
        if (!HttpContext.User.Identity!.IsAuthenticated)
        {
            return StatusCode(StatusCodes.Status401Unauthorized);
        }

        var endpointName = $"{HttpContext.Request.Method} {ControllerContext.ActionDescriptor.ActionName}";

        #region Validation
        var request = new PutIndividualPolicy
        {
            Id = id
        };
        var inputValidationCollection = new List<ValidationCollection>
    {
        new() { Field = () => request.Id, Action = ValidationHelper.Action.CheckLong }
    };
        var inputValidationResultSet = ValidationHelper.ValidateInputs(inputValidationCollection, referenceV1Repository);
        if (!inputValidationResultSet.IsValid)
        {
            LogHelper.LogWarning(StatusCodes.Status400BadRequest, endpointName, inputValidationResultSet.Message);
            return StatusCode(StatusCodes.Status400BadRequest, inputValidationResultSet.Message);
        }
        #endregion

        try
        {
            var user = GlobalFunctionsHelper.GetUser(HttpContext);
            var dynamicRequest = new DynamicObjectWithTypes();
            dynamicRequest.AddClassPropertiesToDynamicObject(request, dynamicRequest);
            dynamicRequest.AddProperty("UserId", user.Id);
            dynamicRequest.AddProperty("IsDeleted", true);

            using var cts = new CancellationTokenSource();
            cts.CancelAfter(TimeSpan.FromSeconds(SystemDefaultsConfig.Config.ApiTimeoutInSeconds));
            var linkedToken = CancellationTokenSource.CreateLinkedTokenSource(HttpContext.RequestAborted, cts.Token).Token;

            var result = await transactionV1Service.PutIndividualPolicy(dynamicRequest.Properties, linkedToken);
            if (result.IsSuccess)
            {
                LogHelper.LoInformation(StatusCodes.Status200OK, endpointName, result.Message);
                return Ok();
            }

            if (result.Exception != null)
            {
                if (result.Exception.Message.Contains(MessageHelper.CustomSqlException))
                {
                    var message = result.Exception.Message.Replace(MessageHelper.CustomSqlException, "");
                    LogHelper.LogWarning(StatusCodes.Status400BadRequest, endpointName, message);
                    return StatusCode(StatusCodes.Status400BadRequest, message);
                }
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

    #region Partner Policy

    [HttpGet("partner-policy")]
    [ProducesResponseType(typeof(IEnumerable<PartnerPolicy>), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status408RequestTimeout)]
    [ProducesResponseType(StatusCodes.Status500InternalServerError)]
    public async Task<IActionResult> GetPartnerPolicy([FromQuery] long? id, string? referenceNumber, string? cocNumber, long? partnersId, bool? issueStatus,
        [FromQuery] List<long>? policyBookingStatusId, [FromQuery] List<long>? cocStatusId, [FromQuery] List<long>? paymentStatusId, [FromQuery] List<long>? claimsStatusId, int pageNumber = 1, int pageSize = 10)
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

            var result = await transactionV1Service.GetPartnerPolicy(id, referenceNumber, cocNumber, partnersId, issueStatus,
                GlobalFunctionsHelper.ToCommaSeparatedString(policyBookingStatusId),
                GlobalFunctionsHelper.ToCommaSeparatedString(cocStatusId),
                GlobalFunctionsHelper.ToCommaSeparatedString(paymentStatusId),
                GlobalFunctionsHelper.ToCommaSeparatedString(claimsStatusId),
                linkedToken, // Moved linkedToken here
                pageNumber, pageSize);
            if (result.IsSuccess)
            {
                var filters = new
                {
                    Id = id,
                    ReferenceNumber = referenceNumber,
                    CocNumber = cocNumber,
                    PartnersId = partnersId,
                    IssueStatus = issueStatus,
                    PolicyBookingStatusId = policyBookingStatusId,
                    CocStatusId = cocStatusId,
                    PaymentStatusId = paymentStatusId,
                    ClaimsStatusId = claimsStatusId
                };
                var response = GlobalFunctionsHelper.CreatePagedResponse(result.Data!, result.Message, filters, pageNumber, pageSize);
                LogHelper.LoInformation(StatusCodes.Status200OK, endpointName, MessageHelper.Success.Generic);
                return Ok(response);
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

    [HttpGet("partner-policy-view")]
    [ProducesResponseType(typeof(IEnumerable<PartnerPolicyView>), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status408RequestTimeout)]
    [ProducesResponseType(StatusCodes.Status500InternalServerError)]
    public async Task<IActionResult> GetPartnerPolicyView([FromQuery] long? id, string? referenceNumber, string? cocNumber, long? partnersId, bool? issueStatus,
        [FromQuery] List<long>? policyBookingStatusId, [FromQuery] List<long>? cocStatusId, [FromQuery] List<long>? paymentStatusId, [FromQuery] List<long>? claimsStatusId, string? partnersCode, int pageNumber = 1, int pageSize = 10)
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

            var result = await transactionV1Service.GetPartnerPolicyView(id, referenceNumber, cocNumber, partnersId, issueStatus,
                GlobalFunctionsHelper.ToCommaSeparatedString(policyBookingStatusId),
                GlobalFunctionsHelper.ToCommaSeparatedString(cocStatusId),
                GlobalFunctionsHelper.ToCommaSeparatedString(paymentStatusId),
                GlobalFunctionsHelper.ToCommaSeparatedString(claimsStatusId),
                partnersCode, linkedToken, // Moved linkedToken here
                pageNumber, pageSize);
            if (result.IsSuccess)
            {
                var filters = new
                {
                    Id = id,
                    ReferenceNumber = referenceNumber,
                    CocNumber = cocNumber,
                    PartnersId = partnersId,
                    IssueStatus = issueStatus,
                    PolicyBookingStatusId = policyBookingStatusId,
                    CocStatusId = cocStatusId,
                    PaymentStatusId = paymentStatusId,
                    ClaimsStatusId = claimsStatusId,
                    PartnersCode = partnersCode // Added PartnersCode
                };
                var response = GlobalFunctionsHelper.CreatePagedResponse(result.Data!, result.Message, filters, pageNumber, pageSize);
                LogHelper.LoInformation(StatusCodes.Status200OK, endpointName, MessageHelper.Success.Generic);
                return Ok(response);
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

    [HttpPost("partner-policy")]
    [ProducesResponseType(typeof(PostId), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status408RequestTimeout)]
    [ProducesResponseType(StatusCodes.Status500InternalServerError)]
    public async Task<IActionResult> PostPartnerPolicy([FromBody] PostPartnerPolicy request)
    {
        if (!HttpContext.User.Identity!.IsAuthenticated)
        {
            return StatusCode(StatusCodes.Status401Unauthorized);
        }

        var endpointName = $"{HttpContext.Request.Method} {ControllerContext.ActionDescriptor.ActionName}";

        #region Validation Batch 1

        var inputValidationCollection1 = new List<ValidationCollection>
    {
        new() { Field = () => request.PartnersId, Action = ValidationHelper.Action.ReferenceData.Partners },
        new() { Field = () => request.AgentsId, Action = ValidationHelper.Action.ReferenceData.Agents },
        new() { Field = () => request.ApproversId, Action = ValidationHelper.Action.ReferenceData.Approvers },
        new() { Field = () => request.ProductsId, Action = ValidationHelper.Action.ReferenceData.Products },
        new() { Field = () => request.ProvidersId, Action = ValidationHelper.Action.ReferenceData.Providers },
        new() { Field = () => request.DistributionChannelId, Action = ValidationHelper.Action.ReferenceData.DistributionChannel },
        new() { Field = () => request.PaymentOptionId, Action = ValidationHelper.Action.ReferenceData.SelectionList, SelectionTypeId = StaticDataHelper.SelectionType.PaymentOption.Id },
        new() { Field = () => request.ProviderPolicyNo, Action = ValidationHelper.Action.CheckString, Pattern = ValidationHelper.RegexPatterns.AlphaNumericDash, MaxLength = 50 },
        new() { Field = () => request.EndorsementNo!, Action = ValidationHelper.Action.CheckString, Pattern = ValidationHelper.RegexPatterns.AlphaNumericDash, MaxLength = 50, IsNullable = true },
        new() { Field = () => request.TerminationDate, Action = ValidationHelper.Action.CheckDate },
        new() { Field = () => request.EffectiveDate, Action = ValidationHelper.Action.CheckDate },
        new() { Field = () => request.IssueDate, Action = ValidationHelper.Action.CheckDate },
        new() { Field = () => request.Remarks!, Action = ValidationHelper.Action.CheckString, MaxLength = 500, IsNullable = true},

        //Premiums
        new() { Field = () => request.BasicPremium, Action = ValidationHelper.Action.CheckDecimal },
        new() { Field = () => request.BasicPremiumCommission, Action = ValidationHelper.Action.CheckDecimal },
        new() { Field = () => request.DJDPatricioMarkup, Action = ValidationHelper.Action.CheckDecimal },
        new() { Field = () => request.PartnerMarkup, Action = ValidationHelper.Action.CheckDecimal },
        new() { Field = () => request.Discount, Action = ValidationHelper.Action.CheckDecimal },
        new() { Field = () => request.Taxes, Action = ValidationHelper.Action.CheckDecimal },
        new() { Field = () => request.DST, Action = ValidationHelper.Action.CheckDecimal },
        new() { Field = () => request.VAT, Action = ValidationHelper.Action.CheckDecimal },
        new() { Field = () => request.LGT, Action = ValidationHelper.Action.CheckDecimal },
        new() { Field = () => request.PT, Action = ValidationHelper.Action.CheckDecimal },
        new() { Field = () => request.FST, Action = ValidationHelper.Action.CheckDecimal },
        new() { Field = () => request.NotarialFee, Action = ValidationHelper.Action.CheckDecimal },
        new() { Field = () => request.Others, Action = ValidationHelper.Action.CheckDecimal },
        new() { Field = () => request.PremiumsRemarks!, Action = ValidationHelper.Action.CheckString, MaxLength = 500, IsNullable = true}
    };
        var inputValidationResultSet1 = ValidationHelper.ValidateInputs(inputValidationCollection1, referenceV1Repository);
        if (!inputValidationResultSet1.IsValid)
        {
            LogHelper.LogWarning(StatusCodes.Status400BadRequest, endpointName, inputValidationResultSet1.Message);
            return StatusCode(StatusCodes.Status400BadRequest, inputValidationResultSet1.Message);
        }

        #endregion

        #region Validation Batch 2

        var inputValidationCollection2 = new List<ValidationCollection>();

        //DistributionChannelWithPromoSalesOption
        if (StaticDataHelper.DistributionChannelWithPromoSalesOption.ContainsValue(request.DistributionChannelId))
        {
            inputValidationCollection2.Add(new ValidationCollection { Field = () => request.PromoManagersId!, Action = ValidationHelper.Action.ReferenceData.PromoManagers });
            inputValidationCollection2.Add(new ValidationCollection { Field = () => request.PromoOfficersId!, Action = ValidationHelper.Action.ReferenceData.PromoOfficers, IsNullable = true });
            inputValidationCollection2.Add(new ValidationCollection { Field = () => request.SalesManagersId!, Action = ValidationHelper.Action.ReferenceData.SalesManagers });
            request.SubAgentsId = null;
        }
        else
        {
            request.PromoManagersId = null;
            request.PromoOfficersId = null;
            request.SalesManagersId = null;
            inputValidationCollection2.Add(new ValidationCollection { Field = () => request.SubAgentsId!, Action = ValidationHelper.Action.ReferenceData.SubAgents, IsNullable = true });
        }

        var inputValidationResultSet2 = ValidationHelper.ValidateInputs(inputValidationCollection2, referenceV1Repository);
        if (!inputValidationResultSet2.IsValid)
        {
            LogHelper.LogWarning(StatusCodes.Status400BadRequest, endpointName, inputValidationResultSet2.Message);
            return StatusCode(StatusCodes.Status400BadRequest, inputValidationResultSet2.Message);
        }

        #endregion

        try
        {
            var user = GlobalFunctionsHelper.GetUser(HttpContext);
            var dynamicRequest = new DynamicObjectWithTypes();
            dynamicRequest.AddClassPropertiesToDynamicObject(request, dynamicRequest);
            dynamicRequest.AddProperty("UserId", user.Id);
            dynamicRequest.AddProperty("PlatformsId", StaticDataHelper.Platforms.IMS3.Id);
            dynamicRequest.AddProperty("PolicyBookingStatusId", StaticDataHelper.PolicyBookingStatus.Pending.Id);
            dynamicRequest.AddProperty("CocStatusId", StaticDataHelper.CocStatus.Active.Id);
            dynamicRequest.AddProperty("ClaimsStatusId", StaticDataHelper.ClaimsStatus.Processing.Id);

            using var cts = new CancellationTokenSource();
            cts.CancelAfter(TimeSpan.FromSeconds(SystemDefaultsConfig.Config.ApiTimeoutInSeconds));
            var linkedToken = CancellationTokenSource.CreateLinkedTokenSource(HttpContext.RequestAborted, cts.Token).Token;

            var result = await transactionV1Service.PostPartnerPolicy(dynamicRequest.Properties, linkedToken);
            if (result.IsSuccess)
            {
                LogHelper.LoInformation(StatusCodes.Status200OK, endpointName, result.Message);
                return Ok(result.Data);
            }

            if (result.Exception != null)
            {
                if (result.Exception.Message.Contains(MessageHelper.CustomSqlException))
                {
                    var message = result.Exception.Message.Replace(MessageHelper.CustomSqlException, "");
                    LogHelper.LogWarning(StatusCodes.Status400BadRequest, endpointName, message);
                    return StatusCode(StatusCodes.Status400BadRequest, message);
                }
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

    [HttpPut("partner-policy")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status408RequestTimeout)]
    [ProducesResponseType(StatusCodes.Status500InternalServerError)]
    public async Task<IActionResult> PutPartnerPolicy([FromBody] PutPartnerPolicy request)
    {
        if (!HttpContext.User.Identity!.IsAuthenticated)
        {
            return StatusCode(StatusCodes.Status401Unauthorized);
        }

        var endpointName = $"{HttpContext.Request.Method} {ControllerContext.ActionDescriptor.ActionName}";

        #region Validation Batch 1

        var inputValidationCollection1 = new List<ValidationCollection>
    {
        new() { Field = () => request.Id, Action = ValidationHelper.Action.CheckLong },
        new() { Field = () => request.AgentsId, Action = ValidationHelper.Action.ReferenceData.Agents },
        new() { Field = () => request.ApproversId, Action = ValidationHelper.Action.ReferenceData.Approvers },
        new() { Field = () => request.Remarks!, Action = ValidationHelper.Action.CheckString, MaxLength = 500, IsNullable = true},

        //Premiums
        new() { Field = () => request.BasicPremium, Action = ValidationHelper.Action.CheckDecimal },
        new() { Field = () => request.BasicPremiumCommission, Action = ValidationHelper.Action.CheckDecimal },
        new() { Field = () => request.DJDPatricioMarkup, Action = ValidationHelper.Action.CheckDecimal },
        new() { Field = () => request.PartnerMarkup, Action = ValidationHelper.Action.CheckDecimal },
        new() { Field = () => request.Discount, Action = ValidationHelper.Action.CheckDecimal },
        new() { Field = () => request.Taxes, Action = ValidationHelper.Action.CheckDecimal },
        new() { Field = () => request.DST, Action = ValidationHelper.Action.CheckDecimal },
        new() { Field = () => request.VAT, Action = ValidationHelper.Action.CheckDecimal },
        new() { Field = () => request.LGT, Action = ValidationHelper.Action.CheckDecimal },
        new() { Field = () => request.PT, Action = ValidationHelper.Action.CheckDecimal },
        new() { Field = () => request.FST, Action = ValidationHelper.Action.CheckDecimal },
        new() { Field = () => request.NotarialFee, Action = ValidationHelper.Action.CheckDecimal },
        new() { Field = () => request.Others, Action = ValidationHelper.Action.CheckDecimal },
        new() { Field = () => request.PremiumsRemarks!, Action = ValidationHelper.Action.CheckString, MaxLength = 500, IsNullable = true}
    };
        var inputValidationResultSet1 = ValidationHelper.ValidateInputs(inputValidationCollection1, referenceV1Repository);
        if (!inputValidationResultSet1.IsValid)
        {
            LogHelper.LogWarning(StatusCodes.Status400BadRequest, endpointName, inputValidationResultSet1.Message);
            return StatusCode(StatusCodes.Status400BadRequest, inputValidationResultSet1.Message);
        }

        #endregion

        #region Validation Batch 2

        var currentPolicyResult = await transactionV1Repository.GetPartnerPolicy(request.Id, null, null, null, null, null, null, null, null);
        PartnerPolicy currentPolicy;
        if (currentPolicyResult.IsSuccess)
        {
            if (currentPolicyResult.Data != null)
            {
                if (currentPolicyResult.Data.ToList().Count != 0)
                {
                    currentPolicy = currentPolicyResult.Data.First();
                }
                else
                {
                    LogHelper.LogWarning(StatusCodes.Status400BadRequest, endpointName, MessageHelper.Error.Policy.PolicyNotFound);
                    return StatusCode(StatusCodes.Status400BadRequest, MessageHelper.Error.Policy.PolicyNotFound);
                }
            }
            else
            {
                LogHelper.LogWarning(StatusCodes.Status400BadRequest, endpointName, MessageHelper.Error.Policy.PolicyNotFound);
                return StatusCode(StatusCodes.Status400BadRequest, MessageHelper.Error.Policy.PolicyNotFound);
            }
        }
        else
        {
            if (currentPolicyResult.Exception != null)
            {
                if (currentPolicyResult.Exception.Message.Contains(MessageHelper.CustomSqlException))
                {
                    var message = currentPolicyResult.Exception.Message.Replace(MessageHelper.CustomSqlException, "");
                    LogHelper.LogWarning(StatusCodes.Status400BadRequest, endpointName, message);
                    return StatusCode(StatusCodes.Status400BadRequest, message);
                }
            }

            LogHelper.LogError(endpointName, currentPolicyResult.Message, currentPolicyResult.Exception);
            return StatusCode(StatusCodes.Status500InternalServerError);
        }

        var inputValidationCollection2 = new List<ValidationCollection>();

        //DistributionChannelWithPromoSalesOption
        if (StaticDataHelper.DistributionChannelWithPromoSalesOption.ContainsValue(currentPolicy.DistributionChannelId))
        {
            inputValidationCollection2.Add(new ValidationCollection { Field = () => request.PromoManagersId!, Action = ValidationHelper.Action.ReferenceData.PromoManagers });
            inputValidationCollection2.Add(new ValidationCollection { Field = () => request.PromoOfficersId!, Action = ValidationHelper.Action.ReferenceData.PromoOfficers, IsNullable = true });
            inputValidationCollection2.Add(new ValidationCollection { Field = () => request.SalesManagersId!, Action = ValidationHelper.Action.ReferenceData.SalesManagers });
            request.SubAgentsId = null;
        }
        else
        {
            request.PromoManagersId = null;
            request.PromoOfficersId = null;
            request.SalesManagersId = null;
            inputValidationCollection2.Add(new ValidationCollection { Field = () => request.SubAgentsId!, Action = ValidationHelper.Action.ReferenceData.SubAgents, IsNullable = true });
        }

        var inputValidationResultSet2 = ValidationHelper.ValidateInputs(inputValidationCollection2, referenceV1Repository);
        if (!inputValidationResultSet2.IsValid)
        {
            LogHelper.LogWarning(StatusCodes.Status400BadRequest, endpointName, inputValidationResultSet2.Message);
            return StatusCode(StatusCodes.Status400BadRequest, inputValidationResultSet2.Message);
        }

        #endregion

        try
        {
            var user = GlobalFunctionsHelper.GetUser(HttpContext);
            var dynamicRequest = new DynamicObjectWithTypes();
            dynamicRequest.AddClassPropertiesToDynamicObject(request, dynamicRequest);
            dynamicRequest.AddProperty("UserId", user.Id);
            dynamicRequest.AddProperty("IssueStatus", currentPolicy.IssueStatus);
            dynamicRequest.AddProperty("PolicyBookingStatusId", currentPolicy.PolicyBookingStatusId);
            dynamicRequest.AddProperty("CocStatusId", currentPolicy.CocStatusId);
            dynamicRequest.AddProperty("ClaimsStatusId", currentPolicy.ClaimsStatusId);

            using var cts = new CancellationTokenSource();
            cts.CancelAfter(TimeSpan.FromSeconds(SystemDefaultsConfig.Config.ApiTimeoutInSeconds));
            var linkedToken = CancellationTokenSource.CreateLinkedTokenSource(HttpContext.RequestAborted, cts.Token).Token;

            var result = await transactionV1Service.PutPartnerPolicy(dynamicRequest.Properties, linkedToken);
            if (result.IsSuccess)
            {
                LogHelper.LoInformation(StatusCodes.Status200OK, endpointName, result.Message);
                return Ok();
            }

            if (result.Exception != null)
            {
                if (result.Exception.Message.Contains(MessageHelper.CustomSqlException))
                {
                    var message = result.Exception.Message.Replace(MessageHelper.CustomSqlException, "");
                    LogHelper.LogWarning(StatusCodes.Status400BadRequest, endpointName, message);
                    return StatusCode(StatusCodes.Status400BadRequest, message);
                }
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

    [HttpDelete("partner-policy")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status408RequestTimeout)]
    [ProducesResponseType(StatusCodes.Status500InternalServerError)]
    public async Task<IActionResult> DeletePartnerPolicy([FromQuery] long id)
    {
        if (!HttpContext.User.Identity!.IsAuthenticated)
        {
            return StatusCode(StatusCodes.Status401Unauthorized);
        }

        var endpointName = $"{HttpContext.Request.Method} {ControllerContext.ActionDescriptor.ActionName}";

        #region Validation
        var request = new PutPartnerPolicy
        {
            Id = id
        };
        var inputValidationCollection = new List<ValidationCollection>
    {
        new() { Field = () => request.Id, Action = ValidationHelper.Action.CheckLong }
    };
        var inputValidationResultSet = ValidationHelper.ValidateInputs(inputValidationCollection, referenceV1Repository);
        if (!inputValidationResultSet.IsValid)
        {
            LogHelper.LogWarning(StatusCodes.Status400BadRequest, endpointName, inputValidationResultSet.Message);
            return StatusCode(StatusCodes.Status400BadRequest, inputValidationResultSet.Message);
        }
        #endregion

        try
        {
            var user = GlobalFunctionsHelper.GetUser(HttpContext);
            var dynamicRequest = new DynamicObjectWithTypes();
            dynamicRequest.AddClassPropertiesToDynamicObject(request, dynamicRequest);
            dynamicRequest.AddProperty("UserId", user.Id);
            dynamicRequest.AddProperty("IsDeleted", true);

            using var cts = new CancellationTokenSource();
            cts.CancelAfter(TimeSpan.FromSeconds(SystemDefaultsConfig.Config.ApiTimeoutInSeconds));
            var linkedToken = CancellationTokenSource.CreateLinkedTokenSource(HttpContext.RequestAborted, cts.Token).Token;

            var result = await transactionV1Service.PutPartnerPolicy(dynamicRequest.Properties, linkedToken);
            if (result.IsSuccess)
            {
                LogHelper.LoInformation(StatusCodes.Status200OK, endpointName, result.Message);
                return Ok();
            }

            if (result.Exception != null)
            {
                if (result.Exception.Message.Contains(MessageHelper.CustomSqlException))
                {
                    var message = result.Exception.Message.Replace(MessageHelper.CustomSqlException, "");
                    LogHelper.LogWarning(StatusCodes.Status400BadRequest, endpointName, message);
                    return StatusCode(StatusCodes.Status400BadRequest, message);
                }
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

    #region Policy Beneficiary

    [HttpGet("policy-beneficiary")]
    [ProducesResponseType(typeof(IEnumerable<PolicyBeneficiary>), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status408RequestTimeout)]
    [ProducesResponseType(StatusCodes.Status500InternalServerError)]
    public async Task<IActionResult> GetPolicyBeneficiary([FromQuery] long? id, long? policyId, long? policyTypeId, int pageNumber = 1, int pageSize = 10)
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

            var result = await transactionV1Service.GetPolicyBeneficiary(id, policyId, policyTypeId, linkedToken, pageNumber, pageSize);
            if (result.IsSuccess)
            {
                var filters = new
                {
                    Id = id,
                    PolicyId = policyId,
                    PolicyTypeId = policyTypeId
                };
                var response = GlobalFunctionsHelper.CreatePagedResponse(result.Data!, result.Message, filters, pageNumber, pageSize);
                LogHelper.LoInformation(StatusCodes.Status200OK, endpointName, MessageHelper.Success.Generic);
                return Ok(response);
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

    [HttpGet("policy-beneficiary-view")]
    [ProducesResponseType(typeof(IEnumerable<PolicyBeneficiaryView>), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status408RequestTimeout)]
    [ProducesResponseType(StatusCodes.Status500InternalServerError)]
    public async Task<IActionResult> GetPolicyBeneficiaryView([FromQuery] long? id, long? policyId, long? policyTypeId, int pageNumber = 1, int pageSize = 10)
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

            var result = await transactionV1Service.GetPolicyBeneficiaryView(id, policyId, policyTypeId, linkedToken, pageNumber, pageSize);
            if (result.IsSuccess)
            {
                var filters = new
                {
                    Id = id,
                    PolicyId = policyId,
                    PolicyTypeId = policyTypeId
                };
                var response = GlobalFunctionsHelper.CreatePagedResponse(result.Data!, result.Message, filters, pageNumber, pageSize);
                LogHelper.LoInformation(StatusCodes.Status200OK, endpointName, MessageHelper.Success.Generic);
                return Ok(response);
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

    [HttpPost("policy-beneficiary")]
    [ProducesResponseType(typeof(PostId), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status408RequestTimeout)]
    [ProducesResponseType(StatusCodes.Status500InternalServerError)]
    public async Task<IActionResult> PostPolicyBeneficiary([FromBody] PostPolicyBeneficiary request)
    {
        if (!HttpContext.User.Identity!.IsAuthenticated)
        {
            return StatusCode(StatusCodes.Status401Unauthorized);
        }

        var endpointName = $"{HttpContext.Request.Method} {ControllerContext.ActionDescriptor.ActionName}";

        #region Validation
        var inputValidationCollection = new List<ValidationCollection>
    {
        new() { Field = () => request.PolicyId, Action = ValidationHelper.Action.CheckLong },
        new() { Field = () => request.PolicyTypeId, Action = ValidationHelper.Action.StaticData.PolicyType },
        new() { Field = () => request.FirstName, Action = ValidationHelper.Action.CheckString, Pattern = ValidationHelper.RegexPatterns.AlphaNumericDotDashApostrophe, MaxLength = 60 },
        new() { Field = () => request.MiddleName!, Action = ValidationHelper.Action.CheckString, Pattern = ValidationHelper.RegexPatterns.AlphaNumericDotDashApostrophe, MaxLength = 60, IsNullable = true },
        new() { Field = () => request.LastName, Action = ValidationHelper.Action.CheckString, Pattern = ValidationHelper.RegexPatterns.AlphaNumericDotDashApostrophe, MaxLength = 60 },
        new() { Field = () => request.Suffix!, Action = ValidationHelper.Action.CheckString, Pattern = ValidationHelper.RegexPatterns.AlphaNumericDotDashApostrophe, MaxLength = 10, IsNullable = true },
        new() { Field = () => request.ContactNumber, Action = ValidationHelper.Action.CheckString, Pattern = ValidationHelper.RegexPatterns.Custom.ContactNumberPh, MaxLength = 13, MinLength = 13 },
        new() { Field = () => request.EmailAddress, Action = ValidationHelper.Action.CheckString, Pattern = ValidationHelper.RegexPatterns.EmailAddress, MaxLength = 100 },
        new() { Field = () => request.DateOfBirth, Action = ValidationHelper.Action.CheckDate },
        new() { Field = () => request.Relationship, Action = ValidationHelper.Action.ReferenceData.SelectionList, SelectionTypeId = StaticDataHelper.SelectionType.Relationship.Id }
    };
        var inputValidationResultSet = ValidationHelper.ValidateInputs(inputValidationCollection, referenceV1Repository);
        if (!inputValidationResultSet.IsValid)
        {
            LogHelper.LogWarning(StatusCodes.Status400BadRequest, endpointName, inputValidationResultSet.Message);
            return StatusCode(StatusCodes.Status400BadRequest, inputValidationResultSet.Message);
        }
        #endregion

        try
        {
            var user = GlobalFunctionsHelper.GetUser(HttpContext);
            var dynamicRequest = new DynamicObjectWithTypes();
            dynamicRequest.AddClassPropertiesToDynamicObject(request, dynamicRequest);
            dynamicRequest.AddProperty("UserId", user.Id);

            using var cts = new CancellationTokenSource();
            cts.CancelAfter(TimeSpan.FromSeconds(SystemDefaultsConfig.Config.ApiTimeoutInSeconds));
            var linkedToken = CancellationTokenSource.CreateLinkedTokenSource(HttpContext.RequestAborted, cts.Token).Token;

            var result = await transactionV1Service.PostPolicyBeneficiary(dynamicRequest.Properties, linkedToken);
            if (result.IsSuccess)
            {
                LogHelper.LoInformation(StatusCodes.Status200OK, endpointName, result.Message);
                return Ok(result.Data);
            }

            if (result.Exception != null)
            {
                if (result.Exception.Message.Contains(MessageHelper.CustomSqlException))
                {
                    var message = result.Exception.Message.Replace(MessageHelper.CustomSqlException, "");
                    LogHelper.LogWarning(StatusCodes.Status400BadRequest, endpointName, message);
                    return StatusCode(StatusCodes.Status400BadRequest, message);
                }
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

    [HttpPut("policy-beneficiary")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status408RequestTimeout)]
    [ProducesResponseType(StatusCodes.Status500InternalServerError)]
    public async Task<IActionResult> PutPolicyBeneficiary([FromBody] PutPolicyBeneficiary request)
    {
        if (!HttpContext.User.Identity!.IsAuthenticated)
        {
            return StatusCode(StatusCodes.Status401Unauthorized);
        }

        var endpointName = $"{HttpContext.Request.Method} {ControllerContext.ActionDescriptor.ActionName}";

        #region Validation
        var inputValidationCollection = new List<ValidationCollection>
    {
        new() { Field = () => request.Id, Action = ValidationHelper.Action.CheckLong },
        new() { Field = () => request.FirstName, Action = ValidationHelper.Action.CheckString, Pattern = ValidationHelper.RegexPatterns.AlphaNumericDotDashApostrophe, MaxLength = 60 },
        new() { Field = () => request.MiddleName!, Action = ValidationHelper.Action.CheckString, Pattern = ValidationHelper.RegexPatterns.AlphaNumericDotDashApostrophe, MaxLength = 60, IsNullable = true },
        new() { Field = () => request.LastName, Action = ValidationHelper.Action.CheckString, Pattern = ValidationHelper.RegexPatterns.AlphaNumericDotDashApostrophe, MaxLength = 60 },
        new() { Field = () => request.Suffix!, Action = ValidationHelper.Action.CheckString, Pattern = ValidationHelper.RegexPatterns.AlphaNumericDotDashApostrophe, MaxLength = 10, IsNullable = true },
        new() { Field = () => request.ContactNumber, Action = ValidationHelper.Action.CheckString, Pattern = ValidationHelper.RegexPatterns.Custom.ContactNumberPh, MaxLength = 13, MinLength = 13 },
        new() { Field = () => request.EmailAddress, Action = ValidationHelper.Action.CheckString, Pattern = ValidationHelper.RegexPatterns.EmailAddress, MaxLength = 100 },
        new() { Field = () => request.DateOfBirth, Action = ValidationHelper.Action.CheckDate },
        new() { Field = () => request.Relationship, Action = ValidationHelper.Action.ReferenceData.SelectionList, SelectionTypeId = StaticDataHelper.SelectionType.Relationship.Id }
    };
        var inputValidationResultSet = ValidationHelper.ValidateInputs(inputValidationCollection, referenceV1Repository);
        if (!inputValidationResultSet.IsValid)
        {
            LogHelper.LogWarning(StatusCodes.Status400BadRequest, endpointName, inputValidationResultSet.Message);
            return StatusCode(StatusCodes.Status400BadRequest, inputValidationResultSet.Message);
        }
        #endregion

        try
        {
            var user = GlobalFunctionsHelper.GetUser(HttpContext);
            var dynamicRequest = new DynamicObjectWithTypes();
            dynamicRequest.AddClassPropertiesToDynamicObject(request, dynamicRequest);
            dynamicRequest.AddProperty("UserId", user.Id);

            using var cts = new CancellationTokenSource();
            cts.CancelAfter(TimeSpan.FromSeconds(SystemDefaultsConfig.Config.ApiTimeoutInSeconds));
            var linkedToken = CancellationTokenSource.CreateLinkedTokenSource(HttpContext.RequestAborted, cts.Token).Token;

            var result = await transactionV1Service.PutPolicyBeneficiary(dynamicRequest.Properties, linkedToken);
            if (result.IsSuccess)
            {
                LogHelper.LoInformation(StatusCodes.Status200OK, endpointName, result.Message);
                return Ok();
            }

            if (result.Exception != null)
            {
                if (result.Exception.Message.Contains(MessageHelper.CustomSqlException))
                {
                    var message = result.Exception.Message.Replace(MessageHelper.CustomSqlException, "");
                    LogHelper.LogWarning(StatusCodes.Status400BadRequest, endpointName, message);
                    return StatusCode(StatusCodes.Status400BadRequest, message);
                }
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

    [HttpDelete("policy-beneficiary")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status408RequestTimeout)]
    [ProducesResponseType(StatusCodes.Status500InternalServerError)]
    public async Task<IActionResult> DeletePolicyBeneficiary([FromQuery] long id)
    {
        if (!HttpContext.User.Identity!.IsAuthenticated)
        {
            return StatusCode(StatusCodes.Status401Unauthorized);
        }

        var endpointName = $"{HttpContext.Request.Method} {ControllerContext.ActionDescriptor.ActionName}";

        #region Validation
        var request = new PutPolicyBeneficiary
        {
            Id = id
        };
        var inputValidationCollection = new List<ValidationCollection>
    {
        new() { Field = () => request.Id, Action = ValidationHelper.Action.CheckLong }
    };
        var inputValidationResultSet = ValidationHelper.ValidateInputs(inputValidationCollection, referenceV1Repository);
        if (!inputValidationResultSet.IsValid)
        {
            LogHelper.LogWarning(StatusCodes.Status400BadRequest, endpointName, inputValidationResultSet.Message);
            return StatusCode(StatusCodes.Status400BadRequest, inputValidationResultSet.Message);
        }
        #endregion

        try
        {
            var user = GlobalFunctionsHelper.GetUser(HttpContext);
            var dynamicRequest = new DynamicObjectWithTypes();
            dynamicRequest.AddClassPropertiesToDynamicObject(request, dynamicRequest);
            dynamicRequest.AddProperty("UserId", user.Id);
            dynamicRequest.AddProperty("IsDeleted", true);

            using var cts = new CancellationTokenSource();
            cts.CancelAfter(TimeSpan.FromSeconds(SystemDefaultsConfig.Config.ApiTimeoutInSeconds));
            var linkedToken = CancellationTokenSource.CreateLinkedTokenSource(HttpContext.RequestAborted, cts.Token).Token;

            var result = await transactionV1Service.PutPolicyBeneficiary(dynamicRequest.Properties, linkedToken);
            if (result.IsSuccess)
            {
                LogHelper.LoInformation(StatusCodes.Status200OK, endpointName, result.Message);
                return Ok();
            }

            if (result.Exception != null)
            {
                if (result.Exception.Message.Contains(MessageHelper.CustomSqlException))
                {
                    var message = result.Exception.Message.Replace(MessageHelper.CustomSqlException, "");
                    LogHelper.LogWarning(StatusCodes.Status400BadRequest, endpointName, message);
                    return StatusCode(StatusCodes.Status400BadRequest, message);
                }
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

    #region Policy Benefits

    [HttpGet("policy-benefits")]
    [ProducesResponseType(typeof(IEnumerable<PolicyBenefits>), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status408RequestTimeout)]
    [ProducesResponseType(StatusCodes.Status500InternalServerError)]
    public async Task<IActionResult> GetPolicyBenefits([FromQuery] long? id, long? policyId, long? policyTypeId, int pageNumber = 1, int pageSize = 10)
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

            var result = await transactionV1Service.GetPolicyBenefits(id, policyId, policyTypeId, linkedToken, pageNumber, pageSize);
            if (result.IsSuccess)
            {
                var filters = new
                {
                    Id = id,
                    PolicyId = policyId,
                    PolicyTypeId = policyTypeId
                };
                var response = GlobalFunctionsHelper.CreatePagedResponse(result.Data!, result.Message, filters, pageNumber, pageSize);
                LogHelper.LoInformation(StatusCodes.Status200OK, endpointName, MessageHelper.Success.Generic);
                return Ok(response);
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

    [HttpGet("policy-benefits-view")]
    [ProducesResponseType(typeof(IEnumerable<PolicyBenefitsView>), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status408RequestTimeout)]
    [ProducesResponseType(StatusCodes.Status500InternalServerError)]
    public async Task<IActionResult> GetPolicyBenefitsView([FromQuery] long? id, long? policyId, long? policyTypeId, int pageNumber = 1, int pageSize = 10)
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

            var result = await transactionV1Service.GetPolicyBenefitsView(id, policyId, policyTypeId, linkedToken, pageNumber, pageSize);
            if (result.IsSuccess)
            {
                var filters = new
                {
                    Id = id,
                    PolicyId = policyId,
                    PolicyTypeId = policyTypeId
                };
                var response = GlobalFunctionsHelper.CreatePagedResponse(result.Data!, result.Message, filters, pageNumber, pageSize);
                LogHelper.LoInformation(StatusCodes.Status200OK, endpointName, MessageHelper.Success.Generic);
                return Ok(response);
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

    [HttpPost("policy-benefits")]
    [ProducesResponseType(typeof(PostId), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status408RequestTimeout)]
    [ProducesResponseType(StatusCodes.Status500InternalServerError)]
    public async Task<IActionResult> PostPolicyBenefits([FromBody] PostPolicyBenefits request)
    {
        if (!HttpContext.User.Identity!.IsAuthenticated)
        {
            return StatusCode(StatusCodes.Status401Unauthorized);
        }

        var endpointName = $"{HttpContext.Request.Method} {ControllerContext.ActionDescriptor.ActionName}";

        #region Validation
        var inputValidationCollection = new List<ValidationCollection>
    {
        new() { Field = () => request.PolicyId, Action = ValidationHelper.Action.CheckLong },
        new() { Field = () => request.PolicyTypeId, Action = ValidationHelper.Action.StaticData.PolicyType },
        new() { Field = () => request.BenefitsId, Action = ValidationHelper.Action.ReferenceData.Benefits },
        new() { Field = () => request.CoverageAmount, Action = ValidationHelper.Action.CheckDecimal },
        new() { Field = () => request.PremiumAmount, Action = ValidationHelper.Action.CheckDecimal },
        new() { Field = () => request.PremiumCommissionAmount, Action = ValidationHelper.Action.CheckDecimal },
    };
        var inputValidationResultSet = ValidationHelper.ValidateInputs(inputValidationCollection, referenceV1Repository);
        if (!inputValidationResultSet.IsValid)
        {
            LogHelper.LogWarning(StatusCodes.Status400BadRequest, endpointName, inputValidationResultSet.Message);
            return StatusCode(StatusCodes.Status400BadRequest, inputValidationResultSet.Message);
        }
        #endregion

        try
        {
            var user = GlobalFunctionsHelper.GetUser(HttpContext);
            var dynamicRequest = new DynamicObjectWithTypes();
            dynamicRequest.AddClassPropertiesToDynamicObject(request, dynamicRequest);
            dynamicRequest.AddProperty("UserId", user.Id);

            using var cts = new CancellationTokenSource();
            cts.CancelAfter(TimeSpan.FromSeconds(SystemDefaultsConfig.Config.ApiTimeoutInSeconds));
            var linkedToken = CancellationTokenSource.CreateLinkedTokenSource(HttpContext.RequestAborted, cts.Token).Token;

            var result = await transactionV1Service.PostPolicyBenefits(dynamicRequest.Properties, linkedToken);
            if (result.IsSuccess)
            {
                LogHelper.LoInformation(StatusCodes.Status200OK, endpointName, result.Message);
                return Ok(result.Data);
            }

            if (result.Exception != null)
            {
                if (result.Exception.Message.Contains(MessageHelper.CustomSqlException))
                {
                    var message = result.Exception.Message.Replace(MessageHelper.CustomSqlException, "");
                    LogHelper.LogWarning(StatusCodes.Status400BadRequest, endpointName, message);
                    return StatusCode(StatusCodes.Status400BadRequest, message);
                }
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

    #region Policy Deductibles

    [HttpGet("policy-deductibles")]
    [ProducesResponseType(typeof(IEnumerable<PolicyDeductibles>), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status408RequestTimeout)]
    [ProducesResponseType(StatusCodes.Status500InternalServerError)]
    public async Task<IActionResult> GetPolicyDeductibles([FromQuery] long? id, long? policyId, long? policyTypeId, int pageNumber = 1, int pageSize = 10)
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

            var result = await transactionV1Service.GetPolicyDeductibles(id, policyId, policyTypeId, linkedToken, pageNumber, pageSize);
            if (result.IsSuccess)
            {
                var filters = new
                {
                    Id = id,
                    PolicyId = policyId,
                    PolicyTypeId = policyTypeId
                };
                var response = GlobalFunctionsHelper.CreatePagedResponse(result.Data!, result.Message, filters, pageNumber, pageSize);
                LogHelper.LoInformation(StatusCodes.Status200OK, endpointName, MessageHelper.Success.Generic);
                return Ok(response);
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

    [HttpGet("policy-deductibles-view")]
    [ProducesResponseType(typeof(IEnumerable<PolicyDeductiblesView>), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status408RequestTimeout)]
    [ProducesResponseType(StatusCodes.Status500InternalServerError)]
    public async Task<IActionResult> GetPolicyDeductiblesView([FromQuery] long? id, long? policyId, long? policyTypeId, int pageNumber = 1, int pageSize = 10)
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

            var result = await transactionV1Service.GetPolicyDeductiblesView(id, policyId, policyTypeId, linkedToken, pageNumber, pageSize);
            if (result.IsSuccess)
            {
                var filters = new
                {
                    Id = id,
                    PolicyId = policyId,
                    PolicyTypeId = policyTypeId
                };
                var response = GlobalFunctionsHelper.CreatePagedResponse(result.Data!, result.Message, filters, pageNumber, pageSize);
                LogHelper.LoInformation(StatusCodes.Status200OK, endpointName, MessageHelper.Success.Generic);
                return Ok(response);
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

    [HttpPost("policy-deductibles")]
    [ProducesResponseType(typeof(PostId), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status408RequestTimeout)]
    [ProducesResponseType(StatusCodes.Status500InternalServerError)]
    public async Task<IActionResult> PostPolicyDeductibles([FromBody] PostPolicyDeductibles request)
    {
        if (!HttpContext.User.Identity!.IsAuthenticated)
        {
            return StatusCode(StatusCodes.Status401Unauthorized);
        }

        var endpointName = $"{HttpContext.Request.Method} {ControllerContext.ActionDescriptor.ActionName}";

        #region Validation
        var inputValidationCollection = new List<ValidationCollection>
    {
        new() { Field = () => request.PolicyId, Action = ValidationHelper.Action.CheckLong },
        new() { Field = () => request.PolicyTypeId, Action = ValidationHelper.Action.StaticData.PolicyType },
        new() { Field = () => request.DeductiblesId, Action = ValidationHelper.Action.ReferenceData.Deductibles },
        new() { Field = () => request.Amount, Action = ValidationHelper.Action.CheckDecimal },
    };
        var inputValidationResultSet = ValidationHelper.ValidateInputs(inputValidationCollection, referenceV1Repository);
        if (!inputValidationResultSet.IsValid)
        {
            LogHelper.LogWarning(StatusCodes.Status400BadRequest, endpointName, inputValidationResultSet.Message);
            return StatusCode(StatusCodes.Status400BadRequest, inputValidationResultSet.Message);
        }
        #endregion

        try
        {
            var user = GlobalFunctionsHelper.GetUser(HttpContext);
            var dynamicRequest = new DynamicObjectWithTypes();
            dynamicRequest.AddClassPropertiesToDynamicObject(request, dynamicRequest);
            dynamicRequest.AddProperty("UserId", user.Id);

            using var cts = new CancellationTokenSource();
            cts.CancelAfter(TimeSpan.FromSeconds(SystemDefaultsConfig.Config.ApiTimeoutInSeconds));
            var linkedToken = CancellationTokenSource.CreateLinkedTokenSource(HttpContext.RequestAborted, cts.Token).Token;

            var result = await transactionV1Service.PostPolicyDeductibles(dynamicRequest.Properties, linkedToken);
            if (result.IsSuccess)
            {
                LogHelper.LoInformation(StatusCodes.Status200OK, endpointName, result.Message);
                return Ok(result.Data);
            }

            if (result.Exception != null)
            {
                if (result.Exception.Message.Contains(MessageHelper.CustomSqlException))
                {
                    var message = result.Exception.Message.Replace(MessageHelper.CustomSqlException, "");
                    LogHelper.LogWarning(StatusCodes.Status400BadRequest, endpointName, message);
                    return StatusCode(StatusCodes.Status400BadRequest, message);
                }
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

    #region Policy Payments

    [HttpGet("policy-payments")]
    [ProducesResponseType(typeof(IEnumerable<PolicyPayments>), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status408RequestTimeout)]
    [ProducesResponseType(StatusCodes.Status500InternalServerError)]
    public async Task<IActionResult> GetPolicyPayments([FromQuery] long? id, long? policyId, long? policyTypeId, int pageNumber = 1, int pageSize = 10)
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

            var result = await transactionV1Service.GetPolicyPayments(id, policyId, policyTypeId, linkedToken, pageNumber, pageSize);
            if (result.IsSuccess)
            {
                var filters = new
                {
                    Id = id,
                    PolicyId = policyId,
                    PolicyTypeId = policyTypeId
                };
                var response = GlobalFunctionsHelper.CreatePagedResponse(result.Data!, result.Message, filters, pageNumber, pageSize);
                LogHelper.LoInformation(StatusCodes.Status200OK, endpointName, MessageHelper.Success.Generic);
                return Ok(response);
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

    [HttpGet("policy-payments-view")]
    [ProducesResponseType(typeof(IEnumerable<PolicyPaymentsView>), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status408RequestTimeout)]
    [ProducesResponseType(StatusCodes.Status500InternalServerError)]
    public async Task<IActionResult> GetPolicyPaymentsView([FromQuery] long? id, long? policyId, long? policyTypeId, int pageNumber = 1, int pageSize = 10)
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

            var result = await transactionV1Service.GetPolicyPaymentsView(id, policyId, policyTypeId, linkedToken, pageNumber, pageSize);
            if (result.IsSuccess)
            {
                var filters = new
                {
                    Id = id,
                    PolicyId = policyId,
                    PolicyTypeId = policyTypeId
                };
                var response = GlobalFunctionsHelper.CreatePagedResponse(result.Data!, result.Message, filters, pageNumber, pageSize);
                LogHelper.LoInformation(StatusCodes.Status200OK, endpointName, MessageHelper.Success.Generic);
                return Ok(response);
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

    [HttpPost("policy-payments")]
    [ProducesResponseType(typeof(PostId), StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status408RequestTimeout)]
    [ProducesResponseType(StatusCodes.Status500InternalServerError)]
    public async Task<IActionResult> PostPolicyPayments([FromBody] PostPolicyPayments request)
    {
        if (!HttpContext.User.Identity!.IsAuthenticated)
        {
            return StatusCode(StatusCodes.Status401Unauthorized);
        }

        var endpointName = $"{HttpContext.Request.Method} {ControllerContext.ActionDescriptor.ActionName}";

        #region Validation
        var inputValidationCollection = new List<ValidationCollection>
        {
            new() { Field = () => request.PolicyId, Action = ValidationHelper.Action.CheckLong },
            new() { Field = () => request.PolicyTypeId, Action = ValidationHelper.Action.StaticData.PolicyType },
            new() { Field = () => request.Amount, Action = ValidationHelper.Action.CheckDecimal },
            new() { Field = () => request.TransactionDateTime, Action = ValidationHelper.Action.CheckDate },
            new() { Field = () => request.TransactionCheckNo, Action = ValidationHelper.Action.CheckString, MaxLength = 50 },
            new() { Field = () => request.TransactionOrigin, Action = ValidationHelper.Action.CheckString, MaxLength = 50 },
            new() { Field = () => request.NotificationDateTime, Action = ValidationHelper.Action.CheckDate },
            new() { Field = () => request.PaymentMethod, Action = ValidationHelper.Action.ReferenceData.SelectionList, SelectionTypeId = StaticDataHelper.SelectionType.PaymentOption.Id},
            new() { Field = () => request.Notes!, Action = ValidationHelper.Action.CheckString, MaxLength = 500, IsNullable = true},
        };
        var inputValidationResultSet = ValidationHelper.ValidateInputs(inputValidationCollection, referenceV1Repository);
        if (!inputValidationResultSet.IsValid)
        {
            LogHelper.LogWarning(StatusCodes.Status400BadRequest, endpointName, inputValidationResultSet.Message);
            return StatusCode(StatusCodes.Status400BadRequest, inputValidationResultSet.Message);
        }
        #endregion

        try
        {
            var user = GlobalFunctionsHelper.GetUser(HttpContext);
            var dynamicRequest = new DynamicObjectWithTypes();
            dynamicRequest.AddClassPropertiesToDynamicObject(request, dynamicRequest);
            dynamicRequest.AddProperty("UserId", user.Id);

            using var cts = new CancellationTokenSource();
            cts.CancelAfter(TimeSpan.FromSeconds(SystemDefaultsConfig.Config.ApiTimeoutInSeconds));
            var linkedToken = CancellationTokenSource.CreateLinkedTokenSource(HttpContext.RequestAborted, cts.Token).Token;

            var result = await transactionV1Service.PostPolicyPayments(dynamicRequest.Properties, linkedToken);
            if (result.IsSuccess)
            {
                LogHelper.LoInformation(StatusCodes.Status200OK, endpointName, result.Message);
                return Ok(result.Data);
            }

            if (result.Exception != null)
            {
                if (result.Exception.Message.Contains(MessageHelper.CustomSqlException))
                {
                    var message = result.Exception.Message.Replace(MessageHelper.CustomSqlException, "");
                    LogHelper.LogWarning(StatusCodes.Status400BadRequest, endpointName, message);
                    return StatusCode(StatusCodes.Status400BadRequest, message);
                }
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

    [HttpPut("policy-payments")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status408RequestTimeout)]
    [ProducesResponseType(StatusCodes.Status500InternalServerError)]
    public async Task<IActionResult> PutPolicyPayments([FromBody] PutPolicyPayments request)
    {
        if (!HttpContext.User.Identity!.IsAuthenticated)
        {
            return StatusCode(StatusCodes.Status401Unauthorized);
        }

        var endpointName = $"{HttpContext.Request.Method} {ControllerContext.ActionDescriptor.ActionName}";

        #region Validation
        var inputValidationCollection = new List<ValidationCollection>
    {
        new() { Field = () => request.Id, Action = ValidationHelper.Action.CheckLong },
        new() { Field = () => request.Amount, Action = ValidationHelper.Action.CheckDecimal },
        new() { Field = () => request.TransactionDateTime, Action = ValidationHelper.Action.CheckDate },
        new() { Field = () => request.TransactionCheckNo, Action = ValidationHelper.Action.CheckString, MaxLength = 50 },
        new() { Field = () => request.TransactionOrigin, Action = ValidationHelper.Action.CheckString, MaxLength = 50 },
        new() { Field = () => request.NotificationDateTime, Action = ValidationHelper.Action.CheckDate },
        new() { Field = () => request.PaymentMethod, Action = ValidationHelper.Action.ReferenceData.SelectionList, SelectionTypeId = StaticDataHelper.SelectionType.PaymentOption.Id},
        new() { Field = () => request.Notes!, Action = ValidationHelper.Action.CheckString, MaxLength = 500, IsNullable = true},
    };
        var inputValidationResultSet = ValidationHelper.ValidateInputs(inputValidationCollection, referenceV1Repository);
        if (!inputValidationResultSet.IsValid)
        {
            LogHelper.LogWarning(StatusCodes.Status400BadRequest, endpointName, inputValidationResultSet.Message);
            return StatusCode(StatusCodes.Status400BadRequest, inputValidationResultSet.Message);
        }
        #endregion

        try
        {
            var user = GlobalFunctionsHelper.GetUser(HttpContext);
            var dynamicRequest = new DynamicObjectWithTypes();
            dynamicRequest.AddClassPropertiesToDynamicObject(request, dynamicRequest);
            dynamicRequest.AddProperty("UserId", user.Id);

            using var cts = new CancellationTokenSource();
            cts.CancelAfter(TimeSpan.FromSeconds(SystemDefaultsConfig.Config.ApiTimeoutInSeconds));
            var linkedToken = CancellationTokenSource.CreateLinkedTokenSource(HttpContext.RequestAborted, cts.Token).Token;

            var result = await transactionV1Service.PutPolicyPayments(dynamicRequest.Properties, linkedToken);
            if (result.IsSuccess)
            {
                LogHelper.LoInformation(StatusCodes.Status200OK, endpointName, result.Message);
                return Ok();
            }

            if (result.Exception != null)
            {
                if (result.Exception.Message.Contains(MessageHelper.CustomSqlException))
                {
                    var message = result.Exception.Message.Replace(MessageHelper.CustomSqlException, "");
                    LogHelper.LogWarning(StatusCodes.Status400BadRequest, endpointName, message);
                    return StatusCode(StatusCodes.Status400BadRequest, message);
                }
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

    [HttpDelete("policy-payments")]
    [ProducesResponseType(StatusCodes.Status200OK)]
    [ProducesResponseType(StatusCodes.Status401Unauthorized)]
    [ProducesResponseType(StatusCodes.Status400BadRequest)]
    [ProducesResponseType(StatusCodes.Status408RequestTimeout)]
    [ProducesResponseType(StatusCodes.Status500InternalServerError)]
    public async Task<IActionResult> DeletePolicyPayments([FromQuery] long id)
    {
        if (!HttpContext.User.Identity!.IsAuthenticated)
        {
            return StatusCode(StatusCodes.Status401Unauthorized);
        }

        var endpointName = $"{HttpContext.Request.Method} {ControllerContext.ActionDescriptor.ActionName}";

        #region Validation
        var request = new PutPolicyPayments
        {
            Id = id
        };
        var inputValidationCollection = new List<ValidationCollection>
    {
        new() { Field = () => request.Id, Action = ValidationHelper.Action.CheckLong }
    };
        var inputValidationResultSet = ValidationHelper.ValidateInputs(inputValidationCollection, referenceV1Repository);
        if (!inputValidationResultSet.IsValid)
        {
            LogHelper.LogWarning(StatusCodes.Status400BadRequest, endpointName, inputValidationResultSet.Message);
            return StatusCode(StatusCodes.Status400BadRequest, inputValidationResultSet.Message);
        }
        #endregion

        try
        {
            var user = GlobalFunctionsHelper.GetUser(HttpContext);
            var dynamicRequest = new DynamicObjectWithTypes();
            dynamicRequest.AddClassPropertiesToDynamicObject(request, dynamicRequest);
            dynamicRequest.AddProperty("UserId", user.Id);
            dynamicRequest.AddProperty("IsDeleted", true);

            using var cts = new CancellationTokenSource();
            cts.CancelAfter(TimeSpan.FromSeconds(SystemDefaultsConfig.Config.ApiTimeoutInSeconds));
            var linkedToken = CancellationTokenSource.CreateLinkedTokenSource(HttpContext.RequestAborted, cts.Token).Token;

            var result = await transactionV1Service.PutPolicyPayments(dynamicRequest.Properties, linkedToken);
            if (result.IsSuccess)
            {
                LogHelper.LoInformation(StatusCodes.Status200OK, endpointName, result.Message);
                return Ok();
            }

            if (result.Exception != null)
            {
                if (result.Exception.Message.Contains(MessageHelper.CustomSqlException))
                {
                    var message = result.Exception.Message.Replace(MessageHelper.CustomSqlException, "");
                    LogHelper.LogWarning(StatusCodes.Status400BadRequest, endpointName, message);
                    return StatusCode(StatusCodes.Status400BadRequest, message);
                }
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