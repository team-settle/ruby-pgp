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

describe 'Nested Temp files' do
  it 'can be read externally' do
    file_contents1 = "3" * 300000
    actual = ''

    Tempfile.open do |f1|
      Tempfile.open do |f2|
        f1.write(file_contents1)
        f1.rewind

        buffer = File.read(f1.path)
        f2.write(buffer)
        f2.rewind

        actual = File.read(f2.path)
      end
    end

    expect(actual).to eq(file_contents1)
  end

  it 'can be read with its handler' do
    file_contents1 = "3" * 300000
    actual = ''

    Tempfile.open do |f1|
      Tempfile.open do |f2|
        f1.write(file_contents1)
        f1.rewind

        buffer = f1.read
        f2.write(buffer)
        f2.rewind

        buffer = f2.read
        actual << buffer
      end
    end

    expect(actual).to eq(file_contents1)
  end

  it 'can be read mixing approaches' do
    file_contents1 = "3" * 300000
    actual = ''

    Tempfile.open do |f1|
      Tempfile.open do |f2|
        f1.write(file_contents1)
        f1.rewind

        buffer = File.read(f1.path)
        File.write(f2.path, buffer)

        f2.rewind
        actual = f2.read
      end
    end

    expect(actual).to eq(file_contents1)
  end
end