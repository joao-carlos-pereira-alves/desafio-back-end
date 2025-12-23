class CreateRegistration < ApplicationService
  def initialize(payload)
    @payload = payload
  end

  def call
    error = validate_payload
    return error if error

    if @payload[:from_partner] == true && @payload[:many_partners] == true
      @result = create_account_and_notify_partners
    elsif @payload[:from_partner] == true
      @result = create_account_and_notify_partner
    else
      @result = create_account
    end

    return Result.new(true, @result.data) if @result.success?

    @result
  end

  private

  def validate_payload
    return fail!(:name, "não pode ficar em branco") unless @payload[:name].present?
    return fail!(:from_partner, "é obrigatório") unless boolean?(@payload[:from_partner])
    return fail!(:many_partners, "é obrigatório") unless boolean?(@payload[:many_partners])
    return fail!(:users, "é obrigatório") unless @payload[:users].is_a?(Array) && @payload[:users].any?

    user = @payload[:users].first
    %i[email first_name last_name phone].each do |field|
      return fail!(field, "é obrigatório") if user[field].blank?
    end

    nil
  end

  def boolean?(value)
    value == true || value == false
  end

  def fail!(field, message)
    Result.new(false, nil, { field => [message] })
  end

  def create_account_and_notify_partner
    CreateAccountAndNotifyPartner.call(@payload)
  end

  def create_account_and_notify_partners
    CreateAccountAndNotifyPartners.call(@payload)
  end

  def create_account
    if @payload[:name].include?("Fintera") && fintera_users(@payload) == true
      CreateAccount.call(@payload, true)
    else
      CreateAccount.call(@payload, false)
    end
  end

  def fintera_users(payload)
    with_fintera_user = false

    payload[:users].each do |user|
      with_fintera_user = true if user[:email].include? "fintera.com.br"
    end

    with_fintera_user
  end
end
