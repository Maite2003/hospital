DROP SCHEMA public CASCADE;
CREATE SCHEMA public;



-- ===========================================
-- CREACIÓN DE TABLAS BASE
-- ===========================================

CREATE TABLE PERSONA (
    nro_dni VARCHAR(8) PRIMARY KEY,
    CHECK (
        nro_dni BETWEEN '10000' AND '99999999'
    ),
    nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL
);

CREATE TABLE USUARIO (
    username VARCHAR(50) PRIMARY KEY,
    password VARCHAR(50) NOT NULL,
    puede_mod_guardia BOOLEAN DEFAULT FALSE,
    nro_dni VARCHAR(8) UNIQUE NOT NULL,
    FOREIGN KEY (nro_dni) REFERENCES PERSONA (nro_dni)
);

CREATE TABLE PACIENTE (
    nro_dni VARCHAR(8) PRIMARY KEY,
    sexo CHAR(1) CHECK (sexo IN ('M', 'F', 'X')),
    fecha_nac DATE NOT NULL,
    FOREIGN KEY (nro_dni) REFERENCES PERSONA (nro_dni)
);

CREATE TABLE MEDICO (
    nro_matricula VARCHAR(4) PRIMARY KEY,
    fecha_ingreso DATE NOT NULL,
    foto BYTEA NOT NULL,
    cuil VARCHAR(11) UNIQUE NOT NULL,
    cuit VARCHAR(11) UNIQUE NOT NULL,
    nro_dni VARCHAR(8) UNIQUE NOT NULL,
    FOREIGN KEY (nro_dni) REFERENCES PERSONA (nro_dni)
);

CREATE TABLE ESPECIALIDAD (
    id_especialidad SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE
);

-- ===========================================
-- RELACIONES DE MÉDICO Y ESPECIALIDAD
-- ===========================================

CREATE TABLE MED_TIENE_ESP (
    id_especialidad INT NOT NULL,
    nro_matricula VARCHAR(4) NOT NULL,
    max_cant_guardia INT,
    CHECK (
        max_cant_guardia BETWEEN 1 AND 90
    ),
    PRIMARY KEY (
        id_especialidad,
        nro_matricula
    ),
    FOREIGN KEY (id_especialidad) REFERENCES ESPECIALIDAD (id_especialidad),
    FOREIGN KEY (nro_matricula) REFERENCES MEDICO (nro_matricula)
);

-- ===========================================
-- GUARDIAS Y TURNOS
-- ===========================================

CREATE TABLE TURNOGUARDIA (
    id_turno_guardia SERIAL PRIMARY KEY,
    hora_inicio TIME NOT NULL,
    hora_fin TIME NOT NULL,
    CHECK (hora_fin <> hora_inicio),
    CONSTRAINT uq_horario_guardia UNIQUE (hora_inicio, hora_fin)
);

CREATE TABLE GUARDIA (
    id_guardia SERIAL PRIMARY KEY,
    fecha DATE NOT NULL,
    id_especialidad INT NOT NULL,
    nro_matricula VARCHAR(4) NOT NULL,
    FOREIGN KEY (
        id_especialidad,
        nro_matricula
    ) REFERENCES MED_TIENE_ESP (
        id_especialidad,
        nro_matricula
    )
);

CREATE TABLE GUARDIA_TIENE_TURNOGUARDIA (
    id_guardia INT NOT NULL,
    id_turno_guardia INT NOT NULL,
    PRIMARY KEY (id_guardia, id_turno_guardia),
    FOREIGN KEY (id_guardia) REFERENCES GUARDIA (id_guardia),
    FOREIGN KEY (id_turno_guardia) REFERENCES TURNOGUARDIA (id_turno_guardia)
);

CREATE TABLE ESPECIALIDAD_TIENE_TURNOGUARDIA (
    id_especialidad INT NOT NULL,
    id_turno_guardia INT NOT NULL,
    PRIMARY KEY (
        id_especialidad,
        id_turno_guardia
    ),
    FOREIGN KEY (id_especialidad) REFERENCES ESPECIALIDAD (id_especialidad),
    FOREIGN KEY (id_turno_guardia) REFERENCES TURNOGUARDIA (id_turno_guardia)
);

-- AGREGUE UN SERIAL PARA QUE NO HAYA CONFLICTOS EN LA PK
CREATE TABLE USUARIO_MODIFICA_GUARDIA (
    id_modificacion SERIAL,
    username VARCHAR(50) NOT NULL,
    id_guardia INT NOT NULL,
    fecha_hora TIMESTAMP NOT NULL,
    descripcion TEXT,
    PRIMARY KEY (id_modificacion, username, id_guardia),
    FOREIGN KEY (username) REFERENCES USUARIO (username),
    FOREIGN KEY (id_guardia) REFERENCES GUARDIA (id_guardia)
);

-- ===========================================
-- TURNOS DE RONDA Y RONDAS
-- ===========================================

CREATE TABLE TURNORONDA (
    id_turno_ronda SERIAL PRIMARY KEY,
    hora_inicio TIME NOT NULL,
    hora_fin TIME NOT NULL,
    CHECK (hora_fin > hora_inicio),
    CONSTRAINT uq_horario_ronda UNIQUE (hora_inicio, hora_fin)
);

CREATE TABLE RONDA (
    id_ronda SERIAL PRIMARY KEY,
    dia CHAR(1) NOT NULL,
    CHECK (
        dia IN (
            'L',
            'M',
            'X',
            'J',
            'V',
            'S',
            'D'
        )
    )
);

CREATE TABLE RONDA_TIENE_TURNORONDA (
    id_ronda INT NOT NULL,
    id_turno_ronda INT NOT NULL,
    PRIMARY KEY (id_ronda, id_turno_ronda),
    FOREIGN KEY (id_ronda) REFERENCES RONDA (id_ronda),
    FOREIGN KEY (id_turno_ronda) REFERENCES TURNORONDA (id_turno_ronda)
);

-- ===========================================
-- RECURSOS HOSPITALARIOS: SECTOR, HABITACION, CAMA
-- ===========================================

CREATE TABLE SECTOR (
    id_sector SERIAL PRIMARY KEY,
    nombre_sector VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE HABITACION (
    id_habitacion SERIAL PRIMARY KEY,
    piso INT NOT NULL,
    CHECK (piso >= 0),
    orientacion CHAR(1) NOT NULL,
    CHECK (
        orientacion IN ('N', 'S', 'E', 'O')
    ),
    id_sector INT NOT NULL,
    FOREIGN KEY (id_sector) REFERENCES SECTOR (id_sector)
);

-- SE MODIFICO AHORA ID_CAMA NO ES SERIAL. COMO ESTABA DECLARADO ANTES
-- ID_CAMA ERA SERIAL GLOBAL DE LA TABLA CAMA, NO POR HABITACION.
CREATE TABLE CAMA (
    id_cama INT,
    id_habitacion INT NOT NULL,
    esta_libre BOOLEAN DEFAULT TRUE NOT NULL,
    PRIMARY KEY (id_cama, id_habitacion),
    FOREIGN KEY (id_habitacion) REFERENCES HABITACION (id_habitacion)
);

-- ===========================================
-- INTERNACIONES Y RELACIONES
-- ===========================================

CREATE TABLE INTERNACION (
    id_internacion SERIAL PRIMARY KEY,
    fecha_hora_inicio TIMESTAMP NOT NULL,
    fecha_hora_fin TIMESTAMP,
    CHECK (
        fecha_hora_fin IS NULL
        OR fecha_hora_fin > fecha_hora_inicio
    ),
    nro_matricula VARCHAR(4) NOT NULL,
    nro_dni VARCHAR(8) NOT NULL,
    FOREIGN KEY (nro_matricula) REFERENCES MEDICO (nro_matricula),
    FOREIGN KEY (nro_dni) REFERENCES PACIENTE (nro_dni)
);

CREATE TABLE INTERNACION_CAMA (
    fecha_hora_asignacion TIMESTAMP NOT NULL,
    id_internacion INT NOT NULL,
    id_habitacion INT NOT NULL,
    id_cama INT NOT NULL,
    PRIMARY KEY (
        fecha_hora_asignacion,
        id_internacion,
        id_cama,
        id_habitacion
    ),
    FOREIGN KEY (id_internacion) REFERENCES INTERNACION (id_internacion),
    FOREIGN KEY (id_cama, id_habitacion) REFERENCES CAMA (id_cama, id_habitacion)
);

-- ===========================================
-- RONDAS Y RECORRIDOS
-- ===========================================

CREATE TABLE RECORRIDO (
    id_recorrido SERIAL PRIMARY KEY,
    fecha DATE NOT NULL,
    id_ronda INT NOT NULL,
    nro_matricula VARCHAR(4) NOT NULL,
    FOREIGN KEY (id_ronda) REFERENCES RONDA (id_ronda),
    FOREIGN KEY (nro_matricula) REFERENCES MEDICO (nro_matricula)
);

CREATE TABLE ROND_TIENE_HAB (
    id_ronda INT NOT NULL,
    id_habitacion INT NOT NULL,
    PRIMARY KEY (id_ronda, id_habitacion),
    FOREIGN KEY (id_ronda) REFERENCES RONDA (id_ronda),
    FOREIGN KEY (id_habitacion) REFERENCES HABITACION (id_habitacion)
);

-- ===========================================
-- COMENTARIOS
-- ===========================================

CREATE TABLE COMENTARIO (
    id_internacion INT NOT NULL,
    id_comentario SERIAL,
    fecha_hora TIMESTAMP NOT NULL DEFAULT CURRENT_DATE,
    CHECK (fecha_hora <= CURRENT_DATE), 
    descripcion TEXT,
    id_recorrido INT NOT NULL,
    PRIMARY KEY (id_internacion, id_comentario),
    FOREIGN KEY (id_internacion) REFERENCES INTERNACION (id_internacion),
    FOREIGN KEY (id_recorrido) REFERENCES RECORRIDO (id_recorrido)
);

-- ===========================================
-- VACACIONES DE MÉDICOS
-- ===========================================

CREATE TABLE VACACION (
    nro_matricula VARCHAR(4) NOT NULL,
    id_vacacion SERIAL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    CHECK (fecha_fin > fecha_inicio),
    PRIMARY KEY (nro_matricula, id_vacacion),
    FOREIGN KEY (nro_matricula) REFERENCES MEDICO (nro_matricula)
);


















-- ===========================================
-- LISTADO CAMAS DISPONIBLES
-- ===========================================

CREATE OR REPLACE FUNCTION listar_camas_libres()
RETURNS TABLE(
    id_habitacion INT,
    piso INT,
    orientacion CHAR,
    nombre_sector VARCHAR,
    id_cama INT,
    esta_libre BOOLEAN
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        h.id_habitacion,
        h.piso,
        h.orientacion,
        s.nombre_sector,
        c.id_cama,
        c.esta_libre
    FROM CAMA c
    JOIN HABITACION h ON c.id_habitacion = h.id_habitacion
    JOIN SECTOR s ON h.id_sector = s.id_sector
    ORDER BY s.nombre_sector, h.id_habitacion, c.id_cama;
END;
$$ LANGUAGE plpgsql;

-- ===========================================
-- LISTADO COMENTARIOS
-- ===========================================

CREATE OR REPLACE FUNCTION listar_comentarios_internacion(p_id_internacion INT)
RETURNS TABLE(
    id_internacion INT,
    fecha_hora_inicio_int TIMESTAMP,
    fecha_hora_fin_int TIMESTAMP,

    nro_dni VARCHAR(8),
    nombre VARCHAR,
    apellido VARCHAR,

    id_comentario INT,
    fecha_hora_comentario TIMESTAMP,
    descripcion TEXT,

    nro_matricula VARCHAR(4),
    nombre_doctor VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        i.id_internacion,
        i.fecha_hora_inicio,
        i.fecha_hora_fin,

        p.nro_dni,
        p.nombre,
        p.apellido,

        c.id_comentario,
        c.fecha_hora,
        c.descripcion,

        m.nro_matricula,
        per.nombre AS nombre_doctor
    FROM INTERNACION i
    JOIN PACIENTE pa ON pa.nro_dni = i.nro_dni
    JOIN PERSONA p ON p.nro_dni = pa.nro_dni
    JOIN COMENTARIO c ON c.id_internacion = i.id_internacion
    JOIN RECORRIDO r ON r.id_recorrido = c.id_recorrido
    JOIN MEDICO m ON m.nro_matricula = r.nro_matricula
    JOIN PERSONA per ON per.nro_dni = m.nro_dni
    WHERE i.id_internacion = p_id_internacion
    ORDER BY c.fecha_hora;
END;
$$ LANGUAGE plpgsql;

-- ===========================================
-- AUDITORIAS CAMBIO GUARDIAS
-- ===========================================

CREATE OR REPLACE FUNCTION listar_modificaciones_guardia()
RETURNS TABLE(
    username VARCHAR,
    id_guardia INT,
    fecha_hora_mod TIMESTAMP,
    descripcion TEXT,
    fecha_guardia DATE,
    especialidad VARCHAR,
    nro_matricula VARCHAR(4),
    nombre_medico VARCHAR,
    turnos JSON
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        umg.username,
        umg.id_guardia,
        umg.fecha_hora AS fecha_hora_mod,
        umg.descripcion,

        g.fecha AS fecha_guardia,
        e.nombre AS especialidad,
        m.nro_matricula,
        per.nombre AS nombre_medico,

        (
            SELECT json_agg(
                json_build_object(
                    'id_turno_guardia', tg.id_turno_guardia,
                    'hora_inicio', tg.hora_inicio,
                    'hora_fin', tg.hora_fin
                )
            )
            FROM GUARDIA_TIENE_TURNOGUARDIA gtg
            JOIN TURNOGUARDIA tg ON tg.id_turno_guardia = gtg.id_turno_guardia
            WHERE gtg.id_guardia = g.id_guardia
        ) AS turnos

    FROM USUARIO_MODIFICA_GUARDIA umg
    JOIN GUARDIA g ON g.id_guardia = umg.id_guardia
    JOIN MEDICO m ON m.nro_matricula = g.nro_matricula
    JOIN PERSONA per ON per.nro_dni = m.nro_dni
    JOIN ESPECIALIDAD e ON e.id_especialidad = g.id_especialidad

    ORDER BY umg.fecha_hora DESC;
END;
$$ LANGUAGE plpgsql;


















-- ===================================================================
-- Trigger para asignar automáticamente un id_cama único por habitación
-- al insertar una nueva cama sin especificar id_cama.
CREATE OR REPLACE FUNCTION asignar_id_cama()
RETURNS TRIGGER AS $$
DECLARE
    max_cama INT;
BEGIN
    IF NEW.id_cama IS NULL THEN
        SELECT COALESCE(MAX(id_cama), 0) + 1
        INTO max_cama
        FROM CAMA
        WHERE id_habitacion = NEW.id_habitacion;

        NEW.id_cama := max_cama;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_asignar_id_cama
BEFORE INSERT ON CAMA
FOR EACH ROW
EXECUTE FUNCTION asignar_id_cama();

-- ===================================================================
-- Triggers para registrar modificaciones en la tabla GUARDIA
-- Recibe el usuario actual y registra la operación (INSERT, UPDATE, DELETE)
-- en la tabla USUARIO_MODIFICA_GUARDIA con una descripción de la modificación.
CREATE OR REPLACE FUNCTION trg_registrar_modificacion_guardia_fn()
RETURNS TRIGGER AS $$
DECLARE
    v_username VARCHAR(50);
    v_descripcion TEXT;
BEGIN
    v_username := current_user;

    IF TG_OP = 'INSERT' THEN
        v_descripcion := 'Guardia creada: fecha=' || NEW.fecha ||
                         ', especialidad=' || NEW.id_especialidad ||
                         ', matricula=' || NEW.nro_matricula;

        INSERT INTO USUARIO_MODIFICA_GUARDIA (username, id_guardia, fecha_hora, descripcion)
        VALUES (v_username, NEW.id_guardia, NOW(), v_descripcion);

        RETURN NEW;

    ELSIF TG_OP = 'UPDATE' THEN
        v_descripcion := 'Guardia modificada: ' ||
                         'fecha=' || OLD.fecha || '→' || NEW.fecha ||
                         ', especialidad=' || OLD.id_especialidad || '→' || NEW.id_especialidad ||
                         ', matricula=' || OLD.nro_matricula || '→' || NEW.nro_matricula;

        INSERT INTO USUARIO_MODIFICA_GUARDIA (username, id_guardia, fecha_hora, descripcion)
        VALUES (v_username, NEW.id_guardia, NOW(), v_descripcion);

        RETURN NEW;

    ELSIF TG_OP = 'DELETE' THEN
        v_descripcion := 'Guardia eliminada: fecha=' || OLD.fecha ||
                         ', especialidad=' || OLD.id_especialidad ||
                         ', matricula=' || OLD.nro_matricula;

        INSERT INTO USUARIO_MODIFICA_GUARDIA (username, id_guardia, fecha_hora, descripcion)
        VALUES (v_username, OLD.id_guardia, NOW(), v_descripcion);

        RETURN OLD;
    END IF;

END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_registrar_modificacion_guardia
AFTER INSERT OR UPDATE OR DELETE ON GUARDIA
FOR EACH ROW
EXECUTE FUNCTION trg_registrar_modificacion_guardia_fn();

-- ===================================================================
-- Triggers para registrar modificaciones en la tabla GUARDIA_TIENE_TURNOGUARDIA
-- Recibe el usuario actual y registra la operación (INSERT, DELETE)
-- en la tabla USUARIO_MODIFICA_GUARDIA con una descripción de la modificación
CREATE OR REPLACE FUNCTION trg_registrar_modificacion_turnos_fn()
RETURNS TRIGGER AS $$
DECLARE
    v_username VARCHAR(50);
    v_descripcion TEXT;
    v_id_guardia INT;
BEGIN
    v_username := current_user;
    v_id_guardia := COALESCE(NEW.id_guardia, OLD.id_guardia);

    IF TG_OP = 'INSERT' THEN
        v_descripcion := 'Turno agregado: turno=' || NEW.id_turno_guardia;

        INSERT INTO USUARIO_MODIFICA_GUARDIA (username, id_guardia, fecha_hora, descripcion)
        VALUES (v_username, v_id_guardia, NOW(), v_descripcion);

        RETURN NEW;

    ELSIF TG_OP = 'DELETE' THEN
        v_descripcion := 'Turno eliminado: turno=' || OLD.id_turno_guardia;

        INSERT INTO USUARIO_MODIFICA_GUARDIA (username, id_guardia, fecha_hora, descripcion)
        VALUES (v_username, v_id_guardia, NOW(), v_descripcion);

        RETURN OLD;
    END IF;

END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_registrar_modificacion_turnos
AFTER INSERT OR DELETE ON GUARDIA_TIENE_TURNOGUARDIA
FOR EACH ROW
EXECUTE FUNCTION trg_registrar_modificacion_turnos_fn();













INSERT INTO
    PERSONA (nro_dni, nombre, apellido)
VALUES ('10123456', 'Maite', 'Nigro'),
       ('11111222',
        'Francisco',
        'Carerra'
    ),
    (
        '12123456',
        'Daniel',
        'Rodriguez'
    ),
    ('13111222', 'Franco', 'Herrera'),
    (
        '14123456',
        'Tomas',
        'Santiago'
    ),
    (
        '15856456',
        'Benjamin',
        'Diaz'
    ),
    (
        '16654643',
        'Francisco',
        'Veron'
    ),
    ('17467543', 'Elsa', 'Martinez'),
    (
        '18567890',
        'Maria',
        'Stella'
    ),
    (
        '19654321',
        'Dolores',
        'Gonzales'
    ),
    (
        '20876543',
        'Jose',
        'Hernández'
    ),
    ('21678932', 'Erica', 'Mora'),
    ('22456732', 'Roberto', 'Garcia'),
    ('23543219', 'Inés', 'Portado'),
    ('24876123', 'Susana', 'Rojas'),
    ('25456789', 'Carlos', 'Rojas'),
    ('26567890', 'Héctor', 'Lado'),
    ('27678901', 'Anna', 'Casas'),
    ('28789012', 'Pablo', 'Nicas'),
    ('29890123', 'Julio', 'Tinos'),
    ('30901234', 'Esteban', 'Aguirre'),
    ('31012345', 'Agua', 'Marina'),
    (
        '32123456',
        'Rosario',
        'Central'
    ),
    ('33234567', 'Elena', 'Nado'),
    ('34345678', 'Clara', 'Mente'),
    ('35456789', 'Luz', 'Bella'),
    ('36567890', 'Paco', 'Tilla'),
    ('37678901', 'Alicia', 'Keys'),
    (
        '38789012',
        'Alberto',
        'Hongo'
    ),
    ('39890123', 'Selena', 'Mor'),
    ('40901234', 'Teo', 'Rico'),
    ('41012345', 'Max', 'Power'),
    ('42123456', 'Lola', 'Mento'),
    ('43234567', 'Rosa', 'Mística'),
    (
        '44345678',
        'Justo',
        'Barrios'
    ),
    ('45456789', 'Mario', 'Neta'),
    ('46567890', 'Ciro', 'Peretti'),
    ('47678901', 'Nora', 'Linares'),
    (
        '48789012',
        'Ángel',
        'Guardiola'
    ),
    ('49890123', 'Lía', 'Velasco'),
    ('50901234', 'Omar', 'Canto'),
    ('51012345', 'Dante', 'Fuego'),
    ('52123456', 'Carla', 'Rojas'),
    (
        '53234567',
        'Patricio',
        'Lagos'
    ),
    ('54345678', 'Emilia', 'Norte'),
    ('55456789', 'Rafael', 'Paz'),
    (
        '56567890',
        'Ignacio',
        'Salcedo'
    ),
    ('57678901', 'Marta', 'Vega'),
    ('58789012', 'Tania', 'Fierro'),
    (
        '59890123',
        'Julián',
        'Cruces'
    ),
    ('60567891', 'Camila', 'Rivas'),
    ('61678902', 'Mateo', 'Soria'),
    (
        '62789013',
        'Lucía',
        'Benítez'
    ),
    (
        '63890124',
        'Julián',
        'Almada'
    ),
    (
        '64901235',
        'Abril',
        'Coronado'
    ),
    (
        '65012346',
        'Sofía',
        'Linares'
    ),
    (
        '66123457',
        'Bruno',
        'Ferreyra'
    ),
    (
        '67234568',
        'Valentina',
        'Paz'
    ),
    ('68345679', 'Dante', 'Molina'),
    (
        '69456780',
        'Isabella',
        'Campos'
    ),
    ('70567891', 'Tomás', 'Acosta'),
    ('71678902', 'Emma', 'Roldán'),
    (
        '72789013',
        'Ignacio',
        'Crespo'
    ),
    ('73890124', 'Mía', 'Quiroga'),
    (
        '74901235',
        'Benjamín',
        'Lagos'
    ),
    (
        '75012346',
        'Martina',
        'Salcedo'
    ),
    ('76123457', 'Pablo', 'Villar'),
    (
        '77234568',
        'Chloe',
        'Herrera'
    ),
    (
        '78345679',
        'Lautaro',
        'Montes'
    ),
    (
        '79456780',
        'Julieta',
        'Becerra'
    ),
    ('80567891', 'Gael', 'Correa'),
    (
        '81678902',
        'Malena',
        'Olivera'
    ),
    (
        '82789013',
        'Renzo',
        'Paredes'
    ),
    (
        '83890124',
        'Renata',
        'Delgado'
    ),
    ('84901235', 'Teo', 'Carrizo'),
    (
        '85012346',
        'Catalina',
        'Miranda'
    ),
    ('86123457', 'Luca', 'Solís'),
    ('87234568', 'Zoe', 'Vega'),
    (
        '88345679',
        'Elías',
        'Serrano'
    ),
    (
        '89456780',
        'Selena',
        'Moyano'
    ),
    (
        '90567891',
        'Simón',
        'Peralta'
    ),
    ('91678902', 'Uma', 'Villalba'),
    (
        '92789013',
        'Vicente',
        'Funes'
    ),
    ('93890124', 'Lara', 'Aranda'),
    (
        '94901235',
        'Ulises',
        'Saavedra'
    ),
    ('95012346', 'Bianca', 'Tello'),
    (
        '96123457',
        'Thiago',
        'Barrios'
    ),
    (
        '97234568',
        'Maite',
        'Escobar'
    ),
    ('98345679', 'Ciro', 'Farías'),
    ('99456780', 'Alma', 'Vignolo'),
    ('10067891', 'Amparo', 'Ojeda'),
    (
        '10178902',
        'Felipe',
        'Tejeda'
    ),
    (
        '10289013',
        'Lola',
        'Guerrero'
    ),
    (
        '10390124',
        'Bautista',
        'Navarro'
    ),
    (
        '10401235',
        'Olivia',
        'Sarmiento'
    ),
    ('10512346', 'Ramiro', 'Tapia'),
    ('10623457', 'Elena', 'Ramos'),
    (
        '10734568',
        'Francisco',
        'Lema'
    ),
    (
        '10845679',
        'Violeta',
        'Bustamante'
    ),
    ('10956780', 'Camilo', 'Lemus');

INSERT INTO
    USUARIO (
        username,
        password,
        puede_mod_guardia,
        nro_dni
    )
VALUES (
        'neondb_owner',
        'a',
        TRUE,
        '10123456'
    ),
    (
        'medico_1',
        'a',
        FALSE,
        '20876543'
    ),
    (
        'medico_2',
        'a',
        FALSE,
        '30901234'
    ),
    (
        'medico_3',
        'a',
        FALSE,
        '40901234'
    ),
    (
        'medico_4',
        'a',
        FALSE,
        '50901234'
    ),
    (
        'medico_5',
        'a',
        FALSE,
        '60567891'
    ),
    (
        'medico_6',
        'a',
        FALSE,
        '70567891'
    ),
    (
        'medico_7',
        'a',
        FALSE,
        '80567891'
    ),
    (
        'medico_8',
        'a',
        FALSE,
        '90567891'
    ),
    (
        'medico_9',
        'a',
        FALSE,
        '10067891'
    ),
    (
        'medico_10',
        'a',
        FALSE,
        '11111222'
    ),
    (
        'secretaria_1',
        'a',
        TRUE,
        '21678932'
    ),
    (
        'secretaria_2',
        'a',
        TRUE,
        '31012345'
    ),
    (
        'enfermera_1',
        'a',
        FALSE,
        '41012345'
    ),
    (
        'enfermera_2',
        'a',
        FALSE,
        '51012345'
    ),
    (
        'enfermera_3',
        'a',
        FALSE,
        '61678902'
    ),
    (
        'enfermera_4',
        'a',
        FALSE,
        '71678902'
    ),
    (
        'enfermera_5',
        'a',
        FALSE,
        '81678902'
    ),
    (
        'enfermera_6',
        'a',
        FALSE,
        '91678902'
    ),
    (
        'enfermera_7',
        'a',
        FALSE,
        '10178902'
    );

INSERT INTO
    PACIENTE (nro_dni, sexo, fecha_nac)
VALUES ('12123456', 'F', '1990-01-01'),
    ('22456732', 'F', '1990-02-04'),
    ('32123456', 'F', '1990-03-07'),
    ('42123456', 'F', '1990-04-10'),
    ('52123456', 'F', '1990-05-13'),
    ('62789013', 'F', '1990-06-16'),
    ('72789013', 'F', '1990-07-19'),
    ('82789013', 'F', '1990-08-22'),
    ('92789013', 'F', '1990-09-25'),
    ('10289013', 'F', '1990-10-28'),
    ('13111222', 'M', '1991-01-01'),
    ('23543219', 'M', '1991-02-04'),
    ('33234567', 'M', '1991-03-07'),
    ('43234567', 'M', '1991-04-10'),
    ('53234567', 'M', '1991-05-13'),
    ('63890124', 'M', '1991-06-16'),
    ('73890124', 'M', '1991-07-19'),
    ('83890124', 'M', '1991-08-22'),
    ('93890124', 'M', '1991-09-25'),
    ('10390124', 'M', '1991-10-28'),
    ('14123456', 'X', '1992-01-01'),
    ('24876123', 'X', '1992-02-04'),
    ('34345678', 'X', '1992-03-07'),
    ('44345678', 'X', '1992-04-10'),
    ('54345678', 'X', '1992-05-13'),
    ('64901235', 'X', '1992-06-16'),
    ('74901235', 'X', '1992-07-19'),
    ('84901235', 'X', '1992-08-22'),
    ('94901235', 'X', '1992-09-25'),
    ('10401235', 'X', '1992-10-28'),
    ('15856456', 'M', '1993-01-01'),
    ('25456789', 'M', '1993-02-04'),
    ('35456789', 'M', '1993-03-07'),
    ('45456789', 'M', '1993-04-10'),
    ('55456789', 'M', '1993-05-13'),
    ('65012346', 'M', '1993-06-16'),
    ('75012346', 'M', '1993-07-19'),
    ('85012346', 'M', '1993-08-22'),
    ('95012346', 'M', '1993-09-25'),
    ('10512346', 'M', '1993-10-28'),
    ('16654643', 'F', '1994-01-01'),
    ('26567890', 'F', '1994-02-04'),
    ('36567890', 'F', '1994-03-07'),
    ('46567890', 'F', '1994-04-10'),
    ('56567890', 'F', '1994-05-13'),
    ('66123457', 'F', '1994-06-16'),
    ('76123457', 'F', '1994-07-19'),
    ('86123457', 'F', '1994-08-22'),
    ('96123457', 'F', '1994-09-25'),
    ('10623457', 'F', '1994-10-28'),
    ('17467543', 'X', '1995-01-01'),
    ('27678901', 'X', '1995-02-04'),
    ('37678901', 'X', '1995-03-07'),
    ('47678901', 'X', '1995-04-10'),
    ('57678901', 'X', '1995-05-13'),
    ('67234568', 'X', '1995-06-16'),
    ('77234568', 'X', '1995-07-19'),
    ('87234568', 'X', '1995-08-22'),
    ('97234568', 'X', '1995-09-25'),
    ('10734568', 'X', '1995-10-28'),
    ('18567890', 'M', '1996-01-01'),
    ('28789012', 'M', '1996-02-04'),
    ('38789012', 'M', '1996-03-07'),
    ('48789012', 'M', '1996-04-10'),
    ('58789012', 'M', '1996-05-13'),
    ('68345679', 'M', '1996-06-16'),
    ('78345679', 'M', '1996-07-19'),
    ('88345679', 'M', '1996-08-22'),
    ('98345679', 'M', '1996-09-25'),
    ('10845679', 'M', '1996-10-28'),
    ('19654321', 'F', '1997-01-01'),
    ('29890123', 'F', '1997-02-04'),
    ('39890123', 'F', '1997-03-07'),
    ('49890123', 'F', '1997-04-10'),
    ('59890123', 'F', '1997-05-13'),
    ('69456780', 'F', '1997-06-16'),
    ('79456780', 'F', '1997-07-19'),
    ('89456780', 'F', '1997-08-22'),
    ('99456780', 'F', '1997-09-25'),
    ('10956780', 'F', '1997-10-28');

INSERT INTO
    MEDICO (
        nro_matricula,
        fecha_ingreso,
        foto,
        cuil,
        cuit,
        nro_dni
    )
VALUES (
        '1001',
        '2014-01-01',
        decode ('ff', 'hex'),
        '20208765433',
        '20208765433',
        '20876543'
    ),
    (
        '1002',
        '2015-02-04',
        decode ('ff', 'hex'),
        '20309012343',
        '20309012343',
        '30901234'
    ),
    (
        '1003',
        '2016-03-07',
        decode ('ff', 'hex'),
        '20409012343',
        '20409012343',
        '40901234'
    ),
    (
        '1004',
        '2017-04-10',
        decode ('ff', 'hex'),
        '20509012343',
        '20509012343',
        '50901234'
    ),
    (
        '1005',
        '2018-05-13',
        decode ('ff', 'hex'),
        '20605678913',
        '20605678913',
        '60567891'
    ),
    (
        '1006',
        '2019-06-16',
        decode ('ff', 'hex'),
        '20705678913',
        '20705678913',
        '70567891'
    ),
    (
        '1007',
        '2020-07-19',
        decode ('ff', 'hex'),
        '20805678913',
        '20805678913',
        '80567891'
    ),
    (
        '1008',
        '2021-08-22',
        decode ('ff', 'hex'),
        '20905678913',
        '20905678913',
        '90567891'
    ),
    (
        '1009',
        '2022-09-25',
        decode ('ff', 'hex'),
        '20100678913',
        '20100678913',
        '10067891'
    ),
    (
        '1010',
        '2023-10-28',
        decode ('ff', 'hex'),
        '20111112223',
        '20111112223',
        '11111222'
    );

INSERT INTO
    ESPECIALIDAD (nombre)
VALUES ('Clínica Médica'),
    ('Pediatría'),
    ('Traumatología');

INSERT INTO
    MED_TIENE_ESP (
        id_especialidad,
        nro_matricula,
        max_cant_guardia
    )
VALUES (1, '1001', 10),
    (2, '1001', 10),
    (3, '1001', 10),
    (2, '1002', 15),
    (3, '1002', 10),
    (3, '1003', 20),
    (1, '1003', 20),
    (1, '1004', 20),
    (2, '1005', 15),
    (3, '1006', 10),
    (1, '1007', 15),
    (3, '1007', 15),
    (2, '1008', 20),
    (1, '1008', 10),
    (3, '1009', 25),
    (1, '1010', 10),
    (2, '1010', 15),
    (3, '1010', 10);

INSERT INTO
    TURNOGUARDIA (hora_inicio, hora_fin)
VALUES ('08:00', '14:00'),
    ('14:00', '20:00'),
    ('20:00', '08:00');

INSERT INTO
    GUARDIA (
        fecha,
        id_especialidad,
        nro_matricula
    )
VALUES ('2025-10-01', 1, '1001'),
    ('2025-10-01', 1, '1003'),
    ('2025-10-01', 1, '1004'),
    ('2025-10-01', 2, '1002'),
    ('2025-10-01', 2, '1005'),
    ('2025-10-01', 2, '1008'),
    ('2025-10-01', 3, '1010'),
    ('2025-10-01', 3, '1009'),
    ('2025-10-01', 3, '1006'),
    ('2025-10-02', 1, '1007'),
    ('2025-10-02', 1, '1003'),
    ('2025-10-02', 1, '1004'),
    ('2025-10-02', 2, '1002'),
    ('2025-10-02', 2, '1005'),
    ('2025-10-02', 2, '1008'),
    ('2025-10-02', 3, '1010'),
    ('2025-10-02', 3, '1009'),
    ('2025-10-02', 3, '1006'),
    ('2025-10-03', 1, '1001'),
    ('2025-10-03', 1, '1003'),
    ('2025-10-03', 1, '1004'),
    ('2025-10-03', 2, '1002'),
    ('2025-10-03', 2, '1005'),
    ('2025-10-03', 2, '1008'),
    ('2025-10-03', 3, '1007'),
    ('2025-10-03', 3, '1009'),
    ('2025-10-03', 3, '1006'),
    ('2025-10-04', 1, '1001'),
    ('2025-10-04', 1, '1007'),
    ('2025-10-04', 1, '1004'),
    ('2025-10-04', 2, '1002'),
    ('2025-10-04', 2, '1005'),
    ('2025-10-04', 2, '1008'),
    ('2025-10-04', 3, '1010'),
    ('2025-10-04', 3, '1009'),
    ('2025-10-04', 3, '1006'),
    ('2025-10-05', 1, '1001'),
    ('2025-10-05', 1, '1003'),
    ('2025-10-05', 1, '1004'),
    ('2025-10-05', 2, '1002'),
    ('2025-10-05', 2, '1005'),
    ('2025-10-05', 2, '1008'),
    ('2025-10-05', 3, '1010'),
    ('2025-10-05', 3, '1007'),
    ('2025-10-05', 3, '1006'),
    ('2025-10-06', 1, '1001'),
    ('2025-10-06', 1, '1003'),
    ('2025-10-06', 1, '1007'),
    ('2025-10-06', 2, '1002'),
    ('2025-10-06', 2, '1005'),
    ('2025-10-06', 2, '1008'),
    ('2025-10-06', 3, '1010'),
    ('2025-10-06', 3, '1009'),
    ('2025-10-06', 3, '1006'),
    ('2025-10-07', 1, '1001'),
    ('2025-10-07', 1, '1003'),
    ('2025-10-07', 1, '1004'),
    ('2025-10-07', 2, '1002'),
    ('2025-10-07', 2, '1005'),
    ('2025-10-07', 2, '1008'),
    ('2025-10-07', 3, '1010'),
    ('2025-10-07', 3, '1009'),
    ('2025-10-07', 3, '1007');

INSERT INTO
    GUARDIA_TIENE_TURNOGUARDIA
VALUES (1, 1),
    (2, 2),
    (3, 3),
    (4, 1),
    (5, 2),
    (6, 3),
    (7, 1),
    (8, 2),
    (9, 3),
    (10, 1),
    (11, 2),
    (12, 3),
    (13, 1),
    (14, 2),
    (15, 3),
    (16, 1),
    (17, 2),
    (18, 3),
    (19, 1),
    (20, 2),
    (21, 3),
    (22, 1),
    (23, 2),
    (24, 3),
    (25, 1),
    (26, 2),
    (27, 3),
    (28, 1),
    (29, 2),
    (30, 3),
    (31, 1),
    (32, 2),
    (33, 3),
    (34, 1),
    (35, 2),
    (36, 3),
    (37, 1),
    (38, 2),
    (39, 3),
    (40, 1),
    (41, 2),
    (42, 3),
    (43, 1),
    (44, 2),
    (45, 3),
    (46, 1),
    (47, 2),
    (48, 3),
    (49, 1),
    (50, 2),
    (51, 3),
    (52, 1),
    (53, 2),
    (54, 3),
    (55, 1),
    (56, 2),
    (57, 3),
    (58, 1),
    (59, 2),
    (60, 3),
    (61, 1),
    (62, 2),
    (63, 3);

INSERT INTO
    SECTOR (nombre_sector)
VALUES ('Clínica General'),
    ('Pediatría'),
    ('Traumatología y Ortopedia'),
    ('Guardia / Observación');

INSERT INTO
    HABITACION (piso, orientacion, id_sector)
VALUES (1, 'N', 1),
    (1, 'E', 1),
    (1, 'S', 1),
    (1, 'O', 1),
    (2, 'N', 1),
    (2, 'E', 1),
    (2, 'S', 1),
    (2, 'O', 1),
    (1, 'N', 2),
    (1, 'S', 2),
    (1, 'E', 2),
    (1, 'O', 2),
    (2, 'N', 3),
    (2, 'S', 3),
    (2, 'E', 3),
    (2, 'O', 3),
    (3, 'N', 3),
    (3, 'S', 3),
    (0, 'N', 4),
    (0, 'S', 4),
    (0, 'E', 4),
    (0, 'O', 4);

INSERT INTO
    CAMA (id_habitacion)
VALUES (1),
    (1),
    (1),
    (2),
    (2),
    (2),
    (3),
    (3),
    (3),
    (4),
    (4),
    (4),
    (5),
    (5),
    (5),
    (6),
    (6),
    (6),
    (7),
    (7),
    (7),
    (8),
    (8),
    (8),
    (9),
    (9),
    (10),
    (10),
    (11),
    (11),
    (12),
    (12),
    (13),
    (13),
    (14),
    (14),
    (15),
    (15),
    (16),
    (16),
    (17),
    (17),
    (18),
    (18),
    (19),
    (20),
    (21),
    (22);

INSERT INTO
    INTERNACION (
        fecha_hora_inicio,
        fecha_hora_fin,
        nro_matricula,
        nro_dni
    )
VALUES (
        '2025-07-01 03:10',
        '2025-07-03 12:00',
        '1001',
        '13111222'
    ),
    (
        '2025-08-15 03:10',
        '2025-08-20 12:00',
        '1001',
        '33234567'
    ),
    (
        '2025-07-02 03:10',
        '2025-07-09 12:00',
        '1001',
        '63890124'
    ),
    (
        '2025-07-03 03:10',
        '2025-07-06 12:00',
        '1001',
        '93890124'
    ),
    (
        '2025-08-03 03:10',
        '2025-08-09 12:00',
        '1001',
        '24876123'
    ),
    (
        '2025-08-10 03:10',
        '2025-08-15 12:00',
        '1001',
        '64901235'
    ),
    (
        '2025-08-20 03:10',
        '2025-08-25 12:00',
        '1001',
        '10401235'
    ),
    (
        '2025-05-25 03:10',
        '2025-06-10 12:00',
        '1001',
        '15856456'
    ),
    (
        '2025-07-08 03:10',
        '2025-07-13 12:00',
        '1002',
        '95012346'
    ),
    (
        '2025-04-10 03:10',
        '2025-04-17 12:00',
        '1002',
        '16654643'
    ),
    (
        '2025-08-10 03:10',
        '2025-08-14 12:00',
        '1002',
        '13111222'
    ),
    (
        '2025-02-10 03:10',
        '2025-02-15 12:00',
        '1002',
        '43234567'
    ),
    (
        '2025-08-13 03:10',
        '2025-08-16 12:00',
        '1002',
        '63890124'
    ),
    (
        '2025-01-13 03:10',
        '2025-01-16 12:00',
        '1002',
        '73890124'
    ),
    (
        '2025-08-17 03:10',
        '2025-08-20 12:00',
        '1002',
        '93890124'
    ),
    (
        '2025-07-13 03:10',
        '2025-07-16 12:00',
        '1002',
        '34345678'
    ),
    (
        '2025-03-14 03:10',
        '2025-03-19 12:00',
        '1003',
        '74901235'
    ),
    (
        '2025-07-01 03:10',
        '2025-07-01 12:00',
        '1003',
        '25456789'
    ),
    (
        '2025-02-04 03:10',
        '2025-02-07 12:00',
        '1003',
        '10512346'
    ),
    (
        '2025-07-10 03:10',
        '2025-07-13 12:00',
        '1003',
        '26567890'
    ),
    (
        '2025-09-18 03:10',
        '2025-09-21 12:00',
        '1003',
        '13111222'
    ),
    (
        '2025-04-23 03:10',
        '2025-04-25 12:00',
        '1003',
        '43234567'
    ),
    (
        '2025-04-20 03:10',
        '2025-04-27 12:00',
        '1003',
        '73890124'
    ),
    (
        '2025-03-20 03:10',
        '2025-03-24 12:00',
        '1003',
        '10390124'
    ),
    (
        '2025-09-20 03:10',
        '2025-09-25 12:00',
        '1004',
        '34345678'
    ),
    (
        '2025-05-26 03:10',
        '2025-05-26 12:00',
        '1004',
        '74901235'
    ),
    (
        '2025-08-20 03:10',
        '2025-08-27 12:00',
        '1004',
        '35456789'
    ),
    (
        '2025-03-26 03:10',
        '2025-03-28 12:00',
        '1004',
        '36567890'
    ),
    (
        '2025-05-27 03:10',
        '2025-05-29 12:00',
        '1004',
        '96123457'
    ),
    (
        '2025-06-20 03:10',
        '2025-06-30 12:00',
        '1004',
        '57678901'
    ),
    (
        '2025-01-01 03:10',
        '2025-01-02 12:00',
        '1004',
        '23543219'
    ),
    (
        '2025-07-01 03:10',
        '2025-07-03 12:00',
        '1004',
        '43234567'
    ),
    (
        '2025-07-02 03:10',
        '2025-07-05 12:00',
        '1005',
        '73890124'
    ),
    (
        '2025-06-03 03:10',
        '2025-06-07 12:00',
        '1005',
        '10390124'
    ),
    (
        '2025-06-15 03:10',
        '2025-06-18 12:00',
        '1005',
        '44345678'
    ),
    (
        '2025-05-10 03:10',
        '2025-05-13 12:00',
        '1005',
        '84901235'
    ),
    (
        '2025-01-13 03:10',
        '2025-01-16 12:00',
        '1005',
        '45456789'
    ),
    (
        '2025-03-15 03:10',
        '2025-03-20 12:00',
        '1005',
        '46567890'
    ),
    (
        '2025-08-20 03:10',
        '2025-08-27 12:00',
        '1005',
        '10623457'
    ),
    (
        '2025-06-13 03:10',
        '2025-06-19 12:00',
        '1005',
        '67234568'
    ),
    (
        '2025-06-02 03:10',
        '2025-06-03 12:00',
        '1006',
        '23543219'
    ),
    (
        '2025-06-02 03:10',
        '2025-06-04 12:00',
        '1006',
        '53234567'
    ),
    (
        '2025-05-03 03:10',
        '2025-05-06 12:00',
        '1006',
        '83890124'
    ),
    (
        '2025-08-04 03:10',
        '2025-08-08 12:00',
        '1006',
        '10390124'
    ),
    (
        '2025-09-15 03:10',
        '2025-09-20 12:00',
        '1006',
        '44345678'
    ),
    (
        '2025-09-12 03:10',
        '2025-09-12 12:00',
        '1006',
        '84901235'
    ),
    (
        '2025-02-07 03:10',
        '2025-02-14 12:00',
        '1006',
        '55456789'
    ),
    (
        '2025-01-13 03:10',
        '2025-01-16 12:00',
        '1006',
        '56567890'
    ),
    (
        '2025-09-18 03:10',
        '2025-09-18 12:00',
        '1007',
        '17467543'
    ),
    (
        '2025-09-20 03:10',
        '2025-09-20 12:00',
        '1007',
        '77234568'
    ),
    (
        '2025-09-03 03:10',
        '2025-09-06 12:00',
        '1007',
        '23543219'
    ),
    (
        '2025-08-02 03:10',
        '2025-08-04 12:00',
        '1007',
        '53234567'
    ),
    (
        '2025-07-03 03:10',
        '2025-07-07 12:00',
        '1007',
        '83890124'
    ),
    (
        '2025-06-10 03:10',
        '2025-06-10 12:00',
        '1007',
        '14123456'
    ),
    (
        '2025-02-13 03:10',
        '2025-02-13 12:00',
        '1007',
        '54345678'
    ),
    (
        '2025-08-16 03:10',
        '2025-08-16 12:00',
        '1007',
        '94901235'
    ),
    (
        '2025-09-19 03:10',
        '2025-09-19 12:00',
        '1008',
        '65012346'
    ),
    (
        '2025-09-22 03:10',
        '2025-09-22 12:00',
        '1008',
        '66123457'
    ),
    (
        '2025-09-25 03:10',
        '2025-09-25 12:00',
        '1008',
        '27678901'
    ),
    (
        '2025-09-28 03:10',
        '2025-09-28 12:00',
        '1008',
        '87234568'
    ),
    (
        '2025-07-02 03:10',
        '2025-07-05 12:00',
        '1008',
        '33234567'
    ),
    (
        '2025-09-05 03:10',
        '2025-09-05 12:00',
        '1008',
        '53234567'
    ),
    (
        '2025-09-08 03:10',
        '2025-09-08 12:00',
        '1008',
        '83890124'
    ),
    (
        '2025-09-11 03:10',
        '2025-09-11 12:00',
        '1008',
        '14123456'
    ),
    (
        '2025-09-14 03:10',
        '2025-09-14 12:00',
        '1009',
        '54345678'
    ),
    (
        '2025-09-17 03:10',
        '2025-09-17 12:00',
        '1009',
        '94901235'
    ),
    (
        '2025-09-20 03:10',
        '2025-09-20 12:00',
        '1009',
        '75012346'
    ),
    (
        '2025-09-23 03:10',
        '2025-09-23 12:00',
        '1009',
        '76123457'
    ),
    (
        '2025-09-26 03:10',
        '2025-09-26 12:00',
        '1009',
        '37678901'
    ),
    (
        '2025-09-29 03:10',
        '2025-09-29 12:00',
        '1009',
        '97234568'
    );

INSERT INTO
    INTERNACION_CAMA
VALUES ('2025-07-01 03:10', 1, 1, 1),
    ('2025-08-15 03:10', 2, 1, 2),
    ('2025-07-02 03:10', 3, 1, 3),
    ('2025-07-03 03:10', 4, 2, 1),
    ('2025-08-03 03:10', 5, 2, 2),
    ('2025-08-10 03:10', 6, 2, 3),
    ('2025-08-20 03:10', 7, 3, 1),
    ('2025-05-25 03:10', 8, 3, 2),
    ('2025-07-08 03:10', 9, 3, 3),
    ('2025-04-10 03:10', 10, 4, 1),
    ('2025-07-02 03:10', 1, 4, 2),
    ('2025-08-18 03:10', 2, 4, 3),
    ('2025-07-07 03:10', 3, 5, 1),
    ('2025-07-05 03:10', 4, 5, 2),
    ('2025-08-05 03:10', 5, 5, 3),
    ('2025-08-12 03:10', 6, 6, 1),
    ('2025-08-21 03:10', 7, 6, 2),
    ('2025-05-28 03:10', 8, 6, 3),
    ('2025-07-10 03:10', 9, 7, 1),
    ('2025-04-13 03:10', 10, 7, 2),
    ('2025-08-10 03:10', 11, 7, 3),
    ('2025-02-10 03:10', 12, 8, 1),
    ('2025-08-13 03:10', 13, 8, 2),
    ('2025-01-13 03:10', 14, 8, 3),
    ('2025-08-17 03:10', 15, 9, 1),
    ('2025-07-13 03:10', 16, 9, 2),
    ('2025-03-14 03:10', 17, 10, 1),
    ('2025-07-01 03:10', 18, 10, 2),
    ('2025-02-04 03:10', 19, 11, 1),
    ('2025-07-10 03:10', 20, 11, 2),
    ('2025-09-18 03:10', 21, 12, 1),
    ('2025-04-23 03:10', 22, 12, 2),
    ('2025-04-20 03:10', 23, 13, 1),
    ('2025-03-20 03:10', 24, 13, 2),
    ('2025-09-20 03:10', 25, 14, 1),
    ('2025-05-26 03:10', 26, 14, 2),
    ('2025-08-20 03:10', 27, 15, 1),
    ('2025-03-26 03:10', 28, 15, 2),
    ('2025-05-27 03:10', 29, 16, 1),
    ('2025-06-20 03:10', 30, 16, 2),
    ('2025-01-01 03:10', 31, 17, 1),
    ('2025-07-01 03:10', 32, 17, 2),
    ('2025-07-02 03:10', 33, 18, 1),
    ('2025-06-03 03:10', 34, 18, 2),
    ('2025-06-15 03:10', 35, 19, 1),
    ('2025-05-10 03:10', 36, 20, 1),
    ('2025-01-13 03:10', 37, 21, 1),
    ('2025-03-15 03:10', 38, 22, 1),
    ('2025-08-20 03:10', 39, 1, 1),
    ('2025-06-13 03:10', 40, 1, 2),
    ('2025-06-02 03:10', 41, 1, 3),
    ('2025-06-02 03:10', 42, 2, 1),
    ('2025-05-03 03:10', 43, 2, 2),
    ('2025-08-04 03:10', 44, 2, 3),
    ('2025-09-15 03:10', 45, 3, 1),
    ('2025-09-12 03:10', 46, 3, 2),
    ('2025-02-07 03:10', 47, 3, 3),
    ('2025-01-13 03:10', 48, 4, 1),
    ('2025-09-18 03:10', 49, 4, 2),
    ('2025-09-20 03:10', 50, 4, 3),
    ('2025-09-03 03:10', 51, 5, 1),
    ('2025-08-02 03:10', 52, 5, 2),
    ('2025-07-03 03:10', 53, 5, 3),
    ('2025-06-10 03:10', 54, 6, 1),
    ('2025-02-13 03:10', 55, 6, 2),
    ('2025-08-16 03:10', 56, 6, 3),
    ('2025-09-19 03:10', 57, 7, 1),
    ('2025-09-22 03:10', 58, 7, 2),
    ('2025-09-25 03:10', 59, 7, 3),
    ('2025-09-28 03:10', 60, 8, 1),
    ('2025-07-02 03:10', 61, 8, 2),
    ('2025-09-05 03:10', 62, 8, 3),
    ('2025-09-08 03:10', 63, 9, 1),
    ('2025-09-11 03:10', 64, 9, 2),
    ('2025-09-14 03:10', 65, 10, 1),
    ('2025-09-17 03:10', 66, 10, 2),
    ('2025-09-20 03:10', 67, 11, 1),
    ('2025-09-23 03:10', 68, 11, 2),
    ('2025-09-26 03:10', 69, 12, 1),
    ('2025-09-29 03:10', 70, 12, 2);


































--===========================================================================
-- ACA TENES QUE CLAVAR LOS TRIGGERS PARA QUE AL CARGAR LAS INTERNACIONES
-- QUE NO TIENEN FECHA FIN Y LUEGO ASIGNARLES LAS CAMA
-- QUE SE ACTUALICE CORRECTAMENTE LA TABLA CAMA CON LOS ESTA_LIBRE
--===========================================================================

-- ===================================================================
-- Trigger para validar datos en la tabla MEDICO
-- Innecesario validar CUIL y CUIT, muy restrictivo.
-- Se valida:
-- que la fecha de ingreso no sea futura.
-- que el CUIL central coincida con el nro_dni.
-- que el CUIL y CUIT sean positivos y de 11 dígitos.
CREATE OR REPLACE FUNCTION validar_medico()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.fecha_ingreso > CURRENT_DATE THEN
        RAISE EXCEPTION 'Fecha de ingreso inválida';
    END IF;

    IF SUBSTRING(NEW.cuil::text FROM 3 FOR 8) <> NEW.nro_dni THEN
        RAISE EXCEPTION 'CUIL no coincide con DNI';
    END IF;

    IF char_length(NEW.cuil) <> 11
    OR NEW.cuil !~ '^[0-9]{11}$' THEN RAISE EXCEPTION 'CUIL inválido. Debe contener 11 dígitos.';
    END IF;

    IF char_length(NEW.cuit) <> 11
    OR NEW.cuit !~ '^[0-9]{11}$' THEN RAISE EXCEPTION 'CUIT inválido. Debe contener 11 dígitos.';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validar_medico
BEFORE INSERT OR UPDATE ON MEDICO
FOR EACH ROW
EXECUTE FUNCTION validar_medico();

-- ===================================================================
-- Trigger para liberar la última cama asignada a una internación
-- cuando se le asigna una fecha de finalización a la internación.
CREATE OR REPLACE FUNCTION liberar_ultima_cama_internacion()
RETURNS TRIGGER AS $$
DECLARE
    ultima_cama RECORD;
BEGIN
    -- Solo actuar si se le asigna una fecha de finalizacion a la internacion
    IF OLD.fecha_hora_fin IS NULL AND NEW.fecha_hora_fin IS NOT NULL THEN
        
        -- Obtener la última cama asignada a esta internación
        SELECT id_cama, id_habitacion
        INTO ultima_cama
        FROM INTERNACION_CAMA
        WHERE id_internacion = NEW.id_internacion
        ORDER BY fecha_hora_asignacion DESC
        LIMIT 1;

        -- Liberarla
        UPDATE CAMA
        SET esta_libre = TRUE
        WHERE id_cama = ultima_cama.id_cama
        AND id_habitacion = ultima_cama.id_habitacion;

    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_liberar_cama_fin_internacion
AFTER UPDATE ON INTERNACION
FOR EACH ROW
EXECUTE FUNCTION liberar_ultima_cama_internacion();

-- ===================================================================
-- Trigger para gestionar la asignación de camas en INTERNACION_CAMA
-- Al insertar una nueva asignación de cama:
-- 1. Verifica que la internación esté activa (sin fecha de fin).
-- 2. Si la internación ya tiene una cama asignada, libera la última cama.
-- 3. Verifica que la nueva cama esté libre.
-- 4. Ocupa la nueva cama.
CREATE OR REPLACE FUNCTION verificar_internacion_activa(p_id_internacion INT)
RETURNS VOID AS $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM INTERNACION
        WHERE id_internacion = p_id_internacion
          AND fecha_hora_fin IS NOT NULL
          AND fecha_hora_fin <= CURRENT_TIMESTAMP
    ) THEN
        RAISE EXCEPTION 'No se puede asignar cama: la internación % ya finalizó', p_id_internacion;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION liberar_ultima_cama(p_id_internacion INT)
RETURNS VOID AS $$
DECLARE
    ultima_cama RECORD;
BEGIN
    -- Obtener la última cama asignada
    SELECT id_cama, id_habitacion
    INTO ultima_cama
    FROM INTERNACION_CAMA
    WHERE id_internacion = p_id_internacion
    ORDER BY fecha_hora_asignacion DESC
    LIMIT 1;

    -- Si existe, liberarla
    IF FOUND THEN
        UPDATE CAMA
        SET esta_libre = TRUE
        WHERE id_cama = ultima_cama.id_cama
          AND id_habitacion = ultima_cama.id_habitacion;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION verificar_cama_libre(p_id_cama INT, p_id_habitacion INT)
RETURNS VOID AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM CAMA
        WHERE id_cama = p_id_cama
          AND id_habitacion = p_id_habitacion
          AND esta_libre = TRUE
    ) THEN
        RAISE EXCEPTION 'La cama % de la habitación % ya está ocupada', p_id_cama, p_id_habitacion;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION ocupar_cama_fisica(p_id_cama INT, p_id_habitacion INT)
RETURNS VOID AS $$
BEGIN
    UPDATE CAMA
    SET esta_libre = FALSE
    WHERE id_cama = p_id_cama
      AND id_habitacion = p_id_habitacion;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION ocupar_cama_trigger()
RETURNS TRIGGER AS $$
DECLARE
    cantidad_camas INT;
BEGIN
    -- 1. Verificar internación activa
    PERFORM verificar_internacion_activa(NEW.id_internacion);

    -- 2. Contar cuántas camas tiene asignadas
    SELECT COUNT(*) INTO cantidad_camas
    FROM INTERNACION_CAMA
    WHERE id_internacion = NEW.id_internacion;

    -- 3. Liberar última cama si ya tiene alguna
    IF cantidad_camas >= 1 THEN
        PERFORM liberar_ultima_cama(NEW.id_internacion);
    END IF;

    -- 4. Verificar que la nueva cama esté libre
    PERFORM verificar_cama_libre(NEW.id_cama, NEW.id_habitacion);

    -- 5. Ocupar la nueva cama
    PERFORM ocupar_cama_fisica(NEW.id_cama, NEW.id_habitacion);

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_ocupar_cama
BEFORE INSERT ON INTERNACION_CAMA
FOR EACH ROW
EXECUTE FUNCTION ocupar_cama_trigger();

-- ===================================================================
-- Trigger para validar que las vacaciones de un médico no se solapen
-- con otras vacaciones existentes para el mismo médico.
CREATE OR REPLACE FUNCTION validar_vacacion()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM VACACION
        WHERE nro_matricula = NEW.nro_matricula
          AND id_vacacion <> COALESCE(NEW.id_vacacion, 0)
          AND NOT (NEW.fecha_fin < fecha_inicio OR NEW.fecha_inicio > fecha_fin)
    ) THEN
        RAISE EXCEPTION 'La vacación se solapa con otra existente para el mismo médico';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validar_vacacion
BEFORE INSERT OR UPDATE ON VACACION
FOR EACH ROW
EXECUTE FUNCTION validar_vacacion();




























INSERT INTO
    INTERNACION (
        fecha_hora_inicio,
        fecha_hora_fin,
        nro_matricula,
        nro_dni
    )
VALUES (
        '2025-09-22 03:10',
        NULL,
        '1009',
        '33234567'
    ),
    (
        '2025-09-20 03:10',
        NULL,
        '1009',
        '63890124'
    ),
    (
        '2025-09-22 03:10',
        NULL,
        '1010',
        '93890124'
    ),
    (
        '2025-09-05 03:10',
        NULL,
        '1010',
        '24876123'
    ),
    (
        '2025-09-08 03:10',
        NULL,
        '1010',
        '64901235'
    ),
    (
        '2025-09-13 03:10',
        NULL,
        '1010',
        '10401235'
    ),
    (
        '2025-09-21 03:10',
        NULL,
        '1010',
        '85012346'
    ),
    (
        '2025-09-07 03:10',
        NULL,
        '1010',
        '86123457'
    ),
    (
        '2025-09-19 03:10',
        NULL,
        '1010',
        '47678901'
    ),
    (
        '2025-09-23 03:10',
        NULL,
        '1010',
        '10734568'
    );

INSERT INTO
    INTERNACION_CAMA
VALUES ('2025-09-22 03:10', 71, 1, 1),
    ('2025-09-20 03:10', 72, 6, 2),
    ('2025-09-22 03:10', 73, 4, 1),
    ('2025-09-05 03:10', 74, 10, 2),
    ('2025-09-08 03:10', 75, 11, 1),
    ('2025-09-13 03:10', 76, 13, 2),
    ('2025-09-21 03:10', 77, 16, 1),
    ('2025-09-07 03:10', 78, 17, 2),
    ('2025-09-19 03:10', 79, 20, 1),
    ('2025-09-23 03:10', 80, 22, 1);

INSERT INTO
    RONDA (dia)
VALUES ('L'),
    ('L'),
    ('L'),
    ('L'),
    ('M'),
    ('M'),
    ('M'),
    ('M'),
    ('X'),
    ('X'),
    ('X'),
    ('X'),
    ('J'),
    ('J'),
    ('J'),
    ('J'),
    ('V'),
    ('V'),
    ('V'),
    ('V'),
    ('S'),
    ('S'),
    ('S'),
    ('S'),
    ('D'),
    ('D'),
    ('D'),
    ('D');

INSERT INTO
    TURNORONDA (hora_inicio, hora_fin)
VALUES ('09:00', '11:00'),
    ('15:00', '17:00');

INSERT INTO
    RONDA_TIENE_TURNORONDA
VALUES (1, 1),
    (2, 1),
    (3, 2),
    (4, 2),
    (5, 1),
    (6, 1),
    (7, 2),
    (8, 2),
    (9, 1),
    (10, 1),
    (11, 2),
    (12, 2),
    (13, 1),
    (14, 1),
    (15, 2),
    (16, 2),
    (17, 1),
    (18, 1),
    (19, 2),
    (20, 2),
    (21, 1),
    (22, 1),
    (23, 1),
    (24, 1),
    (25, 1),
    (26, 1),
    (27, 1),
    (28, 1);

INSERT INTO
    RECORRIDO (
        fecha,
        id_ronda,
        nro_matricula
    )
VALUES ('2025-09-24', 1, '1001'),
    ('2025-09-24', 2, '1002'),
    ('2025-09-24', 3, '1003'),
    ('2025-09-24', 4, '1004'),
    ('2025-09-25', 5, '1005'),
    ('2025-09-25', 6, '1006'),
    ('2025-09-25', 7, '1007'),
    ('2025-09-25', 8, '1008'),
    ('2025-09-26', 9, '1009'),
    ('2025-09-26', 10, '1010'),
    ('2025-09-26', 11, '1001'),
    ('2025-09-26', 12, '1002'),
    ('2025-09-27', 13, '1003'),
    ('2025-09-27', 14, '1004'),
    ('2025-09-27', 15, '1005'),
    ('2025-09-27', 16, '1006'),
    ('2025-09-28', 17, '1007'),
    ('2025-09-28', 18, '1008'),
    ('2025-09-28', 19, '1009'),
    ('2025-09-28', 20, '1010'),
    ('2025-09-29', 21, '1001'),
    ('2025-09-29', 22, '1002'),
    ('2025-09-29', 23, '1003'),
    ('2025-09-29', 24, '1004'),
    ('2025-09-30', 25, '1005'),
    ('2025-09-30', 26, '1006'),
    ('2025-09-30', 27, '1007'),
    ('2025-09-30', 28, '1008');

INSERT INTO
    ROND_TIENE_HAB (id_ronda, id_habitacion)
VALUES (1, 1),
    (1, 2),
    (1, 3),
    (1, 4),
    (1, 5),
    (1, 6),
    (1, 7),
    (1, 8),
    (2, 9),
    (2, 10),
    (2, 11),
    (2, 12),
    (3, 13),
    (3, 14),
    (3, 15),
    (3, 16),
    (3, 17),
    (3, 18),
    (4, 19),
    (4, 20),
    (4, 21),
    (4, 22),
    (5, 1),
    (5, 2),
    (5, 3),
    (5, 4),
    (5, 5),
    (5, 6),
    (5, 7),
    (5, 8),
    (6, 9),
    (6, 10),
    (6, 11),
    (6, 12),
    (7, 13),
    (7, 14),
    (7, 15),
    (7, 16),
    (7, 17),
    (7, 18),
    (8, 19),
    (8, 20),
    (8, 21),
    (8, 22),
    (9, 1),
    (9, 2),
    (9, 3),
    (9, 4),
    (9, 5),
    (9, 6),
    (9, 7),
    (9, 8),
    (10, 9),
    (10, 10),
    (10, 11),
    (10, 12),
    (11, 13),
    (11, 14),
    (11, 15),
    (11, 16),
    (11, 17),
    (11, 18),
    (12, 19),
    (12, 20),
    (12, 21),
    (12, 22),
    (13, 1),
    (13, 2),
    (13, 3),
    (13, 4),
    (13, 5),
    (13, 6),
    (13, 7),
    (13, 8),
    (14, 9),
    (14, 10),
    (14, 11),
    (14, 12),
    (15, 13),
    (15, 14),
    (15, 15),
    (15, 16),
    (15, 17),
    (15, 18),
    (16, 19),
    (16, 20),
    (16, 21),
    (16, 22),
    (17, 1),
    (17, 2),
    (17, 3),
    (17, 4),
    (17, 5),
    (17, 6),
    (17, 7),
    (17, 8),
    (18, 9),
    (18, 10),
    (18, 11),
    (18, 12),
    (19, 13),
    (19, 14),
    (19, 15),
    (19, 16),
    (19, 17),
    (19, 18),
    (20, 19),
    (20, 20),
    (20, 21),
    (20, 22),
    (21, 1),
    (21, 2),
    (21, 3),
    (21, 4),
    (21, 5),
    (21, 6),
    (21, 7),
    (21, 8),
    (22, 9),
    (22, 10),
    (22, 11),
    (22, 12),
    (23, 13),
    (23, 14),
    (23, 15),
    (23, 16),
    (23, 17),
    (23, 18),
    (24, 19),
    (24, 20),
    (24, 21),
    (24, 22),
    (25, 1),
    (25, 2),
    (25, 3),
    (25, 4),
    (25, 5),
    (25, 6),
    (25, 7),
    (25, 8),
    (26, 9),
    (26, 10),
    (26, 11),
    (26, 12),
    (27, 13),
    (27, 14),
    (27, 15),
    (27, 16),
    (27, 17),
    (27, 18),
    (28, 19),
    (28, 20),
    (28, 21),
    (28, 22);

INSERT INTO
    COMENTARIO (
        id_internacion,
        fecha_hora,
        descripcion,
        id_recorrido
    )
VALUES (
        71,
        '2020-11-18 10:00',
        'Paciente estable.',
        1
    ),
    (
        71,
        '2020-11-17 11:00',
        'Paciente estable.',
        5
    ),
    (
        71,
        '2020-11-18 10:00',
        'Paciente estable.',
        9
    ),
    (
        72,
        '2020-11-17 11:00',
        'Dolor controlado.',
        9
    ),
    (
        72,
        '2020-11-18 10:00',
        'Mucha tos.',
        13
    ),
    (
        72,
        '2020-11-17 11:00',
        'Supervisar, mucho dolor.',
        17
    ),
    (
        73,
        '2020-11-18 10:00',
        'Supervisar, mucho dolor.',
        17
    ),
    (
        73,
        '2020-11-17 11:00',
        'Dolores musculares fuertes',
        21
    ),
    (
        73,
        '2020-11-18 10:00',
        'Dolores musculares fuertes',
        25
    ),
    (
        74,
        '2020-11-17 11:00',
        'Dolores musculares fuertes',
        2
    ),
    (
        74,
        '2020-11-18 10:00',
        'Incapacidad de controlarse',
        6
    ),
    (
        74,
        '2020-11-17 11:00',
        'Paciente inestable.',
        10
    ),
    (
        75,
        '2020-11-18 10:00',
        '100 ml de penicilina',
        14
    ),
    (
        75,
        '2020-11-17 11:00',
        '50 ml de morfina',
        18
    ),
    (
        75,
        '2020-11-18 10:00',
        'Paciente inestable.',
        22
    ),
    (
        76,
        '2020-11-17 11:00',
        'Paciente inestable.',
        3
    ),
    (
        76,
        '2020-11-18 10:00',
        'Paciente mejorando significativamente.',
        7
    ),
    (
        76,
        '2020-11-17 11:00',
        'Pronta alta.',
        11
    ),
    (
        77,
        '2020-11-18 10:00',
        'Sin comentarios.',
        11
    ),
    (
        77,
        '2020-11-17 11:00',
        'Buen progreso.',
        15
    ),
    (
        77,
        '2020-11-18 10:00',
        'Recaida, mucho dolor.',
        19
    ),
    (
        78,
        '2020-11-17 11:00',
        'Dolores en pie derecho.',
        19
    ),
    (
        78,
        '2020-11-18 10:00',
        'Dolores en pie izquierdo.',
        23
    ),
    (
        78,
        '2020-11-17 11:00',
        'Dolor de cabeza fuerte.',
        27
    ),
    (
        79,
        '2020-11-18 10:00',
        'Dolor de cabeza fuerte.',
        4
    ),
    (
        79,
        '2020-11-17 11:00',
        'Migraña fuerte.',
        8
    ),
    (
        79,
        '2020-11-18 10:00',
        'Migraña fuerte.',
        12
    ),
    (
        80,
        '2020-11-17 11:00',
        'Migraña fuerte.',
        16
    ),
    (
        80,
        '2020-11-18 10:00',
        'Buen progreso.',
        20
    ),
    (
        80,
        '2020-11-17 11:00',
        'Buen progreso.',
        28
    );

INSERT INTO
    VACACION (
        nro_matricula,
        fecha_inicio,
        fecha_fin
    )
VALUES (
        '1001',
        '2025-01-01',
        '2025-01-15'
    ),
    (
        '1002',
        '2025-02-01',
        '2025-02-15'
    ),
    (
        '1003',
        '2025-03-01',
        '2025-03-15'
    ),
    (
        '1004',
        '2025-04-01',
        '2025-04-15'
    ),
    (
        '1005',
        '2025-05-01',
        '2025-05-15'
    ),
    (
        '1006',
        '2025-06-01',
        '2025-06-15'
    ),
    (
        '1007',
        '2025-07-01',
        '2025-07-15'
    ),
    (
        '1008',
        '2025-08-01',
        '2025-08-15'
    ),
    (
        '1009',
        '2025-09-01',
        '2025-09-15'
    ),
    (
        '1010',
        '2025-10-01',
        '2025-10-15'
    );

INSERT INTO
    ESPECIALIDAD_TIENE_TURNOGUARDIA (
        id_especialidad,
        id_turno_guardia
    )
VALUES (1, 1),
    (1, 2),
    (1, 3),
    (2, 1),
    (2, 2),
    (2, 3),
    (3, 1),
    (3, 2),
    (3, 3);










