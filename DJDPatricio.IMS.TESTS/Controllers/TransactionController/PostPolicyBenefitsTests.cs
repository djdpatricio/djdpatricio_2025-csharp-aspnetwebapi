using System.Security.Claims;
using DJDPatricio.IMS.API.Models;
using DJDPatricio.IMS.API.Models.Request.Post;
using DJDPatricio.IMS.API.Models.Result.Custom;
using DJDPatricio.IMS.API.Service.Interface.V1;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Moq;

namespace DJDPatricio.IMS.TESTS.Controllers.TransactionController;

public class PostPolicyBenefitsTests
{
    private readonly Mock<ITransactionV1Service> _mockTransactionV1Service;
    private readonly API.Controllers.TransactionController _controller;

    public PostPolicyBenefitsTests()
    {
        _mockTransactionV1Service = new Mock<ITransactionV1Service>();
        var mockTransactionV1Repository = SetupHelper.GenerateTransactionRepositoryMock();
        var mockReferenceV1Repository = SetupHelper.GenerateReferenceRepositoryMock();

        _controller = new API.Controllers.TransactionController(_mockTransactionV1Service.Object, mockTransactionV1Repository.Object, mockReferenceV1Repository.Object);

        var httpContext = new DefaultHttpContext();
        var controllerContext = new ControllerContext
        {
            HttpContext = httpContext,
            ActionDescriptor = new Microsoft.AspNetCore.Mvc.Controllers.ControllerActionDescriptor
            {
                ActionName = "PostPolicyBenefits"
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
    public async Task PostPolicyBenefits_ReturnsOk()
    {
        // Arrange
        const long scopedIdentity = 1;
        SetUserClaims();
        var request = new PostPolicyBenefits()
        {
            PolicyId = 1,
            PolicyTypeId = 1,
            BenefitsId = 1,
            CoverageAmount = 20000.00m,
            PremiumAmount = 7.93m,
            PremiumCommissionAmount = 0.45m,
        };
        _mockTransactionV1Service.Setup(s => s.PostPolicyBenefits(It.IsAny<object>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync((object _, CancellationToken _) => TransactionResult<PostId>.Success(new PostId { Id = scopedIdentity }));

        // Act
        var result = await _controller.PostPolicyBenefits(request);

        // Assert
        var statusCodeResult = Assert.IsType<OkObjectResult>(result);
        var returnData = Assert.IsAssignableFrom<PostId>(statusCodeResult.Value);
        Assert.Equal(StatusCodes.Status200OK, statusCodeResult.StatusCode);
        Assert.Equal(scopedIdentity, returnData.Id);
    }

    [Fact]
    public async Task PostPolicyBenefits_ReturnsBadRequest_WhenValidationFails()
    {
        // Arrange
        SetUserClaims();
        var request = new PostPolicyBenefits()
        {
            PolicyId = 1,
            PolicyTypeId = 300,
            BenefitsId = 1,
            CoverageAmount = 20000.00m,
            PremiumAmount = 7.93m,
            PremiumCommissionAmount = 0.45m,
        };

        var resultData = TransactionResult<PostId>.Failure(new Exception("Invalid values:{ " + Environment.NewLine + "PolicyTypeId - Value is not valid.;" + Environment.NewLine + "}"));
        _mockTransactionV1Service.Setup(s => s.PostPolicyBenefits(It.IsAny<object>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync(resultData);

        // Act
        var result = await _controller.PostPolicyBenefits(request);

        // Assert
        var statusCodeResult = Assert.IsType<ObjectResult>(result);
        Assert.Equal(StatusCodes.Status400BadRequest, statusCodeResult.StatusCode);
        Assert.Contains("PolicyTypeId - Value is not valid.;", (string?)statusCodeResult.Value);
    }

    [Fact]
    public async Task PostPolicyBenefits_ReturnsBadRequest_WhenCustomSQLExceptionIsFound()
    {
        // Arrange
        SetUserClaims();
        var request = new PostPolicyBenefits()
        {
            PolicyId = 1,
            PolicyTypeId = 1,
            BenefitsId = 1,
            CoverageAmount = 20000.00m,
            PremiumAmount = 7.93m,
            PremiumCommissionAmount = 0.45m,
        };

        var resultData = TransactionResult<PostId>.Failure(new Exception("CustomSQLException: Policy not found."));
        _mockTransactionV1Service.Setup(s => s.PostPolicyBenefits(It.IsAny<object>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync(resultData);

        // Act
        var result = await _controller.PostPolicyBenefits(request);

        // Assert
        var statusCodeResult = Assert.IsType<ObjectResult>(result);
        Assert.Equal(StatusCodes.Status400BadRequest, statusCodeResult.StatusCode);
        Assert.Equal("Policy not found.", statusCodeResult.Value);
    }

    [Fact]
    public async Task PostPolicyBenefits_ReturnsInternalServerError()
    {
        // Arrange
        SetUserClaims();
        var request = new PostPolicyBenefits()
        {
            PolicyId = 1,
            PolicyTypeId = 1,
            BenefitsId = 1,
            CoverageAmount = 20000.00m,
            PremiumAmount = 7.93m,
            PremiumCommissionAmount = 0.45m,
        };
        var resultData = TransactionResult<PostId>.Failure(new Exception("Service failed"));
        _mockTransactionV1Service.Setup(s => s.PostPolicyBenefits(It.IsAny<object>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync(resultData);

        // Act
        var result = await _controller.PostPolicyBenefits(request);

        // Assert
        var statusCodeResult = Assert.IsType<StatusCodeResult>(result);
        Assert.Equal(StatusCodes.Status500InternalServerError, statusCodeResult.StatusCode);
    }

    [Fact]
    public async Task PostPolicyBenefits_ReturnsRequestTimeout()
    {
        // Arrange
        SetUserClaims();
        var request = new PostPolicyBenefits()
        {
            PolicyId = 1,
            PolicyTypeId = 1,
            BenefitsId = 1,
            CoverageAmount = 20000.00m,
            PremiumAmount = 7.93m,
            PremiumCommissionAmount = 0.45m,
        };
        _mockTransactionV1Service.Setup(s => s.PostPolicyBenefits(It.IsAny<object>(), It.IsAny<CancellationToken>()))
            .ThrowsAsync(new OperationCanceledException());

        // Act
        var result = await _controller.PostPolicyBenefits(request);

        // Assert
        var statusCodeResult = Assert.IsType<StatusCodeResult>(result);
        Assert.Equal(StatusCodes.Status408RequestTimeout, statusCodeResult.StatusCode);
    }

    [Fact]
    public async Task PostPolicyBenefits_ReturnsUnauthorized()
    {
        // Arrange
        _controller.ControllerContext.HttpContext.User = null!;
        var request = new PostPolicyBenefits()
        {
            PolicyId = 1,
            PolicyTypeId = 1,
            BenefitsId = 1,
            CoverageAmount = 20000.00m,
            PremiumAmount = 7.93m,
            PremiumCommissionAmount = 0.45m,
        };

        // Act
        var result = await _controller.PostPolicyBenefits(request);

        // Assert
        var statusCodeResult = Assert.IsType<StatusCodeResult>(result);
        Assert.Equal(StatusCodes.Status401Unauthorized, statusCodeResult.StatusCode);
    }
}