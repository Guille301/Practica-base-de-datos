USE CatHotelDefinitivo
GO

/**************************************/
/********** 5)  TRIGGERS  ************/
/************************************/


	/* A */

	CREATE TABLE ReservaLog (
    logId INT IDENTITY(1,1) PRIMARY KEY,
    reservaId INT NOT NULL,
    montoAnterior DECIMAL(10, 2),
    montoNuevo DECIMAL(10, 2),
    operacion NVARCHAR(10), 
    fechaHoraRegistro DATETIME DEFAULT GETDATE(),
    usuario NVARCHAR(50) DEFAULT SYSTEM_USER,
    equipo NVARCHAR(50) DEFAULT HOST_NAME()
);

CREATE TRIGGER TR_Registrar_Reserva_Log
ON Reserva
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- Insertar un nuevo registro en ReservaLog cuando se crea una nueva reserva
    INSERT INTO ReservaLog (reservaId, montoNuevo, operacion)
    SELECT r.reservaID, r.reservaMonto, 'INSERT'
    FROM INSERTED r
    WHERE NOT EXISTS (
        SELECT 1 
        FROM ReservaLog l 
        WHERE l.reservaId = r.reservaID 
        AND l.operacion = 'INSERT'
    );

    -- Insertar registros de auditoría para modificaciones en el campo monto
    INSERT INTO ReservaLog (reservaId, montoAnterior, montoNuevo, operacion)
    SELECT r.reservaID, d.reservaMonto AS montoAnterior, r.reservaMonto AS montoNuevo, 'UPDATE'
    FROM INSERTED r
    INNER JOIN DELETED d ON r.reservaID = d.reservaID
    WHERE r.reservaMonto <> d.reservaMonto;  -- Solo si el monto ha cambiado

    -- Registrar la fecha, usuario y equipo
    UPDATE ReservaLog
    SET fechaHoraRegistro = GETDATE(),
        usuario = SYSTEM_USER,
        equipo = HOST_NAME()
    WHERE reservaId IN (SELECT reservaID FROM INSERTED);
END;
GO

-- Insertar propietarios
INSERT INTO Propietario (propietarioDocumento, propietarioNombre, propietarioTelefono, propietarioEmail) 
VALUES 
('12300000', 'Carlos Ruiz', '091234567', 'carlosruiz@example.com'),
('12300001', 'Laura Méndez', NULL, 'lauramedendez@example.com');
GO

-- Insertar gatos
INSERT INTO Gato (gatoNombre, gatoRaza, gatoEdad, gatoPeso, propietarioDocumento) 
VALUES 
('Nube', 'Bengalí', 2, 5.00, '12300000'),
('Sombra', 'Maine Coon', 4, 8.50, '12300001');
GO

-- Insertar habitaciones
INSERT INTO Habitacion (habitacionNombre, habitacionCapacidad, habitacionPrecio, habitacionEstado) 
VALUES 
('Habitacion100', 2, 120.00, 'DISPONIBLE'),
('Habitacion200', 4, 180.00, 'DISPONIBLE');
GO

-- Insertar reservas
INSERT INTO Reserva (gatoID, habitacionNombre, reservaFechaInicio, reservaFechaFin, reservaMonto) 
VALUES 
(3, 'Habitacion100', '2024-10-31', '2024-11-05', 600.00), 
(4, 'Habitacion200', '2024-11-01', '2024-11-03', 400.00);  
GO

	/* B */

CREATE TRIGGER trg_Reserva_Solapamiento
ON Reserva
INSTEAD OF INSERT
AS
BEGIN
    -- Insertar solo aquellas reservas que no tengan solapamientos
    INSERT INTO Reserva (gatoID, habitacionNombre, reservaFechaInicio, reservaFechaFin, reservaMonto)
    SELECT i.gatoID, i.habitacionNombre, i.reservaFechaInicio, i.reservaFechaFin, i.reservaMonto
    FROM inserted i
    WHERE NOT EXISTS (
        SELECT 1
        FROM Reserva r
        WHERE r.gatoID = i.gatoID
        AND (
            (i.reservaFechaInicio < r.reservaFechaFin) 
            AND (i.reservaFechaFin > r.reservaFechaInicio)
        )
    );
END;


-- Insertar propietarios
INSERT INTO Propietario (propietarioDocumento, propietarioNombre, propietarioTelefono, propietarioEmail) 
VALUES 
('23456791', 'Francisco López', '091234568', 'francisco.lopez@example.com'),
('23456792', 'Sofía Torres', '091234569', 'sofia.torres@example.com');

-- Insertar gatos
INSERT INTO Gato (gatoNombre, gatoRaza, gatoEdad, gatoPeso, propietarioDocumento) 
VALUES 
('Mimi', 'Siamés', 3, 4.5, '23456791'),
('Gato', 'Persa', 2, 3.8, '23456792');

-- Insertar habitaciones
INSERT INTO Habitacion (habitacionNombre, habitacionCapacidad, habitacionPrecio, habitacionEstado) 
VALUES 
('Habitacion300', 3, 150.0, 'DISPONIBLE'),
('Habitacion400', 4, 100.0, 'LIMPIANDO');

-- Insertar reservas
INSERT INTO Reserva (gatoID, habitacionNombre, reservaFechaInicio, reservaFechaFin, reservaMonto) 
VALUES 
(3, 'Habitacion300', '2024-11-10', '2024-11-19', 600.0), 
(4, 'Habitacion400', '2024-10-27', '2024-10-29', 400.0);

-- Insertar servicios
INSERT INTO Servicio (servicioNombre, servicioPrecio) 
VALUES 
('Cuidado Especial', 50.0),
('Atención Personalizada', 70.0);

-- Insertar servicios en reservas
INSERT INTO Reserva_Servicio (reservaID, servicioNombre, cantidad) 
VALUES 
(1, 'Cuidado Especial', 1),
(2, 'Atención Personalizada', 2);

