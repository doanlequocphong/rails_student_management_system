require "rails_helper"

RSpec.describe ClassroomAssignmentService, type: :service do
  let(:classroom) { create(:classroom) }
  let(:student)   { create(:student) }

  # ── #assign! ─────────────────────────────────────────────────────
  describe "#assign!" do
    subject(:service) do
      described_class.new(classroom: classroom, student: student).call.assign!
    end

    it "trả về success? = true" do
      expect(service.success?).to be true
    end

    it "gán classroom cho student trong database" do
      service
      expect(student.reload.classroom).to eq(classroom)
    end

    it "error là nil" do
      expect(service.error).to be_nil
    end
  end

  # ── #remove! ─────────────────────────────────────────────────────
  describe "#remove!" do
    before { student.update!(classroom: classroom) }

    subject(:service) do
      described_class.new(classroom: classroom, student: student).call.remove!
    end

    it "trả về success? = true" do
      expect(service.success?).to be true
    end

    it "xóa classroom khỏi student (classroom = nil)" do
      service
      expect(student.reload.classroom).to be_nil
    end

    it "error là nil" do
      expect(service.error).to be_nil
    end
  end

  # ── #success? / #failure? ─────────────────────────────────────────
  describe "#success? và #failure?" do
    it "failure? là true khi chưa gọi assign! hay remove!" do
      service = described_class.new(classroom: classroom, student: student).call
      expect(service.failure?).to be true
      expect(service.success?).to be false
    end

    it "success? là true sau assign! thành công" do
      service = described_class.new(classroom: classroom, student: student).call.assign!
      expect(service.success?).to be true
      expect(service.failure?).to be false
    end
  end

  # ── Class method .call ────────────────────────────────────────────
  describe ".call (ApplicationService class method)" do
    it "tương đương new(...).call" do
      result = described_class.call(classroom: classroom, student: student)
      expect(result).to be_a(ClassroomAssignmentService)
    end
  end
end
