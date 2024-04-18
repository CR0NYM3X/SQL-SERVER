
# parches y ciclos de vida

```SQL													
CATÁLOGO DE PARCHES POSTGRESQL		https://www.postgresql.org/													
CATÁLOGO DE PARCHES MSSQL	 	https://www.catalog.update.microsoft.com/search.aspx?q=sql+server													
CATÁLOGO DE PARCHES MONGODB	 	https://www.mongodb.com/docs/upcoming/release-notes/6.0/													
CATÁLOGO DE PARCHES DB2	 	https://www.ibm.com/support/pages/download-db2-fix-packs-version-db2-linux-unix-and-windows													
CATÁLOGO DE PARCHES MARIADB		https://mariadb.com/kb/en/release-notes/													
CATÁLOGO DE PARCHES VOLTDB	 	https://docs.voltdb.com/													
CATÁLOGO DE PARCHES ORACLE	 	https://support.oracle.com/knowledge/Oracle%20Database%20Products/742060_1.html													
CATÁLOGO DE PARCHES MYSQL		https://dev.mysql.com/doc/relnotes/													

LIFE CYCLES POSTGRESQL 		https://www.postgresql.org/support/versioning/													
LIFE CYCLES MSSQL		https://learn.microsoft.com/en-us/sql/sql-server/end-of-support/sql-server-end-of-support-overview?view=sql-server-ver16													
LIFE CYCLES MONGODB		https://www.mongodb.com/support-policy/lifecycles													
LIFE CYCLES DB2		https://www.ibm.com/support/pages/db2-distributed-end-support-eos-dates													
LIFE CYCLES MARIADB		https://mariadb.org/about/													
LIFE CYCLES VOLTDB		https://www.voltactivedata.com/company/customers/support/													
LIFE CYCLES ORACLE		https://www.oracle.com/us/assets/lifetime-support-technology-069183.pdf													
LIFE CYCLES MYSQL		https://endoflife.software/applications/databases/mysql

```

### GDR VS CU
```SQL

Actualizaciones GDR (General Distribution Release):

Foco en Correcciones Críticas: Las actualizaciones GDR están diseñadas principalmente para proporcionar correcciones críticas de seguridad y estabilidad para SQL Server.
Conservadoras en Cambios: Tienden a ser más conservadoras en términos de cambios y nuevas características, centrándose en mantener la estabilidad y la seguridad del producto.
Menos Frecuentes: Por lo general, se lanzan con menos frecuencia que los CU y se centran en abordar problemas críticos específicos.
Recomendadas para Entornos de Producción Estables: Son una opción sólida para entornos de producción que valoran la estabilidad y prefieren evitar cambios significativos en el software.
Prioridad en Seguridad: Son esenciales para mantener la seguridad de la base de datos y mitigar los riesgos asociados con vulnerabilidades conocidas.


Cumulative Updates (CU):

Actualizaciones Acumulativas: Incluyen todas las correcciones y mejoras de versiones anteriores, así como nuevas correcciones y mejoras adicionales.
Amplia Gama de Correcciones y Mejoras: Pueden abordar una amplia variedad de problemas, incluidos errores críticos, mejoras de rendimiento y nuevas características.
Lanzamientos Periódicos: Se lanzan periódicamente y ofrecen una oportunidad para mantenerse al día con las últimas correcciones y mejoras disponibles.
Mayor Flexibilidad y Funcionalidad: Ofrecen una mayor flexibilidad y funcionalidad en comparación con las actualizaciones GDR, pero también pueden introducir cambios adicionales en el sistema.
Requieren Pruebas Rigurosas: Dado su alcance más amplio, es importante realizar pruebas rigurosas en un entorno de desarrollo antes de implementarlos en un entorno de producción.

```
