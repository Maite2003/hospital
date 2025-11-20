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
