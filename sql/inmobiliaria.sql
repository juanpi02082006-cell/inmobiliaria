-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 12-09-2026 a las 05:23:48
-- Versión del servidor: 10.4.32-MariaDB
-- Versión de PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `inmobiliaria`
--

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `auditoria`
--

CREATE TABLE `auditoria` (
  `id_auditoria` int(11) NOT NULL,
  `id_usuario` int(11) DEFAULT NULL,
  `accion` varchar(80) NOT NULL,
  `entidad` varchar(40) DEFAULT NULL,
  `id_entidad` int(11) DEFAULT NULL,
  `detalle` varchar(255) DEFAULT NULL,
  `ip` varchar(45) DEFAULT NULL,
  `fecha` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `auditoria`
--

INSERT INTO `auditoria` (`id_auditoria`, `id_usuario`, `accion`, `entidad`, `id_entidad`, `detalle`, `ip`, `fecha`) VALUES
(1, 1, 'LOGIN_OK', 'usuario', 1, 'Inicio de sesion administrador', '127.0.0.1', '2026-09-09 19:11:57'),
(2, 2, 'LOGIN_OK', 'usuario', 2, 'Inicio de sesion agente', '127.0.0.1', '2026-09-09 19:11:57'),
(3, 2, 'CREAR_PROPIEDAD', 'propiedad', 1, 'Alta de propiedad MI-300-001', '127.0.0.1', '2026-09-09 19:11:57'),
(4, 2, 'CREAR_PROPIEDAD', 'propiedad', 2, 'Alta de propiedad MI-300-002', '127.0.0.1', '2026-09-09 19:11:57'),
(5, 3, 'EDITAR_PROPIEDAD', 'propiedad', 3, 'Cambio de precio', '127.0.0.1', '2026-09-09 19:11:57'),
(6, 5, 'LOGIN_FAIL', 'usuario', 5, 'Contrasena incorrecta', '190.0.0.5', '2026-09-09 19:11:57'),
(7, 5, 'LOGIN_OK', 'usuario', 5, 'Inicio de sesion cliente', '190.0.0.5', '2026-09-09 19:11:57'),
(8, 5, 'CREAR_CITA', 'cita', 1, 'Agenda visita propiedad 1', '190.0.0.5', '2026-09-09 19:11:57'),
(9, 6, 'CREAR_SOLICITUD', 'solicitud', 2, 'Radica solicitud de compra', '190.0.0.6', '2026-09-09 19:11:57'),
(10, 3, 'APROBAR_SOLICITUD', 'solicitud', 2, 'Solicitud aprobada', '127.0.0.1', '2026-09-09 19:11:57'),
(11, NULL, 'ACCESO_DENEGADO', 'ruta', NULL, 'Intento a /admin sin sesion', '45.10.20.30', '2026-09-09 19:11:57'),
(12, 1, 'ASIGNAR_ROL', 'usuario_rol', 5, 'Asigna rol CLIENTE al usuario 5', '127.0.0.1', '2026-09-09 19:11:57'),
(13, 1, 'LOGIN_OK', NULL, NULL, 'Ingreso como ADMIN', '0:0:0:0:0:0:0:1', '2026-09-09 19:12:00'),
(14, 2, 'LOGIN_OK', NULL, NULL, 'Ingreso como INMOBILIARIA', '0:0:0:0:0:0:0:1', '2026-09-09 19:12:01'),
(15, 5, 'LOGIN_OK', NULL, NULL, 'Ingreso como CLIENTE', '0:0:0:0:0:0:0:1', '2026-09-09 19:12:02'),
(16, 1, 'EDITAR_CIUDAD', NULL, NULL, 'Piedecuesta (Santander)', '0:0:0:0:0:0:0:1', '2026-09-09 19:13:27'),
(17, 1, 'EDITAR_CIUDAD', NULL, NULL, 'Piedecuesta (Santander)', '0:0:0:0:0:0:0:1', '2026-09-09 19:13:33'),
(18, 1, 'LOGOUT', NULL, NULL, 'Cierre de sesion de admin@inmobiliaria.com', '0:0:0:0:0:0:0:1', '2026-09-09 19:14:22'),
(19, 5, 'LOGIN_OK', NULL, NULL, 'Ingreso como CLIENTE', '0:0:0:0:0:0:0:1', '2026-09-09 19:15:04'),
(20, 5, 'LOGIN_OK', NULL, NULL, 'Ingreso como CLIENTE', '0:0:0:0:0:0:0:1', '2026-09-11 20:16:53'),
(21, 2, 'LOGIN_OK', NULL, NULL, 'Ingreso como INMOBILIARIA', '0:0:0:0:0:0:0:1', '2026-09-11 20:17:32'),
(22, 5, 'LOGIN_OK', NULL, NULL, 'Ingreso como CLIENTE', '0:0:0:0:0:0:0:1', '2026-09-11 20:25:57'),
(23, 5, 'AGENDAR_CITA', NULL, NULL, 'Visita a Casa moderna en el norte (MI-300-001)', '0:0:0:0:0:0:0:1', '2026-09-11 20:26:21'),
(24, 2, 'LOGIN_OK', NULL, NULL, 'Ingreso como INMOBILIARIA', '0:0:0:0:0:0:0:1', '2026-09-11 20:26:42'),
(25, 2, 'LOGOUT', NULL, NULL, 'Cierre de sesion de agente.norte@sraiz.com', '0:0:0:0:0:0:0:1', '2026-09-11 20:26:46'),
(26, 2, 'CONFIRMAR_CITA', NULL, NULL, 'Cita 13 confirmada por el agente', '0:0:0:0:0:0:0:1', '2026-09-11 20:26:58'),
(27, 5, 'LOGIN_OK', NULL, NULL, 'Ingreso como CLIENTE', '0:0:0:0:0:0:0:1', '2026-09-11 20:31:47'),
(28, 2, 'LOGIN_OK', NULL, NULL, 'Ingreso como INMOBILIARIA', '0:0:0:0:0:0:0:1', '2026-09-11 20:32:31'),
(29, 5, 'LOGIN_OK', NULL, NULL, 'Ingreso como CLIENTE', '0:0:0:0:0:0:0:1', '2026-09-11 20:32:43'),
(30, 5, 'CANCELAR_CITA', NULL, NULL, 'Cita 1 cancelada por el cliente', '0:0:0:0:0:0:0:1', '2026-09-11 20:33:20'),
(31, 5, 'EDITAR_PERFIL', NULL, NULL, 'Actualizo sus datos personales', '0:0:0:0:0:0:0:1', '2026-09-11 20:34:16'),
(32, 5, 'EDITAR_PERFIL', NULL, NULL, 'Actualizo sus datos personales', '0:0:0:0:0:0:0:1', '2026-09-11 20:34:20'),
(33, 5, 'EDITAR_PERFIL', NULL, NULL, 'Actualizo sus datos personales', '0:0:0:0:0:0:0:1', '2026-09-11 20:34:26'),
(34, 5, 'LOGOUT', NULL, NULL, 'Cierre de sesion de carlos.perez@gmail.com', '0:0:0:0:0:0:0:1', '2026-09-11 20:34:37'),
(35, NULL, 'LOGIN_FAIL', NULL, NULL, 'Credenciales invalidas: agente.norte@sraiz.com', '0:0:0:0:0:0:0:1', '2026-09-11 20:35:14'),
(36, 2, 'LOGIN_OK', NULL, NULL, 'Ingreso como INMOBILIARIA', '0:0:0:0:0:0:0:1', '2026-09-11 20:35:20'),
(37, 2, 'LOGOUT', NULL, NULL, 'Cierre de sesion de agente.norte@sraiz.com', '0:0:0:0:0:0:0:1', '2026-09-11 20:35:31'),
(38, 1, 'LOGIN_OK', NULL, NULL, 'Ingreso como ADMIN', '0:0:0:0:0:0:0:1', '2026-09-11 20:35:45'),
(39, 1, 'ASIGNAR_ROL', NULL, NULL, 'Cambio los roles de admin@inmobiliaria.com', '0:0:0:0:0:0:0:1', '2026-09-11 20:36:22'),
(40, 5, 'LOGIN_OK', NULL, NULL, 'Ingreso como CLIENTE', '0:0:0:0:0:0:0:1', '2026-09-11 20:36:56'),
(41, 5, 'RADICAR_SOLICITUD', NULL, NULL, 'COMPRA sobre Casa moderna en el norte (MI-300-001)', '0:0:0:0:0:0:0:1', '2026-09-11 20:37:04'),
(42, 6, 'LOGIN_OK', NULL, NULL, 'Ingreso como CLIENTE', '0:0:0:0:0:0:0:1', '2026-09-11 20:37:39'),
(43, 5, 'LOGIN_OK', NULL, NULL, 'Ingreso como CLIENTE', '0:0:0:0:0:0:0:1', '2026-09-11 20:41:02'),
(44, 5, 'RADICAR_SOLICITUD', NULL, NULL, 'COMPRA sobre Casa moderna en el norte (MI-300-001)', '0:0:0:0:0:0:0:1', '2026-09-11 20:41:02'),
(45, 2, 'LOGIN_OK', NULL, NULL, 'Ingreso como INMOBILIARIA', '0:0:0:0:0:0:0:1', '2026-09-11 20:41:11'),
(46, 2, 'EVALUAR_DOCUMENTO', NULL, NULL, 'Documento 14 de la solicitud 12 marcado como ACEPTADO', '0:0:0:0:0:0:0:1', '2026-09-11 20:41:22'),
(47, 2, 'REVISAR_SOLICITUD', NULL, NULL, 'Solicitud 12 puesta en revision', '0:0:0:0:0:0:0:1', '2026-09-11 20:41:22'),
(48, 2, 'APROBAR_SOLICITUD', NULL, NULL, 'Solicitud 12 aprobada', '0:0:0:0:0:0:0:1', '2026-09-11 20:41:22'),
(49, 3, 'LOGIN_OK', NULL, NULL, 'Ingreso como INMOBILIARIA', '0:0:0:0:0:0:0:1', '2026-09-11 20:41:35'),
(50, 2, 'RECHAZAR_SOLICITUD', NULL, NULL, 'Solicitud 12 rechazada', '0:0:0:0:0:0:0:1', '2026-09-11 20:41:45'),
(51, 1, 'LOGIN_OK', NULL, NULL, 'Ingreso como ADMIN', '0:0:0:0:0:0:0:1', '2026-09-11 20:45:44'),
(52, 5, 'LOGIN_OK', NULL, NULL, 'Ingreso como CLIENTE', '0:0:0:0:0:0:0:1', '2026-09-11 20:46:04'),
(53, 1, 'LOGIN_OK', NULL, NULL, 'Ingreso como ADMIN', '0:0:0:0:0:0:0:1', '2026-09-11 20:48:05'),
(54, 5, 'LOGIN_OK', NULL, NULL, 'Ingreso como CLIENTE', '0:0:0:0:0:0:0:1', '2026-09-11 20:48:22'),
(55, 1, 'LOGOUT', NULL, NULL, 'Cierre de sesion de admin@inmobiliaria.com', '0:0:0:0:0:0:0:1', '2026-09-11 20:53:40'),
(56, 5, 'LOGIN_OK', NULL, NULL, 'Ingreso como CLIENTE', '0:0:0:0:0:0:0:1', '2026-09-11 20:54:06'),
(57, 2, 'LOGIN_OK', NULL, NULL, 'Ingreso como INMOBILIARIA', '0:0:0:0:0:0:0:1', '2026-09-11 21:07:12'),
(58, 5, 'LOGOUT', NULL, NULL, 'Cierre de sesion de carlos.perez@gmail.com', '0:0:0:0:0:0:0:1', '2026-09-11 21:07:34'),
(59, 2, 'LOGIN_OK', NULL, NULL, 'Ingreso como INMOBILIARIA', '0:0:0:0:0:0:0:1', '2026-09-11 21:07:51'),
(60, 2, 'LOGOUT', NULL, NULL, 'Cierre de sesion de agente.norte@sraiz.com', '0:0:0:0:0:0:0:1', '2026-09-11 21:08:33'),
(61, 3, 'LOGIN_OK', NULL, NULL, 'Ingreso como INMOBILIARIA', '0:0:0:0:0:0:0:1', '2026-09-11 21:08:38'),
(62, 1, 'LOGIN_OK', NULL, NULL, 'Ingreso como ADMIN', '0:0:0:0:0:0:0:1', '2026-09-11 21:08:45'),
(63, 1, 'LOGOUT', NULL, NULL, 'Cierre de sesion de admin@inmobiliaria.com', '0:0:0:0:0:0:0:1', '2026-09-11 21:09:26'),
(64, 2, 'LOGIN_OK', NULL, NULL, 'Ingreso como INMOBILIARIA', '0:0:0:0:0:0:0:1', '2026-09-11 21:09:34'),
(65, 2, 'APROBAR_SOLICITUD', NULL, NULL, 'Solicitud 1 aprobada', '0:0:0:0:0:0:0:1', '2026-09-11 21:09:46'),
(66, 2, 'CREAR_PROPIEDAD', NULL, NULL, 'Inmueble H92-222 (Casa)', '0:0:0:0:0:0:0:1', '2026-09-11 21:11:01'),
(67, 1, 'LOGIN_OK', NULL, NULL, 'Ingreso como ADMIN', '0:0:0:0:0:0:0:1', '2026-09-11 21:11:47'),
(68, 2, 'LOGIN_OK', NULL, NULL, 'Ingreso como INMOBILIARIA', '0:0:0:0:0:0:0:1', '2026-09-11 21:11:47'),
(69, 5, 'LOGIN_OK', NULL, NULL, 'Ingreso como CLIENTE', '0:0:0:0:0:0:0:1', '2026-09-11 21:11:48'),
(70, 2, 'LOGOUT', NULL, NULL, 'Cierre de sesion de agente.norte@sraiz.com', '0:0:0:0:0:0:0:1', '2026-09-11 21:12:59'),
(71, NULL, 'LOGIN_FAIL', NULL, NULL, 'Credenciales invalidas: carlos.perez@gmail.com', '0:0:0:0:0:0:0:1', '2026-09-11 21:13:21'),
(72, 5, 'LOGIN_OK', NULL, NULL, 'Ingreso como CLIENTE', '0:0:0:0:0:0:0:1', '2026-09-11 21:13:26'),
(73, 5, 'LOGOUT', NULL, NULL, 'Cierre de sesion de carlos.perez@gmail.com', '0:0:0:0:0:0:0:1', '2026-09-11 21:14:00'),
(74, 1, 'LOGIN_OK', NULL, NULL, 'Ingreso como ADMIN', '0:0:0:0:0:0:0:1', '2026-09-11 21:14:10'),
(75, 1, 'EDITAR_CIUDAD', NULL, NULL, 'Medellin (Antioquia)', '0:0:0:0:0:0:0:1', '2026-09-11 21:16:48'),
(76, 1, 'EDITAR_CIUDAD', NULL, NULL, 'Medellin (Antioquia)', '0:0:0:0:0:0:0:1', '2026-09-11 21:16:48'),
(77, 1, 'LOGIN_OK', NULL, NULL, 'Ingreso como ADMIN', '0:0:0:0:0:0:0:1', '2026-09-11 21:19:30'),
(78, 1, 'LOGIN_OK', NULL, NULL, 'Ingreso como ADMIN', '0:0:0:0:0:0:0:1', '2026-09-11 21:24:46'),
(79, 2, 'LOGIN_OK', NULL, NULL, 'Ingreso como INMOBILIARIA', '0:0:0:0:0:0:0:1', '2026-09-11 21:24:56'),
(80, 5, 'LOGIN_OK', NULL, NULL, 'Ingreso como CLIENTE', '0:0:0:0:0:0:0:1', '2026-09-11 21:24:57'),
(81, 1, 'LOGOUT', NULL, NULL, 'Cierre de sesion de admin@inmobiliaria.com', '0:0:0:0:0:0:0:1', '2026-09-11 21:25:41'),
(82, 5, 'LOGIN_OK', NULL, NULL, 'Ingreso como CLIENTE', '0:0:0:0:0:0:0:1', '2026-09-11 21:25:57'),
(83, 5, 'LOGOUT', NULL, NULL, 'Cierre de sesion de carlos.perez@gmail.com', '0:0:0:0:0:0:0:1', '2026-09-11 21:27:17'),
(84, NULL, 'LOGIN_FAIL', NULL, NULL, 'Credenciales invalidas: agente.norte@sraiz.com', '0:0:0:0:0:0:0:1', '2026-09-11 21:27:26'),
(85, 2, 'LOGIN_OK', NULL, NULL, 'Ingreso como INMOBILIARIA', '0:0:0:0:0:0:0:1', '2026-09-11 21:27:30'),
(86, 2, 'LOGOUT', NULL, NULL, 'Cierre de sesion de agente.norte@sraiz.com', '0:0:0:0:0:0:0:1', '2026-09-11 21:32:44'),
(87, 5, 'LOGIN_OK', NULL, NULL, 'Ingreso como CLIENTE', '0:0:0:0:0:0:0:1', '2026-09-11 21:32:57'),
(88, 1, 'LOGIN_OK', NULL, NULL, 'Ingreso como ADMIN', '0:0:0:0:0:0:0:1', '2026-09-11 21:33:05'),
(89, 2, 'LOGIN_OK', NULL, NULL, 'Ingreso como INMOBILIARIA', '0:0:0:0:0:0:0:1', '2026-09-11 21:33:14'),
(90, 5, 'LOGIN_OK', NULL, NULL, 'Ingreso como CLIENTE', '0:0:0:0:0:0:0:1', '2026-09-11 21:33:14'),
(91, 2, 'LOGIN_OK', NULL, NULL, 'Ingreso como INMOBILIARIA', '0:0:0:0:0:0:0:1', '2026-09-11 21:33:22'),
(92, 5, 'LOGOUT', NULL, NULL, 'Cierre de sesion de carlos.perez@gmail.com', '0:0:0:0:0:0:0:1', '2026-09-11 21:33:52'),
(93, NULL, 'LOGIN_FAIL', NULL, NULL, 'Credenciales invalidas: agente.norte@sraiz.com', '0:0:0:0:0:0:0:1', '2026-09-11 21:34:00'),
(94, 2, 'LOGIN_OK', NULL, NULL, 'Ingreso como INMOBILIARIA', '0:0:0:0:0:0:0:1', '2026-09-11 21:34:04'),
(95, 2, 'LOGIN_OK', NULL, NULL, 'Ingreso como INMOBILIARIA', '0:0:0:0:0:0:0:1', '2026-09-11 21:35:32'),
(96, 2, 'LOGOUT', NULL, NULL, 'Cierre de sesion de agente.norte@sraiz.com', '0:0:0:0:0:0:0:1', '2026-09-11 21:35:45'),
(97, 1, 'LOGIN_OK', NULL, NULL, 'Ingreso como ADMIN', '0:0:0:0:0:0:0:1', '2026-09-11 21:35:56'),
(98, 1, 'LOGIN_OK', NULL, NULL, 'Ingreso como ADMIN', '0:0:0:0:0:0:0:1', '2026-09-11 21:36:52'),
(99, 1, 'LOGIN_OK', NULL, NULL, 'Ingreso como ADMIN', '0:0:0:0:0:0:0:1', '2026-09-11 21:40:41'),
(100, 2, 'LOGIN_OK', NULL, NULL, 'Ingreso como INMOBILIARIA', '0:0:0:0:0:0:0:1', '2026-09-11 21:40:42'),
(101, 5, 'LOGIN_OK', NULL, NULL, 'Ingreso como CLIENTE', '0:0:0:0:0:0:0:1', '2026-09-11 21:40:43'),
(102, 1, 'LOGOUT', NULL, NULL, 'Cierre de sesion de admin@inmobiliaria.com', '0:0:0:0:0:0:0:1', '2026-09-11 21:44:25'),
(103, 5, 'LOGIN_OK', NULL, NULL, 'Ingreso como CLIENTE', '0:0:0:0:0:0:0:1', '2026-09-11 21:44:36'),
(104, 5, 'LOGIN_OK', NULL, NULL, 'Ingreso como CLIENTE', '0:0:0:0:0:0:0:1', '2026-09-11 21:53:16'),
(105, 5, 'LOGOUT', NULL, NULL, 'Cierre de sesion de carlos.perez@gmail.com', '0:0:0:0:0:0:0:1', '2026-09-11 21:55:33'),
(106, 5, 'LOGIN_OK', NULL, NULL, 'Ingreso como CLIENTE', '0:0:0:0:0:0:0:1', '2026-09-11 21:56:04'),
(107, 2, 'LOGIN_OK', NULL, NULL, 'Ingreso como INMOBILIARIA', '0:0:0:0:0:0:0:1', '2026-09-11 21:57:37'),
(108, 2, 'LOGOUT', NULL, NULL, 'Cierre de sesion de agente.norte@sraiz.com', '0:0:0:0:0:0:0:1', '2026-09-11 21:57:50'),
(109, 2, 'LOGIN_OK', NULL, NULL, 'Ingreso como INMOBILIARIA', '0:0:0:0:0:0:0:1', '2026-09-11 22:05:36'),
(110, 2, 'LOGOUT', NULL, NULL, 'Cierre de sesion de agente.norte@sraiz.com', '0:0:0:0:0:0:0:1', '2026-09-11 22:16:25');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `caracteristica`
--

CREATE TABLE `caracteristica` (
  `id_caracteristica` int(11) NOT NULL,
  `nombre` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `caracteristica`
--

INSERT INTO `caracteristica` (`id_caracteristica`, `nombre`) VALUES
(9, 'Aire acondicionado'),
(3, 'Ascensor'),
(6, 'Balcon'),
(8, 'Deposito'),
(4, 'Gimnasio'),
(10, 'Jardin'),
(2, 'Parqueadero'),
(1, 'Piscina'),
(5, 'Porteria 24h'),
(7, 'Zona BBQ');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `cita`
--

CREATE TABLE `cita` (
  `id_cita` int(11) NOT NULL,
  `id_propiedad` int(11) NOT NULL,
  `id_cliente` int(11) NOT NULL,
  `fecha_hora` datetime NOT NULL,
  `estado` enum('PENDIENTE','CONFIRMADA','CANCELADA','REALIZADA') NOT NULL DEFAULT 'PENDIENTE',
  `observaciones` varchar(255) DEFAULT NULL,
  `fecha_solicitud` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `cita`
--

INSERT INTO `cita` (`id_cita`, `id_propiedad`, `id_cliente`, `fecha_hora`, `estado`, `observaciones`, `fecha_solicitud`) VALUES
(1, 1, 5, '2026-09-15 10:00:00', 'CANCELADA', 'Cliente interesado en compra', '2026-09-09 19:11:57'),
(2, 1, 6, '2026-09-15 15:00:00', 'PENDIENTE', NULL, '2026-09-09 19:11:57'),
(3, 2, 5, '2026-09-16 09:00:00', 'REALIZADA', 'Visito con familia', '2026-09-09 19:11:57'),
(4, 3, 6, '2026-09-16 11:00:00', 'CONFIRMADA', NULL, '2026-09-09 19:11:57'),
(5, 4, 7, '2026-09-17 14:00:00', 'PENDIENTE', 'Consulta arriendo', '2026-09-09 19:11:57'),
(6, 5, 8, '2026-09-18 10:30:00', 'CANCELADA', 'Reprogramar', '2026-09-09 19:11:57'),
(7, 6, 9, '2026-09-18 16:00:00', 'CONFIRMADA', NULL, '2026-09-09 19:11:57'),
(8, 7, 7, '2026-09-19 08:00:00', 'REALIZADA', NULL, '2026-09-09 19:11:57'),
(9, 8, 8, '2026-09-19 17:00:00', 'PENDIENTE', 'Interes alto', '2026-09-09 19:11:57'),
(10, 10, 9, '2026-09-20 12:00:00', 'CONFIRMADA', 'Cliente premium', '2026-09-09 19:11:57'),
(11, 10, 10, '2026-09-21 12:00:00', 'PENDIENTE', NULL, '2026-09-09 19:11:57'),
(12, 12, 11, '2026-09-22 09:30:00', 'PENDIENTE', 'Local para negocio', '2026-09-09 19:11:57');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `ciudad`
--

CREATE TABLE `ciudad` (
  `id_ciudad` int(11) NOT NULL,
  `nombre` varchar(60) NOT NULL,
  `departamento` varchar(60) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `ciudad`
--

INSERT INTO `ciudad` (`id_ciudad`, `nombre`, `departamento`) VALUES
(5, 'Barrancabermeja', 'Santander'),
(10, 'Barranquilla', 'Atlantico'),
(6, 'Bogota', 'Cundinamarca'),
(1, 'Bucaramanga', 'Santander'),
(8, 'Cali', 'Valle del Cauca'),
(9, 'Cucuta', 'Norte de Santander'),
(2, 'Floridablanca', 'Santander'),
(3, 'Giron', 'Santander'),
(7, 'Medellin', 'Antioquia'),
(4, 'Piedecuesta', 'Santander');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `documento_solicitud`
--

CREATE TABLE `documento_solicitud` (
  `id_documento` int(11) NOT NULL,
  `id_solicitud` int(11) NOT NULL,
  `nombre` varchar(120) NOT NULL,
  `url` varchar(255) NOT NULL,
  `estado` enum('PENDIENTE','ACEPTADO','RECHAZADO') NOT NULL DEFAULT 'PENDIENTE',
  `fecha_carga` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `documento_solicitud`
--

INSERT INTO `documento_solicitud` (`id_documento`, `id_solicitud`, `nombre`, `url`, `estado`, `fecha_carga`) VALUES
(1, 1, 'Cedula.pdf', 'docs/1-cedula.pdf', 'ACEPTADO', '2026-09-09 19:11:57'),
(2, 1, 'Certificado laboral.pdf', 'docs/1-laboral.pdf', 'PENDIENTE', '2026-09-09 19:11:57'),
(3, 2, 'Cedula.pdf', 'docs/2-cedula.pdf', 'ACEPTADO', '2026-09-09 19:11:57'),
(4, 2, 'Extractos bancarios.pdf', 'docs/2-extractos.pdf', 'ACEPTADO', '2026-09-09 19:11:57'),
(5, 3, 'Cedula.pdf', 'docs/3-cedula.pdf', 'PENDIENTE', '2026-09-09 19:11:57'),
(6, 4, 'Contrato firmado.pdf', 'docs/4-contrato.pdf', 'ACEPTADO', '2026-09-09 19:11:57'),
(7, 5, 'Carta oferta.pdf', 'docs/5-oferta.pdf', 'RECHAZADO', '2026-09-09 19:11:57'),
(8, 6, 'Cedula.pdf', 'docs/6-cedula.pdf', 'PENDIENTE', '2026-09-09 19:11:57'),
(9, 7, 'Certificado ingresos.pdf', 'docs/7-ingresos.pdf', 'PENDIENTE', '2026-09-09 19:11:57'),
(10, 8, 'Cedula.pdf', 'docs/8-cedula.pdf', 'PENDIENTE', '2026-09-09 19:11:57'),
(11, 9, 'Promesa compraventa.pdf', 'docs/9-promesa.pdf', 'ACEPTADO', '2026-09-09 19:11:57'),
(12, 10, 'Camara comercio.pdf', 'docs/10-camara.pdf', 'PENDIENTE', '2026-09-09 19:11:57');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `favorito`
--

CREATE TABLE `favorito` (
  `id_usuario` int(11) NOT NULL,
  `id_propiedad` int(11) NOT NULL,
  `fecha_agregado` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `favorito`
--

INSERT INTO `favorito` (`id_usuario`, `id_propiedad`, `fecha_agregado`) VALUES
(6, 3, '2026-09-09 19:11:57'),
(6, 5, '2026-09-09 19:11:57'),
(7, 4, '2026-09-09 19:11:57'),
(7, 7, '2026-09-09 19:11:57'),
(8, 1, '2026-09-09 19:11:57'),
(8, 8, '2026-09-09 19:11:57'),
(9, 10, '2026-09-09 19:11:57'),
(10, 6, '2026-09-09 19:11:57'),
(11, 9, '2026-09-09 19:11:57');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `imagen_propiedad`
--

CREATE TABLE `imagen_propiedad` (
  `id_imagen` int(11) NOT NULL,
  `id_propiedad` int(11) NOT NULL,
  `url` varchar(255) NOT NULL,
  `es_portada` tinyint(1) NOT NULL DEFAULT 0,
  `orden` int(11) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `imagen_propiedad`
--

INSERT INTO `imagen_propiedad` (`id_imagen`, `id_propiedad`, `url`, `es_portada`, `orden`) VALUES
(1, 1, 'img/casa-barrio.jpg', 1, 1),
(2, 1, 'img/bucaramanga.jpg', 0, 2),
(3, 2, 'img/apartamento-cabecera.jpg', 1, 1),
(4, 2, 'img/apartamento-cacique.jpg', 0, 2),
(5, 3, 'img/apartamento-cacique.jpg', 1, 1),
(6, 4, 'img/apartamento-cabecera.jpg', 1, 1),
(7, 4, 'img/bucaramanga.jpg', 0, 2),
(8, 5, 'img/casa-barrio.jpg', 1, 1),
(9, 6, 'img/apartamento-cacique.jpg', 1, 1),
(10, 7, 'img/apartamento-cabecera.jpg', 1, 1),
(11, 8, 'img/casa-barrio.jpg', 1, 1),
(12, 8, 'img/bucaramanga.jpg', 0, 2),
(13, 9, 'img/bucaramanga.jpg', 1, 1),
(14, 10, 'img/apartamento-cacique.jpg', 1, 1),
(15, 11, 'img/apartamento-cabecera.jpg', 1, 1),
(16, 12, 'img/apartamento-cacique.jpg', 1, 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `inmobiliaria`
--

CREATE TABLE `inmobiliaria` (
  `id_inmobiliaria` int(11) NOT NULL,
  `id_usuario` int(11) NOT NULL,
  `nombre` varchar(120) NOT NULL,
  `nit` varchar(20) NOT NULL,
  `telefono` varchar(20) DEFAULT NULL,
  `direccion` varchar(150) DEFAULT NULL,
  `activo` tinyint(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `inmobiliaria`
--

INSERT INTO `inmobiliaria` (`id_inmobiliaria`, `id_usuario`, `nombre`, `nit`, `telefono`, `direccion`, `activo`) VALUES
(1, 2, 'Santander Raiz Norte', '900111001-1', '6076550001', 'Cra 33 # 45-10, Bucaramanga', 1),
(2, 3, 'Santander Raiz Sur', '900111002-2', '6076550002', 'Cll 200 # 20-30, Floridablanca', 1),
(3, 4, 'Santander Raiz Metro', '900111003-3', '6076550003', 'Cra 7 # 10-20, Giron', 1),
(4, 2, 'Inversiones Cabecera', '900111004-4', '6076550004', 'Cra 35 # 48-20, Bucaramanga', 1),
(5, 3, 'Habitat Floridablanca', '900111005-5', '6076550005', 'Cll 5 # 8-40, Floridablanca', 1),
(6, 4, 'Giron Propiedades', '900111006-6', '6076550006', 'Cra 25 # 30-10, Giron', 1),
(7, 2, 'Vivienda Piedecuesta', '900111007-7', '6076550007', 'Cll 6 # 9-15, Piedecuesta', 1),
(8, 3, 'Oriente Inmobiliario', '900111008-8', '6076550008', 'Cra 15 # 22-33, Bucaramanga', 1),
(9, 4, 'Metropolitana Bienes', '900111009-9', '6076550009', 'Cll 56 # 17-05, Bucaramanga', 1),
(10, 2, 'Capital Inmuebles', '900111010-0', '6076550010', 'Cra 27 # 52-18, Bucaramanga', 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `perfil`
--

CREATE TABLE `perfil` (
  `id_perfil` int(11) NOT NULL,
  `id_usuario` int(11) NOT NULL,
  `nombres` varchar(60) NOT NULL,
  `apellidos` varchar(60) NOT NULL,
  `documento` varchar(20) NOT NULL,
  `telefono` varchar(20) DEFAULT NULL,
  `direccion` varchar(150) DEFAULT NULL,
  `foto_url` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `perfil`
--

INSERT INTO `perfil` (`id_perfil`, `id_usuario`, `nombres`, `apellidos`, `documento`, `telefono`, `direccion`, `foto_url`) VALUES
(1, 1, 'Julian', 'Jaimes', '1098765432', '3001112233', 'Calle 9 # 23-55, Bucaramanga', NULL),
(2, 2, 'Marcela', 'Ortiz', '1098111222', '3002223344', 'Cra 33 # 45-10, Bucaramanga', NULL),
(3, 3, 'Ricardo', 'Nino', '1098333444', '3003334455', 'Cll 200 # 20-30, Floridablanca', NULL),
(4, 4, 'Sandra', 'Vega', '1098555666', '3004445566', 'Cra 7 # 10-20, Giron', NULL),
(5, 5, 'Juan David', 'Jaimes Herrera', '1192921022', '3011000111', 'Los alpesyork', NULL),
(6, 6, 'Diana', 'Gomez', '1095000222', '3011000222', 'Cra 15 # 30-40, Bucaramanga', NULL),
(7, 7, 'Jorge', 'Ruiz', '1095000333', '3011000333', 'Cll 105 # 25-11, Floridablanca', NULL),
(8, 8, 'Laura', 'Mora', '1095000444', '3011000444', 'Cra 5 # 8-19, Giron', NULL),
(9, 9, 'Andres', 'Silva', '1095000555', '3011000555', 'Cll 56 # 18-22, Bucaramanga', NULL),
(10, 10, 'Paola', 'Leon', '1095000666', '3011000666', 'Cra 27 # 52-30, Bucaramanga', NULL),
(11, 11, 'Mateo', 'Castro', '1095000777', '3011000777', 'Cll 90 # 40-15, Floridablanca', NULL),
(12, 12, 'Visitante', 'Demo', '1095000888', '3011000888', 'N/A', NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `propiedad`
--

CREATE TABLE `propiedad` (
  `id_propiedad` int(11) NOT NULL,
  `id_inmobiliaria` int(11) NOT NULL,
  `id_ciudad` int(11) NOT NULL,
  `id_tipo` int(11) NOT NULL,
  `matricula_inmobiliaria` varchar(30) NOT NULL,
  `titulo` varchar(150) NOT NULL,
  `descripcion` text DEFAULT NULL,
  `direccion` varchar(150) NOT NULL,
  `precio` decimal(15,2) NOT NULL,
  `operacion` enum('VENTA','ARRIENDO') NOT NULL DEFAULT 'VENTA',
  `area_m2` decimal(8,2) NOT NULL,
  `habitaciones` int(11) NOT NULL DEFAULT 0,
  `banos` int(11) NOT NULL DEFAULT 0,
  `parqueaderos` int(11) NOT NULL DEFAULT 0,
  `estado` enum('DISPONIBLE','RESERVADA','VENDIDA','ARRENDADA') NOT NULL DEFAULT 'DISPONIBLE',
  `activo` tinyint(1) NOT NULL DEFAULT 1,
  `fecha_publicacion` datetime NOT NULL DEFAULT current_timestamp()
) ;

--
-- Volcado de datos para la tabla `propiedad`
--

INSERT INTO `propiedad` (`id_propiedad`, `id_inmobiliaria`, `id_ciudad`, `id_tipo`, `matricula_inmobiliaria`, `titulo`, `descripcion`, `direccion`, `precio`, `operacion`, `area_m2`, `habitaciones`, `banos`, `parqueaderos`, `estado`, `activo`, `fecha_publicacion`) VALUES
(1, 1, 1, 1, 'MI-300-001', 'Casa moderna en el norte', 'Casa de 2 pisos, iluminada, patio interno', 'Calle 32 # 15-48, Bucaramanga', 420000000.00, 'VENTA', 180.00, 4, 3, 2, 'DISPONIBLE', 1, '2026-09-09 19:11:57'),
(2, 1, 1, 2, 'MI-300-002', 'Apartamento en Cabecera', 'Apto remodelado cerca a centros comerciales', 'Cra 35 # 48-12, Bucaramanga', 285000000.00, 'VENTA', 96.00, 3, 2, 1, 'DISPONIBLE', 1, '2026-09-09 19:11:57'),
(3, 2, 2, 3, 'MI-300-003', 'Local comercial en Florida', 'Local sobre via principal, alto flujo', 'Avenida 1 # 24-60, Floridablanca', 360000000.00, 'VENTA', 120.00, 0, 2, 4, 'DISPONIBLE', 1, '2026-09-09 19:11:57'),
(4, 3, 3, 2, 'MI-300-004', 'Apartamento vista parque', 'Vista abierta, conjunto con porteria', 'Diagonal 5 # 9-21, Giron', 245000000.00, 'ARRIENDO', 82.00, 2, 2, 1, 'DISPONIBLE', 1, '2026-09-09 19:11:57'),
(5, 2, 2, 1, 'MI-300-005', 'Casa familiar La Florida', 'Casa amplia en sector residencial', 'Sector La Florida, Floridablanca', 530000000.00, 'VENTA', 210.00, 5, 4, 3, 'DISPONIBLE', 1, '2026-09-09 19:11:57'),
(6, 4, 1, 4, 'MI-300-006', 'Oficina centro empresarial', 'Oficina con divisiones y sala de juntas', 'Centro Empresarial, Bucaramanga', 390000000.00, 'ARRIENDO', 160.00, 0, 3, 4, 'DISPONIBLE', 1, '2026-09-09 19:11:57'),
(7, 5, 2, 2, 'MI-300-007', 'Apartamento estudio economico', 'Apartamento de una alcoba, ideal para estudiantes, amoblado', 'Cll 5 # 8-40, Floridablanca', 95000000.00, 'ARRIENDO', 35.00, 1, 1, 0, 'DISPONIBLE', 1, '2026-09-09 19:11:57'),
(8, 6, 3, 1, 'MI-300-008', 'Casa campestre Giron', 'Casa con jardin amplio y zona BBQ', 'Vereda Acapulco, Giron', 610000000.00, 'VENTA', 260.00, 4, 3, 2, 'RESERVADA', 1, '2026-09-09 19:11:57'),
(9, 7, 4, 5, 'MI-300-009', 'Lote urbano Piedecuesta', 'Terreno plano listo para construir', 'Cll 6 # 9-15, Piedecuesta', 180000000.00, 'VENTA', 300.00, 0, 0, 0, 'DISPONIBLE', 1, '2026-09-09 19:11:57'),
(10, 8, 1, 2, 'MI-300-010', 'Apartamento penthouse El Prado', 'Ultimo piso con terraza y jacuzzi', 'Cra 15 # 22-33, Bucaramanga', 890000000.00, 'VENTA', 220.00, 3, 4, 3, 'DISPONIBLE', 1, '2026-09-09 19:11:57'),
(11, 9, 1, 2, 'MI-300-011', 'Apartamento Real de Minas', 'Apto 3 alcobas, conjunto cerrado', 'Cll 56 # 17-05, Bucaramanga', 260000000.00, 'VENTA', 88.00, 3, 2, 1, 'VENDIDA', 1, '2026-09-09 19:11:57'),
(12, 10, 1, 3, 'MI-300-012', 'Local Cabecera cuarta etapa', 'Local esquinero con vitrina', 'Cra 27 # 52-18, Bucaramanga', 320000000.00, 'ARRIENDO', 75.00, 0, 1, 1, 'DISPONIBLE', 1, '2026-09-09 19:11:57'),
(13, 1, 1, 1, 'H92-222', 'Casa', 'casa en bucaramanga', 'Tv 10 #19-19 la colina', 300000000.00, 'VENTA', 70.00, 2, 2, 1, 'DISPONIBLE', 1, '2026-09-11 21:11:01');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `propiedad_caracteristica`
--

CREATE TABLE `propiedad_caracteristica` (
  `id_propiedad` int(11) NOT NULL,
  `id_caracteristica` int(11) NOT NULL,
  `cantidad` int(11) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `propiedad_caracteristica`
--

INSERT INTO `propiedad_caracteristica` (`id_propiedad`, `id_caracteristica`, `cantidad`) VALUES
(1, 2, 2),
(1, 7, 1),
(1, 10, 1),
(2, 2, 1),
(2, 3, 1),
(2, 5, 1),
(2, 6, 1),
(3, 2, 4),
(3, 9, 2),
(4, 2, 1),
(4, 5, 1),
(4, 6, 1),
(5, 1, 1),
(5, 2, 3),
(5, 7, 1),
(5, 10, 1),
(6, 2, 4),
(6, 3, 1),
(6, 9, 3),
(8, 1, 1),
(8, 7, 1),
(8, 10, 1),
(10, 1, 1),
(10, 3, 1),
(10, 4, 1),
(10, 5, 1),
(10, 6, 1);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `rol`
--

CREATE TABLE `rol` (
  `id_rol` int(11) NOT NULL,
  `nombre` varchar(30) NOT NULL,
  `descripcion` varchar(150) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `rol`
--

INSERT INTO `rol` (`id_rol`, `nombre`, `descripcion`) VALUES
(1, 'ADMIN', 'Acceso total: usuarios, roles, catalogos y auditoria'),
(2, 'INMOBILIARIA', 'Agente: publica y administra sus propiedades y solicitudes'),
(3, 'CLIENTE', 'Busca propiedades, agenda citas y radica solicitudes'),
(4, 'VISITANTE', 'Usuario registrado sin privilegios adicionales');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `solicitud`
--

CREATE TABLE `solicitud` (
  `id_solicitud` int(11) NOT NULL,
  `id_propiedad` int(11) NOT NULL,
  `id_cliente` int(11) NOT NULL,
  `tipo` enum('COMPRA','ARRIENDO') NOT NULL,
  `estado` enum('RADICADA','EN_REVISION','APROBADA','RECHAZADA') NOT NULL DEFAULT 'RADICADA',
  `oferta` decimal(15,2) DEFAULT NULL,
  `comentario` varchar(255) DEFAULT NULL,
  `fecha_radicacion` datetime NOT NULL DEFAULT current_timestamp(),
  `fecha_resolucion` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `solicitud`
--

INSERT INTO `solicitud` (`id_solicitud`, `id_propiedad`, `id_cliente`, `tipo`, `estado`, `oferta`, `comentario`, `fecha_radicacion`, `fecha_resolucion`) VALUES
(1, 1, 5, 'COMPRA', 'APROBADA', 410000000.00, 'Oferta sujeta a credito', '2026-09-09 19:11:57', '2026-09-11 21:09:46'),
(2, 2, 6, 'COMPRA', 'APROBADA', 285000000.00, 'Pago de contado', '2026-09-09 19:11:57', '2026-09-05 10:00:00'),
(3, 3, 6, 'ARRIENDO', 'RADICADA', NULL, 'Solicita canon mensual', '2026-09-09 19:11:57', NULL),
(4, 4, 7, 'ARRIENDO', 'APROBADA', 2500000.00, 'Contrato 12 meses', '2026-09-09 19:11:57', '2026-09-06 09:00:00'),
(5, 5, 8, 'COMPRA', 'RECHAZADA', 480000000.00, 'Oferta muy baja', '2026-09-09 19:11:57', '2026-09-07 16:00:00'),
(6, 7, 7, 'ARRIENDO', 'EN_REVISION', 1200000.00, NULL, '2026-09-09 19:11:57', NULL),
(7, 8, 8, 'COMPRA', 'RADICADA', 600000000.00, 'Pendiente documentos', '2026-09-09 19:11:57', NULL),
(8, 10, 9, 'COMPRA', 'EN_REVISION', 870000000.00, 'Solicita avaluo', '2026-09-09 19:11:57', NULL),
(9, 11, 10, 'COMPRA', 'APROBADA', 260000000.00, 'Negocio cerrado', '2026-09-09 19:11:57', '2026-09-08 11:00:00'),
(10, 12, 11, 'ARRIENDO', 'RADICADA', NULL, 'Local comercial', '2026-09-09 19:11:57', NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tipo_propiedad`
--

CREATE TABLE `tipo_propiedad` (
  `id_tipo` int(11) NOT NULL,
  `nombre` varchar(40) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `tipo_propiedad`
--

INSERT INTO `tipo_propiedad` (`id_tipo`, `nombre`) VALUES
(2, 'Apartamento'),
(1, 'Casa'),
(3, 'Local'),
(4, 'Oficina'),
(5, 'Terreno');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuario`
--

CREATE TABLE `usuario` (
  `id_usuario` int(11) NOT NULL,
  `correo` varchar(120) NOT NULL,
  `password_hash` varchar(100) NOT NULL,
  `activo` tinyint(1) NOT NULL DEFAULT 1,
  `intentos_fallidos` int(11) NOT NULL DEFAULT 0,
  `bloqueado_hasta` datetime DEFAULT NULL,
  `fecha_registro` datetime NOT NULL DEFAULT current_timestamp(),
  `ultimo_acceso` datetime DEFAULT NULL
) ;

--
-- Volcado de datos para la tabla `usuario`
--

INSERT INTO `usuario` (`id_usuario`, `correo`, `password_hash`, `activo`, `intentos_fallidos`, `bloqueado_hasta`, `fecha_registro`, `ultimo_acceso`) VALUES
(1, 'admin@inmobiliaria.com', 'pbkdf2$120000$ld2eN+puBNPJCrKIU+cybw==$SgJkcar3b4h8bbk84NQZ/RLdfJTL5QkNOM66f7WW/QQ=', 1, 0, NULL, '2026-09-09 19:11:57', '2026-09-11 21:40:41'),
(2, 'agente.norte@sraiz.com', 'pbkdf2$120000$fT0cr1O19/PmT353U3qa5w==$AWj2aLHY3wHqLoK4twAWk80Wez6kiEuoqNtNmubp9yY=', 1, 0, NULL, '2026-09-09 19:11:57', '2026-09-11 22:05:36'),
(3, 'agente.sur@sraiz.com', 'pbkdf2$120000$NvohGIow2sI+JbD20BogvQ==$J9wpGS5qO9iM+YX1mAXMCui3Px2S3orY4Ku9gfwBICs=', 1, 0, NULL, '2026-09-09 19:11:57', '2026-09-11 21:08:38'),
(4, 'agente.metro@sraiz.com', 'pbkdf2$120000$oDsGtnAYsm5oeDuxg4d0Og==$/TzfJL5AD2dgmpjKr3iA0V2L/6XvDZNDo3J02pQ3uCc=', 1, 0, NULL, '2026-09-09 19:11:57', NULL),
(5, 'carlos.perez@gmail.com', 'pbkdf2$120000$8Cvfr4KEuQWQRarDeTPCxA==$+DjcVzbFKaCmtIiO9yd2ehkpyDCmBNHojg4UWf7leuI=', 1, 0, NULL, '2026-09-09 19:11:57', '2026-09-11 22:21:55'),
(6, 'diana.gomez@gmail.com', 'pbkdf2$120000$hTXFmtr1YGG5nu/tdnv0lQ==$A6hTfX6XR83LyItbccNHhnr7MMqAd6LlLe2Jw+CnP7E=', 1, 0, NULL, '2026-09-09 19:11:57', '2026-09-11 20:37:39'),
(7, 'jorge.ruiz@gmail.com', 'pbkdf2$120000$ev+77AhFK4d9g8P6gCwKBQ==$JbW57AzLLF9Pb5S8gJWG7mgNomNKZVon/KXMLbhOqvQ=', 1, 0, NULL, '2026-09-09 19:11:57', NULL),
(8, 'laura.mora@gmail.com', 'pbkdf2$120000$faKngYfHJUxdneWWEzc40w==$w2GWHpZiXtjokgzb6H5cwmGHmSlTHRmesj9UOODzgek=', 1, 0, NULL, '2026-09-09 19:11:57', NULL),
(9, 'andres.silva@gmail.com', 'pbkdf2$120000$JoaOCWtfObbTQMprFXuE2Q==$FkJVpV2E3lA9GNLjYpGC6T9sTfiYCTUlyzCZWzQ1mNU=', 1, 0, NULL, '2026-09-09 19:11:57', NULL),
(10, 'paola.leon@gmail.com', 'pbkdf2$120000$J/DFGZP0EvY5+/MatrHpsg==$KApv6wg8h5t4SOd5I2zVGe4G8/mC3zHYTMfuR/idxAU=', 1, 0, NULL, '2026-09-09 19:11:57', NULL),
(11, 'mateo.castro@gmail.com', 'pbkdf2$120000$I6thHdkCyxKxnqGTBXtVwQ==$8qBvZo0PxgYaGIs5qa8tUkxm6W1jq3mS4Jd4yL7DnSU=', 1, 0, NULL, '2026-09-09 19:11:57', NULL),
(12, 'visitante@correo.com', 'pbkdf2$120000$S9l62UnhuzwprLiRGkcgCg==$wM7fV+R2KG6qM5a0rJIrJmxsoepsCnd6smetuoQBROc=', 1, 0, NULL, '2026-09-09 19:11:57', NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuario_rol`
--

CREATE TABLE `usuario_rol` (
  `id_usuario` int(11) NOT NULL,
  `id_rol` int(11) NOT NULL,
  `fecha_asignacion` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `usuario_rol`
--

INSERT INTO `usuario_rol` (`id_usuario`, `id_rol`, `fecha_asignacion`) VALUES
(1, 1, '2026-09-11 20:36:22'),
(2, 2, '2026-09-09 19:11:57'),
(3, 2, '2026-09-09 19:11:57'),
(4, 2, '2026-09-09 19:11:57'),
(5, 3, '2026-09-09 19:11:57'),
(5, 4, '2026-09-09 19:11:57'),
(6, 3, '2026-09-09 19:11:57'),
(7, 3, '2026-09-09 19:11:57'),
(8, 3, '2026-09-09 19:11:57'),
(9, 3, '2026-09-09 19:11:57'),
(10, 3, '2026-09-09 19:11:57'),
(11, 3, '2026-09-09 19:11:57'),
(12, 4, '2026-09-09 19:11:57');

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `auditoria`
--
ALTER TABLE `auditoria`
  ADD PRIMARY KEY (`id_auditoria`),
  ADD KEY `fk_auditoria_usuario` (`id_usuario`),
  ADD KEY `idx_auditoria_fecha` (`fecha`);

--
-- Indices de la tabla `caracteristica`
--
ALTER TABLE `caracteristica`
  ADD PRIMARY KEY (`id_caracteristica`),
  ADD UNIQUE KEY `uq_caracteristica` (`nombre`);

--
-- Indices de la tabla `cita`
--
ALTER TABLE `cita`
  ADD PRIMARY KEY (`id_cita`),
  ADD UNIQUE KEY `uq_cita_propiedad_horario` (`id_propiedad`,`fecha_hora`),
  ADD KEY `fk_cita_cliente` (`id_cliente`),
  ADD KEY `idx_cita_estado` (`estado`);

--
-- Indices de la tabla `ciudad`
--
ALTER TABLE `ciudad`
  ADD PRIMARY KEY (`id_ciudad`),
  ADD UNIQUE KEY `uq_ciudad` (`nombre`,`departamento`);

--
-- Indices de la tabla `documento_solicitud`
--
ALTER TABLE `documento_solicitud`
  ADD PRIMARY KEY (`id_documento`),
  ADD KEY `fk_documento_solicitud` (`id_solicitud`);

--
-- Indices de la tabla `favorito`
--
ALTER TABLE `favorito`
  ADD PRIMARY KEY (`id_usuario`,`id_propiedad`),
  ADD KEY `fk_favorito_propiedad` (`id_propiedad`);

--
-- Indices de la tabla `imagen_propiedad`
--
ALTER TABLE `imagen_propiedad`
  ADD PRIMARY KEY (`id_imagen`),
  ADD KEY `fk_imagen_propiedad` (`id_propiedad`);

--
-- Indices de la tabla `inmobiliaria`
--
ALTER TABLE `inmobiliaria`
  ADD PRIMARY KEY (`id_inmobiliaria`),
  ADD UNIQUE KEY `uq_inmobiliaria_nit` (`nit`),
  ADD KEY `fk_inmobiliaria_usuario` (`id_usuario`);

--
-- Indices de la tabla `perfil`
--
ALTER TABLE `perfil`
  ADD PRIMARY KEY (`id_perfil`),
  ADD UNIQUE KEY `uq_perfil_id_usuario` (`id_usuario`),
  ADD UNIQUE KEY `uq_perfil_documento` (`documento`);

--
-- Indices de la tabla `propiedad`
--
ALTER TABLE `propiedad`
  ADD PRIMARY KEY (`id_propiedad`),
  ADD UNIQUE KEY `uq_propiedad_matricula` (`matricula_inmobiliaria`),
  ADD KEY `fk_propiedad_inmobiliaria` (`id_inmobiliaria`),
  ADD KEY `idx_propiedad_ciudad` (`id_ciudad`),
  ADD KEY `idx_propiedad_tipo` (`id_tipo`),
  ADD KEY `idx_propiedad_precio` (`precio`),
  ADD KEY `idx_propiedad_estado` (`estado`);

--
-- Indices de la tabla `propiedad_caracteristica`
--
ALTER TABLE `propiedad_caracteristica`
  ADD PRIMARY KEY (`id_propiedad`,`id_caracteristica`),
  ADD KEY `fk_pc_caracteristica` (`id_caracteristica`);

--
-- Indices de la tabla `rol`
--
ALTER TABLE `rol`
  ADD PRIMARY KEY (`id_rol`),
  ADD UNIQUE KEY `uq_rol_nombre` (`nombre`);

--
-- Indices de la tabla `solicitud`
--
ALTER TABLE `solicitud`
  ADD PRIMARY KEY (`id_solicitud`),
  ADD KEY `fk_solicitud_propiedad` (`id_propiedad`),
  ADD KEY `fk_solicitud_cliente` (`id_cliente`),
  ADD KEY `idx_solicitud_estado` (`estado`);

--
-- Indices de la tabla `tipo_propiedad`
--
ALTER TABLE `tipo_propiedad`
  ADD PRIMARY KEY (`id_tipo`),
  ADD UNIQUE KEY `uq_tipo_propiedad` (`nombre`);

--
-- Indices de la tabla `usuario`
--
ALTER TABLE `usuario`
  ADD PRIMARY KEY (`id_usuario`),
  ADD UNIQUE KEY `uq_usuario_correo` (`correo`);

--
-- Indices de la tabla `usuario_rol`
--
ALTER TABLE `usuario_rol`
  ADD PRIMARY KEY (`id_usuario`,`id_rol`),
  ADD KEY `fk_ur_rol` (`id_rol`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `auditoria`
--
ALTER TABLE `auditoria`
  MODIFY `id_auditoria` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=111;

--
-- AUTO_INCREMENT de la tabla `caracteristica`
--
ALTER TABLE `caracteristica`
  MODIFY `id_caracteristica` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT de la tabla `cita`
--
ALTER TABLE `cita`
  MODIFY `id_cita` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT de la tabla `ciudad`
--
ALTER TABLE `ciudad`
  MODIFY `id_ciudad` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT de la tabla `documento_solicitud`
--
ALTER TABLE `documento_solicitud`
  MODIFY `id_documento` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT de la tabla `imagen_propiedad`
--
ALTER TABLE `imagen_propiedad`
  MODIFY `id_imagen` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;

--
-- AUTO_INCREMENT de la tabla `inmobiliaria`
--
ALTER TABLE `inmobiliaria`
  MODIFY `id_inmobiliaria` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT de la tabla `perfil`
--
ALTER TABLE `perfil`
  MODIFY `id_perfil` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT de la tabla `propiedad`
--
ALTER TABLE `propiedad`
  MODIFY `id_propiedad` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `rol`
--
ALTER TABLE `rol`
  MODIFY `id_rol` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de la tabla `solicitud`
--
ALTER TABLE `solicitud`
  MODIFY `id_solicitud` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT de la tabla `tipo_propiedad`
--
ALTER TABLE `tipo_propiedad`
  MODIFY `id_tipo` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT de la tabla `usuario`
--
ALTER TABLE `usuario`
  MODIFY `id_usuario` int(11) NOT NULL AUTO_INCREMENT;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `auditoria`
--
ALTER TABLE `auditoria`
  ADD CONSTRAINT `fk_auditoria_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`id_usuario`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Filtros para la tabla `cita`
--
ALTER TABLE `cita`
  ADD CONSTRAINT `fk_cita_cliente` FOREIGN KEY (`id_cliente`) REFERENCES `usuario` (`id_usuario`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_cita_propiedad` FOREIGN KEY (`id_propiedad`) REFERENCES `propiedad` (`id_propiedad`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `documento_solicitud`
--
ALTER TABLE `documento_solicitud`
  ADD CONSTRAINT `fk_documento_solicitud` FOREIGN KEY (`id_solicitud`) REFERENCES `solicitud` (`id_solicitud`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `favorito`
--
ALTER TABLE `favorito`
  ADD CONSTRAINT `fk_favorito_propiedad` FOREIGN KEY (`id_propiedad`) REFERENCES `propiedad` (`id_propiedad`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_favorito_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`id_usuario`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `imagen_propiedad`
--
ALTER TABLE `imagen_propiedad`
  ADD CONSTRAINT `fk_imagen_propiedad` FOREIGN KEY (`id_propiedad`) REFERENCES `propiedad` (`id_propiedad`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `inmobiliaria`
--
ALTER TABLE `inmobiliaria`
  ADD CONSTRAINT `fk_inmobiliaria_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`id_usuario`) ON UPDATE CASCADE;

--
-- Filtros para la tabla `perfil`
--
ALTER TABLE `perfil`
  ADD CONSTRAINT `fk_perfil_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`id_usuario`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `propiedad`
--
ALTER TABLE `propiedad`
  ADD CONSTRAINT `fk_propiedad_ciudad` FOREIGN KEY (`id_ciudad`) REFERENCES `ciudad` (`id_ciudad`) ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_propiedad_inmobiliaria` FOREIGN KEY (`id_inmobiliaria`) REFERENCES `inmobiliaria` (`id_inmobiliaria`) ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_propiedad_tipo` FOREIGN KEY (`id_tipo`) REFERENCES `tipo_propiedad` (`id_tipo`) ON UPDATE CASCADE;

--
-- Filtros para la tabla `propiedad_caracteristica`
--
ALTER TABLE `propiedad_caracteristica`
  ADD CONSTRAINT `fk_pc_caracteristica` FOREIGN KEY (`id_caracteristica`) REFERENCES `caracteristica` (`id_caracteristica`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_pc_propiedad` FOREIGN KEY (`id_propiedad`) REFERENCES `propiedad` (`id_propiedad`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `solicitud`
--
ALTER TABLE `solicitud`
  ADD CONSTRAINT `fk_solicitud_cliente` FOREIGN KEY (`id_cliente`) REFERENCES `usuario` (`id_usuario`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_solicitud_propiedad` FOREIGN KEY (`id_propiedad`) REFERENCES `propiedad` (`id_propiedad`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Filtros para la tabla `usuario_rol`
--
ALTER TABLE `usuario_rol`
  ADD CONSTRAINT `fk_ur_rol` FOREIGN KEY (`id_rol`) REFERENCES `rol` (`id_rol`) ON UPDATE CASCADE,
  ADD CONSTRAINT `fk_ur_usuario` FOREIGN KEY (`id_usuario`) REFERENCES `usuario` (`id_usuario`) ON DELETE CASCADE ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
