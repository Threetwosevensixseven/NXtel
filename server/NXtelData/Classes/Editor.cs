using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using MySql.Data.MySqlClient;

namespace NXtelData
{
    public class Editor
    {
        public int EditorID { get; set; }

        public string URLPrefix { get; set; }

        public bool IsDefault { get; set; }

        public string Description { get; set; }

        public Editor()
        {
            EditorID = -1;
            URLPrefix = Description = "";
        }

        public static Editor Load()
        {
            var item = new Editor();
            using (var con = new MySqlConnection(DBOps.ConnectionString))
            {
                con.Open();
                string sql = "SELECT * FROM editor ORDER BY IsDefault DESC,Description";
                var cmd = new MySqlCommand(sql, con);
                using (var rdr = cmd.ExecuteReader())
                {
                    while (rdr.Read())
                    {
                        item.Read(rdr);
                    }
                }
            }
            return item;
        }

        public static Editor LoadDefault()
        {
            var item = new Editor();
            using (var con = new MySqlConnection(DBOps.ConnectionString))
            {
                con.Open();
                string sql = "SELECT * FROM editor ORDER BY IsDefault DESC,Description LIMIT 1;";
                var cmd = new MySqlCommand(sql, con);
                using (var rdr = cmd.ExecuteReader())
                {
                    while (rdr.Read())
                    {
                        item.Read(rdr);
                        break;
                    }
                }
            }
            return item;
        }

        public void Read(MySqlDataReader rdr)
        {
            this.EditorID = rdr.GetInt32("EditorID");
            this.URLPrefix = rdr.GetStringNullable("URLPrefix");
            this.IsDefault = rdr.GetBoolean("IsDefault");
            this.Description = rdr.GetStringNullable("Description").Trim();
        }
    }
}
