module Masks
  class PrivateKey
    attr_reader :env

    def initialize(env)
      @env = env
    end

    def pathname
      Pathname.new(env.private_key)
    end

    def path
      pathname.to_s
    end

    def rsa_key
      File.exist?(path) ? OpenSSL::PKey::RSA.new(File.read(path)) : generate
    end

    def generate
      key = OpenSSL::PKey::RSA.new(2048)
      FileUtils.mkdir_p(pathname.dirname)
      File.write(path, key.to_pem)
      key
    end

    def secret_key
      @secret_key ||= env.secret_key&.presence || derive_secret("secret_key")
    end

    def encryption_key
      @encryption_key ||=
        env.encryption_key&.presence || derive_secret("encryption_key")
    end

    def deterministic_key
      @deterministic_key ||=
        env.deterministic_key&.presence || derive_secret("deterministic_key")
    end

    def salt
      @salt ||= env.salt&.presence || derive_secret("salt")
    end

    def derive_secret(purpose)
      hmac = OpenSSL::HMAC.new(rsa_key.to_der, OpenSSL::Digest::SHA256.new)
      hmac.update(purpose).hexdigest
    end
  end
end
