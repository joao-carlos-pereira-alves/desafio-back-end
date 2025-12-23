class CreateAccount < ApplicationService
  def initialize(payload, from_fintera = false)
    @payload = payload
    @from_fintera = from_fintera
    @errors = []
  end

  def call
    account = Account.create!(account_params)
    entity  = Entity.create!(name: account.name, account: account)

    users = @payload[:users].map do |user|
      User.find_or_create_by!(email: user[:email]) do |u|
        u.first_name = user[:first_name]
        u.last_name  = user[:last_name]
        u.phone      = user[:phone].to_s.gsub(/\D/, "")
      end
    end

    users.each do |user|
      EntitiesUser.create!(entity: entity, user: user)
    end

    Result.new(true, account)
  rescue ActiveRecord::RecordInvalid => e
    Result.new(false, nil, e.record.errors.to_hash)
  end

  def is_account_valid?
    return false if @payload.blank?

    true
  end

  def account_params
    if @from_fintera
      {
        name: @payload[:name],
        active: true,
      }
    else
      {
        name: @payload[:name],
        active: false,
      }
    end
  end
end
