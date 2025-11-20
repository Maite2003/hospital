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