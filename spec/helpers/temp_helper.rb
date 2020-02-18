module TempHelper
  def setup_temp_paths(paths)
    allow(GPG::TempPathHelper).to receive(:create) do |&block|
      p = paths.pop
      block.call(p)
      p
    end
  end
end