using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using MySql.Data.MySqlClient;

namespace NXtelData
{
    public class Zone
    {
        public int ID { get; set; }
        [Required(ErrorMessage = "Description is required.")]
        public string Description { get; set; }
        public string Environment { get; set; }

        public Zone()
        {
            ID = -1;
            Description = "";
        }

        public bool SaveForPage(int PageID, MySqlConnection ConX = null)
        {
            bool openConX = ConX == null;
            if (openConX)
            {
                ConX = new MySqlConnection(DBOps.ConnectionString);
                ConX.Open();
            }

            string sql = @"INSERT INTO pagezone (PageID,ZoneID) VALUES(@PageID,@ZoneID);";
            var cmd = new MySqlCommand(sql, ConX);
            cmd.Parameters.AddWithValue("PageID", PageID);
            cmd.Parameters.AddWithValue("ZoneID", ID);
            cmd.ExecuteNonQuery();

            if (openConX)
                ConX.Close();

            return true;
        }

        public static Zone Load(int ZoneID, MySqlConnection ConX = null)
        {
            var item = new Zone();
            bool openConX = ConX == null;
            if (openConX)
            {
                ConX = new MySqlConnection(DBOps.ConnectionString);
                ConX.Open();
            }

            string sql = "SELECT * FROM zone WHERE ZoneID=" + ZoneID;
            var cmd = new MySqlCommand(sql, ConX);
            using (var rdr = cmd.ExecuteReader())
            {
                while (rdr.Read())
                {
                    item.Read(rdr);
                    break;
                }
            }

            if (openConX)
                ConX.Close();

            return item;
        }

        public void Read(MySqlDataReader rdr, bool StubOnly = false)
        {
            this.ID = rdr.GetInt32("ZoneID");
            this.Description = rdr.GetString("Description").Trim();
        }

        public bool Delete(out string Err)
        {
            Err = "";
            try
            {
                using (var con = new MySqlConnection(DBOps.ConnectionString))
                {
                    con.Open();
                    string sql = @"DELETE FROM zone WHERE ZoneID=@ZoneID;";
                    var cmd = new MySqlCommand(sql, con);
                    cmd.Parameters.AddWithValue("ZoneID", ID);
                    cmd.ExecuteNonQuery();
                    return true;
                }
            }
            catch (Exception ex)
            {
                Err = ex.Message;
                return false;
            }
        }

        public bool Save(out string Err)
        {
            Err = "";
            try
            {
                using (var ConX = new MySqlConnection(DBOps.GetConnectionString(Environment)))
                {
                    ConX.Open();
                    if (!string.IsNullOrWhiteSpace(Environment))
                        GetIDFromDescription(ConX);
                    if (ID <= 0)
                        return Create(out Err, ConX);
                    else
                        return Update(out Err, ConX);
                }
            }
            catch (Exception ex)
            {
                Err = ex.Message;
                return false;
            }
        }

        public bool Create(out string Err, MySqlConnection ConX = null)
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
                string sql = @"INSERT INTO zone
                        (Description)
                        VALUES(@Description);
                        SELECT LAST_INSERT_ID();";
                var cmd = new MySqlCommand(sql, ConX);
                cmd.Parameters.AddWithValue("Description", (Description ?? "").Trim());
                int rv = cmd.ExecuteScalarInt32();
                if (rv > 0)
                    ID = rv;
                if (ID <= 0)
                    Err = "The zone could not be saved.";
                return ID > 0;
            }
            catch (Exception ex)
            {
                if (ex.Message.ToLower().Contains("duplicate entry"))
                    Err = "Zone " + ID + " already exists.";
                else
                    Err = ex.Message;
                return false;
            }
            finally
            {
                if (openConX)
                    ConX.Close();
            }
        }

        public bool Update(out string Err, MySqlConnection ConX = null)
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
                string sql = @"UPDATE zone
                        SET Description=@Description
                        WHERE ZoneID=@ZoneID;
                        SELECT ROW_COUNT();";
                var cmd = new MySqlCommand(sql, ConX);
                cmd.Parameters.AddWithValue("Description", (Description ?? "").Trim());
                cmd.Parameters.AddWithValue("ZoneID", ID);
                int rv = cmd.ExecuteScalarInt32();
                if (rv <= 0)
                    Err = "The zone could not be saved.";
                return rv > 0;
            }
            catch (Exception ex)
            {
                if (ex.Message.ToLower().Contains("duplicate entry"))
                    Err = "Zone " + ID + " already exists.";
                else
                    Err = ex.Message;
                return false;
            }
            finally
            {
                if (openConX)
                    ConX.Close();
            }
        }

        public int GetIDFromDescription(MySqlConnection ConX = null, bool ResetIfNotFound = true)
        {
            int rv = -1;
            bool found = false;
            bool openConX = ConX == null;
            if (openConX)
            {
                ConX = new MySqlConnection(DBOps.ConnectionString);
                ConX.Open();
            }
            string sql = @"SELECT ZoneID FROM zone
                WHERE Description=@Description
                ORDER BY ZoneID LIMIT 1;";
            using (var cmd = new MySqlCommand(sql, ConX))
            {
                cmd.Parameters.AddWithValue("Description", (Description ?? "").Trim());
                using (var rdr = cmd.ExecuteReader())
                {
                    while (rdr.Read())
                    {
                        rv = rdr.GetInt32("ZoneID");
                        ID = rv;
                        found = true;
                        break;
                    }
                }
            }

            if (ResetIfNotFound && !found)
                ID = -1;

            if (openConX)
                ConX.Close();

            return rv;
        }
    }
}
