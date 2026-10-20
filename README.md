# ZapaImport-BI

> Diseño e implementación de un Data Warehouse para la analítica en ZapaImport.
> Proyecto final — Base de Datos Avanzadas y Big Data — 2026-2

---

## Sobre el proyecto

ZapaImport es una pequeña empresa familiar que importa y vende zapatillas por 4 canales (tienda física, web, Instagram, WhatsApp). Su problema: decide los pedidos de importación "a ojo", sin análisis de rotación, margen real ni inversión comercial.

Esta solución construye un "Data Warehouse con modelo estrella" en SQL Server, un "pipeline ETL automatizado en T-SQL con reglas de calidad de datos", y un "dashboard interactivo en Power BI" que responde las 7 decisiones de negocio del caso.

> **Nota de enfoque:** por directiva del curso y juicio de ingeniería, el proyecto se centra en **Business Intelligence relacional**. El volumen de datos (55 líneas de detalle, ~KB) no supera los umbrales que justifican un ecosistema Big Data distribuido. Como mecanismo de escalabilidad y separación de cargas, se implementa un **procedimiento de replicación** (requisito de la rúbrica).

---

## Requisitos

| Componente | Versión mínima | Para qué |
|---|---|---|
| SQL Server | 2019+ (Express / Developer / Standard) | Motor OLTP + DW + ETL + replicación |
| SQL Server Management Studio (SSMS) | 18.x+ | Ejecución de scripts |
| SQL Server Agent | Activo | Job del ETL y replicación |
| Power BI Desktop | 2026+ | Dashboard |
| Windows | 10/11 | Entorno |

---

## Instalación y ejecución (reproducir la solución)

Clona el repositorio y ejecuta los scripts en fila del 1 al 4

```bash
git clone https://github.com/Kentha52/ZapaImport-BI.git
cd ZapaImport-BI