using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using MySql.Data.MySqlClient;

namespace NXtelData
{
    public class User
    {
        public string ID { get; set; }
        public List<string> Roles { get; set; }
        public string Email { get; set; }
        public bool EmailConfirmed { get; set; }
        public string Mailbox { get; set; }

        public User()
        {
            ID = Email = Mailbox = "";
            Roles = new List<string>();
        }

        public bool IsAdmin
        {
            get
            {
                return Roles.Any(r => r == "Admin");
            }
        }

        public bool IsPageEditor
        {
            get
            {
                return Roles.Any(r => r == "Page Editor");
            }
        }

        public static User Load(string UserID)
        {
            var user = new User();
            using (var con = new MySqlConnection(DBOps.ConnectionString))
            {
                con.Open();
                string sql = @"SELECT u.Id,Email,EmailConfirmed,Mailbox,r.`Name` AS Role
                    FROM AspNetUsers u
                    LEFT JOIN AspNetUserRoles ur ON u.Id = ur.UserId
                    LEFT JOIN AspNetRoles r ON ur.RoleId = r.Id
                    WHERE u.Id=@UserID;";
                var cmd = new MySqlCommand(sql, con);
                cmd.Parameters.AddWithValue("UserID", UserID);
                using (var rdr = cmd.ExecuteReader())
                {
                    while (rdr.Read())
                    {
                        user.ID = rdr.GetString("Id").Trim();
                        user.Email = rdr.GetString("Email").Trim();
                        user.EmailConfirmed = rdr.GetBoolean("EmailConfirmed");
                        user.Mailbox = rdr.GetString("Mailbox").Trim();
                        string role = rdr.GetStringNullable("Role").Trim();
                        if (!string.IsNullOrEmpty(role))
                            user.Roles.Add(role);
                    }
                }
            }
            return user;
        }

        public static bool Delete(string UserID, out string Err)
        {
            Err = "";
            try
            {
                using (var con = new MySqlConnection(DBOps.ConnectionString))
                {
                    con.Open();
                    string sql = @"DELETE FROM AspNetUserClaims WHERE UserId=@ID;
                        DELETE FROM AspNetUserLogins WHERE UserId=@ID;
                        DELETE FROM AspNetUserRoles WHERE UserId=@ID;
                        DELETE FROM AspNetUsers WHERE Id=@ID;";
                    var cmd = new MySqlCommand(sql, con);
                    cmd.Parameters.AddWithValue("ID", UserID);
                    cmd.ExecuteNonQuery();
                    return true;
                }
            }
            catch (Exception ex)
            {
                Err = ex.Message;
                return false;
            }
        }

        public static bool Confirm(string UserID, out string Err)
        {
            Err = "";
            try
            {
                using (var con = new MySqlConnection(DBOps.ConnectionString))
                {
                    con.Open();
                    string sql = @"UPDATE AspNetUsers 
                        SET EmailConfirmed=1 
                        WHERE Id=@ID;";
                    var cmd = new MySqlCommand(sql, con);
                    cmd.Parameters.AddWithValue("ID", UserID);
                    bool success = cmd.ExecuteNonQuery() > 0;
                    return success;
                }
            }
            catch (Exception ex)
            {
                Err = ex.Message;
                return false;
            }
        }

        public static string GetUniqueMailbox()
        {
            try
            {
                using (var con = new MySqlConnection(DBOps.ConnectionString))
                {
                    con.Open();
                    string sql = @"CALL sp_GetUniqueMailbox;";
                    var cmd = new MySqlCommand(sql, con);
                    return cmd.ExecuteScalar() as string;
                }
            }
            catch (Exception ex)
            {
                return "";
            }
        }
    }
}
