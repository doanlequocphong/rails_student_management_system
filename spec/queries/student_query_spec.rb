require "rails_helper"

RSpec.describe StudentQuery, type: :query do
  # ── #search ──────────────────────────────────────────────────────
  describe "#search" do
    it "lọc sinh viên theo tên" do
      student = create(:student, name: "Nguyen Van A")
      create(:student, name: "Tran Thi B")

      result = described_class.new.search("Nguyen").result
      expect(result).to include(student)
      expect(result.count).to eq(1)
    end

    it "lọc sinh viên theo email" do
      student = create(:student, email: "nguyen@example.com")
      create(:student, email: "tran@example.com")

      result = described_class.new.search("nguyen").result
      expect(result).to include(student)
    end

    it "không phân biệt hoa thường (ILIKE)" do
      student = create(:student, name: "Nguyen Van A")

      result = described_class.new.search("nguyen").result
      expect(result).to include(student)
    end

    it "trả về tất cả khi term là blank" do
      create_list(:student, 3)

      result = described_class.new.search("").result
      expect(result.count).to eq(3)
    end

    it "trả về self để chain" do
      query = described_class.new.search("term")
      expect(query).to be_a(StudentQuery)
    end
  end

  # ── #with_classroom ───────────────────────────────────────────────
  describe "#with_classroom" do
    it "eager loads classroom để tránh N+1" do
      create(:student, :with_classroom)
      result = described_class.new.with_classroom.result
      expect(result.first.association(:classroom)).to be_loaded
    end

    it "trả về self để chain" do
      query = described_class.new.with_classroom
      expect(query).to be_a(StudentQuery)
    end
  end

  # ── #recent ───────────────────────────────────────────────────────
  describe "#recent" do
    it "sắp xếp mới nhất lên đầu" do
      old_student = create(:student, created_at: 2.days.ago)
      new_student = create(:student, created_at: 1.hour.ago)

      result = described_class.new.recent.result
      expect(result.first).to eq(new_student)
      expect(result.last).to  eq(old_student)
    end
  end

  # ── Chaining ─────────────────────────────────────────────────────
  describe "method chaining" do
    it "có thể chain nhiều filters" do
      student = create(:student, name: "Nguyen Van A", :with_classroom)
      create(:student, name: "Tran Thi B", :with_classroom)

      result = described_class.new
                              .search("Nguyen")
                              .with_classroom
                              .recent
                              .result
      expect(result).to include(student)
      expect(result.count).to eq(1)
    end
  end

  # ── Custom scope ─────────────────────────────────────────────────
  describe "custom scope (policy_scope simulation)" do
    it "nhận scope ngoài thay vì Student.all" do
      classroom = create(:classroom)
      in_scope  = create(:student, classroom: classroom)
      out_scope = create(:student)

      scope  = Student.where(classroom: classroom)
      result = described_class.new(scope).result
      expect(result).to     include(in_scope)
      expect(result).not_to include(out_scope)
    end
  end
end
