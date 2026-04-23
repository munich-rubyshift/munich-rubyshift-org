class JasmineController < ApplicationController
  helper :all

  content_security_policy do |policy|
    policy.script_src :self, :unsafe_eval
  end

  etag { SecureRandom.hex(16) }

  def index
  end
end
