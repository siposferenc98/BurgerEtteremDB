-- phpMyAdmin SQL Dump
-- version 5.1.1
-- https://www.phpmyadmin.net/
--
-- Gép: 127.0.0.1
-- Létrehozás ideje: 2022. Jan 23. 10:18
-- Kiszolgáló verziója: 10.4.20-MariaDB
-- PHP verzió: 8.0.9

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Adatbázis: `burgeretterem`
--
CREATE DATABASE IF NOT EXISTS `burgeretterem` DEFAULT CHARACTER SET utf8 COLLATE utf8_hungarian_ci;
USE `burgeretterem`;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `burger`
--

CREATE TABLE `burger` (
  `bazon` int(1) NOT NULL,
  `bnev` varchar(50) COLLATE utf8_hungarian_ci NOT NULL,
  `bar` int(4) NOT NULL,
  `bleir` varchar(150) COLLATE utf8_hungarian_ci NOT NULL,
  `aktiv` tinyint(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_hungarian_ci;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `desszert`
--

CREATE TABLE `desszert` (
  `dazon` int(1) NOT NULL,
  `dnev` varchar(50) COLLATE utf8_hungarian_ci NOT NULL,
  `dar` int(4) NOT NULL,
  `dleir` varchar(100) COLLATE utf8_hungarian_ci NOT NULL,
  `aktiv` tinyint(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_hungarian_ci;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `felhasznalo`
--

CREATE TABLE `felhasznalo` (
  `azon` int(6) UNSIGNED NOT NULL,
  `nev` varchar(50) COLLATE utf8_hungarian_ci NOT NULL,
  `lak` varchar(100) COLLATE utf8_hungarian_ci NOT NULL,
  `tel` varchar(12) COLLATE utf8_hungarian_ci NOT NULL,
  `email` varchar(50) COLLATE utf8_hungarian_ci NOT NULL,
  `jog` int(1) NOT NULL,
  `pw` varchar(40) COLLATE utf8_hungarian_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_hungarian_ci;

--
-- A tábla adatainak kiíratása `felhasznalo`
--

INSERT INTO `felhasznalo` (`azon`, `nev`, `lak`, `tel`, `email`, `jog`, `pw`) VALUES
(1, 'Admin', '-', '9999999', 'admin', 4, '21232f297a57a5a743894a0e4a801fc3');

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `foglalas`
--

CREATE TABLE `foglalas` (
  `fazon` int(4) UNSIGNED NOT NULL,
  `azon` int(6) UNSIGNED DEFAULT NULL,
  `szemelydb` int(1) NOT NULL,
  `datum` date NOT NULL,
  `idopont` time NOT NULL,
  `ido` datetime NOT NULL,
  `megjelent` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_hungarian_ci;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `ital`
--

CREATE TABLE `ital` (
  `iazon` int(1) NOT NULL,
  `inev` varchar(50) COLLATE utf8_hungarian_ci NOT NULL,
  `iar` int(4) NOT NULL,
  `ileir` varchar(50) COLLATE utf8_hungarian_ci NOT NULL,
  `aktiv` tinyint(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_hungarian_ci;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `koret`
--

CREATE TABLE `koret` (
  `kazon` int(1) NOT NULL,
  `knev` varchar(50) COLLATE utf8_hungarian_ci NOT NULL,
  `kar` int(4) NOT NULL,
  `kleir` varchar(100) COLLATE utf8_hungarian_ci NOT NULL,
  `aktiv` tinyint(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_hungarian_ci;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `rendeles`
--

CREATE TABLE `rendeles` (
  `razon` int(4) UNSIGNED NOT NULL,
  `fazon` int(4) UNSIGNED DEFAULT NULL,
  `asztal` int(1) NOT NULL,
  `ido` datetime NOT NULL,
  `etelstatus` int(1) NOT NULL,
  `italstatus` int(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_hungarian_ci;

--
-- Eseményindítók `rendeles`
--
DELIMITER $$
CREATE TRIGGER `foglalasmegjelent` AFTER UPDATE ON `rendeles` FOR EACH ROW UPDATE foglalas f INNER JOIN rendeles r ON f.fazon = r.fazon
    SET f.megjelent = IF((SELECT MIN(r.etelstatus) FROM rendeles r WHERE f.fazon = r.fazon) = 4, 1, 0) WHERE f.fazon = r.fazon
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Tábla szerkezet ehhez a táblához `tetel`
--

CREATE TABLE `tetel` (
  `tazon` int(4) UNSIGNED NOT NULL,
  `razon` int(4) UNSIGNED DEFAULT NULL,
  `bazon` int(1) NOT NULL,
  `bdb` int(1) DEFAULT NULL,
  `kazon` int(1) NOT NULL,
  `kdb` int(1) DEFAULT NULL,
  `dazon` int(1) NOT NULL,
  `ddb` int(1) DEFAULT NULL,
  `iazon` int(1) NOT NULL,
  `idb` int(1) DEFAULT NULL,
  `etelstatus` int(1) NOT NULL,
  `italstatus` int(1) NOT NULL,
  `megjegyzes` varchar(255) COLLATE utf8_hungarian_ci DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_hungarian_ci;

--
-- Eseményindítók `tetel`
--
DELIMITER $$
CREATE TRIGGER `rendelestetelfrissit` AFTER UPDATE ON `tetel` FOR EACH ROW UPDATE rendeles r INNER JOIN tetel t ON r.razon = t.razon
    SET r.etelstatus = (SELECT MIN( t.etelstatus) FROM tetel t WHERE r.razon = t.razon),
    r.italstatus = (SELECT MIN( t.italstatus) FROM tetel t WHERE r.razon = t.razon)
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `rendelestetelfrissitinsert` AFTER INSERT ON `tetel` FOR EACH ROW UPDATE rendeles r INNER JOIN tetel t ON r.razon = t.razon
    SET r.italstatus = (SELECT MIN( t.italstatus) FROM tetel t WHERE r.razon = t.razon),
    r.etelstatus = (SELECT MIN( t.etelstatus) FROM tetel t WHERE r.razon = t.razon)
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `urestermekstatus` BEFORE INSERT ON `tetel` FOR EACH ROW SET NEW.italstatus = IF(NEW.iazon = 0,2,1), 
 NEW.etelstatus = IF(NEW.bazon = 0 AND NEW.kazon = 0 AND NEW.dazon = 0,2,1)
$$
DELIMITER ;

--
-- Indexek a kiírt táblákhoz
--

--
-- A tábla indexei `burger`
--
ALTER TABLE `burger`
  ADD PRIMARY KEY (`bazon`);

--
-- A tábla indexei `desszert`
--
ALTER TABLE `desszert`
  ADD PRIMARY KEY (`dazon`);

--
-- A tábla indexei `felhasznalo`
--
ALTER TABLE `felhasznalo`
  ADD PRIMARY KEY (`azon`);

--
-- A tábla indexei `foglalas`
--
ALTER TABLE `foglalas`
  ADD PRIMARY KEY (`fazon`),
  ADD KEY `fk_foglalas_felhasznalo` (`azon`);

--
-- A tábla indexei `ital`
--
ALTER TABLE `ital`
  ADD PRIMARY KEY (`iazon`);

--
-- A tábla indexei `koret`
--
ALTER TABLE `koret`
  ADD PRIMARY KEY (`kazon`);

--
-- A tábla indexei `rendeles`
--
ALTER TABLE `rendeles`
  ADD PRIMARY KEY (`razon`),
  ADD KEY `fk_rendeles_foglalas` (`fazon`);

--
-- A tábla indexei `tetel`
--
ALTER TABLE `tetel`
  ADD PRIMARY KEY (`tazon`),
  ADD KEY `fk_tetel_rendeles` (`razon`),
  ADD KEY `fk_tetel_burger` (`bazon`),
  ADD KEY `fk_tetel_koret` (`kazon`),
  ADD KEY `fk_tetel_desszert` (`dazon`),
  ADD KEY `fk_tetel_ital` (`iazon`);

--
-- A kiírt táblák AUTO_INCREMENT értéke
--

--
-- AUTO_INCREMENT a táblához `burger`
--
ALTER TABLE `burger`
  MODIFY `bazon` int(1) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT a táblához `desszert`
--
ALTER TABLE `desszert`
  MODIFY `dazon` int(1) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT a táblához `felhasznalo`
--
ALTER TABLE `felhasznalo`
  MODIFY `azon` int(6) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT a táblához `foglalas`
--
ALTER TABLE `foglalas`
  MODIFY `fazon` int(4) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT a táblához `ital`
--
ALTER TABLE `ital`
  MODIFY `iazon` int(1) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT a táblához `koret`
--
ALTER TABLE `koret`
  MODIFY `kazon` int(1) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT a táblához `rendeles`
--
ALTER TABLE `rendeles`
  MODIFY `razon` int(4) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT a táblához `tetel`
--
ALTER TABLE `tetel`
  MODIFY `tazon` int(4) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- Megkötések a kiírt táblákhoz
--

--
-- Megkötések a táblához `foglalas`
--
ALTER TABLE `foglalas`
  ADD CONSTRAINT `fk_foglalas_felhasznalo` FOREIGN KEY (`azon`) REFERENCES `felhasznalo` (`azon`) ON DELETE CASCADE;

--
-- Megkötések a táblához `rendeles`
--
ALTER TABLE `rendeles`
  ADD CONSTRAINT `fk_rendeles_foglalas` FOREIGN KEY (`fazon`) REFERENCES `foglalas` (`fazon`) ON DELETE CASCADE;

--
-- Megkötések a táblához `tetel`
--
ALTER TABLE `tetel`
  ADD CONSTRAINT `fk_tetel_burger` FOREIGN KEY (`bazon`) REFERENCES `burger` (`bazon`),
  ADD CONSTRAINT `fk_tetel_desszert` FOREIGN KEY (`dazon`) REFERENCES `desszert` (`dazon`),
  ADD CONSTRAINT `fk_tetel_ital` FOREIGN KEY (`iazon`) REFERENCES `ital` (`iazon`),
  ADD CONSTRAINT `fk_tetel_koret` FOREIGN KEY (`kazon`) REFERENCES `koret` (`kazon`),
  ADD CONSTRAINT `fk_tetel_rendeles` FOREIGN KEY (`razon`) REFERENCES `rendeles` (`razon`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;