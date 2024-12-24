USE CatHotelDefinitivo
GO
/**************************************/
/************  CONSULTAS  ************/
/************************************/



/**** A ******/

Select DISTINCT G.gatoNombre,P.propietarioNombre,R.habitacionNombre,R.reservaMonto from Gato G
	INNER JOIN Propietario P
	ON P.propietarioDocumento = G.propietarioDocumento
	INNER JOIN Reserva R 
	ON R.gatoID = G.gatoID
	INNER JOIN Habitacion H
	ON H.habitacionNombre = R.habitacionNombre
	WHERE H.habitacionCapacidad = (SELECT MAX(H1.habitacionCapacidad) FROM Habitacion H1)
  AND R.reservaFechaFin >= (SELECT MIN(R1.reservaFechaFin) FROM Reserva R1);





  /********* B *********/

	SELECT TOP 3 S.servicioNombre, S.servicioPrecio, SUM(RS.cantidad) AS cantidadTotal FROM Servicio AS S
		INNER JOIN Reserva_Servicio RS ON S.servicioNombre = RS.servicioNombre
		INNER JOIN Reserva R ON R.reservaID = RS.reservaID
		WHERE YEAR(R.reservaFechaInicio) = YEAR(GETDATE()) - 1
		AND YEAR(R.reservaFechaFin) = YEAR(GETDATE()) - 1
		GROUP BY S.servicioNombre, S.servicioPrecio
		HAVING SUM(RS.cantidad) >= 5
		ORDER BY cantidadTotal DESC;



	/*********** C ***********/

	Select G.gatoNombre , H.habitacionNombre from Gato G
		INNER JOIN Reserva R
		ON R.gatoID = G.gatoID
		INNER JOIN Habitacion H
		ON H.habitacionNombre = R.habitacionNombre
		INNER JOIN Reserva_Servicio RS
		ON RS.reservaID = R.reservaID
		GROUP BY G.gatoNombre, H.habitacionNombre
		HAVING COUNT(DISTINCT RS.servicioNombre) = (SELECT COUNT(S.servicioNombre) FROM Servicio S);


/********* D ***********/

	Select  YEAR(R.reservaFechaInicio) AS Año ,G.gatoNombre ,SUM(R.reservaMonto) AS TotalMonto from Reserva R
	INNER JOIN Gato G
	ON R.gatoID = G.gatoID
	WHERE G.gatoRaza = 'Persa' 
	AND G.gatoEdad > 10
	GROUP BY YEAR(R.reservaFechaInicio),G.gatoNombre
	HAVING SUM(R.reservaMonto) > 500 
	ORDER BY G.gatoNombre, Año;



/********* E ***********/

SELECT R.reservaID, R.gatoID, R.habitacionNombre, R.reservaFechaInicio, R.reservaFechaFin, (R.reservaMonto + SUM(RS.cantidad * S.servicioPrecio)) AS montoTotalReserva
FROM Reserva R
LEFT JOIN Reserva_Servicio RS 
ON R.reservaID = RS.reservaID
LEFT JOIN Servicio S 
ON RS.servicioNombre = S.servicioNombre
GROUP BY R.reservaID, R.gatoID, R.habitacionNombre, R.reservaFechaInicio, R.reservaFechaFin, R.reservaMonto
ORDER BY montoTotalReserva DESC; 

/********* F ***********/

SELECT AVG(DATEDIFF(day, R.reservaFechaInicio, R.reservaFechaFin)) AS Promedio_Duracion
FROM Reserva R
JOIN Reserva_Servicio RS1 
    ON R.reservaID = RS1.reservaID
    AND RS1.servicioNombre = 'CONTROL_PARASITOS'
LEFT JOIN Reserva_Servicio RS2 
    ON R.reservaID = RS2.reservaID
    AND RS2.servicioNombre = 'REVISION_VETERINARIA'
WHERE RS2.servicioNombre IS NULL 
AND YEAR(R.reservaFechaInicio) = YEAR(GETDATE());

/***** G ****/
Select H.habitacionNombre ,SUM(DATEDIFF(DAY,R.reservaFechaInicio, R.reservaFechaFin)) AS DiasReservados, 
	DATEDIFF(DAY, MIN(R.reservaFechaInicio) , GETDATE()) AS DiasDesdeInicioHastaHoy,
	CASE 
	WHEN (SUM(DATEDIFF(DAY, R.reservaFechaInicio, R.reservaFechaFin)) *1.0 / DATEDIFF(DAY, MIN(R.reservaFechaInicio) , GETDATE())) >0.6
	THEN 'REDITUABLE'
	WHEN (SUM(DATEDIFF(DAY, R.reservaFechaInicio, R.reservaFechaFin)) *1.0 / DATEDIFF(DAY, MIN(R.reservaFechaInicio) , GETDATE())) >= 0.4 
	THEN 'MAGRO'
	ELSE 'NOESNEGOCIO' END AS Rentabilidad
	from Habitacion H
	INNER JOIN Reserva R
	ON R.habitacionNombre = H.habitacionNombre
	GROUP BY H.habitacionNombre;

