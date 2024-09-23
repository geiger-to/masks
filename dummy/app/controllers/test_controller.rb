# frozen_string_literal: true

class TestController < ApplicationController
  def anon
    render json: { anon: true }
  end

  def public
    render json: { public: masked_session.actor.actor_id }
  end

  def private
    render json: { private: masked_session.actor.actor_id }
  end
end
