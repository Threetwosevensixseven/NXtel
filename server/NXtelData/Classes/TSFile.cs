using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using MySql.Data.MySqlClient;

namespace NXtelData
{
    public class TSFile
    {
        public int TeleSoftwareID { get; set; }
        [Required(ErrorMessage = "Key is required.")]
        public string Key { get; set; }
        [Display(Name = "File Name")]
        public string FileName { get; set; }
        public byte[] Contents { get; set; }
        [Display(Name = "Owner")]
        public int OwnerID { get; set; }
        public string Environment { get; set; }
        public int CopyingFromID { get; set; }

        public TSFile()
        {
            TeleSoftwareID = OwnerID = CopyingFromID = - 1;
            Key = FileName = "";
            Contents = new byte[0];
        }

        [Display(Name = "File Size")]
        public string FileSize
        {
            get
            {
                int size = (Contents ?? new byte[0]).Length;
                return size + (size == 1 ? " Byte" : " Bytes");
            }
        }

        public int FileSizeBytes
        {
            get
            {
                return (Contents ?? new byte[0]).Length;
            }
        }

        public static TSFile Load(int TelesoftwareID)
        {
            var item = new TSFile();
            using (var con = new MySqlConnection(DBOps.ConnectionString))
            {
                con.Open();
                string sql = "SELECT * FROM telesoftware WHERE TelesoftwareID=" + TelesoftwareID;
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

        public static bool Save(TSFile File, out string Err, bool ResetOwnerIfNotFound = true)
        {
            Err = "";
            try
            {
                using (var ConX = new MySqlConnection(DBOps.GetConnectionString(File.Environment)))
                {
                    ConX.Open();
                    if (!string.IsNullOrWhiteSpace(File.Environment))
                        File.GetIDFromDescription(ConX, true, ResetOwnerIfNotFound);
                    if (File.TeleSoftwareID <= 0)
                        return File.Create(out Err, ConX);
                    else
                        return File.Update(out Err, ConX);
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
                string sql = @"INSERT INTO telesoftware
                        (`Key`,Contents,FileName,OwnerID)
                        VALUES(@Key,@Contents,@FileName,@OwnerID);
                        SELECT LAST_INSERT_ID();";
                var cmd = new MySqlCommand(sql, ConX);
                cmd.Parameters.AddWithValue("Key", Key);
                cmd.Parameters.AddWithValue("Contents", Contents);
                cmd.Parameters.AddWithValue("FileName", FileName);
                int? ownerID = OwnerID <= 0 ? null : (int?)OwnerID;
                cmd.Parameters.AddWithValue("OwnerID", ownerID);
                int rv = cmd.ExecuteScalarInt32();
                if (rv > 0)
                    TeleSoftwareID = rv;
                if (TeleSoftwareID <= 0)
                    Err = "The file could not be saved.";
                return TeleSoftwareID > 0;
            }
            catch (Exception ex)
            {
                if (ex.Message.ToLower().Contains("duplicate entry"))
                    Err = "File '" + (Key ?? "") + "' already exists.";
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
                string sql = @"UPDATE telesoftware
                        SET `Key`=@Key,
                        Contents=@Contents,
                        FileName=@FileName,
                        OwnerID=@OwnerID
                        WHERE TeleSoftwareID=@TeleSoftwareID;
                        SELECT ROW_COUNT();";
                var cmd = new MySqlCommand(sql, ConX);
                cmd.Parameters.AddWithValue("TeleSoftwareID", TeleSoftwareID);
                cmd.Parameters.AddWithValue("Key", Key);
                cmd.Parameters.AddWithValue("Contents", Contents);
                cmd.Parameters.AddWithValue("FileName", FileName);
                int? ownerID = OwnerID <= 0 ? null : (int?)OwnerID;
                cmd.Parameters.AddWithValue("OwnerID", ownerID);
                int rv = cmd.ExecuteScalarInt32();
                if (rv <= 0)
                    Err = "The file could not be saved.";
                return rv > 0;
            }
            catch (Exception ex)
            {
                if (ex.Message.ToLower().Contains("duplicate entry"))
                    Err = "File '" + (Key ?? "") + "' already exists.";
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

        public bool Delete(out string Err)
        {
            Err = "";
            try
            {
                using (var con = new MySqlConnection(DBOps.ConnectionString))
                {
                    con.Open();
                    string sql = @"DELETE FROM telesoftware WHERE TeleSoftwareID=@TeleSoftwareID;";
                    var cmd = new MySqlCommand(sql, con);
                    cmd.Parameters.AddWithValue("TeleSoftwareID", TeleSoftwareID);
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

        public void Read(MySqlDataReader rdr, bool StubOnly = false)
        {
            this.TeleSoftwareID = rdr.GetInt32("TeleSoftwareID");
            this.Key = rdr.GetStringNullable("Key");
            this.FileName = rdr.GetStringNullable("FileName");
            this.OwnerID = rdr.GetInt32Safe("OwnerID");
            if (StubOnly) return;
            this.Contents = rdr.GetBytesNullable("Contents");
        }

        public int GetIDFromDescription(MySqlConnection ConX = null, bool ResetIfNotFound = true, bool ResetOwnerIfNotFound = true)
        {
            int rv = -1;
            bool found = false;
            bool openConX = ConX == null;
            if (openConX)
            {
                ConX = new MySqlConnection(DBOps.ConnectionString);
                ConX.Open();
            }
            string sql = @"SELECT TeleSoftwareID FROM telesoftware
                WHERE telesoftware.`Key`=@Key
                ORDER BY TeleSoftwareID LIMIT 1;";
            using (var cmd = new MySqlCommand(sql, ConX))
            {
                cmd.Parameters.AddWithValue("Key", (Key ?? "").Trim());
                using (var rdr = cmd.ExecuteReader())
                {
                    while (rdr.Read())
                    {
                        rv = rdr.GetInt32("TeleSoftwareID");
                        TeleSoftwareID = rv;
                        found = true;
                        break;
                    }
                }
            }
            if (ResetIfNotFound && !found)
                TeleSoftwareID = -1;
            if (ResetOwnerIfNotFound && !found)
                OwnerID = -1;

            if (openConX)
                ConX.Close();

            return rv;
        }
    }
}
