using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using MySql.Data.MySqlClient;

namespace NXtelData
{
    public class Roles : List<Role>
    {
        public static Roles Load(MySqlConnection ConX = null)
        {
            var list = new Roles();
            bool openConX = ConX == null;
            if (openConX)
            {
                ConX = new MySqlConnection(DBOps.ConnectionString);
                ConX.Open();
            }

            string sql = @"SELECT * FROM aspnetroles ORDER BY Name;";
            var cmd = new MySqlCommand(sql, ConX);
            using (var rdr = cmd.ExecuteReader())
            {
                while (rdr.Read())
                {
                    var item = new Role();
                    item.ID = rdr.GetStringNullable("Id");
                    item.Name = rdr.GetStringNullable("Name");
                    list.Add(item);
                }
            }

            if (openConX)
                ConX.Close();

            return list;
        }

        public static bool DeleteForUser(string UserID, out string Err, MySqlConnection ConX = null)
        {
            Err = "";
            bool openConX = ConX == null;
            if (openConX)
            {
                ConX = new MySqlConnection(DBOps.ConnectionString);
                ConX.Open();
            }
            try
            {
                string sql = @"DELETE FROM aspnetuserroles WHERE UserId=@UserId;";
                var cmd = new MySqlCommand(sql, ConX);
                cmd.Parameters.AddWithValue("UserId", (UserID ?? "").Trim());
                cmd.ExecuteNonQuery();
                return true;
            }
            catch (Exception ex)
            {
                Err = ex.Message;
                return false;
            }
            finally
            {
                if (openConX)
                    ConX.Close();
            }
        }

        public static bool SaveForUser(string UserID, List<string> Roles, out string Err, MySqlConnection ConX = null)
        {
            Err = "";
            bool openConX = ConX == null;
            if (openConX)
            {
                ConX = new MySqlConnection(DBOps.ConnectionString);
                ConX.Open();
            }
            try
            {
                var roles = NXtelData.Roles.Load(ConX);
                var rv = DeleteForUser(UserID, out Err, ConX);
                if (!string.IsNullOrWhiteSpace(Err))
                    return false;

                if (Roles == null || Roles.Count == 0)
                    return true;

                foreach (var roleName in Roles)
                {
                    var role = roles.FirstOrDefault(r => r.Name == roleName);
                    if (role != null)
                        role.SaveForUser(UserID, ConX);
                }
                return true;
            }
            catch (Exception ex)
            {
                Err = ex.Message;
                return false;
            }
            finally
            {
                if (openConX)
                    ConX.Close();
            }
        }
    }
}
