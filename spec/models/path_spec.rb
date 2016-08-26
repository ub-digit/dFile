require "rails_helper"

RSpec.configure do |c|
  c.include ModelHelper
end

describe Path do
  before :each do
    @test_path = Rails.root.to_s + "/tmp/testdata/"
    initiate_test_environment(@test_path)
  end
  it "should have path after init" do
    path = Path.new("TEST:123")
    expect(path).to be_a Path
  end

  it "should raise error if path is outside root" do
    expect { Path.new("TEST:../../123") }.to raise_error(StandardError)
  end

  it "should raise error if path is same as root" do
    expect { Path.new("TEST:/") }.to raise_error(StandardError)
  end

  it "should work without prefix" do
    path = Path.new(@test_path)
    expect(path.to_s == @test_path).to be true
  end
  it "should return list of files" do
    create_folder_with_files(@test_path + "testfolder")
    path = Path.new(@test_path + "testfolder")
    expect(path.files(file_type: 'txt').size).to be 5
  end

  context "sorting" do
    it "should sort numeric files regardless of leading zeroes or not" do
      filelist = ["3.ext", "04.ext", "001.ext", "10.ext", "00002.ext"].map { |x| Pathname.new(x) }
      
      sorted_list = Path.new(".").sort_files(filelist).to_a
      
      expect(sorted_list[0].to_s).to eq("001.ext")
      expect(sorted_list[1].to_s).to eq("00002.ext")
      expect(sorted_list[2].to_s).to eq("3.ext")
      expect(sorted_list[3].to_s).to eq("04.ext")
      expect(sorted_list[4].to_s).to eq("10.ext")
    end

    it "should sort files with leading digit as if they were numeric" do
      filelist = ["3.ext", "04.ext", "001.ext", "10.ext", "00002.ext", "3thisisnotanumber.ext"].map { |x| Pathname.new(x) }
      
      sorted_list = Path.new(".").sort_files(filelist).to_a
      
      expect(sorted_list[0].to_s).to eq("001.ext")
      expect(sorted_list[1].to_s).to eq("00002.ext")
      expect(sorted_list[2].to_s).to eq("3.ext")
      expect(sorted_list[3].to_s).to eq("3thisisnotanumber.ext")
      expect(sorted_list[4].to_s).to eq("04.ext")
      expect(sorted_list[5].to_s).to eq("10.ext")
    end

    it "should sort non-numeric files after numeric files" do
      filelist = ["3.ext", "04.ext", "001.ext", "thisisnotnumeric.ext", "10.ext", "00002.ext", "3thisisnotanumber.ext"].map { |x| Pathname.new(x) }
      
      sorted_list = Path.new(".").sort_files(filelist).to_a
      
      expect(sorted_list[0].to_s).to eq("001.ext")
      expect(sorted_list[1].to_s).to eq("00002.ext")
      expect(sorted_list[2].to_s).to eq("3.ext")
      expect(sorted_list[3].to_s).to eq("3thisisnotanumber.ext")
      expect(sorted_list[4].to_s).to eq("04.ext")
      expect(sorted_list[5].to_s).to eq("10.ext")
      expect(sorted_list[6].to_s).to eq("thisisnotnumeric.ext")
    end

    it "should sort non-numeric files with numeric subparts in numerical subpart order" do
      filelist = ["3.ext", "04.ext", "001.ext", "thisisnotnumeric.ext", "not_4_003.ext", "not_4_001.ext", "not_3.ext", "not_001.ext", "10.ext", "00002.ext", "3thisisnotanumber.ext"].map { |x| Pathname.new(x) }
      
      sorted_list = Path.new(".").sort_files(filelist).to_a
      
      expect(sorted_list[0].to_s).to eq("001.ext")
      expect(sorted_list[1].to_s).to eq("00002.ext")
      expect(sorted_list[2].to_s).to eq("3.ext")
      expect(sorted_list[3].to_s).to eq("3thisisnotanumber.ext")
      expect(sorted_list[4].to_s).to eq("04.ext")
      expect(sorted_list[5].to_s).to eq("10.ext")
      expect(sorted_list[6].to_s).to eq("not_001.ext")
      expect(sorted_list[7].to_s).to eq("not_3.ext")
      expect(sorted_list[8].to_s).to eq("not_4_001.ext")
      expect(sorted_list[9].to_s).to eq("not_4_003.ext")
      expect(sorted_list[10].to_s).to eq("thisisnotnumeric.ext")
    end
  end
end
