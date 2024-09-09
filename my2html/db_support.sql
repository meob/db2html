-- Generate by mysqldump and... vi

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";

CREATE TABLE `db_versions` (
  `db` varchar(64) NOT NULL,
  `version` varchar(64) NOT NULL,
  `upgrade` varchar(64) NOT NULL,
  `status` varchar(64) DEFAULT NULL,
  `note` varchar(64) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

INSERT INTO `db_versions` (`db`, `version`, `upgrade`, `status`, `note`) VALUES
('MySQL', '3.23', '3.23.58', 'DESUPPORTED', NULL),
('MySQL', '4.0', '4.0.27', 'DESUPPORTED', NULL),
('MySQL', '4.1', '4.1.22', 'DESUPPORTED', NULL),
('MySQL', '5.0', '5.0.96', 'DESUPPORTED', NULL),
('MySQL', '5.1', '5.1.73', 'DESUPPORTED', NULL),
('MySQL', '5.5', '5.5.59', 'Supported', NULL),
('MySQL', '5.6', '5.6.39', 'Supported', NULL),
('MySQL', '5.7', '5.7.21', 'Supported', NULL),
('MySQL', '8.0', '8.0.3', 'NOT YET SUPPORTED', NULL),
('MariaDB', '5.1', '5.1.67', 'DESUPPORTED', NULL),
('MariaDB', '5.2', '5.2.14', 'DESUPPORTED', NULL),
('MariaDB', '5.3', '5.3.12', 'DESUPPORTED', NULL),
('MariaDB', '5.5', '5.5.59', 'Supported', NULL),
('MariaDB', '10.0', '10.0.34', 'Supported', NULL),
('MariaDB', '10.1', '10.1.31', 'Supported', NULL),
('MariaDB', '10.2', '10.2.13', 'Supported', NULL),
('MariaDB', '10.3', '10.3.4', 'NOT YET SUPPORTED', NULL),
('Oracle', '10.1', '10.1.0.5', 'DESUPPORTED', NULL),
('Oracle', '10.2', '10.2.0.5', 'DESUPPORTED', NULL),
('Oracle', '11.1', '11.1.0.7', 'DESUPPORTED', NULL),
('Oracle', '11.2', '11.2.0.4', 'Supported', '11.2.0.4.180116'),
('Oracle', '12.1', '12.1.0.2', 'Supported', '12.1.0.2.180116'),
('Oracle', '12.2', '12.2.0.1', 'Supported', '12.2.0.1.180116'),
('Oracle', '7.3', '7.3.4.5', 'DESUPPORTED', NULL),
('Oracle', '8.0', '8.0.6.3', 'DESUPPORTED', NULL),
('Oracle', '8.1', '8.1.7.4', 'DESUPPORTED', NULL),
('Oracle', '9.0', '9.0.1.5', 'DESUPPORTED', NULL),
('Oracle', '9.2', '9.2.0.8', 'DESUPPORTED', NULL),
('PostgreSQL', '10.2', '10.2.0', 'Supported', NULL),
('PostgreSQL', '6.0', '6.5.3', 'DESUPPORTED', NULL),
('PostgreSQL', '7.0', '7.4.30', 'DESUPPORTED', NULL),
('PostgreSQL', '8.0', '8.0.26', 'DESUPPORTED', NULL),
('PostgreSQL', '8.1', '8.1.23', 'DESUPPORTED', NULL),
('PostgreSQL', '8.2', '8.2.23', 'DESUPPORTED', NULL),
('PostgreSQL', '8.3', '8.3.23', 'DESUPPORTED', NULL),
('PostgreSQL', '8.4', '8.4.21', 'DESUPPORTED', NULL),
('PostgreSQL', '9.0', '9.0.23', 'DESUPPORTED', NULL),
('PostgreSQL', '9.1', '9.1.24', 'DESUPPORTED', NULL),
('PostgreSQL', '9.2', '9.2.24', 'DESUPPORTED', NULL),
('PostgreSQL', '9.3', '9.3.21', 'Supported', NULL),
('PostgreSQL', '9.4', '9.4.16', 'Supported', NULL),
('PostgreSQL', '9.5', '9.5.11', 'Supported', NULL),
('PostgreSQL', '9.6', '9.6.7', 'Supported', NULL),
('SQL Server', '10.0', '10.0.6000.29', 'DESUPPORTED', NULL),
('SQL Server', '10.50', '10.50.6000.34', 'DESUPPORTED', NULL),
('SQL Server', '11.0', '11.0.6607.3', 'Supported', NULL),
('SQL Server', '12.0', '12.0.5563.0', 'Supported', NULL),
('SQL Server', '13.0', '13.0.4466.4', 'Supported', NULL),
('SQL Server', '14.0', '14.0.3015.40', 'Supported', NULL),
('SQL Server', '7.0', '7.00.1063', 'DESUPPORTED', NULL),
('SQL Server', '8.0', '8.00.2039', 'DESUPPORTED', NULL),
('SQL Server', '9.0', '9.00.5000', 'DESUPPORTED', NULL);

ALTER TABLE `db_versions`
  ADD PRIMARY KEY (`db`,`version`);
COMMIT;
