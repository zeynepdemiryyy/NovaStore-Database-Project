-- ==========================================
-- PROJE: NovaStore E-Ticaret Veri Yönetim Sistemi
-- ==========================================

IF DB_ID('NovaStoreDB') IS NOT NULL
BEGIN
    ALTER DATABASE NovaStoreDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE NovaStoreDB;
END;
GO

CREATE DATABASE NovaStoreDB;
GO

USE NovaStoreDB;
GO

-- BÖLÜM 1: Tablo Oluşturma (DDL)
CREATE TABLE Categories (
    CategoryID INT IDENTITY(1,1) PRIMARY KEY,
    CategoryName VARCHAR(50) NOT NULL
);
GO

CREATE TABLE Products (
    ProductID INT IDENTITY(1,1) PRIMARY KEY,
    ProductName VARCHAR(100) NOT NULL,
    Price DECIMAL(10,2) CHECK (Price >= 0),
    Stock INT DEFAULT 0 CHECK (Stock >= 0),
    CategoryID INT FOREIGN KEY REFERENCES Categories(CategoryID) ON DELETE CASCADE
);
GO

CREATE TABLE Customers (
    CustomerID INT IDENTITY(1,1) PRIMARY KEY,
    FullName VARCHAR(50) NOT NULL,
    City VARCHAR(20),
    Email VARCHAR(100) UNIQUE NOT NULL
);
GO

CREATE TABLE Orders (
    OrderID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT FOREIGN KEY REFERENCES Customers(CustomerID) ON DELETE CASCADE,
    OrderDate DATETIME DEFAULT GETDATE(),
    TotalAmount DECIMAL(10,2) CHECK (TotalAmount >= 0)
);
GO

CREATE TABLE OrderDetails (
    DetailID INT IDENTITY(1,1) PRIMARY KEY,
    OrderID INT FOREIGN KEY REFERENCES Orders(OrderID) ON DELETE CASCADE,
    ProductID INT FOREIGN KEY REFERENCES Products(ProductID),
    Quantity INT CHECK (Quantity > 0)
);
GO

-- BÖLÜM 2: Veri Ekleme (DML)
INSERT INTO Categories (CategoryName) VALUES
(N'Elektronik'),
(N'Giyim'),
(N'Kitap'),
(N'Kozmetik'),
(N'Ev ve Yaşam');
GO

INSERT INTO Products (ProductName, Price, Stock, CategoryID) VALUES
(N'Kablosuz Kulaklık', 1499.99, 15, 1),
(N'Akıllı Saat', 2999.00, 8, 1),
(N'Mekanik Klavye', 850.50, 25, 1),
(N'Pamuklu T-Shirt', 199.90, 50, 2),
(N'Kot Pantolon', 450.00, 18, 2),
(N'Deri Ceket', 1200.00, 5, 2),
(N'Veritabanı Sistemleri Kitabı', 120.00, 30, 3),
(N'SQL Öğreniyorum Kitabı', 85.00, 12, 3),
(N'Nemlendirici Krem', 150.00, 40, 4),
(N'Parfüm 100ml', 650.00, 10, 4),
(N'Kahve Makinesi', 2100.00, 7, 5),
(N'Masa Lambası', 250.00, 22, 5);
GO

INSERT INTO Customers (FullName, City, Email) VALUES
(N'Ahmet Yılmaz', N'İstanbul', 'ahmet.yilmaz@email.com'),
(N'Ayşe Kaya', N'Ankara', 'ayse.kaya@email.com'),
(N'Mehmet Demir', N'İzmir', 'mehmet.demir@email.com'),
(N'Elif Şahin', N'Bursa', 'elif.sahin@email.com'),
(N'Can Öztürk', N'Antalya', 'can.ozturk@email.com'),
(N'Zeynep Çelik', N'İstanbul', 'zeynep.celik@email.com');
GO

INSERT INTO Orders (CustomerID, OrderDate, TotalAmount) VALUES
(1, '2026-08-01 10:30:00', 1619.99),
(2, '2026-08-05 14:15:00', 2999.00),
(1, '2026-08-10 09:00:00', 850.50),
(3, '2026-08-12 16:45:00', 649.90),
(4, '2026-08-15 11:20:00', 120.00),
(5, '2026-08-18 18:10:00', 2350.00),
(2, '2026-08-20 13:00:00', 150.00),
(6, '2026-08-22 15:30:00', 1200.00);
GO

INSERT INTO OrderDetails (OrderID, ProductID, Quantity) VALUES
(1, 1, 1),
(1, 7, 1),
(2, 2, 1),
(3, 3, 1),
(4, 4, 1),
(4, 5, 1),
(5, 7, 1),
(6, 11, 1),
(6, 12, 1),
(7, 9, 1),
(8, 6, 1);
GO

-- BÖLÜM 3: Analiz Sorguları (DQL)
SELECT ProductName AS [Ürün Adı], Stock AS [Stok Miktarı]
FROM Products
WHERE Stock < 20
ORDER BY Stock DESC;
GO

SELECT c.FullName AS [Müşteri Adı], c.City AS [Şehir], o.OrderDate AS [Sipariş Tarihi], o.TotalAmount AS [Toplam Tutar]
FROM Customers c
INNER JOIN Orders o ON c.CustomerID = o.CustomerID
ORDER BY o.OrderDate DESC;
GO

SELECT c.FullName AS [Müşteri Adı], p.ProductName AS [Ürün Adı], p.Price AS [Fiyat], cat.CategoryName AS [Kategori]
FROM Customers c
INNER JOIN Orders o ON c.CustomerID = o.CustomerID
INNER JOIN OrderDetails od ON o.OrderID = od.OrderID
INNER JOIN Products p ON od.ProductID = p.ProductID
INNER JOIN Categories cat ON p.CategoryID = cat.CategoryID
WHERE c.FullName = N'Ahmet Yılmaz';
GO

SELECT cat.CategoryName AS [Kategori], COUNT(p.ProductID) AS [Ürün Sayısı]
FROM Categories cat
LEFT JOIN Products p ON cat.CategoryID = p.CategoryID
GROUP BY cat.CategoryID, cat.CategoryName
ORDER BY [Ürün Sayısı] DESC;
GO

SELECT c.FullName AS [Müşteri Adı], ISNULL(SUM(o.TotalAmount), 0) AS [Toplam Ciro]
FROM Customers c
LEFT JOIN Orders o ON c.CustomerID = o.CustomerID
GROUP BY c.CustomerID, c.FullName
ORDER BY [Toplam Ciro] DESC;
GO

SELECT o.OrderID AS [Sipariş No], c.FullName AS [Müşteri], o.OrderDate AS [Sipariş Tarihi],
       DATEDIFF(DAY, o.OrderDate, GETDATE()) AS [Geçen Gün Sayısı]
FROM Orders o
INNER JOIN Customers c ON o.CustomerID = c.CustomerID
ORDER BY o.OrderDate DESC;
GO

-- BÖLÜM 4: View ve Backup
IF OBJECT_ID('dbo.vw_SiparisOzet', 'V') IS NOT NULL
    DROP VIEW dbo.vw_SiparisOzet;
GO

CREATE VIEW dbo.vw_SiparisOzet AS
SELECT c.FullName AS MusteriAdi, o.OrderDate AS SiparisTarihi, p.ProductName AS UrunAdi, od.Quantity AS Adet
FROM Customers c
INNER JOIN Orders o ON c.CustomerID = o.CustomerID
INNER JOIN OrderDetails od ON o.OrderID = od.OrderID
INNER JOIN Products p ON od.ProductID = p.ProductID;
GO

SELECT * FROM dbo.vw_SiparisOzet;
GO

EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
GO

BACKUP DATABASE NovaStoreDB 
TO DISK = N'C:\Yedek\NovaStoreDB.bak' 
WITH FORMAT, MEDIANAME = 'NovaStore_Backup', NAME = 'Full Backup of NovaStoreDB';
GO