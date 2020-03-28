using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using MySql.Data.MySqlClient;

namespace NXtelData
{
    public class Zones : List<Zone>
    {
        public static Zones Load(MySqlConnection ConX = null)
        {
            var list = new Zones();
            bool openConX = ConX == null;
            if (openConX)
            {
                ConX = new MySqlConnection(DBOps.ConnectionString);
                ConX.Open();
            }

            string sql = @"SELECT * FROM zone ORDER BY Description,ZoneID;";
            var cmd = new MySqlCommand(sql, ConX);
            using (var rdr = cmd.ExecuteReader())
            {
                while (rdr.Read())
                {
                    var item = new Zone();
                    item.ID = rdr.GetInt32("ZoneID");
                    item.Description = rdr.GetStringNullable("Description");
                    list.Add(item);
                }
            }

            if (openConX)
                ConX.Close();

            return list;
        }

        public static Zones Search(string Value, bool AllowNone, MySqlConnection ConX = null)
        {
            var list = new Zones();
            if (AllowNone)
                list.Add(new Zone() { ID = -1, Description = "[None]" });
            bool openConX = ConX == null;
            if (openConX)
            {
                ConX = new MySqlConnection(DBOps.ConnectionString);
                ConX.Open();
            }

            Value = Value ?? "";
            string filter = "1=0";
            if (Value.Length > 0)
            {
                filter = "Description LIKE @Description";
                Value = "%" + Value + "%";
            }

            string sql = @"SELECT * 
                FROM zone
                WHERE " + filter + @"
                ORDER BY Description,ZoneID;";
            using (var cmd = new MySqlCommand(sql, ConX))
            {
                cmd.Parameters.AddWithValue("@Description", Value);
                using (var rdr = cmd.ExecuteReader())
                {
                    while (rdr.Read())
                    {
                        var item = new Zone();
                        item.ID = rdr.GetInt32("ZoneID");
                        item.Description = rdr.GetStringNullable("Description");
                        list.Add(item);
                    }
                }
            }

            if (openConX)
                ConX.Close();

            return list;
        }

        public static Zones LoadForPage(int PageID, MySqlConnection ConX = null)
        {
            var list = new Zones();
            bool openConX = ConX == null;
            if (openConX)
            {
                ConX = new MySqlConnection(DBOps.ConnectionString);
                ConX.Open();
            }

            string sql = @"SELECT z.*
                FROM pagezone pz
                JOIN zone z ON z.ZoneID=pz.ZoneID
                JOIN `page` p ON p.PageID=pz.PageID
                WHERE p.PageID="+ PageID + @"
                ORDER BY z.Description,z.ZoneID;";
            var cmd = new MySqlCommand(sql, ConX);
            using (var rdr = cmd.ExecuteReader())
            {
                while (rdr.Read())
                {
                    var item = new Zone();
                    item.ID = rdr.GetInt32("ZoneID");
                    item.Description = rdr.GetStringNullable("Description");
                    list.Add(item);
                }
            }

            if (openConX)
                ConX.Close();

            return list;
        }

        public bool DeleteForPage(int PageID, out string Err, MySqlConnection ConX = null)
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
                string sql = @"DELETE FROM pagezone WHERE PageID=" + PageID;
                var cmd = new MySqlCommand(sql, ConX);
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

        public bool SaveForPage(int PageID, out string Err, MySqlConnection ConX = null)
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
                var rv = DeleteForPage(PageID, out Err, ConX);
                if (!string.IsNullOrWhiteSpace(Err))
                    return false;
                foreach (var item in this)
                    item.SaveForPage(PageID, ConX);
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
