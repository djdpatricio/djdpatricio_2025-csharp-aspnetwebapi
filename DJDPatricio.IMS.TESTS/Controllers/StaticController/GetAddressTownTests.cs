using System.Security.Claims;
using DJDPatricio.IMS.API.Models;
using DJDPatricio.IMS.API.Models.Result.Static;
using DJDPatricio.IMS.API.Service.Interface.V1;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Moq;

namespace DJDPatricio.IMS.TESTS.Controllers.StaticController;

public class GetAddressTownTests
{
    private readonly Mock<IStaticV1Service> _mockStaticV1Service;
    private readonly API.Controllers.StaticController _controller;

    public GetAddressTownTests()
    {
        _mockStaticV1Service = new Mock<IStaticV1Service>();
        _controller = new API.Controllers.StaticController(_mockStaticV1Service.Object);

        var httpContext = new DefaultHttpContext();

        var controllerContext = new ControllerContext
        {
            HttpContext = httpContext,
            ActionDescriptor = new Microsoft.AspNetCore.Mvc.Controllers.ControllerActionDescriptor
            {
                ActionName = "GetAddressTown"
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
    public async Task GetAddressTown_ReturnsOk_NoParameters()
    {
        // Arrange
        SetUserClaims();
        _mockStaticV1Service.Setup(s => s.GetAddressTown(It.IsAny<long?>(), It.IsAny<long?>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync((long? id, long? cityId, CancellationToken _) =>
            {
                var filteredList = MockData.Static.AddressTown.AddressTownList().Where(x => (id == null || x.Id == id) && (cityId == null || x.AddressCityId == cityId)).ToList();
                return TransactionResult<IEnumerable<AddressTown>>.Success(filteredList);
            });

        // Act
        var result = await _controller.GetAddressTown(null, null);

        // Assert
        var statusCodeResult = Assert.IsType<OkObjectResult>(result);
        var returnData = Assert.IsAssignableFrom<IEnumerable<AddressTown>>(statusCodeResult.Value);
        var returnList = returnData.ToList();
        Assert.Equal(StatusCodes.Status200OK, statusCodeResult.StatusCode);
        Assert.NotNull(returnData);
        Assert.True(returnList.Count > 0);
    }

    [Fact]
    public async Task GetAddressTown_ReturnsOk_WithParameters()
    {
        // Arrange
        SetUserClaims();
        _mockStaticV1Service.Setup(s => s.GetAddressTown(It.IsAny<long?>(), It.IsAny<long?>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync((long? id, long? cityId, CancellationToken _) =>
            {
                var filteredList = MockData.Static.AddressTown.AddressTownList().Where(x => (id == null || x.Id == id) && (cityId == null || x.AddressCityId == cityId)).ToList();
                return TransactionResult<IEnumerable<AddressTown>>.Success(filteredList);
            });

        // Act
        var result = await _controller.GetAddressTown(1126, null);

        // Assert
        var statusCodeResult = Assert.IsType<OkObjectResult>(result);
        var returnData = Assert.IsAssignableFrom<IEnumerable<AddressTown>>(statusCodeResult.Value);
        var returnList = returnData.ToList();
        Assert.Equal(StatusCodes.Status200OK, statusCodeResult.StatusCode);
        Assert.NotNull(returnData);
        Assert.Equal(1126, returnList.First().Id);
    }

    [Fact]
    public async Task GetAddressTown_ReturnsInternalServerError()
    {
        // Arrange
        SetUserClaims();
        var resultData = TransactionResult<IEnumerable<AddressTown>>.Failure(new Exception("Service failed"));
        _mockStaticV1Service.Setup(s => s.GetAddressTown(It.IsAny<long?>(), It.IsAny<long?>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync(resultData);

        // Act
        var result = await _controller.GetAddressTown(null, null);

        // Assert
        var statusCodeResult = Assert.IsType<StatusCodeResult>(result);
        Assert.Equal(StatusCodes.Status500InternalServerError, statusCodeResult.StatusCode);
    }

    [Fact]
    public async Task GetAddressTown_ReturnsRequestTimeout()
    {
        // Arrange
        SetUserClaims();
        _mockStaticV1Service.Setup(s => s.GetAddressTown(It.IsAny<long?>(), It.IsAny<long?>(), It.IsAny<CancellationToken>()))
            .ThrowsAsync(new OperationCanceledException());

        // Act
        var result = await _controller.GetAddressTown(null, null);

        // Assert
        var statusCodeResult = Assert.IsType<StatusCodeResult>(result);
        Assert.Equal(StatusCodes.Status408RequestTimeout, statusCodeResult.StatusCode);
    }

    [Fact]
    public async Task GetAddressTown_ReturnsUnauthorized()
    {
        // Arrange
        _controller.ControllerContext.HttpContext.User = null!;

        // Act
        var result = await _controller.GetAddressTown(null, null);

        // Assert
        var statusCodeResult = Assert.IsType<StatusCodeResult>(result);
        Assert.Equal(StatusCodes.Status401Unauthorized, statusCodeResult.StatusCode);
    }
}