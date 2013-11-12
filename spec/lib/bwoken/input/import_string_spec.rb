require 'bwoken/input/import_string'

describe Bwoken::Input::ImportString do
  let(:string) { '#import foo.js' }
  subject { Bwoken::Input::ImportString.new(string) }

  describe '#parse' do
    it 'does not affect @string' do
      subject.parse
      expect(subject.instance_variable_get('@string')).to eq(string)
    end
  end

  its(:to_s) { should == string }
end
