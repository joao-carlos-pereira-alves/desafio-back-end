module Api
  module V1
    class RegistrationsController < ApplicationController
      def create
        result = CreateRegistration.call(create_params)

        if result.success?
          render json: { message: "Registro realizado com sucesso" }, status: :created
        else
          render json: {errors: result&.error }, status: :unprocessable_entity
        end
      end

      def index
        accounts = Account
                      .includes(entities: :users)

        render json: accounts.as_json(
          include: {
            entities: {
              include: :users
            }
          }
        )
      end

      private

      def create_params
        params.require(:account)
              .permit(:name, :from_partner, :many_partners, users: %i[email first_name last_name phone])
      end
    end
  end
end
