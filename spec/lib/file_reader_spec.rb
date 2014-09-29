require 'spec_helper'

describe FileReader do
  using FileReader

  describe '.read_if_exists' do
    it 'reads the file when it exists' do
      File.open('foo.ext', 'w+') { |f| f.write('stuff') }
      expect(File.read_if_exists('foo.ext')).to eq 'stuff'
      File.delete('foo.ext')
    end

    it 'returns nil if the file does not exist' do
      expect(File.read_if_exists('/path/to/non/existing/file.ext')).to eq nil
    end

    it 'returns nil if passed nil' do
      expect(File.read_if_exists(nil)).to eq nil
    end
  end
end
