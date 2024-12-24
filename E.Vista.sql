USE CatHotelDefinitivo
GO

/**************************************/
/*************  VISTA  ***************/
/************************************/

 CREATE VIEW VistaFacturacionPropietarios AS
SELECT 
    P.propietarioNombre AS NombrePropietario,
    ISNULL(SUM(R.reservaMonto), 0) AS MontoTotalReservas,
    ISNULL(SUM(RS.cantidad * S.servicioPrecio), 0) AS MontoTotalServicios,
    ISNULL(SUM(R.reservaMonto), 0) + ISNULL(SUM(RS.cantidad * S.servicioPrecio), 0) AS MontoTotalFacturar
FROM 
    Propietario P
JOIN 
    Gato G ON P.propietarioDocumento = G.propietarioDocumento
LEFT JOIN 
    Reserva R ON G.gatoID = R.gatoID AND MONTH(R.reservaFechaInicio) = MONTH(DATEADD(MONTH, -1, GETDATE())) 
    AND YEAR(R.reservaFechaInicio) = YEAR(DATEADD(MONTH, -1, GETDATE()))
LEFT JOIN 
    Reserva_Servicio RS ON R.reservaID = RS.reservaID
LEFT JOIN 
    Servicio S ON RS.servicioNombre = S.servicioNombre
GROUP BY 
    P.propietarioNombre;




	/*Para ver la vista*/
	SELECT * FROM VistaFacturacionPropietarios;
