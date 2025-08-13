create table fe_deptos(
coddep  varchar(2) NOT NULL PRIMARY KEY
,nombredep varchar(50) NOT NULL
);
		insert into fe_deptos values(
				"91"
			,
				"Amazonas"
		);
		insert into fe_deptos values(
				"05"
			,
				"Antioquia"
		);
		insert into fe_deptos values(
				"81"
			,
				"Arauca"
		);
		insert into fe_deptos values(
				"08"
			,
				"Atlántico"
		);
		insert into fe_deptos values(
				"11"
			,
				"Bogotá"
		);
		insert into fe_deptos values(
				"13"
			,
				"Bolívar"
		);
		insert into fe_deptos values(
				"15"
			,
				"Boyacá"
		);
		insert into fe_deptos values(
				"17"
			,
				"Caldas"
		);
		insert into fe_deptos values(
				"18"
			,
				"Caquetá"
		);
		insert into fe_deptos values(
				"85"
			,
				"Casanare"
		);
		insert into fe_deptos values(
				"19"
			,
				"Cauca"
		);
		insert into fe_deptos values(
				"20"
			,
				"Cesar"
		);
		insert into fe_deptos values(
				"27"
			,
				"Chocó"
		);
		insert into fe_deptos values(
				"23"
			,
				"Córdoba"
		);
		insert into fe_deptos values(
				"25"
			,
				"Cundinamarca"
		);
		insert into fe_deptos values(
				"94"
			,
				"Guainía"
		);
		insert into fe_deptos values(
				"95"
			,
				"Guaviare"
		);
		insert into fe_deptos values(
				"41"
			,
				"Huila"
		);
		insert into fe_deptos values(
				"44"
			,
				"La Guajira"
		);
		insert into fe_deptos values(
				"47"
			,
				"Magdalena"
		);
		insert into fe_deptos values(
				"50"
			,
				"Meta"
		);
		insert into fe_deptos values(
				"52"
			,
				"Nariño"
		);
		insert into fe_deptos values(
				"54"
			,
				"Norte de Santander"
		);
		insert into fe_deptos values(
				"86"
			,
				"Putumayo"
		);
		insert into fe_deptos values(
				"63"
			,
				"Quindío"
		);
		insert into fe_deptos values(
				"66"
			,
				"Risaralda"
		);
		insert into fe_deptos values(
				"88"
			,
				"San Andrés y Providencia"
		);
		insert into fe_deptos values(
				"68"
			,
				"Santander"
		);
		insert into fe_deptos values(
				"70"
			,
				"Sucre"
		);
		insert into fe_deptos values(
				"73"
			,
				"Tolima"
		);
		insert into fe_deptos values(
				"76"
			,
				"Valle del Cauca"
		);
		insert into fe_deptos values(
				"97"
			,
				"Vaupés"
		);
		insert into fe_deptos values(
				"99"
			,
				"Vichada"
		);
update fe_deptos set nombredep = trim(nombredep);
