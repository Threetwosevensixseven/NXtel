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

            LinkPagesAndFiles(ConX);
            PageFileFK(ConX);
            PageFileFKConstraint(ConX);

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

        public static void UpdateRoles(MySqlConnection ConX = null)
        {
            bool openConX = ConX == null;
            try
            {
                if (openConX)
                {
                    ConX = new MySqlConnection(DBOps.ConnectionString);
                    ConX.Open();
                }

                string sql = @"UPDATE AspNetRoles 
                    SET Name='Page Editor' 
                    WHERE Name='PageEditor';";
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

        public static void CreateGetUniqueMailbox(MySqlConnection ConX = null)
        {
            bool openConX = ConX == null;
            try
            {
                if (openConX)
                {
                    ConX = new MySqlConnection(DBOps.ConnectionString);
                    ConX.Open();
                }

                string sql = @"DROP PROCEDURE IF EXISTS sp_GetUniqueMailbox$$
CREATE PROCEDURE sp_GetUniqueMailbox()
BEGIN
    SET @Mailbox='';
    SET @Count=1;
    WHILE(@Count<>0) DO
        SELECT @Mailbox:=CAST(CAST(RAND()*900000000+100000000 AS unsigned) AS char(9));
        SELECT @Count:=COUNT(*) FROM AspNetUsers WHERE Mailbox=@Mailbox;
    END WHILE;
    SELECT @Mailbox AS Mailbox;
END$$";
                var script = new MySqlScript(ConX, sql);
                script.Delimiter = "$$";
                script.Execute();
            }
            catch (Exception /*ex*/)
            {
            }
            finally
            {
                if (openConX)
                    ConX.Close();
            }
        }

        public static void CreateTelesoftwareTable(MySqlConnection ConX = null)
        {
            bool openConX = ConX == null;
            try
            {
                if (openConX)
                {
                    ConX = new MySqlConnection(DBOps.ConnectionString);
                    ConX.Open();
                }

                string sql = @"CREATE TABLE `telesoftware` (
                      `TeleSoftwareID` int(11) NOT NULL AUTO_INCREMENT,
                      `Key` varchar(15) NOT NULL,
                      `Contents` blob,
                      `FileName` varchar(260) DEFAULT NULL,
                      PRIMARY KEY (`TeleSoftwareID`),
                      UNIQUE KEY `idx_telesoftware_Key` (`Key`)
                    ) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;";
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

        public static void DeleteBadTelesoftwareFiles(MySqlConnection ConX = null)
        {
            bool openConX = ConX == null;
            try
            {
                if (openConX)
                {
                    ConX = new MySqlConnection(DBOps.ConnectionString);
                    ConX.Open();
                }

                string sql = @"DELETE FROM telesoftware 
                    WHERE TeleSoftwareID<=0;";
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

        public static void CreateToPageFrameNo(MySqlConnection ConX = null)
        {
            bool openConX = ConX == null;
            try
            {
                if (openConX)
                {
                    ConX = new MySqlConnection(DBOps.ConnectionString);
                    ConX.Open();
                }

                string sql = @"ALTER TABLE `page` 
                    ADD COLUMN `ToPageFrameNo` DECIMAL(11,2) NULL;";
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

        public static void CreateFromPageFrameNo(MySqlConnection ConX = null)
        {
            bool openConX = ConX == null;
            try
            {
                if (openConX)
                {
                    ConX = new MySqlConnection(DBOps.ConnectionString);
                    ConX.Open();
                }

                string sql = @"ALTER TABLE `page` 
                    ADD COLUMN `FromPageFrameNo` DECIMAL(11,2) NULL;";
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

        public static void UpdateToPageFrameNo(MySqlConnection ConX = null)
        {
            bool openConX = ConX == null;
            try
            {
                if (openConX)
                {
                    ConX = new MySqlConnection(DBOps.ConnectionString);
                    ConX.Open();
                }

                string sql = @"update `page` 
                    set ToPageFrameNo=PageNo+(FrameNo/100);";
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

        public static void UpdateFromPageFrameNo(MySqlConnection ConX = null)
        {
            bool openConX = ConX == null;
            try
            {
                if (openConX)
                {
                    ConX = new MySqlConnection(DBOps.ConnectionString);
                    ConX.Open();
                }

                string sql = @"update `page` 
                    set FromPageFrameNo=PageNo+(FrameNo/100);";
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

        public static void LinkPagesAndFiles(MySqlConnection ConX = null)
        {
            bool openConX = ConX == null;
            try
            {
                if (openConX)
                {
                    ConX = new MySqlConnection(DBOps.ConnectionString);
                    ConX.Open();
                }

                string sql = @"ALTER TABLE `page` 
                        ADD COLUMN `TeleSoftwareID` INT NULL;";
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

        public static void PageFileFK(MySqlConnection ConX = null)
        {
            bool openConX = ConX == null;
            try
            {
                if (openConX)
                {
                    ConX = new MySqlConnection(DBOps.ConnectionString);
                    ConX.Open();
                }

                string sql = @"ALTER TABLE `page` 
                    ADD INDEX `FK_page_TeleSoftwareID_idx` (`TeleSoftwareID` ASC);";
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

        public static void PageFileFKConstraint(MySqlConnection ConX = null)
        {
            bool openConX = ConX == null;
            try
            {
                if (openConX)
                {
                    ConX = new MySqlConnection(DBOps.ConnectionString);
                    ConX.Open();
                }

                string sql = @"ALTER TABLE `page` 
                        ADD CONSTRAINT `FK_page_TeleSoftwareID` FOREIGN KEY (`TeleSoftwareID`) 
                        REFERENCES `nxtel`.`telesoftware` (`TeleSoftwareID`)
                        ON DELETE CASCADE
                        ON UPDATE CASCADE;";
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

    }
}
