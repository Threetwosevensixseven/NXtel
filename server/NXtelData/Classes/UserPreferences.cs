using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Text;
using MySql.Data.MySqlClient;

namespace NXtelData
{
    public class UserPreferences
    {
        public string Key { get; set; }
        public string Value { get; set; }

        public static string Get(string UserID, string Key, string DefaultValue = "", MySqlConnection ConX = null)
        {
            string val = "";
            bool openConX = ConX == null;
            if (openConX)
            {
                ConX = new MySqlConnection(DBOps.ConnectionString);
                ConX.Open();
            }

            string sql = @"SELECT `Value`
                FROM userpref
                WHERE UserID=@UserID
                AND `Key`=@Key
                LIMIT 1;";
            var cmd = new MySqlCommand(sql, ConX);
            cmd.Parameters.AddWithValue("UserID", (UserID ?? "").Trim());
            cmd.Parameters.AddWithValue("Key", (Key ?? "").Trim());
            using (var rdr = cmd.ExecuteReader())
            {
                while (rdr.Read())
                {
                    val = rdr.GetStringNullable("Value");
                    break;
                }
            }

            if (string.IsNullOrEmpty(val) && !string.IsNullOrEmpty(DefaultValue))
                val = DefaultValue;

            if (openConX)
                ConX.Close();

            return val;
        }

        public static T Get<T>(string UserID, string Key, object DefaultValue = null, MySqlConnection ConX = null)
        {
            try
            {
                var converter = TypeDescriptor.GetConverter(typeof(T));
                if (converter != null)
                    return (T)converter.ConvertFromString(Get(UserID, Key, (DefaultValue ?? "").ToString(), ConX));
            }
            catch { }
            return default(T);
        }

        public static void Set(string UserID, string Key, object Value, MySqlConnection ConX = null)
        {
            bool openConX = ConX == null;
            if (openConX)
            {
                ConX = new MySqlConnection(DBOps.ConnectionString);
                ConX.Open();
            }

            string sql = @"UPDATE userpref
                SET `Value`=@Value
                WHERE UserID=@UserID
                AND `Key`=@Key;
                INSERT INTO userpref (UserID,`Key`,`Value`) 
                VALUES (@UserID,@Key,@Value);";
            var cmd = new MySqlCommand(sql, ConX);
            cmd.Parameters.AddWithValue("UserID", (UserID ?? "").Trim());
            cmd.Parameters.AddWithValue("Key", (Key ?? "").Trim());
            cmd.Parameters.AddWithValue("Value", (Value ?? "").ToString());
            try
            {
                cmd.ExecuteNonQuery();
            }
            catch { }

            if (openConX)
                ConX.Close();
        }
    }
}
