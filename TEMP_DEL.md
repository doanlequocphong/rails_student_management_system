
- Mục tiêu :
    + Nâng cao kỹ năng phát triển backend với Ruby on Rails ở mức production level.
    + Hiểu rõ hơn về architecture và maintainability của hệ thống Rails.
    + Cải thiện hiệu năng và chất lượng code của ứng dụng Rails.

- Cách tiếp cận :
    + Refactor và mở rộng project Student Management System để áp dụng các best practices trong Rails development.
    + Tìm hiểu thêm về Rails architecture, service layer và design pattern trong Rails.
    + Nghiên cứu các kỹ thuật tối ưu database query và performance trong Rails.

- Kết quả đạt được :
    + Áp dụng Service Object Pattern để tách business logic khỏi controller và model.
    + Hiểu và xử lý các vấn đề về N+1 query và database optimization.
    + Áp dụng background job (Sidekiq / ActiveJob) cho các tác vụ xử lý bất đồng bộ.
    + Cải thiện cấu trúc project để code dễ maintain và dễ mở rộng hơn.

- Point:
    + 1PT: Hiểu và áp dụng các design pattern phổ biến trong Rails như Service Object.
               Refactor code trong project Rails để tách rõ controller – business logic – data layer.
    + 2PT: Tối ưu database query và xử lý các vấn đề N+1 query.
               Áp dụng caching hoặc background job trong Rails application.
    + 3PT: Xây dựng hoặc refactor một module Rails theo production architecture với:
               . Service layer
               . Background job
               . Optimized database query
               . Maintainable structure


File đã được lưu tại .claude/reports/rails-refactor-analysis.md. Đây là tóm tắt phân tích:

📊 PROJECT ANALYSIS — Tóm tắt
Vấn đề Critical (Fix ngay)
#	Vấn đề	Nơi xảy ra
🔴	Dual grading system — enrollments.grade (0–10) và grades table (0–100) tồn tại song song	enrollments_controller.rb + grades_controller.rb
🔴	N+1 query — student.classroom.name trong view loop không có includes	students/index.html.erb
🔴	Missing DB indexes — students.email không có unique index; grades không có composite unique index	db/schema.rb
🟡	Fat Student model (146 lines) — GPA, academic standing, earned credits đều ở model	app/models/student.rb
🟡	Business logic trong view — transcript.html.erb (173 lines) tính avg, tạo Grade.new chỉ để gọi helper	app/views/students/transcript.html.erb
Architecture Gaps
app/services/ — không tồn tại
app/queries/ — không tồn tại
app/jobs/ — có nhưng trống (chỉ có stub)
API dùng manual JSON helpers thay vì Jbuilder/serializer
📋 Task List mới (13 tasks)
Task	Tiêu đề	Points
task-31	Fix N+1 + Add Missing DB Indexes	2PT
task-32	Resolve Dual Grading System	3PT
task-33	GpaCalculatorService	1PT
task-34	EnrollmentService	1PT
task-35	ClassroomAssignmentService	1PT
task-36	Query Object Pattern	2PT
task-37	StudentTranscriptPresenter	1PT
task-38	API Serialization (Jbuilder)	1PT
task-39	Pagy Pagination	2PT
task-40	Sidekiq + GpaCalculationJob	3PT
task-41	Email Notification Job	3PT
task-42	User–Student FK Association	2PT
task-43	API Caching + Rate Limiting	3PT
Tổng: 25 points

Thứ tự ưu tiên đề xuất:
task-31 → Fix N+1 ngay (nhanh, impact cao)
task-32 → Giải quyết dual grading (prerequisite cho task-33, 34)
task-33 → GpaCalculatorService (core refactor)
task-35 → ClassroomAssignmentService
Tiếp theo tùy mục tiêu học tập
Bạn muốn bắt đầu với task nào?

################

Đã tạo xong 13 task file mới. Tóm tắt:

Task files đã tạo (task-31 → task-43):

Task	File	Nội dung
task-31	task-31-fix-n1-query-db-indexes.md	Fix N+1 query + thêm DB indexes (Bullet gem)
task-32	task-32-resolve-dual-grading-system.md	Gộp 2 grading system thành 1 (grades table)
task-33	task-33-service-object-gpa-calculator.md	GpaCalculatorService (SQL aggregation)
task-34	task-34-service-object-enrollment.md	EnrollmentService (enroll/cancel)
task-35	task-35-service-object-classroom-assignment.md	ClassroomAssignmentService
task-36	task-36-query-object-pattern.md	StudentQuery + TranscriptQuery + DashboardQuery
task-37	task-37-presenter-student-transcript.md	StudentTranscriptPresenter
task-38	task-38-api-jbuilder-serialization.md	Jbuilder views thay thế manual JSON
task-39	task-39-pagination-pagy.md	Pagy pagination (web + API)
task-40	task-40-background-job-gpa-calculation.md	GpaCalculationJob + Sidekiq setup
task-41	task-41-email-notification-report-job.md	ActionMailer + NotificationJob
task-42	task-42-user-student-association.md	user_id FK trên students table
task-43	task-43-api-caching-rate-limiting.md	ETag caching + Rack::Attack rate limiting
Lưu ý: File task-31-production-deployment.md (stub cũ) vẫn còn tồn tại song song với task-31-fix-n1-query-db-indexes.md. Bạn có muốn xóa file stub cũ không?

