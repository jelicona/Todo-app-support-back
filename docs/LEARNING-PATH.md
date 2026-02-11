# LEARNING PATH - TaskManager Backend

> **Objetivo**: Aprender desarrollo backend profesional construyendo TaskManager
> **Metodología**: Julian implementa, Claude guía con conceptos y revisiones
> **Última actualización**: Enero 2025

---

## FASE 1: FUNDAMENTOS (Semana actual)

### 1.1 Configuración del Proyecto
- [ ] **Estructura de carpetas** - Decidir arquitectura
- [ ] **TypeORM setup** - Conexión a MySQL
- [ ] **Variables de entorno** - ConfigModule
- [ ] **Validación global** - class-validator, class-transformer

**Conceptos CS a aprender:**
- Dependency Injection (DI)
- Inversion of Control (IoC)
- Environment configuration patterns

**Docs NestJS:**
- https://docs.nestjs.com/first-steps
- https://docs.nestjs.com/techniques/configuration
- https://docs.nestjs.com/techniques/validation

---

### 1.2 Módulo de Autenticación
- [ ] **Registro de usuarios** - Hash de passwords
- [ ] **Login** - Generación de JWT
- [ ] **Refresh tokens** - Rotación segura
- [ ] **Guards** - Protección de rutas

**Conceptos CS a aprender:**
- Autenticación vs Autorización
- JWT (JSON Web Tokens) - estructura, firma, verificación
- Stateless authentication
- Bcrypt y hashing
- Token refresh strategy

**Patrones:**
- Strategy pattern (para múltiples auth providers)
- Guard pattern (para protección)

**Docs NestJS:**
- https://docs.nestjs.com/security/authentication
- https://docs.nestjs.com/security/authorization
- https://docs.nestjs.com/guards

**Investigar:**
- "JWT vs Sessions"
- "OAuth 2.0 flow"
- "Refresh token rotation"
- "Bcrypt salt rounds"

---

## FASE 2: CRUD CORE

### 2.1 Entidades TypeORM
- [ ] **Usuario entity**
- [ ] **Tema/Subtema/Seccion entities**
- [ ] **Tarea entity** con JSON column
- [ ] **Relaciones** - OneToMany, ManyToOne

**Conceptos CS:**
- ORM (Object-Relational Mapping)
- Active Record vs Data Mapper
- Lazy loading vs Eager loading
- Entity relationships

**Docs NestJS/TypeORM:**
- https://docs.nestjs.com/techniques/database
- https://typeorm.io/entities
- https://typeorm.io/relations

---

### 2.2 Módulo Temas (Nivel 1)
- [ ] **CRUD completo**
- [ ] **Validación con DTOs**
- [ ] **Manejo de errores**
- [ ] **Filtrado por usuario**

**Conceptos CS:**
- DTO (Data Transfer Object)
- Input validation
- Error handling strategies
- HTTP status codes semánticos

**Patrones:**
- Repository pattern
- Service layer pattern

---

### 2.3 Módulo Tareas
- [ ] **CRUD con filtros avanzados**
- [ ] **Paginación**
- [ ] **Ordenamiento**
- [ ] **Búsqueda**

**Conceptos CS:**
- Pagination strategies (offset vs cursor)
- Query optimization
- N+1 problem
- Database indexing

**Investigar:**
- "Offset pagination vs cursor pagination"
- "TypeORM query builder"
- "Database query optimization"

---

## FASE 3: FEATURES AVANZADOS

### 3.1 Sistema de Acciones
- [ ] **CRUD acciones**
- [ ] **Próxima acción (es_siguiente)**
- [ ] **Acciones destacadas**
- [ ] **Historial de cambios**

**Conceptos CS:**
- State machines
- Audit logging
- Business rules en dominio

---

### 3.2 Relaciones entre Tareas
- [ ] **Crear relaciones**
- [ ] **Tipos de relación**
- [ ] **Detección de ciclos**

**Conceptos CS:**
- Graph data structures
- Cycle detection algorithms
- Self-referential relationships

---

### 3.3 Notificaciones y Recordatorios
- [ ] **Crear notificaciones**
- [ ] **Programar recordatorios**
- [ ] **Job scheduler**

**Conceptos CS:**
- Job scheduling (cron)
- Message queues
- Async processing
- Background workers

**Docs NestJS:**
- https://docs.nestjs.com/techniques/task-scheduling
- https://docs.nestjs.com/techniques/queues

---

## FASE 4: REAL-TIME

### 4.1 WebSockets
- [ ] **Gateway setup**
- [ ] **Autenticación WS**
- [ ] **Eventos de tareas**
- [ ] **Rooms/namespaces**

**Conceptos CS:**
- WebSocket protocol
- Bidirectional communication
- Event-driven architecture
- Pub/Sub pattern

**Docs NestJS:**
- https://docs.nestjs.com/websockets/gateways

---

## FASE 5: OPTIMIZACIÓN

### 5.1 Caching
- [ ] **Cache de queries**
- [ ] **Invalidación de cache**
- [ ] **Redis setup**

**Conceptos CS:**
- Cache strategies (write-through, write-behind)
- Cache invalidation
- TTL (Time To Live)
- Cache stampede

**Docs NestJS:**
- https://docs.nestjs.com/techniques/caching

---

### 5.2 Rate Limiting
- [ ] **Throttler setup**
- [ ] **Por endpoint**
- [ ] **Por usuario**

**Conceptos CS:**
- Rate limiting algorithms (token bucket, sliding window)
- DDoS protection
- API quotas

**Docs NestJS:**
- https://docs.nestjs.com/security/rate-limiting

---

## FASE 6: TESTING

### 6.1 Unit Tests
- [ ] **Services**
- [ ] **Mocking**

### 6.2 Integration Tests
- [ ] **Controllers**
- [ ] **Database**

### 6.3 E2E Tests
- [ ] **Flujos completos**

**Conceptos CS:**
- Test pyramid
- Mocking vs Stubbing
- Test isolation
- Code coverage

**Docs NestJS:**
- https://docs.nestjs.com/fundamentals/testing

---

## CONCEPTOS TRANSVERSALES

### System Design
| Concepto | Cuándo aprenderlo | Aplicación en TaskManager |
|----------|-------------------|---------------------------|
| REST API Design | Fase 1 | Diseño de endpoints |
| JWT/OAuth | Fase 1.2 | Autenticación |
| Database Design | Fase 2.1 | Entidades y relaciones |
| Caching | Fase 5.1 | Optimización de queries |
| Rate Limiting | Fase 5.2 | Protección de API |
| WebSockets | Fase 4 | Real-time updates |
| Message Queues | Fase 3.3 | Notificaciones async |
| Idempotency | Fase 2 | POST/PUT endpoints |

### Patrones de Diseño
| Patrón | Dónde usarlo |
|--------|--------------|
| Repository | Acceso a datos |
| Service Layer | Lógica de negocio |
| Factory | Creación de entidades |
| Strategy | Auth providers, notificaciones |
| Observer | WebSocket events |
| Decorator | NestJS decorators |
| Singleton | Conexión BD, Cache |
| Dependency Injection | Todo NestJS |

### SOLID en Práctica
| Principio | Ejemplo en TaskManager |
|-----------|------------------------|
| **S**ingle Responsibility | TareasService solo maneja tareas |
| **O**pen/Closed | Nuevos tipos de notificación sin modificar existente |
| **L**iskov Substitution | Cualquier AuthProvider funciona igual |
| **I**nterface Segregation | Interfaces específicas por funcionalidad |
| **D**ependency Inversion | Services dependen de interfaces, no implementaciones |

---

## PROGRESO ACTUAL

### Completado
- [x] Diseño de API (78 endpoints)
- [x] Diseño de BD (14 tablas)
- [x] Schema SQL con triggers
- [x] CLAUDE.md configurado

### En Progreso
- [ ] Configuración inicial del proyecto NestJS

### Próximo
- [ ] Decidir estructura de carpetas
- [ ] Configurar TypeORM con MySQL
- [ ] Implementar módulo Auth

---

## RECURSOS DE REFERENCIA

### Documentación Oficial
- NestJS: https://docs.nestjs.com/
- TypeORM: https://typeorm.io/
- Socket.io: https://socket.io/docs/

### Libros/Artículos Recomendados
- "Clean Architecture" - Robert C. Martin
- "Designing Data-Intensive Applications" - Martin Kleppmann
- "System Design Interview" - Alex Xu

### Repos de Referencia
- NestJS Realworld Example: https://github.com/lujakob/nestjs-realworld-example-app
- NestJS Boilerplate: https://github.com/NarHakobyan/awesome-nest-boilerplate

---

*Este documento se actualiza conforme avanza el proyecto*
