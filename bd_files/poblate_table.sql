INSERT INTO PERSONA (nro_dni, nombre, apellido) VALUES
(20123456, 'Maite', 'Nigger'),
(22111222, 'Franchota', 'Corta'),
(30123456, 'Franco', 'Lanzichota'),
(31111222, 'Franco', 'Cum'),
(32123456, 'Tomas', 'Turbado'),
(76856456, 'Benito', 'Camela'),
(54654643, 'Francisco', 'Vergon'),
(23467543, 'Elsa', 'Pito');


INSERT INTO USUARIO (username, password, puede_mod_guardia, nro_dni) VALUES
('postgres', 'postgres', TRUE, 20123456),
('secretaria', '1234', FALSE, 22111222);

INSERT INTO PACIENTE (nro_dni, sexo, fecha_nac) VALUES
(30123456, 'F', '1985-03-10'),
(31111222, 'M', '1977-11-22'),
(32123456, 'F', '1999-07-05');

INSERT INTO MEDICO (nro_matricula, fecha_ingreso, foto, cuil, cuit, nro_dni) VALUES
(1001, '2015-01-01', decode('DEADBEEF','hex'), 20768564563, 20768564563, 76856456),
(1002, '2012-05-10', decode('DEADBEEF','hex'), 23546546433, 23546546433, 54654643),
(1003, '2015-01-03', decode('DEADBEEF','hex'), 20234675433, 20234675433, 23467543);

INSERT INTO ESPECIALIDAD (nombre) VALUES
('Clínica Médica'),
('Pediatría'),
('Cardiología');

INSERT INTO MED_TIENE_ESP (id_especialidad, nro_matricula, max_cant_guardia) VALUES
(1, 1001, 20),
(3, 1002, 15),
(2, 1003, 10);

INSERT INTO TURNOGUARDIA (hora_inicio, hora_fin) VALUES
('08:00', '14:00'),
('14:00', '20:00'),
('20:00', '08:00');

INSERT INTO GUARDIA (fecha, id_especialidad, nro_matricula) VALUES
('2025-11-10', 1, 1001),
('2025-11-11', 3, 1002),
('2025-12-06', 2, 1003);

INSERT INTO GUARDIA_TIENE_TURNOGUARDIA VALUES
(1, 1),
(1, 2),
(2, 2),
(3, 1);

INSERT INTO SECTOR (nombre_sector) VALUES
('Ala Norte'),
('Ala Sur');

INSERT INTO HABITACION (piso, orientacion, id_sector) VALUES
(1, 'N', 1),
(2, 'S', 2);

INSERT INTO CAMA (id_cama, id_habitacion) VALUES
(1, 1),
(2, 1),
(1, 2),
(2, 2);

INSERT INTO INTERNACION (fecha_hora_inicio, fecha_hora_fin, nro_matricula, nro_dni) VALUES
('2025-11-18 08:00', NULL, 1001, 30123456),
('2025-11-17 10:00', NULL, 1002, 31111222),
('2025-11-10 09:00', '2025-11-12 13:00', 1003, 32123456);

INSERT INTO INTERNACION_CAMA VALUES
('2025-11-18 08:10', 1, 1, 1),
('2025-11-17 10:10', 2, 2, 1);

INSERT INTO RONDA (dia) VALUES ('L'), ('M');

INSERT INTO TURNORONDA (hora_inicio, hora_fin) VALUES
('09:00','11:00'),
('11:00','13:00');

INSERT INTO RONDA_TIENE_TURNORONDA VALUES
(1,1),
(1,2),
(2,1);

INSERT INTO RECORRIDO (fecha, id_ronda, nro_matricula) VALUES
('2025-11-18', 1, 1001),
('2025-11-17', 2, 1002);

INSERT INTO ROND_TIENE_HAB (id_ronda, id_habitacion) VALUES
(1, 2),
(2, 1);

INSERT INTO COMENTARIO (id_internacion, fecha_hora, descripcion, id_recorrido) VALUES
(1, '2020-11-18 10:00', 'Paciente estable.', 1),
(2, '2020-11-17 11:00', 'Dolor controlado.', 2);

INSERT INTO VACACION (nro_matricula, fecha_inicio, fecha_fin) VALUES
(1001, '2025-12-01', '2025-12-15'),
(1002, '2025-12-10', '2025-12-20'),
(1003, '2025-09-07', '2025-09-21');

INSERT INTO ESPECIALIDAD_TIENE_TURNOGUARDIA (id_especialidad, id_turno_guardia) VALUES
(1, 2),
(2, 1);