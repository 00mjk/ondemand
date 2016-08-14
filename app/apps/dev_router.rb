class DevRouter
  attr_reader :name, :owner

  def initialize(name, owner=OodSupport::Process.user.name)
    @name = name
    @owner = owner
  end

  def base_path
    Pathname.new "#{Dir.home(owner)}/#{ENV['OOD_PORTAL']}/dev"
  end

  def type
    :dev
  end

  def url
    "/pun/dev/#{name}"
  end

  def path
    @path ||= base_path.join(name)
  end
end
