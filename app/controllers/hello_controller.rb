# frozen_string_literal: true

class HelloController < ApplicationController
  def index
    c = Time.zone.now
    Rails.logger.debug c
    render plain: "Hello, world!"
  end
end
