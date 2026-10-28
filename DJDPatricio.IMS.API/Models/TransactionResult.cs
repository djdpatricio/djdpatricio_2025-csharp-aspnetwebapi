using DJDPatricio.IMS.API.Helpers;

namespace DJDPatricio.IMS.API.Models;

public class TransactionResult<T>(bool isSuccess, string message, T? data, Exception? exception)
{
    public bool IsSuccess { get; } = isSuccess;
    public string Message { get; } = message;
    public Exception? Exception { get; } = exception;
    public T? Data { get; } = data;

    public static TransactionResult<T> Success()
    {
        return new TransactionResult<T>(true, MessageHelper.Success.Generic, default, null);
    }
    public static TransactionResult<T> Success(string message)
    {
        return new TransactionResult<T>(true, message, default, null);
    }
    public static TransactionResult<T> Success(T data)
    {
        return new TransactionResult<T>(true, MessageHelper.Success.Generic, data, null);
    }
    public static TransactionResult<T> Success(string message, T data)
    {
        return new TransactionResult<T>(true, message, data, null);
    }

    public static TransactionResult<T> Failure()
    {
        return new TransactionResult<T>(false, MessageHelper.Error.Generic, default, null);
    }
    public static TransactionResult<T> Failure(string message)
    {
        return new TransactionResult<T>(false, message, default, null);
    }
    public static TransactionResult<T> Failure(Exception exception)
    {
        return new TransactionResult<T>(false, MessageHelper.Error.Generic, default, exception);
    }
    public static TransactionResult<T> Failure(string message, Exception exception)
    {
        return new TransactionResult<T>(false, message, default, exception);
    }
}

public class TransactionResult(bool isSuccess, string message, Exception? exception)
{
    public bool IsSuccess { get; } = isSuccess;
    public string Message { get; } = message;
    public Exception? Exception { get; } = exception;

    public static TransactionResult Success()
    {
        return new TransactionResult(true, MessageHelper.Success.Generic, null);
    }
    public static TransactionResult Success(string message)
    {
        return new TransactionResult(true, message, null);
    }
    public static TransactionResult Failure()
    {
        return new TransactionResult(false, MessageHelper.Error.Generic, null);
    }
    public static TransactionResult Failure(string message)
    {
        return new TransactionResult(false, message, null);
    }
    public static TransactionResult Failure(Exception exception)
    {
        return new TransactionResult(false, MessageHelper.Error.Generic, exception);
    }
    public static TransactionResult Failure(string message, Exception exception)
    {
        return new TransactionResult(false, message, exception);
    }
}