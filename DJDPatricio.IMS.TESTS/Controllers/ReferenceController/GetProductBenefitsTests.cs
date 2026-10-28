using System.Security.Claims;
using DJDPatricio.IMS.API.Models;
using DJDPatricio.IMS.API.Models.Result.Reference;
using DJDPatricio.IMS.API.Service.Interface.V1;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Moq;

namespace DJDPatricio.IMS.TESTS.Controllers.ReferenceController;

public class GetProductBenefitsTests
{
    private readonly Mock<IReferenceV1Service> _mockReferenceV1Service;
    private readonly API.Controllers.ReferenceController _controller;

    public GetProductBenefitsTests()
    {
        _mockReferenceV1Service = new Mock<IReferenceV1Service>();
        _controller = new API.Controllers.ReferenceController(_mockReferenceV1Service.Object);

        var httpContext = new DefaultHttpContext();

        var controllerContext = new ControllerContext
        {
            HttpContext = httpContext,
            ActionDescriptor = new Microsoft.AspNetCore.Mvc.Controllers.ControllerActionDescriptor
            {
                ActionName = "GetProductBenefits"
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
    public async Task GetProductBenefits_ReturnsOk_NoParameters()
    {
        // Arrange
        SetUserClaims();
        _mockReferenceV1Service.Setup(s => s.GetProductBenefits(It.IsAny<long?>(), It.IsAny<bool?>(), It.IsAny<long?>(), It.IsAny<long?>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync((long? id, bool? isActiveOnly, long? productsId, long? mandatoryId, CancellationToken _) =>
            {
                var filteredList = MockData.Reference.ProductBenefits.ProductBenefitsList().Where(x => (id == null || x.Id == id) && (isActiveOnly == null || x.IsActive == isActiveOnly) && (productsId == null || x.ProductsId == productsId)).ToList();
                if (mandatoryId == null) return TransactionResult<IEnumerable<ProductBenefits>>.Success(filteredList);
                {
                    var mandatoryItem = MockData.Reference.ProductBenefits.ProductBenefitsList().Where(x => x.Id == mandatoryId).ToList().First();
                    filteredList.Add(mandatoryItem);
                }
                return TransactionResult<IEnumerable<ProductBenefits>>.Success(filteredList);
            });

        // Act
        var result = await _controller.GetProductBenefits(null, null, null, null);

        // Assert
        var statusCodeResult = Assert.IsType<OkObjectResult>(result);
        var returnData = Assert.IsAssignableFrom<IEnumerable<ProductBenefits>>(statusCodeResult.Value);
        var returnList = returnData.ToList();
        Assert.Equal(StatusCodes.Status200OK, statusCodeResult.StatusCode);
        Assert.NotNull(returnData);
        Assert.True(returnList.Count > 0);
    }

    [Fact]
    public async Task GetProductBenefits_ReturnsOk_WithParameters()
    {
        // Arrange
        SetUserClaims();
        _mockReferenceV1Service.Setup(s => s.GetProductBenefits(It.IsAny<long?>(), It.IsAny<bool?>(), It.IsAny<long?>(), It.IsAny<long?>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync((long? id, bool? isActiveOnly, long? productsId, long? mandatoryId, CancellationToken _) =>
            {
                var filteredList = MockData.Reference.ProductBenefits.ProductBenefitsList().Where(x => (id == null || x.Id == id) && (isActiveOnly == null || x.IsActive == isActiveOnly) && (productsId == null || x.ProductsId == productsId)).ToList();
                if (mandatoryId == null) return TransactionResult<IEnumerable<ProductBenefits>>.Success(filteredList);
                {
                    var mandatoryItem = MockData.Reference.ProductBenefits.ProductBenefitsList().Where(x => x.Id == mandatoryId).ToList().First();
                    filteredList.Add(mandatoryItem);
                }
                return TransactionResult<IEnumerable<ProductBenefits>>.Success(filteredList);
            });

        // Act
        var result = await _controller.GetProductBenefits(1, null, null, null);

        // Assert
        var statusCodeResult = Assert.IsType<OkObjectResult>(result);
        var returnData = Assert.IsAssignableFrom<IEnumerable<ProductBenefits>>(statusCodeResult.Value);
        var returnList = returnData.ToList();
        Assert.Equal(StatusCodes.Status200OK, statusCodeResult.StatusCode);
        Assert.NotNull(returnData);
        Assert.Equal(1, returnList.First().Id);
    }

    [Fact]
    public async Task GetProductBenefits_ReturnsInternalServerError()
    {
        // Arrange
        SetUserClaims();
        var resultData = TransactionResult<IEnumerable<ProductBenefits>>.Failure(new Exception("Service failed"));
        _mockReferenceV1Service.Setup(s => s.GetProductBenefits(It.IsAny<long?>(), It.IsAny<bool?>(), It.IsAny<long?>(), It.IsAny<long?>(), It.IsAny<CancellationToken>()))
            .ReturnsAsync(resultData);

        // Act
        var result = await _controller.GetProductBenefits(null, null, null, null);

        // Assert
        var statusCodeResult = Assert.IsType<StatusCodeResult>(result);
        Assert.Equal(StatusCodes.Status500InternalServerError, statusCodeResult.StatusCode);
    }

    [Fact]
    public async Task GetProductBenefits_ReturnsRequestTimeout()
    {
        // Arrange
        SetUserClaims();
        _mockReferenceV1Service.Setup(s => s.GetProductBenefits(It.IsAny<long?>(), It.IsAny<bool?>(), It.IsAny<long?>(), It.IsAny<long?>(), It.IsAny<CancellationToken>()))
            .ThrowsAsync(new OperationCanceledException());

        // Act
        var result = await _controller.GetProductBenefits(null, null, null, null);

        // Assert
        var statusCodeResult = Assert.IsType<StatusCodeResult>(result);
        Assert.Equal(StatusCodes.Status408RequestTimeout, statusCodeResult.StatusCode);
    }

    [Fact]
    public async Task GetProductBenefits_ReturnsUnauthorized()
    {
        // Arrange
        _controller.ControllerContext.HttpContext.User = null!;

        // Act
        var result = await _controller.GetProductBenefits(null, null, null, null);

        // Assert
        var statusCodeResult = Assert.IsType<StatusCodeResult>(result);
        Assert.Equal(StatusCodes.Status401Unauthorized, statusCodeResult.StatusCode);
    }
}