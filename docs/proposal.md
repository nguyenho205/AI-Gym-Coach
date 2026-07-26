# AI Gym Coach

## 1. Giới thiệu đề tài

AI Gym Coach là hệ thống hỗ trợ người tập Gym phân tích kỹ thuật thực hiện động tác thông qua video bằng công nghệ Deep Learning và Computer Vision. Hệ thống cho phép người dùng tải lên video tập luyện, tự động nhận diện tư thế cơ thể, đánh giá chất lượng động tác, phát hiện các lỗi kỹ thuật và đưa ra gợi ý cải thiện.

Khác với các ứng dụng chỉ nhận diện tên bài tập hoặc đếm số lần thực hiện, AI Gym Coach tập trung vào việc đánh giá chất lượng động tác (Action Quality Assessment), giúp người dùng hiểu được mình đang tập đúng hay sai và cần điều chỉnh ở đâu để đạt hiệu quả cao hơn cũng như hạn chế nguy cơ chấn thương.

Phiên bản đầu tiên của hệ thống hướng tới ba bài tập phổ biến gồm Squat, Push-up và Bicep Curl, tạo nền tảng để mở rộng sang các bài tập khác trong tương lai.

---

## 2. Lý do chọn đề tài

Hiện nay, nhu cầu tập luyện thể thao và Gym ngày càng tăng. Tuy nhiên, đa số người tập tự học thông qua các nền tảng như YouTube, TikTok hoặc Facebook mà không có huấn luyện viên theo dõi trực tiếp. Điều này dẫn đến việc thực hiện sai kỹ thuật trong thời gian dài mà người tập không nhận ra.

Việc tập sai kỹ thuật không chỉ làm giảm hiệu quả phát triển cơ bắp mà còn làm tăng nguy cơ chấn thương ở đầu gối, cột sống, vai và các khớp khác.

Trong khi đó, sự phát triển của Computer Vision và Deep Learning đã tạo điều kiện để máy tính có thể nhận biết tư thế cơ thể con người thông qua video. Việc kết hợp các công nghệ này với thiết bị di động giúp xây dựng một hệ thống có khả năng hỗ trợ người tập kiểm tra kỹ thuật mọi lúc, mọi nơi mà không cần sự có mặt của huấn luyện viên.

Vì những lý do trên, nhóm lựa chọn xây dựng đề tài "AI Gym Coach - Hệ thống phân tích kỹ thuật tập Gym bằng Deep Learning".

---

## 3. Bài toán

Bài toán đặt ra là xây dựng một hệ thống có khả năng đánh giá chất lượng thực hiện động tác Gym dựa trên video do người dùng cung cấp.

Hệ thống tiếp nhận video tập luyện, sử dụng mô hình MediaPipe Pose để trích xuất các điểm khớp trên cơ thể theo từng khung hình. Chuỗi landmark sau đó được chuẩn hóa và đưa vào mô hình ST-GCN nhằm phân tích chuyển động theo không gian và thời gian.

Kết quả từ mô hình AI sẽ được kết hợp với các luật đánh giá dựa trên góc khớp và biên độ chuyển động để đưa ra điểm số kỹ thuật, xác định các lỗi thường gặp và sinh phản hồi giúp người dùng cải thiện động tác.

Đầu vào của hệ thống là video tập luyện của người dùng.

Đầu ra của hệ thống bao gồm:

- Tên bài tập.
- Số lần thực hiện (Rep).
- Điểm kỹ thuật.
- Danh sách lỗi kỹ thuật.
- Gợi ý cải thiện động tác.

---

## 4. Mục tiêu

Đề tài hướng tới việc xây dựng một hệ thống hoàn chỉnh có khả năng:

- Cho phép người dùng đăng nhập và quản lý tài khoản.
- Tải video tập luyện từ thiết bị di động lên hệ thống.
- Nhận diện bài tập từ video.
- Đếm số lần thực hiện động tác.
- Phân tích chất lượng động tác bằng mô hình ST-GCN.
- Phát hiện các lỗi kỹ thuật phổ biến.
- Chấm điểm kỹ thuật cho từng video.
- Đưa ra phản hồi giúp người dùng cải thiện động tác.
- Lưu lịch sử các lần phân tích để người dùng theo dõi tiến bộ.

---

## 5. Phạm vi đề tài

Phiên bản đầu tiên của hệ thống chỉ hỗ trợ ba bài tập:

- Back Squat
- Barbel Row
- Overhead Press

Các giới hạn của hệ thống:

- Chỉ xử lý video đã quay sẵn.
- Mỗi video chỉ chứa một người tập.
- Video có thời lượng tối đa 60 giây.
- Chưa hỗ trợ phân tích thời gian thực.
- Chưa hỗ trợ nhiều người trong cùng một video.
- Chưa hỗ trợ xây dựng giáo án tập luyện tự động.

---

## 6. Công nghệ sử dụng

### Mobile

- Flutter

### Backend

- FastAPI

### Database

- PostgreSQL

### AI

- MediaPipe Pose Landmarker
- ST-GCN
- OpenCV

### Công cụ phát triển

- Python
- VS Code
- Android Studio
- Git
- GitHub

---

## 7. Kiến trúc tổng quan

Hệ thống được chia thành bốn thành phần chính:

- Ứng dụng Flutter trên thiết bị di động.
- Backend xây dựng bằng FastAPI.
- Hệ thống AI thực hiện phân tích video.
- Cơ sở dữ liệu PostgreSQL lưu trữ thông tin.

Quy trình xử lý của hệ thống như sau:

Người dùng tải video từ ứng dụng Flutter.

↓

Video được gửi tới Backend.

↓

Backend chuyển video cho AI Service.

↓

AI Service sử dụng MediaPipe Pose để trích xuất landmark.

↓

Chuỗi landmark được đưa vào mô hình ST-GCN để đánh giá chất lượng động tác.

↓

Rule-based Engine phân tích các góc khớp, biên độ và các lỗi kỹ thuật.

↓

Kết quả được lưu vào PostgreSQL.

↓

Backend trả kết quả về ứng dụng Flutter.

---

## 8. Kết quả mong đợi

Sau khi hoàn thành, hệ thống có khả năng:

- Phân tích video tập Gym của người dùng.
- Nhận diện bài tập đang thực hiện.
- Đếm số lần thực hiện động tác.
- Đánh giá kỹ thuật tập luyện.
- Chấm điểm chất lượng động tác.
- Phát hiện các lỗi phổ biến.
- Đưa ra hướng dẫn cải thiện.
- Lưu lịch sử phân tích để người dùng theo dõi quá trình luyện tập.

Đề tài kỳ vọng tạo ra một ứng dụng có tính ứng dụng thực tế, hỗ trợ người tập Gym tự đánh giá kỹ thuật tập luyện ngay trên thiết bị di động mà không cần huấn luyện viên theo dõi trực tiếp.