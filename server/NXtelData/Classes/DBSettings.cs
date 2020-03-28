using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using MySql.Data.MySqlClient;

namespace NXtelData
{
    public class DBSettings
    {
        #region Public

        public static int NoticeZone
        {
            get
            {
                int val = -1;
                int.TryParse(GetValue("NoticeZone"), out val);
                return val > 0 ? val : -1;
                   
            }
            set
            {
                int val = value > 0 ? value : -1;
                SetValue("NoticeZone", val.ToString());
            }
        }

        #endregion Public

        #region Private

        private static string GetValue(string Key)
        {
            string rv = null;
            if (string.IsNullOrWhiteSpace(Key))
                return rv;
            using (var con = new MySqlConnection(DBOps.ConnectionString))
            {
                con.Open();
                string sql = @"SELECT `Value`
                    FROM settings
                    WHERE `Key`=@k;";
                using (var cmd = new MySqlCommand(sql, con))
                {
                    cmd.Parameters.AddWithValue("k", (Key ?? "").Trim());
                    using (var rdr = cmd.ExecuteReader())
                    {
                        while (rdr.Read())
                        {
                            rv = rdr.GetStringNullable("Value");
                            break;
                        }
                    }
                }
            }

            return rv;
        }

        private static void SetValue(string Key, string Value)
        {
            using (var con = new MySqlConnection(DBOps.ConnectionString))
            {
                con.Open();
                string sql = @"INSERT IGNORE INTO settings (`Key`,`Value`) VALUES (@k,@v);
                    UPDATE settings SET `Value`=@v WHERE `Key`=@k;";
                using (var cmd = new MySqlCommand(sql, con))
                {
                    cmd.Parameters.AddWithValue("k", (Key ?? "").Trim());
                    cmd.Parameters.AddWithValue("v", Value);
                    cmd.ExecuteNonQuery();
                }
            }
        }

        #endregion Public

    }
}
