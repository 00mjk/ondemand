class MotdFormatterMarkdownErb

  attr_reader :content, :title

  def initialize(motd_file)
    motd_file = MotdFile.new unless motd_file
    @title = motd_file.title
    file_content =
    	begin
    		ERB.new(motd_file.content).result
    	rescue
    		motd_file.content
    	end
    @content = OodAppkit.markdown.render(file_content)
  end

  def to_partial_path
    "dashboard/motd_markdown"
  end
end