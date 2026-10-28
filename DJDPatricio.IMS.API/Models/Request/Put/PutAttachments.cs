namespace DJDPatricio.IMS.API.Models.Request.Put;

public class PutAttachments
{
    public long Id { get; set; }
    public string? ContentType { get; set; }
    public string FileName { get; set; } = string.Empty;
    public byte[] Attachment { get; set; } = [];
}