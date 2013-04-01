require 'spec_helper'

def gcm_supported?
  RUBY_VERSION >= '2.0.0' && OpenSSL::OPENSSL_VERSION >= 'OpenSSL 1.0.1c'
end

describe JSON::JWE do
  let(:plain_text) { 'Hello World' }
  let(:jwe) { JSON::JWE.new plain_text }

  shared_examples_for :gcm_encryption do
    context 'when enc=A128GCM' do
      before { jwe.enc = :A128GCM }

      it do
        jwe.encrypt! key
        p jwe.to_s
      end
    end

    context 'when enc=A256GCM' do
      before { jwe.enc = :A256GCM }

      it do
        jwe.encrypt! key
        p jwe.to_s
      end
    end
  end
  shared_examples_for :gcm_encryption_unsupported do
    context 'when enc=A128GCM' do
      before { jwe.enc = :A128GCM }

      it do
        expect do
          jwe.encrypt! key
        end.to raise_error JSON::JWE::UnexpectedAlgorithm
      end
    end

    context 'when enc=A256GCM' do
      before { jwe.enc = :A256GCM }

      it do
        expect do
          jwe.encrypt! key
        end.to raise_error JSON::JWE::UnexpectedAlgorithm
      end
    end
  end

  describe 'encrypt!' do
    context 'when alg=RSA-OAEP' do
      let(:key) { public_key }
      before { jwe.alg = :'RSA1_5' }

      if gcm_supported?
        it_behaves_like :gcm_encryption
      else
        it_behaves_like :gcm_encryption_unsupported
      end
    end

    context 'when alg=RSA-OAEP' do
      let(:key) { public_key }
      before { jwe.alg = :'RSA-OAEP' }

      if gcm_supported?
        it_behaves_like :gcm_encryption
      else
        it_behaves_like :gcm_encryption_unsupported
      end
    end

    context 'when alg=dir' do
      let(:key) { SecureRandom.hex 16 }
      before { jwe.alg = :dir }

      if gcm_supported?
        it_behaves_like :gcm_encryption

        it 'should use given key directly' do
          jwe.enc = :A256GCM
          jwe.key.should be_nil
          jwe.encrypt! key
          jwe.key.should == key
          jwe.encrypted_key.should == ''
        end
      else
        it_behaves_like :gcm_encryption_unsupported
      end
    end
  end
end