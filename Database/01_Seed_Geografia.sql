USE [DB_TornilloFlojo];
GO


PRINT 'Insertando Departamentos...';
INSERT INTO departamento (id, nombre) VALUES
(1, 'Boaco'),
(2, 'Carazo'),
(3, 'Chinandega'),
(4, 'Chontales'),
(5, 'Esteli'),
(6, 'Granada'),
(7, 'Jinotega'),
(8, 'Leon'),
(9, 'Madriz'),
(10, 'Managua'),
(11, 'Masaya'),
(12, 'Matagalpa'),
(13, 'Nueva Segovia'),
(14, 'Rio San Juan'),
(15, 'Rivas');
GO

PRINT 'Insertando Municipios...';
INSERT INTO municipio (id, nombre, id_dep) VALUES
(1, 'Boaco', 1),
(2, 'Camoapa', 1),
(3, 'Teustepe', 1),
(4, 'San Lorenzo', 1),
(5, 'Santa Lucía', 1),

(6, 'Jinotepe', 2),
(7, 'Diriamba', 2),
(8, 'San Marcos', 2),
(9, 'Santa Teresa', 2),
(10, 'Dolores', 2),

(11, 'Chinandega', 3),
(12, 'Corinto', 3),
(13, 'El Viejo', 3),
(14, 'Somotillo', 3),
(15, 'Chichigalpa', 3),

(16, 'Juigalpa', 4),
(17, 'Acoyapa', 4),
(18, 'Santo Tomás', 4),
(19, 'Villa Sandino', 4),
(20, 'Comalapa', 4),

(21, 'Esteli', 5),
(22, 'Condega', 5),
(23, 'Pueblo Nuevo', 5),
(24, 'La Trinidad', 5),
(25, 'San Nicolas', 5),

(26, 'Granada', 6),
(27, 'Nandaime', 6),
(28, 'Diriá', 6),
(29, 'Diriomo', 6),
(30, 'Malacatoya', 6),

(31, 'Jinotega', 7),
(32, 'San Rafael del Norte', 7),
(33, 'La Concordia', 7),
(34, 'Wiwilí de Jinotega', 7),
(35, 'El Cuá', 7),

(36, 'Leon', 8),
(37, 'Nagarote', 8),
(38, 'La Paz Centro', 8),
(39, 'Telica', 8),
(40, 'El Sauce', 8),

(41, 'Somoto', 9),
(42, 'Totogalpa', 9),
(43, 'Yalagüina', 9),
(44, 'Palacagüina', 9),
(45, 'San Juan de Río Coco', 9),

(46, 'Managua', 10),
(47, 'Tipitapa', 10),
(48, 'Ciudad Sandino', 10),
(49, 'San Rafael del Sur', 10),
(50, 'El Crucero', 10),

(51, 'Masaya', 11),
(52, 'Nindirí', 11),
(53, 'Catarina', 11),
(54, 'Masatepe', 11),
(55, 'Niquinohomo', 11),

(56, 'Matagalpa', 12),
(57, 'Sébaco', 12),
(58, 'San Ramón', 12),
(59, 'Ciudad Darío', 12),
(60, 'Matiguás', 12),

(61, 'Ocotal', 13),
(62, 'Jalapa', 13),
(63, 'Quilalí', 13),
(64, 'Dipilto', 13),
(65, 'Wiwilí de Nueva Segovia', 13),

(66, 'San Carlos', 14),
(67, 'El Castillo', 14),
(68, 'San Juan del Norte', 14),
(69, 'Morrito', 14),
(70, 'El Almendro', 14),

(71, 'Rivas', 15),
(72, 'San Juan del Sur', 15),
(73, 'Tola', 15),
(74, 'Cárdenas', 15),
(75, 'Moyogalpa', 15);
GO

PRINT 'Carga de datos de geografía completada exitosamente.';
