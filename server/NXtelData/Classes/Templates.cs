using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using MySql.Data.MySqlClient;

namespace NXtelData
{
    public class Templates : List<Template>
    {
        public static Templates Load()
        {
            var list = new Templates();
            using (var con = new MySqlConnection(DBOps.ConnectionString))
            {
                con.Open();
                string sql = "SELECT * FROM template ORDER BY Description,TemplateID;";
                var cmd = new MySqlCommand(sql, con);
                using (var rdr = cmd.ExecuteReader())
                {
                    while (rdr.Read())
                    {
                        var item = new Template();
                        item.Read(rdr);
                        list.Add(item);
                    }
                }
            }
            return list;
        }

        public static Templates LoadForPage(int PageID, MySqlConnection ConX)
        {
            var list = new Templates();
            string sql = @"SELECT t.*
                    FROM pagetemplate pt
                    JOIN template t ON pt.TemplateID=t.TemplateID
                    WHERE pt.PageID=" + PageID + @"
                    ORDER BY pt.Seq,t.TemplateID;";
            var cmd = new MySqlCommand(sql, ConX);
            using (var rdr = cmd.ExecuteReader())
            {
                int seq = 10;
                while (rdr.Read())
                {
                    var item = new Template();
                    item.Read(rdr);
                    item.Sequence = seq;
                    seq += 10;
                    list.Add(item);
                }
            }
            return list;
        }
    }
}
