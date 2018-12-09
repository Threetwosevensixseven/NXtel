-- MySQL dump 10.13  Distrib 5.7.17, for Win64 (x86_64)
--
-- Host: localhost    Database: nxtel
-- ------------------------------------------------------
-- Server version	5.7.19-log

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `aspnetroles`
--

DROP TABLE IF EXISTS `aspnetroles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `aspnetroles` (
  `Id` varchar(128) CHARACTER SET utf8 NOT NULL,
  `Name` varchar(128) CHARACTER SET utf8 NOT NULL,
  PRIMARY KEY (`Id`),
  UNIQUE KEY `RoleNameIndex` (`Name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `aspnetuserclaims`
--

DROP TABLE IF EXISTS `aspnetuserclaims`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `aspnetuserclaims` (
  `Id` int(11) NOT NULL AUTO_INCREMENT,
  `UserId` varchar(128) CHARACTER SET utf8 NOT NULL,
  `ClaimType` varchar(128) CHARACTER SET utf8 DEFAULT NULL,
  `ClaimValue` varchar(128) CHARACTER SET utf8 DEFAULT NULL,
  PRIMARY KEY (`Id`),
  KEY `IX_UserId` (`UserId`) USING BTREE,
  CONSTRAINT `FK_AspNetUserClaims_AspNetUsers_UserId` FOREIGN KEY (`UserId`) REFERENCES `aspnetusers` (`Id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `aspnetuserlogins`
--

DROP TABLE IF EXISTS `aspnetuserlogins`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `aspnetuserlogins` (
  `LoginProvider` varchar(128) CHARACTER SET utf8 NOT NULL,
  `ProviderKey` varchar(128) CHARACTER SET utf8 NOT NULL,
  `UserId` varchar(128) CHARACTER SET utf8 NOT NULL,
  PRIMARY KEY (`LoginProvider`,`ProviderKey`,`UserId`),
  KEY `IX_UserId` (`UserId`) USING BTREE,
  CONSTRAINT `FK_AspNetUserLogins_AspNetUsers_UserId` FOREIGN KEY (`UserId`) REFERENCES `aspnetusers` (`Id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `aspnetuserroles`
--

DROP TABLE IF EXISTS `aspnetuserroles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `aspnetuserroles` (
  `UserId` varchar(128) CHARACTER SET utf8 NOT NULL,
  `RoleId` varchar(128) CHARACTER SET utf8 NOT NULL,
  PRIMARY KEY (`UserId`,`RoleId`),
  KEY `IX_RoleId` (`RoleId`) USING BTREE,
  KEY `IX_UserId` (`UserId`) USING BTREE,
  CONSTRAINT `FK_AspNetUserRoles_AspNetRoles_RoleId` FOREIGN KEY (`RoleId`) REFERENCES `aspnetroles` (`Id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_AspNetUserRoles_AspNetUsers_UserId` FOREIGN KEY (`UserId`) REFERENCES `aspnetusers` (`Id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `aspnetusers`
--

DROP TABLE IF EXISTS `aspnetusers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `aspnetusers` (
  `Id` varchar(128) CHARACTER SET utf8 NOT NULL,
  `Email` varchar(200) CHARACTER SET utf8 DEFAULT NULL,
  `EmailConfirmed` tinyint(1) NOT NULL,
  `PasswordHash` varchar(200) CHARACTER SET utf8 DEFAULT NULL,
  `SecurityStamp` varchar(200) CHARACTER SET utf8 DEFAULT NULL,
  `PhoneNumber` varchar(200) CHARACTER SET utf8 DEFAULT NULL,
  `PhoneNumberConfirmed` tinyint(1) NOT NULL,
  `TwoFactorEnabled` tinyint(1) NOT NULL,
  `LockoutEndDateUtc` datetime DEFAULT NULL,
  `LockoutEnabled` tinyint(1) NOT NULL,
  `AccessFailedCount` int(11) NOT NULL,
  `UserName` varchar(200) CHARACTER SET utf8 NOT NULL,
  `Mailbox` varchar(9) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `UserNo` int(11) NOT NULL AUTO_INCREMENT,
  `FirstName` varchar(30) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `LastName` varchar(40) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`Id`),
  UNIQUE KEY `UserNameIndex` (`UserName`),
  UNIQUE KEY `UserNo_UNIQUE` (`UserNo`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `charsub`
--

DROP TABLE IF EXISTS `charsub`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `charsub` (
  `UnhandledChar` char(1) NOT NULL,
  PRIMARY KEY (`UnhandledChar`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `dummy`
--

DROP TABLE IF EXISTS `dummy`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `dummy` (
  `DummyID` int(11) NOT NULL,
  PRIMARY KEY (`DummyID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `feed`
--

DROP TABLE IF EXISTS `feed`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `feed` (
  `FeedURL` varchar(255) NOT NULL,
  `XML` longtext,
  `LastUpdated` datetime DEFAULT NULL,
  PRIMARY KEY (`FeedURL`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `page`
--

DROP TABLE IF EXISTS `page`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `page` (
  `PageID` int(11) NOT NULL AUTO_INCREMENT,
  `PageNo` int(11) NOT NULL,
  `FrameNo` int(11) NOT NULL,
  `Title` varchar(30) DEFAULT NULL,
  `Contents` varbinary(1000) DEFAULT NULL,
  `BoxMode` tinyint(1) NOT NULL DEFAULT '0',
  `URL` varchar(2048) DEFAULT NULL,
  `ToPageFrameNo` decimal(11,2) DEFAULT NULL,
  `FromPageFrameNo` decimal(11,2) DEFAULT NULL,
  `TeleSoftwareID` int(11) DEFAULT NULL,
  `OwnerID` int(11) DEFAULT NULL,
  PRIMARY KEY (`PageID`),
  UNIQUE KEY `idx_page_PageNo_Seq` (`PageNo`,`FrameNo`),
  KEY `FK_page_TeleSoftwareID_idx` (`TeleSoftwareID`),
  KEY `idx_page_OwnerID` (`OwnerID`),
  CONSTRAINT `FK_page_OwnerID` FOREIGN KEY (`OwnerID`) REFERENCES `aspnetusers` (`UserNo`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pagetemplate`
--

DROP TABLE IF EXISTS `pagetemplate`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pagetemplate` (
  `PageID` int(11) NOT NULL,
  `TemplateID` int(11) NOT NULL,
  `Seq` int(11) NOT NULL DEFAULT '10',
  PRIMARY KEY (`PageID`,`TemplateID`),
  UNIQUE KEY `UQPageTemplate_PageID_TemplateID` (`PageID`,`TemplateID`),
  KEY `FKPageTemplate_Page_idx` (`PageID`) USING BTREE,
  KEY `FKPageTemplate_Template_idx` (`TemplateID`) USING BTREE,
  CONSTRAINT `FKPageTemplate_Page` FOREIGN KEY (`PageID`) REFERENCES `page` (`PageID`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FKPageTemplate_Template` FOREIGN KEY (`TemplateID`) REFERENCES `template` (`TemplateID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `pagezone`
--

DROP TABLE IF EXISTS `pagezone`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `pagezone` (
  `PageZoneID` int(11) NOT NULL AUTO_INCREMENT,
  `PageID` int(11) NOT NULL,
  `ZoneID` int(11) NOT NULL,
  PRIMARY KEY (`PageZoneID`),
  UNIQUE KEY `uq_pagezone_page_zone` (`PageID`,`ZoneID`),
  KEY `fk_pagezone_page_idx` (`PageID`),
  KEY `fk_pagezone_zone_idx` (`ZoneID`),
  CONSTRAINT `fk_pagezone_page` FOREIGN KEY (`PageID`) REFERENCES `page` (`PageID`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_pagezone_zone` FOREIGN KEY (`ZoneID`) REFERENCES `zone` (`ZoneID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `route`
--

DROP TABLE IF EXISTS `route`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `route` (
  `PageID` int(11) NOT NULL,
  `KeyCode` tinyint(3) unsigned NOT NULL,
  `NextPageNo` int(11) DEFAULT NULL,
  `NextFrameNo` int(11) DEFAULT NULL,
  `GoNextPage` tinyint(1) NOT NULL DEFAULT '0',
  `GoNextFrame` tinyint(1) NOT NULL DEFAULT '0',
  PRIMARY KEY (`PageID`,`KeyCode`),
  UNIQUE KEY `UQPageKey_PageID_KeyChar` (`PageID`,`KeyCode`),
  KEY `FKPageKey_Page_idx` (`PageID`) USING BTREE,
  CONSTRAINT `FKPageKey_Page` FOREIGN KEY (`PageID`) REFERENCES `page` (`PageID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `telesoftware`
--

DROP TABLE IF EXISTS `telesoftware`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `telesoftware` (
  `TeleSoftwareID` int(11) NOT NULL AUTO_INCREMENT,
  `Key` varchar(15) NOT NULL,
  `Contents` blob,
  `FileName` varchar(260) DEFAULT NULL,
  `FileType` bit(1) DEFAULT NULL,
  `EOL` tinyint(1) DEFAULT NULL,
  `OwnerID` int(11) DEFAULT NULL,
  PRIMARY KEY (`TeleSoftwareID`),
  UNIQUE KEY `idx_telesoftware_Key` (`Key`),
  KEY `idx_telesoftware_OwnerID` (`OwnerID`),
  CONSTRAINT `FK_telesoftware_OwnerID` FOREIGN KEY (`OwnerID`) REFERENCES `aspnetusers` (`UserNo`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `template`
--

DROP TABLE IF EXISTS `template`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `template` (
  `TemplateID` int(11) NOT NULL AUTO_INCREMENT,
  `Description` varchar(30) DEFAULT NULL,
  `X` tinyint(3) NOT NULL,
  `Y` tinyint(3) NOT NULL,
  `Width` tinyint(3) DEFAULT NULL,
  `Height` tinyint(3) DEFAULT NULL,
  `Contents` varbinary(1000) DEFAULT NULL,
  `URL` varchar(2048) DEFAULT NULL,
  `Expression` varchar(300) DEFAULT NULL,
  `IsContainer` tinyint(1) NOT NULL DEFAULT '0',
  `IsRepeatingItem` tinyint(1) NOT NULL DEFAULT '0',
  `CanExpand` tinyint(1) NOT NULL DEFAULT '0',
  `StickToTop` tinyint(1) NOT NULL DEFAULT '0',
  `StickToBottom` tinyint(1) NOT NULL DEFAULT '0',
  `ContinuedOver` tinyint(1) NOT NULL DEFAULT '0',
  `ContinuedFrom` tinyint(1) NOT NULL DEFAULT '0',
  `NotContinuedOver` tinyint(1) NOT NULL DEFAULT '0',
  `NotContinuedFrom` tinyint(1) NOT NULL DEFAULT '0',
  `KeepTogether` tinyint(1) NOT NULL DEFAULT '0',
  `MinOrphanWidowRows` tinyint(2) DEFAULT NULL,
  `OwnerID` int(11) DEFAULT NULL,
  PRIMARY KEY (`TemplateID`),
  KEY `idx_template_OwnerID` (`OwnerID`),
  CONSTRAINT `FK_template_OwnerID` FOREIGN KEY (`OwnerID`) REFERENCES `aspnetusers` (`UserNo`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `templatetree`
--

DROP TABLE IF EXISTS `templatetree`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `templatetree` (
  `ParentTemplateID` int(11) NOT NULL,
  `ChildTemplateID` int(11) NOT NULL,
  `Seq` int(11) NOT NULL DEFAULT '10',
  PRIMARY KEY (`ParentTemplateID`,`ChildTemplateID`),
  KEY `FK_templatetree_childtemplate_idx` (`ChildTemplateID`) USING BTREE,
  CONSTRAINT `FK_templatetree_childtemplate` FOREIGN KEY (`ChildTemplateID`) REFERENCES `template` (`TemplateID`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_templatetree_parenttemplate` FOREIGN KEY (`ParentTemplateID`) REFERENCES `template` (`TemplateID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `userpagerange`
--

DROP TABLE IF EXISTS `userpagerange`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userpagerange` (
  `UserPageRangeID` int(11) NOT NULL AUTO_INCREMENT,
  `UserID` varchar(128) NOT NULL,
  `FromPageNo` int(11) NOT NULL,
  `ToPageNo` int(11) NOT NULL,
  PRIMARY KEY (`UserPageRangeID`),
  UNIQUE KEY `UQ_userpagerange` (`FromPageNo`,`ToPageNo`,`UserID`),
  KEY `IX_userpagerange_user` (`UserID`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `userpref`
--

DROP TABLE IF EXISTS `userpref`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `userpref` (
  `UserPrefID` int(11) NOT NULL AUTO_INCREMENT,
  `UserID` varchar(128) NOT NULL,
  `Key` varchar(40) NOT NULL,
  `Value` varchar(20) DEFAULT NULL,
  PRIMARY KEY (`UserPrefID`),
  UNIQUE KEY `UQ_userpref_UserID_Key` (`UserID`,`Key`),
  KEY `IX_userpref_Key` (`Key`),
  KEY `IX_userpref_UserID` (`UserID`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `zone`
--

DROP TABLE IF EXISTS `zone`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `zone` (
  `ZoneID` int(11) NOT NULL AUTO_INCREMENT,
  `Description` varchar(40) NOT NULL,
  PRIMARY KEY (`ZoneID`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping events for database 'nxtel'
--

--
-- Dumping routines for database 'nxtel'
--
/*!50003 DROP PROCEDURE IF EXISTS `sp_GetUniqueMailbox` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8 */ ;
/*!50003 SET character_set_results = utf8 */ ;
/*!50003 SET collation_connection  = utf8_general_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'STRICT_TRANS_TABLES,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`nxtel`@`%` PROCEDURE `sp_GetUniqueMailbox`()
BEGIN
    SET @Mailbox='';
    SET @Count=1;
    WHILE(@Count<>0) DO
        SELECT @Mailbox:=CAST(CAST(RAND()*900000000+100000000 AS unsigned) AS char(9));
        SELECT @Count:=COUNT(*) FROM AspNetUsers WHERE Mailbox=@Mailbox;
    END WHILE;
    SELECT @Mailbox AS Mailbox;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2018-12-09 12:00:45
