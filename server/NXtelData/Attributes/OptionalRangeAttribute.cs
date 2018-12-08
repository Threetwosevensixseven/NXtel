using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace System.ComponentModel.DataAnnotations
{
    public class OptionalRangeAttribute : RangeAttribute
    {
        public OptionalRangeAttribute(int minimum, int maximum) 
            : base(minimum, maximum)
        {
        }

        public OptionalRangeAttribute(double minimum, double maximum) 
            : base(minimum, maximum)
        {
        }

        public OptionalRangeAttribute(Type type, string minimum, string maximum) 
            : base(type, minimum, maximum)
        {
        }

        public override bool IsValid(object value)
        {
            int i;
            bool converted = int.TryParse((value ?? "").ToString(), out i);
            if (value == null || (converted && i == 0)) return true;
            return base.IsValid(value);
        }
    }
}