namespace DJDPatricio.IMS.API.Helpers;

public static class MessageHelper
{
    public const string CustomSqlException = "CustomSQLException: ";
    public static class Success
    {
        public const string Generic = "Success";
    }

    public static class Error
    {
        public const string Forbidden = "Forbidden";
        public const string BadRequest = "Bad Request";
        public const string NotFound = "Not Found";

            

        public const string Generic = "An unexpected error occurred";
        public const string NoAccess = "Unable to continue. You do not have access to this item.";
        public static class Account
        {
            public const string SignInFailed = "The credentials you entered are invalid, please try again!";
        }
        public static class Policy
        {
            public const string PolicyNotFound = "Policy not found";
        }
    }
}