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

public class GetPolicyBeneficiaryViewTests
{
    private readonly Mock<ITransactionV1Service> _mockTransactionV1Service;
    private readonly API.Controllers.TransactionController _controller;

    public GetPolicyBeneficiaryViewTests()
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
                ActionName = "GetPolicyBeneficiaryView"
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
            new(ClaimTypes.AuthenticationMethod, "mc.ims.api"),
            new(ClaimTypes.Expiration, "1893456000")
        };

        var identity = new ClaimsIdentity(claims, "mock");
        var principal = new ClaimsPrincipal(identity);
        _controller.ControllerContext.HttpContext.User = principal;
    }

    [Fact]
    public async Task GetPolicyBeneficiaryView_ReturnsOk_NoParameters()
    {
        // Arrange
        SetUserClaims();
        _mockTransactionV1Service.Setup(s => s.GetPolicyBeneficiaryView(It.IsAny<long?>(), It.IsAny<long?>(), It.IsAny<long?>(), It.IsAny<CancellationToken>(), It.IsAny<int>(), It.IsAny<int>()))
            .ReturnsAsync((long? id, long? policyId, long? policyTypeId, CancellationToken _, int _, int _) =>
            {
                var filteredList = MockData.Transaction.View.PolicyBeneficiaryView.PolicyBeneficiaryViewList().Where(x =>
                    (id == null || x.Id == id) &&
                    (policyId == null || x.PolicyId == policyId) &&
                    (policyTypeId == null || x.PolicyTypeId == policyTypeId)
                    ).ToList();
                return TransactionResult<IEnumerable<PolicyBeneficiaryView>>.Success(filteredList);
            });

        // Act
        var result = await _controller.GetPolicyBeneficiaryView(null, null, null);

        // Assert
        var statusCodeResult = Assert.IsType<OkObjectResult>(result);
        var returnData = Assert.IsAssignableFrom<PagedResponse<IEnumerable<PolicyBeneficiaryView>>>(statusCodeResult.Value);
        var returnList = returnData.Data.ToList();
        Assert.Equal(StatusCodes.Status200OK, statusCodeResult.StatusCode);
        Assert.NotNull(returnData);
        Assert.True(returnList.Count > 0);
    }

    [Fact]
    public async Task GetPolicyBeneficiaryView_ReturnsOk_WithParameters()
    {
        // Arrange
        SetUserClaims();
        _mockTransactionV1Service.Setup(s => s.GetPolicyBeneficiaryView(It.IsAny<long?>(), It.IsAny<long?>(), It.IsAny<long?>(), It.IsAny<CancellationToken>(), It.IsAny<int>(), It.IsAny<int>()))
            .ReturnsAsync((long? id, long? policyId, long? policyTypeId, CancellationToken _, int _, int _) =>
            {
                var filteredList = MockData.Transaction.View.PolicyBeneficiaryView.PolicyBeneficiaryViewList().Where(x =>
                    (id == null || x.Id == id) &&
                    (policyId == null || x.PolicyId == policyId) &&
                    (policyTypeId == null || x.PolicyTypeId == policyTypeId)
                ).ToList();
                return TransactionResult<IEnumerable<PolicyBeneficiaryView>>.Success(filteredList);
            });

        // Act
        var result = await _controller.GetPolicyBeneficiaryView(10, null, null);

        // Assert
        var statusCodeResult = Assert.IsType<OkObjectResult>(result);
        var returnData = Assert.IsAssignableFrom<PagedResponse<IEnumerable<PolicyBeneficiaryView>>>(statusCodeResult.Value);
        var returnList = returnData.Data.ToList();
        Assert.Equal(StatusCodes.Status200OK, statusCodeResult.StatusCode);
        Assert.NotNull(returnData);
        Assert.Equal(10, returnList.First().Id);
    }

    [Fact]
    public async Task GetPolicyBeneficiaryView_ReturnsInternalServerError()
    {
        // Arrange
        SetUserClaims();
        var resultData = TransactionResult<IEnumerable<PolicyBeneficiaryView>>.Failure(new Exception("Service failed"));
        _mockTransactionV1Service.Setup(s => s.GetPolicyBeneficiaryView(It.IsAny<long?>(), It.IsAny<long?>(), It.IsAny<long?>(), It.IsAny<CancellationToken>(), It.IsAny<int>(), It.IsAny<int>()))
            .ReturnsAsync(resultData);

        // Act
        var result = await _controller.GetPolicyBeneficiaryView(null, null, null);

        // Assert
        var statusCodeResult = Assert.IsType<StatusCodeResult>(result);
        Assert.Equal(StatusCodes.Status500InternalServerError, statusCodeResult.StatusCode);
    }

    [Fact]
    public async Task GetPolicyBeneficiaryView_ReturnsRequestTimeout()
    {
        // Arrange
        SetUserClaims();
        _mockTransactionV1Service.Setup(s => s.GetPolicyBeneficiaryView(It.IsAny<long?>(), It.IsAny<long?>(), It.IsAny<long?>(), It.IsAny<CancellationToken>(), It.IsAny<int>(), It.IsAny<int>()))
            .ThrowsAsync(new OperationCanceledException());

        // Act
        var result = await _controller.GetPolicyBeneficiaryView(null, null, null);

        // Assert
        var statusCodeResult = Assert.IsType<StatusCodeResult>(result);
        Assert.Equal(StatusCodes.Status408RequestTimeout, statusCodeResult.StatusCode);
    }

    [Fact]
    public async Task GetPolicyBeneficiaryView_ReturnsUnauthorized()
    {
        // Arrange
        _controller.ControllerContext.HttpContext.User = null!;

        // Act
        var result = await _controller.GetPolicyBeneficiaryView(null, null, null);

        // Assert
        var statusCodeResult = Assert.IsType<StatusCodeResult>(result);
        Assert.Equal(StatusCodes.Status401Unauthorized, statusCodeResult.StatusCode);
    }
}