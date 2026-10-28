namespace DJDPatricio.IMS.API.Models.Result.Transaction;

public class AttachmentsView : Attachments
{
    public string AttachmentType { get; set; } = string.Empty;
    public long PolicyId { get; set; }
    public string PolicyReferenceNumber { get; set; } = string.Empty;
    public string PolicyCocNumber { get; set; } = string.Empty;
}