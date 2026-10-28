using Serilog;

namespace DJDPatricio.IMS.API.Helpers;

public static class LogHelper
{

    public static void LogError(string title, string message, Exception? exception)
    {
        Log.Logger.Error(exception is not null
            ? $": ({StatusCodes.Status500InternalServerError}) {title} - {exception.Message}"
            : $": ({StatusCodes.Status500InternalServerError}) {title} - {message}");
    }
    public static void LogError(string title, Exception exception)
    {
        Log.Logger.Error($": ({StatusCodes.Status500InternalServerError}) {title} - {exception.Message}");
    }

    public static void LogWarning(int code, string title, string? message)
    {
        Log.Logger.Warning($": ({code}) {title} - {message}");
    }

    public static void LoInformation(int code, string title, string? message)
    {
        Log.Logger.Information($": ({code}) {title} - {message}");
    }
}