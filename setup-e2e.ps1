# 🧪 Script de Setup para Pruebas E2E
# Ejecuta este script antes de correr npm run test:e2e

Write-Host " Configurando entorno para pruebas E2E..." -ForegroundColor Cyan

# Variables
$TEST_DB_URL = "postgresql://test_user:test_pass@localhost:5433/douremember_test"
$NATS_URL = "nats://localhost:4222"

# Paso 1: Verificar PostgreSQL
Write-Host "`n Verificando PostgreSQL..." -ForegroundColor Yellow
try {
    docker ps | Select-String "postgres-test" | Out-Null
    if ($?) {
        Write-Host " PostgreSQL ya está corriendo" -ForegroundColor Green
    } else {
        Write-Host " Iniciando PostgreSQL en Docker..." -ForegroundColor Yellow
        docker run -d `
            --name postgres-test `
            -e POSTGRES_USER=test_user `
            -e POSTGRES_PASSWORD=test_pass `
            -e POSTGRES_DB=douremember_test `
            -p 5433:5432 `
            postgres:15
        Start-Sleep -Seconds 5
        Write-Host " PostgreSQL iniciado" -ForegroundColor Green
    }
} catch {
    Write-Host " Error con PostgreSQL: $_" -ForegroundColor Red
    exit 1
}

# Paso 2: Verificar NATS
Write-Host "`n Verificando NATS..." -ForegroundColor Yellow
try {
    docker ps | Select-String "nats-test" | Out-Null
    if ($?) {
        Write-Host " NATS ya está corriendo" -ForegroundColor Green
    } else {
        Write-Host " Iniciando NATS en Docker..." -ForegroundColor Yellow
        docker run -d --name nats-test -p 4222:4222 nats:latest
        Start-Sleep -Seconds 3
        Write-Host " NATS iniciado" -ForegroundColor Green
    }
} catch {
    Write-Host " Error con NATS: $_" -ForegroundColor Red
    exit 1
}

# Paso 3: Aplicar migraciones de Prisma
Write-Host "`n Aplicando migraciones de Prisma..." -ForegroundColor Yellow
$env:DATABASE_URL = $TEST_DB_URL

try {
    Push-Location
    Set-Location "descripciones-imagenes-ms"
    
    # Verificar si hay migraciones pendientes
    $migrateStatus = npx prisma migrate status 2>&1
    
    if ($migrateStatus -match "Database schema is up to date") {
        Write-Host " Base de datos ya está actualizada" -ForegroundColor Green
    } else {
        Write-Host " Ejecutando migraciones..." -ForegroundColor Yellow
        npx prisma migrate deploy
        if ($LASTEXITCODE -eq 0) {
            Write-Host " Migraciones aplicadas correctamente" -ForegroundColor Green
        } else {
            Write-Host "  Algunas migraciones fallaron, intentando reset..." -ForegroundColor Yellow
            npx prisma migrate reset --force
            if ($LASTEXITCODE -eq 0) {
                Write-Host " Base de datos reiniciada correctamente" -ForegroundColor Green
            } else {
                Write-Host " Error aplicando migraciones" -ForegroundColor Red
                Pop-Location
                exit 1
            }
        }
    }
    
    Pop-Location
} catch {
    Write-Host " Error con migraciones: $_" -ForegroundColor Red
    Pop-Location
    exit 1
}

# Paso 4: Verificar configuración
Write-Host "`n Verificando archivos de configuración..." -ForegroundColor Yellow

$setupFile = "descripciones-imagenes-ms\test\setup-e2e.ts"
$jestConfig = "descripciones-imagenes-ms\test\jest-e2e.json"

if (Test-Path $setupFile) {
    Write-Host " setup-e2e.ts encontrado" -ForegroundColor Green
} else {
    Write-Host " setup-e2e.ts no encontrado" -ForegroundColor Red
    exit 1
}

if (Test-Path $jestConfig) {
    Write-Host " jest-e2e.json encontrado" -ForegroundColor Green
} else {
    Write-Host " jest-e2e.json no encontrado" -ForegroundColor Red
    exit 1
}

# Resumen
Write-Host "`n Resumen de servicios:" -ForegroundColor Cyan
Write-Host "  PostgreSQL: localhost:5433" -ForegroundColor White
Write-Host "  NATS:       localhost:4222" -ForegroundColor White
Write-Host "  DATABASE:   douremember_test" -ForegroundColor White

Write-Host "`n Todo listo para ejecutar las pruebas E2E!" -ForegroundColor Green
Write-Host "`n Ejecuta ahora:" -ForegroundColor Cyan
Write-Host "  cd descripciones-imagenes-ms" -ForegroundColor Yellow
Write-Host "  npm run test:e2e" -ForegroundColor Yellow

# Mostrar comandos útiles
Write-Host "`n Comandos útiles:" -ForegroundColor Cyan
Write-Host "  Ver logs PostgreSQL:  docker logs postgres-test" -ForegroundColor White
Write-Host "  Ver logs NATS:        docker logs nats-test" -ForegroundColor White
Write-Host "  Detener servicios:    docker stop postgres-test nats-test" -ForegroundColor White
Write-Host "  Eliminar servicios:   docker rm -f postgres-test nats-test" -ForegroundColor White
Write-Host "  Reiniciar BD:         npx prisma migrate reset --force" -ForegroundColor White
