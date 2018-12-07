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
        public UserPageRanges PageRanges { get; set; }

        public User()
        {
            ID = Email = Mailbox = "";
            Roles = new List<string>();
            PageRanges = new UserPageRanges();
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
                if (!string.IsNullOrWhiteSpace(user.ID))
                    user.PageRanges = UserPageRanges.Load(user.ID, con);

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
            catch (Exception /*ex*/)
            {
                return "";
            }
        }

        public static bool Save(User User, out string Err)
        {
            Err = "";
            try
            {
                if (string.IsNullOrWhiteSpace(User.ID))
                    throw new InvalidOperationException("You cannot create a user from here.");
                else
                    return User.Update(out Err);
            }
            catch (Exception ex)
            {
                Err = ex.Message;
                return false;
            }
        }

        public bool Update(out string Err)
        {
            Err = "";
            try
            {
                using (var con = new MySqlConnection(DBOps.ConnectionString))
                {
                    con.Open();
                    string sql = @"UPDATE AspNetUsers
                        SET email=@email,
                        emailconfirmed=@emailconfirmed,
                        mailbox=@mailbox
                        WHERE id=@id;
                        SELECT ROW_COUNT();";
                    var cmd = new MySqlCommand(sql, con);
                    cmd.Parameters.AddWithValue("email", (Email ?? "").Trim());
                    cmd.Parameters.AddWithValue("emailconfirmed", EmailConfirmed);
                    cmd.Parameters.AddWithValue("mailbox", (Mailbox ?? "").Trim());
                    cmd.Parameters.AddWithValue("id", (ID ?? "").Trim());
                    int rv = cmd.ExecuteScalarInt32();
                    if (rv <= 0)
                        Err = "The user could not be saved.";

                    if (!string.IsNullOrWhiteSpace(ID))
                    {
                        NXtelData.Roles.SaveForUser(ID, Roles, out Err, con);
                        if (!string.IsNullOrWhiteSpace(Err))
                            return false;
                        PageRanges.Save(ID, out Err, con);
                        if (!string.IsNullOrWhiteSpace(Err))
                            return false;

                    }

                    return rv > 0;
                }
            }
            catch (Exception ex)
            {
                Err = ex.Message;
                return false;
            }
        }
    }
}
