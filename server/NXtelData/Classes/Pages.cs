using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using MySql.Data.MySqlClient;

namespace NXtelData
{
    public class Pages : List<Page>
    {
        public static Pages Load()
        {
            var list = new Pages();
            using (var con = new MySqlConnection(DBOps.ConnectionString))
            {
                con.Open();
                string sql = "SELECT * FROM page ORDER BY PageNo,FrameNo;";
                var cmd = new MySqlCommand(sql, con);
                using (var rdr = cmd.ExecuteReader())
                {
                    while (rdr.Read())
                    {
                        var item = new Page();
                        item.Read(rdr);
                        list.Add(item);
                    }
                }
            }
            return list;
        }

        public static Pages LoadStubs()
        {
            var list = new Pages();
            using (var con = new MySqlConnection(DBOps.ConnectionString))
            {
                con.Open();
                string sql = "SELECT PageID,PageNo,FrameNo,Title FROM page ORDER BY PageNo,FrameNo;";
                var cmd = new MySqlCommand(sql, con);
                using (var rdr = cmd.ExecuteReader())
                {
                    while (rdr.Read())
                    {
                        var item = new Page();
                        item.Read(rdr, true);
                        list.Add(item);
                    }
                }
            }
            return list;
        }

    }
}
