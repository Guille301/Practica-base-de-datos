USE CatHotelDefinitivo
GO

/**************************************/
/****  PROCEDIMIENTOS Y FUNCIONES ****/
/************************************/
	

/* A */
DROP PROCEDURE IF EXISTS spReservarHabitacion;
GO

CREATE PROCEDURE spReservarHabitacion 
    @propietarioDocumento CHAR(30),
    @habitacionNombre CHAR(30),
    @reservaFechaInicio DATE,
    @reservaFechaFin DATE,
    @reservaMonto DECIMAL(7,2),
    @reservaID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @capacidadHabitacion INT;
    DECLARE @estadoHabitacion VARCHAR(20);
    DECLARE @cantidadGatosActuales INT;
    DECLARE @nuevosGatos INT;

    -- Obtener la capacidad y el estado de la habitaci�n
    SELECT @capacidadHabitacion = habitacionCapacidad, 
           @estadoHabitacion = habitacionEstado
    FROM Habitacion
    WHERE habitacionNombre = @habitacionNombre;

    -- Verificar si la habitaci�n est� "LLENA" o "LIMPIANDO"
    IF @estadoHabitacion = 'LLENA' OR @estadoHabitacion = 'LIMPIANDO'
    BEGIN
        SET @reservaID = 0;
        RETURN;
    END

    -- Contar la cantidad de gatos actualmente en la habitaci�n para el per�odo solicitado
    SELECT @cantidadGatosActuales = COUNT(*)
    FROM Reserva r
    INNER JOIN Gato g ON r.gatoID = g.gatoID
    WHERE r.habitacionNombre = @habitacionNombre
    AND r.reservaFechaFin > @reservaFechaInicio
    AND r.reservaFechaInicio < @reservaFechaFin;

    -- Contar los gatos del propietario que se agregar�n
    SELECT @nuevosGatos = COUNT(*)
    FROM Gato
    WHERE propietarioDocumento = @propietarioDocumento;

    -- Verificar si se superar� la capacidad de la habitaci�n
    IF (@cantidadGatosActuales + @nuevosGatos > @capacidadHabitacion)
    BEGIN
        SET @reservaID = 0;
        RETURN;
    END

    -- Insertar las reservas y obtener el ID de la �ltima reserva insertada
    INSERT INTO Reserva (gatoID, habitacionNombre, reservaFechaInicio, reservaFechaFin, reservaMonto)
    SELECT gatoID, 
           @habitacionNombre, 
           @reservaFechaInicio, 
           @reservaFechaFin, 
           @reservaMonto
    FROM Gato
    WHERE propietarioDocumento = @propietarioDocumento;

    -- Asignar el ID de la �ltima reserva insertada al par�metro de salida
    SELECT TOP 1 @reservaID = reservaID 
	FROM Reserva
	ORDER BY reservaID DESC;

    -- Actualizar el estado de la habitaci�n a "LLENA" si se alcanz� la capacidad
    IF (@cantidadGatosActuales + @nuevosGatos = @capacidadHabitacion)
    BEGIN
        UPDATE Habitacion
        SET habitacionEstado = 'LLENA'
        WHERE habitacionNombre = @habitacionNombre;
    END
END;
GO

DECLARE @reservaID INT;
EXEC spReservarHabitacion 
    @propietarioDocumento = '12345678', 
    @habitacionNombre = 'Suite Ejecutiva', 
    @reservaFechaInicio = '2024-10-17', 
    @reservaFechaFin = '2024-10-27', 
    @reservaMonto = 1567.00, 
    @reservaID = @reservaID OUTPUT;
SELECT @reservaID AS NumeroReserva; -- Esperado: N�mero de reserva nuevo si la capacidad permite, 0 si est� llena.

DECLARE @reservaID INT;
EXEC spReservarHabitacion 
    @propietarioDocumento = '23456789', 
    @habitacionNombre = 'Habitaci�n Doble', 
    @reservaFechaInicio = '2024-11-01', 
    @reservaFechaFin = '2024-11-05', 
    @reservaMonto = 800.00, 
    @reservaID = @reservaID OUTPUT;
SELECT @reservaID AS NumeroReserva; -- Esperado: 0 porque la habitaci�n est� en estado LLENA.

DECLARE @reservaID INT;
EXEC spReservarHabitacion 
    @propietarioDocumento = '34567890', 
    @habitacionNombre = 'Habitaci�n Individual', 
    @reservaFechaInicio = '2024-10-20', 
    @reservaFechaFin = '2024-10-25', 
    @reservaMonto = 375.00, 
    @reservaID = @reservaID OUTPUT;
SELECT @reservaID AS NumeroReserva; -- Esperado: N�mero de reserva nuevo porque la habitaci�n est� DISPONIBLE.

DECLARE @reservaID INT;
EXEC spReservarHabitacion 
    @propietarioDocumento = '67890124', 
    @habitacionNombre = '�tico de Lujo', 
    @reservaFechaInicio = '2024-10-21', 
    @reservaFechaFin = '2024-10-24', 
    @reservaMonto = 1200.00, 
    @reservaID = @reservaID OUTPUT;
SELECT @reservaID AS NumeroReserva; -- Esperado: N�mero de reserva nuevo porque la habitaci�n est� DISPONIBLE.

DECLARE @reservaID INT;
EXEC spReservarHabitacion 
    @propietarioDocumento = '56789012', 
    @habitacionNombre = 'Suite Presidencial', 
    @reservaFechaInicio = '2024-10-25', 
    @reservaFechaFin = '2024-10-30', 
    @reservaMonto = 3000.00, 
    @reservaID = @reservaID OUTPUT;
SELECT @reservaID AS NumeroReserva; -- Esperado: 0 porque la habitaci�n est� en estado LIMPIANDO.

DECLARE @reservaID INT;
EXEC spReservarHabitacion 
    @propietarioDocumento = '78901234', 
    @habitacionNombre = 'Habitaci�n Triple', 
    @reservaFechaInicio = '2024-10-22', 
    @reservaFechaFin = '2024-10-25', 
    @reservaMonto = 360.00, 
    @reservaID = @reservaID OUTPUT;
SELECT @reservaID AS NumeroReserva; -- Esperado: N�mero de reserva nuevo si la capacidad permite. (no permite porque tiene 4 gatos)

DECLARE @reservaID INT;
EXEC spReservarHabitacion 
    @propietarioDocumento = '90123456', 
    @habitacionNombre = 'Habitaci�n Familiar', 
    @reservaFechaInicio = '2024-10-22', 
    @reservaFechaFin = '2024-10-26', 
    @reservaMonto = 800.00, 
    @reservaID = @reservaID OUTPUT;
SELECT @reservaID AS NumeroReserva; -- Esperado: 0 porque la habitaci�n est� en estado LLENA. 

/******* B ********/

CREATE FUNCTION dbo.fnServicioContratado(@ServicioNombre VARCHAR(50)) 
RETURNS BIT
AS
BEGIN 
    DECLARE @cantEsteAnio INT;
    DECLARE @cantAnioPasado INT;

   -- Contar el n�mero de contrataciones este a�o para el servicio espec�fico
SELECT @cantEsteAnio = COUNT(*)
FROM Servicio S
INNER JOIN Reserva_Servicio RS ON RS.servicioNombre = S.servicioNombre
INNER JOIN Reserva R ON R.reservaID = RS.reservaID
WHERE YEAR(R.reservaFechaInicio) = YEAR(GETDATE())
  AND S.servicioNombre = @ServicioNombre;

-- Contar el n�mero de contrataciones el a�o pasado para el servicio espec�fico
SELECT @cantAnioPasado = COUNT(*)
FROM Servicio S
INNER JOIN Reserva_Servicio RS ON RS.servicioNombre = S.servicioNombre
INNER JOIN Reserva R ON R.reservaID = RS.reservaID
WHERE YEAR(R.reservaFechaInicio) = YEAR(GETDATE()) - 1
  AND S.servicioNombre = @ServicioNombre;

    IF (@cantEsteAnio > @cantAnioPasado)
    BEGIN 
        RETURN 1; 
    END

    RETURN 0; 
END;

DECLARE @nombreServicio VARCHAR(50) = 'Aromaterapia';

SELECT dbo.fnServicioContratado(@nombreServicio) AS FueContratadoMasEsteAnio;

