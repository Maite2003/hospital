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

-- ===========================================
-- LISTADO INTERNACIONES
-- ===========================================

CREATE OR REPLACE FUNCTION listar_internaciones()
RETURNS TABLE(
    id_internacion INT,
    fecha_hora_inicio TIMESTAMP,
    fecha_hora_fin TIMESTAMP

    nro_dni VARCHAR,
    nombre_paciente VARCHAR,
    apellido_paciente VARCHAR,
    sexo CHAR,
    fecha_nac DATE,

    nro_matricula VARCHAR(4),
    nombre_medico VARCHAR,
    apellido_medico VARCHAR,

    id_cama INT,
    id_habitacion INT,
    piso INT,
    orientacion CHAR,
    nombre_sector VARCHAR,
    fecha_hora_asignacion TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        i.id_internacion,
        i.fecha_hora_inicio,
        i.fecha_hora_fin,

        -- Paciente
        p.nro_dni,
        p.nombre AS nombre_paciente,
        p.apellido AS apellido_paciente,
        pa.sexo,
        pa.fecha_nac,

        -- Médico responsable
        m.nro_matricula,
        per.nombre AS nombre_medico,
        per.apellido AS apellido_medico,

        -- Última cama asignada
        c.id_cama,
        h.id_habitacion,
        h.piso,
        h.orientacion,
        s.nombre_sector,
        ic.fecha_hora_asignacion

    FROM INTERNACION i
    JOIN PACIENTE pa ON pa.nro_dni = i.nro_dni
    JOIN PERSONA p ON p.nro_dni = pa.nro_dni

    JOIN MEDICO m ON m.nro_matricula = i.nro_matricula
    JOIN PERSONA per ON per.nro_dni = m.nro_dni

    -- Última cama asignada (LATERAL subquery)
    JOIN LATERAL (
        SELECT *
        FROM INTERNACION_CAMA ic2
        WHERE ic2.id_internacion = i.id_internacion
        ORDER BY ic2.fecha_hora_asignacion DESC
        LIMIT 1
    ) ic ON true

    JOIN CAMA c ON c.id_cama = ic.id_cama AND c.id_habitacion = ic.id_habitacion
    JOIN HABITACION h ON h.id_habitacion = c.id_habitacion
    JOIN SECTOR s ON s.id_sector = h.id_sector

    ORDER BY i.fecha_hora_inicio;
END;
$$ LANGUAGE plpgsql;
