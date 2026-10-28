using System.Security.Claims;
using DJDPatricio.IMS.API.Models;
using DJDPatricio.IMS.API.Models.Request.Put;
using DJDPatricio.IMS.API.Service.Interface.V1;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Moq;

namespace DJDPatricio.IMS.TESTS.Controllers.TransactionController;

public class PutPolicyPaymentsTests
{
    private readonly Mock<ITransactionV1Service> _mockTransactionV1Service;
    private readonly API.Controllers.TransactionController _controller;

    public PutPolicyPaymentsTests()
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
                ActionName = "PutPolicyPayments"
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
    public async Task PutPolicyPayments_ReturnsOk()
    {
        // Arrange
        SetUserClaims();
        var request = new PutPolicyPayments()
        {
            Id = 1,
            Amount = 645.17m,
            TransactionDateTime = new DateTime(2025, 06, 07, 08, 04, 12, 176),
            TransactionCheckNo = "CHK12345",
            TransactionOrigin = "Online",
            NotificationDateTime = new DateTime(2025, 06, 01, 08, 04, 12, 176),
            PaymentMethod = 27,
            Notes = null,
        };
        _mockTransactionV1Service.Setup(s => s.PutPolicyPayments(It.IsAny<object>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync((object _, CancellationToken _) => TransactionResult.Success());

        // Act
        var result = await _controller.PutPolicyPayments(request);

        // Assert
        var statusCodeResult = Assert.IsType<OkResult>(result);
        Assert.Equal(StatusCodes.Status200OK, statusCodeResult.StatusCode);
    }

    [Fact]
    public async Task PutPolicyPayments_ReturnsBadRequest_WhenValidationFails()
    {
        // Arrange
        SetUserClaims();
        var request = new PutPolicyPayments()
        {
            Id = 1,
            Amount = 645.17m,
            TransactionDateTime = new DateTime(2025, 06, 07, 08, 04, 12, 176),
            TransactionCheckNo = null!,
            TransactionOrigin = "Online",
            NotificationDateTime = new DateTime(2025, 06, 01, 08, 04, 12, 176),
            PaymentMethod = 27,
            Notes = null,
        };

        var resultData = TransactionResult.Failure(new Exception("Invalid values:{ " + Environment.NewLine + "TransactionCheckNo - Value must not be null.;" + Environment.NewLine + "}"));
        _mockTransactionV1Service.Setup(s => s.PutPolicyPayments(It.IsAny<object>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync(resultData);

        // Act
        var result = await _controller.PutPolicyPayments(request);

        // Assert
        var statusCodeResult = Assert.IsType<ObjectResult>(result);
        Assert.Equal(StatusCodes.Status400BadRequest, statusCodeResult.StatusCode);
        Assert.Contains("TransactionCheckNo - Value must not be null.;", (string?)statusCodeResult.Value);
    }

    [Fact]
    public async Task PutPolicyPayments_ReturnsBadRequest_WhenCustomSQLExceptionIsFound()
    {
        // Arrange
        SetUserClaims();
        var request = new PutPolicyPayments()
        {
            Id = 1,
            Amount = 645.17m,
            TransactionDateTime = new DateTime(2025, 06, 07, 08, 04, 12, 176),
            TransactionCheckNo = "CHK12345",
            TransactionOrigin = "Online",
            NotificationDateTime = new DateTime(2025, 06, 01, 08, 04, 12, 176),
            PaymentMethod = 27,
            Notes = null,
        };

        var resultData = TransactionResult.Failure(new Exception("CustomSQLException: Reference not found."));
        _mockTransactionV1Service.Setup(s => s.PutPolicyPayments(It.IsAny<object>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync(resultData);

        // Act
        var result = await _controller.PutPolicyPayments(request);

        // Assert
        var statusCodeResult = Assert.IsType<ObjectResult>(result);
        Assert.Equal(StatusCodes.Status400BadRequest, statusCodeResult.StatusCode);
        Assert.Equal("Reference not found.", statusCodeResult.Value);
    }

    [Fact]
    public async Task PutPolicyPayments_ReturnsInternalServerError()
    {
        // Arrange
        SetUserClaims();
        var request = new PutPolicyPayments()
        {
            Id = 1,
            Amount = 645.17m,
            TransactionDateTime = new DateTime(2025, 06, 07, 08, 04, 12, 176),
            TransactionCheckNo = "CHK12345",
            TransactionOrigin = "Online",
            NotificationDateTime = new DateTime(2025, 06, 01, 08, 04, 12, 176),
            PaymentMethod = 27,
            Notes = null,
        };
        var resultData = TransactionResult.Failure(new Exception("Service failed"));
        _mockTransactionV1Service.Setup(s => s.PutPolicyPayments(It.IsAny<object>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync(resultData);

        // Act
        var result = await _controller.PutPolicyPayments(request);

        // Assert
        var statusCodeResult = Assert.IsType<StatusCodeResult>(result);
        Assert.Equal(StatusCodes.Status500InternalServerError, statusCodeResult.StatusCode);
    }

    [Fact]
    public async Task PutPolicyPayments_ReturnsRequestTimeout()
    {
        // Arrange
        SetUserClaims();
        var request = new PutPolicyPayments()
        {
            Id = 1,
            Amount = 645.17m,
            TransactionDateTime = new DateTime(2025, 06, 07, 08, 04, 12, 176),
            TransactionCheckNo = "CHK12345",
            TransactionOrigin = "Online",
            NotificationDateTime = new DateTime(2025, 06, 01, 08, 04, 12, 176),
            PaymentMethod = 27,
            Notes = null,
        };
        _mockTransactionV1Service.Setup(s => s.PutPolicyPayments(It.IsAny<object>(), It.IsAny<CancellationToken>()))
            .ThrowsAsync(new OperationCanceledException());

        // Act
        var result = await _controller.PutPolicyPayments(request);

        // Assert
        var statusCodeResult = Assert.IsType<StatusCodeResult>(result);
        Assert.Equal(StatusCodes.Status408RequestTimeout, statusCodeResult.StatusCode);
    }

    [Fact]
    public async Task PutPolicyPayments_ReturnsUnauthorized()
    {
        // Arrange
        _controller.ControllerContext.HttpContext.User = null!;
        var request = new PutPolicyPayments()
        {
            Id = 1,
            Amount = 645.17m,
            TransactionDateTime = new DateTime(2025, 06, 07, 08, 04, 12, 176),
            TransactionCheckNo = "CHK12345",
            TransactionOrigin = "Online",
            NotificationDateTime = new DateTime(2025, 06, 01, 08, 04, 12, 176),
            PaymentMethod = 27,
            Notes = null,
        };

        // Act
        var result = await _controller.PutPolicyPayments(request);

        // Assert
        var statusCodeResult = Assert.IsType<StatusCodeResult>(result);
        Assert.Equal(StatusCodes.Status401Unauthorized, statusCodeResult.StatusCode);
    }
}