RSpec.describe CreateRegistration do
  describe "#call" do
    subject(:call) { described_class.call(payload) }

    let(:fake_result) { ApplicationService::Result.new(true, double('Account')) }

    def build_payload(overrides = {})
      {
        name: "Empresa Teste",
        from_partner: false,
        many_partners: false,
        users: [{
          email: "user@example.com",
          first_name: "João",
          last_name: "Silva",
          phone: "11999999999"
        }]
      }.merge(overrides)
    end

    context "when account is from partner" do
      let(:payload) { build_payload(from_partner: true, name: "Parceiro A") }

      it "calls CreateAccountAndNotifyPartner service" do
        expect(CreateAccountAndNotifyPartner).to receive(:call)
          .with(hash_including(name: "Parceiro A"))
          .and_return(fake_result)

        call
      end
    end

    context "when account is from many partners" do
      let(:payload) { build_payload(from_partner: true, many_partners: true) }

      it "calls CreateAccountAndNotifyPartners service" do
        expect(CreateAccountAndNotifyPartners).to receive(:call)
          .with(hash_including(many_partners: true))
          .and_return(fake_result)

        call
      end
    end

    context "when account is not from a partner (Fintera Case)" do
      let(:payload) do 
        build_payload(
          name: "Fintera - New Account", 
          users: [{ email: "test@fintera.com.br", first_name: "A", last_name: "B", phone: "1" }]
        ) 
      end

      it "calls CreateAccount service with from_fintera as true" do
        expect(CreateAccount).to receive(:call).with(payload, true).and_return(fake_result)

        call
      end
    end

    describe "Validations" do
      it "returns error if name is blank" do
        payload = build_payload(name: "")
        result = described_class.call(payload)
        
        expect(result.success?).to be false
        expect(result.error).to have_key(:name)
      end

      it "returns error if from_partner is missing" do
        payload = build_payload.except(:from_partner)
        result = described_class.call(payload)
        
        expect(result.success?).to be false
        expect(result.error[:from_partner]).to include("é obrigatório")
      end
    end
  end
end