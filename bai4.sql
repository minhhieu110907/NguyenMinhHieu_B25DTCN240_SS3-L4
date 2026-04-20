CREATE DATABASE supermarket_management;
USE supermarket_management;

CREATE TABLE ORDERS (
    OrderID INT PRIMARY KEY AUTO_INCREMENT,
    CustomerName VARCHAR(100),
    OrderDate DATETIME,
    TotalAmount DECIMAL(18, 2),
    Status ENUM('Completed', 'Canceled', 'Pending'),
    IsDeleted TINYINT(1) DEFAULT 0 -- 0: Còn sống, 1: Đã xóa mềm
);

CREATE INDEX idx_is_deleted ON ORDERS(IsDeleted);

INSERT INTO ORDERS (CustomerName, OrderDate, TotalAmount, Status) VALUES
('Nguyễn Văn A', '2023-01-10', 500000, 'Completed'),
('Khách vãng lai', '2023-02-15', 1200000, 'Canceled'), 
('Trần Thị B', '2023-05-20', 300000, 'Canceled'),    
('Lê Văn C', '2024-01-05', 850000, 'Completed');

-- Thay vì DELETE FROM ORDERS WHERE Status = 'Canceled' 
-- Chúng ta chỉ đánh dấu chúng là đã xóa.
UPDATE ORDERS 
SET IsDeleted = 1 
WHERE Status = 'Canceled';

SELECT * FROM ORDERS WHERE IsDeleted = 0;
SELECT * FROM ORDERS WHERE Status = 'Canceled';


/* CÁCH KHÔNG TỐI ƯU :
   - SELECT * FROM ORDERS WHERE Status = 'Completed';
   => Cách này sai vì sau 5 năm, bảng ORDERS sẽ phình to khủng khiếp. 
   => Dù lọc theo Status, MySQL vẫn phải tốn công quét qua hàng triệu dòng 'Canceled' 
      nếu không có Index tốt, gây chậm hệ thống.

   CÁCH TỐI ƯU (ĐANG LÀM):
   - Dùng Soft Delete (IsDeleted) kết hợp với INDEX (như đã tạo ở bước 1).
   - Khi truy vấn 'WHERE IsDeleted = 0', Database sẽ tìm đến vùng dữ liệu 
     của các đơn hàng đang hoạt động nhanh hơn rất nhiều vì nó bỏ qua vùng dữ liệu 'rác'.
   - Nếu ổ cứng thực sự cạn kiệt, giải pháp tối ưu nhất là "Data Archiving":
     Di chuyển các đơn hàng 'Canceled' sang một bảng khác (ORDERS_ARCHIVE) hoặc 
     một database lưu trữ riêng. Như vậy bảng chính sẽ nhẹ mà kế toán vẫn có chỗ để tra cứu.
*/
