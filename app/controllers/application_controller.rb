class ApplicationController < ActionController::Base
  protect_from_forgery

  before_filter :set_locale

  # to test the locale
  def set_locale
    if %w{en ja}.include?(params[:hl])
      I18n.locale = params[:hl]
    end
  end
  private :set_locale
end
