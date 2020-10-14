require 'test_helper'

class MotdTest < ActiveSupport::TestCase
  test "test when motd_formatter_plaintext_erb_valid" do
    path = "#{Rails.root}/test/fixtures/files/motd_valid"
    motd_file = MotdFile.new(path)
    formatted_motd = MotdFormatterPlaintextErb.new(motd_file)
    expected_file = File.open(path).read

    assert_equal expected_file, formatted_motd.content
  end

  test "test when motd_formatter_plaintext_erb_empty" do
    path = "#{Rails.root}/test/fixtures/files/motd_empty"
    motd_file = MotdFile.new(path)
    formatted_motd = MotdFormatterPlaintextErb.new(motd_file)

    assert_equal '', formatted_motd.content
  end

  test "test when motd_formatter_plaintext_erb_throws_exception" do
    path = "#{Rails.root}/test/fixtures/files/motd_erb_exception"
    motd_file = MotdFile.new(path)
    msg = "ERB Has Failed To Parse The File"
    exception = assert_raises(Exception) {
      MotdFormatterPlaintextErb.new(motd_file)
    }

    assert_equal msg, exception.message
  end

  test "test when motd_formatter_plaintext_erb_renders_erb" do
    path = "#{Rails.root}/test/fixtures/files/motd_valid_erb"
    motd_file = MotdFile.new(path)
    formatted_motd = MotdFormatterPlaintextErb.new(motd_file)
    expected_file = "\nWelcome to the Ohio Supercomputer Center!\n"
    
    assert_equal expected_file, formatted_motd.content
  end
  
  test "test when motd_formatter_plaintext_erb_missing" do
    path = "#{Rails.root}/test/fixtures/files/motd_missing"
    motd_file = MotdFile.new(path)
    formatted_motd = MotdFormatterPlaintextErb.new(motd_file)

    assert_equal '', formatted_motd.content
  end

  test "test when motd_formatter_plaintext_erb_nil" do
    motd_file = nil
    formatted_motd = MotdFormatterPlaintextErb.new(motd_file)

    assert_not_nil formatted_motd.content
  end
end

