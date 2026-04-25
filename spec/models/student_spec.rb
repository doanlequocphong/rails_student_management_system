require "rails_helper"

RSpec.describe Student, type: :model do

  # ── Validations ───────────────────────────────────────────────────
  describe "Validations" do
    it "valid với đầy đủ thông tin hợp lệ" do
      student = build(:student)
      expect(student).to be_valid
    end

    it "invalid khi không có name" do
      student = build(:student, name: "")
      expect(student).not_to be_valid
      expect(student.errors[:name]).to be_present
    end

    it "invalid khi name quá ngắn (< 2 ký tự)" do
      student = build(:student, name: "A")
      expect(student).not_to be_valid
    end

    it "invalid khi email không đúng định dạng" do
      student = build(:student, email: "not-an-email")
      expect(student).not_to be_valid
      expect(student.errors[:email]).to include("không đúng định dạng email")
    end

    it "invalid khi email trùng lặp" do
      create(:student, email: "test@example.com")
      student = build(:student, email: "test@example.com")
      expect(student).not_to be_valid
    end

    it "invalid khi tuổi < 16" do
      student = build(:student, date_of_birth: 10.years.ago.to_date)
      expect(student).not_to be_valid
      expect(student.errors[:date_of_birth]).to include(a_string_matching("phải đủ 16 tuổi"))
    end

    it "valid khi date_of_birth là nil (không bắt buộc)" do
      student = build(:student, date_of_birth: nil)
      expect(student).to be_valid
    end
  end

  # ── Normalization ────────────────────────────────────────────────
  describe "Normalization" do
    it "tự động downcase email" do
      student = create(:student, email: "UPPER@EXAMPLE.COM")
      expect(student.email).to eq("upper@example.com")
    end

    it "tự động strip khoảng trắng email" do
      student = create(:student, email: "  space@example.com  ")
      expect(student.email).to eq("space@example.com")
    end

    it "tự động squeeze khoảng trắng trong name" do
      student = create(:student, name: "Nguyễn  Văn   A")
      expect(student.name).to eq("Nguyễn Văn A")
    end
  end

  # ── GPA Methods (đã chuyển sang GpaCalculatorService) ──────────
  # Chi tiết tests: spec/services/gpa_calculator_service_spec.rb
  describe "#gpa_calculator" do
    let(:student) { create(:student) }

    it "trả về GpaCalculatorService instance" do
      expect(student.gpa_calculator).to be_a(GpaCalculatorService)
    end

    it "cache kết quả (memoization)" do
      calc1 = student.gpa_calculator
      calc2 = student.gpa_calculator
      expect(calc1).to equal(calc2)
    end
  end
end
