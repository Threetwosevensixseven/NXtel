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
    }
}
