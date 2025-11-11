# 🧠 Douremember - Sistema de Monitoreo de Alzheimer

Douremember es un sistema de microservicios diseñado para la detección temprana de Alzheimer mediante el análisis de descripciones de imágenes con IA. El proyecto utiliza Google Gemini AI para evaluar descripciones cognitivas de pacientes y genera reportes automáticos para médicos y cuidadores.

## 📋 Tabla de Contenidos

- [Arquitectura del Sistema](#arquitectura-del-sistema)
- [Microservicios](#microservicios)
- [Gestión de Submódulos Git](#gestión-de-submódulos-git)
- [Instalación y Configuración](#instalación-y-configuración)
- [Entorno de Desarrollo](#entorno-de-desarrollo)
- [Entorno de Producción](#entorno-de-producción)

## 🏗️ Arquitectura del Sistema

El sistema está compuesto por 4 microservicios que se comunican mediante NATS:

### Microservicios

1. **Gateway** (Puerto 3000)
   - Punto de entrada único para todas las peticiones HTTP
   - Enrutamiento a los microservicios correspondientes
   - Manejo centralizado de excepciones

2. **Usuarios y Autenticación** (Puerto 3002)
   - Gestión de usuarios multi-rol (paciente, cuidador, médico, administrador)
   - Autenticación con Supabase Auth
   - Sistema de invitaciones y relaciones entre usuarios

3. **Descripciones e Imágenes** (Puerto 3001)
   - Carga de imágenes a Cloudinary
   - Gestión de sesiones de evaluación
   - Evaluación cognitiva con Google Gemini AI
   - Cálculo de puntajes y métricas

4. **Alertas y Reportes** (Puerto 3003)
   - Envío de notificaciones por correo electrónico
   - Alertas de puntaje bajo
   - Reportes de baseline y activación de sesiones

## 🔧 Gestión de Submódulos Git

Este proyecto fue desarrollado utilizando **submódulos de Git**, por lo que es importante tener en cuenta los siguientes aspectos para trabajar correctamente con el repositorio.

### Clonar el Repositorio con Submódulos

Cuando clones el repositorio por primera vez, debes inicializar y actualizar los submódulos:

```bash
git clone <repository_url>
cd Douremember-launcher
git submodule update --init --recursive
```

### Actualizar Referencias de Submódulos

Para obtener los últimos cambios de todos los submódulos:

```bash
git submodule update --remote
```

### ⚠️ Importante: Orden de Commits

Si trabajas en un repositorio que contiene submódulos:

1. **Primero:** Hacer push en el submódulo
   ```bash
   cd <microservicio>
   git add .
   git commit -m "Cambios en el microservicio"
   git push
   ```

2. **Después:** Hacer push en el repositorio principal
   ```bash
   cd ..
   git add .
   git commit -m "Actualizar referencia del submódulo"
   git push
   ```

**Nota:** Si se hace en orden inverso, se perderán las referencias de los submódulos y será necesario resolver conflictos.

### Agregar Nuevos Submódulos

Para agregar un nuevo submódulo al proyecto:

```bash
git submodule add <repository_url> <directory_name>
git add .
git commit -m "Agregar nuevo submódulo: <nombre>"
git push
```

## 📦 Instalación y Configuración

### Requisitos Previos

- Docker y Docker Compose
- Node.js 18+ (para desarrollo local)
- Git

### Variables de Entorno

1. Crea un archivo `.env` en la raíz del proyecto basado en `.env.template`
2. Configura las variables necesarias para cada microservicio
3. Asegúrate de tener las credenciales de:
   - Supabase (autenticación y base de datos)
   - Cloudinary (almacenamiento de imágenes)
   - Google Gemini AI (evaluación cognitiva)
   - Resend (envío de correos)

## 🚀 Entorno de Desarrollo

### Levantar el Proyecto

1. Clona el repositorio e inicializa los submódulos:
   ```bash
   git clone <repository_url>
   cd Douremember-launcher
   git submodule update --init --recursive
   ```

2. Crea el archivo `.env` basado en `.env.template`

3. Levanta todos los servicios con Docker Compose:
   ```bash
   docker compose up --build
   ```

### Servidor NATS

El sistema requiere un servidor NATS para la comunicación entre microservicios. Si desarrollas sin Docker Compose, levanta NATS manualmente:

```bash
docker run -d --name nats-main -p 4222:4222 -p 8222:8222 nats
```

### Acceso a los Servicios

- **Gateway:** http://localhost:3000
- **Descripciones e Imágenes:** http://localhost:3001
- **Usuarios y Autenticación:** http://localhost:3002
- **Alertas y Reportes:** http://localhost:3003
- **NATS Monitoring:** http://localhost:8222

## 🌐 Entorno de Producción

### Despliegue con Docker Compose

#### Construcción de Imágenes

```bash
docker compose -f docker-compose.prod.yml build
```

#### Levantar Servicios en Producción

```bash
docker compose -f docker-compose.prod.yml up -d
```

#### Detener Servicios

```bash
docker compose -f docker-compose.prod.yml down
```

### Despliegue en Google Cloud con Kubernetes (GKE)

El proyecto está desplegado en **Google Kubernetes Engine (GKE)** utilizando Helm Charts para gestionar las configuraciones.

#### Estructura de Kubernetes

El proyecto cuenta con manifiestos de Kubernetes organizados en la carpeta `k8s/douremember/`:

```
k8s/douremember/
├── Chart.yaml                          # Definición del Helm Chart
├── values.yaml                         # Valores de configuración
└── templates/
    ├── gateway/                        # Deployment y Service del Gateway
    ├── usuarios-autenticacion-ms/      # Deployment y Service de Usuarios
    ├── descripciones-imagenes-ms/      # Deployment y Service de Descripciones
    ├── alertas-reportes-ms/            # Deployment y Service de Alertas
    ├── nats/                           # Deployment y Service de NATS
    └── ingress/                        # Configuración de Ingress
```

#### Comandos Helm Principales

**Instalación inicial del chart:**
```bash
helm install douremember ./k8s/douremember
```

**Actualizar configuración:**
```bash
helm upgrade douremember ./k8s/douremember
```

**Desinstalar:**
```bash
helm uninstall douremember
```

#### Comandos Kubectl Útiles

**Ver estado de los servicios:**
```bash
# Ver todos los pods
kubectl get pods

# Ver todos los deployments
kubectl get deployments

# Ver todos los services
kubectl get services
```

**Revisar logs de un pod:**
```bash
kubectl logs <nombre-del-pod>
```

**Describir un pod específico:**
```bash
kubectl describe pod <nombre-del-pod>
```

#### Gestión de Secrets en Kubernetes

**Crear secrets para variables de entorno:**
```bash
kubectl create secret generic douremember-secrets \
  --from-literal=DATABASE_URL=postgresql://... \
  --from-literal=GEMINI_API_KEY=... \
  --from-literal=RESEND_API_KEY=...
```

**Ver secrets:**
```bash
kubectl get secrets
```

**Ver contenido de un secret:**
```bash
kubectl get secret <nombre> -o yaml
```

#### Configuración de Google Container Registry

Para que Kubernetes pueda obtener las imágenes de Google Container Registry:

```bash
# Crear secret con credenciales de GCR
kubectl create secret docker-registry gcr-json-key \
  --docker-server=us-central1-docker.pkg.dev \
  --docker-username=_json_key \
  --docker-password="$(cat 'path/to/service-account.json')" \
  --docker-email=tu-email@gmail.com

# Configurar el service account para usar el secret
kubectl patch serviceaccounts default -p '{"imagePullSecrets": [{"name":"gcr-json-key"}]}'
```

#### Documentación Completa de Kubernetes

Para comandos detallados y configuración avanzada, consulta el archivo [K8s.README.md](./K8s.README.md).

## 📚 Documentación Adicional

Para información detallada sobre cada microservicio, consulta sus respectivos READMEs:

- [Gateway](./gateway/README.md)
- [Usuarios y Autenticación](./usuarios-autenticacion-ms/README.md)
- [Descripciones e Imágenes](./descripciones-imagenes-ms/README.md)
- [Alertas y Reportes](./alertas-reportes-ms/README.md)

## 🛠️ Tecnologías Utilizadas

- **Framework:** NestJS
- **Mensajería:** NATS
- **Base de Datos:** PostgreSQL (Supabase)
- **Autenticación:** Supabase Auth
- **IA:** Google Gemini 2.5 Flash
- **Almacenamiento:** Cloudinary
- **Email:** Resend
- **ORM:** Prisma
- **Contenedores:** Docker & Docker Compose
