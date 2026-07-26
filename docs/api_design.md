# AI Gym Coach

# API Design Specification

**Version:** 1.0

---

# 1. Giới thiệu

Tài liệu này mô tả toàn bộ các RESTful API được sử dụng trong hệ thống AI Gym Coach.

API được xây dựng bằng FastAPI và sử dụng giao thức HTTPS để giao tiếp giữa ứng dụng Flutter và Backend.

Dữ liệu trao đổi sử dụng định dạng JSON.

---

# 2. Quy ước chung

## Base URL

```text
http://localhost:8000/api/v1
```

Trong môi trường Production:

```text
https://api.aigymcoach.com/api/v1
```

---

## Response thành công

```json
{
    "success": true,
    "message": "Success",
    "data": {}
}
```

---

## Response lỗi

```json
{
    "success": false,
    "message": "Error message",
    "errors": []
}
```

---

## Authentication

Sau khi đăng nhập thành công, Backend trả về JWT Access Token.

Các API yêu cầu xác thực sẽ gửi Header:

```
Authorization: Bearer <access_token>
```

---

# 3. Authentication API

## Đăng ký

POST

```
/auth/register
```

### Request

```json
{
    "full_name": "Nguyen Van A",
    "email": "user@gmail.com",
    "password": "123456"
}
```

### Response

```json
{
    "success": true,
    "message": "Register successfully"
}
```

---

## Đăng nhập

POST

```
/auth/login
```

### Request

```json
{
    "email": "user@gmail.com",
    "password": "123456"
}
```

### Response

```json
{
    "success": true,
    "access_token": "...",
    "token_type": "Bearer"
}
```

---

# 4. User API

## Lấy thông tin cá nhân

GET

```
/users/profile
```

---

## Cập nhật thông tin

PUT

```
/users/profile
```

Cho phép cập nhật:

* Họ tên
* Ảnh đại diện
* Giới tính
* Chiều cao
* Cân nặng

---

# 5. Video API

## Upload Video

POST

```
/videos/upload
```

### Request

Multipart Form Data

```
video.mp4
exercise_type
```

### Response

```json
{
    "video_id": 15,
    "status": "uploaded"
}
```

---

## Danh sách Video

GET

```
/videos
```

---

## Xóa Video

DELETE

```
/videos/{video_id}
```

---

# 6. Analysis API

Đây là API quan trọng nhất của hệ thống.

---

## Phân tích Video

POST

```
/analysis
```

### Request

```json
{
    "video_id": 15
}
```

### Quy trình Backend

```
Receive Request

↓

Read Video

↓

Call AI Service

↓

Save Result

↓

Return Result
```

---

### Response

```json
{
    "analysis_id": 101,
    "status": "completed"
}
```

---

## Xem kết quả

GET

```
/analysis/{analysis_id}
```

### Response

```json
{
    "exercise": "Squat",
    "score": 88,
    "rep_count": 12,
    "errors": [
        "Knee Valgus",
        "Insufficient Squat Depth"
    ],
    "suggestions": [
        "Keep knees aligned with toes.",
        "Lower hips until thighs are parallel to the floor."
    ]
}
```

---

## Lịch sử phân tích

GET

```
/history
```

Trả về danh sách các lần phân tích của người dùng.

---

## Xóa lịch sử

DELETE

```
/history/{analysis_id}
```

---

# 7. AI Internal API

Các API này chỉ được Backend sử dụng để giao tiếp với AI Service.

Không công khai ra Internet.

---

## Phân tích Video

POST

```
/internal/analyze
```

### Request

```json
{
    "video_path": "/uploads/video_001.mp4"
}
```

### Response

```json
{
    "exercise": "Squat",
    "score": 88,
    "rep_count": 12,
    "errors": [
        "Knee Valgus"
    ],
    "suggestions": [
        "Keep knees aligned with toes."
    ]
}
```

---

# 8. HTTP Status Code

| Code | Ý nghĩa               |
| ---- | --------------------- |
| 200  | Success               |
| 201  | Created               |
| 400  | Bad Request           |
| 401  | Unauthorized          |
| 403  | Forbidden             |
| 404  | Not Found             |
| 422  | Validation Error      |
| 500  | Internal Server Error |

---

# 9. API Flow

## Đăng nhập

```
Flutter

↓

POST /auth/login

↓

Backend

↓

JWT

↓

Flutter
```

---

## Upload Video

```
Flutter

↓

POST /videos/upload

↓

Backend

↓

Save File

↓

Database

↓

Return video_id
```

---

## Phân tích Video

```
Flutter

↓

POST /analysis

↓

Backend

↓

AI Service

↓

MediaPipe

↓

ST-GCN

↓

Rule Engine

↓

JSON

↓

Backend

↓

Database

↓

Flutter
```

---

# 10. Chuẩn dữ liệu AI

Kết quả AI luôn trả về định dạng sau:

```json
{
    "exercise": "Squat",
    "score": 88,
    "rep_count": 12,
    "errors": [
        "Knee Valgus"
    ],
    "suggestions": [
        "Keep knees aligned with toes."
    ],
    "processing_time": 3.12
}
```

Điều này giúp Backend không phụ thuộc vào cách triển khai mô hình AI.

Nếu sau này thay ST-GCN bằng mô hình khác, Backend và Mobile vẫn hoạt động bình thường.

---

# 11. API Security

Hệ thống áp dụng các biện pháp bảo mật:

* JWT Authentication.
* BCrypt Hash Password.
* HTTPS.
* Kiểm tra định dạng tệp tải lên.
* Giới hạn dung lượng video.
* Chỉ chấp nhận định dạng MP4 và MOV.
* Chặn truy cập các API nội bộ.

---

# 12. Kết luận

Thiết kế API theo chuẩn RESTful giúp các thành phần Flutter, Backend và AI Service hoạt động độc lập nhưng vẫn giao tiếp thống nhất.

Việc chuẩn hóa Request và Response ngay từ đầu giúp giảm chi phí bảo trì, thuận lợi cho việc mở rộng thêm chức năng hoặc thay thế mô hình AI trong tương lai.
