-- phpMyAdmin SQL Dump
-- version 3.5.1
-- http://www.phpmyadmin.net
--
-- Client: localhost
-- Généré le: Lun 14 Janvier 2013 à 08:19
-- Version du serveur: 5.5.24-log
-- Version de PHP: 5.4.3

SET SQL_MODE="NO_AUTO_VALUE_ON_ZERO";
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8 */;

--
-- Base de données: `csv_db`
--

-- --------------------------------------------------------

--
-- Structure de la table `stop_times`
--

CREATE TABLE IF NOT EXISTS `stop_times` (
  `trip_id` varchar(5) DEFAULT NULL,
  `stop_id` varchar(4) DEFAULT NULL,
  `stop_sequence` varchar(2) DEFAULT NULL,
  `arrival_time` varchar(8) DEFAULT NULL,
  `departure_time` varchar(8) DEFAULT NULL,
  `stop_headsign` varchar(10) DEFAULT NULL,
  `pickup_type` varchar(1) DEFAULT NULL,
  `drop_off_type` varchar(1) DEFAULT NULL,
  `shape_dist_traveled` varchar(10) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Structure de la table `trips`
--

CREATE TABLE IF NOT EXISTS `trips` (
  `trip_id` varchar(5) DEFAULT NULL,
  `service_id` varchar(2) DEFAULT NULL,
  `route_id` varchar(4) DEFAULT NULL,
  `trip_headsign` varchar(37) DEFAULT NULL,
  `direction_id` varchar(1) DEFAULT NULL,
  `block_id` varchar(10) DEFAULT NULL,
  KEY `trip_id` (`trip_id`),
  KEY `trip_id_2` (`trip_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
