require 'spec_helper'

describe OptimizePlayer::Proxies::ProjectProxy do
  subject { described_class.new(client) }
  let(:client) { OptimizePlayer::Client.new('access_token', 'secret_key') }

  before do
    allow(OptimizePlayer::Converter).to receive(:convert_to_object)
    allow(client).to receive(:send_request).and_return(response)
  end

  context '#all' do
    let(:response) { [] }

    it 'invokes send_request' do
      expect(client).to receive(:send_request).with('projects', :get, {})
      subject.all
    end

    it 'invokes send_request with params' do
      expect(client).to receive(:send_request).with('projects', :get, {:attr => 'value'})
      subject.all(:attr => 'value')
    end

    it 'invokes convertation' do
      expect(OptimizePlayer::Converter).to receive(:convert_to_object).with(subject, [])
      subject.all
    end
  end

  context '#find' do
    let(:response) { {} }

    it 'invokes send_request' do
      expect(client).to receive(:send_request).with('projects/1', :get)
      subject.find(1)
    end

    it 'invokes convertation' do
      expect(OptimizePlayer::Converter).to receive(:convert_to_object).with(subject, {})
      subject.find(1)
    end
  end

  context '#create' do
    let(:response) { {} }

    it 'invokes send_request with params' do
      expect(client).to receive(:send_request).with('projects', :post, {:attr => 'value'})
      subject.create(:attr => 'value')
    end

    it 'invokes convertation' do
      expect(OptimizePlayer::Converter).to receive(:convert_to_object).with(subject, {})
      subject.create(:attr => 'value')
    end
  end

  context '#move' do
    let(:response) { {} }

    it 'invokes send_request with params' do
      expect(client).to receive(:send_request).with('projects/move', :post, {:attr => 'value'})
      subject.move(:attr => 'value')
    end
  end
end
