using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using MySql.Data.MySqlClient;

namespace MySql.Data.MySqlClient
{
    public static class MySqlDataReaderExtensions
    {
        public static T GetValueOrDefault<T>(this MySqlDataReader dataReader, int columnIndex)
        {
            int index = Convert.ToInt32(columnIndex);
            return !dataReader.IsDBNull(index) ? (T)dataReader.GetValue(index) : default(T);
        }

        public static string GetStringNullable(this MySqlDataReader rdr, string column)
        {
            if (rdr == null)
                return "";
            if (rdr.IsDBNull(rdr.GetOrdinal(column)))
                return "";
            return rdr.GetString(column);
        }

        public static byte? GetByteNullable(this MySqlDataReader rdr, string column)
        {
            if (rdr == null)
                return null;
            if (rdr.IsDBNull(rdr.GetOrdinal(column)))
                return null;
            return rdr.GetByte(column);
        }

        public static int? GetInt32Nullable(this MySqlDataReader rdr, string column)
        {
            if (rdr == null)
                return null;
            if (rdr.IsDBNull(rdr.GetOrdinal(column)))
                return null;
            return rdr.GetInt32(column);
        }

        public static int GetInt32Safe(this MySqlDataReader rdr, string column)
        {
            if (rdr == null)
                return -1;
            if (rdr.IsDBNull(rdr.GetOrdinal(column)))
                return -1;
            return rdr.GetInt32(column);
        }

        public static bool GetBooleanSafe(this MySqlDataReader rdr, string column)
        {
            if (rdr == null)
                return false;
            if (rdr.IsDBNull(rdr.GetOrdinal(column)))
                return false;
            return rdr.GetBoolean(column);
        }

        public static byte[] GetBytesNullable(this MySqlDataReader rdr, string column)
        {
            if (rdr == null)
                return new byte[0];
            if (rdr.IsDBNull(rdr.GetOrdinal(column)))
                return new byte[0];
            return (byte[])rdr[column];
        }
    }
}
