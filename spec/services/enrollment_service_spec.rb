require "rails_helper"

RSpec.describe EnrollmentService, type: :service do
  let(:student)    { create(:student) }
  let(:course)     { create(:course) }

  # ── #enroll! ─────────────────────────────────────────────────────
  describe "#enroll!" do
    subject(:service) do
      described_class.new(student: student, course: course).call.enroll!
    end

    context "khi đăng ký hợp lệ (sinh viên chưa đăng ký môn này)" do
      it "trả về success? = true" do
        expect(service.success?).to be true
      end

      it "tạo enrollment trong database" do
        expect { service }.to change(Enrollment, :count).by(1)
      end

      it "enrollment được persist (saved)" do
        expect(service.enrollment).to be_persisted
      end

      it "enrollment thuộc đúng student và course" do
        expect(service.enrollment.student).to eq(student)
        expect(service.enrollment.course).to  eq(course)
      end

      it "gán ngày đăng ký là hôm nay" do
        expect(service.enrollment.enrolled_at).to eq(Date.current)
      end

      it "error là nil" do
        expect(service.error).to be_nil
      end
    end

    context "khi đăng ký trùng (sinh viên đã đăng ký môn này rồi)" do
      before { create(:enrollment, student: student, course: course) }

      it "trả về failure? = true" do
        expect(service.failure?).to be true
      end

      it "không tạo enrollment mới" do
        expect { service }.not_to change(Enrollment, :count)
      end

      it "error có nội dung thông báo lỗi" do
        expect(service.error).to be_present
        expect(service.error).to include("đã đăng ký")
      end
    end
  end

  # ── #cancel! ─────────────────────────────────────────────────────
  describe "#cancel!" do
    let!(:enrollment) { create(:enrollment, student: student, course: course) }

    subject(:service) do
      described_class.new(enrollment: enrollment).call.cancel!
    end

    it "trả về success? = true" do
      expect(service.success?).to be true
    end

    it "xóa enrollment khỏi database" do
      expect { service }.to change(Enrollment, :count).by(-1)
    end

    it "error là nil" do
      expect(service.error).to be_nil
    end
  end

  # ── #success? / #failure? ─────────────────────────────────────────
  describe "#success? và #failure?" do
    it "failure? là true khi chưa gọi enroll! hay cancel!" do
      service = described_class.new(student: student, course: course).call
      expect(service.failure?).to be true
      expect(service.success?).to be false
    end

    it "success? là true sau enroll! thành công" do
      service = described_class.new(student: student, course: course).call.enroll!
      expect(service.success?).to be true
      expect(service.failure?).to be false
    end
  end

  # ── attr_reader :enrollment ───────────────────────────────────────
  describe "#enrollment" do
    it "trả về nil trước khi gọi enroll!" do
      service = described_class.new(student: student, course: course).call
      expect(service.enrollment).to be_nil
    end

    it "trả về enrollment object sau enroll!" do
      service = described_class.new(student: student, course: course).call.enroll!
      expect(service.enrollment).to be_a(Enrollment)
    end
  end

  # ── Class method .call ────────────────────────────────────────────
  describe ".call (ApplicationService class method)" do
    it "tương đương new(...).call" do
      result = described_class.call(student: student, course: course)
      expect(result).to be_a(EnrollmentService)
    end
  end
end
