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

    -- Obtener la capacidad y el estado de la habitación
    SELECT @capacidadHabitacion = habitacionCapacidad, 
           @estadoHabitacion = habitacionEstado
    FROM Habitacion
    WHERE habitacionNombre = @habitacionNombre;

    -- Verificar si la habitación está "LLENA" o "LIMPIANDO"
    IF @estadoHabitacion = 'LLENA' OR @estadoHabitacion = 'LIMPIANDO'
    BEGIN
        SET @reservaID = 0;
        RETURN;
    END

    -- Contar la cantidad de gatos actualmente en la habitación para el período solicitado
    SELECT @cantidadGatosActuales = COUNT(*)
    FROM Reserva r
    INNER JOIN Gato g ON r.gatoID = g.gatoID
    WHERE r.habitacionNombre = @habitacionNombre
    AND r.reservaFechaFin > @reservaFechaInicio
    AND r.reservaFechaInicio < @reservaFechaFin;

    -- Contar los gatos del propietario que se agregarán
    SELECT @nuevosGatos = COUNT(*)
    FROM Gato
    WHERE propietarioDocumento = @propietarioDocumento;

    -- Verificar si se superará la capacidad de la habitación
    IF (@cantidadGatosActuales + @nuevosGatos > @capacidadHabitacion)
    BEGIN
        SET @reservaID = 0;
        RETURN;
    END

    -- Insertar las reservas y obtener el ID de la última reserva insertada
    INSERT INTO Reserva (gatoID, habitacionNombre, reservaFechaInicio, reservaFechaFin, reservaMonto)
    SELECT gatoID, 
           @habitacionNombre, 
           @reservaFechaInicio, 
           @reservaFechaFin, 
           @reservaMonto
    FROM Gato
    WHERE propietarioDocumento = @propietarioDocumento;

    -- Asignar el ID de la última reserva insertada al parámetro de salida
    SELECT TOP 1 @reservaID = reservaID 
	FROM Reserva
	ORDER BY reservaID DESC;

    -- Actualizar el estado de la habitación a "LLENA" si se alcanzó la capacidad
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
SELECT @reservaID AS NumeroReserva; -- Esperado: Número de reserva nuevo si la capacidad permite, 0 si está llena.

DECLARE @reservaID INT;
EXEC spReservarHabitacion 
    @propietarioDocumento = '23456789', 
    @habitacionNombre = 'Habitación Doble', 
    @reservaFechaInicio = '2024-11-01', 
    @reservaFechaFin = '2024-11-05', 
    @reservaMonto = 800.00, 
    @reservaID = @reservaID OUTPUT;
SELECT @reservaID AS NumeroReserva; -- Esperado: 0 porque la habitación está en estado LLENA.

DECLARE @reservaID INT;
EXEC spReservarHabitacion 
    @propietarioDocumento = '34567890', 
    @habitacionNombre = 'Habitación Individual', 
    @reservaFechaInicio = '2024-10-20', 
    @reservaFechaFin = '2024-10-25', 
    @reservaMonto = 375.00, 
    @reservaID = @reservaID OUTPUT;
SELECT @reservaID AS NumeroReserva; -- Esperado: Número de reserva nuevo porque la habitación está DISPONIBLE.

DECLARE @reservaID INT;
EXEC spReservarHabitacion 
    @propietarioDocumento = '67890124', 
    @habitacionNombre = 'Ático de Lujo', 
    @reservaFechaInicio = '2024-10-21', 
    @reservaFechaFin = '2024-10-24', 
    @reservaMonto = 1200.00, 
    @reservaID = @reservaID OUTPUT;
SELECT @reservaID AS NumeroReserva; -- Esperado: Número de reserva nuevo porque la habitación está DISPONIBLE.

DECLARE @reservaID INT;
EXEC spReservarHabitacion 
    @propietarioDocumento = '56789012', 
    @habitacionNombre = 'Suite Presidencial', 
    @reservaFechaInicio = '2024-10-25', 
    @reservaFechaFin = '2024-10-30', 
    @reservaMonto = 3000.00, 
    @reservaID = @reservaID OUTPUT;
SELECT @reservaID AS NumeroReserva; -- Esperado: 0 porque la habitación está en estado LIMPIANDO.

DECLARE @reservaID INT;
EXEC spReservarHabitacion 
    @propietarioDocumento = '78901234', 
    @habitacionNombre = 'Habitación Triple', 
    @reservaFechaInicio = '2024-10-22', 
    @reservaFechaFin = '2024-10-25', 
    @reservaMonto = 360.00, 
    @reservaID = @reservaID OUTPUT;
SELECT @reservaID AS NumeroReserva; -- Esperado: Número de reserva nuevo si la capacidad permite. (no permite porque tiene 4 gatos)

DECLARE @reservaID INT;
EXEC spReservarHabitacion 
    @propietarioDocumento = '90123456', 
    @habitacionNombre = 'Habitación Familiar', 
    @reservaFechaInicio = '2024-10-22', 
    @reservaFechaFin = '2024-10-26', 
    @reservaMonto = 800.00, 
    @reservaID = @reservaID OUTPUT;
SELECT @reservaID AS NumeroReserva; -- Esperado: 0 porque la habitación está en estado LLENA. 

/******* B ********/

CREATE FUNCTION dbo.fnServicioContratado(@ServicioNombre VARCHAR(50)) 
RETURNS BIT
AS
BEGIN 
    DECLARE @cantEsteAnio INT;
    DECLARE @cantAnioPasado INT;

   -- Contar el número de contrataciones este año para el servicio específico
SELECT @cantEsteAnio = COUNT(*)
FROM Servicio S
INNER JOIN Reserva_Servicio RS ON RS.servicioNombre = S.servicioNombre
INNER JOIN Reserva R ON R.reservaID = RS.reservaID
WHERE YEAR(R.reservaFechaInicio) = YEAR(GETDATE())
  AND S.servicioNombre = @ServicioNombre;

-- Contar el número de contrataciones el año pasado para el servicio específico
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

