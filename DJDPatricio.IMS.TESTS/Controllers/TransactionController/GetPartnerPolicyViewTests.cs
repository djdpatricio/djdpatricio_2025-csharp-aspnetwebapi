using System.Security.Claims;
using DJDPatricio.IMS.API.Models;
using DJDPatricio.IMS.API.Models.Result;
using DJDPatricio.IMS.API.Models.Result.Transaction;
using DJDPatricio.IMS.API.Repository.Interface.V1;
using DJDPatricio.IMS.API.Service.Interface.V1;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Moq;

namespace DJDPatricio.IMS.TESTS.Controllers.TransactionController;

public class GetPartnerPolicyViewTests
{
    private readonly Mock<ITransactionV1Service> _mockTransactionV1Service;
    private readonly API.Controllers.TransactionController _controller;

    public GetPartnerPolicyViewTests()
    {
        _mockTransactionV1Service = new Mock<ITransactionV1Service>();
        Mock<ITransactionV1Repository> mockTransactionV1Repository = new();
        Mock<IReferenceV1Repository> mockReferenceV1Repository = new();
        _controller = new API.Controllers.TransactionController(_mockTransactionV1Service.Object, mockTransactionV1Repository.Object, mockReferenceV1Repository.Object);

        var httpContext = new DefaultHttpContext();

        var controllerContext = new ControllerContext
        {
            HttpContext = httpContext,
            ActionDescriptor = new Microsoft.AspNetCore.Mvc.Controllers.ControllerActionDescriptor
            {
                ActionName = "GetPartnerPolicyView"
            }
        };

        _controller.ControllerContext = controllerContext;
    }

    private void SetUserClaims()
    {
        var claims = new List<Claim>
        {
            new(ClaimTypes.NameIdentifier, "500329"),
            new(ClaimTypes.Name, "John Doe"),
            new(ClaimTypes.Role, "Sales Agent"),
            new(ClaimTypes.Authentication, "http://localhost:7175"),
            new(ClaimTypes.AuthenticationMethod, "djdpatricio.ims.api"),
            new(ClaimTypes.Expiration, "1893456000")
        };

        var identity = new ClaimsIdentity(claims, "mock");
        var principal = new ClaimsPrincipal(identity);
        _controller.ControllerContext.HttpContext.User = principal;
    }

    [Fact]
    public async Task GetPartnerPolicyView_ReturnsOk_NoParameters()
    {
        // Arrange
        SetUserClaims();
        _mockTransactionV1Service.Setup(s => s.GetPartnerPolicyView(It.IsAny<long?>(), It.IsAny<string?>(), It.IsAny<string?>(), It.IsAny<long?>(), It.IsAny<bool?>(), It.IsAny<string?>(), It.IsAny<string?>(), It.IsAny<string?>(), It.IsAny<string?>(), It.IsAny<string?>(), It.IsAny<CancellationToken>(), It.IsAny<int>(), It.IsAny<int>()))
            .ReturnsAsync((long? id, string? referenceNumber, string? cocNumber, long? partnersId, bool? issueStatus, string? policyBookingStatusId, string? cocStatusId, string? paymentStatusId, string? claimsStatusId, string? partnersCode, CancellationToken _, int _, int _) =>
            {
                var filteredList = MockData.Transaction.View.PartnerPolicyView.PartnerPolicyViewList().Where(x =>
                    (id == null || x.Id == id) &&
                    (referenceNumber == null || x.ReferenceNumber == referenceNumber) &&
                    (cocNumber == null || x.CocNumber == cocNumber) &&
                    (partnersId == null || x.PartnersId == partnersId) &&
                    (partnersCode == null || x.PartnersCode == partnersCode) &&
                    (issueStatus == null || x.IssueStatus == issueStatus) &&
                    // Filter by PolicyBookingStatusId
                    (policyBookingStatusId == null ||
                     policyBookingStatusId.Split(',', StringSplitOptions.RemoveEmptyEntries)
                          .Select(s => long.TryParse(s.Trim(), out var parsedId) ? (long?)parsedId : null)
                          .Where(pId => pId.HasValue)
                          .Select(pId => pId.GetValueOrDefault())
                          .Contains(x.PolicyBookingStatusId)
                    ) &&

                    // Filter by CocStatusId
                    (cocStatusId == null ||
                     cocStatusId.Split(',', StringSplitOptions.RemoveEmptyEntries)
                          .Select(s => long.TryParse(s.Trim(), out var parsedId) ? (long?)parsedId : null)
                          .Where(pId => pId.HasValue)
                          .Select(pId => pId.GetValueOrDefault())
                          .Contains(x.CocStatusId)
                    ) &&

                    // Filter by PaymentStatusId
                    (paymentStatusId == null ||
                     paymentStatusId.Split(',', StringSplitOptions.RemoveEmptyEntries)
                          .Select(s => long.TryParse(s.Trim(), out var parsedId) ? (long?)parsedId : null)
                          .Where(pId => pId.HasValue)
                          .Select(pId => pId.GetValueOrDefault())
                          .Contains(x.PaymentStatusId)
                    ) &&

                    // Filter by ClaimsStatusId
                    (claimsStatusId == null ||
                     claimsStatusId.Split(',', StringSplitOptions.RemoveEmptyEntries)
                          .Select(s => long.TryParse(s.Trim(), out var parsedId) ? (long?)parsedId : null)
                          .Where(pId => pId.HasValue)
                          .Select(pId => pId.GetValueOrDefault())
                          .Contains(x.ClaimsStatusId)
                    )
                ).ToList();
                return TransactionResult<IEnumerable<PartnerPolicyView>>.Success(filteredList);
            });

        // Act
        var result = await _controller.GetPartnerPolicyView(null, null, null, null, null, null, null, null, null, null);

        // Assert
        var statusCodeResult = Assert.IsType<OkObjectResult>(result);
        var returnData = Assert.IsAssignableFrom<PagedResponse<IEnumerable<PartnerPolicyView>>>(statusCodeResult.Value);
        var returnList = returnData.Data.ToList();
        Assert.Equal(StatusCodes.Status200OK, statusCodeResult.StatusCode);
        Assert.NotNull(returnData);
        Assert.True(returnList.Count > 0);
    }

    [Fact]
    public async Task GetPartnerPolicyView_ReturnsOk_WithParameters()
    {
        // Arrange
        SetUserClaims();
        _mockTransactionV1Service.Setup(s => s.GetPartnerPolicyView(It.IsAny<long?>(), It.IsAny<string?>(), It.IsAny<string?>(), It.IsAny<long?>(), It.IsAny<bool?>(), It.IsAny<string?>(), It.IsAny<string?>(), It.IsAny<string?>(), It.IsAny<string?>(), It.IsAny<string?>(), It.IsAny<CancellationToken>(), It.IsAny<int>(), It.IsAny<int>()))
            .ReturnsAsync((long? id, string? referenceNumber, string? cocNumber, long? partnersId, bool? issueStatus, string? policyBookingStatusId, string? cocStatusId, string? paymentStatusId, string? claimsStatusId, string? partnersCode, CancellationToken _, int _, int _) =>
            {
                var filteredList = MockData.Transaction.View.PartnerPolicyView.PartnerPolicyViewList().Where(x =>
                    (id == null || x.Id == id) &&
                    (referenceNumber == null || x.ReferenceNumber == referenceNumber) &&
                    (cocNumber == null || x.CocNumber == cocNumber) &&
                    (partnersId == null || x.PartnersId == partnersId) &&
                    (partnersCode == null || x.PartnersCode == partnersCode) &&
                    (issueStatus == null || x.IssueStatus == issueStatus) &&
                    // Filter by PolicyBookingStatusId
                    (policyBookingStatusId == null ||
                     policyBookingStatusId.Split(',', StringSplitOptions.RemoveEmptyEntries)
                          .Select(s => long.TryParse(s.Trim(), out var parsedId) ? (long?)parsedId : null)
                          .Where(pId => pId.HasValue)
                          .Select(pId => pId.GetValueOrDefault())
                          .Contains(x.PolicyBookingStatusId)
                    ) &&

                    // Filter by CocStatusId
                    (cocStatusId == null ||
                     cocStatusId.Split(',', StringSplitOptions.RemoveEmptyEntries)
                          .Select(s => long.TryParse(s.Trim(), out var parsedId) ? (long?)parsedId : null)
                          .Where(pId => pId.HasValue)
                          .Select(pId => pId.GetValueOrDefault())
                          .Contains(x.CocStatusId)
                    ) &&

                    // Filter by PaymentStatusId
                    (paymentStatusId == null ||
                     paymentStatusId.Split(',', StringSplitOptions.RemoveEmptyEntries)
                          .Select(s => long.TryParse(s.Trim(), out var parsedId) ? (long?)parsedId : null)
                          .Where(pId => pId.HasValue)
                          .Select(pId => pId.GetValueOrDefault())
                          .Contains(x.PaymentStatusId)
                    ) &&

                    // Filter by ClaimsStatusId
                    (claimsStatusId == null ||
                     claimsStatusId.Split(',', StringSplitOptions.RemoveEmptyEntries)
                          .Select(s => long.TryParse(s.Trim(), out var parsedId) ? (long?)parsedId : null)
                          .Where(pId => pId.HasValue)
                          .Select(pId => pId.GetValueOrDefault())
                          .Contains(x.ClaimsStatusId)
                    )
                ).ToList();
                return TransactionResult<IEnumerable<PartnerPolicyView>>.Success(filteredList);
            });

        // Act
        var result = await _controller.GetPartnerPolicyView(1, null, null, null, null, null, null, null, null, null);

        // Assert
        var statusCodeResult = Assert.IsType<OkObjectResult>(result);
        var returnData = Assert.IsAssignableFrom<PagedResponse<IEnumerable<PartnerPolicyView>>>(statusCodeResult.Value);
        var returnList = returnData.Data.ToList();
        Assert.Equal(StatusCodes.Status200OK, statusCodeResult.StatusCode);
        Assert.NotNull(returnData);
        Assert.Equal(1, returnList.First().Id);
    }

    [Fact]
    public async Task GetPartnerPolicyView_ReturnsInternalServerError()
    {
        // Arrange
        SetUserClaims();
        var resultData = TransactionResult<IEnumerable<PartnerPolicyView>>.Failure(new Exception("Service failed"));
        _mockTransactionV1Service.Setup(s => s.GetPartnerPolicyView(It.IsAny<long?>(), It.IsAny<string?>(), It.IsAny<string?>(), It.IsAny<long?>(), It.IsAny<bool?>(), It.IsAny<string?>(), It.IsAny<string?>(), It.IsAny<string?>(), It.IsAny<string?>(), It.IsAny<string?>(), It.IsAny<CancellationToken>(), It.IsAny<int>(), It.IsAny<int>()))
            .ReturnsAsync(resultData);

        // Act
        var result = await _controller.GetPartnerPolicyView(null, null, null, null, null, null, null, null, null, null);

        // Assert
        var statusCodeResult = Assert.IsType<StatusCodeResult>(result);
        Assert.Equal(StatusCodes.Status500InternalServerError, statusCodeResult.StatusCode);
    }

    [Fact]
    public async Task GetPartnerPolicyView_ReturnsRequestTimeout()
    {
        // Arrange
        SetUserClaims();
        _mockTransactionV1Service.Setup(s => s.GetPartnerPolicyView(It.IsAny<long?>(), It.IsAny<string?>(), It.IsAny<string?>(), It.IsAny<long?>(), It.IsAny<bool?>(), It.IsAny<string?>(), It.IsAny<string?>(), It.IsAny<string?>(), It.IsAny<string?>(), It.IsAny<string?>(), It.IsAny<CancellationToken>(), It.IsAny<int>(), It.IsAny<int>()))
            .ThrowsAsync(new OperationCanceledException());

        // Act
        var result = await _controller.GetPartnerPolicyView(null, null, null, null, null, null, null, null, null, null);

        // Assert
        var statusCodeResult = Assert.IsType<StatusCodeResult>(result);
        Assert.Equal(StatusCodes.Status408RequestTimeout, statusCodeResult.StatusCode);
    }

    [Fact]
    public async Task GetPartnerPolicyView_ReturnsUnauthorized()
    {
        // Arrange
        _controller.ControllerContext.HttpContext.User = null!;

        // Act
        var result = await _controller.GetPartnerPolicyView(null, null, null, null, null, null, null, null, null, null);

        // Assert
        var statusCodeResult = Assert.IsType<StatusCodeResult>(result);
        Assert.Equal(StatusCodes.Status401Unauthorized, statusCodeResult.StatusCode);
    }
}