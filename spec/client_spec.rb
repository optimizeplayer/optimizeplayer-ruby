require 'spec_helper'

describe OptimizePlayer::Client do
  subject { described_class.new('access_token', 'secret_key') }

  context 'proxies' do
    it 'returns account proxy' do
      expect(subject.account).to be_a_kind_of(OptimizePlayer::Proxies::AccountProxy)
    end

    it 'returns project proxy' do
      expect(subject.projects).to be_a_kind_of(OptimizePlayer::Proxies::ProjectProxy)
    end

    it 'returns asset proxy' do
      expect(subject.assets).to be_a_kind_of(OptimizePlayer::Proxies::AssetProxy)
    end

    it 'returns folder proxy' do
      expect(subject.folders).to be_a_kind_of(OptimizePlayer::Proxies::FolderProxy)
    end

    it 'returns integration proxy' do
      expect(subject.integrations).to be_a_kind_of(OptimizePlayer::Proxies::IntegrationProxy)
    end
  end

  describe '#send_request' do
    context 'url' do
      before do
        allow(RestClient::Request).to receive(:execute).and_return(response)
        allow_any_instance_of(OptimizePlayer::Signer).to receive(:sign_url).and_return('signed_url')
      end

      let(:response) { double(:body => {:key => 'value'}.to_json) }

      it 'executes with signed url' do
        expect(RestClient::Request).to receive(:execute).with(hash_including(:url => "signed_url"))
        subject.send_request('projects', :get)
      end

      it 'executes with signed url without a payload' do
        expect(RestClient::Request).to receive(:execute).with(hash_including(:url => "signed_url"))
        subject.send_request('projects', :get, {:attr => 'value'})
      end
    end

    context 'payload' do
      before do
        allow(RestClient::Request).to receive(:execute).and_return(response)
      end

      let(:response) { double(:body => {:key => 'value'}.to_json) }

      it 'executes without a payload' do
        expect(RestClient::Request).to receive(:execute).with(hash_including(:payload => nil))
        subject.send_request('projects', :get)
      end

      it 'executes with empty payload' do
        expect(RestClient::Request).to receive(:execute).with(hash_including(:payload => {}))
        subject.send_request('projects', :post)
      end

      it 'executes with empty payload' do
        expect(RestClient::Request).to receive(:execute).with(hash_including(:payload => {:attr => 'value'}))
        subject.send_request('projects', :post, {:attr => 'value'})
      end
    end

    context 'when response is success' do
      before do
        allow(RestClient::Request).to receive(:execute).and_return(response)
      end

      context 'with json' do
        let(:response) { double(:body => {:key => 'value'}.to_json) }

        it 'returns success json' do
          result = subject.send_request('projects', :get)
          expect(result).to eq({'key' => 'value'})
        end
      end

      context 'with non-json format' do
        let(:response) { double(:body => "simple string", :code => '200') }

        it 'returns success json' do
          expect {
            subject.send_request('projects', :get)
          }.to raise_error(OptimizePlayer::Errors::ApiError, /Invalid response object from API: "simple string"/)
        end
      end
    end

    context 'API errors' do
      let(:response_code) { nil }
      let(:response_body) { {:error => 'error', :message => 'message'}.to_json }

      before do
        allow_any_instance_of(RestClient::BadRequest).to receive(:http_code).and_return(response_code)
        allow_any_instance_of(RestClient::BadRequest).to receive(:http_body).and_return(response_body)
        allow(RestClient::Request).to receive(:execute).and_raise(RestClient::BadRequest)
      end

      context 'when 400 error is raised' do
        let(:response_code) { 400 }

        it 'should raise OptimizePlayer 400 error' do
          expect {
            subject.send_request('projects', :get)
          }.to raise_error { |error|
            expect(error.status).to eq(400)
            expect(error.error).to eq('error')
            expect(error.message).to eq('message')
            expect(error).to be_a(OptimizePlayer::Errors::BadRequest)
          }
        end
      end

      context 'when 401 error is raised' do
        let(:response_code) { 401 }

        it 'should raise OptimizePlayer 401 error' do
          expect {
            subject.send_request('projects', :get)
          }.to raise_error { |error|
            expect(error.status).to eq(401)
            expect(error.error).to eq('error')
            expect(error.message).to eq('message')
            expect(error).to be_a(OptimizePlayer::Errors::BadRequest)
          }
        end
      end

      context 'when 404 error is raised' do
        let(:response_code) { 404 }

        it 'should raise OptimizePlayer 404 error' do
          expect {
            subject.send_request('projects', :get)
          }.to raise_error { |error|
            expect(error.status).to eq(404)
            expect(error.error).to eq('error')
            expect(error.message).to eq('message')
            expect(error).to be_a(OptimizePlayer::Errors::BadRequest)
          }
        end
      end

      context 'when 403 error is raised' do
        let(:response_code) { 403 }

        it 'should raise OptimizePlayer 403 error' do
          expect {
            subject.send_request('projects', :get)
          }.to raise_error { |error|
            expect(error.status).to eq(403)
            expect(error.error).to eq('error')
            expect(error.message).to eq('message')
            expect(error).to be_a(OptimizePlayer::Errors::BadRequest)
          }
        end
      end

      context 'when 422 error is raised' do
        let(:response_code) { 422 }

        it 'should raise OptimizePlayer 422 error' do
          expect {
            subject.send_request('projects', :get)
          }.to raise_error { |error|
            expect(error.status).to eq(422)
            expect(error.error).to eq('error')
            expect(error.message).to eq('message')
            expect(error).to be_a(OptimizePlayer::Errors::BadRequest)
          }
        end
      end
    end

    context 'undefined errors' do
      before do
        allow(RestClient::Request).to receive(:execute).and_raise(RestClient::ExceptionWithResponse)
      end

      context 'when custom json error is raised' do
        before do
          allow_any_instance_of(RestClient::ExceptionWithResponse).to receive(:http_code).and_return(1111)
          allow_any_instance_of(RestClient::ExceptionWithResponse).to receive(:http_body).and_return({:error => 'error', :message => 'message'}.to_json)
        end

        it 'should raise OptimizePlayer API error' do
          expect {
            subject.send_request('projects', :get)
          }.to raise_error { |error|
            expect(error.error).to eq('error')
            expect(error.message).to eq('message')
            expect(error).to be_a(OptimizePlayer::Errors::ApiError)
          }
        end
      end

      context 'when custom non-json error is raised' do
        before do
          allow_any_instance_of(RestClient::ExceptionWithResponse).to receive(:http_code).and_return(nil)
          allow_any_instance_of(RestClient::ExceptionWithResponse).to receive(:http_body).and_return(nil)
        end

        it 'should raise OptimizePlayer UnhandledError' do
          expect {
            subject.send_request('projects', :get)
          }.to raise_error { |error|
            expect(error.error).to eq('UnhandledError')
            expect(error.message).to eq('Unexpected error communicating with OptimizePlayer.')
            expect(error).to be_a(OptimizePlayer::Errors::UnhandledError)
          }
        end
      end
    end

    context 'socket error' do
      before do
        allow(RestClient::Request).to receive(:execute).and_raise(SocketError)
      end

      it 'should raise OptimizePlayer SocketError' do
        expect {
          subject.send_request('projects', :get)
        }.to raise_error { |error|
          expect(error.error).to eq('NetworkError')
          expect(error.message).to eq('Unexpected error communicating when trying to connect to OptimizePlayer. You may be seeing this message because your DNS is not working.')
          expect(error).to be_a(OptimizePlayer::Errors::SocketError)
        }
      end
    end

    context 'Errno::ECONNREFUSED error' do
      before do
        allow(RestClient::Request).to receive(:execute).and_raise(Errno::ECONNREFUSED)
      end

      it 'should raise OptimizePlayer connection error' do
        expect {
          subject.send_request('projects', :get)
        }.to raise_error { |error|
          expect(error.error).to eq('ConnectionError')
          expect(error.message).to eq('Unexpected error communicating with OptimizePlayer.')
          expect(error).to be_a(OptimizePlayer::Errors::ConnectionError)
        }
      end
    end

    context 'Errno::ServerBrokeConnection error' do
      before do
        allow(RestClient::Request).to receive(:execute).and_raise(RestClient::ServerBrokeConnection)
      end

      it 'should raise OptimizePlayer connection error' do
        expect {
          subject.send_request('projects', :get)
        }.to raise_error { |error|
          expect(error.error).to eq('ConnectionError')
          expect(error.message).to eq('Could not connect to OptimizePlayer. Please check your internet connection and try again.')
          expect(error).to be_a(OptimizePlayer::Errors::ConnectionError)
        }
      end
    end

    context 'timeout error' do
      before do
        allow(RestClient::Request).to receive(:execute).and_raise(RestClient::RequestTimeout)
      end

      it 'should raise OptimizePlayer connection error' do
        expect {
          subject.send_request('projects', :get)
        }.to raise_error { |error|
          expect(error.error).to eq('ConnectionError')
          expect(error.message).to eq('Could not connect to OptimizePlayer. Please check your internet connection and try again.')
          expect(error).to be_a(OptimizePlayer::Errors::ConnectionError)
        }
      end
    end

    context '405 error' do
      before do
        allow(RestClient::Request).to receive(:execute).and_raise(RestClient::MethodNotAllowed)
        allow_any_instance_of(RestClient::MethodNotAllowed).to receive(:http_code).and_return(405)
        # APi returne 405 method with empty body
        allow_any_instance_of(RestClient::MethodNotAllowed).to receive(:http_body).and_return("")
      end

      it 'should raise OptimizePlayer 405 error' do
        expect {
          subject.send_request('projects', :get)
        }.to raise_error { |error|
          expect(error.error).to eq('MethodNotAllowed')
          expect(error.message).to eq('Method Not Allowed')
          expect(error).to be_a(OptimizePlayer::Errors::MethodNotAllowed)
        }
      end
    end
  end
end
