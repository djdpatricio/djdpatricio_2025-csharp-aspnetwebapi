using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Asp.Versioning;
using DJDPatricio.IMS.API.Helpers.Config;
using DJDPatricio.IMS.API.Repository.Interface;
using DJDPatricio.IMS.API.Repository.Interface.V1;
using DJDPatricio.IMS.API.Repository.Repository;
using DJDPatricio.IMS.API.Repository.Repository.V1;
using DJDPatricio.IMS.API.Service.Interface.V1;
using DJDPatricio.IMS.API.Service.Service.V1;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using Serilog;
using Swashbuckle.AspNetCore.SwaggerGen;

namespace DJDPatricio.IMS.API;

public class Program
{
    public static void Main(string[] args)
    {
        var builder = WebApplication.CreateBuilder(args);

        // Logging
        Log.Logger = new LoggerConfiguration()
            .MinimumLevel.Verbose()
            .WriteTo.File("Logs/Log.log", rollingInterval: RollingInterval.Day, fileSizeLimitBytes: null, rollOnFileSizeLimit: true, outputTemplate: "[{Timestamp:yyyy-MM-dd HH:mm:ss.fff} UTC] [{Level:u3}] {Message:lj}{NewLine}{Exception}")
            .CreateLogger();
        builder.Services.AddLogging();

        // Configurations
        var configurationBuilder = new ConfigurationBuilder();
        configurationBuilder.AddJsonFile("appsettings.json", optional: false, reloadOnChange: true);
        if (builder.Environment.IsDevelopment())
        {
            configurationBuilder.AddJsonFile($"appsettings.{builder.Environment.EnvironmentName}.json", optional: true, reloadOnChange: true);
            configurationBuilder.AddUserSecrets<Program>(optional: true);
        }
        else
        {
            configurationBuilder.AddJsonFile("/run/secrets/appsettings.Production.json", optional: false, reloadOnChange: true);
        }
        configurationBuilder.AddEnvironmentVariables();
        IConfiguration configuration = configurationBuilder.Build();
        ConnectionStringsConfig.Initialize(configuration);
        AuthenticationConfig.Initialize(configuration);
        if (Encoding.UTF8.GetByteCount(AuthenticationConfig.Config.JwtKey) < 32)
        {
            throw new InvalidOperationException("Authentication:JwtKey is missing or shorter than 32 bytes. Set it with dotnet user-secrets or the Authentication__JwtKey environment variable, see README How to Run.");
        }
        SystemDefaultsConfig.Initialize(configuration);
        CorsOriginConfig.Initialize(configuration);

        // Documentation
        builder.Services.AddApiVersioning(options =>
        {
            options.ReportApiVersions = true;
            options.AssumeDefaultVersionWhenUnspecified = true;
            options.DefaultApiVersion = new ApiVersion(1, 0);
            options.ApiVersionReader = new UrlSegmentApiVersionReader();
        }).AddApiExplorer(options =>
        {
            options.GroupNameFormat = "'v'VVV";
            options.SubstituteApiVersionInUrl = true;
            options.AssumeDefaultVersionWhenUnspecified = true;
            options.DefaultApiVersion = new ApiVersion(1, 0);
        });
        builder.Services.AddControllers();
        builder.Services.AddCors(options =>
        {
            options.AddPolicy("AllowSpecificOrigin", corsPolicyBuilder =>
            {
                if (builder.Environment.IsDevelopment() || !CorsOriginConfig.Config.UseCors)
                {
                    corsPolicyBuilder
                        .AllowAnyOrigin()
                        .AllowAnyHeader()
                        .AllowAnyMethod();
                }
                else
                {
                    corsPolicyBuilder.WithOrigins(CorsOriginConfig.Config.Endpoints.ToArray())
                        .AllowAnyHeader()
                        .AllowAnyMethod();
                }
            });
        });
        builder.Services.AddEndpointsApiExplorer();
        builder.Services.AddSwaggerGen(c =>
        {
            c.SwaggerDoc("v1", new OpenApiInfo { Title = "CLIB Api : IMS3 v1", Version = "v1" });
            c.DocInclusionPredicate((docName, apiDesc) =>
            {
                var versions = apiDesc.CustomAttributes().OfType<ApiVersionAttribute>().SelectMany(attr => attr.Versions);
                return versions.Any(v => $"v{v.MajorVersion}" == docName);
            });
            c.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
            {
                Description = "JWT Authorization header using the Bearer scheme. Example: \"Authorization: Bearer {token}\"",
                Name = "Authorization",
                In = ParameterLocation.Header,
                Type = SecuritySchemeType.Http,
                Scheme = "Bearer"
            });
            c.AddSecurityRequirement(new OpenApiSecurityRequirement
            {
                {
                    new OpenApiSecurityScheme
                    {
                        Reference = new OpenApiReference { Type = ReferenceType.SecurityScheme, Id = "Bearer" }
                    },
                    Array.Empty<string>()
                }
            });
        });

        // DI - Repository
        builder.Services.AddScoped<IDbFactoryWrapperRepository, DbFactoryWrapperRepository>();
        builder.Services.AddScoped<IStaticV1Repository, StaticV1Repository>();
        builder.Services.AddScoped<IReferenceV1Repository, ReferenceV1Repository>();
        builder.Services.AddScoped<ITransactionV1Repository, TransactionV1Repository>();
        builder.Services.AddScoped<IDboV1Repository, DboV1Repository>();

        // DI - Service
        builder.Services.AddScoped<IStaticV1Service, StaticV1Service>();
        builder.Services.AddScoped<IReferenceV1Service, ReferenceV1Service>();
        builder.Services.AddScoped<ITransactionV1Service, TransactionV1Service>();
        builder.Services.AddScoped<IDboV1Service, DboV1Service>();

        // Authentication
        builder.Services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme).AddJwtBearer(options =>
        {
            options.TokenValidationParameters = new TokenValidationParameters
            {
                ValidateIssuer = true,
                ValidIssuer = AuthenticationConfig.Config.Issuer,
                ValidateAudience = true,
                ValidAudience = AuthenticationConfig.Config.Audience,
                ValidateLifetime = true,
                ValidateIssuerSigningKey = true,
                IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(AuthenticationConfig.Config.JwtKey))
            };
            options.Events = new JwtBearerEvents
            {
                OnTokenValidated = context =>
                {
                    try
                    {
                        var handler = new JwtSecurityTokenHandler();
                        var token = handler.ReadJwtToken(context.Request.Headers["Authorization"].ToString().Replace("Bearer ", ""));
                        var claims = new List<Claim>
                        {
                            new(ClaimTypes.NameIdentifier, token!.Claims.FirstOrDefault(c => c.Type == "sub")?.Value!),
                            new(ClaimTypes.Name, token.Claims.FirstOrDefault(c => c.Type == "name")?.Value!),
                            new(ClaimTypes.Role, token.Claims.FirstOrDefault(c => c.Type == "role")?.Value!),
                            new(ClaimTypes.Authentication, token.Claims.FirstOrDefault(c => c.Type == "iss")?.Value!),
                            new(ClaimTypes.AuthenticationMethod, token.Claims.FirstOrDefault(c => c.Type == "aud")?.Value!),
                            new(ClaimTypes.Expiration, token.Claims.FirstOrDefault(c => c.Type == "exp")?.Value!)
                        };
                        context.Principal!.AddIdentity(new ClaimsIdentity(claims));
                    }
                    catch (Exception ex)
                    {
                        context.Fail(ex);
                    }
                    return Task.CompletedTask;
                }
            };
        });
        builder.Services.AddAuthorization();

        // Building the app
        var app = builder.Build();
        app.Use(async (context, next) =>
        {
            if (context.Request.Path == "/")
            {
                context.Response.Redirect("/swagger/index.html");
                return;
            }
            await next();
        });

        // Middleware Configuration (Order matters)
        app.UseSwagger();
        app.UseSwaggerUI(c =>
        {
            c.SwaggerEndpoint("/swagger/v1/swagger.json", "CLIB Api : IMS3 v1");
            c.RoutePrefix = "swagger";
        });
        app.UseHttpsRedirection();
        app.UseCors("AllowSpecificOrigin");
        app.UseAuthentication();
        app.UseAuthorization();
        app.MapControllers();

        // Run the application
        app.Run();
    }
}