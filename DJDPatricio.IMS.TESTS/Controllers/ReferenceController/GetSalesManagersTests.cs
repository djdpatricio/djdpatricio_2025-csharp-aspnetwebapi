using System.Security.Claims;
using DJDPatricio.IMS.API.Models;
using DJDPatricio.IMS.API.Models.Result.Reference;
using DJDPatricio.IMS.API.Service.Interface.V1;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Moq;

namespace DJDPatricio.IMS.TESTS.Controllers.ReferenceController;

public class GetSalesManagersTests
{
    private readonly Mock<IReferenceV1Service> _mockReferenceV1Service;
    private readonly API.Controllers.ReferenceController _controller;

    public GetSalesManagersTests()
    {
        _mockReferenceV1Service = new Mock<IReferenceV1Service>();
        _controller = new API.Controllers.ReferenceController(_mockReferenceV1Service.Object);

        var httpContext = new DefaultHttpContext();

        var controllerContext = new ControllerContext
        {
            HttpContext = httpContext,
            ActionDescriptor = new Microsoft.AspNetCore.Mvc.Controllers.ControllerActionDescriptor
            {
                ActionName = "GetSalesManagers"
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
    public async Task GetSalesManagers_ReturnsOk_NoParameters()
    {
        // Arrange
        SetUserClaims();
        _mockReferenceV1Service.Setup(s => s.GetSalesManagers(It.IsAny<long?>(), It.IsAny<bool?>(), It.IsAny<string?>(), It.IsAny<long?>(), It.IsAny<long?>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync((long? id, bool? isActiveOnly, string? DJDPatricioOrAgentId, long? agentsId, long? mandatoryId, CancellationToken _) =>
            {
                var filteredList = MockData.Reference.SalesManagers.SalesManagersList().Where(x => (id == null || x.Id == id) && (isActiveOnly == null || x.IsActive == isActiveOnly) && (DJDPatricioOrAgentId == null || x.DJDPatricioOrAgentId == DJDPatricioOrAgentId) && (agentsId == null || x.AgentsId == agentsId)).ToList();
                if (mandatoryId == null) return TransactionResult<IEnumerable<SalesManagers>>.Success(filteredList);
                {
                    var mandatoryItem = MockData.Reference.SalesManagers.SalesManagersList().Where(x => x.Id == mandatoryId).ToList().First();
                    filteredList.Add(mandatoryItem);
                }
                return TransactionResult<IEnumerable<SalesManagers>>.Success(filteredList);
            });

        // Act
        var result = await _controller.GetSalesManagers(null, null, null, null, null);

        // Assert
        var statusCodeResult = Assert.IsType<OkObjectResult>(result);
        var returnData = Assert.IsAssignableFrom<IEnumerable<SalesManagers>>(statusCodeResult.Value);
        var returnList = returnData.ToList();
        Assert.Equal(StatusCodes.Status200OK, statusCodeResult.StatusCode);
        Assert.NotNull(returnData);
        Assert.True(returnList.Count > 0);
    }

    [Fact]
    public async Task GetSalesManagers_ReturnsOk_WithParameters()
    {
        // Arrange
        SetUserClaims();
        _mockReferenceV1Service.Setup(s => s.GetSalesManagers(It.IsAny<long?>(), It.IsAny<bool?>(), It.IsAny<string?>(), It.IsAny<long?>(), It.IsAny<long?>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync((long? id, bool? isActiveOnly, string? DJDPatricioOrAgentId, long? agentsId, long? mandatoryId, CancellationToken _) =>
            {
                var filteredList = MockData.Reference.SalesManagers.SalesManagersList().Where(x => (id == null || x.Id == id) && (isActiveOnly == null || x.IsActive == isActiveOnly) && (DJDPatricioOrAgentId == null || x.DJDPatricioOrAgentId == DJDPatricioOrAgentId) && (agentsId == null || x.AgentsId == agentsId)).ToList();
                if (mandatoryId == null) return TransactionResult<IEnumerable<SalesManagers>>.Success(filteredList);
                {
                    var mandatoryItem = MockData.Reference.SalesManagers.SalesManagersList().Where(x => x.Id == mandatoryId).ToList().First();
                    filteredList.Add(mandatoryItem);
                }
                return TransactionResult<IEnumerable<SalesManagers>>.Success(filteredList);
            });

        // Act
        var result = await _controller.GetSalesManagers(3, null, null, null, null);

        // Assert
        var statusCodeResult = Assert.IsType<OkObjectResult>(result);
        var returnData = Assert.IsAssignableFrom<IEnumerable<SalesManagers>>(statusCodeResult.Value);
        var returnList = returnData.ToList();
        Assert.Equal(StatusCodes.Status200OK, statusCodeResult.StatusCode);
        Assert.NotNull(returnData);
        Assert.Equal(3, returnList.First().Id);
    }

    [Fact]
    public async Task GetSalesManagers_ReturnsInternalServerError()
    {
        // Arrange
        SetUserClaims();
        var resultData = TransactionResult<IEnumerable<SalesManagers>>.Failure(new Exception("Service failed"));
        _mockReferenceV1Service.Setup(s => s.GetSalesManagers(It.IsAny<long?>(), It.IsAny<bool?>(), It.IsAny<string?>(), It.IsAny<long?>(), It.IsAny<long?>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync(resultData);

        // Act
        var result = await _controller.GetSalesManagers(null, null, null, null, null);

        // Assert
        var statusCodeResult = Assert.IsType<StatusCodeResult>(result);
        Assert.Equal(StatusCodes.Status500InternalServerError, statusCodeResult.StatusCode);
    }

    [Fact]
    public async Task GetSalesManagers_ReturnsRequestTimeout()
    {
        // Arrange
        SetUserClaims();
        _mockReferenceV1Service.Setup(s => s.GetSalesManagers(It.IsAny<long?>(), It.IsAny<bool?>(), It.IsAny<string?>(), It.IsAny<long?>(), It.IsAny<long?>(), It.IsAny<CancellationToken>()))
            .ThrowsAsync(new OperationCanceledException());

        // Act
        var result = await _controller.GetSalesManagers(null, null, null, null, null);

        // Assert
        var statusCodeResult = Assert.IsType<StatusCodeResult>(result);
        Assert.Equal(StatusCodes.Status408RequestTimeout, statusCodeResult.StatusCode);
    }

    [Fact]
    public async Task GetSalesManagers_ReturnsUnauthorized()
    {
        // Arrange
        _controller.ControllerContext.HttpContext.User = null!;

        // Act
        var result = await _controller.GetSalesManagers(null, null, null, null, null);

        // Assert
        var statusCodeResult = Assert.IsType<StatusCodeResult>(result);
        Assert.Equal(StatusCodes.Status401Unauthorized, statusCodeResult.StatusCode);
    }
}