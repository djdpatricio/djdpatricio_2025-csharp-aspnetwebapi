using System.Security.Claims;
using DJDPatricio.IMS.API.Models;
using DJDPatricio.IMS.API.Service.Interface.V1;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Moq;

namespace DJDPatricio.IMS.TESTS.Controllers.TransactionController;

public class DeletePolicyPaymentsTests
{
    private readonly Mock<ITransactionV1Service> _mockTransactionV1Service;
    private readonly API.Controllers.TransactionController _controller;

    public DeletePolicyPaymentsTests()
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
                ActionName = "DeletePolicyPayments"
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
    public async Task DeletePolicyPayments_ReturnsOk()
    {
        // Arrange
        SetUserClaims();
        const long scopedIdentity = 1;
        _mockTransactionV1Service.Setup(s => s.PutPolicyPayments(It.IsAny<object>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync((object _, CancellationToken _) => TransactionResult.Success());

        // Act
        var result = await _controller.DeletePolicyPayments(scopedIdentity);

        // Assert
        var statusCodeResult = Assert.IsType<OkResult>(result);
        Assert.Equal(StatusCodes.Status200OK, statusCodeResult.StatusCode);
    }

    [Fact]
    public async Task DeletePolicyPayments_ReturnsBadRequest_WhenCustomSQLExceptionIsFound()
    {
        // Arrange
        SetUserClaims();
        const long scopedIdentity = 1;
        var resultData = TransactionResult.Failure(new Exception("CustomSQLException: Reference not found."));
        _mockTransactionV1Service.Setup(s => s.PutPolicyPayments(It.IsAny<object>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync(resultData);

        // Act
        var result = await _controller.DeletePolicyPayments(scopedIdentity);

        // Assert
        var statusCodeResult = Assert.IsType<ObjectResult>(result);
        Assert.Equal(StatusCodes.Status400BadRequest, statusCodeResult.StatusCode);
        Assert.Equal("Reference not found.", statusCodeResult.Value);
    }

    [Fact]
    public async Task DeletePolicyPayments_ReturnsInternalServerError()
    {
        // Arrange
        SetUserClaims();
        const long scopedIdentity = 1;
        var resultData = TransactionResult.Failure(new Exception("Service failed"));
        _mockTransactionV1Service.Setup(s => s.PutPolicyPayments(It.IsAny<object>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync(resultData);

        // Act
        var result = await _controller.DeletePolicyPayments(scopedIdentity);

        // Assert
        var statusCodeResult = Assert.IsType<StatusCodeResult>(result);
        Assert.Equal(StatusCodes.Status500InternalServerError, statusCodeResult.StatusCode);
    }

    [Fact]
    public async Task DeletePolicyPayments_ReturnsRequestTimeout()
    {
        // Arrange
        SetUserClaims();
        const long scopedIdentity = 1;
        _mockTransactionV1Service.Setup(s => s.PutPolicyPayments(It.IsAny<object>(), It.IsAny<CancellationToken>()))
            .ThrowsAsync(new OperationCanceledException());

        // Act
        var result = await _controller.DeletePolicyPayments(scopedIdentity);

        // Assert
        var statusCodeResult = Assert.IsType<StatusCodeResult>(result);
        Assert.Equal(StatusCodes.Status408RequestTimeout, statusCodeResult.StatusCode);
    }

    [Fact]
    public async Task DeletePolicyPayments_ReturnsUnauthorized()
    {
        // Arrange
        _controller.ControllerContext.HttpContext.User = null!;
        const long scopedIdentity = 1;

        // Act
        var result = await _controller.DeletePolicyPayments(scopedIdentity);

        // Assert
        var statusCodeResult = Assert.IsType<StatusCodeResult>(result);
        Assert.Equal(StatusCodes.Status401Unauthorized, statusCodeResult.StatusCode);
    }
}