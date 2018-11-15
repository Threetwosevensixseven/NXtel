using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using MySql.Data.MySqlClient;

namespace NXtelData
{
    public class TSFiles : List<TSFile>
    {
        public static TSFiles LoadStubs()
        {
            var list = new TSFiles();
            using (var con = new MySqlConnection(DBOps.ConnectionString))
            {
                con.Open();
                string sql = @"SELECT TeleSoftwareID,`Key`,FileName FROM telesoftware ORDER BY `Key`;";
                var cmd = new MySqlCommand(sql, con);
                using (var rdr = cmd.ExecuteReader())
                {
                    while (rdr.Read())
                    {
                        var item = new TSFile();
                        item.Read(rdr, true);
                        list.Add(item);
                    }
                }
            }
            return list;
        }
    }
}
