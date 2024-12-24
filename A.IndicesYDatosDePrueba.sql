Create database CatHotelDefinitivo2

USE CatHotelDefinitivo2
GO



CREATE TABLE Propietario (
    propietarioDocumento CHAR(30) PRIMARY KEY,
    propietarioNombre VARCHAR(100) NOT NULL,
    propietarioTelefono VARCHAR(20) NULL,
    propietarioEmail VARCHAR(100) NULL,
    CONSTRAINT CHK_Propietario_TelefonoEmail CHECK (propietarioTelefono IS NOT NULL OR propietarioEmail IS NOT NULL) );
GO
CREATE TABLE Gato (
    gatoID INT IDENTITY(1,1) PRIMARY KEY,
    gatoNombre VARCHAR(50) NOT NULL,
    gatoRaza VARCHAR(50),
    gatoEdad INT,
    gatoPeso DECIMAL(5,2),
    propietarioDocumento CHAR(30) NOT NULL,
    CONSTRAINT CHK_Gato_Edad CHECK (gatoEdad >= 0),
    CONSTRAINT CHK_Gato_Peso CHECK (gatoPeso > 0),
    CONSTRAINT FK_Gato_Propietario FOREIGN KEY (propietarioDocumento) REFERENCES Propietario(propietarioDocumento) );
GO
CREATE TABLE Habitacion (
    habitacionNombre CHAR(30) PRIMARY KEY,
    habitacionCapacidad INT,
	habitacionPrecio DECIMAL(6,2),
    habitacionEstado VARCHAR(20),
    CONSTRAINT CHK_Habitacion_Capacidad CHECK (habitacionCapacidad > 0),
    CONSTRAINT CHK_Habitacion_Precio CHECK (habitacionPrecio > 0),
    CONSTRAINT CHK_Habitacion_Estado CHECK (habitacionEstado IN ('DISPONIBLE', 'LLENA', 'LIMPIANDO')) );
GO
CREATE TABLE Reserva (
    reservaID INT IDENTITY(1,1) PRIMARY KEY,
    gatoID INT NOT NULL,
    habitacionNombre CHAR(30) NOT NULL,
    reservaFechaInicio DATE NOT NULL,
    reservaFechaFin DATE NOT NULL,
    reservaMonto DECIMAL(7,2) NOT NULL,
    CONSTRAINT FK_Reserva_Gato FOREIGN KEY (gatoID) REFERENCES Gato(gatoID),
    CONSTRAINT FK_Reserva_Habitacion FOREIGN KEY (habitacionNombre) REFERENCES Habitacion(habitacionNombre),
    CONSTRAINT CHK_Reserva_Fecha CHECK (reservaFechaFin > reservaFechaInicio) );
GO
CREATE TABLE Servicio (
    servicioNombre CHAR(30) NOT NULL PRIMARY KEY,
    servicioPrecio DECIMAL(7,2),
    CONSTRAINT CHK_Servicio_Precio CHECK (servicioPrecio >= 0) );
GO
CREATE TABLE Reserva_Servicio (
    reservaID INT NOT NULL,
    servicioNombre CHAR(30) NOT NULL,
    cantidad INT DEFAULT 1,
    PRIMARY KEY (reservaID, servicioNombre),
    CONSTRAINT CHK_ReservaServicio_Cantidad CHECK (cantidad > 0),
    CONSTRAINT FK_ReservaServicio_Reserva FOREIGN KEY (reservaID) REFERENCES Reserva(reservaID),
    CONSTRAINT FK_ReservaServicio_Servicio FOREIGN KEY (servicioNombre) REFERENCES Servicio(servicioNombre) );
GO





/**************************************/
/************  INDICES  **************/
/************************************/

/* �ndice para Reserva por gatoID y fechas */
CREATE INDEX IX_Reserva_GatoID_Fecha ON Reserva(gatoID, reservaFechaInicio, reservaFechaFin);

/* �ndice para Reserva_Servicio por reservaID y servicioNombre */
CREATE INDEX IX_ReservaServicio_ReservaID_ServicioNombre ON Reserva_Servicio(reservaID, servicioNombre);

/* �ndice para Habitacion por habitacionEstado */
CREATE INDEX IX_Habitacion_Estado ON Habitacion(habitacionEstado);

/* �ndice para Gato por propietarioDocumento */
CREATE INDEX IX_Gato_PropietarioDocumento ON Gato(propietarioDocumento);

/* �ndice para Reserva por reservaFechaInicio y reservaMonto */
CREATE INDEX IX_Reserva_FechaInicio_Monto ON Reserva(reservaFechaInicio, reservaMonto);

/* �ndice para Propietario por propietarioNombre */
CREATE INDEX IX_Propietario_Nombre ON Propietario(propietarioNombre);


/**************************************/
/*********  DATOS DE PRUEBA  *********/
/************************************/

--Propietarios
INSERT INTO Propietario(propietarioDocumento, propietarioNombre, propietarioTelefono, propietarioEmail) 
VALUES  (12345678, 'Santiago Beltr�n', '093245678', 'santiago.beltran@domain.com'),
        (23456789, 'Valentina Ortiz', '097123456', 'valentina.ortiz@domain.com'),
        (34567890, 'Joaqu�n Santamar�a', '094567123', 'joaquin.santamaria@domain.com'),
        (45678901, 'Luc�a Fern�ndez', '091678234', 'lucia.fernandez@domain.com'),
        (56789012, 'Mart�n Esquivel', '098765123', 'martin.esquivel@domain.com'),
        (67890123, 'Camila R�os', '093456789', 'camila.rios@domain.com'),
        (78901234, 'Mat�as �lvarez', '096543210', 'matias.alvarez@domain.com'),
        (89012345, 'Emilia Guevara', '094321678', 'emilia.guevara@domain.com'),
        (90123456, 'Facundo Mendoza', '091234567', 'facundo.mendoza@domain.com'),
        (12345679, 'Agustina Sol�s', '097654321', 'agustina.solis@domain.com'),
        (23456780, 'Tom�s Figueroa', '092345678', 'tomas.figueroa@domain.com'),
        (34567891, 'Sof�a Pereyra', '099876543', 'sofia.pereyra@domain.com'),
        (45678902, 'Benjam�n Dur�n', '095432167', 'benjamin.duran@domain.com'),
        (56789013, 'M�a Castro', '098123456', 'mia.castro@domain.com'),
        (67890124, 'Julieta Ram�rez', '094567890', 'julieta.ramirez@domain.com');


--Gato
DBCC CHECKIDENT ('Gato', RESEED, 1);
INSERT INTO Gato(gatoNombre, gatoRaza, gatoEdad, gatoPeso, propietarioDocumento) 
VALUES  ('Misu', 'Siames', 3, 4.5, 12345678),
        ('Luna', 'Persa', 2, 3.8, 23456789),
        ('Tom', 'Bengal�', 4, 5.2, 34567890),
        ('Nina', 'Maine Coon', 5, 6.1, 45678901),
        ('Simba', 'Abisinio', 1, 3.0, 56789012),
        ('Milo', 'Ragdoll', 3, 4.7, 67890123),
        ('Cleo', 'Siberiano', 2, 4.2, 78901234),
        ('Kira', 'Sphynx', 4, 3.5, 89012345),
        ('Leo', 'Azul Ruso', 3, 4.6, 90123456),
        ('Nala', 'Chartreux', 2, 4.1, 12345679),
        ('Olivia', 'Birmano', 5, 5.3, 23456780),
        ('Thor', 'Bombay', 4, 4.9, 34567891),
        ('Bella', 'Manx', 3, 3.8, 45678902),
        ('Felix', 'Ocicat', 2, 3.9, 56789013),
        ('Lola', 'Savannah', 4, 5.0, 67890124),
		('Loli', 'Manx', 13, 5.0, 12345679),
		('Michi', 'Persa', 15, 4.5, 78901234),
		('Mich', 'Persa', 13, 4.5, 78901234),
		('Mici', 'Persa', 17, 4.5, 78901234)
		;
--Habitaciones

INSERT INTO Habitacion(habitacionNombre, habitacionCapacidad, habitacionPrecio, habitacionEstado) 
VALUES  ('Suite Ejecutiva', 2, 150.00, 'DISPONIBLE'),
        ('Habitaci�n Doble', 4, 100.00, 'LLENA'),
        ('Habitaci�n Individual', 1, 75.00, 'DISPONIBLE'),
        ('Suite Presidencial', 2, 3000.00, 'LIMPIANDO'),
        ('Habitaci�n Familiar', 6, 200.00, 'LLENA'),
        ('Habitaci�n Triple', 3, 120.00, 'DISPONIBLE'),
        ('Habitaci�n Econ�mica', 2, 570.00, 'LIMPIANDO'),
        ('�tico de Lujo', 2, 250.00, 'DISPONIBLE'),
        ('Habitaci�n Compartida', 8, 30.00, 'LLENA'),
        ('Suite Nupcial', 2, 500, 'LIMPIANDO');


--Reservas
DBCC CHECKIDENT ('Reserva', RESEED, 0);
INSERT INTO Reserva(gatoID, habitacionNombre, reservaFechaInicio, reservaFechaFin, reservaMonto) 
VALUES  
    (1, 'Suite Ejecutiva', '2023-06-01', '2023-06-04', 600.00), 
	(19, 'Suite Ejecutiva', '2023-09-05', '2023-09-06', 600.00),  
    (19, 'Suite Ejecutiva', '2023-09-07', '2023-09-10', 600.00),  
    (17, 'Suite Ejecutiva', '2023-09-24', '2023-09-26', 600.00),  
    (18, 'Suite Ejecutiva', '2024-09-27', '2024-09-30', 600.00),
   
	(2, 'Habitaci�n Doble', '2024-09-02', '2024-09-04', 200.00), 
	(2, 'Habitaci�n Doble', '2024-09-05', '2024-09-14', 200.00),

    (3, 'Habitaci�n Individual', '2024-09-03', '2024-09-06', 225.00),
	(3, 'Habitaci�n Individual', '2023-09-07', '2023-09-10', 225.00),

	(8, '�tico de Lujo', '2024-08-10', '2024-08-13', 1000.00),
	(8, '�tico de Lujo', '2024-09-03', '2024-09-07', 1000.00), 

    (4, 'Suite Presidencial', '2024-09-01', '2024-09-07', 2100.00), 
    (5, 'Habitaci�n Familiar', '2024-09-04', '2024-09-08', 800.00), 
    (6, 'Habitaci�n Triple', '2024-09-02', '2024-09-05', 360.00), 
    (7, 'Habitaci�n Econ�mica', '2024-09-01', '2024-09-03', 100.00), 
    (9, 'Habitaci�n Compartida', '2024-09-01', '2024-09-02', 30.00), 
    (10, 'Suite Nupcial', '2024-09-02', '2024-09-05', 540.00),
	(9, 'Habitaci�n Individual', '2024-10-05', '2024-10-08', 150.00),  
    (10, 'Suite Ejecutiva', '2024-10-10', '2024-10-12', 600.00),  
    (11, 'Habitaci�n Triple', '2024-10-15', '2024-10-18', 360.00),  
    (12, 'Habitaci�n Doble', '2024-10-03', '2024-10-06', 200.00),  
    (13, '�tico de Lujo', '2024-10-21', '2024-10-25', 1000.00),  
    (14, 'Suite Nupcial', '2024-10-10', '2024-10-14', 500.00),
	(1, 'Habitaci�n Doble', '2024-01-10', '2024-01-15', 200.00), 
    (2, 'Habitaci�n Individual', '2024-01-05', '2024-01-07', 150.00); 

---Servicio
INSERT INTO Servicio (servicioNombre, servicioPrecio)
VALUES ('Rascador de Lujo', 45.00),
		('Alimentaci�n Gourmet', 25.50),
		('Ba�o Espumoso', 30.00),
		('Cama Suave', 60.00),
		('Juguetes Interactivos', 20.00),
		('Corte de U�as', 15.00),
		('Peinado', 35.00),
		('Aromaterapia', 50.00),
		('Cuidado Dental', 40.00),
		('Collar Personalizado', 25.00),
		('Fuente de Agua', 70.00),
		('Arena Premium', 18.00),
		('Comida Org�nica', 22.00),
		('Manta T�rmica', 55.00),
		('Peluquer�a Exclusiva', 80.00),
		('CONTROL_PARASITOS', 35.00),
		('REVISION_VETERINARIA', 50.00);

		INSERT INTO Reserva (gatoID, habitacionNombre, reservaFechaInicio, reservaFechaFin, reservaMonto) 
VALUES 
    (9, 'Habitaci�n Individual', '2024-10-05', '2024-10-08', 150.00),  
    (10, 'Suite Ejecutiva', '2024-10-10', '2024-10-12', 600.00),  
    (11, 'Habitaci�n Triple', '2024-10-15', '2024-10-18', 360.00),  
    (12, 'Habitaci�n Doble', '2024-10-03', '2024-10-06', 200.00),  
    (13, '�tico de Lujo', '2024-10-21', '2024-10-25', 1000.00),  
    (14, 'Suite Nupcial', '2024-10-10', '2024-10-14', 500.00);

--Reserva servicio

INSERT INTO Reserva_Servicio (reservaID, servicioNombre, cantidad) 
VALUES  (2, 'Peinado', 2),            
        (3, 'Aromaterapia', 1),        
        (4, 'Cama Suave', 3),          
        (5, 'Ba�o Espumoso', 1),       
        (6, 'Alimentaci�n Gourmet', 2),
        (7, 'Comida Org�nica', 4),     
        (8, 'Peinado', 1),            
        (9, 'Ba�o Espumoso', 3),       
        (10, 'Cama Suave', 2),          
        (11, 'Aromaterapia', 1),
		(12, 'Aromaterapia', 1),
		(13, 'Cama Suave', 3),
		(14, 'Ba�o Espumoso', 1),
		(15, 'Alimentaci�n Gourmet', 2),
		(2, 'Comida Org�nica', 20),
		(2, 'Juguetes Interactivos', 1),
		(2, 'Rascador de Lujo', 1),
		(2, 'Corte de U�as', 1),
		(2, 'Collar Personalizado', 12),
		(2, 'Fuente de Agua', 1),
		(2, 'Arena Premium', 15),
		(2, 'Manta T�rmica', 1),
		(2, 'Peluquer�a Exclusiva', 1),
		(2, 'CONTROL_PARASITOS', 1),
		(2, 'Cuidado Dental', 1),
		(2, 'Alimentaci�n Gourmet', 2), 
		(2, 'Ba�o Espumoso', 5), 
		(2, 'Cama Suave', 3),
		(2, 'REVISION_VETERINARIA', 3),
		(2, 'Aromaterapia', 3),
		(21, 'Ba�o Espumoso', 1), 
		(21, 'Cama Suave', 2),  
		(22, 'Rascador de Lujo', 1), 
		(22, 'Corte de U�as', 2), 
		(22, 'Aromaterapia', 1),  
		(23, 'Alimentaci�n Gourmet', 2), 
		(23, 'Ba�o Espumoso', 1), 
		(23, 'Peinado', 1),  
		(24, 'Cama Suave', 3), 
		(24, 'Corte de U�as', 1),  
		(25, 'Aromaterapia', 1), 
		(25, 'Cuidado Dental', 1), 
		(25, 'Manta T�rmica', 1),  
		(26, 'Peinado', 1), 
		(26, 'Comida Org�nica', 3), 
		(26, 'Juguetes Interactivos', 1);

INSERT INTO Reserva_Servicio (reservaID, servicioNombre, cantidad) 
VALUES  
    (11, 'CONTROL_PARASITOS', 1),  
    (11, 'Cama Suave', 1),
    (11, 'Alimentaci�n Gourmet', 2), 
    (12, 'CONTROL_PARASITOS', 1), 
    (12, 'Ba�o Espumoso', 1);   
	
