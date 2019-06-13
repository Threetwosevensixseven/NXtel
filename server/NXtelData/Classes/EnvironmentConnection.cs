using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace NXtelData
{
    public class EnvironmentConnection
    {
        public EnvironmentNames Environment { get; set; }
        public string ConnectionString { get; set; }

        public EnvironmentConnection()
        {
        }

        public EnvironmentConnection(EnvironmentNames Environment, string ConnectionString)
        {
            this.Environment = Environment;
            this.ConnectionString = ConnectionString;
        }
    }
}
