require 'spec_helper'

describe OptimizePlayer::Converter do
  let(:proxy) { OptimizePlayer::Proxies::ProjectProxy.new(client) }
  let(:client) { OptimizePlayer::Client.new('access_token', 'secret_key') }

  context 'collection' do
    let(:data) do
      [
        {
          "object_class" => "Project",
          "cid" => 'cid',
          "title" => 'Project Title'
        }
      ]
    end

    it 'returns only one object in collection' do
      result = described_class.convert_to_object(proxy, data)
      expect(result.length).to eq(1)
    end

    it 'returns converted object' do
      result = described_class.convert_to_object(proxy, data)
      expect(result[0]).to be_a_kind_of(OptimizePlayer::Project)
    end

    it 'returns project title' do
      result = described_class.convert_to_object(proxy, data)
      expect(result[0].title).to eq('Project Title')
    end

    it 'should raise NoMethoderror' do
      result = described_class.convert_to_object(proxy, data)
      expect { result[0].name }.to raise_error(NoMethodError, /undefined method `name'/)
    end
  end

  context 'object' do
    let(:data) do
      {
        "object_class" => "Project",
        "cid" => 'cid',
        "title" => 'Project Title'
      }
    end

    it 'returns converted object' do
      result = described_class.convert_to_object(proxy, data)
      expect(result).to be_a_kind_of(OptimizePlayer::Project)
    end

    it 'returns project title' do
      result = described_class.convert_to_object(proxy, data)
      expect(result.title).to eq('Project Title')
    end

    it 'should raise NoMethoderror' do
      result = described_class.convert_to_object(proxy, data)
      expect { result.name }.to raise_error(NoMethodError, /undefined method `name'/)
    end
  end
end
