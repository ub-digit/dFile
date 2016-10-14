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



    it "should sort non-numeric files with multiple numeric subparts in numerical subpart order" do
      filelist = ["1814474_0001_.tif",
                  "1814474_0002_.tif",
                  "1814474_0003_.tif",
                  "1814474_0004_.tif",
                  "1814474_0005_.tif",
                  "1814474_0006_.tif",
                  "1814474_0007_.tif",
                  "1814474_0008_.tif",
                  "1814474_0009_.tif",
                  "1814474_0010_.tif",
                  "1814474_0011_.tif",
                  "1814474_0012_.tif",
                  "1814474_0013_.tif",
                  "1814474_0014_4.tif",
                  "1814474_0015_5.tif",
                  "1814474_0016_6.tif",
                  "1814474_0017_7.tif",
                  "1814474_0018_8.tif",
                  "1814474_0019_9.tif",
                  "1814474_0020_10.tif",
                  "1814474_0021_11.tif",
                  "1814474_0022_12.tif",
                  "1814474_0023_13.tif",
                  "1814474_0024_14.tif",
                  "1814474_0025_15.tif",
                  "1814474_0026_16.tif",
                  "1814474_0027_17.tif",
                  "1814474_0028_18.tif",
                  "1814474_0029_19.tif",
                  "1814474_0030_20.tif",
                  "1814474_0031_21.tif",
                  "1814474_0032_22.tif",
                  "1814474_0033_23.tif",
                  "1814474_0034_24.tif",
                  "1814474_0035_25.tif",
                  "1814474_0036_26.tif",
                  "1814474_0037_27.tif",
                  "1814474_0038_28.tif",
                  "1814474_0039_29.tif",
                  "1814474_0040_30.tif",
                  "1814474_0041_31.tif",
                  "1814474_0042_32.tif",
                  "1814474_0043_33.tif",
                  "1814474_0044_34.tif",
                  "1814474_0045_35.tif",
                  "1814474_0046_36.tif",
                  "1814474_0047_37.tif",
                  "1814474_0048_38.tif",
                  "1814474_0049_39.tif",
                  "1814474_0050_40.tif",
                  "1814474_0051_41.tif",
                  "1814474_0052_42.tif",
                  "1814474_0053_43.tif",
                  "1814474_0054_44.tif",
                  "1814474_0055_45.tif",
                  "1814474_0056_46.tif",
                  "1814474_0057_47.tif",
                  "1814474_0058_48.tif",
                  "1814474_0059_49.tif",
                  "1814474_0060_50.tif",
                  "1814474_0061_51.tif",
                  "1814474_0062_52.tif",
                  "1814474_0063_53.tif",
                  "1814474_0064_54.tif",
                  "1814474_0065_55.tif",
                  "1814474_0066_56.tif",
                  "1814474_0067_57.tif",
                  "1814474_0068_58.tif",
                  "1814474_0069_59.tif",
                  "1814474_0070_60.tif",
                  "1814474_0071_61.tif",
                  "1814474_0072_62.tif",
                  "1814474_0073_63.tif",
                  "1814474_0074_64.tif",
                  "1814474_0075_65.tif",
                  "1814474_0076_66.tif",
                  "1814474_0077_67.tif",
                  "1814474_0078_68.tif",
                  "1814474_0079_69.tif",
                  "1814474_0080_70.tif",
                  "1814474_0081_71.tif",
                  "1814474_0082_72.tif",
                  "1814474_0083_73.tif",
                  "1814474_0084_74.tif",
                  "1814474_0085_75.tif",
                  "1814474_0086_76.tif",
                  "1814474_0087_.tif",
                  "1814474_0088_.tif",
                  "1814474_0089_.tif",
                  "1814474_0090_80.tif",
                  "1814474_0091_81.tif",
                  "1814474_0092_82.tif",
                  "1814474_0093_83.tif",
                  "1814474_0094_84.tif",
                  "1814474_0095_85.tif",
                  "1814474_0096_86.tif",
                  "1814474_0097_87.tif",
                  "1814474_0098_88.tif",
                  "1814474_0099_89.tif",
                  "1814474_0100_90.tif",
                  "1814474_0101_91.tif",
                  "1814474_0102_92.tif",
                  "1814474_0103_93.tif",
                  "1814474_0104_94.tif",
                  "1814474_0105_95.tif",
                  "1814474_0106_96.tif",
                  "1814474_0107_97.tif",
                  "1814474_0108_98.tif",
                  "1814474_0109_99.tif",
                  "1814474_0110_.tif",
                  "1814474_0111_.tif",
                  "1814474_0112_.tif",
                  "1814474_0113_.tif",
                  "1814474_0114_104.tif",
                  "1814474_0115_105.tif",
                  "1814474_0116_106.tif",
                  "1814474_0117_107.tif",
                  "1814474_0118_108.tif",
                  "1814474_0119_109.tif",
                  "1814474_0120_110.tif",
                  "1814474_0121_111.tif",
                  "1814474_0122_112.tif",
                  "1814474_0123_.tif",
                  "1814474_0124_.tif",
                  "1814474_0125_.tif",
                  "1814474_0126_116.tif",
                  "1814474_0127_117.tif",
                  "1814474_0128_118.tif",
                  "1814474_0129_119.tif",
                  "1814474_0130_120.tif",
                  "1814474_0131_121.tif",
                  "1814474_0132_122.tif",
                  "1814474_0133_123.tif",
                  "1814474_0134_124.tif",
                  "1814474_0135_125.tif",
                  "1814474_0136_126.tif",
                  "1814474_0137_.tif",
                  "1814474_0138_.tif",
                  "1814474_0139_.tif",
                  "1814474_0140_130.tif",
                  "1814474_0141_131.tif",
                  "1814474_0142_132.tif",
                  "1814474_0143_133.tif",
                  "1814474_0144_134.tif",
                  "1814474_0145_135.tif",
                  "1814474_0146_136.tif",
                  "1814474_0147_137.tif",
                  "1814474_0148_138.tif",
                  "1814474_0149_139.tif",
                  "1814474_0150_140.tif",
                  "1814474_0151_141.tif",
                  "1814474_0152_142.tif",
                  "1814474_0153_143.tif",
                  "1814474_0154_144.tif",
                  "1814474_0155_145.tif",
                  "1814474_0156_146.tif",
                  "1814474_0157_147.tif",
                  "1814474_0158_148.tif",
                  "1814474_0159_149.tif",
                  "1814474_0160_150.tif",
                  "1814474_0161_151.tif",
                  "1814474_0162_152.tif",
                  "1814474_0163_153.tif",
                  "1814474_0164_154.tif",
                  "1814474_0165_155.tif",
                  "1814474_0166_156.tif",
                  "1814474_0167_157.tif",
                  "1814474_0168_158.tif",
                  "1814474_0169_159.tif",
                  "1814474_0170_160.tif",
                  "1814474_0171_161.tif",
                  "1814474_0172_162.tif",
                  "1814474_0173_163.tif",
                  "1814474_0174_164.tif",
                  "1814474_0175_165.tif",
                  "1814474_0176_166.tif",
                  "1814474_0177_167.tif",
                  "1814474_0178_168.tif",
                  "1814474_0179_169.tif",
                  "1814474_0180_170.tif",
                  "1814474_0181_171.tif",
                  "1814474_0182_172.tif",
                  "1814474_0183_173.tif",
                  "1814474_0184_174.tif",
                  "1814474_0185_175.tif",
                  "1814474_0186_176.tif",
                  "1814474_0187_177.tif",
                  "1814474_0188_178.tif",
                  "1814474_0189_179.tif",
                  "1814474_0190_180.tif",
                  "1814474_0191_181.tif",
                  "1814474_0192_182.tif",
                  "1814474_0193_183.tif",
                  "1814474_0194_184.tif",
                  "1814474_0195_.tif",
                  "1814474_0196_.tif",
                  "1814474_0197_.tif",
                  "1814474_0198_.tif",
                  "1814474_0199_.tif",
                  "1814474_0200_.tif",
                  "1814474_0201_.tif",
                  "1814474_0202_.tif",
                  "1814474_0203_.tif",
                  "1814474_0204_.tif"].shuffle.map { |x| Pathname.new(x) }
      
      sorted_list = Path.new(".").sort_files(filelist).to_a
      
      expect(sorted_list[0].to_s).to eq("1814474_0001_.tif")
      expect(sorted_list[1].to_s).to eq("1814474_0002_.tif")
      expect(sorted_list[2].to_s).to eq("1814474_0003_.tif")
      expect(sorted_list[3].to_s).to eq("1814474_0004_.tif")
      expect(sorted_list[4].to_s).to eq("1814474_0005_.tif")
      expect(sorted_list[5].to_s).to eq("1814474_0006_.tif")
      expect(sorted_list[6].to_s).to eq("1814474_0007_.tif")
      expect(sorted_list[7].to_s).to eq("1814474_0008_.tif")
      expect(sorted_list[8].to_s).to eq("1814474_0009_.tif")
      expect(sorted_list[9].to_s).to eq("1814474_0010_.tif")
      expect(sorted_list[10].to_s).to eq("1814474_0011_.tif")
      expect(sorted_list[11].to_s).to eq("1814474_0012_.tif")
      expect(sorted_list[12].to_s).to eq("1814474_0013_.tif")
      expect(sorted_list[13].to_s).to eq("1814474_0014_4.tif")
      expect(sorted_list[14].to_s).to eq("1814474_0015_5.tif")
      expect(sorted_list[15].to_s).to eq("1814474_0016_6.tif")
      expect(sorted_list[16].to_s).to eq("1814474_0017_7.tif")
      expect(sorted_list[17].to_s).to eq("1814474_0018_8.tif")
      expect(sorted_list[18].to_s).to eq("1814474_0019_9.tif")
      expect(sorted_list[19].to_s).to eq("1814474_0020_10.tif")
      expect(sorted_list[20].to_s).to eq("1814474_0021_11.tif")
      expect(sorted_list[21].to_s).to eq("1814474_0022_12.tif")
      expect(sorted_list[22].to_s).to eq("1814474_0023_13.tif")
      expect(sorted_list[23].to_s).to eq("1814474_0024_14.tif")
      expect(sorted_list[24].to_s).to eq("1814474_0025_15.tif")
      expect(sorted_list[25].to_s).to eq("1814474_0026_16.tif")
      expect(sorted_list[26].to_s).to eq("1814474_0027_17.tif")
      expect(sorted_list[27].to_s).to eq("1814474_0028_18.tif")
      expect(sorted_list[28].to_s).to eq("1814474_0029_19.tif")
      expect(sorted_list[29].to_s).to eq("1814474_0030_20.tif")
      expect(sorted_list[30].to_s).to eq("1814474_0031_21.tif")
      expect(sorted_list[31].to_s).to eq("1814474_0032_22.tif")
      expect(sorted_list[32].to_s).to eq("1814474_0033_23.tif")
      expect(sorted_list[33].to_s).to eq("1814474_0034_24.tif")
      expect(sorted_list[34].to_s).to eq("1814474_0035_25.tif")
      expect(sorted_list[35].to_s).to eq("1814474_0036_26.tif")
      expect(sorted_list[36].to_s).to eq("1814474_0037_27.tif")
      expect(sorted_list[37].to_s).to eq("1814474_0038_28.tif")
      expect(sorted_list[38].to_s).to eq("1814474_0039_29.tif")
      expect(sorted_list[39].to_s).to eq("1814474_0040_30.tif")
      expect(sorted_list[40].to_s).to eq("1814474_0041_31.tif")
      expect(sorted_list[41].to_s).to eq("1814474_0042_32.tif")
      expect(sorted_list[42].to_s).to eq("1814474_0043_33.tif")
      expect(sorted_list[43].to_s).to eq("1814474_0044_34.tif")
      expect(sorted_list[44].to_s).to eq("1814474_0045_35.tif")
      expect(sorted_list[45].to_s).to eq("1814474_0046_36.tif")
      expect(sorted_list[46].to_s).to eq("1814474_0047_37.tif")
      expect(sorted_list[47].to_s).to eq("1814474_0048_38.tif")
      expect(sorted_list[48].to_s).to eq("1814474_0049_39.tif")
      expect(sorted_list[49].to_s).to eq("1814474_0050_40.tif")
      expect(sorted_list[50].to_s).to eq("1814474_0051_41.tif")
      expect(sorted_list[51].to_s).to eq("1814474_0052_42.tif")
      expect(sorted_list[52].to_s).to eq("1814474_0053_43.tif")
      expect(sorted_list[53].to_s).to eq("1814474_0054_44.tif")
      expect(sorted_list[54].to_s).to eq("1814474_0055_45.tif")
      expect(sorted_list[55].to_s).to eq("1814474_0056_46.tif")
      expect(sorted_list[56].to_s).to eq("1814474_0057_47.tif")
      expect(sorted_list[57].to_s).to eq("1814474_0058_48.tif")
      expect(sorted_list[58].to_s).to eq("1814474_0059_49.tif")
      expect(sorted_list[59].to_s).to eq("1814474_0060_50.tif")
      expect(sorted_list[60].to_s).to eq("1814474_0061_51.tif")
      expect(sorted_list[61].to_s).to eq("1814474_0062_52.tif")
      expect(sorted_list[62].to_s).to eq("1814474_0063_53.tif")
      expect(sorted_list[63].to_s).to eq("1814474_0064_54.tif")
      expect(sorted_list[64].to_s).to eq("1814474_0065_55.tif")
      expect(sorted_list[65].to_s).to eq("1814474_0066_56.tif")
      expect(sorted_list[66].to_s).to eq("1814474_0067_57.tif")
      expect(sorted_list[67].to_s).to eq("1814474_0068_58.tif")
      expect(sorted_list[68].to_s).to eq("1814474_0069_59.tif")
      expect(sorted_list[69].to_s).to eq("1814474_0070_60.tif")
      expect(sorted_list[70].to_s).to eq("1814474_0071_61.tif")
      expect(sorted_list[71].to_s).to eq("1814474_0072_62.tif")
      expect(sorted_list[72].to_s).to eq("1814474_0073_63.tif")
      expect(sorted_list[73].to_s).to eq("1814474_0074_64.tif")
      expect(sorted_list[74].to_s).to eq("1814474_0075_65.tif")
      expect(sorted_list[75].to_s).to eq("1814474_0076_66.tif")
      expect(sorted_list[76].to_s).to eq("1814474_0077_67.tif")
      expect(sorted_list[77].to_s).to eq("1814474_0078_68.tif")
      expect(sorted_list[78].to_s).to eq("1814474_0079_69.tif")
      expect(sorted_list[79].to_s).to eq("1814474_0080_70.tif")
      expect(sorted_list[80].to_s).to eq("1814474_0081_71.tif")
      expect(sorted_list[81].to_s).to eq("1814474_0082_72.tif")
      expect(sorted_list[82].to_s).to eq("1814474_0083_73.tif")
      expect(sorted_list[83].to_s).to eq("1814474_0084_74.tif")
      expect(sorted_list[84].to_s).to eq("1814474_0085_75.tif")
      expect(sorted_list[85].to_s).to eq("1814474_0086_76.tif")
      expect(sorted_list[86].to_s).to eq("1814474_0087_.tif")
      expect(sorted_list[87].to_s).to eq("1814474_0088_.tif")
      expect(sorted_list[88].to_s).to eq("1814474_0089_.tif")
      expect(sorted_list[89].to_s).to eq("1814474_0090_80.tif")
      expect(sorted_list[90].to_s).to eq("1814474_0091_81.tif")
      expect(sorted_list[91].to_s).to eq("1814474_0092_82.tif")
      expect(sorted_list[92].to_s).to eq("1814474_0093_83.tif")
      expect(sorted_list[93].to_s).to eq("1814474_0094_84.tif")
      expect(sorted_list[94].to_s).to eq("1814474_0095_85.tif")
      expect(sorted_list[95].to_s).to eq("1814474_0096_86.tif")
      expect(sorted_list[96].to_s).to eq("1814474_0097_87.tif")
      expect(sorted_list[97].to_s).to eq("1814474_0098_88.tif")
      expect(sorted_list[98].to_s).to eq("1814474_0099_89.tif")
      expect(sorted_list[99].to_s).to eq("1814474_0100_90.tif")
      expect(sorted_list[100].to_s).to eq("1814474_0101_91.tif")
      expect(sorted_list[101].to_s).to eq("1814474_0102_92.tif")
      expect(sorted_list[102].to_s).to eq("1814474_0103_93.tif")
      expect(sorted_list[103].to_s).to eq("1814474_0104_94.tif")
      expect(sorted_list[104].to_s).to eq("1814474_0105_95.tif")
      expect(sorted_list[105].to_s).to eq("1814474_0106_96.tif")
      expect(sorted_list[106].to_s).to eq("1814474_0107_97.tif")
      expect(sorted_list[107].to_s).to eq("1814474_0108_98.tif")
      expect(sorted_list[108].to_s).to eq("1814474_0109_99.tif")
      expect(sorted_list[109].to_s).to eq("1814474_0110_.tif")
      expect(sorted_list[110].to_s).to eq("1814474_0111_.tif")
      expect(sorted_list[111].to_s).to eq("1814474_0112_.tif")
      expect(sorted_list[112].to_s).to eq("1814474_0113_.tif")
      expect(sorted_list[113].to_s).to eq("1814474_0114_104.tif")
      expect(sorted_list[114].to_s).to eq("1814474_0115_105.tif")
      expect(sorted_list[115].to_s).to eq("1814474_0116_106.tif")
      expect(sorted_list[116].to_s).to eq("1814474_0117_107.tif")
      expect(sorted_list[117].to_s).to eq("1814474_0118_108.tif")
      expect(sorted_list[118].to_s).to eq("1814474_0119_109.tif")
      expect(sorted_list[119].to_s).to eq("1814474_0120_110.tif")
      expect(sorted_list[120].to_s).to eq("1814474_0121_111.tif")
      expect(sorted_list[121].to_s).to eq("1814474_0122_112.tif")
      expect(sorted_list[122].to_s).to eq("1814474_0123_.tif")
      expect(sorted_list[123].to_s).to eq("1814474_0124_.tif")
      expect(sorted_list[124].to_s).to eq("1814474_0125_.tif")
      expect(sorted_list[125].to_s).to eq("1814474_0126_116.tif")
      expect(sorted_list[126].to_s).to eq("1814474_0127_117.tif")
      expect(sorted_list[127].to_s).to eq("1814474_0128_118.tif")
      expect(sorted_list[128].to_s).to eq("1814474_0129_119.tif")
      expect(sorted_list[129].to_s).to eq("1814474_0130_120.tif")
      expect(sorted_list[130].to_s).to eq("1814474_0131_121.tif")
      expect(sorted_list[131].to_s).to eq("1814474_0132_122.tif")
      expect(sorted_list[132].to_s).to eq("1814474_0133_123.tif")
      expect(sorted_list[133].to_s).to eq("1814474_0134_124.tif")
      expect(sorted_list[134].to_s).to eq("1814474_0135_125.tif")
      expect(sorted_list[135].to_s).to eq("1814474_0136_126.tif")
      expect(sorted_list[136].to_s).to eq("1814474_0137_.tif")
      expect(sorted_list[137].to_s).to eq("1814474_0138_.tif")
      expect(sorted_list[138].to_s).to eq("1814474_0139_.tif")
      expect(sorted_list[139].to_s).to eq("1814474_0140_130.tif")
      expect(sorted_list[140].to_s).to eq("1814474_0141_131.tif")
      expect(sorted_list[141].to_s).to eq("1814474_0142_132.tif")
      expect(sorted_list[142].to_s).to eq("1814474_0143_133.tif")
      expect(sorted_list[143].to_s).to eq("1814474_0144_134.tif")
      expect(sorted_list[144].to_s).to eq("1814474_0145_135.tif")
      expect(sorted_list[145].to_s).to eq("1814474_0146_136.tif")
      expect(sorted_list[146].to_s).to eq("1814474_0147_137.tif")
      expect(sorted_list[147].to_s).to eq("1814474_0148_138.tif")
      expect(sorted_list[148].to_s).to eq("1814474_0149_139.tif")
      expect(sorted_list[149].to_s).to eq("1814474_0150_140.tif")
      expect(sorted_list[150].to_s).to eq("1814474_0151_141.tif")
      expect(sorted_list[151].to_s).to eq("1814474_0152_142.tif")
      expect(sorted_list[152].to_s).to eq("1814474_0153_143.tif")
      expect(sorted_list[153].to_s).to eq("1814474_0154_144.tif")
      expect(sorted_list[154].to_s).to eq("1814474_0155_145.tif")
      expect(sorted_list[155].to_s).to eq("1814474_0156_146.tif")
      expect(sorted_list[156].to_s).to eq("1814474_0157_147.tif")
      expect(sorted_list[157].to_s).to eq("1814474_0158_148.tif")
      expect(sorted_list[158].to_s).to eq("1814474_0159_149.tif")
      expect(sorted_list[159].to_s).to eq("1814474_0160_150.tif")
      expect(sorted_list[160].to_s).to eq("1814474_0161_151.tif")
      expect(sorted_list[161].to_s).to eq("1814474_0162_152.tif")
      expect(sorted_list[162].to_s).to eq("1814474_0163_153.tif")
      expect(sorted_list[163].to_s).to eq("1814474_0164_154.tif")
      expect(sorted_list[164].to_s).to eq("1814474_0165_155.tif")
      expect(sorted_list[165].to_s).to eq("1814474_0166_156.tif")
      expect(sorted_list[166].to_s).to eq("1814474_0167_157.tif")
      expect(sorted_list[167].to_s).to eq("1814474_0168_158.tif")
      expect(sorted_list[168].to_s).to eq("1814474_0169_159.tif")
      expect(sorted_list[169].to_s).to eq("1814474_0170_160.tif")
      expect(sorted_list[170].to_s).to eq("1814474_0171_161.tif")
      expect(sorted_list[171].to_s).to eq("1814474_0172_162.tif")
      expect(sorted_list[172].to_s).to eq("1814474_0173_163.tif")
      expect(sorted_list[173].to_s).to eq("1814474_0174_164.tif")
      expect(sorted_list[174].to_s).to eq("1814474_0175_165.tif")
      expect(sorted_list[175].to_s).to eq("1814474_0176_166.tif")
      expect(sorted_list[176].to_s).to eq("1814474_0177_167.tif")
      expect(sorted_list[177].to_s).to eq("1814474_0178_168.tif")
      expect(sorted_list[178].to_s).to eq("1814474_0179_169.tif")
      expect(sorted_list[179].to_s).to eq("1814474_0180_170.tif")
      expect(sorted_list[180].to_s).to eq("1814474_0181_171.tif")
      expect(sorted_list[181].to_s).to eq("1814474_0182_172.tif")
      expect(sorted_list[182].to_s).to eq("1814474_0183_173.tif")
      expect(sorted_list[183].to_s).to eq("1814474_0184_174.tif")
      expect(sorted_list[184].to_s).to eq("1814474_0185_175.tif")
      expect(sorted_list[185].to_s).to eq("1814474_0186_176.tif")
      expect(sorted_list[186].to_s).to eq("1814474_0187_177.tif")
      expect(sorted_list[187].to_s).to eq("1814474_0188_178.tif")
      expect(sorted_list[188].to_s).to eq("1814474_0189_179.tif")
      expect(sorted_list[189].to_s).to eq("1814474_0190_180.tif")
      expect(sorted_list[190].to_s).to eq("1814474_0191_181.tif")
      expect(sorted_list[191].to_s).to eq("1814474_0192_182.tif")
      expect(sorted_list[192].to_s).to eq("1814474_0193_183.tif")
      expect(sorted_list[193].to_s).to eq("1814474_0194_184.tif")
      expect(sorted_list[194].to_s).to eq("1814474_0195_.tif")
      expect(sorted_list[195].to_s).to eq("1814474_0196_.tif")
      expect(sorted_list[196].to_s).to eq("1814474_0197_.tif")
      expect(sorted_list[197].to_s).to eq("1814474_0198_.tif")
      expect(sorted_list[198].to_s).to eq("1814474_0199_.tif")
      expect(sorted_list[199].to_s).to eq("1814474_0200_.tif")
      expect(sorted_list[200].to_s).to eq("1814474_0201_.tif")
      expect(sorted_list[201].to_s).to eq("1814474_0202_.tif")
      expect(sorted_list[202].to_s).to eq("1814474_0203_.tif")
      expect(sorted_list[203].to_s).to eq("1814474_0204_.tif") 
    end

  end
end
