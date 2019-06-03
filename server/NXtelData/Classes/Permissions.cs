using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using MySql.Data.MySqlClient;

namespace NXtelData
{
    public class Permissions : List<Permission>
    {
        public static Permissions Load(string UserID, MySqlConnection ConX = null)
        {
            var list = new Permissions();
            if (string.IsNullOrWhiteSpace(UserID))
                return list;
            bool openConX = ConX == null;
            if (openConX)
            {
                ConX = new MySqlConnection(DBOps.ConnectionString);
                ConX.Open();
            }

            string sql = @"SELECT MIN(p.UserPermissionID) AS UserPermissionID,p.PermissionType,p.`From`,p.`To`
                FROM userpermission p
                LEFT JOIN template t ON p.PermissionType=1 AND p.`From`=t.TemplateID
                LEFT JOIN zone z ON p.PermissionType=2 AND p.`From`=z.ZoneID
                LEFT JOIN telesoftware f on p.PermissionType=3 AND p.`From`=f.TeleSoftwareID
                WHERE p.UserID=@UserID
                AND (p.PermissionType=0
                OR t.TemplateID>0 OR z.ZoneID>0 OR f.TeleSoftwareID >0)
                GROUP BY p.PermissionType,p.`From`,p.`To`;";
            using (var cmd = new MySqlCommand(sql, ConX))
            {
                cmd.Parameters.AddWithValue("UserID", UserID.Trim());
                using (var rdr = cmd.ExecuteReader())
                {
                    while (rdr.Read())
                    {
                        var item = new Permission();
                        item.UserPermissionID = rdr.GetInt32("UserPermissionID");
                        item.Type = (PermissionTypes)rdr.GetInt32("PermissionType");
                        item.From = rdr.GetInt32("From");
                        if (item.Type == PermissionTypes.Page)
                        {
                            item.To = rdr.GetInt32("To");
                            if (item.From > item.To)
                            {
                                int temp = item.To;
                                item.To = item.From;
                                item.From = temp;
                            }
                            if (item.From >= 0 && item.To >= 0)
                                list.Add(item);
                        }
                        else
                            list.Add(item);
                    }
                }
            }

            if (openConX)
                ConX.Close();

            return list;
        }

        public bool Save(string UserID, out string Err, MySqlConnection ConX = null)
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
                string ids = string.Join(",", this.Where(r => r.UserPermissionID > 0).Select(r => r.UserPermissionID));
                var rv = Delete(UserID, ids, out Err, ConX);
                if (!string.IsNullOrWhiteSpace(Err))
                    return false;

                foreach (var pr in this)
                    pr.Save(UserID, ConX);
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

        public static bool Delete(string UserID, string IDs, out string Err, MySqlConnection ConX = null)
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
                string filter = "";
                if (!string.IsNullOrWhiteSpace(IDs))
                    filter = " AND UserPermissionID NOT IN (" + IDs + ")";
                string sql = @"DELETE FROM userpermission
                    WHERE UserID=@UserID" + filter;
                var cmd = new MySqlCommand(sql, ConX);
                cmd.Parameters.AddWithValue("UserID", (UserID ?? "").Trim());
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
    }
}
