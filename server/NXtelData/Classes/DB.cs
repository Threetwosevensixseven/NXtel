using System;
using System.Collections.Generic;
using System.Configuration;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NXtelData
{
    internal static partial class DBOps
    {
        private static string _connectionString = null;

        public static string ConnectionString
        {
            get
            {
                if (_connectionString == null)
                {
                    _connectionString = ConfigurationManager.ConnectionStrings["NXTel"].ToString();
                }
                return _connectionString;
            }
        }
    }
}
