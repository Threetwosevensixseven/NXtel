using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using MySql.Data.MySqlClient;

namespace NXtelData
{
    public class UserPageRanges : List<UserPageRange>
    {
        public static UserPageRanges Load(string UserID, MySqlConnection ConX = null)
        {
            var list = new UserPageRanges();
            bool openConX = ConX == null;
            if (openConX)
            {
                ConX = new MySqlConnection(DBOps.ConnectionString);
                ConX.Open();
            }

            string sql = @"SELECT UserPageRangeID,FromPageNo,ToPageNo
                FROM userpagerange r
                JOIN AspNetUsers u ON r.UserID=u.Id
                WHERE u.Id=@UserID
                ORDER BY FromPageNo,ToPageNo;";
            var cmd = new MySqlCommand(sql, ConX);
            cmd.Parameters.AddWithValue("UserID", (UserID ?? "").Trim());
            using (var rdr = cmd.ExecuteReader())
            {
                while (rdr.Read())
                {
                    var item = new UserPageRange();
                    item.ID = rdr.GetInt32("UserPageRangeID");
                    item.FromPageNo = rdr.GetInt32("FromPageNo");
                    item.ToPageNo = rdr.GetInt32("ToPageNo");
                    list.Add(item);
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
                string ids = string.Join(",", this.Where(r => r.ID > 0).Select(r => r.ID));
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
                    filter = " AND UserPageRangeID NOT IN (" + IDs + ")";
                string sql = @"DELETE FROM userpagerange
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
