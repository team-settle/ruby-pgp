module TempHelper
  def setup_temp_file(contents='')
    stub = create_temp_file_stub(contents)
    allow(Tempfile).to receive(:open).and_yield(stub)
    stub
  end

  def create_temp_file_stub(contents='')
    stub = double
    allow(stub).to receive(:path).and_return(random_string)
    allow(stub).to receive(:write).with(contents)
    allow(stub).to receive(:read).and_return(contents)
    allow(stub).to receive(:rewind)
    stub
  end

  def random_string(length=20)
    (0...length).map { (65 + rand(26)).chr }.join
  end

  def setup_temp_paths(paths)
    allow(GPG::TempPathHelper).to receive(:create) do |&block|
      p = paths.pop
      block.call(p)
      p
    end
  end
end