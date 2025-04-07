# Controller to handle currency exchange logic
# Request sent to the ExchangeRate-API Open Access to get latest rates

require 'net/http'
require 'json'

class CurrencyController < ApplicationController
  # Displays the page for currency conversion
  def index
  end

  # Handles conversion from base to target currency
  def convert
    base = params[:base_currency].to_s.strip.upcase
    target = params[:target_currency].to_s.strip.upcase
    amount = params[:amount].to_s.strip     # User  - entered amount


    # Check if the fields are not empty
    if base.blank? || target.blank? || amount.blank?
      flash[:error] = "All fields are required."
      redirect_to root_path and return
    end

    # Convert the amount field to float after validation
    amount = amount.to_f

    url = URI("https://open.er-api.com/v6/latest/#{base}")
    response = Net::HTTP.get_response(url)
    data = JSON.parse(response.body)

    if data["result"] == "success"
      rate = data["rates"][target]

      if rate
        @converted_amount = (rate * amount).round(2)
        @rate = rate
      else
        flash[:error] = "Target currency '#{target}' not found."
        redirect_to root_path
      end
    else
      flash[:error] = data["error-type"] || "Something went wrong."
      redirect_to root_path
    end
  end
end
