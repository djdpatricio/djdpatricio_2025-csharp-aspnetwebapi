namespace DJDPatricio.IMS.API.Models.Result.Transaction;

public class Attachments : ResultBaseEntity
{
    public long ReferenceId { get; set; }
    public long AttachmentTypeId { get; set; }
    public string? ContentType { get; set; }
    public string FileName { get; set; } = string.Empty;
    public byte[] Attachment { get; set; } = [];
}