-- ===========================================
-- TRANSACCIÓN CREAR INTERNACIÓN Y ASIGNAR CAMA INICIAL
-- ===========================================
BEGIN;

-- 1. Crear internación
INSERT INTO INTERNACION (fecha_hora_inicio, nro_matricula, nro_dni)
VALUES (NOW(), :matricula, :dni)
RETURNING id_internacion;

-- 2. Asignar cama inicial
INSERT INTO INTERNACION_CAMA (fecha_hora_asignacion, id_internacion, id_habitacion, id_cama)
VALUES (
    NOW(),
    currval('internacion_id_internacion_seq'),  -- Última internación creada
    :id_habitacion,
    :id_cama
);

COMMIT;

-- ===========================================
-- TRANSACCIÓN FINALIZAR INTERNACIÓN Y LIBERAR CAMA
-- ===========================================
BEGIN;

UPDATE INTERNACION
SET fecha_hora_fin = NOW()
WHERE id_internacion = :id_internacion;

-- El trigger: libera la última cama usada

COMMIT;

-- ===========================================
-- TRANSACCIÓN CAMBIAR CAMA DE INTERNACIÓN
-- ===========================================
BEGIN;

INSERT INTO INTERNACION_CAMA (fecha_hora_asignacion, id_internacion, id_habitacion, id_cama)
VALUES (
    NOW(),
    :id_internacion,
    :nueva_habitacion,
    :nueva_cama
);

-- El trigger hace:
--   ✔ liberar la última cama
--   ✔ verificar que la nueva esté libre
--   ✔ ocupar la nueva

COMMIT;
