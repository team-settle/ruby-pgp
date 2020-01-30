module TempHelper
  def setup_temp_file(contents)
    stub = double
    allow(stub).to receive(:path).and_return(random_string)
    allow(stub).to receive(:write).with(contents)
    allow(Tempfile).to receive(:open).and_yield(stub)
    stub
  end

  protected

  def random_string(length=20)
    (0...length).map { (65 + rand(26)).chr }.join
  end
end