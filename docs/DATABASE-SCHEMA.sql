-- ============================================================
-- 🗄️ TaskManager - Database Schema
-- Motor: MySQL 8+
-- Charset: utf8mb4
-- Generado: Enero 2025
-- ============================================================

-- Crear base de datos
CREATE DATABASE IF NOT EXISTS taskmanager_db
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE taskmanager_db;

-- ============================================================
-- 1. USUARIOS
-- ============================================================
CREATE TABLE usuarios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    avatar_url TEXT NULL,
    notificaciones_email BOOLEAN DEFAULT TRUE,
    notificaciones_push BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    last_login TIMESTAMP NULL,
    
    INDEX idx_usuarios_email (email),
    INDEX idx_usuarios_created (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 2. TEMAS (Nivel 1 de organización)
-- ============================================================
CREATE TABLE temas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    color VARCHAR(20) DEFAULT '#3B82F6',
    codigo VARCHAR(20) NULL,
    icono VARCHAR(10) DEFAULT '📁',
    orden INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    UNIQUE KEY uk_usuario_tema (usuario_id, nombre),
    INDEX idx_temas_usuario (usuario_id),
    INDEX idx_temas_orden (usuario_id, orden)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 3. SUBTEMAS (Nivel 2 de organización)
-- ============================================================
CREATE TABLE subtemas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    tema_id INT NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    color VARCHAR(20) DEFAULT '#10B981',
    icono VARCHAR(10) DEFAULT '📂',
    orden INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (tema_id) REFERENCES temas(id) ON DELETE CASCADE,
    UNIQUE KEY uk_tema_subtema (tema_id, nombre),
    INDEX idx_subtemas_tema (tema_id),
    INDEX idx_subtemas_orden (tema_id, orden)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 4. SECCIONES (Nivel 3 de organización)
-- ============================================================
CREATE TABLE secciones (
    id INT AUTO_INCREMENT PRIMARY KEY,
    subtema_id INT NOT NULL,
    nombre VARCHAR(100) NOT NULL,
    color VARCHAR(20) DEFAULT '#F59E0B',
    icono VARCHAR(10) DEFAULT '📄',
    orden INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (subtema_id) REFERENCES subtemas(id) ON DELETE CASCADE,
    UNIQUE KEY uk_subtema_seccion (subtema_id, nombre),
    INDEX idx_secciones_subtema (subtema_id),
    INDEX idx_secciones_orden (subtema_id, orden)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 5. TAREAS
-- ============================================================
CREATE TABLE tareas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT NOT NULL,
    
    -- Jerarquía de organización (todos opcionales para permitir huérfanas)
    tema_id INT NULL,
    subtema_id INT NULL,
    seccion_id INT NULL,
    
    -- Información básica
    titulo VARCHAR(255) NOT NULL,
    descripcion TEXT NULL,
    
    -- Categoría y metadata dinámica
    categoria ENUM('ticket', 'idea', 'asignacion') NULL,
    info JSON NULL,
    
    -- Estado y prioridad
    estado ENUM('pendiente', 'en_progreso', 'completada', 'cancelada') DEFAULT 'pendiente',
    prioridad ENUM('alta', 'media', 'baja') DEFAULT 'media',
    
    -- Sistema de importancia (clicks)
    puntos_importancia INT DEFAULT 0,
    
    -- Criticidad calculada (columna generada)
    criticidad_calculada DECIMAL(5,2) AS (
        (puntos_importancia * 10) + 
        CASE prioridad 
            WHEN 'alta' THEN 30 
            WHEN 'media' THEN 20 
            ELSE 10 
        END +
        CASE 
            WHEN fecha_entrega IS NOT NULL AND fecha_entrega < NOW() THEN 50 
            WHEN fecha_entrega IS NOT NULL AND fecha_entrega < DATE_ADD(NOW(), INTERVAL 24 HOUR) THEN 30
            WHEN fecha_entrega IS NOT NULL AND fecha_entrega < DATE_ADD(NOW(), INTERVAL 72 HOUR) THEN 15
            ELSE 0 
        END
    ) STORED,
    
    -- Fechas
    fecha_entrega TIMESTAMP NULL,
    fecha_completado TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    -- Foreign Keys
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    FOREIGN KEY (tema_id) REFERENCES temas(id) ON DELETE SET NULL,
    FOREIGN KEY (subtema_id) REFERENCES subtemas(id) ON DELETE SET NULL,
    FOREIGN KEY (seccion_id) REFERENCES secciones(id) ON DELETE SET NULL,
    
    -- Índices
    INDEX idx_tareas_usuario (usuario_id),
    INDEX idx_tareas_tema (tema_id),
    INDEX idx_tareas_subtema (subtema_id),
    INDEX idx_tareas_seccion (seccion_id),
    INDEX idx_tareas_estado (estado),
    INDEX idx_tareas_categoria (categoria),
    INDEX idx_tareas_prioridad (prioridad),
    INDEX idx_tareas_fecha_entrega (fecha_entrega),
    INDEX idx_tareas_criticidad (usuario_id, criticidad_calculada DESC),
    INDEX idx_tareas_updated (usuario_id, updated_at DESC),
    INDEX idx_tareas_huerfanas (usuario_id, tema_id, estado)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 6. ACCIONES (Historial de pasos por tarea)
-- ============================================================
CREATE TABLE acciones (
    id INT AUTO_INCREMENT PRIMARY KEY,
    tarea_id INT NOT NULL,
    nombre VARCHAR(255) NOT NULL,
    descripcion TEXT NULL,
    
    -- Estado
    completada BOOLEAN DEFAULT FALSE,
    fecha_completado TIMESTAMP NULL,
    
    -- Sistema de relevancia
    relevancia INT DEFAULT 0,
    
    -- Sistema de próxima acción (verde/amarillo)
    es_siguiente BOOLEAN DEFAULT FALSE,
    motivo_cambio_siguiente TEXT NULL,
    fecha_cambio_siguiente TIMESTAMP NULL,
    
    -- Sistema de destacados
    es_destacada BOOLEAN DEFAULT FALSE,
    icono_destacado VARCHAR(50) NULL,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (tarea_id) REFERENCES tareas(id) ON DELETE CASCADE,
    
    INDEX idx_acciones_tarea (tarea_id),
    INDEX idx_acciones_completada (completada),
    INDEX idx_acciones_siguiente (tarea_id, es_siguiente),
    INDEX idx_acciones_destacada (tarea_id, es_destacada),
    INDEX idx_acciones_created (tarea_id, created_at DESC),
    
    CONSTRAINT chk_relevancia CHECK (relevancia BETWEEN 0 AND 10)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 7. NOTAS
-- ============================================================
CREATE TABLE notas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    tarea_id INT NOT NULL,
    contenido TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (tarea_id) REFERENCES tareas(id) ON DELETE CASCADE,
    INDEX idx_notas_tarea (tarea_id),
    INDEX idx_notas_created (tarea_id, created_at DESC)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 8. RELACIONES ENTRE TAREAS
-- ============================================================
CREATE TABLE relaciones_tareas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    tarea_origen_id INT NOT NULL,
    tarea_destino_id INT NOT NULL,
    tipo_relacion ENUM(
        'relacionada', 
        'bloquea', 
        'bloqueada_por', 
        'duplicada', 
        'padre', 
        'hija'
    ) DEFAULT 'relacionada',
    descripcion VARCHAR(255) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (tarea_origen_id) REFERENCES tareas(id) ON DELETE CASCADE,
    FOREIGN KEY (tarea_destino_id) REFERENCES tareas(id) ON DELETE CASCADE,
    
    UNIQUE KEY uk_relacion (tarea_origen_id, tarea_destino_id, tipo_relacion),
    INDEX idx_relaciones_origen (tarea_origen_id),
    INDEX idx_relaciones_destino (tarea_destino_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 9. REGISTROS DE APERTURA (últimas 3 por tarea)
-- ============================================================
CREATE TABLE registros_apertura (
    id INT AUTO_INCREMENT PRIMARY KEY,
    tarea_id INT NOT NULL,
    usuario_id INT NOT NULL,
    fecha_apertura TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (tarea_id) REFERENCES tareas(id) ON DELETE CASCADE,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    
    INDEX idx_apertura_tarea (tarea_id, fecha_apertura DESC)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 10. NOTIFICACIONES
-- ============================================================
CREATE TABLE notificaciones (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT NOT NULL,
    tarea_id INT NULL,
    
    tipo ENUM('email', 'push', 'browser') NOT NULL,
    estado ENUM('pendiente', 'enviada', 'fallida', 'cancelada') DEFAULT 'pendiente',
    
    contenido TEXT NOT NULL,
    fecha_programada TIMESTAMP NOT NULL,
    fecha_enviada TIMESTAMP NULL,
    
    leida BOOLEAN DEFAULT FALSE,
    fecha_leida TIMESTAMP NULL,
    
    intentos INT DEFAULT 0,
    ultimo_error TEXT NULL,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    FOREIGN KEY (tarea_id) REFERENCES tareas(id) ON DELETE CASCADE,
    
    INDEX idx_notif_usuario (usuario_id),
    INDEX idx_notif_tarea (tarea_id),
    INDEX idx_notif_estado (estado),
    INDEX idx_notif_fecha (fecha_programada),
    INDEX idx_notif_leida (usuario_id, leida),
    INDEX idx_notif_pendientes (estado, fecha_programada),
    
    CONSTRAINT chk_intentos CHECK (intentos <= 5)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 11. RECORDATORIOS
-- ============================================================
CREATE TABLE recordatorios (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT NOT NULL,
    tarea_id INT NULL,
    
    tipo ENUM('individual', 'grupo', 'general') DEFAULT 'individual',
    descripcion TEXT NOT NULL,
    
    -- Configuración de frecuencia
    frecuencia_valor INT DEFAULT 1,
    frecuencia_unidad ENUM('minutos', 'horas', 'dias', 'semanas') DEFAULT 'horas',
    
    -- Ventana de tiempo
    hora_inicio TIME DEFAULT '09:00:00',
    hora_fin TIME DEFAULT '18:00:00',
    dias_semana JSON DEFAULT '[1,2,3,4,5]',
    
    -- Control de estado
    estado ENUM('activo', 'pausado', 'completado', 'expirado') DEFAULT 'activo',
    fecha_inicio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_fin TIMESTAMP NULL,
    ultima_ejecucion TIMESTAMP NULL,
    proxima_ejecucion TIMESTAMP NULL,
    
    -- Canales de notificación
    notificar_email BOOLEAN DEFAULT TRUE,
    notificar_push BOOLEAN DEFAULT TRUE,
    notificar_browser BOOLEAN DEFAULT TRUE,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    FOREIGN KEY (tarea_id) REFERENCES tareas(id) ON DELETE CASCADE,
    
    INDEX idx_recordatorios_usuario (usuario_id),
    INDEX idx_recordatorios_tarea (tarea_id),
    INDEX idx_recordatorios_proxima (proxima_ejecucion),
    INDEX idx_recordatorios_estado (estado),
    INDEX idx_recordatorios_activos (estado, proxima_ejecucion)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 12. ESTADÍSTICAS (1:1 con usuarios)
-- ============================================================
CREATE TABLE estadisticas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT NOT NULL UNIQUE,
    
    tareas_completadas INT DEFAULT 0,
    tareas_pendientes INT DEFAULT 0,
    tareas_en_progreso INT DEFAULT 0,
    tareas_canceladas INT DEFAULT 0,
    tareas_a_tiempo INT DEFAULT 0,
    tareas_tarde INT DEFAULT 0,
    
    racha_actual INT DEFAULT 0,
    mejor_racha INT DEFAULT 0,
    
    ultima_actividad TIMESTAMP NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    INDEX idx_estadisticas_usuario (usuario_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 13. LOGS DEL SISTEMA (para analytics y entrenamiento IA)
-- ============================================================
CREATE TABLE logs_sistema (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT NOT NULL,
    tarea_id INT NULL,
    accion_id INT NULL,
    
    tipo_evento ENUM(
        'tarea_creada', 
        'tarea_actualizada', 
        'tarea_completada', 
        'tarea_eliminada',
        'accion_agregada', 
        'accion_completada', 
        'accion_destacada',
        'nota_agregada', 
        'relacion_creada',
        'recordatorio_creado', 
        'recordatorio_ejecutado',
        'card_abierta', 
        'importancia_modificada',
        'proxima_accion_definida', 
        'proxima_accion_modificada',
        'login',
        'logout'
    ) NOT NULL,
    
    datos_antes JSON NULL,
    datos_despues JSON NULL,
    contexto JSON NULL,
    
    ip_address VARCHAR(45) NULL,
    user_agent TEXT NULL,
    tiempo_respuesta_ms INT NULL,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    
    INDEX idx_logs_usuario (usuario_id),
    INDEX idx_logs_tipo (tipo_evento),
    INDEX idx_logs_fecha (created_at),
    INDEX idx_logs_tarea (tarea_id),
    INDEX idx_logs_usuario_fecha (usuario_id, created_at DESC)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- 14. REFRESH TOKENS (para JWT)
-- ============================================================
CREATE TABLE refresh_tokens (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT NOT NULL,
    token VARCHAR(500) NOT NULL UNIQUE,
    expires_at TIMESTAMP NOT NULL,
    revoked BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    INDEX idx_refresh_usuario (usuario_id),
    INDEX idx_refresh_token (token),
    INDEX idx_refresh_expires (expires_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================================
-- TRIGGERS
-- ============================================================

-- Trigger: Crear registro de estadísticas al crear usuario
DELIMITER //
CREATE TRIGGER after_usuario_insert
AFTER INSERT ON usuarios
FOR EACH ROW
BEGIN
    INSERT INTO estadisticas (usuario_id) VALUES (NEW.id);
END//
DELIMITER ;

-- Trigger: Actualizar estadísticas al completar tarea
DELIMITER //
CREATE TRIGGER after_tarea_update
AFTER UPDATE ON tareas
FOR EACH ROW
BEGIN
    IF OLD.estado != 'completada' AND NEW.estado = 'completada' THEN
        UPDATE estadisticas 
        SET 
            tareas_completadas = tareas_completadas + 1,
            tareas_pendientes = GREATEST(tareas_pendientes - 1, 0),
            ultima_actividad = NOW(),
            tareas_a_tiempo = tareas_a_tiempo + IF(NEW.fecha_entrega IS NULL OR NOW() <= NEW.fecha_entrega, 1, 0),
            tareas_tarde = tareas_tarde + IF(NEW.fecha_entrega IS NOT NULL AND NOW() > NEW.fecha_entrega, 1, 0)
        WHERE usuario_id = NEW.usuario_id;
    END IF;
    
    IF OLD.estado = 'completada' AND NEW.estado != 'completada' THEN
        UPDATE estadisticas 
        SET 
            tareas_completadas = GREATEST(tareas_completadas - 1, 0),
            tareas_pendientes = tareas_pendientes + 1
        WHERE usuario_id = NEW.usuario_id;
    END IF;
END//
DELIMITER ;

-- Trigger: Incrementar tareas pendientes al crear tarea
DELIMITER //
CREATE TRIGGER after_tarea_insert
AFTER INSERT ON tareas
FOR EACH ROW
BEGIN
    IF NEW.estado = 'pendiente' OR NEW.estado = 'en_progreso' THEN
        UPDATE estadisticas 
        SET tareas_pendientes = tareas_pendientes + 1
        WHERE usuario_id = NEW.usuario_id;
    END IF;
END//
DELIMITER ;

-- ============================================================
-- DATOS INICIALES (opcional - para testing)
-- ============================================================

-- Usuario de prueba (password: Test123!)
-- INSERT INTO usuarios (nombre, email, password_hash) 
-- VALUES ('Usuario Test', 'test@taskmanager.com', '$2b$10$...');

-- Temas de ejemplo
-- INSERT INTO temas (usuario_id, nombre, color, codigo, icono) VALUES
-- (1, 'Trabajo', '#3B82F6', 'TRB', '💼'),
-- (1, 'Vida Personal', '#10B981', 'PRS', '🏠');

-- ============================================================
-- RESUMEN DE TABLAS
-- ============================================================
-- Total: 14 tablas
-- 
-- 1.  usuarios          - Usuarios del sistema
-- 2.  temas             - Nivel 1 organización
-- 3.  subtemas          - Nivel 2 organización
-- 4.  secciones         - Nivel 3 organización
-- 5.  tareas            - TODOs del usuario
-- 6.  acciones          - Pasos/historial por tarea
-- 7.  notas             - Notas por tarea
-- 8.  relaciones_tareas - Links entre tareas
-- 9.  registros_apertura- Últimas 3 aperturas
-- 10. notificaciones    - Notificaciones
-- 11. recordatorios     - Recordatorios recurrentes
-- 12. estadisticas      - Métricas por usuario
-- 13. logs_sistema      - Auditoría y analytics
-- 14. refresh_tokens    - Tokens JWT
-- ============================================================
