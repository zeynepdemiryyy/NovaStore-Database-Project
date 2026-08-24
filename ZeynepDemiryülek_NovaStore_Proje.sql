USE NovaStoreDB;

-- Soru 1: Stok miktarı 20'den az olan ürünler
SELECT ProductName AS [Ürün Adı], Stock AS [Stok Miktarı]
FROM dbo.Products WHERE Stock < 20 ORDER BY Stock DESC;

-- Soru 2: Müşteri sipariş tarihleri ve tutarları
SELECT c.FullName AS [Müşteri Adı], c.City AS [Şehir], o.OrderDate AS [Sipariş Tarihi], o.TotalAmount AS [Toplam Tutar]
FROM dbo.Customers c INNER JOIN dbo.Orders o ON c.CustomerID = o.CustomerID ORDER BY o.OrderDate DESC;

-- Soru 3: Ahmet Yılmaz'ın aldığı ürünler
SELECT c.FullName AS [Müşteri Adı], p.ProductName AS [Ürün Adı], p.Price AS [Fiyat], cat.CategoryName AS [Kategori]
FROM dbo.Customers c
INNER JOIN dbo.Orders o ON c.CustomerID = o.CustomerID
INNER JOIN dbo.OrderDetails od ON o.OrderID = od.OrderID
INNER JOIN dbo.Products p ON od.ProductID = p.ProductID
INNER JOIN dbo.Categories cat ON p.CategoryID = cat.CategoryID
WHERE c.FullName = N'Ahmet Yılmaz';

-- Soru 4: Kategorilerdeki ürün sayıları
SELECT cat.CategoryName AS [Kategori], COUNT(p.ProductID) AS [Ürün Sayısı]
FROM dbo.Categories cat LEFT JOIN dbo.Products p ON cat.CategoryID = p.CategoryID
GROUP BY cat.CategoryID, cat.CategoryName ORDER BY [Ürün Sayısı] DESC;

-- Soru 5: Müşteri Ciro Analizi
SELECT c.FullName AS [Müşteri Adı], ISNULL(SUM(o.TotalAmount), 0) AS [Toplam Ciro]
FROM dbo.Customers c LEFT JOIN dbo.Orders o ON c.CustomerID = o.CustomerID
GROUP BY c.CustomerID, c.FullName ORDER BY [Toplam Ciro] DESC;

-- Soru 6: Siparişlerin üzerinden geçen gün sayısı
SELECT o.OrderID AS [Sipariş No], c.FullName AS [Müşteri], o.OrderDate AS [Sipariş Tarihi],
       DATEDIFF(DAY, o.OrderDate, GETDATE()) AS [Geçen Gün Sayısı]
FROM dbo.Orders o INNER JOIN dbo.Customers c ON o.CustomerID = c.CustomerID ORDER BY o.OrderDate DESC;
