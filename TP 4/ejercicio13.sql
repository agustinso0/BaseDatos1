CREATE TABLE Ordenes (
    OrdenId INT PRIMARY KEY IDENTITY(1,1),
    ClienteId INT NOT NULL,
    FechaOrden DATE NOT NULL,
    TotalOrden DECIMAL(10,2) NOT NULL
);

CREATE TABLE DetalleOrden (
    DetalleId INT PRIMARY KEY IDENTITY(1,1),
    OrdenId INT FOREIGN KEY REFERENCES Ordenes(OrdenId),
    ProductoId INT NOT NULL,
    Cantidad INT NOT NULL,
    PrecioUnitario DECIMAL(10,2) NOT NULL
);

CREATE TABLE OrdenesInconsistentes (
    InconsistenciaId INT PRIMARY KEY AUTO_INCREMENT,
    OrdenId INT,
    TotalOrden DECIMAL(10,2),
    TotalCalculado DECIMAL(10,2),
    Diferencia DECIMAL(10,2),
    FechaRegistro DATETIME DEFAULT NOW()
);

INSERT INTO Ordenes (ClienteId, FechaOrden, TotalOrden) VALUES
(1, '2024-10-01', 300.50),
(2, '2024-10-02', 150.75),
(3, '2024-10-03', 450.00),
(4, '2024-10-04', 500.99),
(5, '2024-10-05', 220.25),
(6, '2024-10-06', 670.00),
(1, '2024-10-07', 340.75),
(3, '2024-10-08', 480.50),
(4, '2024-10-09', 590.00),
(2, '2024-10-10', 325.99),
(6, '2024-10-11', 150.00),
(5, '2024-10-12', 425.75),
(7, '2024-10-13', 800.25),
(8, '2024-10-14', 275.50),
(9, '2024-10-15', 520.00),
(10, '2024-10-16', 390.75),
(2, '2024-10-17', 275.99),
(1, '2024-10-18', 650.00),
(7, '2024-10-19', 720.30),
(10, '2024-10-20', 815.50),
(8, '2024-10-21', 430.00);


INSERT INTO DetalleOrden (OrdenId, ProductoId, Cantidad, PrecioUnitario) VALUES
(1, 101, 2, 150.25),
(2, 102, 1, 150.75),
(3, 103, 3, 150.00),
(4, 104, 2, 250.49),
(5, 105, 5, 44.05),
(6, 106, 1, 670.00),
(1, 107, 3, 50.00),
(3, 108, 4, 120.13),
(4, 109, 1, 590.00),
(2, 110, 2, 75.00),
(6, 111, 2, 75.00),
(5, 112, 4, 106.44),
(7, 113, 1, 800.25),
(8, 114, 2, 137.75),
(9, 115, 3, 173.33),
(10, 116, 2, 195.38),
(2, 117, 1, 200.00),
(1, 118, 4, 162.50),
(7, 119, 5, 144.06),
(10, 120, 3, 271.83),
(8, 121, 6, 71.67);

-- PROCEDIMIENTO

DELIMITER $$

CREATE PROCEDURE ValidarIntegridadOrdenes()
BEGIN
    DECLARE listo INT DEFAULT FALSE;
    DECLARE orden_id INT;
    DECLARE total_orden DECIMAL(10,2);
    DECLARE total_calculado DECIMAL(10,2);
    DECLARE diferencia DECIMAL(10,2);

    DECLARE cursor_ordenes CURSOR FOR 
    SELECT OrdenId, TotalOrden 
    FROM Ordenes;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET listo = TRUE;

    OPEN cursor_ordenes;

    START TRANSACTION;

    FETCH cursor_ordenes INTO orden_id, total_orden;
    WHILE listo = FALSE DO
        SELECT SUM(PrecioUnitario * Cantidad)
        INTO total_calculado
        FROM DetalleOrden
        WHERE OrdenId = orden_id;

        IF total_calculado != total_orden THEN
            SET diferencia = total_orden - total_calculado;
            
            INSERT INTO OrdenesInconsistentes (OrdenId, TotalOrden, TotalCalculado, Diferencia)
            VALUES (orden_id, total_orden, total_calculado, diferencia);
        END IF;
        FETCH cursor_ordenes INTO orden_id, total_orden;
    END WHILE;

    CLOSE cursor_ordenes;

    COMMIT;

END $$

DELIMITER ;