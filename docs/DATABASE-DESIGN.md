# 🗄️ Diseño de Base de Datos - TaskManager

> **Motor:** MySQL 8+  
> **ORM:** TypeORM  
> **Charset:** utf8mb4  
> **Última actualización:** Enero 2025

---

## 📐 Arquitectura de Organización

TaskManager utiliza una jerarquía de 3 niveles para organizar tareas, donde **cada nivel es opcional**:

```
📦 BANDEJA DE ENTRADA (Tareas sin clasificar / huérfanas)
│
├── 📁 TEMA: Trabajo
│   │   └── [Tareas directas del tema]
│   │
│   ├── 📂 SUBTEMA: Soporte
│   │   │   └── [Tareas del subtema]
│   │   │
│   │   ├── 📄 SECCIÓN: Tickets pendientes
│   │   │       └── [Tareas de la sección]
│   │   ├── 📄 SECCIÓN: Esperando respuesta
│   │   └── 📄 SECCIÓN: Revisiones
│   │
│   ├── 📂 SUBTEMA: Proyecto X
│   │   ├── 📄 SECCIÓN: Requerimientos
│   │   └── 📄 SECCIÓN: Investigación
│   │
│   └── 📂 SUBTEMA: Ideas
│
└── 📁 TEMA: Vida Personal
    ├── 📂 SUBTEMA: Salud
    └── 📂 SUBTEMA: Finanzas
```

### Reglas de Asignación de Tareas

| Escenario | tema_id | subtema_id | seccion_id | Nombre |
|-----------|---------|------------|------------|--------|
| Tarea sin clasificar | NULL | NULL | NULL | **Huérfana** |
| Solo en tema | ✓ | NULL | NULL | En tema |
| En tema y subtema | ✓ | ✓ | NULL | En subtema |
| Clasificación completa | ✓ | ✓ | ✓ | En sección |

**Restricción:** Si `seccion_id` está definido, `subtema_id` debe estar definido. Si `subtema_id` está definido, `tema_id` debe estar definido.

---

## 📊 Diagrama Entidad-Relación

```
┌─────────────────────────────────────────────────────────────────────────┐
│                              USUARIOS                                    │
├─────────────────────────────────────────────────────────────────────────┤
│ PK  id                    INT AUTO_INCREMENT                            │
│     nombre                VARCHAR(100) NOT NULL                         │
│ UK  email                 VARCHAR(255) NOT NULL UNIQUE                  │
│     password_hash         VARCHAR(255) NOT NULL                         │
│     avatar_url            TEXT NULL                                     │
│     notificaciones_email  BOOLEAN DEFAULT TRUE                          │
│     notificaciones_push   BOOLEAN DEFAULT FALSE                         │
│     created_at            TIMESTAMP DEFAULT CURRENT_TIMESTAMP           │
│     updated_at            TIMESTAMP ON UPDATE CURRENT_TIMESTAMP         │
│     last_login            TIMESTAMP NULL                                │
└───────────────────────────────┬─────────────────────────────────────────┘
                                │ 1
                                │
        ┌───────────────────────┼───────────────────────┐
        │                       │                       │
        ▼ N                     ▼ N                     ▼ 1
┌───────────────┐       ┌───────────────┐       ┌───────────────┐
│    TEMAS      │       │    TAREAS     │       │ ESTADISTICAS  │
└───────┬───────┘       └───────┬───────┘       └───────────────┘
        │ 1                     │ 1
        │                       │
        ▼ N                     ├──────────────┬──────────────┐
┌───────────────┐               │              │              │
│   SUBTEMAS    │               ▼ N            ▼ N            ▼ N
└───────┬───────┘       ┌───────────────┐┌───────────┐┌───────────────┐
        │ 1             │   ACCIONES    ││   NOTAS   ││NOTIFICACIONES │
        │               └───────────────┘└───────────┘└───────────────┘
        ▼ N
┌───────────────┐               │ M
│   SECCIONES   │               │
└───────────────┘               ▼ N
                        ┌───────────────┐
                        │  RELACIONES   │
                        │    TAREAS     │
                        └───────────────┘
```

---

## 📋 Especificación de Tablas

### 1. Tabla: `usuarios`

**Descripción:** Almacena información de los usuarios del sistema.

```sql
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
```

| Columna | Tipo | Restricciones | Descripción |
|---------|------|---------------|-------------|
| id | INT | PK, AUTO_INCREMENT | Identificador único |
| nombre | VARCHAR(100) | NOT NULL | Nombre completo |
| email | VARCHAR(255) | UNIQUE, NOT NULL | Email de acceso |
| password_hash | VARCHAR(255) | NOT NULL | Contraseña (bcrypt) |
| avatar_url | TEXT | NULL | URL del avatar |
| notificaciones_email | BOOLEAN | DEFAULT TRUE | Preferencia email |
| notificaciones_push | BOOLEAN | DEFAULT FALSE | Preferencia push |
| created_at | TIMESTAMP | DEFAULT NOW | Fecha de registro |
| updated_at | TIMESTAMP | ON UPDATE | Última actualización |
| last_login | TIMESTAMP | NULL | Último login |

---

### 2. Tabla: `temas`

**Descripción:** Nivel 1 de organización. Categorías principales (ej: Trabajo, Vida Personal).

```sql
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
```

| Columna | Tipo | Restricciones | Descripción |
|---------|------|---------------|-------------|
| id | INT | PK, AUTO_INCREMENT | Identificador único |
| usuario_id | INT | FK → usuarios(id), NOT NULL | Propietario |
| nombre | VARCHAR(100) | NOT NULL, UNIQUE por usuario | Nombre del tema |
| color | VARCHAR(20) | DEFAULT '#3B82F6' | Color hexadecimal |
| codigo | VARCHAR(20) | NULL | Código corto (ej: TRB) |
| icono | VARCHAR(10) | DEFAULT '📁' | Emoji representativo |
| orden | INT | DEFAULT 0 | Orden de visualización |
| created_at | TIMESTAMP | DEFAULT NOW | Fecha de creación |
| updated_at | TIMESTAMP | ON UPDATE | Última actualización |

**Comportamiento CASCADE:** Si se elimina un usuario, se eliminan todos sus temas.

---

### 3. Tabla: `subtemas`

**Descripción:** Nivel 2 de organización. Subcategorías dentro de un tema.

```sql
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
```

| Columna | Tipo | Restricciones | Descripción |
|---------|------|---------------|-------------|
| id | INT | PK, AUTO_INCREMENT | Identificador único |
| tema_id | INT | FK → temas(id), NOT NULL | Tema padre |
| nombre | VARCHAR(100) | NOT NULL, UNIQUE por tema | Nombre del subtema |
| color | VARCHAR(20) | DEFAULT '#10B981' | Color hexadecimal |
| icono | VARCHAR(10) | DEFAULT '📂' | Emoji representativo |
| orden | INT | DEFAULT 0 | Orden de visualización |
| created_at | TIMESTAMP | DEFAULT NOW | Fecha de creación |
| updated_at | TIMESTAMP | ON UPDATE | Última actualización |

**Comportamiento CASCADE:** Si se elimina un tema, se eliminan todos sus subtemas.

---

### 4. Tabla: `secciones`

**Descripción:** Nivel 3 de organización. Secciones dentro de un subtema.

```sql
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
```

| Columna | Tipo | Restricciones | Descripción |
|---------|------|---------------|-------------|
| id | INT | PK, AUTO_INCREMENT | Identificador único |
| subtema_id | INT | FK → subtemas(id), NOT NULL | Subtema padre |
| nombre | VARCHAR(100) | NOT NULL, UNIQUE por subtema | Nombre de la sección |
| color | VARCHAR(20) | DEFAULT '#F59E0B' | Color hexadecimal |
| icono | VARCHAR(10) | DEFAULT '📄' | Emoji representativo |
| orden | INT | DEFAULT 0 | Orden de visualización |
| created_at | TIMESTAMP | DEFAULT NOW | Fecha de creación |
| updated_at | TIMESTAMP | ON UPDATE | Última actualización |

**Comportamiento CASCADE:** Si se elimina un subtema, se eliminan todas sus secciones.

---

### 5. Tabla: `tareas`

**Descripción:** Tareas/TODOs del usuario. Pueden estar en cualquier nivel de la jerarquía o sin clasificar.

```sql
CREATE TABLE tareas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id INT NOT NULL,
    
    -- Jerarquía de organización (todos opcionales)
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
    INDEX idx_tareas_updated (usuario_id, updated_at DESC)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

| Columna | Tipo | Restricciones | Descripción |
|---------|------|---------------|-------------|
| id | INT | PK, AUTO_INCREMENT | Identificador único |
| usuario_id | INT | FK, NOT NULL | Propietario |
| tema_id | INT | FK, NULL | Tema asociado (opcional) |
| subtema_id | INT | FK, NULL | Subtema asociado (opcional) |
| seccion_id | INT | FK, NULL | Sección asociada (opcional) |
| titulo | VARCHAR(255) | NOT NULL | Título de la tarea |
| descripcion | TEXT | NULL | Descripción detallada |
| categoria | ENUM | NULL | ticket, idea, asignacion |
| info | JSON | NULL | Metadata según categoría |
| estado | ENUM | DEFAULT 'pendiente' | Estado actual |
| prioridad | ENUM | DEFAULT 'media' | Nivel de prioridad |
| puntos_importancia | INT | DEFAULT 0 | Contador de clicks (+/-) |
| criticidad_calculada | DECIMAL(5,2) | GENERATED | Score automático |
| fecha_entrega | TIMESTAMP | NULL | Fecha límite |
| fecha_completado | TIMESTAMP | NULL | Cuándo se completó |
| created_at | TIMESTAMP | DEFAULT NOW | Fecha de creación |
| updated_at | TIMESTAMP | ON UPDATE | Última actualización |

#### Estructuras JSON por Categoría

**Categoría: `ticket`**
```json
{
  "nombre_ticket": "INC-12345",
  "fuente": "correo",
  "links": [
    {
      "tipo": "principal",
      "url": "https://servicedesk.com/INC-12345",
      "titulo": "Ticket ServiceDesk"
    },
    {
      "tipo": "derivado",
      "url": "https://jira.com/TASK-789",
      "titulo": "Tarea Jira relacionada"
    }
  ]
}
```

**Categoría: `idea`**
```json
{
  "nombre_idea": "Automatizar reportes semanales",
  "sistema_relacionado": "Sistema de reportes",
  "origen": "propia",
  "estado_compartir": "pendiente",
  "notas_origen": "Surgió en reunión del 15/12"
}
```

**Categoría: `asignacion`**
```json
{
  "nombre_asignacion": "Revisar código PR #234",
  "con_ticket": true,
  "ticket_asociado": "TASK-567",
  "fuente": "clickup",
  "asignador": "Juan Pérez",
  "fecha_asignacion": "2025-01-10T09:00:00Z"
}
```

---

### 6. Tabla: `acciones`

**Descripción:** Historial de acciones/pasos asociados a una tarea.

```sql
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
    
    CONSTRAINT chk_relevancia CHECK (relevancia BETWEEN 0 AND 10)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

| Columna | Tipo | Restricciones | Descripción |
|---------|------|---------------|-------------|
| id | INT | PK, AUTO_INCREMENT | Identificador único |
| tarea_id | INT | FK, NOT NULL | Tarea asociada |
| nombre | VARCHAR(255) | NOT NULL | Nombre de la acción |
| descripcion | TEXT | NULL | Descripción detallada |
| completada | BOOLEAN | DEFAULT FALSE | ¿Está completada? |
| fecha_completado | TIMESTAMP | NULL | Cuándo se completó |
| relevancia | INT | DEFAULT 0, CHECK 0-10 | Nivel de relevancia |
| es_siguiente | BOOLEAN | DEFAULT FALSE | Marcador próxima acción (🟢) |
| motivo_cambio_siguiente | TEXT | NULL | Razón del cambio (🟡) |
| fecha_cambio_siguiente | TIMESTAMP | NULL | Cuándo cambió |
| es_destacada | BOOLEAN | DEFAULT FALSE | ¿Está destacada? |
| icono_destacado | VARCHAR(50) | NULL | Icono: 📧⚡✅📞🔄📝🚀 |
| created_at | TIMESTAMP | DEFAULT NOW | Fecha de creación |
| updated_at | TIMESTAMP | ON UPDATE | Última actualización |

**Regla de negocio:** Solo puede haber UNA acción con `es_siguiente = TRUE` por tarea.

---

### 7. Tabla: `notas`

**Descripción:** Notas generales asociadas a una tarea.

```sql
CREATE TABLE notas (
    id INT AUTO_INCREMENT PRIMARY KEY,
    tarea_id INT NOT NULL,
    contenido TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    
    FOREIGN KEY (tarea_id) REFERENCES tareas(id) ON DELETE CASCADE,
    INDEX idx_notas_tarea (tarea_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

| Columna | Tipo | Restricciones | Descripción |
|---------|------|---------------|-------------|
| id | INT | PK, AUTO_INCREMENT | Identificador único |
| tarea_id | INT | FK, NOT NULL | Tarea asociada |
| contenido | TEXT | NOT NULL | Texto de la nota |
| created_at | TIMESTAMP | DEFAULT NOW | Fecha de creación |
| updated_at | TIMESTAMP | ON UPDATE | Última actualización |

---

### 8. Tabla: `relaciones_tareas`

**Descripción:** Relaciones entre tareas (bloquea, relacionada, duplicada, etc.).

```sql
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
```

| Columna | Tipo | Restricciones | Descripción |
|---------|------|---------------|-------------|
| id | INT | PK, AUTO_INCREMENT | Identificador único |
| tarea_origen_id | INT | FK, NOT NULL | Tarea de origen |
| tarea_destino_id | INT | FK, NOT NULL | Tarea de destino |
| tipo_relacion | ENUM | DEFAULT 'relacionada' | Tipo de relación |
| descripcion | VARCHAR(255) | NULL | Descripción opcional |
| created_at | TIMESTAMP | DEFAULT NOW | Fecha de creación |

**Tipos de relación:**
- `relacionada` - Relación genérica
- `bloquea` - Esta tarea bloquea a la otra
- `bloqueada_por` - Esta tarea está bloqueada por la otra
- `duplicada` - Las tareas son duplicados
- `padre` - Esta tarea es padre de la otra
- `hija` - Esta tarea es hija de la otra

---

### 9. Tabla: `registros_apertura`

**Descripción:** Registro de las últimas 3 aperturas de cada card.

```sql
CREATE TABLE registros_apertura (
    id INT AUTO_INCREMENT PRIMARY KEY,
    tarea_id INT NOT NULL,
    usuario_id INT NOT NULL,
    fecha_apertura TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    FOREIGN KEY (tarea_id) REFERENCES tareas(id) ON DELETE CASCADE,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE,
    
    INDEX idx_apertura_tarea (tarea_id, fecha_apertura DESC)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

| Columna | Tipo | Restricciones | Descripción |
|---------|------|---------------|-------------|
| id | INT | PK, AUTO_INCREMENT | Identificador único |
| tarea_id | INT | FK, NOT NULL | Tarea abierta |
| usuario_id | INT | FK, NOT NULL | Usuario que abrió |
| fecha_apertura | TIMESTAMP | DEFAULT NOW | Cuándo se abrió |

**Regla de negocio:** El backend debe mantener solo las últimas 3 aperturas por tarea, eliminando las más antiguas.

---

### 10. Tabla: `notificaciones`

**Descripción:** Notificaciones generadas (email, push, browser).

```sql
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
    
    CONSTRAINT chk_intentos CHECK (intentos <= 5)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

| Columna | Tipo | Restricciones | Descripción |
|---------|------|---------------|-------------|
| id | INT | PK, AUTO_INCREMENT | Identificador único |
| usuario_id | INT | FK, NOT NULL | Destinatario |
| tarea_id | INT | FK, NULL | Tarea asociada (opcional) |
| tipo | ENUM | NOT NULL | email, push, browser |
| estado | ENUM | DEFAULT 'pendiente' | Estado de envío |
| contenido | TEXT | NOT NULL | Mensaje |
| fecha_programada | TIMESTAMP | NOT NULL | Cuándo enviar |
| fecha_enviada | TIMESTAMP | NULL | Cuándo se envió |
| leida | BOOLEAN | DEFAULT FALSE | ¿Fue leída? |
| fecha_leida | TIMESTAMP | NULL | Cuándo se leyó |
| intentos | INT | DEFAULT 0, MAX 5 | Reintentos |
| ultimo_error | TEXT | NULL | Último error |
| created_at | TIMESTAMP | DEFAULT NOW | Fecha de creación |

---

### 11. Tabla: `recordatorios`

**Descripción:** Sistema de recordatorios recurrentes.

```sql
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
    INDEX idx_recordatorios_estado (estado)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

| Columna | Tipo | Restricciones | Descripción |
|---------|------|---------------|-------------|
| id | INT | PK, AUTO_INCREMENT | Identificador único |
| usuario_id | INT | FK, NOT NULL | Propietario |
| tarea_id | INT | FK, NULL | Tarea (si individual) |
| tipo | ENUM | DEFAULT 'individual' | individual/grupo/general |
| descripcion | TEXT | NOT NULL | Descripción del recordatorio |
| frecuencia_valor | INT | DEFAULT 1 | Cada cuánto |
| frecuencia_unidad | ENUM | DEFAULT 'horas' | Unidad de tiempo |
| hora_inicio | TIME | DEFAULT '09:00' | Inicio ventana |
| hora_fin | TIME | DEFAULT '18:00' | Fin ventana |
| dias_semana | JSON | DEFAULT [1-5] | Días activos (0=Dom, 6=Sáb) |
| estado | ENUM | DEFAULT 'activo' | Estado actual |
| fecha_inicio | TIMESTAMP | DEFAULT NOW | Inicio del recordatorio |
| fecha_fin | TIMESTAMP | NULL | Fin del recordatorio |
| ultima_ejecucion | TIMESTAMP | NULL | Última vez ejecutado |
| proxima_ejecucion | TIMESTAMP | NULL | Próxima ejecución |
| notificar_email | BOOLEAN | DEFAULT TRUE | ¿Notificar por email? |
| notificar_push | BOOLEAN | DEFAULT TRUE | ¿Notificar por push? |
| notificar_browser | BOOLEAN | DEFAULT TRUE | ¿Notificar en browser? |

---

### 12. Tabla: `estadisticas`

**Descripción:** Métricas agregadas por usuario (1:1).

```sql
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
```

---

### 13. Tabla: `logs_sistema`

**Descripción:** Registro completo de acciones para analytics y entrenamiento de IA.

```sql
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
    INDEX idx_logs_tarea (tarea_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

---

## 🔗 Diagrama de Relaciones

```
usuarios (1) ──────┬──────── (N) temas
                   │
                   ├──────── (N) tareas
                   │
                   ├──────── (1) estadisticas
                   │
                   ├──────── (N) notificaciones
                   │
                   ├──────── (N) recordatorios
                   │
                   └──────── (N) logs_sistema

temas (1) ─────────────────── (N) subtemas
                   │
                   └──────── (N) tareas (opcional)

subtemas (1) ──────────────── (N) secciones
                   │
                   └──────── (N) tareas (opcional)

secciones (1) ─────────────── (N) tareas (opcional)

tareas (1) ────────┬──────── (N) acciones
                   │
                   ├──────── (N) notas
                   │
                   ├──────── (N) relaciones_tareas (origen)
                   │
                   ├──────── (N) relaciones_tareas (destino)
                   │
                   ├──────── (N) registros_apertura
                   │
                   ├──────── (N) notificaciones
                   │
                   └──────── (N) recordatorios
```

---

## 📊 Resumen de Tablas

| # | Tabla | Descripción | Relación Principal |
|---|-------|-------------|-------------------|
| 1 | usuarios | Usuarios del sistema | - |
| 2 | temas | Nivel 1 organización | usuarios (1:N) |
| 3 | subtemas | Nivel 2 organización | temas (1:N) |
| 4 | secciones | Nivel 3 organización | subtemas (1:N) |
| 5 | tareas | TODOs del usuario | usuarios, temas?, subtemas?, secciones? |
| 6 | acciones | Pasos de una tarea | tareas (1:N) |
| 7 | notas | Notas de una tarea | tareas (1:N) |
| 8 | relaciones_tareas | Links entre tareas | tareas (M:N) |
| 9 | registros_apertura | Últimas 3 aperturas | tareas (1:N) |
| 10 | notificaciones | Notificaciones | usuarios, tareas? |
| 11 | recordatorios | Recordatorios recurrentes | usuarios, tareas? |
| 12 | estadisticas | Métricas agregadas | usuarios (1:1) |
| 13 | logs_sistema | Auditoría y analytics | usuarios |

**Total: 13 tablas**

---

## 🔧 Script SQL Completo

El script completo para crear la base de datos se encuentra en el archivo `DATABASE-SCHEMA.sql` adjunto.

---

*Documento generado para TaskManager v1.0*
