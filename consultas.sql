-- ===========================================
-- LISTADO CAMAS DISPONIBLES
-- ===========================================

CREATE OR REPLACE FUNCTION listar_cantidad_camas_libres()
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

-- ===========================================
-- LISTADO COMENTARIOS
-- ===========================================

CREATE OR REPLACE FUNCTION obtener_comentarios_paciente_internacion(
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

-- ===========================================
-- AUDOTORIAS CAMBIO GUARDIAS
-- ===========================================

CREATE TABLE USUARIO_MODIFICA_GUARDIA (
    username VARCHAR(50) NOT NULL,
    id_guardia INT NOT NULL,
    fecha_hora TIMESTAMP NOT NULL,
    descripcion TEXT,
    PRIMARY KEY (username, id_guardia),
    FOREIGN KEY (username) REFERENCES USUARIO (username),
    FOREIGN KEY (id_guardia) REFERENCES GUARDIA (id_guardia)
);

-- TODO --
-- VERIFICAR LOGICA DE MODIFICACIONES --
-- ACA SE PUEDE AGREGAR ATRIBUTO DESCRIPCION DONDE EN EL TRIGGER EN GUARDIA

-- SE HACE UN TRIGGER QUE SE EJECUTA CON CUALQUIER TIPO DE ACCION A LA TABLA GUARDIA
-- EXISTEN 3 TIPOS DE CAMBIOS: ALTA, BAJA O UPDATE
-- SI ES UPDATE PUEDEN SER DE DOS TIPOS: ACTUALIZO FECHA O CAMBIO MEDICO
-- EL TRIGGER CREA LA DESCRIPCION DEL CAMBIO (ej: 'el medico con matricula xxxxx fue reemplazado por el emdico con matricula yyyyyyy') Y AGREGA UNA FILA A LA TABLA
-- ESTA TABLA UNICAMENTE LA TOCA EL TRIGGER, NADIE MAS DEBERIA AGREGAR FILAS. SE CREAN AUTOMATICAMENTE

-- ===========================================
-- RELACIONES ENTRE GUARDIAS, TURNOS Y ESPECIALIDADES
-- ===========================================