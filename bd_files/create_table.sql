-- ===========================================
-- CREACIÓN DE TABLAS BASE
-- ===========================================

CREATE TABLE PERSONA (
    nro_dni BIGINT PRIMARY KEY,
    CHECK (
        nro_dni BETWEEN 1000000 AND 99999999
    ),
    nombre VARCHAR(50) NOT NULL,
    apellido VARCHAR(50) NOT NULL
);

CREATE TABLE USUARIO (
    username VARCHAR(50) PRIMARY KEY,
    password VARCHAR(50) NOT NULL,
    puede_mod_guardia BOOLEAN DEFAULT FALSE,
    nro_dni BIGINT UNIQUE NOT NULL,
    FOREIGN KEY (nro_dni) REFERENCES PERSONA (nro_dni)
);

CREATE TABLE PACIENTE (
    nro_dni BIGINT PRIMARY KEY,
    sexo CHAR(1) CHECK (sexo IN ('M', 'F', 'X')),
    fecha_nac DATE NOT NULL,
    FOREIGN KEY (nro_dni) REFERENCES PERSONA (nro_dni)
);

CREATE TABLE MEDICO (
    nro_matricula BIGINT PRIMARY KEY,
    fecha_ingreso DATE NOT NULL,
    foto BYTEA NOT NULL,
    cuil BIGINT UNIQUE NOT NULL,
    cuit BIGINT UNIQUE NOT NULL,
    nro_dni BIGINT UNIQUE NOT NULL,
    FOREIGN KEY (nro_dni) REFERENCES PERSONA (nro_dni)
);

CREATE OR REPLACE FUNCTION validar_medico()
RETURNS TRIGGER AS $$
BEGIN
    -- 1. Fecha de ingreso lógica
    IF NEW.fecha_ingreso > CURRENT_DATE OR NEW.fecha_ingreso < CURRENT_DATE - INTERVAL '100 years' THEN
        RAISE EXCEPTION 'Fecha de ingreso inválida';
    END IF;

    -- 2. CUIL central debe coincidir con nro_dni
    IF SUBSTRING(NEW.cuil::text FROM 3 FOR 8)::BIGINT <> NEW.nro_dni THEN
        RAISE EXCEPTION 'CUIL no coincide con DNI';
    END IF;

    -- 3. CUIL y CUIT positivos y 11 dígitos
    IF NEW.cuil <= 0 OR char_length(NEW.cuil::text) <> 11 THEN
        RAISE EXCEPTION 'CUIL inválido';
    END IF;
    IF NEW.cuit <= 0 OR char_length(NEW.cuit::text) <> 11 THEN
        RAISE EXCEPTION 'CUIT inválido';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validar_medico
BEFORE INSERT OR UPDATE ON MEDICO
FOR EACH ROW
EXECUTE FUNCTION validar_medico();

CREATE TABLE ESPECIALIDAD (
    id_especialidad SERIAL PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL UNIQUE

-- TODO --
-- CONSULTAR SI DEBERIA SER UNIQUE EL NOMBRE --
-- NO LO DECLARAMOS ASI--

);

-- ===========================================
-- RELACIONES DE MÉDICO Y ESPECIALIDAD
-- ===========================================

CREATE TABLE MED_TIENE_ESP (
    id_especialidad INT NOT NULL,
    nro_matricula BIGINT NOT NULL,
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
    CHECK (hora_fin > hora_inicio),
    CONSTRAINT uq_horario_guardia UNIQUE (hora_inicio, hora_fin)
);

CREATE OR REPLACE FUNCTION evitar_solapamiento_turno_guardia()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM TURNOGUARDIA
        WHERE id_turno_guardia <> NEW.id_turno_guardia
          AND NOT (NEW.hora_fin <= hora_inicio OR NEW.hora_inicio >= hora_fin)
    ) THEN
        RAISE EXCEPTION 'El turno se solapa con otro existente';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_evitar_solapamiento_turno_guardia
BEFORE INSERT OR UPDATE ON TURNOGUARDIA
FOR EACH ROW
EXECUTE FUNCTION evitar_solapamiento_turno_guardia();

-- NO LO DECLARAMOS ASI--
-- TODO --
-- LOS TURNOS GUARDIAS SE PODRIAN SOLAPAR ???? --

CREATE TABLE GUARDIA (
    id_guardia SERIAL PRIMARY KEY,
    fecha DATE NOT NULL,
    -- TODO --
    -- CONSULTAR --
    -- PODRIAMOS FORZAR QUE SEA FECHA FUTURA, --
    -- PERO SI SE OLVIDAN ALGUN DIA ES UN PROBLEMA --
    id_especialidad INT NOT NULL,
    nro_matricula BIGINT NOT NULL,
    FOREIGN KEY (
        id_especialidad,
        nro_matricula
    ) REFERENCES MED_TIENE_ESP (
        id_especialidad,
        nro_matricula
    )
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

CREATE OR REPLACE FUNCTION evitar_solapamiento_turno_ronda()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM TURNORONDA
        WHERE id_turno_ronda <> NEW.id_turno_ronda
          AND NOT (NEW.hora_fin <= hora_inicio OR NEW.hora_inicio >= hora_fin)
    ) THEN
        RAISE EXCEPTION 'El turno se solapa con otro existente';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_evitar_solapamiento_turno_ronda
BEFORE INSERT OR UPDATE ON TURNORONDA
FOR EACH ROW
EXECUTE FUNCTION evitar_solapamiento_turno_ronda();

-- NO LO DECLARAMOS ASI--
-- TODO --
-- LOS TURNOS RONDA SE PODRIAN SOLAPAR ???? --

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

-- TODO --
-- CONSULTAR SI DEBERIA SER UNIQUE EL NOMBRE --
-- NO LO DECLARAMOS ASI--

);

CREATE TABLE HABITACION (
    id_habitacion SERIAL PRIMARY KEY,
    piso INT NOT NULL,
    CHECK (piso >= 0),
    orientacion CHAR(1),
    CHECK (
        orientacion IN ('N', 'S', 'E', 'O')
    ),
    id_sector INT NOT NULL,
    FOREIGN KEY (id_sector) REFERENCES SECTOR (id_sector)
);

CREATE TABLE CAMA (
    id_cama SERIAL,
    id_habitacion INT NOT NULL,
    esta_libre BOOLEAN DEFAULT TRUE,
    PRIMARY KEY (id_cama, id_habitacion),
    FOREIGN KEY (id_habitacion) REFERENCES HABITACION (id_habitacion)
);

-- TODO --
-- PROBLEMA DE SEGURIDAD, SI ALGUIEN ACTUALIZA --
-- ESTA_LIBRE A MANO PUEDE ROMPER LA BD --

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
    nro_matricula BIGINT NOT NULL,
    nro_dni BIGINT NOT NULL,
    FOREIGN KEY (nro_matricula) REFERENCES MEDICO (nro_matricula),
    FOREIGN KEY (nro_dni) REFERENCES PACIENTE (nro_dni)
);

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
-- TODO --
--  CHEQUEAR PORQUE SI YO ASIGNO FECHA DE FINALIZACION CUANDO LO CREO ESTO NUNCA SE DISPARARIA--
-- ASI COMO ESTA FUNCIONA PERO NO PARA TODOS LOS CASOS --
EXECUTE FUNCTION liberar_ultima_cama_internacion();

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

-- ===========================================
-- RONDAS Y RECORRIDOS
-- ===========================================

CREATE TABLE RECORRIDO (
    id_recorrido SERIAL PRIMARY KEY,
    fecha DATE NOT NULL,
    -- TODO --
    -- PODRIAMOS FORZAR QUE SEA FECHA FUTURA, --
    -- PERO SI SE OLVIDAN ALGUN DIA ES UN PROBLEMA --
    id_ronda INT NOT NULL,
    nro_matricula BIGINT NOT NULL,
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
    CHECK (fecha_hora <= CURRENT_DATE) descripcion TEXT,
    id_recorrido INT NOT NULL,
    PRIMARY KEY (id_internacion, id_comentario),
    FOREIGN KEY (id_internacion) REFERENCES INTERNACION (id_internacion),
    FOREIGN KEY (id_recorrido) REFERENCES RECORRIDO (id_recorrido)
);

-- ===========================================
-- VACACIONES DE MÉDICOS
-- ===========================================

CREATE TABLE VACACION (
    nro_matricula BIGINT NOT NULL,
    id_vacacion SERIAL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    CHECK (fecha_fin > fecha_inicio),
    PRIMARY KEY (nro_matricula, id_vacacion),
    FOREIGN KEY (nro_matricula) REFERENCES MEDICO (nro_matricula)
);

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