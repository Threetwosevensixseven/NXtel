using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using MySql.Data.MySqlClient;

namespace NXtelData
{
    public class Users : List<User>
    {
        public static Users Load()
        {
            var list = new Users();
            var dic = new Dictionary<string, User>();
            using (var con = new MySqlConnection(DBOps.ConnectionString))
            {
                con.Open();
                string sql = @"SELECT u.Id,Email,EmailConfirmed,Mailbox,r.`Name` AS Role,
                    u.FirstName,u.LastName
                    FROM aspnetusers u
                    LEFT JOIN aspnetuserroles ur ON u.Id = ur.UserId
                    LEFT JOIN aspnetroles r ON ur.RoleId = r.Id
                    ORDER BY EmailConfirmed DESC,Email;";
                var cmd = new MySqlCommand(sql, con);
                using (var rdr = cmd.ExecuteReader())
                {
                    while (rdr.Read())
                    {
                        User user = new User();
                        var id = rdr.GetString("Id").Trim();
                        if (dic.Keys.Contains(id))
                        {
                            user = dic[id];
                        }
                        else
                        {
                            list.Add(user);
                            dic.Add(id, user);
                            user.ID = id;
                        }
                        user.Email = rdr.GetString("Email").Trim();
                        user.EmailConfirmed = rdr.GetBoolean("EmailConfirmed");
                        user.Mailbox = rdr.GetString("Mailbox").Trim();
                        user.FirstName = rdr.GetStringNullable("FirstName").Trim();
                        user.LastName = rdr.GetStringNullable("LastName").Trim();
                        string role = rdr.GetStringNullable("Role").Trim();
                        if (!string.IsNullOrEmpty(role))
                            user.Roles.Add(role);
                    }
                }
            }
            return list;
        }
    }
}
