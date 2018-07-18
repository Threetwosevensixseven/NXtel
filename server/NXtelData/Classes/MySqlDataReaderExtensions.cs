using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using MySql.Data.MySqlClient;

namespace NXtelData
{
    internal static class MySqlDataReaderExtensions
    {
        public static T GetValueOrDefault<T>(this MySqlDataReader dataReader, int columnIndex)
        {
            int index = Convert.ToInt32(columnIndex);
            return !dataReader.IsDBNull(index) ? (T)dataReader.GetValue(index) : default(T);
        }
    }
}
