require 'spec_helper'

describe Pushr::Configuration do

  describe 'all' do
    it 'returns all configurations' do
      expect(Pushr::Configuration.all).to eql([])
    end
  end
end
