namespace DJDPatricio.IMS.API.Models.Result.Custom;

public class ValidationResult
{
    public bool IsValid { get; set; } = true;
    public string Field { get; set; } = string.Empty;
    public string Message { get; set; } = string.Empty;
}

