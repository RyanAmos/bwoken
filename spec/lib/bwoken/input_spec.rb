require 'bwoken/input'
require 'stringio'

require 'spec_helper'

describe Bwoken::Input do
  let(:subject) { Bwoken::Input }

  describe '.precompile' do
    describe '"#import"' do
      let(:test_coffee) {"foo = 1\n#import bazzle.js\nbar = 2"}
      it 'splits #import statements from other statements' do
        subject.preprocess(test_coffee).should == [
          ["#import bazzle.js\n"],
          ["foo = 1\n", "bar = 2"]
        ]
      end
    end

    describe '"#github"' do
      let(:test_coffee) {"#github alexvollmer/tuneup_js\n#import bazzle.js\nfoo = 1\nbar = 2"}
      it 'converts github to import' do
        subject.preprocess(test_coffee).should == [
          ["#github alexvollmer/tuneup_js\n", "#import bazzle.js\n"],
          ["foo = 1\n", "bar = 2"]
        ]
      end
    end
  end

  describe '.coffee_script?' do
    context 'is coffee script' do
      it 'is true' do
        subject.coffee_script?("foo/bar.coffee").should be_true
      end
    end
    context 'is javascript' do
      it 'is false' do
        subject.coffee_script?("foo/bar.js").should be_false
      end
    end
  end

  describe '.process' do
    before do
      subject.stub(:preprocess => [[], []])
      IO.stub(:read)
      subject.stub(:write)
      subject.stub(:compile_to_javascript)
      subject.stub(:githubs_to_imports)
    end

    after { subject.process 'a', 'b' }

    it 'preprocesses' do
      subject.should_receive(:preprocess)
    end

    it 'script-compiles' do
      subject.should_receive(:compile_to_javascript)
    end

    it 'resolves github imports' do
      subject.should_receive(:githubs_to_imports)
    end

    it 'writes to disk' do
      subject.should_receive(:write)
    end
  end

  describe '.write' do
    it 'saves the javascript to the destination_file' do
      stringio = StringIO.new
      destination_file = 'bazzle/bar.js'

      File.should_receive(:open).with(destination_file, 'w').and_yield(stringio)

      subject.write('foo', '', 'bar', :to => destination_file)

      stringio.string.should == "foo\nbar\n"
    end
  end

end
