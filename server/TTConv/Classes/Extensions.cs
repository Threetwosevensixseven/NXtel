using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace TTConv.Classes
{
    public static class Extensions
    {
        public static string GetDescription<T>(this T Value)
        {
            System.Reflection.FieldInfo fi = Value.GetType().GetField(Value.ToString());
            DescriptionAttribute[] attributes =
                (DescriptionAttribute[])fi.GetCustomAttributes(
                typeof(DescriptionAttribute),
                false);
            if (attributes != null &&
                attributes.Length > 0)
                return attributes[0].Description;
            else
                return Value.ToString();
        }

        public static string GetURL<T>(this T Value)
        {
            System.Reflection.FieldInfo fi = Value.GetType().GetField(Value.ToString());
            URLAttribute[] attributes =
                (URLAttribute[])fi.GetCustomAttributes(
                typeof(URLAttribute),
                false);
            if (attributes != null &&
                attributes.Length > 0)
                return attributes[0].URL;
            else
                return Value.ToString();
        }

    }
}
