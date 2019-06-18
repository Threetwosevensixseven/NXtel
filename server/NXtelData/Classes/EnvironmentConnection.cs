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

        public static bool TryParse(string Environment, out EnvironmentNames Value)
        {
            Value = default(EnvironmentNames);
            if (string.IsNullOrWhiteSpace(Environment))
                return false;
            string env = Environment.Trim().ToLower();
            foreach (var item in EnvironmentNames.Dev.GetList())
            {
                if (env == item.ToString().ToLower().Trim())
                {
                    Value = item;
                    return true;
                }
            }
            return false;
        }

        public static bool TryParse(string Environment, out EnvironmentConnection Value)
        {
            Value = null;
            if (string.IsNullOrWhiteSpace(Environment))
                return false;
            string env = Environment.Trim().ToLower();
            foreach (var item in EnvironmentNames.Dev.GetList())
            {
                if (env == item.ToString().ToLower().Trim())
                {
                    if (item == Options.Environment)
                    {
                        Value = new EnvironmentConnection();
                        Value.Environment = item;
                        Value.ConnectionString = DBOps.ConnectionString;
                        return true;
                    }
                    foreach (var con in DBOps.Settings.AdditionalConnections)
                    {
                        if (con.Environment == item)
                        {
                            Value = con;
                            return true;
                        }
                    }
                }
            }
            return false;
        }

    }
}
