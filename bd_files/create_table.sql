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
    nro_matricula VARCHAR(8) NOT NULL,
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
    nro_matricula VARCHAR(8) NOT NULL,
    id_vacacion SERIAL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    CHECK (fecha_fin > fecha_inicio),
    PRIMARY KEY (nro_matricula, id_vacacion),
    FOREIGN KEY (nro_matricula) REFERENCES MEDICO (nro_matricula)
);
