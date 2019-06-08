using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Linq;
using System.Text;

namespace NXtelData
{
    public static class EnumExtensions
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

        public static List<T> GetList<T>(this T Value)
        {
            var list = new List<T>();
            foreach (T item in Enum.GetValues(typeof(T)))
                list.Add(item);
            return list;
        }

        public static List<KeyValuePair<Int32, string>> GetKVPListInt32<T>(this T Value, Int32? FirstKey = null, string FirstValue = null)
        {
            var list = new List<KeyValuePair<Int32, string>>();
            if (FirstKey != null) list.Add(new KeyValuePair<Int32, string>((Int32)FirstKey, FirstValue ?? "Select..."));
            foreach (T item in Enum.GetValues(typeof(T)))
                list.Add(new KeyValuePair<Int32, string>((int)(object)item, item.GetDescription()));
            return list;
        }

        public static List<KeyValuePair<char, string>> GetKVPListChar<T>(this T Value, char? FirstKey = null, string FirstValue = null)
        {
            var list = new List<KeyValuePair<char, string>>();
            if (FirstKey != null) list.Add(new KeyValuePair<char, string>((char)FirstKey, FirstValue ?? "Select..."));
            foreach (T item in Enum.GetValues(typeof(T)))
                list.Add(new KeyValuePair<char, string>((char)(int)(object)item, item.GetDescription()));
            return list;
        }

        public static List<KeyValuePair<string, string>> GetKVPListString<T>(this T Value, string FirstKey = null, string FirstValue = null)
        {
            var list = new List<KeyValuePair<string, string>>();
            if (FirstKey != null) list.Add(new KeyValuePair<string, string>(FirstKey, FirstValue ?? "Select..."));
            foreach (T item in Enum.GetValues(typeof(T)))
                list.Add(new KeyValuePair<string, string>(item.GetDefaultValue(), item.GetDescription()));
            return list;
        }

        public static int GetEnumDefaultValueInt32(object Value)
        {
            if (Value == null || !Value.GetType().IsEnum)
                throw new ArgumentException("Value must be of an an enumerated type");
            object valueo = (object)Value;
            int valuei = (int)valueo;
            foreach (int val in Enum.GetValues(Value.GetType()))
            {
                if (val == valuei)
                    return valuei;
            }
            return default(int);
        }

        public static char GetEnumDefaultValueChar(object Value)
        {
            if (Value == null || !Value.GetType().IsEnum)
                throw new ArgumentException("Value must be of an an enumerated type");
            System.Reflection.FieldInfo fi = Value.GetType().GetField(Value.ToString());
            DefaultValueAttribute[] attributes =
            (DefaultValueAttribute[])fi.GetCustomAttributes(
            typeof(DefaultValueAttribute),
            false);
            if (attributes != null &&
            attributes.Length > 0)
                return (attributes[0].Value ?? "\0").ToString()[0];
            else
            {
                object valueo = (object)Value;
                int valuei = (int)valueo;
                char valuec = (char)valuei;
                foreach (int val in Enum.GetValues(Value.GetType()))
                {
                    if (val == valuei)
                        return valuec;
                }
                return default(char);
            }
        }

        public static string GetEnumDefaultValueString(object Value)
        {
            if (Value == null || !Value.GetType().IsEnum)
                throw new ArgumentException("Value must be of an an enumerated type");
            System.Reflection.FieldInfo fi = Value.GetType().GetField(Value.ToString());
            DefaultValueAttribute[] attributes =
            (DefaultValueAttribute[])fi.GetCustomAttributes(
            typeof(DefaultValueAttribute),
            false);
            if (attributes != null &&
            attributes.Length > 0)
                return (attributes[0].Value ?? "").ToString();
            else
            {
                object valueo = (object)Value;
                int valuei = (int)valueo;
                char valuec = (char)valuei;
                string values = valuec.ToString();
                foreach (int val in Enum.GetValues(Value.GetType()))
                {
                    if (val == valuei)
                        return values;
                }
                return "";
            }
        }

        public static string GetDefaultValue<T>(this T Value)
        {
            System.Reflection.FieldInfo fi = Value.GetType().GetField(Value.ToString());
            DefaultValueAttribute[] attributes =
            (DefaultValueAttribute[])fi.GetCustomAttributes(
            typeof(DefaultValueAttribute),
            false);
            if (attributes != null &&
            attributes.Length > 0)
            {
                return attributes[0].Value == null ? null : attributes[0].Value.ToString();
            }
            else
            {
                object valueo = (object)Value;
                int valuei = (int)valueo;
                char valuec = (char)valuei;
                string values = valuec.ToString();
                string valued = Value.ToString();
                foreach (int val in Enum.GetValues(typeof(T)))
                {
                    if (val == valuei)
                        return values;
                }
                return Value.ToString();
            }
        }

        public static T DREnumChar<T>(DataRow dr, string dataElementName, T defaultValue = default(T)) where T : struct, IConvertible
        {
            if (!typeof(T).IsEnum)
                // Deliberately thrown because this would be a coding design error not a runtime data error
                throw new ArgumentException("T must be an enumerated type");
            try
            {
                if (dr[dataElementName] == DBNull.Value)
                    return defaultValue;
                else
                {
                    int dbval = dr[dataElementName].ToString()[0];
                    foreach (object val in Enum.GetValues(typeof(T)))
                    {
                        if ((int)val == dbval)
                            return (T)val;
                    }
                    return defaultValue;
                }
            }
            catch { return defaultValue; }
        }

        public static T DREnumInt32<T>(DataRow dr, string dataElementName, T defaultValue = default(T)) where T : struct, IConvertible
        {
            if (!typeof(T).IsEnum)
                // Deliberately thrown because this would be a coding design error not a runtime data error
                throw new ArgumentException("T must be an enumerated type");
            try
            {
                if (dr[dataElementName] == DBNull.Value)
                    return defaultValue;
                else
                {
                    int dbval = Int32.Parse(dr[dataElementName].ToString());
                    foreach (object val in Enum.GetValues(typeof(T)))
                    {
                        if ((int)val == dbval)
                            return (T)val;
                    }
                    return defaultValue;
                }
            }
            catch { return defaultValue; }
        }

        public static T EnumString<T>(string value, T defaultValue = default(T)) where T : struct, IConvertible
        {
            if (!typeof(T).IsEnum)
                // Deliberately thrown because this would be a coding design error not a runtime data error
                throw new ArgumentException("T must be an enumerated type");
            try
            {
                if (string.IsNullOrEmpty(value))
                    return defaultValue;
                else
                {
                    foreach (T val in Enum.GetValues(typeof(T)))
                    {
                        if (value == GetDefaultValue<T>(val))
                            return val;
                    }
                    return defaultValue;
                }
            }
            catch { return defaultValue; }
        }

        public static T DREnumString<T>(DataRow dr, string dataElementName, T defaultValue = default(T)) where T : struct, IConvertible
        {
            if (!typeof(T).IsEnum)
                // Deliberately thrown because this would be a coding design error not a runtime data error
                throw new ArgumentException("T must be an enumerated type");
            try
            {
                if (dr[dataElementName] == DBNull.Value)
                    return defaultValue;
                else
                {
                    string dbval = dr[dataElementName].ToString();
                    foreach (T val in Enum.GetValues(typeof(T)))
                    {
                        if (dbval == GetDefaultValue<T>(val))
                            return val;
                    }
                    return defaultValue;
                }
            }
            catch { return defaultValue; }
        }
    }
}
