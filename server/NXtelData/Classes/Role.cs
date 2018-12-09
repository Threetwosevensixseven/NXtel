using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using MySql.Data.MySqlClient;

namespace NXtelData
{
    public class Role
    {
        public string ID { get; set; }
        public string Name { get; set; }

        public Role()
        {
            ID = Name = "";
        }

        public bool SaveForUser(string UserID, MySqlConnection ConX = null)
        {
            bool openConX = ConX == null;
            if (openConX)
            {
                ConX = new MySqlConnection(DBOps.ConnectionString);
                ConX.Open();
            }

            string sql = @"INSERT INTO aspnetuserroles (UserId,RoleId) VALUES(@UserId,@RoleId);";
            var cmd = new MySqlCommand(sql, ConX);
            cmd.Parameters.AddWithValue("UserId", (UserID ?? "").Trim());
            cmd.Parameters.AddWithValue("RoleId", (ID ?? "").Trim());
            cmd.ExecuteNonQuery();

            if (openConX)
                ConX.Close();

            return true;
        }
    }
}
