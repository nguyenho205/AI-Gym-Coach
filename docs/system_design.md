# AI Gym Coach

# System Design Document

**Version:** 1.0
**Project:** AI Gym Coach
**Document Type:** System Design Specification (SDS)

---

# MỤC LỤC

1. Giới thiệu
2. Mục tiêu thiết kế
3. Kiến trúc tổng thể
4. Kiến trúc các module
5. Luồng xử lý hệ thống
6. Thiết kế AI Pipeline
7. Thiết kế cơ sở dữ liệu
8. Thiết kế API
9. Thiết kế Mobile
10. Thiết kế Backend
11. Thiết kế AI Service
12. Thiết kế bảo mật
13. Khả năng mở rộng
14. Deployment Diagram
15. Các quyết định kiến trúc

---

# 1. Giới thiệu

Tài liệu này mô tả toàn bộ kiến trúc và thiết kế của hệ thống **AI Gym Coach**.

Hệ thống được xây dựng nhằm hỗ trợ người tập Gym tự đánh giá kỹ thuật tập luyện thông qua video bằng Computer Vision và Deep Learning. Người dùng chỉ cần tải video tập luyện lên ứng dụng, hệ thống sẽ tự động phân tích chuyển động, đánh giá kỹ thuật và đưa ra phản hồi giúp cải thiện động tác.

Tài liệu là cơ sở để các thành phần AI, Backend và Mobile được phát triển đồng bộ.

---

# 2. Mục tiêu thiết kế

Kiến trúc hệ thống được xây dựng theo các mục tiêu sau:

* Phân tách rõ Mobile, Backend và AI.
* Dễ mở rộng thêm bài tập mới.
* Dễ thay thế mô hình AI.
* Hỗ trợ triển khai trên Cloud.
* Dễ bảo trì.
* Đảm bảo hiệu năng khi xử lý video.
* Dễ tích hợp với Flutter.

---

# 3. Kiến trúc tổng thể

## 3.1 Kiến trúc hệ thống

```
                    +-----------------------+
                    |    Flutter Mobile     |
                    +-----------+-----------+
                                |
                          HTTPS REST API
                                |
                                ▼
                  +-----------------------------+
                  |      FastAPI Backend        |
                  +-------------+---------------+
                                |
          +---------------------+----------------------+
          |                                            |
          ▼                                            ▼
+-------------------------+              +---------------------------+
|       AI Service        |              |       PostgreSQL          |
|-------------------------|              |---------------------------|
| OpenCV                  |              | User                      |
| MediaPipe Pose          |              | Exercise                  |
| ST-GCN                  |              | Video                     |
| Rule-based Engine       |              | Analysis                  |
+-------------------------+              +---------------------------+
```

Kiến trúc được thiết kế theo mô hình **Client – Server – AI Service**, trong đó AI Service được tách riêng để có thể nâng cấp hoặc thay đổi mô hình mà không ảnh hưởng đến Backend và Mobile.

---

## 3.2 Các tầng của hệ thống

### Presentation Layer

Bao gồm Flutter.

Nhiệm vụ:

* Hiển thị giao diện.
* Upload video.
* Hiển thị kết quả.
* Quản lý lịch sử.

---

### Business Layer

Bao gồm FastAPI.

Nhiệm vụ:

* Authentication.
* Quản lý video.
* Gọi AI.
* Quản lý Database.

---

### AI Layer

Bao gồm:

* OpenCV
* MediaPipe Pose
* ST-GCN
* Rule-based Engine

---

### Data Layer

Bao gồm PostgreSQL.

Lưu:

* User
* Video
* Exercise
* Analysis
* Feedback

---

# 4. Kiến trúc các Module

## 4.1 Mobile Module

### Chức năng

* Đăng nhập
* Đăng ký
* Trang chủ
* Upload Video
* Lịch sử
* Chi tiết kết quả
* Hồ sơ

### Không thực hiện

* AI
* Xử lý video
* Tính toán kỹ thuật

---

## 4.2 Backend Module

Các thành phần

```
Backend

├── Authentication

├── Upload Manager

├── Analysis Manager

├── History Manager

├── User Manager

└── AI Gateway
```

Backend đóng vai trò điều phối toàn bộ hệ thống.

---

## 4.3 AI Module

AI Module được chia thành 6 thành phần.

```
Video

↓

Frame Extraction

↓

Pose Estimation

↓

Feature Engineering

↓

ST-GCN

↓

Rule Engine
```

---

## 4.4 Database Module

Lưu trữ:

* User
* Video
* Exercise
* Analysis Result
* Feedback

---

# 5. Luồng xử lý hệ thống

## Bước 1

Người dùng đăng nhập.

↓

## Bước 2

Chọn bài tập.

↓

## Bước 3

Upload video.

↓

## Bước 4

Backend lưu video.

↓

## Bước 5

Backend gửi video tới AI Service.

↓

## Bước 6

OpenCV đọc video.

↓

## Bước 7

MediaPipe trích xuất 33 landmark.

↓

## Bước 8

Landmark được chuẩn hóa.

↓

## Bước 9

ST-GCN đánh giá chất lượng động tác.

↓

## Bước 10

Rule Engine phân tích lỗi kỹ thuật.

↓

## Bước 11

Sinh kết quả.

↓

## Bước 12

Lưu Database.

↓

## Bước 13

Trả JSON về Mobile.

---

# 6. Thiết kế AI Pipeline

## 6.1 Tổng quan

```
Video

↓

OpenCV

↓

Frame Extraction

↓

MediaPipe Pose

↓

33 Landmark

↓

Normalize Landmark

↓

Feature Engineering

↓

ST-GCN

↓

Technique Evaluation

↓

Rule-based Feedback

↓

JSON
```

---

## 6.2 Frame Extraction

Video được chuyển thành chuỗi Frame.

FPS được chuẩn hóa để đảm bảo số lượng Frame ổn định.

---

## 6.3 Pose Estimation

MediaPipe Pose phát hiện:

* 33 Landmark
* Visibility
* 3D Coordinate

Output

```
Frame

↓

33 x (x,y,z)
```

---

## 6.4 Landmark Normalization

Chuẩn hóa:

* Scale
* Center
* Rotation

Mục đích:

Giảm ảnh hưởng của

* Khoảng cách camera
* Chiều cao
* Góc quay

---

## 6.5 Feature Engineering

Tính:

* Joint Angle
* Velocity
* Acceleration
* ROM
* Rep Phase

Các Feature này được dùng cho:

* Rule Engine
* Visualization

ST-GCN vẫn sử dụng trực tiếp chuỗi landmark làm đầu vào chính.

---

## 6.6 ST-GCN

ST-GCN học:

* Quan hệ giữa các khớp.
* Chuyển động theo thời gian.

Input

```
Landmark Sequence
```

Output

* Technique Score
* Motion Feature

---

## 6.7 Rule-based Feedback

Rule Engine kiểm tra:

Back Squat

* Knee Valgus
* Knee Too Forward
* Heel Lift
* Rounded Back
* Squat Depth


Barbell Row


* Rounded Back
* Neck Position
* Elbow Path
* Hip Hinge
*Bar Path


Overhead Press


* Elbow Flare
* Lockout
* Bar Path
* Lean Back
* Wrist Position


Output

* Error List
* Suggestion

---

# 7. Thiết kế Cơ sở dữ liệu

## Các bảng chính

### Users

* UserID
* FullName
* Email
* PasswordHash
* Avatar
* CreatedAt

---

### Videos

* VideoID
* UserID
* FilePath
* ExerciseType
* UploadTime

---

### Analysis

* AnalysisID
* VideoID
* Score
* RepCount
* Feedback
* ProcessingTime

---

### Exercises

* ExerciseID
* ExerciseName
* Description

---

## Quan hệ

```
User

1

↓

N

Video

1

↓

1

Analysis

Exercise

1

↓

N

Video
```

---

# 8. Thiết kế API

## Authentication

POST /auth/register

POST /auth/login

---

## User

GET /users/profile

PUT /users/profile

---

## Video

POST /videos/upload

GET /videos

DELETE /videos/{id}

---

## Analysis

POST /analysis

GET /analysis/{id}

GET /history

DELETE /history/{id}

---

# 9. Thiết kế Mobile

Các màn hình

```
Splash

↓

Login

↓

Register

↓

Home

↓

Upload

↓

Processing

↓

Result

↓

History

↓

Profile
```

---

## Result Screen

Hiển thị

* Score
* Rep
* Errors
* Suggestion
* Video Playback

---

# 10. Thiết kế Backend

Backend chia thành

```
API

↓

Service

↓

Repository

↓

Database
```

Service Layer chịu trách nhiệm:

* Upload
* AI Call
* Result Processing

Repository Layer thao tác Database.

---

# 11. Thiết kế AI Service

AI Service gồm

```
OpenCV

↓

MediaPipe

↓

Preprocessing

↓

ST-GCN

↓

Rule Engine

↓

Response Builder
```

Đầu ra

```
{
 score,
 exercise,
 rep,
 errors,
 suggestions
}
```

---

# 12. Thiết kế bảo mật

Áp dụng:

* JWT Authentication.
* HTTPS.
* Password Hash (BCrypt).
* Kiểm tra định dạng video.
* Giới hạn dung lượng upload.
* Phân quyền người dùng.

---

# 13. Khả năng mở rộng

Kiến trúc hiện tại cho phép:

* Thêm bài tập mới.
* Thay thế ST-GCN bằng mô hình khác.
* Chuyển AI Service sang GPU Server.
* Thêm Dashboard Web.
* Thêm Realtime Analysis.
* Thêm Personal Trainer AI.

Không cần thay đổi Mobile Architecture.

---

# 14. Deployment Diagram

```
Android / iOS

↓

Flutter

↓

Internet

↓

FastAPI Server

↓

PostgreSQL

↓

AI Server

    ├── OpenCV

    ├── MediaPipe

    ├── ST-GCN

    └── Rule Engine
```

Có thể triển khai Backend và AI trên cùng một máy chủ trong giai đoạn phát triển, sau đó tách thành hai dịch vụ độc lập khi cần mở rộng.

---

# 15. Các quyết định kiến trúc

Trong quá trình thiết kế, nhóm đã đưa ra các quyết định sau:

### 1. Chọn Flutter

Phát triển đa nền tảng Android và iOS bằng một mã nguồn duy nhất.

---

### 2. Chọn FastAPI

Hiệu năng cao, hỗ trợ bất đồng bộ, tích hợp tốt với Python và các thư viện AI.

---

### 3. Chọn PostgreSQL

Ổn định, hỗ trợ tốt dữ liệu quan hệ và dễ mở rộng.

---

### 4. Chọn MediaPipe Pose

Có khả năng trích xuất 33 điểm khớp theo thời gian thực với độ chính xác cao, phù hợp cho bài toán phân tích động tác.

---

### 5. Chọn ST-GCN

Mô hình được thiết kế chuyên biệt cho dữ liệu skeleton, tận dụng mối quan hệ không gian giữa các khớp và sự thay đổi theo thời gian để đánh giá chất lượng chuyển động. Đây là lựa chọn cân bằng giữa độ chính xác, tính hiện đại và khả năng triển khai trong phạm vi đồ án tốt nghiệp.

---

### 6. Chọn Rule-based Engine

Bổ sung khả năng giải thích kết quả bằng các quy tắc chuyên môn như góc khớp, biên độ chuyển động và tư thế, giúp người dùng hiểu rõ nguyên nhân và cách cải thiện thay vì chỉ nhận một điểm số.

---

# Kết luận

Kiến trúc của AI Gym Coach được xây dựng theo hướng module hóa, tách biệt giữa Mobile, Backend, AI Service và Database. Việc kết hợp MediaPipe Pose, ST-GCN và Rule-based Engine giúp hệ thống vừa tận dụng được khả năng học của mô hình Deep Learning, vừa cung cấp phản hồi dễ hiểu và có giá trị thực tiễn cho người tập Gym.

Thiết kế này đáp ứng yêu cầu của một đồ án tốt nghiệp với khả năng mở rộng, bảo trì và phát triển thành sản phẩm thực tế trong các phiên bản tiếp theo.
