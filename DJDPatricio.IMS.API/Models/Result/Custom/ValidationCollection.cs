using System.Linq.Expressions;

namespace DJDPatricio.IMS.API.Models.Result.Custom
{
    public class ValidationCollection
    {

        public required Expression<Func<object>> Field { get; set; }
        public string Action { get; set; } = string.Empty;
        public bool IsNullable { get; set; } = false;
        public long SelectionTypeId { get; set; }

        //If Date
        public DateTime MinDate { get; set; } = DateTime.MinValue;
        public DateTime MaxDate { get; set; } = DateTime.MaxValue;

        //If String
        public int MinLength { get; set; } = int.MinValue;
        public int MaxLength { get; set; } = int.MaxValue;
        public string Pattern { get; set; } = string.Empty;
        public bool IsEmptyStringAllowed { get; set; } = false;

        //If Int
        public int IntMinValue { get; set; } = int.MinValue;
        public int IntMaxValue { get; set; } = int.MaxValue;

        //If Long
        public long LongMinValue { get; set; } = long.MinValue;
        public long LongMaxValue { get; set; } = long.MaxValue;

        //If Decimal
        public decimal DecimalMinValue { get; set; } = decimal.MinValue;
        public decimal DecimalMaxValue { get; set; } = decimal.MaxValue;
        public int DecimalMaxPrecision { get; set; } = 21;
        public int DecimalMaxScale { get; set; } = 8;
        public int DecimalDefaultMaxPrecision { get; set; } = 21;
        public int DecimalDefaultMaxScale { get; set; } = 8;
    }
}