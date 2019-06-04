using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using MySql.Data.MySqlClient;

namespace NXtelData
{
    public class User
    {
        public string ID { get; set; }
        public List<string> Roles { get; set; }
        [Display(Name = "Email Address")]
        [Required(ErrorMessage = "Email Address is required.")]
        public string Email { get; set; }
        [Display(Name = "Email Confirmed?")]
        public bool EmailConfirmed { get; set; }
        [Required(ErrorMessage = "Mailbox must be a number between 100,000,000 and 999,999,999.")]
        [Range(100000000, 999999999, ErrorMessage = "Mailbox must be a number between 100,000,000 and 999,999,999.")]
        public string Mailbox { get; set; }
        public Permissions Permissions { get; set; }
        [Display(Name = "First Name")]
        public string FirstName { get; set; }
        [Display(Name = "Last Name")]
        public string LastName { get; set; }
        public int UserNo { get; set; }

        public User()
        {
            ID = Email = Mailbox = FirstName = LastName = "";
            UserNo = -1;
            Roles = new List<string>();
            Permissions = new Permissions();
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
                string sql = @"SELECT u.Id,Email,EmailConfirmed,Mailbox,r.`Name` AS Role,
                    u.FirstName,u.LastName
                    FROM aspnetusers u
                    LEFT JOIN aspnetuserroles ur ON u.Id = ur.UserId
                    LEFT JOIN aspnetroles r ON ur.RoleId = r.Id
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
                        user.FirstName = rdr.GetStringNullable("FirstName").Trim();
                        user.LastName = rdr.GetStringNullable("LastName").Trim();
                        string role = rdr.GetStringNullable("Role").Trim();
                        if (!string.IsNullOrEmpty(role))
                            user.Roles.Add(role);
                    }
                }
                if (!string.IsNullOrWhiteSpace(user.ID))
                    user.Permissions = Permissions.Load(user.ID, con);

            }
            return user;
        }

        public static User LoadByUserName(string UserName)
        {
            var user = new User();
            using (var con = new MySqlConnection(DBOps.ConnectionString))
            {
                con.Open();
                string sql = @"SELECT u.Id,Email,EmailConfirmed,Mailbox,r.`Name` AS Role,
                    u.FirstName,u.LastName,u.UserNo
                    FROM aspnetusers u
                    LEFT JOIN aspnetuserroles ur ON u.Id = ur.UserId
                    LEFT JOIN aspnetroles r ON ur.RoleId = r.Id
                    WHERE u.UserName=@UserName;";
                var cmd = new MySqlCommand(sql, con);
                cmd.Parameters.AddWithValue("UserName", UserName);
                using (var rdr = cmd.ExecuteReader())
                {
                    while (rdr.Read())
                    {
                        user.ID = rdr.GetString("Id").Trim();
                        user.Email = rdr.GetString("Email").Trim();
                        user.EmailConfirmed = rdr.GetBoolean("EmailConfirmed");
                        user.Mailbox = rdr.GetString("Mailbox").Trim();
                        user.FirstName = rdr.GetStringNullable("FirstName").Trim();
                        user.LastName = rdr.GetStringNullable("LastName").Trim();
                        user.UserNo = rdr.GetInt32Safe("UserNo");
                        string role = rdr.GetStringNullable("Role").Trim();
                        if (!string.IsNullOrEmpty(role))
                            user.Roles.Add(role);
                    }
                }
                if (!string.IsNullOrWhiteSpace(user.ID))
                    user.Permissions = Permissions.Load(user.ID, con);

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
                    string sql = @"DELETE FROM aspnetuserclaims WHERE UserId=@ID;
                        DELETE FROM aspnetuserlogins WHERE UserId=@ID;
                        DELETE FROM aspnetuserroles WHERE UserId=@ID;
                        DELETE FROM aspnetusers WHERE Id=@ID;";
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
                    string sql = @"UPDATE aspnetusers 
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
                throw ex;
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
                    string sql = @"UPDATE aspnetusers
                        SET email=@email,
                        emailconfirmed=@emailconfirmed,
                        mailbox=@mailbox,
                        FirstName=@FirstName,
                        LastName=@LastName
                        WHERE id=@id;
                        SELECT ROW_COUNT();";
                    var cmd = new MySqlCommand(sql, con);
                    cmd.Parameters.AddWithValue("email", (Email ?? "").Trim());
                    cmd.Parameters.AddWithValue("emailconfirmed", EmailConfirmed);
                    cmd.Parameters.AddWithValue("mailbox", (Mailbox ?? "").Trim());
                    cmd.Parameters.AddWithValue("FirstName", (FirstName ?? "").Trim());
                    cmd.Parameters.AddWithValue("LastName", (LastName ?? "").Trim());
                    cmd.Parameters.AddWithValue("id", (ID ?? "").Trim());
                    int rv = cmd.ExecuteScalarInt32();
                    if (rv <= 0)
                        Err = "The user could not be saved.";

                    if (!string.IsNullOrWhiteSpace(ID))
                    {
                        NXtelData.Roles.SaveForUser(ID, Roles, out Err, con);
                        if (!string.IsNullOrWhiteSpace(Err))
                            return false;
                        Permissions.Save(ID, out Err, con);
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

        public string Name
        {
            get
            {
                string join = string.IsNullOrEmpty(LastName) || string.IsNullOrEmpty(FirstName) ? "" : ", ";
                return (LastName ?? "").Trim() + join + (FirstName ?? "").Trim();
            }
        }
    }
}
