require 'rails_helper'

RSpec.describe "Api::V1::RegistrationsController", type: :request do
  # Mock do objeto de resultado que o Service costuma retornar
  let(:success_result) { double('Result', success?: true, error: nil) }
  let(:failure_result) { double('Result', success?: false, error: { name: ["não pode ficar em branco"] }) }

  describe "POST #create" do
    let(:url) { "/api/v1/registrations" } # Ajuste se sua rota for diferente
    
    let(:valid_params) do
      {
        account: {
          name: Faker::Superhero.name,
          from_partner: true,
          many_partners: false,
          users: [{
            email: Faker::Internet.email,
            first_name: Faker::Name.female_first_name,
            last_name: Faker::Name.last_name,
            phone: "11999999999"
          }]
        }
      }
    end

    context "com parâmetros válidos" do
      it "retorna status 201 created e mensagem de sucesso" do
        # MUDANÇA AQUI: Use CreateRegistration para coincidir com o Controller
        expect(CreateRegistration).to receive(:call).and_return(success_result)

        post url, params: valid_params

        expect(response).to have_http_status(:created)
        expect(JSON.parse(response.body)).to include("message" => "Registro realizado com sucesso")
      end
    end

    context "quando o service falha (validação de modelo)" do
      it "retorna status 422 e os erros do service" do
        allow(CreateAccount).to receive(:call).and_return(failure_result)

        post url, params: valid_params

        expect(response).to have_http_status(:unprocessable_entity)
        expect(JSON.parse(response.body)).to have_key("errors")
      end
    end
  end

  describe "GET #index" do
    it "retorna a lista de contas com entidades e usuários" do
      # Criar dados reais se for teste de integração ou mockar se for funcional
      account = Account.create!(name: "Test Account", active: true)
      entity = Entity.create!(name: "Main Entity", account: account)
      user = User.create!(email: "test@test.com", first_name: "John", last_name: "Doe", phone: "11999999999")

      EntitiesUser.create!(entity: entity, user: user)

      get "/api/v1/registrations"

      json_response = JSON.parse(response.body)

      expect(response).to have_http_status(:ok)
      expect(json_response.first["entities"].first["users"]).to be_an(Array)
    end
  end
end