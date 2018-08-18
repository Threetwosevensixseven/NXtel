using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MySql.Data.MySqlClient
{
    public static class MySqlCommandExtensions
    {
        public static int ExecuteScalarInt32(this MySqlCommand Command)
        {
            object val = Command.ExecuteScalar();
            int rv;
            if (int.TryParse((val ?? "").ToString(), out rv))
                return rv;
            else
                return -1;
        }
    }
}
