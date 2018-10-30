using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using MySql.Data.MySqlClient;

namespace NXtelData
{
    public class Roles : List<Role>
    {
        public static Roles Load(MySqlConnection ConX = null)
        {
            var list = new Roles();
            bool openConX = ConX == null;
            if (openConX)
            {
                ConX = new MySqlConnection(DBOps.ConnectionString);
                ConX.Open();
            }

            string sql = @"SELECT * FROM AspNetRoles ORDER BY Name;";
            var cmd = new MySqlCommand(sql, ConX);
            using (var rdr = cmd.ExecuteReader())
            {
                while (rdr.Read())
                {
                    var item = new Role();
                    item.ID = rdr.GetStringNullable("Id");
                    item.Name = rdr.GetStringNullable("Name");
                    list.Add(item);
                }
            }

            if (openConX)
                ConX.Close();

            return list;
        }
    }
}
