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

            CreateUserNoField(ConX);
            CreateUserPageRangeTable(ConX);

            if (openConX)
                ConX.Close();
        }

        public static void SetupData(MySqlConnection ConX = null)
        {
            bool openConX = ConX == null;
            if (openConX)
            {
                ConX = new MySqlConnection(DBOps.ConnectionString);
                ConX.Open();
            }

            PopulateDummyTable(ConX);
            FixRoutes1(ConX);
            FixRoutes2(ConX);

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

        public static void CreateTSFileType(MySqlConnection ConX = null)
        {
            bool openConX = ConX == null;
            try
            {
                if (openConX)
                {
                    ConX = new MySqlConnection(DBOps.ConnectionString);
                    ConX.Open();
                }

                string sql = @"ALTER TABLE `telesoftware` 
                    ADD COLUMN `FileType` BIT NULL AFTER `FileName`,
                    ADD COLUMN `EOL` TINYINT(1) NULL AFTER `FileType`;";
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

        public static void MakeRouteKeycodeUnsigned(MySqlConnection ConX = null)
        {
            bool openConX = ConX == null;
            try
            {
                if (openConX)
                {
                    ConX = new MySqlConnection(DBOps.ConnectionString);
                    ConX.Open();
                }

                string sql = @"ALTER TABLE `route` 
                    CHANGE COLUMN `KeyCode` `KeyCode` TINYINT(3) UNSIGNED NOT NULL;";
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

        public static void CreateDummyTable(MySqlConnection ConX = null)
        {
            bool openConX = ConX == null;
            try
            {
                if (openConX)
                {
                    ConX = new MySqlConnection(DBOps.ConnectionString);
                    ConX.Open();
                }

                string sql = @"CREATE TABLE `dummy` (
                    `DummyID` INT NOT NULL,
                    PRIMARY KEY (`DummyID`));";
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

        public static void PopulateDummyTable(MySqlConnection ConX = null)
        {
            // Don't delete this, it gets run on NXtelManager startup
            bool openConX = ConX == null;
            try
            {
                if (openConX)
                {
                    ConX = new MySqlConnection(DBOps.ConnectionString);
                    ConX.Open();
                }

                string sql = @"INSERT INTO dummy (DummyID) VALUES (1);";
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

        public static void FixRoutes1(MySqlConnection ConX = null)
        {
            // Don't delete this, it gets run on NXtelManager startup
            bool openConX = ConX == null;
            try
            {
                if (openConX)
                {
                    ConX = new MySqlConnection(DBOps.ConnectionString);
                    ConX.Open();
                }

                string sql = @"UPDATE Route
                    SET NextFrameNo=0
                    WHERE NextFrameNo IS NULL
                    AND (GoNextPage IS NULL OR GoNextPage=0)
                    AND (GoNextFrame IS NULL OR GoNextFrame=0);";
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

        public static void FixRoutes2(MySqlConnection ConX = null)
        {
            // Don't delete this, it gets run on NXtelManager startup
            bool openConX = ConX == null;
            try
            {
                if (openConX)
                {
                    ConX = new MySqlConnection(DBOps.ConnectionString);
                    ConX.Open();
                }

                string sql = @"UPDATE Route
                    SET NextPageNo=NULL,NextFrameNo=NULL
                    WHERE (NextPageNo IS NOT NULL
                    OR NextFrameNo IS NOT NULL)
                    AND (GoNextPage=1 OR GoNextFrame=1);";
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

        public static void CreateZoneTable(MySqlConnection ConX = null)
        {
            bool openConX = ConX == null;
            try
            {
                if (openConX)
                {
                    ConX = new MySqlConnection(DBOps.ConnectionString);
                    ConX.Open();
                }

                string sql = @"CREATE TABLE `zone` (
                      `ZoneID` int(11) NOT NULL AUTO_INCREMENT,
                      `Description` varchar(40) NOT NULL,
                      PRIMARY KEY (`ZoneID`)
                    ) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;";
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

        public static void CreatePageZoneTable(MySqlConnection ConX = null)
        {
            bool openConX = ConX == null;
            try
            {
                if (openConX)
                {
                    ConX = new MySqlConnection(DBOps.ConnectionString);
                    ConX.Open();
                }

                string sql = @"CREATE TABLE `pagezone` (
                      `PageZoneID` int(11) NOT NULL AUTO_INCREMENT,
                      `PageID` int(11) NOT NULL,
                      `ZoneID` int(11) NOT NULL,
                      PRIMARY KEY (`PageZoneID`),
                      UNIQUE KEY `uq_pagezone_page_zone` (`PageID`,`ZoneID`),
                      KEY `fk_pagezone_page_idx` (`PageID`),
                      KEY `fk_pagezone_zone_idx` (`ZoneID`),
                      CONSTRAINT `fk_pagezone_page` FOREIGN KEY (`PageID`) REFERENCES `page` (`PageID`) ON DELETE CASCADE ON UPDATE CASCADE,
                      CONSTRAINT `fk_pagezone_zone` FOREIGN KEY (`ZoneID`) REFERENCES `zone` (`ZoneID`) ON DELETE CASCADE ON UPDATE CASCADE
                    ) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;";
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

        public static void CreateUserPrefTable(MySqlConnection ConX = null)
        {
            bool openConX = ConX == null;
            try
            {
                if (openConX)
                {
                    ConX = new MySqlConnection(DBOps.ConnectionString);
                    ConX.Open();
                }

                string sql = @"CREATE TABLE `userpref` (
                      `UserPrefID` int(11) NOT NULL AUTO_INCREMENT,
                      `UserID` varchar(128) NOT NULL,
                      `Key` varchar(40) NOT NULL,
                      `Value` varchar(20) DEFAULT NULL,
                      PRIMARY KEY (`UserPrefID`),
                      UNIQUE KEY `UQ_userpref_UserID_Key` (`UserID`,`Key`),
                      KEY `IX_userpref_Key` (`Key`)
                    ) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;";
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

        public static void CreateUserNoField(MySqlConnection ConX = null)
        {
            bool openConX = ConX == null;
            try
            {
                if (openConX)
                {
                    ConX = new MySqlConnection(DBOps.ConnectionString);
                    ConX.Open();
                }

                string sql = @"ALTER TABLE `aspnetusers` 
                    ADD COLUMN `UserNo` INT NOT NULL AUTO_INCREMENT AFTER `Mailbox`,
                    ADD UNIQUE INDEX `UserNo_UNIQUE` (`UserNo` ASC);";
                using (var cmd = new MySqlCommand(sql, ConX))
                {
                    cmd.ExecuteNonQuery();
                }
            }
            catch (Exception ex)
            {
                Logger.Log(ex.Message);
                Logger.Log(ex.StackTrace);
            }
            finally
            {
                if (openConX)
                    ConX.Close();
            }
        }

        public static void CreateUserPageRangeTable(MySqlConnection ConX = null)
        {
            bool openConX = ConX == null;
            try
            {
                if (openConX)
                {
                    ConX = new MySqlConnection(DBOps.ConnectionString);
                    ConX.Open();
                }

                string sql = @"CREATE TABLE `userpagerange` (
                      `UserPageRangeID` INT NOT NULL AUTO_INCREMENT,
                      `UserID` VARCHAR(128) CHARACTER SET 'utf8' NOT NULL,
                      `FromPageNo` INT NOT NULL,
                      `ToPageNo` INT NOT NULL,
                      PRIMARY KEY (`UserPageRangeID`),
                      INDEX `IX_userpagerange_user` (`UserID` ASC),
                      UNIQUE INDEX `UQ_userpagerange` (`FromPageNo` ASC, `ToPageNo` ASC, `UserID` ASC))
                    ENGINE = InnoDB
                    DEFAULT CHARACTER SET = utf8;";
                using (var cmd = new MySqlCommand(sql, ConX))
                {
                    cmd.ExecuteNonQuery();
                }
            }
            catch (Exception ex)
            {
                Logger.Log(ex.Message);
                Logger.Log(ex.StackTrace);
            }
            finally
            {
                if (openConX)
                    ConX.Close();
            }
        }
    }
}
