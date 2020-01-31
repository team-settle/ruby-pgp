require 'spec_helper'

describe 'RSpec multiple yields quirks' do
  it 'this should work' do
    stub1 = double
    allow(stub1).to receive(:path).and_return('path1')

    stub2 = double
    allow(stub2).to receive(:path).and_return('path2')

    allow(Tempfile).to receive(:open).and_return(stub1, stub2)

    paths = []
    Tempfile.open do |f1|
      Tempfile.open do |f2|
        paths = [f1.path, f2.path]
      end
    end
    expect(paths).to eq(['path1', 'path2'])
  end

  it 'workaround' do
    stub1 = double
    allow(stub1).to receive(:path).and_return('path1', 'path2')

    allow(Tempfile).to receive(:open).and_yield(stub1)

    paths = []
    Tempfile.open do |f1|
      Tempfile.open do |f2|
        paths = [f1.path, f2.path]
      end
    end
    expect(paths).to eq(['path1', 'path2'])
  end
end