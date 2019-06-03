using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using MySql.Data.MySqlClient;

namespace NXtelData
{
    public class Permission
    {
        public int UserPermissionID { get; set; }
        public PermissionTypes Type { get; set; }
        public int From { get; set; }
        public int To { get; set; }

        public Permission()
        {
            UserPermissionID = From = To = -1;
        }

        public Permission(int UserPermissionID, PermissionTypes Type, int From, int To)
        {
            this.UserPermissionID = UserPermissionID;
            this.Type = Type;
            this.From = From;
            this.To = this.Type == PermissionTypes.Page ? To : -1;
        }

        public string Sort
        {
            get
            {
                int from = From;
                int to = To;
                if (to >= 0 && from > to)
                {
                    int temp = from;
                    from = to;
                    to = temp;
                }
                return ((int)Type).ToString("X8") + from.ToString("X8") + to.ToString("X8");
            }
        }

        public bool Save(string UserID, MySqlConnection ConX = null)
        {
            bool openConX = ConX == null;
            if (openConX)
            {
                ConX = new MySqlConnection(DBOps.ConnectionString);
                ConX.Open();
            }

            string sql;
            if (this.UserPermissionID <= 0)
                sql = @"INSERT INTO userpermission (UserID,PermissionType,`From`,`To`) 
                    VALUES(@UserID,@PermissionType,@From,@To);";
            else
                sql = @"UPDATE userpermission
                    SET UserID=@UserID,
                    PermissionType=@PermissionType,
                    `From`=@From,
                    `To`=@To
                    WHERE UserPermissionID=@UserPermissionID;";
            var cmd = new MySqlCommand(sql, ConX);
            cmd.Parameters.AddWithValue("UserID", (UserID ?? "").Trim());
            cmd.Parameters.AddWithValue("PermissionType", (int)Type);
            cmd.Parameters.AddWithValue("From", From);
            int? to = To > 0 ? To : (int?)null;
            cmd.Parameters.AddWithValue("To", to);
            cmd.Parameters.AddWithValue("UserPermissionID", UserPermissionID);
            cmd.ExecuteNonQuery();

            if (openConX)
                ConX.Close();

            return true;
        }

        public int PType
        {
            get
            {
                return (int)Type;
            }
        }
    }
}
