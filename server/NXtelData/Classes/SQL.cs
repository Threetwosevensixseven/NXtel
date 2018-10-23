using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using MySql.Data.MySqlClient;

namespace NXtelData
{
    public static class SQL
    {
        public static void UpdateStructure(MySqlConnection ConX = null)
        {
            if (!Options.UpdateSQL)
                return;

            bool openConX = ConX == null;
            if (openConX)
            {
                ConX = new MySqlConnection(DBOps.ConnectionString);
                ConX.Open();
            }

            CreateUserMailbox(ConX);
            UpdateAllUserMailboxes(ConX);

            if (openConX)
                ConX.Close();
        }


        public static void CreateUserMailbox(MySqlConnection ConX = null)
        {
            bool openConX = ConX == null;
            try
            {
                if (openConX)
                {
                    ConX = new MySqlConnection(DBOps.ConnectionString);
                    ConX.Open();
                }

                string sql = @"ALTER TABLE AspNetUsers 
                ADD COLUMN Mailbox VARCHAR(9) NULL AFTER UserName;";
                using (var cmd = new MySqlCommand(sql, ConX))
                {
                    cmd.ExecuteNonQuery();
                }
            }
            catch { }
            finally
            {
                if (openConX)
                    ConX.Close();
            }
        }

        public static void UpdateAllUserMailboxes(MySqlConnection ConX = null)
        {
            bool openConX = ConX == null;
            if (openConX)
            {
                ConX = new MySqlConnection(DBOps.ConnectionString);
                ConX.Open();
            }

            var rng = new Random();
            var ids = new List<string>();
            string sql = @"select Id from AspNetUsers
                WHERE Mailbox IS NULL OR length(Mailbox)<9;";
            var cmd = new MySqlCommand(sql, ConX);
            using (var rdr = cmd.ExecuteReader())
            {
                while (rdr.Read())
                {
                    ids.Add(rdr.GetString("Id"));
                }
            }

            foreach (string id in ids)
            {
                string mbox = rng.Next(1000, 9999).ToString().PadLeft(4, '0')
                    + rng.Next(0, 99999).ToString().PadLeft(5, '0');
                sql = @"UPDATE AspNetUsers SET Mailbox=@Mailbox WHERE Id=@Id;";
                var cmd2 = new MySqlCommand(sql, ConX);
                cmd2.Parameters.AddWithValue("Mailbox", mbox);
                cmd2.Parameters.AddWithValue("Id", id);
                cmd2.ExecuteNonQuery();
            }

            if (openConX)
                ConX.Close();
        }

    }
}
