require 'spec_helper'
require 'active_support/all'
require 'doorkeeper/errors'
require 'doorkeeper/server'

describe Doorkeeper::Server do
  let(:fake_class) { double :fake_class }

  subject do
    described_class.new
  end

  describe '.authorization_request' do
    it 'raises error when strategy does not exist' do
      expect { subject.authorization_request(:duh) }.to raise_error(Doorkeeper::Errors::InvalidAuthorizationStrategy)
    end

    it 'raises error when strategy does not match phase' do
      expect { subject.token_request(:code) }.to raise_error(Doorkeeper::Errors::InvalidTokenStrategy)
    end

    context 'when set optional_grant_types configuration' do
      before { Doorkeeper::Request::Code.stub(:build) } # suppress error in Doorkeeper::Request::Code.build
      it 'does not raise error when strategy matches optional phase' do
        expect(Doorkeeper.configuration).to receive(:optional_grant_types).and_return %w[code]
        expect { subject.token_request(:code) }.to_not raise_error
      end
    end

    it 'builds the request with selected strategy' do
      stub_const 'Doorkeeper::Request::Code', fake_class
      fake_class.should_receive(:build).with(subject)
      subject.authorization_request :code
    end
  end
end
