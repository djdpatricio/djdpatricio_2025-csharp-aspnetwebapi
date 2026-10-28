using System.Security.Claims;
using DJDPatricio.IMS.API.Models;
using DJDPatricio.IMS.API.Models.Request.Post;
using DJDPatricio.IMS.API.Models.Result.Custom;
using DJDPatricio.IMS.API.Service.Interface.V1;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Moq;

namespace DJDPatricio.IMS.TESTS.Controllers.TransactionController;

public class PostIndividualPolicyTests
{
    private readonly Mock<ITransactionV1Service> _mockTransactionV1Service;
    private readonly API.Controllers.TransactionController _controller;

    public PostIndividualPolicyTests()
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
                ActionName = "PostIndividualPolicy"
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
    public async Task PostIndividualPolicy_ReturnsOk()
    {
        // Arrange
        const long scopedIdentity = 1;
        SetUserClaims();
        var request = new PostIndividualPolicy()
        {
            ClientsId = 26,
            PartnersId = 5,
            AgentsId = 1,
            SubAgentsId = null,
            ApproversId = 3,
            PromoManagersId = 1,
            SalesManagersId = 3,
            PromoOfficersId = 2,
            ProductsId = 1,
            ProvidersId = 11,
            DistributionChannelId = 7,
            PaymentOptionId = 27,
            ProviderPolicyNo = "PPN-IMS3-001",
            EndorsementNo = "EN-IMS3-001",
            TerminationDate = new DateTime(2026, 06, 07),
            EffectiveDate = new DateTime(2025, 06, 07),
            IssueDate = new DateTime(2025, 06, 07),
            Remarks = "Remarks",
        };
        _mockTransactionV1Service.Setup(s => s.PostIndividualPolicy(It.IsAny<object>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync((object _, CancellationToken _) => TransactionResult<PostId>.Success(new PostId { Id = scopedIdentity }));

        // Act
        var result = await _controller.PostIndividualPolicy(request);

        // Assert
        var statusCodeResult = Assert.IsType<OkObjectResult>(result);
        var returnData = Assert.IsAssignableFrom<PostId>(statusCodeResult.Value);
        Assert.Equal(StatusCodes.Status200OK, statusCodeResult.StatusCode);
        Assert.Equal(scopedIdentity, returnData.Id);
    }

    [Fact]
    public async Task PostIndividualPolicy_ReturnsBadRequest_WhenValidationFails()
    {
        // Arrange
        SetUserClaims();
        var request = new PostIndividualPolicy()
        {
            ClientsId = 26,
            PartnersId = 300,
            AgentsId = 1,
            SubAgentsId = null,
            ApproversId = 3,
            PromoManagersId = 1,
            SalesManagersId = 3,
            PromoOfficersId = 2,
            ProductsId = 1,
            ProvidersId = 11,
            DistributionChannelId = 7,
            PaymentOptionId = 27,
            ProviderPolicyNo = "PPN-IMS3-001",
            EndorsementNo = "EN-IMS3-001",
            TerminationDate = new DateTime(2026, 06, 07),
            EffectiveDate = new DateTime(2025, 06, 07),
            IssueDate = new DateTime(2025, 06, 07),
            Remarks = "Remarks",
        };

        var resultData = TransactionResult<PostId>.Failure(new Exception("Invalid values:{ " + Environment.NewLine + "PartnersId - Value is not valid.;" + Environment.NewLine + "}"));
        _mockTransactionV1Service.Setup(s => s.PostIndividualPolicy(It.IsAny<object>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync(resultData);

        // Act
        var result = await _controller.PostIndividualPolicy(request);

        // Assert
        var statusCodeResult = Assert.IsType<ObjectResult>(result);
        Assert.Equal(StatusCodes.Status400BadRequest, statusCodeResult.StatusCode);
        Assert.Contains("PartnersId - Value is not valid.;", (string?)statusCodeResult.Value);
    }

    [Fact]
    public async Task PostIndividualPolicy_ReturnsBadRequest_WhenCustomSQLExceptionIsFound()
    {
        // Arrange
        SetUserClaims();
        var request = new PostIndividualPolicy()
        {
            ClientsId = 26,
            PartnersId = 5,
            AgentsId = 1,
            SubAgentsId = null,
            ApproversId = 3,
            PromoManagersId = 1,
            SalesManagersId = 3,
            PromoOfficersId = 2,
            ProductsId = 1,
            ProvidersId = 11,
            DistributionChannelId = 7,
            PaymentOptionId = 27,
            ProviderPolicyNo = "PPN-IMS3-001",
            EndorsementNo = "EN-IMS3-001",
            TerminationDate = new DateTime(2026, 06, 07),
            EffectiveDate = new DateTime(2025, 06, 07),
            IssueDate = new DateTime(2025, 06, 07),
            Remarks = "Remarks",
        };

        var resultData = TransactionResult<PostId>.Failure(new Exception("CustomSQLException: Max COC limit Reached."));
        _mockTransactionV1Service.Setup(s => s.PostIndividualPolicy(It.IsAny<object>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync(resultData);

        // Act
        var result = await _controller.PostIndividualPolicy(request);

        // Assert
        var statusCodeResult = Assert.IsType<ObjectResult>(result);
        Assert.Equal(StatusCodes.Status400BadRequest, statusCodeResult.StatusCode);
        Assert.Equal("Max COC limit Reached.", statusCodeResult.Value);
    }

    [Fact]
    public async Task PostIndividualPolicy_ReturnsInternalServerError()
    {
        // Arrange
        SetUserClaims();
        var request = new PostIndividualPolicy()
        {
            ClientsId = 26,
            PartnersId = 5,
            AgentsId = 1,
            SubAgentsId = null,
            ApproversId = 3,
            PromoManagersId = 1,
            SalesManagersId = 3,
            PromoOfficersId = 2,
            ProductsId = 1,
            ProvidersId = 11,
            DistributionChannelId = 7,
            PaymentOptionId = 27,
            ProviderPolicyNo = "PPN-IMS3-001",
            EndorsementNo = "EN-IMS3-001",
            TerminationDate = new DateTime(2026, 06, 07),
            EffectiveDate = new DateTime(2025, 06, 07),
            IssueDate = new DateTime(2025, 06, 07),
            Remarks = "Remarks",
        };
        var resultData = TransactionResult<PostId>.Failure(new Exception("Service failed"));
        _mockTransactionV1Service.Setup(s => s.PostIndividualPolicy(It.IsAny<object>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync(resultData);

        // Act
        var result = await _controller.PostIndividualPolicy(request);

        // Assert
        var statusCodeResult = Assert.IsType<StatusCodeResult>(result);
        Assert.Equal(StatusCodes.Status500InternalServerError, statusCodeResult.StatusCode);
    }

    [Fact]
    public async Task PostIndividualPolicy_ReturnsRequestTimeout()
    {
        // Arrange
        SetUserClaims();
        var request = new PostIndividualPolicy()
        {
            ClientsId = 26,
            PartnersId = 5,
            AgentsId = 1,
            SubAgentsId = null,
            ApproversId = 3,
            PromoManagersId = 1,
            SalesManagersId = 3,
            PromoOfficersId = 2,
            ProductsId = 1,
            ProvidersId = 11,
            DistributionChannelId = 7,
            PaymentOptionId = 27,
            ProviderPolicyNo = "PPN-IMS3-001",
            EndorsementNo = "EN-IMS3-001",
            TerminationDate = new DateTime(2026, 06, 07),
            EffectiveDate = new DateTime(2025, 06, 07),
            IssueDate = new DateTime(2025, 06, 07),
            Remarks = "Remarks",
        };
        _mockTransactionV1Service.Setup(s => s.PostIndividualPolicy(It.IsAny<object>(), It.IsAny<CancellationToken>()))
            .ThrowsAsync(new OperationCanceledException());

        // Act
        var result = await _controller.PostIndividualPolicy(request);

        // Assert
        var statusCodeResult = Assert.IsType<StatusCodeResult>(result);
        Assert.Equal(StatusCodes.Status408RequestTimeout, statusCodeResult.StatusCode);
    }

    [Fact]
    public async Task PostIndividualPolicy_ReturnsUnauthorized()
    {
        // Arrange
        _controller.ControllerContext.HttpContext.User = null!;
        var request = new PostIndividualPolicy()
        {
            ClientsId = 26,
            PartnersId = 5,
            AgentsId = 1,
            SubAgentsId = null,
            ApproversId = 3,
            PromoManagersId = 1,
            SalesManagersId = 3,
            PromoOfficersId = 2,
            ProductsId = 1,
            ProvidersId = 11,
            DistributionChannelId = 7,
            PaymentOptionId = 27,
            ProviderPolicyNo = "PPN-IMS3-001",
            EndorsementNo = "EN-IMS3-001",
            TerminationDate = new DateTime(2026, 06, 07),
            EffectiveDate = new DateTime(2025, 06, 07),
            IssueDate = new DateTime(2025, 06, 07),
            Remarks = "Remarks",
        };

        // Act
        var result = await _controller.PostIndividualPolicy(request);

        // Assert
        var statusCodeResult = Assert.IsType<StatusCodeResult>(result);
        Assert.Equal(StatusCodes.Status401Unauthorized, statusCodeResult.StatusCode);
    }
}