# 📋 API REST - TaskManager

> **Versión:** 1.0  
> **Base URL:** `/api/v1`  
> **Formato:** JSON  
> **Autenticación:** JWT Bearer Token  
> **Última actualización:** Enero 2025

---

## 📐 Convenciones

### Naming Convention
- **Endpoints en español** (coherente con BD): `/temas`, `/subtemas`, `/secciones`, `/tareas`
- **Verbos HTTP estándar:** GET, POST, PUT, PATCH, DELETE
- **IDs en URL:** `/tareas/{id}`
- **Recursos anidados:** `/tareas/{tareaId}/acciones`

### Respuesta Estándar Exitosa
```json
{
  "success": true,
  "data": { },
  "message": "Operación exitosa"
}
```

### Respuesta de Error
```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "Descripción del error",
    "details": { }
  }
}
```

### Respuesta Paginada
```json
{
  "success": true,
  "data": [],
  "pagination": {
    "page": 1,
    "limit": 10,
    "total": 100,
    "totalPages": 10,
    "hasNext": true,
    "hasPrev": false
  }
}
```

### Códigos HTTP

| Código | Significado | Uso |
|--------|-------------|-----|
| 200 | OK | GET, PUT, PATCH exitosos |
| 201 | Created | POST exitoso |
| 204 | No Content | DELETE exitoso |
| 400 | Bad Request | Datos inválidos |
| 401 | Unauthorized | No autenticado |
| 403 | Forbidden | Sin permisos |
| 404 | Not Found | Recurso no existe |
| 409 | Conflict | Duplicado |
| 422 | Unprocessable | Validación fallida |
| 429 | Too Many Requests | Rate limit |
| 500 | Server Error | Error interno |

---

## 1️⃣ Autenticación (`/auth`)

### `POST /api/v1/auth/register`
Registrar nuevo usuario.

**Auth:** No requerida

**Request:**
```json
{
  "nombre": "Julian Licona",
  "email": "julian@ejemplo.com",
  "password": "MiPassword123!"
}
```

**Response (201):**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": 1,
      "nombre": "Julian Licona",
      "email": "julian@ejemplo.com"
    },
    "accessToken": "eyJhbGciOiJIUzI1...",
    "refreshToken": "eyJhbGciOiJIUzI1..."
  }
}
```

---

### `POST /api/v1/auth/login`
Iniciar sesión.

**Request:**
```json
{
  "email": "julian@ejemplo.com",
  "password": "MiPassword123!"
}
```

**Response (200):**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": 1,
      "nombre": "Julian Licona",
      "email": "julian@ejemplo.com",
      "avatar_url": null
    },
    "accessToken": "eyJhbGciOiJIUzI1...",
    "refreshToken": "eyJhbGciOiJIUzI1..."
  }
}
```

---

### `POST /api/v1/auth/refresh`
Renovar access token.

**Request:**
```json
{
  "refreshToken": "eyJhbGciOiJIUzI1..."
}
```

---

### `POST /api/v1/auth/logout`
Cerrar sesión (invalidar tokens).

**Auth:** Requerida

---

## 2️⃣ Usuarios (`/usuarios`)

### `GET /api/v1/usuarios/me`
Obtener perfil del usuario autenticado.

### `PATCH /api/v1/usuarios/me`
Actualizar perfil (nombre, avatar_url).

### `PATCH /api/v1/usuarios/me/preferencias`
Actualizar preferencias de notificación.

### `PATCH /api/v1/usuarios/me/password`
Cambiar contraseña.

---

## 3️⃣ Temas (`/temas`) - Nivel 1 Organización

### `GET /api/v1/temas`
Listar temas del usuario.

**Query Params:** `?incluir_subtemas=true&incluir_conteo=true`

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "nombre": "Trabajo",
      "color": "#3B82F6",
      "codigo": "TRB",
      "icono": "💼",
      "orden": 0,
      "subtemas_count": 3,
      "tareas_count": 15
    }
  ]
}
```

### `POST /api/v1/temas`
Crear tema.

**Request:**
```json
{
  "nombre": "Trabajo",
  "color": "#3B82F6",
  "codigo": "TRB",
  "icono": "💼"
}
```

### `GET /api/v1/temas/{id}`
Obtener tema específico.

### `PUT /api/v1/temas/{id}`
Actualizar tema.

### `DELETE /api/v1/temas/{id}`
Eliminar tema (CASCADE subtemas/secciones, SET NULL tareas).

### `PATCH /api/v1/temas/{id}/orden`
Cambiar orden del tema.

### `GET /api/v1/temas/{id}/subtemas`
Listar subtemas de un tema.

### `GET /api/v1/temas/{id}/tareas`
Listar tareas directas del tema.

---

## 4️⃣ Subtemas (`/subtemas`) - Nivel 2 Organización

### `GET /api/v1/subtemas`
Listar subtemas. **Query:** `?tema_id=1`

### `POST /api/v1/subtemas`
Crear subtema.

**Request:**
```json
{
  "tema_id": 1,
  "nombre": "Soporte",
  "color": "#10B981",
  "icono": "📂"
}
```

### `GET /api/v1/subtemas/{id}`
### `PUT /api/v1/subtemas/{id}`
### `DELETE /api/v1/subtemas/{id}`
### `PATCH /api/v1/subtemas/{id}/orden`
### `GET /api/v1/subtemas/{id}/secciones`
### `GET /api/v1/subtemas/{id}/tareas`

---

## 5️⃣ Secciones (`/secciones`) - Nivel 3 Organización

### `GET /api/v1/secciones`
Listar secciones. **Query:** `?subtema_id=1`

### `POST /api/v1/secciones`
Crear sección.

**Request:**
```json
{
  "subtema_id": 1,
  "nombre": "Tickets Pendientes",
  "color": "#F59E0B",
  "icono": "📄"
}
```

### `GET /api/v1/secciones/{id}`
### `PUT /api/v1/secciones/{id}`
### `DELETE /api/v1/secciones/{id}`
### `PATCH /api/v1/secciones/{id}/orden`
### `GET /api/v1/secciones/{id}/tareas`

---

## 6️⃣ Tareas (`/tareas`)

### `GET /api/v1/tareas`
Listar tareas con filtros avanzados.

**Query Params:**

| Param | Tipo | Descripción |
|-------|------|-------------|
| `page`, `limit` | int | Paginación |
| `estado` | string | pendiente,en_progreso,completada,cancelada |
| `prioridad` | string | alta,media,baja |
| `categoria` | string | ticket,idea,asignacion |
| `tema_id` | int | Filtrar por tema |
| `subtema_id` | int | Filtrar por subtema |
| `seccion_id` | int | Filtrar por sección |
| `huerfanas` | boolean | Solo sin clasificar |
| `search` | string | Búsqueda texto |
| `sort` | string | Campo ordenar |
| `order` | string | asc/desc |
| `vista` | string | `revuelta` o `organizada` |

**Vista `revuelta`:** Por `updated_at DESC`  
**Vista `organizada`:** Agrupadas por jerarquía

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "titulo": "Revisar ticket INC-123",
      "descripcion": "Cliente reporta error",
      "estado": "pendiente",
      "prioridad": "alta",
      "categoria": "ticket",
      "info": {
        "nombre_ticket": "INC-123",
        "fuente": "correo",
        "links": [
          { "tipo": "principal", "url": "https://...", "titulo": "Ticket" }
        ]
      },
      "puntos_importancia": 5,
      "criticidad_calculada": 75.50,
      "tema": { "id": 1, "nombre": "Trabajo", "color": "#3B82F6", "icono": "💼" },
      "subtema": { "id": 2, "nombre": "Soporte", "color": "#10B981" },
      "seccion": { "id": 5, "nombre": "Tickets Pendientes", "color": "#F59E0B" },
      "proxima_accion": { "id": 10, "nombre": "Enviar seguimiento" },
      "acciones_count": 5,
      "notas_count": 2,
      "relaciones_count": 1,
      "fecha_entrega": "2025-01-20T18:00:00Z",
      "updated_at": "2025-01-18T14:30:00Z"
    }
  ],
  "pagination": {...}
}
```

---

### `POST /api/v1/tareas`
Crear tarea.

**Request (Ticket):**
```json
{
  "titulo": "Revisar ticket INC-123",
  "descripcion": "Cliente reporta error en login",
  "tema_id": 1,
  "subtema_id": 2,
  "seccion_id": 5,
  "categoria": "ticket",
  "prioridad": "alta",
  "fecha_entrega": "2025-01-20T18:00:00Z",
  "info": {
    "nombre_ticket": "INC-123",
    "fuente": "correo",
    "links": [
      { "tipo": "principal", "url": "https://servicedesk.com/INC-123", "titulo": "Ticket principal" },
      { "tipo": "derivado", "url": "https://jira.com/TASK-456", "titulo": "Jira" }
    ]
  }
}
```

**Request (Idea):**
```json
{
  "titulo": "Automatizar reportes",
  "tema_id": 1,
  "categoria": "idea",
  "info": {
    "nombre_idea": "Automatizar reportes semanales",
    "sistema_relacionado": "Sistema de reportes",
    "origen": "propia"
  }
}
```

**Request (Asignación):**
```json
{
  "titulo": "Revisar PR #234",
  "tema_id": 1,
  "categoria": "asignacion",
  "info": {
    "nombre_asignacion": "Revisar código PR #234",
    "con_ticket": true,
    "ticket_asociado": "TASK-567",
    "fuente": "clickup",
    "asignador": "Juan Pérez"
  }
}
```

**Request (Huérfana):**
```json
{
  "titulo": "Llamar al banco",
  "prioridad": "baja"
}
```

---

### `GET /api/v1/tareas/{id}`
Obtener tarea con detalles.

**Query:** `?incluir=acciones,notas,relaciones,aperturas`

---

### `PUT /api/v1/tareas/{id}`
### `PATCH /api/v1/tareas/{id}`
### `DELETE /api/v1/tareas/{id}`

### `PATCH /api/v1/tareas/{id}/estado`
Cambiar estado.

**Request:** `{ "estado": "completada" }`

### `PATCH /api/v1/tareas/{id}/importancia`
Modificar puntos (+1/-1).

**Request:** `{ "accion": "incrementar" }` o `"decrementar"`

### `POST /api/v1/tareas/{id}/abrir`
Registrar apertura (mantiene últimas 3).

### `PATCH /api/v1/tareas/{id}/mover`
Mover a otra ubicación.

**Request:** `{ "tema_id": 2, "subtema_id": null, "seccion_id": null }`

---

## 7️⃣ Acciones (`/tareas/{tareaId}/acciones`)

### `GET /api/v1/tareas/{tareaId}/acciones`
**Query:** `?solo_destacadas=true&solo_pendientes=true`

### `POST /api/v1/tareas/{tareaId}/acciones`
**Request:**
```json
{
  "nombre": "Enviar correo de seguimiento",
  "descripcion": "Preguntar estado",
  "relevancia": 7,
  "es_siguiente": true
}
```

### `GET /api/v1/tareas/{tareaId}/acciones/{id}`
### `PUT /api/v1/tareas/{tareaId}/acciones/{id}`
### `DELETE /api/v1/tareas/{tareaId}/acciones/{id}`

### `PATCH /api/v1/tareas/{tareaId}/acciones/{id}/completar`
**Request:** `{ "completada": true }`

### `PATCH /api/v1/tareas/{tareaId}/acciones/{id}/destacar`
**Request:** `{ "es_destacada": true, "icono_destacado": "📧" }`

**Iconos:** 📧⚡✅📞🔄📝🚀

### `PATCH /api/v1/tareas/{tareaId}/acciones/{id}/marcar-siguiente`
Marcar como próxima (🟢).

### `PATCH /api/v1/tareas/{tareaId}/acciones/{id}/cambiar-siguiente`
Cambiar próxima con motivo (🟡 la anterior).

**Request:**
```json
{
  "nueva_accion_id": 5,
  "motivo_cambio": "Cliente pidió esperar"
}
```

---

## 8️⃣ Notas (`/tareas/{tareaId}/notas`)

### `GET /api/v1/tareas/{tareaId}/notas`
### `POST /api/v1/tareas/{tareaId}/notas`
**Request:** `{ "contenido": "Juan pidió priorizar esto" }`

### `PUT /api/v1/tareas/{tareaId}/notas/{id}`
### `DELETE /api/v1/tareas/{tareaId}/notas/{id}`

---

## 9️⃣ Relaciones (`/tareas/{tareaId}/relaciones`)

### `GET /api/v1/tareas/{tareaId}/relaciones`

### `POST /api/v1/tareas/{tareaId}/relaciones`
**Request:**
```json
{
  "tarea_destino_id": 5,
  "tipo_relacion": "bloquea",
  "descripcion": "Depende de esta"
}
```

**Tipos:** `relacionada`, `bloquea`, `bloqueada_por`, `duplicada`, `padre`, `hija`

### `DELETE /api/v1/tareas/{tareaId}/relaciones/{id}`

---

## 🔟 Notificaciones (`/notificaciones`)

### `GET /api/v1/notificaciones`
**Query:** `?estado=pendiente&tipo=email&leida=false&page=1&limit=20`

### `POST /api/v1/notificaciones`
**Request:**
```json
{
  "tarea_id": 1,
  "tipo": "push",
  "contenido": "Recordatorio: revisar antes de las 5pm",
  "fecha_programada": "2025-01-20T16:00:00Z"
}
```

### `PATCH /api/v1/notificaciones/{id}/leer`
### `PATCH /api/v1/notificaciones/{id}/cancelar`
### `POST /api/v1/notificaciones/leer-todas`
### `GET /api/v1/notificaciones/no-leidas/conteo`

---

## 1️⃣1️⃣ Recordatorios (`/recordatorios`)

### `GET /api/v1/recordatorios`
**Query:** `?estado=activo&tipo=individual&tarea_id=1`

### `POST /api/v1/recordatorios`
**Request:**
```json
{
  "tarea_id": 1,
  "tipo": "individual",
  "descripcion": "Seguimiento cada 2 horas",
  "frecuencia_valor": 2,
  "frecuencia_unidad": "horas",
  "hora_inicio": "09:00:00",
  "hora_fin": "18:00:00",
  "dias_semana": [1, 2, 3, 4, 5],
  "fecha_fin": "2025-01-25T18:00:00Z",
  "notificar_email": true,
  "notificar_push": true,
  "notificar_browser": true
}
```

**Tipos:** `individual`, `grupo`, `general`  
**Unidades:** `minutos`, `horas`, `dias`, `semanas`  
**Días:** 0=Dom, 1=Lun, ..., 6=Sáb

### `GET /api/v1/recordatorios/{id}`
### `PUT /api/v1/recordatorios/{id}`
### `DELETE /api/v1/recordatorios/{id}`
### `PATCH /api/v1/recordatorios/{id}/pausar`
### `PATCH /api/v1/recordatorios/{id}/reanudar`
### `POST /api/v1/recordatorios/pausar-todos`
### `POST /api/v1/recordatorios/reanudar-todos`

---

## 1️⃣2️⃣ Estadísticas (`/estadisticas`)

### `GET /api/v1/estadisticas`
Métricas generales del usuario.

### `GET /api/v1/estadisticas/dashboard`
Datos para dashboard (resumen, por tema, por categoría, actividad semanal, tareas críticas).

### `GET /api/v1/estadisticas/por-periodo`
**Query:** `?desde=2025-01-01&hasta=2025-01-31&agrupar_por=semana`

---

## 1️⃣3️⃣ Logs (`/logs`)

### `GET /api/v1/logs`
**Query:** `?tipo_evento=tarea_completada&desde=...&hasta=...`

**Tipos:** `tarea_creada`, `tarea_actualizada`, `tarea_completada`, `tarea_eliminada`, `accion_agregada`, `accion_completada`, `accion_destacada`, `nota_agregada`, `relacion_creada`, `recordatorio_creado`, `recordatorio_ejecutado`, `card_abierta`, `importancia_modificada`, `proxima_accion_definida`, `proxima_accion_modificada`, `login`, `logout`

### `GET /api/v1/logs/exportar`
**Query:** `?formato=json&desde=...&hasta=...`

---

## 🌐 WebSocket Events

**Conexión:** `ws://api.taskmanager.com/ws`  
**Header:** `Authorization: Bearer {token}`

### Servidor → Cliente
| Evento | Descripción |
|--------|-------------|
| `tarea:creada` | Nueva tarea |
| `tarea:actualizada` | Tarea modificada |
| `tarea:eliminada` | Tarea borrada |
| `tarea:estado-cambiado` | Cambio de estado |
| `accion:creada` | Nueva acción |
| `accion:completada` | Acción completada |
| `accion:siguiente-cambiada` | Próxima acción cambió |
| `notificacion:nueva` | Nueva notificación |
| `recordatorio:ejecutado` | Recordatorio disparado |
| `importancia:cambiada` | Puntos modificados |

### Cliente → Servidor
| Evento | Descripción |
|--------|-------------|
| `suscribir:tareas` | Suscribirse a tareas |
| `desuscribir:tareas` | Desuscribirse |
| `suscribir:tarea` | Suscribirse a tarea específica |
| `ping` | Keep-alive |

---

## 📊 Resumen

| Módulo | Endpoints |
|--------|-----------|
| Auth | 4 |
| Usuarios | 4 |
| Temas | 8 |
| Subtemas | 8 |
| Secciones | 7 |
| Tareas | 10 |
| Acciones | 10 |
| Notas | 4 |
| Relaciones | 3 |
| Notificaciones | 6 |
| Recordatorios | 9 |
| Estadísticas | 3 |
| Logs | 2 |
| **Total** | **~78** |

---

*Documento generado para TaskManager v1.0*
