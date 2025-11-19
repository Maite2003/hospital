-- ===========================================
-- LISTADO CAMAS DISPONIBLES
-- ===========================================

/* CREATE OR REPLACE FUNCTION listar_cantidad_camas_libres()
RETURNS TABLE(
    nombre_sector VARCHAR,
    cantidad_camas_libres INT
) AS $$
BEGIN
    RETURN QUERY
    SELECT s.nombre_sector,
           COUNT(*) AS cantidad_camas_libres
    FROM SECTOR s
    JOIN HABITACION h ON h.id_sector = s.id_sector
    JOIN CAMA c ON c.id_habitacion = h.id_habitacion
    WHERE c.esta_libre = TRUE
    GROUP BY s.nombre_sector
    ORDER BY s.nombre_sector;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION listar_detalle_camas_libres()
RETURNS TABLE(
    nombre_sector VARCHAR,
    id_habitacion INT,
    id_cama INT,
    esta_libre BOOLEAN
) AS $$
BEGIN
    RETURN QUERY
    SELECT s.nombre_sector,
           h.id_habitacion,
           c.id_cama,
           c.esta_libre
    FROM SECTOR s
    JOIN HABITACION h ON h.id_sector = s.id_sector
    JOIN CAMA c ON c.id_habitacion = h.id_habitacion
    WHERE c.esta_libre = TRUE
    ORDER BY s.nombre_sector, h.id_habitacion, c.id_cama;
END;
$$ LANGUAGE plpgsql;
 */

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

/* CREATE OR REPLACE FUNCTION obtener_comentarios_paciente_internacion(
  p_id_internacion INT
)
RETURNS TABLE(
  id_comentario INT,
  fecha_hora TIMESTAMP,
  descripcion TEXT,
  id_recorrido INT
) AS $$
BEGIN
  RETURN QUERY
  SELECT c.id_comentario,
          c.fecha_hora,
          c.descripcion,
          c.id_recorrido
  FROM COMENTARIO c
  JOIN INTERNACION i ON c.id_internacion = i.id_internacion
  WHERE i.id_internacion = p_id_internacion
  ORDER BY c.fecha_hora;
END;
$$ LANGUAGE plpgsql;
 */

CREATE OR REPLACE FUNCTION listar_comentarios_internacion(p_id_internacion INT)
RETURNS TABLE(
    id_internacion INT,
    fecha_hora_inicio_int TIMESTAMP,
    fecha_hora_fin_int TIMESTAMP,

    nro_dni BIGINT,
    nombre VARCHAR,
    apellido VARCHAR,

    id_comentario INT,
    fecha_hora_comentario TIMESTAMP,
    descripcion TEXT,

    nro_matricula BIGINT,
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
-- AUDOTORIAS CAMBIO GUARDIAS
-- ===========================================

CREATE OR REPLACE FUNCTION listar_modificaciones_guardia()
RETURNS TABLE(
    username VARCHAR,
    id_guardia INT,
    fecha_hora_mod TIMESTAMP,
    descripcion TEXT,
    fecha_guardia DATE,
    especialidad VARCHAR,
    nro_matricula BIGINT,
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
-- RELACIONES ENTRE GUARDIAS, TURNOS Y ESPECIALIDADES
-- ===========================================