using System.Security.Claims;
using DJDPatricio.IMS.API.Models;
using DJDPatricio.IMS.API.Models.Request.Put;
using DJDPatricio.IMS.API.Service.Interface.V1;
using DJDPatricio.IMS.TESTS.MockData.Transaction;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Moq;

namespace DJDPatricio.IMS.TESTS.Controllers.TransactionController;

public class PutAttachmentsTests
{
    private readonly Mock<ITransactionV1Service> _mockTransactionV1Service;
    private readonly API.Controllers.TransactionController _controller;

    public PutAttachmentsTests()
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
                ActionName = "PutAttachments"
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
    public async Task PutAttachments_ReturnsOk()
    {
        // Arrange
        SetUserClaims();
        var request = new PutAttachments()
        {
            Id = 1,
            ContentType = "text/csv",
            FileName = "SampleCSV.csv",
            Attachment = Attachments.SampleFile
        };
        _mockTransactionV1Service.Setup(s => s.PutAttachments(It.IsAny<object>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync((object _, CancellationToken _) => TransactionResult.Success());

        // Act
        var result = await _controller.PutAttachments(request);

        // Assert
        var statusCodeResult = Assert.IsType<OkResult>(result);
        Assert.Equal(StatusCodes.Status200OK, statusCodeResult.StatusCode);
    }

    [Fact]
    public async Task PutAttachments_ReturnsBadRequest_WhenValidationFails()
    {
        // Arrange
        SetUserClaims();
        var request = new PutAttachments()
        {
            Id = 1,
            ContentType = "text/csv",
            FileName = null!,
            Attachment = Attachments.SampleFile
        };

        var resultData = TransactionResult.Failure(new Exception("Invalid values:{ " + Environment.NewLine + "FileName - Value must not be null.;" + Environment.NewLine + "}"));
        _mockTransactionV1Service.Setup(s => s.PutAttachments(It.IsAny<object>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync(resultData);

        // Act
        var result = await _controller.PutAttachments(request);

        // Assert
        var statusCodeResult = Assert.IsType<ObjectResult>(result);
        Assert.Equal(StatusCodes.Status400BadRequest, statusCodeResult.StatusCode);
        Assert.Contains("FileName - Value must not be null.;", (string?)statusCodeResult.Value);
    }

    [Fact]
    public async Task PutAttachments_ReturnsBadRequest_WhenCustomSQLExceptionIsFound()
    {
        // Arrange
        SetUserClaims();
        var request = new PutAttachments()
        {
            Id = 1,
            ContentType = "text/csv",
            FileName = "SampleCSV.csv",
            Attachment = Attachments.SampleFile
        };

        var resultData = TransactionResult.Failure(new Exception("CustomSQLException: Attachment not found."));
        _mockTransactionV1Service.Setup(s => s.PutAttachments(It.IsAny<object>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync(resultData);

        // Act
        var result = await _controller.PutAttachments(request);

        // Assert
        var statusCodeResult = Assert.IsType<ObjectResult>(result);
        Assert.Equal(StatusCodes.Status400BadRequest, statusCodeResult.StatusCode);
        Assert.Equal("Attachment not found.", statusCodeResult.Value);
    }

    [Fact]
    public async Task PutAttachments_ReturnsInternalServerError()
    {
        // Arrange
        SetUserClaims();
        var request = new PutAttachments()
        {
            Id = 1,
            ContentType = "text/csv",
            FileName = "SampleCSV.csv",
            Attachment = Attachments.SampleFile
        };
        var resultData = TransactionResult.Failure(new Exception("Service failed"));
        _mockTransactionV1Service.Setup(s => s.PutAttachments(It.IsAny<object>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync(resultData);

        // Act
        var result = await _controller.PutAttachments(request);

        // Assert
        var statusCodeResult = Assert.IsType<StatusCodeResult>(result);
        Assert.Equal(StatusCodes.Status500InternalServerError, statusCodeResult.StatusCode);
    }

    [Fact]
    public async Task PutAttachments_ReturnsRequestTimeout()
    {
        // Arrange
        SetUserClaims();
        var request = new PutAttachments()
        {
            Id = 1,
            ContentType = "text/csv",
            FileName = "SampleCSV.csv",
            Attachment = Attachments.SampleFile
        };
        _mockTransactionV1Service.Setup(s => s.PutAttachments(It.IsAny<object>(), It.IsAny<CancellationToken>()))
            .ThrowsAsync(new OperationCanceledException());

        // Act
        var result = await _controller.PutAttachments(request);

        // Assert
        var statusCodeResult = Assert.IsType<StatusCodeResult>(result);
        Assert.Equal(StatusCodes.Status408RequestTimeout, statusCodeResult.StatusCode);
    }

    [Fact]
    public async Task PutAttachments_ReturnsUnauthorized()
    {
        // Arrange
        _controller.ControllerContext.HttpContext.User = null!;
        var request = new PutAttachments()
        {
            Id = 1,
            ContentType = "text/csv",
            FileName = "SampleCSV.csv",
            Attachment = Attachments.SampleFile
        };

        // Act
        var result = await _controller.PutAttachments(request);

        // Assert
        var statusCodeResult = Assert.IsType<StatusCodeResult>(result);
        Assert.Equal(StatusCodes.Status401Unauthorized, statusCodeResult.StatusCode);
    }
}