using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using MySql.Data.MySqlClient;

namespace NXtelData
{
    public static class Character
    {
        private static Dictionary<char, byte> _substitutions = null;

        public static byte Substitute(char Unicode)
        {
            if (_substitutions == null)
            {
                _substitutions = new Dictionary<char, byte>();
                _substitutions.Add('’', Convert.ToByte("'"[0]));
                _substitutions.Add('‘', Convert.ToByte("'"[0]));
            }
            if (_substitutions.ContainsKey(Unicode))
                return _substitutions[Unicode];

            _substitutions.Add(Unicode, Convert.ToByte('\0'));
            using (var con = new MySqlConnection(DBOps.ConnectionString))
            {
                con.Open();
                string sql = @"INSERT IGNORE INTO charsub (UnhandledChar) VALUES (@UnhandledChar);";
                var cmd = new MySqlCommand(sql, con);
                cmd.Parameters.AddWithValue("UnhandledChar", Unicode);
                cmd.ExecuteNonQuery();
            }
            return Convert.ToByte('\0');
        }
    }
}
